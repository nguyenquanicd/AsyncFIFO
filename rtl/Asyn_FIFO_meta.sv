`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// File Name: 		Asyn_FIFO_meta.sv
// Design Name: 	Asynchronous FIFO with Metastable Approximation
// Project Name: 	LAB 5: Asynchronous FIFO
// Author: 			hungbk99
//////////////////////////////////////////////////////////////////////////////////
//`include"Asyn_Flip_Flop.sv";
`include "asyn_fifo_define.vh"

module fifo_asynchronous(
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
    
//===================================Parameters===================================    
   `include"asyn_fifo_parameters.vh";

//===================================Interfaces===================================
//Inputs
    input   r_clk;
    input   w_clk;
    input   rst_n;
    input   store;
    input   load;
    input   [DATA_WIDTH-1:0] data_in;
	
//Outputs
    // `ifdef FULL_FLAG
        output    reg   fifo_full;
    //`endif
    `ifdef OVERFLOW_FLAG
        output    reg   fifo_overflow;
    `endif
    //`ifdef EMPTY_FLAG
        output    reg   fifo_empty;
    //`endif
    `ifdef  UNDERFLOW_FLAG
        output    reg   fifo_underflow;
    `endif
    output  reg [DATA_WIDTH-1:0] data_out;
    
//=================================Internal Signals===============================    
    reg    [POINTER_WIDTH:0] r_ptr;
    reg    [POINTER_WIDTH:0] w_ptr;
    bit     [DATA_WIDTH-1:0]  FIFO_mem [0:FIFO_DEPTH-1];
    wire    write_en;
    wire    read_en;
    reg    [POINTER_WIDTH:0] r_addr;
    reg    [POINTER_WIDTH:0] w_addr;
    wire    [POINTER_WIDTH-1:0] r_addr_fifo;
    wire    [POINTER_WIDTH-1:0] w_addr_fifo;
	wire 	[POINTER_WIDTH:0] notif_A1;
	wire 	[POINTER_WIDTH:0] notif_A2;
	wire	[POINTER_WIDTH:0] notif_B1;
	wire 	[POINTER_WIDTH:0] notif_B2;
    
//================================================================================
//                                 A HANDSHAKE
//================================================================================  

//===============================Internal Signals=================================
    integer i;
    wire    [POINTER_WIDTH:0] r_ptr_buf;
    wire    [POINTER_WIDTH:0] r_ptr_s;    
    wire    cond1;
    wire    cond2;
       
           
