/* conform: run the suite's tests against one tool and judge each one.
 *
 * The tool is described by a config file of shell commands, one per stage and
 * language (see README.md, "Tool configs"). The harness never interprets the
 * testbench directives a tool reads (`//! bias`, `//! analysis`, ...); it only
 * decides the verdict from exit statuses, `ok=` lines, and expected outputs.
 *
 * POSIX C99, no dependencies: cc -O2 -o conform conform.c
 */
#define _XOPEN_SOURCE 700
#include <errno.h>
#include <fcntl.h>
#include <dirent.h>
#include <ftw.h>
#include <limits.h>
#include <math.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <time.h>
#include <unistd.h>

#define MAXCONF 64
#define MSG 512

static struct { char *key, *cmd; } conf[MAXCONF];
static int nconf;
static char conf_dir[PATH_MAX];
static char work_root[PATH_MAX];
static int timeout_s = 120;
static int jobs = 1;
static int verbose;
static int keep_work;

/* A file test reads its expectations from its own `//!` lines; a manifest
 * test from its row (`row`, with `mroot` the directory its paths start at). */
typedef struct {
    char *name, *path, *row, *mroot;
} Test;
static Test *tests;
static size_t ntests, captests;
static char **xfails;
static size_t nxfails;

static void die(const char *fmt, ...) {
    va_list ap;
    va_start(ap, fmt);
    fputs("conform: ", stderr);
    vfprintf(stderr, fmt, ap);
    fputc('\n', stderr);
    va_end(ap);
    exit(2);
}

static char *xstrdup(const char *s) {
    char *p = strdup(s);
    if (!p) die("out of memory");
    return p;
}

static char *trim(char *s) {
    while (*s == ' ' || *s == '\t') s++;
    char *e = s + strlen(s);
    while (e > s && (e[-1] == ' ' || e[-1] == '\t' || e[-1] == '\n' || e[-1] == '\r')) *--e = 0;
    return s;
}

/* Whole file into a NUL-terminated buffer; NULL if unreadable. */
static char *slurp(const char *path, size_t *len) {
    FILE *f = fopen(path, "rb");
    if (!f) return NULL;
    size_t cap = 4096, n = 0;
    char *buf = malloc(cap);
    size_t r;
    while (buf && (r = fread(buf + n, 1, cap - n - 1, f)) > 0) {
        n += r;
        if (cap - n < 2) buf = realloc(buf, cap *= 2);
    }
    fclose(f);
    if (!buf) die("out of memory");
    buf[n] = 0;
    if (len) *len = n;
    return buf;
}

static void load_conf(const char *path) {
    char *text = slurp(path, NULL);
    if (!text) die("cannot read %s", path);
    char *abs = realpath(path, NULL);
    if (!abs) die("cannot resolve %s", path);
    snprintf(conf_dir, sizeof conf_dir, "%s", abs);
    *strrchr(conf_dir, '/') = 0;
    free(abs);
    for (char *line = strtok(text, "\n"); line; line = strtok(NULL, "\n")) {
        char *s = trim(line);
        if (!*s || *s == '#') continue;
        char *eq = strchr(s, '=');
        if (!eq) die("%s: expected `key = command`: %s", path, s);
        *eq = 0;
        if (nconf == MAXCONF) die("%s: too many keys", path);
        conf[nconf].key = xstrdup(trim(s));
        conf[nconf].cmd = xstrdup(trim(eq + 1));
        nconf++;
    }
    free(text);
}

/* `stage.lang`, falling back to `stage.*`. */
static const char *command(const char *stage, const char *lang) {
    char want[64], any[64];
    snprintf(want, sizeof want, "%s.%s", stage, lang);
    snprintf(any, sizeof any, "%s.*", stage);
    const char *fallback = NULL;
    for (int i = 0; i < nconf; i++) {
        if (!strcmp(conf[i].key, want)) return conf[i].cmd;
        if (!strcmp(conf[i].key, any)) fallback = conf[i].cmd;
    }
    return fallback;
}

/* ---- discovery ------------------------------------------------------- */

static int has_ext(const char *p, const char *ext) {
    size_t n = strlen(p), e = strlen(ext);
    return n > e && !strcmp(p + n - e, ext);
}

static int is_source(const char *p) {
    return has_ext(p, ".va") || has_ext(p, ".vams") || has_ext(p, ".v") || has_ext(p, ".c");
}

/* `<dir>/<stem><suffix>` beside `path`. */
static void sibling(char *out, size_t cap, const char *path, const char *suffix) {
    snprintf(out, cap, "%s", path);
    char *dot = strrchr(out, '.');
    char *slash = strrchr(out, '/');
    if (dot && (!slash || dot > slash)) *dot = 0;
    strncat(out, suffix, cap - strlen(out) - 1);
}

