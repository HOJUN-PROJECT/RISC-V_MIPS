module mips
  (
   input        clk,
   input        rst,
   output reg [9:0]  pco,
   output reg [31:0] inso
   );
   localparam s0 = 0, s1 = 1, s2_1 = 2, s2_2 = 3, s2_3 = 4, s2_4 = 5, s2_5 = 6, s2_6 = 7,s2_7 = 8, s2_8 = 9, err = 10;
   localparam s5 = 11, s6 = 12;
   
   localparam RFORMAT = 0;
   localparam LW = 35;
   localparam SW = 43;
   localparam BEQ = 4;
   localparam BNE = 5;
   localparam ADDI = 8;
   localparam ORI = 13;
   localparam ANDI = 12;
   localparam F_ADD = 6'b100000;
   localparam F_SUB = 6'b100010;
   localparam F_MUL = 6'b011000;
   localparam F_AND = 6'b100100;
   localparam F_OR = 6'b100101;
   localparam F_XOR = 6'b100110;
   localparam F_SLT = 6'b101010;
   localparam F_SLLV = 6'b000100;
   localparam F_SRLV = 6'b000110; 
   
   reg [3:0] state;
   reg [3:0] nstate;
   reg signed [31:0] register[7:0];
   reg signed [31:0] nregister[7:0];
   reg [9:0] pc;
   reg [9:0] npc;
   reg [31:0] instruction;
   reg [31:0] ninstruction;
   reg [4:0] rs;
   reg [4:0] nrs;
   reg [4:0] rt;
   reg [4:0] nrt;
   reg [4:0] rd;
   reg [4:0] nrd;
   reg signed [15:0] imm;
   reg signed [15:0] nimm;
   reg signed [31:0] ext_imm;
   reg signed [31:0] next_imm;
   reg [5:0] funct;
   reg [5:0] nfunct;
   reg signed [31:0] result;
   reg signed [31:0] nresult;
   reg [9:0] addr;
   reg [9:0] naddr;
   reg [7:0] im_addr;
   wire [31:0] im_rdata;
   reg [31:0] im_wdata;
   reg im_wea;
   reg [7:0] dm_addr;
   wire [31:0] dm_rdata;
   reg [31:0] dm_wdata;
   reg dm_wea;
   integer i;
   
   // 1 port SRAM: width 32 bits, depth 256 ea
   inst imem
     (.addra(im_addr),
      .clka(clk), 
      .douta(im_rdata)
      );
   datamemory dmem
     (.addra(dm_addr), 
      .clka(clk),
      .dina(dm_wdata),
      .douta(dm_rdata),
      .wea(dm_wea)
      );
