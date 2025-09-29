#include <stdio.h>
#include <stdlib.h>
#define RFORMAT 0
#define LW      35
#define SW      43
#define BEQ     4
#define BNE     5  //추가
#define ADDI    8  //추가
#define ANDI    12 //추가
#define ORI     13 //추가
#define ADD     0B100000
#define SUB     0B100010
#define MUL     0B011000 //추가 
#define AND     0B100100
#define OR      0B100101 
#define XOR     0B100110 //추가
#define SLT     0B101010
#define SLLV    0B000100 //추가
#define SRLV    0B000110 //추가
int main() {
    unsigned int imem[256];    // instruction memory: 32bits x 256
    unsigned int dmem[256];    // data memory: 32bits x 256
    int reg[32];                // register file: 32bits x 8
    int pc;                    // 10 bits
    unsigned int instruction;  // 32 bits
    int rs, rt, rd;            // 5 bits
    int imm;                   // 16 bits
    unsigned int ext_imm;      // 32 bits
    int funct;                 // 6 bits
    int result;                // 32 bits
    int addr;                  // 10 bits
    int i;                     // integer
    for (i = 0; i <= 255; i++) {
        imem[i] = 0;
        dmem[i] = 0;
    }
    for (i = 0; i <= 7; i++) {  // C only
        reg[i] = 0;
    }
    
    // load initial data
    imem[0] = 0x8c020000;  // LW $2, 0($0)
    imem[1] = 0x8c030004;  // LW $2, 4($0)
    imem[2] = 0x20040001;  // ADDI
    imem[3] = 0x00042820;  // ADD
    imem[4] = 0x00853022;  // SUB
    imem[5] = 0x00c53826;  // XOR
    imem[6] = 0x00c74025;  // OR
    imem[7] = 0x70a74802;  // MUL
    imem[8] = 0x00a22820;  // ADD
    imem[9] = 0x00a32820;  // ADD
    imem[10] = 0x00a4302a; // SLT
    imem[11] = 0x14c0fffc; // BNE
    imem[12] = 0xac05000c; // SW
    
    dmem[0] = 0x00000001; // C only
    dmem[1] = 0x00000002;
    
    pc = 0;
    i = 0;  // C only
    while (1) {
        // s0
        // fetch
        // instruction = imem[pc/4];
        addr = pc;
        instruction = imem[addr / 4];  // fetch: instruction 값을 초기화
        printf("-----------------------------\n");
        printf("pc = %d\n", pc);
        printf("instruction = %08x\n", instruction);
        printf("-----------------------------\n");
        
        pc = pc + 4;
        // s1
        instruction = imem[addr / 4];  // instruction = imem[imem_addr];
        rs = (instruction >> 21) & 0B011111;    // instruction[25:21]
        rt = (instruction >> 16) & 0B011111;    // instruction[20:16]
        rd = (instruction >> 11) & 0B011111;    // instruction[15:11]
        funct = instruction & 0B0111111;        // instruction[5:0]
        imm = instruction & 0x0ffff;           // instruction[15:0]
        if (((imm >> 15) & 0B01) == 1) {
            ext_imm = 0xffff << 16 | imm;
        } else {
            ext_imm = 0x0000 << 16 | imm;
        }
        
        addr = reg[rs] + ext_imm;  // low 10 bits
        // decode & execute
        switch (instruction >> 26) {  // instruction[31:26]
            //
            // s2-1
            //
            case RFORMAT:
                result = 0;
                if (funct == ADD) {
                    result = reg[rs] + reg[rt];
                } else if (funct == SUB) {
                    result = reg[rs] - reg[rt];
                } else if (funct == AND) {
                    result = reg[rs] & reg[rt];
                } else if (funct == OR) {
                    result = reg[rs] | reg[rt];
                } else if (funct == XOR) {
                    result = reg[rs] ^ reg[rt];
                } else if (funct == MUL) {
                    result = reg[rs] * reg[rt];
                } else if (funct == SLLV) {
                    result = reg[rt] << (reg[rs]& 0x1F);
                } else if (funct == SRLV) {
                    result = ((unsigned int)reg[rt]) >> (reg[rs]& 0x1F);
                } else if (funct == SLT) {
                    result = reg[rs] - reg[rt];
                    if (result < 0) {   // result(31) == 1
                        result = 1;
                    } else {
                        result = 0;
                    }
                }
                reg[rd] = result;
                break;
            // s2-2
            case LW:
                reg[rt] = dmem[addr / 4];
                break;
            // s2-3
            case SW:
                dmem[addr / 4] = reg[rt];
                break;
            // s2-4
            case BEQ:
                ext_imm = ext_imm << 2 | 0B00;
                if (reg[rs] - reg[rt] == 0) {
                    pc = pc + ext_imm;  // low 10 bits
                }
                break;
            // s2-5 추가 
            case BNE: 
                ext_imm = ext_imm << 2 | 0B00;
                if (reg[rs] - reg[rt] != 0) {
                    pc = pc + ext_imm;  // low 10 bits
                }
                break;
            // s2-6 추가 
            case ADDI:
                ext_imm = ext_imm << 2 | 0B00; 
                reg[rt] = reg[rs] + ext_imm;
                break;
            // s2-7 추가 
            case ORI:
                ext_imm = ext_imm << 2 | 0B00; 
                reg[rt] = reg[rs] | ext_imm;
                break;
            // s2-8 추가 
            case ANDI:
                ext_imm = ext_imm << 2 | 0B00; 
                reg[rt] = reg[rs] & ext_imm;
                break;
            default:
                break;
        }
        i++;  // C only
        if (i >= 16)
            break;  // C only
    }
    return 0;
}
