module clkgen 
  (
   input  clk,
   input  reset,
   output pclk,
   output iclk,
   output dclk
   );

   localparam s0 = 0, s1 = 1, s2 = 2;

   reg [1:0]  state, nstate;
   reg [2:0]  cont, ncont;

   // external signal out
   assign pclk = cont[2];
   assign iclk = cont[1];
   assign dclk = cont[0];

   always @ (state, reset, cont) begin
      //default
      ncont = cont;
      nstate = state;

      case (state)
	s0: begin
           nstate = s1;
           ncont = 3'b100;
	end
	s1: begin
           nstate = s2;
           ncont = 3'b010;
	end
	default: begin
           nstate = s0;
           ncont = 3'b001;
	end
      endcase

    // reset
      if (reset == 1'b1) begin
	 nstate = s0;
	 ncont = 0;
      end
   end

   // ff
  always @ (posedge clk) begin
     state <= nstate;
     cont <= ncont;
  end

endmodule // clkgen
