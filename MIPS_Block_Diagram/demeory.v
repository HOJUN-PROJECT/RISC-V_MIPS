module dmemory 
  (
   output [31:0] read_data,
   input [7:0]	 address,
   input [31:0]	 write_data,
   input	 memread,
   input	 memwrite,
   input	 dclk,
   input	 reset
   );

   wire [31:0] rdata;

   assign read_data = rdata;
  
   datamemory DM 
     (
      .addra(address), 
      .clka(dclk),
      .dina(write_data),
      .douta(rdata),
      .wea(memwrite)
      );

endmodule // dmemory
