module control 
  (
   input [5:0]	opcode,
   input [5:0]  funct,
   output	regdst,
   output	alusrc,
   output	memtoreg,
   output	regwrite,
   output	memread,
   output	memwrite,
   output	branch,
   output   bne_out,
   output   addi,
   output   slti,
   output   j,
   output [1:0]	aluop
   );

   wire r_format, lw, sw, beq, bne, jump;

   assign r_format = (opcode == 0) ? 1'b1 : 1'b0;
   assign lw = (opcode ==   35) ? 1'b1 : 1'b0;
   assign sw = (opcode == 43) ? 1'b1 : 1'b0;
   assign beq = (opcode == 4) ? 1'b1 : 1'b0;
   assign bne = (opcode == 5) ? 1'b1 : 1'b0;
   assign addi = (opcode == 8) ? 1'b1 : 1'b0;
   assign slti = (opcode == 10) ? 1'b1 : 1'b0;
   assign jump = (opcode == 2) ? 1'b1 : 1'b0;
   assign jr = (funct == 8) ? 1'b1 : 1'b0;

   assign regdst = r_format;
   assign alusrc = lw | sw | addi | slti;
   assign memtoreg = lw;
   assign regwrite = r_format | lw | addi | slti;
   assign memread  = lw;
   assign memwrite = sw; 
   assign branch = beq;
   assign aluop[1] = r_format | slti;
   assign aluop[0] = beq | bne | slti;
   assign bne_out = bne;
   assign j = jump;

endmodule // control
