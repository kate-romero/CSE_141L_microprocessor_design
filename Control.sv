// control decoder

// TA questions: RegDst?

import definitions::*;			        // includes package "definitions"

// r-type opcodes
    const logic [3:0]kLOAD  = 4'b0000;
    const logic [3:0]kSTOR  = 4'b0001;
    const logic [3:0]kMOVF  = 4'b0010;
    const logic [3:0]kMOVT  = 4'b0011;
    const logic [3:0]kMOVI  = 4'b0100;
	const logic [3:0]kCMPR  = 4'b0101;
	const logic [3:0]kBNOT  = 4'b0110;
	const logic [3:0]kBORR  = 4'b0111;
    const logic [3:0]kBAND  = 4'b1000;
    const logic [3:0]kLSHL  = 4'b1001;
    const logic [3:0]kLSHR  = 4'b1010;
    const logic [3:0]kADDR  = 4'b1011;
	const logic [3:0]kSUBR  = 4'b1100;
	const logic [3:0]kHALT  = 4'b1101;
    const logic [3:0]kADDC  = 4'b1110;
	const logic [3:0]kSUBC  = 4'b1111;
// enum names will appear in timing diagram
    typedef enum logic[3:0] {
        LOAD, STOR, MOVF, MOVT, MOVI, CMPR, BNOT, 
		BORR, BAND, LSHL, LSHR, ADDR, SUBR, HALT, ADDC, SUBC } op_mne;

module Control (
  input [8:8] instrType,	// instruction type (B=1 or R=0)
  input [7:6] bopcode,    	// branch opcode
  input [7:4] ropcode,		// r-type intruction opcode
  input [0:0] equalQ, less_thanQ, greater_thanQ,
  output logic Branch, MemtoReg, MemWrite, 
			   ALUSrc, RegWrite, RegWAddr);
  
    op_mne op_mnemonic;			        // type enum: used for convenient waveform viewing

always_comb begin
  // defaults
  Branch 	=   'b0;   // 1: branch (jump)
  MemWrite  =	'b0;   // 1: store to memory
  ALUSrc 	=	'b0;   // 1: immediate  0: second reg file output
  RegWrite  =	'b1;   // 0: for store or no op  1: most other operations 
  MemtoReg  =	'b0;   // 1: load -- route memory instead of ALU to reg_file data in
  RegWAddr  =   'b0;   // 0: write to imp_reg (A); 1: write to reg B
  case(instrType)		// check instruction type
    'b1:	// b-type
	  begin
	    case(bopcode)
		  00: Branch = equalQ;
		  01: Branch = less_thanQ;
		  10: Branch = greater_thanQ;
		  11: Branch = less_thanQ | greater_thanQ;
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
