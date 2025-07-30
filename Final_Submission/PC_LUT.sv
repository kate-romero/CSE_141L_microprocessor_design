module PC_LUT #(parameter D=12)(
  input       [5:0] addr,	   // label index
  output logic[D-1:0] target);

  // logic[D-1:0] core[2**D];
  // initial							    // load the program
  //   $readmemb("lut.txt",core);

  // always_comb  target = core[addr];

  always_comb case(addr)
    // program 1:
    0: target = 37;
    1: target = 49;
    2: target = 53;
    3: target = 65;
    4: target = 95;
    5: target = 121;
    6: target = 143;
    7: target = 150;

    // program 2:
    // 0: target = 61;

    // program 3:
    // 0: target = 55;
    // 1: target = 67;
    // 2: target = 110;
    // 3: target = 144;

    default: target = 0;
  endcase

endmodule