/* A line that, trimmed, starts with `marker`; returns its body or NULL. */
static const char *directive(const char *line, const char *marker) {
    while (*line == ' ' || *line == '\t') line++;
    size_t m = strlen(marker);
    if (strncmp(line, marker, m)) return NULL;
    line += m;
    while (*line == ' ' || *line == '\t') line++;
    return line;
}

static int is_test(const char *path) {
    char gold[PATH_MAX];
    sibling(gold, sizeof gold, path, ".expected.txt");
    if (access(gold, F_OK) == 0) return 1;
    char *text = slurp(path, NULL);
    if (!text) return 0;
    int yes = 0;
    for (char *l = text; l && !yes; l = strchr(l, '\n') ? strchr(l, '\n') + 1 : NULL) {
        const char *d = directive(l, "//!");
        if (d && *d && *d != '\n') yes = has_ext(path, ".c") ? !strncmp(d, "design ", 7) : 1;
    }
    free(text);
    return yes;
}

static int locate(const char *abs, char *root, char *lang, const char **rel);

static void add_test(char *name, char *path, char *row, char *mroot) {
    if (ntests == captests) {
        captests = captests ? captests * 2 : 1024;
        tests = realloc(tests, captests * sizeof *tests);
        if (!tests) die("out of memory");
    }
    tests[ntests++] = (Test){name, path, row, mroot};
}

/* A manifest: `#root DIR` (relative to the manifest), then one test per row:
 * `lang<TAB>want<TAB>source[<TAB>gold|-][<TAB>KEY=VALUE...]`. */
static void collect_manifest(const char *path) {
    char *text = slurp(path, NULL);
    if (!text) die("cannot read %s", path);
    char *abs = realpath(path, NULL), mroot[PATH_MAX], stem[256];
    if (!abs) die("cannot resolve %s", path);
    snprintf(mroot, sizeof mroot, "%s", abs);
    *strrchr(mroot, '/') = 0;
    snprintf(stem, sizeof stem, "%s", strrchr(abs, '/') + 1);
    *strrchr(stem, '.') = 0;
    char *root = NULL;
    for (char *l = strtok(text, "\n"); l; l = strtok(NULL, "\n")) {
        if (!strncmp(l, "#root ", 6)) {
            char buf[PATH_MAX * 2];
            snprintf(buf, sizeof buf, "%s/%s", mroot, trim(l + 6));
            root = realpath(buf, NULL);
            if (!root) die("%s: root %s does not exist (git submodule update --init?)", path, buf);
            continue;
        }
        if (!*trim(l) || *l == '#') continue;
        if (!root) die("%s: a row before #root", path);
        char src[PATH_MAX], name[PATH_MAX];
        if (sscanf(l, "%*[^\t]\t%*[^\t]\t%4095[^\t]", src) != 1) die("%s: bad row: %s", path, l);
        snprintf(name, sizeof name, "%s/%s", stem, src);
        add_test(xstrdup(name), NULL, xstrdup(l), root);
    }
    free(abs);
    free(text);
}

static int collect(const char *path, const struct stat *st, int type, struct FTW *ftw) {
    (void)st;
    (void)ftw;
    if (type != FTW_F || strstr(path, "/include/")) return 0;
    if (has_ext(path, ".manifest")) return collect_manifest(path), 0;
    if (!is_source(path) || !is_test(path)) return 0;
    char abs[PATH_MAX], root[PATH_MAX], lang[64];
    const char *rel = NULL;
    if (!realpath(path, abs) || locate(abs, root, lang, &rel)) die("%s: not under a suite root (no include/ above it)", path);
    add_test(xstrdup(rel), xstrdup(abs), NULL, NULL);
    return 0;
}

static int by_name(const void *a, const void *b) { return strcmp(((const Test *)a)->name, ((const Test *)b)->name); }

/* The suite root is the nearest ancestor holding `include/`; the language is
 * the directory right below it. `rel` is the path from the root. */
static int locate(const char *abs, char *root, char *lang, const char **rel) {
    snprintf(root, PATH_MAX, "%s", abs);
    char probe[PATH_MAX + 16];
    for (char *s; (s = strrchr(root, '/')) && s != root;) {
        *s = 0;
        snprintf(probe, sizeof probe, "%s/include", root);
        struct stat st;
        if (stat(probe, &st) == 0 && S_ISDIR(st.st_mode)) {
            *rel = abs + strlen(root) + 1;
            const char *slash = strchr(*rel, '/');
            if (!slash) return -1;
            snprintf(lang, 64, "%.*s", (int)(slash - *rel), *rel);
            if (has_ext(abs, ".c")) snprintf(lang, 64, "vpi");
            return 0;
        }
    }
    return -1;
}

