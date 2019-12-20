`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Design Name: Asynchronous FIFO Testbench
// Module Name: FIFO_testbench
// Project Name: LAB 5: Asynchronous FIFO
// Author: hungbk99
// Page:     VLSI Technology
//////////////////////////////////////////////////////////////////////////////////
include"Asyn_Flip_Flop.sv";
`include "asyn_fifo_define.vh"

module FIFO_testbench(raddr_buf, waddr_buf, meta_br, meta_bw, w_meta, r_meta);
    
    `include"asyn_fifo_parameters.vh";
    
 //==================================Interfaces===================================
    reg r_clk;
    reg w_clk;
    reg rst_n;
    reg store;
    reg load;
    reg [DATA_WIDTH-1:0] data_in;
    reg [DATA_WIDTH-1:0] data_out;
    // `ifdef FULL_FLAG
    reg    fifo_full;
    //`endif
    `ifdef OVERFLOW_FLAG
     reg   fifo_overflow;
    `endif
    //`ifdef EMPTY_FLAG
     reg   fifo_empty;
    //`endif
    `ifdef  UNDERFLOW_FLAG
     reg   fifo_underflow;
    `endif
	
	
	wire	[POINTER_WIDTH:0] r_ptr;
	wire	[POINTER_WIDTH:0] w_ptr;    
	wire	[POINTER_WIDTH-1:0] w_addr_fifo;
	wire	[POINTER_WIDTH-1:0] r_addr_fifo;
	wire 	write_en;
	wire	read_en;
	wire	cond1;
	wire	cond2;
	input bit		meta_br;
	input bit 		meta_bw;
	input reg		[POINTER_WIDTH:0] raddr_buf;
	input reg		[POINTER_WIDTH:0] waddr_buf;
	reg     [POINTER_WIDTH:0] r_ptr_buf;
    reg     [POINTER_WIDTH:0] w_ptr_buf;	
	input 	reg     [POINTER_WIDTH:0] r_meta;
	input 	reg     [POINTER_WIDTH:0] w_meta;
	integer n, m;
	
 //===============================Module Undertest================================
	`include"asynchronous_fifo.sv";
 //	`include"Asyn_FIFO_meta.sv";	
	
	fifo_asynchronous	U(
    r_clk,
    w_clk,
    rst_n,
    store,
    load,
    data_in,
    data_out,
    // `ifdef FULL_FLAG
        fifo_full,
    //`endif
    `ifdef OVERFLOW_FLAG
        fifo_overflow,
    `endif
    //`ifdef EMPTY_FLAG
        fifo_empty,
    //`endif
    `ifdef  UNDERFLOW_FLAG
        fifo_underflow,
    `endif);
    
	assign r_ptr = FIFO_testbench.U.r_ptr;
	assign w_ptr = FIFO_testbench.U.w_ptr;
	assign w_addr_fifo = FIFO_testbench.U.w_addr_fifo;
	assign r_addr_fifo = FIFO_testbench.U.r_addr_fifo;
	assign write_en = FIFO_testbench.U.write_en;
	assign read_en = FIFO_testbench.U.read_en;
	assign r_ptr_buf = FIFO_testbench.U.r_ptr_buf;
	assign w_ptr_buf = FIFO_testbench.U.w_ptr_buf;
	
//	assign cond1 = FIFO_testbench.U.cond1;
//	assign cond2 = FIFO_testbench.U.cond2;
//	assign notif_A1 = FIFO_testbench.U.notif_A1;
//	assign notif_A2 = FIFO_testbench.U.notif_A2;	
//	assign notif_B1 = FIFO_testbench.U.notif_B1;
//	assign notif_B2 = FIFO_testbench.U.notif_B2;	
	
//====================================Test Code===================================


       
	   
						
	always @(posedge r_clk) begin
		meta_br = $random;	
		if((waddr_buf != w_ptr) &&(n == 0))
			begin
				n = 1;
				w_meta = {(POINTER_WIDTH + 1){meta_br}};
				waddr_buf = ((w_ptr ^ waddr_buf) & w_meta)|w_ptr;		
			end
		else begin 
			n = 0;
			waddr_buf = w_ptr;
		end	
		force U.r_ptr_buf = raddr_buf;
	end
	
	always @(posedge w_clk) begin
		meta_bw = $random;
		if((r_ptr != raddr_buf) && (m == 0))
			begin
				m = 1;
				//raddr_buf = ((r_ptr ^ raddr_buf) & {(POINTER_WIDTH+1){meta_bw}})|r_ptr;
				r_meta = {(POINTER_WIDTH+1){meta_bw}};
				raddr_buf = ((r_ptr ^ raddr_buf) & r_meta)|r_ptr;
			end
		else begin
			m = 0;
			raddr_buf = r_ptr;
		end	
		force U.w_ptr_buf = waddr_buf;	
	end

/*	
	always begin
		force U.r_ptr_buf = raddr_buf;
		force U.w_ptr_buf = waddr_buf;	
	end	
//*/

//							slow clock to fast clock
/* 	
    always #10 r_clk = ~r_clk; 
    always #40 w_clk = ~w_clk;

    initial begin
		raddr_buf = 0;
		waddr_buf = 0;
		n = 0;
		m = 0;
        r_clk = 0;
        w_clk = 0;
        rst_n = 0;
        store = 0;
        load = 0;
        data_in = 0;
        //data_out = 0;
        #40
        rst_n = 1;
        store = 1;
        load = 1; 
//		#1000 $finish;
    end
    
    integer i;
    
    initial begin
            // Check FIFO 8x8
        #40    
        for(i = 1; i < 12; i = i + 1)
            #80 data_in = i;      
    end
	
    initial begin
        $display("data_in   data_out");
        $monitor("%d    %d", data_in, data_out);
    end
//*/
	    
//							fast clock to slow clock				
///*
	 always #40 r_clk = ~r_clk; 
     always #10 w_clk = ~w_clk;
             
    initial begin
		raddr_buf = 0;
		waddr_buf = 0;
        r_clk = 0;
        w_clk = 0;
        rst_n = 0;
        store = 0;
        load = 0;
        data_in = 0;
        //data_out = 0;
        #30
        rst_n = 1;
        store = 1;
        load = 1; 
//		#500 $finish;
    end
    
    integer i , k;
    
    initial begin
            // Check FIFO 8x8
		i = 0;	
		k = 0;
        #30
		k = 1;
    end

	always  begin
	#20 if((i < 20)&&(write_en))
		begin	
			data_in = i;
			i = i + 1;	
		end			
	end
	
    initial begin
        $display("data_in   data_out");
        $monitor("%d    %d", data_in, data_out);
    end
//*/
		
		
endmodule

