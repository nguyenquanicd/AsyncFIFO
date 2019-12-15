include "Asyn_Flip_Flop.sv";
module UDP_test(clk_w,
				rst_n,
				r_ptr_buf,
				r_ptr_buf_b,
				r_ptr_s,
				r_ptr,
				notif_A1,
				notif_A2);
				
	parameter POINTER_WIDTH = 4;
	input reg clk_w;
	input reg rst_n;
	input [POINTER_WIDTH:0] r_ptr_buf;
	input [POINTER_WIDTH:0] r_ptr_s;
	input reg [POINTER_WIDTH:0] r_ptr;
	input reg [POINTER_WIDTH:0] notif_A1;
	input reg [POINTER_WIDTH:0] notif_A2;
	input [POINTER_WIDTH:0] r_ptr_buf_b;
	
	genvar a, b, c;
	generate
		for (a = 0; a <= POINTER_WIDTH; a = a + 1)
		begin: A_syn_F
			Asyn_FF A_F(
				r_ptr_buf_b[a],
				clk_w,
				r_ptr[a],
				rst_n,
				notif_A1[a]);
		end
		
		for (c = 0; c <= POINTER_WIDTH; c = c + 1)
		begin: time_buff
			buf #0.5 tim(r_ptr_buf[c],r_ptr_buf_b[c]);
		end	
		
		for (b = 0; b <= POINTER_WIDTH; b = b + 1)
		begin:	A_syn_S
			Asyn_FF A_S(
				r_ptr_s[b],
				clk_w,
				r_ptr_buf[b],			
				rst_n,
				notif_A2[b]);
		end		
	endgenerate

/*	Asyn_FF A_F(
				r_ptr_buf[0],
				clk_w,
				r_ptr[0],
				rst_n,
				notif_A1[0]);
*/
	initial begin
		notif_A1 = 0;
		notif_A2 = 0;
		clk_w = 1;
		rst_n = 0;
		r_ptr = 1;
		#2
		rst_n = 1;
		#4 
		r_ptr = 2;
		#2
		r_ptr = 5;
	end	

	always #1 clk_w = ~clk_w;	

endmodule