/* ---- one test -------------------------------------------------------- */

typedef struct {
    int reject, reject_run, exit_want, checks_want, needs_run, self_checks, passed;
    char *stdout_want[16];
    int nstdout;
    char *vcd_out, *vcd_gold;
    char *files, *libmap, *liblist, *std;
    char gold[PATH_MAX], errgold[PATH_MAX]; /* empty: none */
    char *filter;                           /* applied to stdout and gold alike */
    double rtol, atol;                      /* gold numbers within tolerance */
} Spec;

static void append(char **dst, const char *word) {
    size_t n = *dst ? strlen(*dst) : 0;
    *dst = realloc(*dst, n + strlen(word) + 2);
    if (!*dst) die("out of memory");
    if (n) (*dst)[n++] = ' ';
    strcpy(*dst + n, word);
}

/* `//@` paths are relative to the test; tools get them absolute. */
static void append_paths(char **dst, const char *words, const char *dir) {
    char buf[1024], path[PATH_MAX];
    snprintf(buf, sizeof buf, "%s", words);
    for (char *w = strtok(buf, " \t"); w; w = strtok(NULL, " \t")) {
        snprintf(path, sizeof path, "%s/%s", dir, w);
        append(dst, path);
    }
}

static int kw_is(const char *d, size_t n, const char *kw) { return strlen(kw) == n && !strncmp(d, kw, n); }

/* Metadata directives say what a test cites; any other `//!` keyword is a
 * testbench the tool must run. */
static int is_meta(const char *kw, size_t n) {
    static const char *meta[] = {"lrm", "inherited", "lrm-reject", "inherited-reject", "neighbour",
                                 "reject", "reject-only", "warn", "nowarn", NULL};
    for (int i = 0; meta[i]; i++)
        if (kw_is(kw, n, meta[i])) return 1;
    return 0;
}

static int parse(const char *src, const char *dir, Spec *sp, char *why) {
    memset(sp, 0, sizeof *sp);
    sp->checks_want = -1;
    int exit_set = 0;
    char *text = slurp(src, NULL);
    if (!text) return snprintf(why, MSG, "cannot read source"), -1;
    sp->self_checks = strstr(text, "`CHECK") || strstr(text, "ok=");
    for (char *l = text, *next; l; l = next) {
        next = strchr(l, '\n');
        if (next) *next++ = 0;
        const char *d;
        if ((d = directive(l, "//@"))) {
            char kw[32] = {0}, rest[1024] = {0};
            sscanf(d, "%31s %1023[^\r]", kw, rest);
            if (!strcmp(kw, "files")) append_paths(&sp->files, rest, dir);
            else if (!strcmp(kw, "libmap")) append_paths(&sp->libmap, rest, dir);
            else if (!strcmp(kw, "liblist")) append(&sp->liblist, rest);
            else if (!strcmp(kw, "std")) append(&sp->std, rest);
            else return snprintf(why, MSG, "unknown directive //@ %s", kw), free(text), -1;
            continue;
        }
        if (!(d = directive(l, "//!")) || !*d) continue;
        size_t kn = strcspn(d, " \t\r");
        const char *arg = d + kn + strspn(d + kn, " \t");
        if (kw_is(d, kn, "reject") || kw_is(d, kn, "reject-only")) sp->reject = 1;
        else if (kw_is(d, kn, "reject-run")) sp->reject_run = 1;
        else if (kw_is(d, kn, "exit")) sp->exit_want = atoi(arg), exit_set = 1;
        else if (kw_is(d, kn, "checks")) sp->checks_want = atoi(arg);
        else if (kw_is(d, kn, "stdout") && sp->nstdout < 16) sp->stdout_want[sp->nstdout++] = xstrdup(trim((char *)arg));
        else if (kw_is(d, kn, "expect")) {
            char out[256], gold[256];
            if (sscanf(arg, "vcd %255s == %255s", out, gold) != 2)
                return snprintf(why, MSG, "bad //! expect: %s", arg), free(text), -1;
            sp->vcd_out = xstrdup(out);
            sp->vcd_gold = xstrdup(gold);
        }
        if (!is_meta(d, kn)) sp->needs_run = 1;
    }
    free(text);
    if (sp->reject_run && !exit_set) sp->exit_want = -1; /* any normal failure */
    sibling(sp->gold, sizeof sp->gold, src, ".expected.txt");
    if (access(sp->gold, F_OK)) *sp->gold = 0;
    sibling(sp->errgold, sizeof sp->errgold, src, ".expected.stderr.txt");
    if (access(sp->errgold, F_OK)) *sp->errgold = 0;
    if (*sp->gold || sp->self_checks || has_ext(src, ".c")) sp->needs_run = 1;
    return 0;
}

