
module idecode
  (
   output reg [31:0] read_data_1,
   output reg [31:0] read_data_2,
   input [31:0]      instruction, 
   input [31:0]      read_data, 
   input [31:0]      alu_result,
   input 	     regwrite,
   input 	     memtoreg,
   input 	     regdst, 
   output reg [31:0] sign_extend,
   input 	     pclk,
   input 	     reset
   );

   reg [31:0]	 registers[0:7];  //31 bits vector with depth = 8
   reg [4:0]	 write_register;
   reg [31:0]	 write_data;
   reg [3:0]	 i;

   always @ (instruction, regdst, alu_result, memtoreg, read_data, registers) begin
      // read register 1
      read_data_1 = registers[instruction[25:21]];
      
      // read register 2		 
      read_data_2 = registers[instruction[20:16]];
  
      // mux for register write address
      if (regdst == 1) begin
	write_register = instruction[15:11];
      end
      else begin
	write_register = instruction[20:16];
      end

      if (memtoreg == 0) begin
	write_data = alu_result;
      end
      else begin
	write_data = read_data;
      end

      // sign extension
      sign_extend[15:0] = instruction[15:0];

      if (instruction[15] == 0) begin
	 sign_extend[31:16] = 0;
      end
      else begin
	 sign_extend[31:16] = 16'hffff;
      end
	
   end // always @ (instruction, regdst, alu_result, memtoreg, read_data)
   
   always @ (posedge pclk, posedge reset) begin
      if (reset == 1) begin
	for (i=0; i<=7; i=i+1) begin
          registers[i] <= 0;
	end
      end
      else begin
	 if (regwrite == 1 && write_register != 0) begin
            registers[write_register] <= write_data;
	 end
      end
   end // always @ (posedge pclk, posedge reset)

endmodule // idecode
