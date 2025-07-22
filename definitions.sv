//This file defines the parameters used in the alu
// import package into each module that needs it
//   packages very useful for declaring global variables
package definitions;
    
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
// enum names will appear in timing diagram
    typedef enum logic[3:0] {
        LOAD, STOR, MOVF, MOVT, MOVI, CMPR, BNOT, 
		BORR, BAND, LSHL, LSHR, ADDR, SUBR } op_mne;
endpackage // definitions