/* A manifest row into `sp`, `lang` and `src`; KEY=VALUE columns are exported
 * as CONFORM_KEY. */
static int parse_row(char *row, const char *mroot, Spec *sp, char *lang, char *src, char *why) {
    memset(sp, 0, sizeof *sp);
    sp->checks_want = -1;
    char *col[32];
    int n = 0;
    for (char *c = strtok(row, "\t"); c && n < 32; c = strtok(NULL, "\t")) col[n++] = c;
    if (n < 3) return snprintf(why, MSG, "manifest row has %d columns", n), -1;
    snprintf(lang, 64, "%s", col[0]);
    snprintf(src, PATH_MAX, "%s/%s", mroot, col[2]);
    const char *w = col[1];
    if (!strcmp(w, "ok")) sp->needs_run = 1;
    else if (!strcmp(w, "passed")) sp->needs_run = sp->passed = 1;
    else if (!strcmp(w, "compile")) ;
    else if (!strcmp(w, "reject")) sp->reject = 1;
    else if (!strcmp(w, "reject-run")) sp->reject_run = sp->needs_run = 1, sp->exit_want = -1;
    else return snprintf(why, MSG, "unknown want `%s`", w), -1;
    if (n > 3 && strcmp(col[3], "-")) snprintf(sp->gold, sizeof sp->gold, "%s/%s", mroot, col[3]);
    for (int i = 4; i < n; i++) {
        char *eq = strchr(col[i], '=');
        if (!eq) return snprintf(why, MSG, "column `%s` is not KEY=VALUE", col[i]), -1;
        *eq = 0;
        char key[64];
        snprintf(key, sizeof key, "CONFORM_%s", col[i]);
        setenv(key, eq + 1, 1);
        if (!strcmp(col[i], "FILTER")) sp->filter = eq + 1;
        if (!strcmp(col[i], "RTOL")) sp->rtol = atof(eq + 1);
        if (!strcmp(col[i], "ATOL")) sp->atol = atof(eq + 1);
    }
    return 0;
}

/* Every top-level entry of a manifest's root, linked into the work
 * directory: an upstream suite's tests read paths relative to its root. */
static void link_root(const char *mroot, const char *work) {
    DIR *d = opendir(mroot);
    if (!d) return;
    char from[PATH_MAX * 2], to[PATH_MAX * 2];
    for (struct dirent *e; (e = readdir(d));) {
        if (e->d_name[0] == '.') continue;
        snprintf(from, sizeof from, "%s/%s", mroot, e->d_name);
        snprintf(to, sizeof to, "%s/%s", work, e->d_name);
        symlink(from, to);
    }
    closedir(d);
}

static void setenv_opt(const char *k, const char *v) {
    if (v) setenv(k, v, 1);
    else unsetenv(k);
}

/* Link every file the source names that exists beside the test into the work
 * directory (`$readmemh("x.hex")`, `//! data x.bin`), so a test reads its
 * inputs from the directory it runs in and its writes stay out of the tree.
 * ponytail: names with a `/` are not linked; add when a test reads one. */
static void link_inputs(const char *src, const char *dir, const char *work) {
    char *text = slurp(src, NULL);
    if (!text) return;
    static const char word[] = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_.+-";
    char from[PATH_MAX], to[PATH_MAX];
    for (char *p = text; *p;) {
        size_t n = strspn(p, word);
        if (!n) {
            p++;
            continue;
        }
        char c = p[n];
        p[n] = 0;
        if (strchr(p, '.') && strcmp(p, ".") && strcmp(p, "..") && n < 256) {
            snprintf(from, sizeof from, "%s/%s", dir, p);
            snprintf(to, sizeof to, "%s/%s", work, p);
            struct stat st;
            if (stat(from, &st) == 0 && S_ISREG(st.st_mode)) symlink(from, to);
        }
        p[n] = c;
        p += n;
    }
    free(text);
}

typedef struct {
    int status; /* exit code, or -1 signal, -2 timeout */
    char *out, *err;
} Stage;

