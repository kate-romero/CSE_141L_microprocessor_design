// control decoder

// TA questions: RegDst?

import definitions::*;			        // includes package "definitions"

module Control (
  input [8:8] instrType,	// instruction type (B=1 or R=0)
  input [7:6] bopcode,    	// branch opcode
  input [7:4] ropcode,		// r-type intruction opcode
  input logic equalQ, less_thanQ, greater_thanQ,
  output logic RelBranch, AbsBranch, MemtoReg, MemWrite, 
			   ALUSrc, RegWrite, RegWAddr);
  
    op_mne op_mnemonic;			        // type enum: used for convenient waveform viewing

always_comb begin
  // defaults
  AbsBranch 	=   'b0;   // 1: abs branch (jump)
  // RelBranch 	=   'b0;   // 1: rel branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  RegWAddr  =   'b0;   // 0: write to imp_reg (A); 1: write to reg B
  case(instrType)		// check instruction type
    'b1:	// b-type
	  begin
		RegWrite = 'b0;
	    case(bopcode)
		  2'b00: AbsBranch = equalQ;
		  2'b01: AbsBranch = less_thanQ;
		  2'b10: AbsBranch = greater_thanQ;
		  2'b11: AbsBranch = less_thanQ | greater_thanQ;
		endcase
		// uncomment if change to relative branching
		// case(bopcode)
		//   00: AbsBranch = equalQ;
		//   01: AbsBranch = less_thanQ;
		//   10: AbsBranch = greater_thanQ;
		//   11: AbsBranch = less_thanQ | greater_thanQ;
		// endcase
	  end
	'b0:	// r-type
	  begin
	    case(ropcode)	// check r-type opcode
		  LOAD:
			begin
			  MemtoReg = 'b1;
			end
		  STOR:
			begin
			  MemWrite = 'b1;
			  RegWrite = 'b0;
			end
		  CMPR:
		    begin
			  RegWrite = 'b0;	// change if I dedicate a gen_reg to compare result
			end
		  MOVI:
		    begin
			  ALUSrc = 'b1;
			end
		  MOVT, BNOT:
			begin
			  RegWAddr = 'b1;	// dest reg B (not imp_reg A)
			end
		  HALT:
		    begin
			  RegWrite = 'b0;	// Don't write to register on HALT
			end
		endcase
	  end
  endcase

end
	
endmodule
