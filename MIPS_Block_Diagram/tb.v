module tb;

   // inputs
   reg reset;
   reg clk;

   // outputs
   wire [9:0] pc_out;
   wire [31:0] alu_result_out;
   wire [31:0] read_data_1_out;
   wire [31:0] read_data_2_out;
   wire [31:0] instruction_out;
   wire        branch_out;
   wire        zero_out;
   wire        memwrite_out;
   wire        regwrite_out;

   // instantiate the unit under test (uut)
   top_spim uut
     (
      .reset(reset),
      .clk(clk),
      .pc_out(pc_out),
      .alu_result_out(alu_result_out),
      .read_data_1_out(read_data_1_out),
      .read_data_2_out(read_data_2_out),
      .instruction_out(instruction_out),
      .branch_out(branch_out),
      .zero_out(zero_out),
      .memwrite_out(memwrite_out),
      .regwrite_out(regwrite_out)
      );

   initial begin
          reset = 1'b0;
      #20 reset = 1'b1;
      #20 reset = 1'b0;
   end

   initial begin
      clk = 0;
      forever #10 clk = ~clk;
   end

   always @ (negedge reset) begin
     $display("start of simulation\n");
   end

endmodule // tb
