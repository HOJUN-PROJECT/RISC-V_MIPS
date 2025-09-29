module ifetch (
    output [31:0] instruction,
    output reg [9:0] pc_plus_4_out,
    input [9:0] add_result,
    input branch,
    input zero,
    input bne_out,
    output reg [9:0] pc_out,
    input pclk,
    input iclk,
    input reset,
    input j
);

    reg [31:0] pc, pc_plus_4;
    reg [31:0] next_pc;
    reg [31:0] jump_pc, branch_pc;

    // instruction memory
    inst1 im (
        .addra(pc[9:2]),
        .clka(iclk),
        .douta(instruction)
    );

    always @ (pc, pc_plus_4, zero, branch, add_result) begin
        pc_out = pc;
        pc_plus_4_out = pc_plus_4;

        // pc + 4  
        pc_plus_4 = pc + 4;

        // mux operation
        if ((zero == 1 && branch == 1) || (zero == 0 && bne_out == 1)) begin
            branch_pc = add_result;
              end
              else begin
            branch_pc = pc_plus_4;
              end


//         j operation
         if (j == 1) begin
             jump_pc = {pc_plus_4[31:28], instruction[25:0], 2'b00};
         end else begin
             jump_pc = branch_pc;
             next_pc = jump_pc;
         end
    end

    // store pc on rising clock edge
    always @ (posedge pclk, posedge reset) begin
        if (reset == 1) begin
            pc <= 0;
        end else begin
            pc <= next_pc;
        end
    end

endmodule // ifetch
