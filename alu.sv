// combinational -- no clock
// sample -- change as desired
module alu(
  input[3:0] alu_cmd,    // ALU instruction
  input[7:0] inA, inB,	 // 8-bit wide data path; inA is always implied register
  input      sc_i,       // shift_carry in
  output logic[7:0] rslt,// almost always sent to implied register
  output logic sc_o,     // shift_carry out
               pari,     // reduction XOR (output); TODO: not needed?
			   zero      // NOR (output); TODO: not needed?
);

always_comb begin 
  rslt = 'b0;            
  sc_o = 'b0;    
  zero = !rslt; // needed?
  pari = ^rslt; // needed?
  case(alu_cmd)

	4'b0000:	// TODO: in ALU? load from memory
	4'b0001:	// TODO: in ALU? store to memory
	4'b0010:	// in ALU? move from reg inB to inA
	  rslt = inB;
	4'b0011:	// in ALU? move to reg inB from inA
	  rslt = inA;
	4'b0100:	// in ALU? move immediate to register; immediate is inB?
	  rslt = inB;
	4'b0101:	// in ALU? compare
	  if (inA == inB)
	    rslt = 8'b00000000;
	  else if (inA < inB)
	    rslt = 8'b00000001;
	  else
	    rslt = 8'b00000010;
	4'b0110:	// bitwise NOT; flips inB?
	  rslt = ~inB;
	4'b0111:	// bitwise OR
	  rslt = inA | inB;
	4'b1000:	// bitwise AND
	  rslt = inA & inB;
	4'b1001:	// logical shift left
	  rslt = inA << inB;
	4'b1010:	// logical shift right
	  rslt = inA >> inB;
	4'b1011:	// add register value
	  {sc_o,rslt} = inA + inB + sc_i;
	4'b1100:	// subtract register value
	  {sc_o,rslt} = inA - inB + sc_i;

  endcase
end
   
endmodule