//=================================Write Counter==================================   
    always_ff @(posedge w_clk or negedge rst_n) begin
        if(~rst_n)
            w_addr <= {(POINTER_WIDTH+1){1'b0}};
        else if(write_en)
             w_addr <= w_addr + 1'b1;     
    end
    
//================================W_PTR_BIN2GRAY==================================
    always @(w_addr) begin
        w_ptr[POINTER_WIDTH] = w_addr[POINTER_WIDTH];
        for(i = 0; i < POINTER_WIDTH; i = i + 1)
            w_ptr[i] = w_addr[i] ^ w_addr[i+1];    
    end
 
//===============================R_PTR_SYNCHRONOUS================================
/*    always_ff @(posedge w_clk or negedge rst_n) begin
        if(~rst_n)
        begin
            r_ptr_buf <= 0;
            r_ptr_s <= 0;
        end else
        begin    
            r_ptr_buf <= r_ptr;
            r_ptr_s <= r_ptr_buf;
        end    
    end
 */
///*
	genvar a;
	generate
		for (a = 0; a <= POINTER_WIDTH; a = a + 1)
		begin: A_syn_F
			Asyn_FF A_F(
				r_ptr_buf[a],
				clk_w,
				r_ptr[a],
				rst_n,
				notif_A1[a]);
	
			Asyn_FF A_S(
				r_ptr_s[a],
				clk_w,
				r_ptr_buf[a],			
				rst_n,
				notif_A2[a]);
		end		
	endgenerate
//*/
	
//==============================FULL FLAG GENERATOR===============================
    //`ifdef FULL_FLAG
        assign cond1 = (w_ptr[POINTER_WIDTH-2:0] == r_ptr_s[POINTER_WIDTH-2:0]) ? 1 : 0;
        assign cond2 = ((w_ptr[POINTER_WIDTH] != r_ptr_s[POINTER_WIDTH])
        &&(w_ptr[POINTER_WIDTH-1] != r_ptr_s[POINTER_WIDTH-1])) ? 1 : 0;
        assign fifo_full = cond1 & cond2; 
    //`endif
 
//=================================Write Enable===================================   
   assign write_en = store & (~fifo_full);
   `ifndef FULL_FLAG
        assign write_en = store;
   `endif
   
//==================================Over Flow=====================================
    `ifdef OVERFLOW_FLAG
        always_ff @(posedge w_clk) begin
            if((fifo_full == 1'b1)&&(store == 1'b1))
                    fifo_overflow <= 1'b1;
			else if(load)		
					fifo_overflow <= 1'b0;
			else	
					fifo_overflow <= fifo_overflow;
        end            
    `endif   
    
//================================================================================
//                                B HANDSHAKE
//================================================================================    
         
//================================Internal Signals===============================
    integer j;
    wire     [POINTER_WIDTH:0] w_ptr_buf;
    wire     [POINTER_WIDTH:0] w_ptr_s;  
      
//==================================Read Counter=================================
    always_ff @(posedge r_clk or negedge rst_n) begin
        if(~rst_n)
            r_addr <= {(POINTER_WIDTH+1){1'b0}};
        else if(read_en)
            r_addr <= r_addr + 1'b1;     
    end
    
//================================R_PTR_BIN2GRAY=================================
    always @(r_addr) begin
        r_ptr[POINTER_WIDTH] = r_addr[POINTER_WIDTH];
        for(j = 0; j < POINTER_WIDTH; j = j + 1)
            r_ptr[j] = r_addr[j] ^ r_addr[j+1];    
    end
   
//==============================W_PTR_SYNCHRONOUS================================   
/*  
  always_ff @(posedge r_clk or negedge rst_n) begin
        if(~rst_n) 
        begin
            w_ptr_buf <= 0;
            w_ptr_s <= 0;
        end else
        begin      
            w_ptr_buf <= w_ptr;
            w_ptr_s <= w_ptr_buf; 
        end
    end             
 */
 ///*
	genvar b;
	generate
		for(b = 0; b <= POINTER_WIDTH; b = b + 1)
		begin: B_syn_F	
			Asyn_FF	B_F(
				w_ptr_buf[b],
				clk_r,
				w_ptr[b],
				rst_n,
				notif_B1[b]);
	
			Asyn_FF B_S(
				w_ptr_s[b],
				clk_r,
				w_ptr_buf[b],			
				rst_n,
				notif_B2[b]);
		end	
	endgenerate	
//*/	
	
//================== =============EMPTY_FLAG_GEN==================================         
    //`ifdef EMPTY_FLAG
    assign  fifo_empty = (w_ptr_s[POINTER_WIDTH:0] == r_ptr[POINTER_WIDTH:0]) ? 1 : 0;
    //`endif
    
//================================Read Enable====================================
    assign read_en = load & (~fifo_empty);
    
//================================Under Flow=====================================
    `ifdef UNDERFLOW_FLAG
        always_ff @(posedge r_clk) begin
            if(fifo_empty && load) 
                fifo_underflow <= 1'b1;
			else if(store)	
				fifo_underflow <= 1'b0;
			else	
				fifo_underflow <= fifo_underflow;
        end
    `endif                           

//===============================================================================	

//===============================================================================
    assign r_addr_fifo = r_addr[POINTER_WIDTH-1:0];
    assign w_addr_fifo = w_addr[POINTER_WIDTH-1:0];
 
    always_ff @(posedge r_clk) begin
        if(read_en) 
            data_out <= FIFO_mem[r_addr_fifo];
    end        
    
    always_ff @(posedge w_clk) begin
        if(write_en)
            FIFO_mem[w_addr_fifo] <= data_in;
    end
          
	initial begin	
		$readmemh("D:/questa_sim/VLSI/LAB_5_ASYN_FIFO/memtest.txt", FIFO_mem);
	end	
		
endmodule