static Stage run_stage(const char *cmd, const char *work, const char *name) {
    Stage s = {0};
    char out[PATH_MAX], err[PATH_MAX];
    snprintf(out, sizeof out, "%s/%s.stdout", work, name);
    snprintf(err, sizeof err, "%s/%s.stderr", work, name);
    pid_t pid = fork();
    if (pid < 0) die("fork: %s", strerror(errno));
    if (pid == 0) {
        setpgid(0, 0);
        int o = open(out, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        int e = open(err, O_WRONLY | O_CREAT | O_TRUNC, 0644);
        int nul = open("/dev/null", O_RDONLY);
        if (o < 0 || e < 0 || nul < 0 || chdir(work)) _exit(126);
        dup2(nul, 0), dup2(o, 1), dup2(e, 2);
        execl("/bin/sh", "sh", "-c", cmd, (char *)NULL);
        _exit(127);
    }
    setpgid(pid, pid);
    int st;
    struct timespec tick = {0, 5000000};
    time_t deadline = time(NULL) + timeout_s;
    for (;;) {
        pid_t r = waitpid(pid, &st, WNOHANG);
        if (r == pid) break;
        if (r < 0 && errno != EINTR) die("waitpid: %s", strerror(errno));
        if (time(NULL) >= deadline) {
            kill(-pid, SIGKILL);
            waitpid(pid, &st, 0);
            s.status = -2;
            goto done;
        }
        nanosleep(&tick, NULL);
    }
    s.status = WIFEXITED(st) ? WEXITSTATUS(st) : -1;
    kill(-pid, SIGKILL); /* stray background children */
done:
    s.out = slurp(out, NULL);
    s.err = slurp(err, NULL);
    if (!s.out) s.out = xstrdup("");
    if (!s.err) s.err = xstrdup("");
    return s;
}

static const char *describe(const Stage *s, const char *name, char *buf) {
    if (s->status == -2) snprintf(buf, MSG, "%s timed out after %ds", name, timeout_s);
    else if (s->status == -1) snprintf(buf, MSG, "%s crashed (signal)", name);
    else if (s->status >= 126) snprintf(buf, MSG, "%s could not run the command (exit %d)", name, s->status);
    else snprintf(buf, MSG, "%s exited %d", name, s->status);
    return buf;
}

/* A diagnosed failure: a normal nonzero exit, not a crash, timeout or a
 * command the shell could not run. */
static int diagnosed(const Stage *s) { return s->status >= 1 && s->status <= 125; }

static int count(const char *hay, const char *needle) {
    int n = 0;
    for (const char *p = hay; (p = strstr(p, needle)); p += strlen(needle)) n++;
    return n;
}

/* VCD tokens with the `$date` and `$version` bodies dropped (IEEE 1364
 * §18.2.3.2, §18.2.3.8: tool-specific text). */
static char *vcd_norm(char *text) {
    char *out = malloc(strlen(text) + 1), *o = out;
    if (!out) die("out of memory");
    int skip = 0;
    for (char *t = strtok(text, " \t\r\n"); t; t = strtok(NULL, " \t\r\n")) {
        if (skip && strcmp(t, "$end")) continue;
        skip = !strcmp(t, "$date") || !strcmp(t, "$version");
        o += sprintf(o, "%s ", t);
    }
    *o = 0;
    return out;
}

/* Judges the output of the stage that produced the program's transcript. */
/* `file` through the shell command `filter`. */
static char *filtered(const char *filter, const char *file, const char *work, const char *name) {
    size_t n = strlen(filter) + strlen(file) + 16;
    char *cmd = malloc(n);
    if (!cmd) die("out of memory");
    snprintf(cmd, n, "(%s) < '%s'", filter, file);
    Stage f = run_stage(cmd, work, name);
    free(cmd);
    free(f.err);
    return f.out;
}

/* Same whitespace-separated tokens, where two numbers also match when
 * |a - b| <= atol + rtol * max(|a|, |b|). */
static int same_within(char *a, char *b, double rtol, double atol) {
    char *sa, *sb;
    char *x = strtok_r(a, " \t\r\n", &sa), *y = strtok_r(b, " \t\r\n", &sb);
    for (; x && y; x = strtok_r(NULL, " \t\r\n", &sa), y = strtok_r(NULL, " \t\r\n", &sb)) {
        if (!strcmp(x, y)) continue;
        char *ex, *ey;
        double u = strtod(x, &ex), v = strtod(y, &ey);
        if (*ex || *ey || ex == x || ey == y) return 0;
        double m = fabs(u) > fabs(v) ? fabs(u) : fabs(v);
        if (fabs(u - v) > atol + rtol * m) return 0;
    }
    return !x && !y;
}

static int passed_line(const char *out) {
    for (const char *l = out; l; l = strchr(l, '\n') ? strchr(l, '\n') + 1 : NULL) {
        while (*l == ' ' || *l == '\t') l++;
        if (!strncasecmp(l, "passed", 6) && strspn(l + 6, " \t\r") == strcspn(l + 6, "\n")) return 1;
    }
    return 0;
}

static int judge_output(const char *dir, const char *work, const Spec *sp, const Stage *s, char *why) {
    char *want;
    if (*sp->gold) {
        char *got;
        if (sp->filter) {
            char out[PATH_MAX + 16];
            snprintf(out, sizeof out, "%s/run.stdout", work);
            got = filtered(sp->filter, out, work, "filtered-run");
            want = filtered(sp->filter, sp->gold, work, "filtered-gold");
        } else {
            got = xstrdup(s->out);
            want = slurp(sp->gold, NULL);
        }
        int same = want && (sp->rtol > 0 || sp->atol > 0 ? same_within(want, got, sp->rtol, sp->atol) : !strcmp(want, got));
        free(want), free(got);
        if (!same) return snprintf(why, MSG, "stdout differs from %s", strrchr(sp->gold, '/') + 1), 0;
    }
    if (*sp->errgold && (want = slurp(sp->errgold, NULL))) {
        /* stderr is shared with the tool's own diagnostics: contained, not equal */
        int has = strstr(s->err, want) != NULL;
        free(want);
        if (!has) return snprintf(why, MSG, "stderr lacks %s", strrchr(sp->errgold, '/') + 1), 0;
    }
    if (sp->passed && !passed_line(s->out)) return snprintf(why, MSG, "no PASSED line"), 0;
    for (int i = 0; i < sp->nstdout; i++)
        if (!strstr(s->out, sp->stdout_want[i])) return snprintf(why, MSG, "stdout lacks \"%s\"", sp->stdout_want[i]), 0;
    int bad = count(s->out, "ok=0"), all = count(s->out, "ok=");
    if (bad) return snprintf(why, MSG, "%d of %d assertion(s) reported ok=0", bad, all), 0;
    if (sp->checks_want >= 0 && all != sp->checks_want)
        return snprintf(why, MSG, "expected exactly %d ok= line(s), got %d", sp->checks_want, all), 0;
    if (sp->self_checks && all == 0 && !sp->reject && !sp->reject_run)
        return snprintf(why, MSG, "no assertion printed an ok= line"), 0;
    if (sp->vcd_out) {
        char a[PATH_MAX], b[PATH_MAX];
        snprintf(a, sizeof a, "%s/%s", work, sp->vcd_out);
        snprintf(b, sizeof b, "%s/%s", dir, sp->vcd_gold);
        char *x = slurp(a, NULL), *y = slurp(b, NULL);
        int same = 0;
        if (x && y) {
            char *nx = vcd_norm(x), *ny = vcd_norm(y);
            same = !strcmp(nx, ny);
            free(nx), free(ny);
        }
        free(x), free(y);
        if (!same) return snprintf(why, MSG, "%s differs from %s", sp->vcd_out, sp->vcd_gold), 0;
    }
    return 1;
}

static int rm_entry(const char *p, const struct stat *st, int t, struct FTW *f) {
    (void)st, (void)t, (void)f;
    return remove(p);
}

enum { PASS, FAIL, SKIP, ACCEPT }; /* ACCEPT: compiled, run stage absent */
static const char *names[] = {"PASS", "FAIL", "SKIP", "PASS"};

/* Runs one test; `why` explains a FAIL or SKIP. */
static int run_test(const Test *t, size_t index, char *why) {
    char abs[PATH_MAX], root[PATH_MAX], lang[64], dir[PATH_MAX], work[PATH_MAX + 32], inc[PATH_MAX + 16];
    const char *rel = t->name;
    Spec sp;
    char row[8192]; /* sp.filter points into it */
    if (t->row) {
        snprintf(row, sizeof row, "%s", t->row);
        if (parse_row(row, t->mroot, &sp, lang, abs, why)) return FAIL;
        snprintf(root, sizeof root, "%s", t->mroot);
        rel = abs + strlen(root) + 1;
    } else {
        snprintf(abs, sizeof abs, "%s", t->path);
        if (locate(abs, root, lang, &rel)) return snprintf(why, MSG, "not under a suite root"), FAIL;
    }
    snprintf(dir, sizeof dir, "%s", abs);
    *strrchr(dir, '/') = 0;
    if (!t->row && parse(abs, dir, &sp, why)) return FAIL;
    const char *cc = command("compile", lang), *rc = command("run", lang);
    if (!cc && !rc) return snprintf(why, MSG, "tool has no command for %s", lang), SKIP;
    if (sp.reject_run && !rc) return snprintf(why, MSG, "reject-run needs a run command"), SKIP;
    if (!sp.reject && !sp.needs_run) rc = cc ? NULL : rc; /* accept test: compiling is enough */
    if (sp.reject && !sp.needs_run && cc) rc = NULL;

    snprintf(work, sizeof work, "%s/%zu", work_root, index);
    if (mkdir(work, 0755) && errno != EEXIST) die("mkdir %s: %s", work, strerror(errno));
    snprintf(inc, sizeof inc, t->row ? "%s" : "%s/include", root);
    char *stem = xstrdup(strrchr(abs, '/') + 1);
    if (strrchr(stem, '.')) *strrchr(stem, '.') = 0;
    setenv("CONFORM_SRC", abs, 1);
    setenv("CONFORM_REL", rel, 1);
    setenv("CONFORM_DIR", dir, 1);
    setenv("CONFORM_STEM", stem, 1);
    setenv("CONFORM_WORK", work, 1);
    setenv("CONFORM_LANG", lang, 1);
    setenv("CONFORM_INCLUDE", inc, 1);
    setenv("CONFORM_TOOLDIR", conf_dir, 1);
    setenv_opt("CONFORM_FILES", sp.files);
    setenv_opt("CONFORM_LIBMAP", sp.libmap);
    setenv_opt("CONFORM_LIBLIST", sp.liblist);
    setenv_opt("CONFORM_STD", sp.std);
    free(stem);
    if (t->row) link_root(root, work);
    else link_inputs(abs, dir, work);

    char d[MSG];
    int verdict = PASS;
    Stage c = {0, NULL, NULL}, r = {0, NULL, NULL};
    if (cc) {
        c = run_stage(cc, work, "compile");
        if (c.status != 0) {
            if (sp.reject && diagnosed(&c)) verdict = PASS;
            else snprintf(why, MSG, "%s", describe(&c, "compile", d)), verdict = FAIL;
            goto out;
        }
    }
    if (!rc) {
        if (sp.reject) snprintf(why, MSG, "compiled cleanly; expected a rejection"), verdict = FAIL;
        else if (sp.needs_run) verdict = ACCEPT;
        goto out;
    }
    r = run_stage(rc, work, "run");
    if (r.status == 77) { /* the tool cannot express this testbench */
        const char *e = *r.err ? r.err : "run stage skipped (exit 77)";
        snprintf(why, MSG, "%.*s", (int)strcspn(e, "\n"), e);
        verdict = SKIP;
        goto out;
    }
    if (sp.reject || sp.reject_run) {
        int ok = sp.exit_want > 0 ? r.status == sp.exit_want : diagnosed(&r);
        if (!ok) {
            if (r.status == 0) snprintf(why, MSG, "ran cleanly; expected a rejection");
            else snprintf(why, MSG, "%s", describe(&r, "run", d));
            verdict = FAIL;
        } else if (!judge_output(dir, work, &sp, &r, why)) verdict = FAIL;
        goto out;
    }
    if (r.status != sp.exit_want) {
        snprintf(why, MSG, "%s", describe(&r, "run", d));
        if (r.status >= 0 && r.status < 126) {
            const char *e = *r.err ? r.err : r.out;
            size_t n = strcspn(e, "\n");
            snprintf(why + strlen(why), MSG - strlen(why), ": %.*s", (int)(n > 200 ? 200 : n), e);
        }
        verdict = FAIL;
    } else if (!judge_output(dir, work, &sp, &r, why)) verdict = FAIL;
out:
    free(c.out), free(c.err), free(r.out), free(r.err);
    if (verdict != FAIL && !keep_work) nftw(work, rm_entry, 16, FTW_DEPTH | FTW_PHYS);
    return verdict;
}

/* ---- driver ---------------------------------------------------------- */

static void load_xfails(const char *path) {
    char *text = slurp(path, NULL);
    if (!text) die("cannot read %s", path);
    for (char *l = strtok(text, "\n"); l; l = strtok(NULL, "\n")) {
        l = trim(l);
        if (!*l || *l == '#') continue;
        l[strcspn(l, " \t")] = 0;
        xfails = realloc(xfails, (nxfails + 1) * sizeof *xfails);
        if (!xfails) die("out of memory");
        xfails[nxfails++] = xstrdup(l);
    }
    free(text);
}

static int expected_fail(const char *name) {
    for (size_t i = 0; i < nxfails; i++)
        if (!strcmp(xfails[i], name)) return 1;
    return 0;
}

static void usage(void) {
    fputs("usage: conform -t TOOL.conf [-j N] [-x XFAIL] [-T SECONDS] [-o RESULTS.tsv] [-k] [-v] PATH...\n"
          "  PATH      test files, directories under a suite root (tests/), or .manifest files\n"
          "  -t        the tool config: `stage.language = shell command` lines\n"
          "  -j        tests run in parallel (default 1)\n"
          "  -x        expected failures: one test name (as printed) per line\n"
          "  -T        per-stage timeout (default 120)\n"
          "  -o        write every verdict as `STATUS<TAB>path<TAB>detail`\n"
          "  -k        keep every work directory (failures always keep theirs)\n"
          "  -v        print passing tests too\n",
          stderr);
    exit(2);
}

int main(int argc, char **argv) {
    const char *tool = NULL, *results = NULL;
    int opt;
    while ((opt = getopt(argc, argv, "t:j:x:T:o:kv")) != -1) {
        switch (opt) {
        case 't': tool = optarg; break;
        case 'j': jobs = atoi(optarg) > 0 ? atoi(optarg) : 1; break;
        case 'x': load_xfails(optarg); break;
        case 'T': timeout_s = atoi(optarg) > 0 ? atoi(optarg) : 1; break;
        case 'o': results = optarg; break;
        case 'k': keep_work = 1; break;
        case 'v': verbose = 1; break;
        default: usage();
        }
    }
    if (!tool || optind == argc) usage();
    load_conf(tool);
    for (int i = optind; i < argc; i++) {
        struct stat st;
        if (stat(argv[i], &st)) die("%s: %s", argv[i], strerror(errno));
        if (S_ISDIR(st.st_mode)) nftw(argv[i], collect, 32, FTW_PHYS);
        else collect(argv[i], &st, FTW_F, NULL);
    }
    if (!ntests) die("no tests found");
    qsort(tests, ntests, sizeof *tests, by_name);

    const char *tmp = getenv("TMPDIR");
    snprintf(work_root, sizeof work_root, "%s/conform.XXXXXX", tmp ? tmp : "/tmp");
    if (!mkdtemp(work_root)) die("mkdtemp: %s", strerror(errno));

    FILE *tsv = results ? fopen(results, "w") : NULL;
    if (results && !tsv) die("cannot write %s", results);

    /* One child per test, `jobs` at a time; each reports through a pipe. */
    pid_t *pids = calloc(jobs, sizeof *pids);
    int *fds = calloc(jobs, sizeof *fds);
    size_t *which = calloc(jobs, sizeof *which);
    size_t next = 0, done = 0, tally[6] = {0}; /* PASS FAIL SKIP XFAIL XPASS compile-only */
    signal(SIGPIPE, SIG_IGN);
    while (done < ntests) {
        for (int slot = 0; slot < jobs && next < ntests; slot++) {
            if (pids[slot]) continue;
            int p[2];
            if (pipe(p)) die("pipe: %s", strerror(errno));
            fflush(NULL);
            pid_t pid = fork();
            if (pid < 0) die("fork: %s", strerror(errno));
            if (pid == 0) {
                close(p[0]);
                char why[MSG] = "";
                int v = run_test(&tests[next], next, why);
                dprintf(p[1], "%d\t%s", v, why);
                _exit(0);
            }
            close(p[1]);
            pids[slot] = pid, fds[slot] = p[0], which[slot] = next++;
        }
        int st;
        pid_t pid = wait(&st);
        if (pid < 0) die("wait: %s", strerror(errno));
        int slot = 0;
        while (slot < jobs && pids[slot] != pid) slot++;
        if (slot == jobs) continue;
        char buf[MSG + 16] = "";
        ssize_t n = read(fds[slot], buf, sizeof buf - 1);
        close(fds[slot]);
        pids[slot] = 0;
        done++;
        const char *path = tests[which[slot]].name;
        int v = n > 0 ? atoi(buf) : FAIL;
        const char *why = n > 0 && strchr(buf, '\t') ? strchr(buf, '\t') + 1 : "harness child died";
        const char *status = names[v];
        int xf = expected_fail(path);
        if (xf && v == FAIL) status = "XFAIL", tally[3]++;
        else if (xf && (v == PASS || v == ACCEPT)) status = "XPASS", why = "expected to fail, passed", tally[4]++;
        else tally[v == ACCEPT ? 5 : v]++;
        if (v == ACCEPT && !xf) why = "compile-only: the tool has no run command";
        if (verbose || (strcmp(status, "PASS") && strcmp(status, "SKIP") && strcmp(status, "XFAIL")))
            printf("%-5s %s%s%s\n", status, path, *why ? ": " : "", why);
        if (tsv) fprintf(tsv, "%s\t%s\t%s\n", status, path, why);
    }
    if (tsv) fclose(tsv);
    if (!keep_work) rmdir(work_root); /* only empty when nothing failed */
    printf("\n%zu tests: %zu passed, %zu compile-only, %zu failed, %zu skipped, %zu xfail, %zu xpass\n", ntests, tally[0],
           tally[5], tally[1], tally[2], tally[3], tally[4]);
    if (tally[1] || tally[4]) printf("work directories of failures: %s\n", work_root);
    return tally[1] || tally[4];
}
