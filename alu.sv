// combinational -- no clock
// debug starting place: need 'assign?'
/* Questions for TA:
 * compare in ALU or elsewhere? doing compare right?
 * need pari, zero outputs?
 * need +0 for moves?
 */
import definitions::*;			         // includes package "definitions"

module alu(
  input[3:0] alu_cmd,    // ALU instruction
  input[7:0] inA, inB,	 // 8-bit wide data path; inA is always implied register
  input      sc_i,       // shift_carry in
  output logic[7:0] rslt,// almost always sent to implied register
  output logic sc_o,     // shift_carry out
               pari,     // reduction XOR (output)
			   zero      // NOR (output)
);

  op_mne op_mnemonic;			         // type enum: used for convenient waveform viewing

always_comb begin 
  rslt = 'b0;            
  sc_o = 'b0;    
  zero = !rslt;
  pari = ^rslt;
  case(alu_cmd)

	MOVF:	// move val from reg B to A
	  rslt = inB;
	MOVT:	// move val to reg B from A
	  rslt = inA;
	MOVI:	// move immediate to register; immediate in inB
	  rslt = inB;
	CMPR:	// compare
	  if (inA == inB)
	    rslt = 8'b00000000;
	  else if (inA < inB)
	    rslt = 8'b00000001;
	  else
	    rslt = 8'b00000010;
	BNOT:	// bitwise NOT; flips inB
	  rslt = ~inB;
	BORR:	// bitwise OR
	  rslt = inA | inB;
	BAND:	// bitwise AND
	  rslt = inA & inB;
	LSHL:	// logical shift left
	  rslt = inA << inB;
	LSHR:	// logical shift right
	  rslt = inA >> inB;
	ADDR:	// add register value
	  {sc_o,rslt} = inA + inB + sc_i;
	SUBBR:	// subtract register value
	  {sc_o,rslt} = inA - inB + sc_i;

  endcase
end
   
endmodule