module PC_LUT #(parameter D=12)(
  input       [5:0] addr,	   // label index
  output logic[D-1:0] target);

  logic[D-1:0] core[2**D];
  initial							    // load the program
    $readmemb("lut.txt",core);

  assign target = core[addr];

endmodule
