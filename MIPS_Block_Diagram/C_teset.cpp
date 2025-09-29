
#include <stdio.h>
#include <stdlib.h>

#define RFORMAT 0
#define LW      35
#define SW      43
#define BEQ     4
#define ADD     0B100000
#define SUB     0B100010
#define AND     0B100100
#define OR      0B100101
#define SLT     0B101010
#define BNE     5
#define ADDI    8
#define J       2

#define XOR     0B100110
#define MUL     0B011000
#define NOR     0B100111
#define SLTI    0B001010

int main() {
    unsigned int imem[256];
    unsigned int dmem[256];
    int reg[8];
    int pc;
    unsigned int instruction;
    int rs, rt, rd;
    int imm;
    unsigned int ext_imm;
    int funct;
    int result;
    int addr;
    int i;

    for (i = 0; i <= 255; i++) {
        imem[i] = 0;
        dmem[i] = 0;
    }
    for (i = 0; i <= 7; i++) {
        reg[i] = 0;
    }

    imem[0] = 0x8c020000;
    imem[1] = 0x8c030004;
    imem[2] = 0x20040001;
    imem[3] = 0x00042820;
    imem[4] = 0x00853022;
    imem[5] = 0x00c53826;
    imem[6] = 0x00c74027;
    imem[7] = 0x00a73818;
    imem[8] = 0x00a22820;
    imem[9] = 0x00a32820;
    imem[10] = 0x28c60005;
    imem[11] = 0x14c0fffb;
    imem[12] = 0xac05000c;
    imem[13] = 0x08000009;

    dmem[0] = 0x00000001;
    dmem[1] = 0x00000002;

    pc = 0;
    i = 0;

    while (1) {
        addr = pc;
        printf("-----------------------------\n");
        printf("pc = %d\n", pc);
        printf("instruction = %08x\n", instruction);
        printf("-----------------------------\n");
        pc = pc + 4;

        instruction = imem[addr / 4];
        rs = (instruction >> 21) & 0B011111;
        rt = (instruction >> 16) & 0B011111;
        rd = (instruction >> 11) & 0B011111;
        funct = instruction & 0B0111111;

        imm = instruction & 0x0ffff;
        if (((imm >> 15) & 0B01) == 1) {
            ext_imm = 0xffff << 16 | imm;
        } else {
            ext_imm = 0x0000 << 16 | imm;
        }
        addr = reg[rs] + ext_imm;

        switch (instruction >> 26) {
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
                } else if (funct == NOR) {
                    result = ~(reg[rs] | reg[rt]);
                } else if (funct == MUL) {
                    result = reg[rs] * reg[rt];
                } else if (funct == SLT) {
                    result = reg[rs] - reg[rt];
                    result = (result < 0) ? 1 : 0;
                }
                reg[rd] = result;
                break;

            case LW:
                reg[rt] = dmem[addr / 4];
                break;

            case SW:
                dmem[addr / 4] = reg[rt];
                break;

            case BEQ:
                ext_imm = ext_imm << 2 | 0B00;
                if (reg[rs] - reg[rt] == 0) {
                    pc = pc + ext_imm;
                }
                break;

            case BNE:
                ext_imm = ext_imm << 2 | 0B00;
                if (reg[rs] - reg[rt] != 0) {
                    pc = pc + ext_imm;
                }
                break;

            case ADDI:
                reg[rt] = reg[rs] + ext_imm;
                break;

            case J:
                pc = (instruction & 0x03ffffff) << 2;
                break;

            case SLTI:
                reg[rt] = (reg[rs] < (int)ext_imm) ? 1 : 0;
                break;

            default:
                break;
        }

        i++;
        if (i >= 16) break;
    }

    return 0;
}
