// sample top level design

// TA Questions: how to change relative jump to absolute branch?

module top_level(
  input        clk, reset, req, 
  output logic done);
  parameter D = 12,             // program counter width
    A = 4;             		  	// ALU command bit width
  wire[D-1:0] //target, 			  // jump 
              prog_ctr;
  wire        RegWrite,
			  RegWaddr,
			  MemtoReg;
  wire[7:0]   datA,datB,		  // from RegFile
              muxB, 
			  muxWA,
			  muxWD,
			  rslt,               // alu output
              immed,
			  mem_out;
  logic sc_in,   				  // shift/carry out from/to ALU
   		pariQ,              	  // registered parity flag from ALU
		zeroQ;                    // registered zero flag from ALU 
  wire  relj;                     // from control to PC; relative jump enable
  wire  pari,
        zero,
		sc_clr,
		sc_en,
        MemWrite,
        ALUSrc;		              // immediate switch
  wire[A-1:0] alu_cmd;
  wire[8:0]   mach_code;          // machine code
  wire[3:0] rd_addrA, rd_adrB;    // address pointers to reg_file
  logic[5:0] how_high;
// fetch subassembly
  PC #(.D(D)) 					  // D sets program counter width
     pc1 (.reset            ,
         .clk              ,
		 .reljump_en (relj),
//		 .absjump_en (absj),
//		 .target           ,
		 .how_high		   ,
		 .prog_ctr          );

// lookup table to facilitate jumps/branches
//  PC_LUT #(.D(D))
//    pl1 (.addr  (how_high),
//         .target          );   

// contains machine code
  instr_ROM ir1(.prog_ctr,
               .mach_code);

// control decoder
  Control ctl1(.instr(mach_code),
  .Branch  (relj)  , 
  .How_high(how_high) ,
  .MemWrite , 
  .ALUSrc   , 
  .RegWrite   , 
  .RegWAddr,
  .MemtoReg);

  assign alu_cmd  = mach_code[7:4];
  assign rd_addrA = 'b0000;				// implied dest reg (for most ops)
  assign rd_addrB = mach_code[3:0];
  
  assign muxWA = RegWAddr? rd_addrA : rd_addrB;
  assign muxWD = MemtoReg? mem_out : result;

  reg_file #(.pw(3)) rf1(.dat_in(MemtoReg),	   // loads, most ops
              .clk         ,
              .wr_en   (RegWrite),
              .rd_addrA(rd_addrA),
              .rd_addrB(rd_addrB),
              .wr_addr (muxWA),
              .datA_out(datA),
              .datB_out(datB)); 

  assign muxB = ALUSrc? immed : datB;

  alu alu1(.alu_cmd,
         .inA    (datA),
		 .inB    (muxB),
		 .sc_i   (sc),   // output from sc register
		 .rslt       ,
		 .sc_o   (sc_o), // input to sc register
		 .pari  );  

  dat_mem dm1(.dat_in(datA)  ,  // from imp_reg
             .clk           ,
			 .wr_en  (MemWrite), // stores
			 .addr   ({4'b0000, rd_addrB}),
             .dat_out(mem_out));

// registered flags from ALU
  always_ff @(posedge clk) begin
    pariQ <= pari;
	zeroQ <= zero;
    if(sc_clr)
	  sc_in <= 'b0;
    else if(sc_en)
      sc_in <= sc_o;
  end

  assign done = prog_ctr == 128;
 
endmodule