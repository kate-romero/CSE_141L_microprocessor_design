//This file defines the parameters used in the alu
// import package into each module that needs it
//   packages very useful for declaring global variables
package definitions;
    
// r-type opcodes
    const logic [3:0]LOAD  = 4'b0000;
    const logic [3:0]STOR  = 4'b0001;
    const logic [3:0]MOVF  = 4'b0010;
    const logic [3:0]MOVT  = 4'b0011;
    const logic [3:0]MOVI  = 4'b0100;
	const logic [3:0]CMPR  = 4'b0101;
	const logic [3:0]BNOT  = 4'b0110;
	const logic [3:0]BORR  = 4'b0111;
    const logic [3:0]BAND  = 4'b1000;
    const logic [3:0]LSHL  = 4'b1001;
    const logic [3:0]LSHR  = 4'b1010;
    const logic [3:0]ADDR  = 4'b1011;
	const logic [3:0]SUBR  = 4'b1100;
// enum names will appear in timing diagram
    typedef enum logic[3:0] {
        LOAD, STOR, MOVF, MOVT, MOVI, CMPR, BNOT, 
		BORR, BAND, LSHL, LSHR, ADDR, SUBR } op_mne;
endpackage // definitions
