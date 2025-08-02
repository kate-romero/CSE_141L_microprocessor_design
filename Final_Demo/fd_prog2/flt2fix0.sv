// behavioral model of float to fix 8.8 converter	   rev. 2025.05.24
// not intended to be synthesizable -- just shows the algorithm
// CSE141L  
module TopLevel0(			     // my dummy placeholder for your design
  input              clk, 
                     reset, 
                     start,        //	request from test bench
  output logic       done);		 // acknowledge back to test bench

logic[15:0] flt_in;				 // incoming floating point value
logic[14:0] int_out;
logic[ 4:0] exp;	             // incoming exponent
logic[41:0] int_frac;            // internal fixed point
// 32 shift positions, 11 bit mantissa, so 31+11=42
logic       sign,
            start_q;				 // request delayed 1 cycle
logic[ 7:0] ctr;				 // cycle counter
// memory core
logic[ 7:0] dm_out, dm_in, dm_addr;

// dummy "hookup" to real data mem. module
data_mem data_mem1(.clk(clk), .WriteMem('0), .DataOut(dm_out), 
  .DataIn(dm_in), .DataAddress(dm_addr), .ReadMem('1));

always @(posedge clk) begin
  if(reset)	begin
    start_q   <= '0;
	ctr     <= '0;
  end
  else begin
    start_q   <= start;
    ctr     <= ctr + 'b1;		 // count clock cycles
  end   
end

// we'll ignore the sign bit and solve for magnitudes first
// negatives require a final sign-mag to two's comp conversion, below
// note trap for max negative case
always begin
  wait(start_q && !start)			 // detect falling request
  flt_in   = {data_mem1.mem_core[5],data_mem1.mem_core[4]};	  // read from data_mem
  sign     = flt_in[15];
  exp      = flt_in[14:10];
// leave room for large and small exponents 
  int_frac = {31'b0,|flt_in[14:10],flt_in[ 9: 0]};
  int_frac = int_frac<<exp;
  int_out  = int_frac[31:17];  // exp bias = 15; 8 bit frac
  if(exp > 5'b10110) begin   
// trap special max neg. case
    if(sign) {data_mem1.mem_core[7],data_mem1.mem_core[6]} = 16'hffff; // s&n
// limit overflow to max. positive
    else 	 {data_mem1.mem_core[7],data_mem1.mem_core[6]} = 16'h7fff;
  end
  else begin 
//    if(sign)		                  // negative result -- take two's comp.
//      {data_mem1.mem_core[7],data_mem1.mem_core[6]} = ~int_out + 'b1;
//    else 
      {data_mem1.mem_core[7],data_mem1.mem_core[6]} = {sign,int_out};
  end
  #20ns done = '1;				 // send ack pulse to test bench (dummy timing)
  #20ns done = '0;
end

endmodule