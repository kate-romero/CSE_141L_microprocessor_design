
module PC_tb;

localparam D = 12;

logic clk, reset, reljump_en;//, absjump_en;
// logic [D-1:0] target;
logic [5:0] how_high;
logic [D-1:0] prog_ctr;

PC #(D) dut (
    .reset(reset),
    .clk(clk),
    .reljump_en(reljump_en),
    // .absjump_en(absjump_en),
    // .target(target),
    .how_high(how_high),
    .prog_ctr(prog_ctr)
);

initial clk = 0;
always #5 clk = ~clk;

initial begin
    
    reset = 1;
    reljump_en = 0;
    // absjump_en = 0;
    how_high = 0;

    #10;
    reset = 0;

    #10;
    $display("Normal increment: prog_ctr = %0d", prog_ctr);

    reljump_en = 1;
    how_high = 5;
    #10;
    reljump_en = 0;
    $display("Relative jump by 5: prog_ctr = %0d", prog_ctr);

    // absjump_en = 1;
    // target = 100;
    // #10;
    // absjump_en = 0;
    // $display("Absolute jump to 100: prog_ctr = %0d", prog_ctr);

    #10;
    $display("Normal increment: prog_ctr = %0d", prog_ctr);

    reset = 1;
    #10;
    reset = 0;
    $display("After reset: prog_ctr = %0d", prog_ctr);

    #10;
    $finish;
end

endmodule
