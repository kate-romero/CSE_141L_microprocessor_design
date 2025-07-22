// control decoder

// TA questions: RegDst?

import definitions::*;			        // includes package "definitions"

module Control (
  input [8:8] instrType,	// instruction type (B=1 or R=0)
  input [7:6] bopcode,    	// branch opcode
  input [7:4] ropcode,		// r-type intruction opcode
  input [0:0] equal, less_than, greater_than,
  output logic Branch, MemtoReg, MemWrite, 
			   ALUSrc, RegWrite, RegWAddr);
  
    op_mne op_mnemonic;			        // type enum: used for convenient waveform viewing

always_comb begin
  // defaults
  Branch 	=   'b0;   // 1: branch (jump)
  How_high  =   'b0;   // branch address
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  ALUOp	    =   'b111; // y = a+0;
  RegWAddr  =   'b0;   // 0: write to imp_reg (A); 1: write to reg B
  case(instrType)		// check instruction type
    'b1:	// b-type
	  begin
	    case(bopcode)
		  00: Branch = equal;
		  01: Branch = less_than;
		  10: Branch = greater_than;
		  11: Branch = less_than | greater_than;
		endcase
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
			  RegWaddr = 'b1;	// dest reg B (not imp_reg A)
			end
		endcase
	  end
  endcase

end
	
endmodule