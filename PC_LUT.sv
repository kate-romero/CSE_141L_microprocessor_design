/* TA Questions: 
 *		How to populate LUT with file?
 *		line 19?
 */

module PC_LUT #(parameter D=12)(
  input       [ 5:0] addr,	   // target 4 values
  output logic[D-1:0] target);

//   always_comb case(addr)
//     0: target = -5;   // go back 5 spaces
// 	1: target = 20;   // go ahead 20 spaces
// 	2: target = '1;   // go back 1 space   1111_1111_1111
// 	default: target = 'b0;  // hold PC  
//   endcase
  logic[D-1:0] core[2**D];
  initial							    // load the program
    $readmemb("LUT.txt",core);

  always_comb  mach_code = core[prog_ctr];

endmodule

/*

	   pc = 4    0000_0000_0100	  4
	             1111_1111_1111	 -1

                 0000_0000_0011   3

				 (a+b)%(2**12)


   	  1111_1111_1011      -5
      0000_0001_0100     +20
	  1111_1111_1111      -1
	  0000_0000_0000     + 0


  */
