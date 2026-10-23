//! inherited IEEE 1364-2005 17.1.1.2
// %u reads unformatted two-value data; a 32-bit word written with %u reads
// back unchanged (fscanf_u).
module triage_fscanf_unformatted_u;
  reg [31:0] in_32, out_32;
  integer res, fd;
  reg failed;

  initial begin
    failed = 0;
    in_32 = 32'h12345678;

    fd = $fopen("triage_fscanf_u.bin", "wb");
    $fwrite(fd, "%u", in_32);
    $fclose(fd);

    fd = $fopen("triage_fscanf_u.bin", "rb");
    res = $fscanf(fd, "%u", out_32);
    if (res !== 1) failed = 1;
    else if (out_32 !== 32'h12345678) failed = 1;
    $fclose(fd);

    if (failed) $display("FAILED %b", out_32); else $display("PASSED");
  end
endmodule
