module top_spim
  (
   input	 clk, 
   input	 reset, 
   output [9:0]	 pc_out, 
   output [31:0] alu_result_out, 
   output [31:0] read_data_1_out,
   output [31:0] read_data_2_out,
   output [31:0] instruction_out,
   output	 branch_out, 
   output	 zero_out, 
   output	 memwrite_out,
   output	 regwrite_out
   );
   
   // internal signals
   wire		 pclk;
   wire		 iclk;
   wire		 dclk;
   wire		 regdst;
   wire		 branch;
   wire		 memread;
   wire		 memtoreg;
   wire [1:0]	 aluop;
   wire		 memwrite;
   wire		 alusrc;
   wire		 regwrite;
   wire [9:0]	 pc_plus_4;
   wire [31:0]	 instruction;
   wire [31:0]	 read_data_1;
   wire [31:0]	 read_data_2;
   wire [31:0]	 sign_extend;
   wire [9:0]	 add_result;
   wire		 zero;
   wire [31:0]	 alu_result;
   wire [31:0]	 read_data;

   // signal out for debug
   assign instruction_out = instruction;
   assign alu_result_out  = alu_result;
   assign read_data_1_out = read_data_1;
   assign read_data_2_out = read_data_2;
   assign branch_out = branch;
   assign zero_out = zero;
   assign regwrite_out = regwrite;
   assign memwrite_out = memwrite;

   // connect the clocks	
   clkgen CK 
     (.clk(clk),
      .reset(reset),
      .pclk(pclk),
      .iclk(iclk),
      .dclk(dclk)
      );	
   
   ifetch IFE
     (.instruction(instruction),
      .pc_plus_4_out(pc_plus_4),
      .add_result(add_result),
      .branch(branch), 
      .zero(zero),
      .pc_out(pc_out),
      .pclk(pclk),
      .iclk(iclk),
      .reset(reset)
      );

   idecode ID
     (.read_data_1(read_data_1),
      .read_data_2(read_data_2),
      .instruction(instruction),
      .read_data(read_data),
      .alu_result(alu_result),
      .regwrite(regwrite),
      .memtoreg(memtoreg),
      .regdst(regdst),
      .sign_extend(sign_extend),
      .pclk(pclk),  
      .reset(reset)
      );

   control CTL
     (.opcode(instruction[31:26]),
      .regdst(regdst),
      .alusrc(alusrc),
      .memtoreg(memtoreg),
      .regwrite(regwrite),
      .memread(memread),
      .memwrite(memwrite),
      .branch(branch),
      .aluop(aluop)
      );

   execute EXE
     (.read_data_1(read_data_1),
      .read_data_2(read_data_2),
      .sign_extend(sign_extend),
      .funct(instruction[5:0]),
      .aluop(aluop),
      .alusrc(alusrc),
      .zero(zero),
      .alu_result(alu_result),
      .add_result(add_result),
      .pc_plus_4(pc_plus_4)
      );
   
   dmemory MEM
     (.read_data(read_data),
      .address(alu_result[9:2]),
      .write_data(read_data_2),
      .memread(memread), 
      .memwrite(memwrite), 
      .dclk(dclk),  
      .reset(reset)
      );

endmodule // top_spim
