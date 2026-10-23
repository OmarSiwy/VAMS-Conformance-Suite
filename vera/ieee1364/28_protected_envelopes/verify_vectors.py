"""Check the committed public DES vectors independently of VerA.

Requires OpenSSL with its DES legacy provider. This validates test data; it
does not supply protected-envelope conformance evidence for the engine.
"""
import base64
import binascii
import hashlib
import json
from pathlib import Path
import re
import subprocess


ROOT = Path(__file__).resolve().parent
PROFILE = json.loads((ROOT / "known_keys.json").read_text())
KEYS = {key["name"]: key["key_hex"] for key in PROFILE["keys"]}


def decrypt(cipher, key):
    return subprocess.run(
        ["openssl", "enc", "-d", "-des-cbc", "-provider", "legacy", "-provider", "default",
         "-K", key, "-iv", PROFILE["profile"]["iv_hex"]],
        input=cipher, check=True, capture_output=True,
    ).stdout


def blocks(text):
    result = {}
    pattern = (r'`pragma protect encoding=\(enctype="([^"]+)",line_length=\d+,bytes=(\d+)\)\n'
               r'`pragma protect (\w+)\n((?:(?!^`pragma)[^\n]*\n)*)')
    for encoding, count, kind, payload in re.findall(pattern, text, re.MULTILINE):
        if encoding == "base64":
            decoded = base64.b64decode("".join(payload.split()), validate=True)
        else:
            decoded = b"".join(binascii.a2b_uu(line) for line in payload.splitlines() if line != "`")
        assert len(decoded) == int(count), (kind, len(decoded), count)
        result[kind] = decoded
    return result


def main():
    for vector in PROFILE["vectors"]:
        text = (ROOT / vector["source"]).read_text()
        for _ in range(vector["depth"]):
            encoded = blocks(text)
            key = KEYS["des-fixture"]
            if vector["session_key"]:
                session = decrypt(encoded["key_block"], KEYS["exchange-fixture"]).decode()
                key = blocks(session)["data_decrypt_key"].hex()
            clear = decrypt(encoded["data_block"], key)
            if vector["digest"]:
                digest = decrypt(encoded["digest_block"], KEYS["digest-fixture"])
                assert digest == hashlib.new(vector["digest"], clear).digest(), vector["source"]
            text = clear.decode()
        assert text == vector["plaintext"], vector["source"]
        assert hashlib.sha256(text.encode()).hexdigest() == vector["plaintext_sha256"]
        print(vector["source"] + ": payload, key, padding and digest verified")


if __name__ == "__main__":
    main()