always @ (rst, state, im_rdata, dm_rdata, register[0], register[1], register[2],
          register[3], register[4], register[5], register[6], register[7], pc, instruction, 
          rs, rt, rd, imm, ext_imm, funct, result, addr) begin
   // signal out
   pco = pc;
   inso = instruction;
   
   // memory default
   im_addr = 0;
   im_wdata = 0;
   im_wea = 1'b0;
   dm_addr = 0;
   dm_wdata = 0;
   dm_wea = 1'b0;
   // default
   nstate = state;
   nregister[0] = register[0];
   nregister[1] = register[1];
   nregister[2] = register[2];
   nregister[3] = register[3];
   nregister[4] = register[4];
   nregister[5] = register[5];
   nregister[6] = register[6];
   nregister[7] = register[7];
   npc = pc;
   ninstruction = instruction;
   nrs = rs;
   nrt = rt;
   nrd = rd;
   nimm = imm;
   next_imm = ext_imm;
   nfunct = funct;
   nresult = result;
   naddr = addr;
   case (state)
    s5: begin
        nstate = s0;
    end
    s0: begin
        im_addr = pc[9:2];  // naddr = pc[9:2]; im_addr = naddr;
        npc = pc + 4;
        nstate = s1;
    end
    s1: begin
        ninstruction = im_rdata;
        nrs = ninstruction[25:21];
        nrt = ninstruction[20:16];
        nrd = ninstruction[15:11];
        nfunct = ninstruction[5:0];
        nimm = ninstruction[15:0];
        if (nimm[15] == 1'b1) begin
            next_imm = {16'hffff, nimm};
        end else begin
            next_imm = {16'h0000, nimm};
        end
        naddr = $signed(register[nrs][9:0]) + $signed(next_imm[9:0]);
        // naddr = register[nrs] + next_imm;
        if (ninstruction[31:26] == RFORMAT) begin
            nstate = s2_1;
        end else if (ninstruction[31:26] == LW) begin
            dm_addr = naddr[9:2];
            nstate = s2_2;
        end else if (ninstruction[31:26] == SW) begin
            nstate = s2_3;
        end else if (ninstruction[31:26] == BEQ) begin
            nstate = s2_4;
        end else if (ninstruction[31:26] == BNE) begin
            nstate = s2_5;
        end else if (ninstruction[31:26] == ADDI) begin
            nstate = s2_6;
        end else if (ninstruction[31:26] == ORI) begin
            nstate = s2_7;
        end else if (ninstruction[31:26] == ANDI) begin
            nstate = s2_8;
        end else begin
            nstate = err;
        end
    end // case: s1
    // rformat
    s2_1: begin
        nresult = 0;
        if (funct == F_ADD) begin
            nresult = register[rs] + register[rt];
        end else if (funct == F_SUB) begin
            nresult = register[rs] - register[rt];
        end else if (funct == F_AND) begin
            nresult = register[rs] & register[rt];
        end else if (funct == F_OR) begin
            nresult = register[rs] | register[rt];
        end else if (funct == F_XOR) begin
            nresult = register[rs] ^ register[rt];
        end else if (funct == F_MUL) begin
            nresult = register[rs] * register[rt];
        end else if (funct == F_SLLV) begin
            nresult = register[rt] << register[rs][4:0]; 
        end else if (funct == F_SRLV) begin
            nresult = register[rt] >> register[rs][4:0]; 
        end else if (funct == F_SLT) begin
            nresult = register[rs] - register[rt];
            if (nresult < 0) begin
                nresult = 1;
            end else begin
                nresult = 0;
            end
        end
        nregister[rd] = nresult;
        nstate = s0;
    end // case: s2_1
    // lw
    s2_2: begin
        nregister[rt] = dm_rdata;
        nstate = s0;
    end
    // sw
    s2_3: begin
        dm_addr = addr[9:2];
        dm_wdata = register[rt];
        dm_wea = 1'b1;
        nstate = s0;
    end
    // beq
    s2_4: begin
        next_imm = {ext_imm[29:0], 2'b00};
        if (register[rs] - register[rt] == 0) begin
            npc = $signed({1'b0, pc}) + $signed(next_imm[9:0]);
        end
        nstate = s0;
    end
    
    //bne
    s2_5: begin
        next_imm = {ext_imm[29:0], 2'b00};
        if (register[rs] - register[rt] != 0) begin
            npc = $signed({1'b0, pc}) + $signed(next_imm[9:0]);
        end
        nstate = s0;
    end
    
    //addi
    s2_6: begin
        nresult = register[rs] + ext_imm;
        nregister[rt] = nresult;
        nstate = s0;
    end
    
    //ori
    s2_7: begin
        nresult = register[rs] | ext_imm;
        nregister[rt] = nresult;
        nstate = s0;
    end
    
    //andi
    s2_8: begin
        nresult = register[rs] & ext_imm;
        nregister[rt] = nresult;
        nstate = s0;
    end
    err: begin
        nstate = s0;
    end
    default: begin
        nstate = s0;
    end
endcase // case (state)
   
  if (rst == 1'b1) begin
   nstate = s5;
   for (i = 0; i <= 7; i = i + 1) begin
      nregister[i] = 0;
   end
   npc         = 0;
   ninstruction = 0;
   nrs         = 0;
   nrt         = 0;
   nrd         = 0;
   nimm        = 0;
   next_imm    = 0;
   nfunct      = 0;
   nresult     = 0;
   naddr       = 0;
   end
end // always @ (rst, state, im_rdata, dm_rdata, register, pc, instruction,...)
always @ (posedge clk) begin
   state       <= nstate;
   register[0] <= nregister[0];
   register[1] <= nregister[1];
   register[2] <= nregister[2];
   register[3] <= nregister[3];
   register[4] <= nregister[4];
   register[5] <= nregister[5];
   register[6] <= nregister[6];
   register[7] <= nregister[7];
   pc          <= npc;
   instruction <= ninstruction;
   rs          <= nrs;
   rt          <= nrt;
   rd          <= nrd;
   imm         <= nimm;
   ext_imm     <= next_imm;
   funct       <= nfunct;
   result      <= nresult;
   addr        <= naddr;
end
// synopsys translate_off
always @ (posedge clk) begin
   if (state == s0) begin
      $display("-----------------------------");
      $display("pc = %d", pc);
   end
   else if (state == s1) begin
      $display("instruction = %08x", ninstruction);
      $display("-----------------------------");
   end
   else if (state == s2_1 | state == s2_5) begin
      $display("result = %d", nresult);
      $display("-----------------------------");
   end
end
// synopsys translate_on
endmodule // mips
