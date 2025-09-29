module execute (
    input [31:0] read_data_1,
    input [31:0] read_data_2,
    input [31:0] sign_extend,
    input [5:0] funct,
    input [1:0] aluop,
    input alusrc,
    output reg zero,
    output reg [31:0] alu_result,
    output reg signed [9:0] add_result,
    input [9:0] pc_plus_4
);

    reg signed [31:0] aluin1, aluin2;
    reg signed [31:0] alu_output;
    reg [2:0] alu_ctl;
    reg [2:0] alu_ctl2;

    always @ (
        pc_plus_4, sign_extend, read_data_1, read_data_2, alusrc,
        aluop, funct, alu_ctl, alu_output
    ) begin
        // branch address calculation
        add_result = pc_plus_4 + {sign_extend[7:0], 2'b00};

        // alu inputs
        aluin1 = read_data_1;
        if (alusrc == 1'b0) begin
            aluin2 = read_data_2;
        end else begin
            aluin2 = sign_extend;
        end

        alu_ctl = 3'b000; // default
        if (aluop == 2'b00) begin //add
            alu_ctl = 3'b010;
        end else if (aluop == 2'b01) begin //sub
            alu_ctl = 3'b110;
        end else if (aluop == 2'b10) begin
            if (funct == 6'b100000) begin // add
                alu_ctl = 3'b010;
            end else if (funct == 6'b100010) begin // sub
                alu_ctl = 3'b110;
            end else if (funct == 6'b100100) begin // and
                alu_ctl = 3'b000;
            end else if (funct == 6'b100101) begin // or
                alu_ctl = 3'b001;
            end else if (funct == 6'b101010) begin // slt
                alu_ctl = 3'b111;
            end else if (funct == 6'b100110) begin // xor
                alu_ctl = 3'b011;
            end else if (funct == 6'b100111) begin // nor
                alu_ctl = 3'b100;
            end else if (funct == 6'b011000) begin // mul
                alu_ctl = 3'b101;
            end
        end

        // Select ALU operation
        case (alu_ctl)
            3'b000: alu_output = aluin1 & aluin2;
            3'b001: alu_output = aluin1 | aluin2;
            3'b010: alu_output = aluin1 + aluin2;
            3'b011: alu_output = aluin1 ^ aluin2;
            3'b100: alu_output = ~(aluin1 | aluin2);
            3'b101: alu_output = aluin1 * aluin2;
            3'b110: alu_output = aluin1 - aluin2; 
            3'b111: alu_output = (aluin1 < aluin2) ? 1 : 0;
            default: alu_output = 0;
        endcase

        // generate zero flag
        if (alu_output == 0)
            zero = 1;
        else
            zero = 0;

        // Select ALU output
        if (alu_ctl == 3'b111)
            alu_result = alu_output[31];
        else
            alu_result = alu_output;
    end

endmodule // execute
