//==============================================================
// Design name:		Asynchronous Flip-Flop
// File name: 		Asyn_Flip_Flop.sv
// Project name:	LAB 5: Asynchronous FIFO 
// Author:			hungbk99
//==============================================================
primitive	Asyn_FF(
			q,
			clk,
			d,
			r,
			notif);
//========================Interfaces============================
//Inputs			
	input	clk;
	input	d;
	input 	r;
	input 	notif;
	
//Outputs	
	output 	q;
	
//Internal signals
	reg		q;	

//==========================Table===============================
/*	table
	//	clk	rst_n	notif	D	:	Q	:	Q+
		?	0		b		?	:	?	:	0;
		?	? 		*		?	:	?	:	b;
		r	1		b		0	:	?	:	0;
		r 	1		b		1	:	?	:	1;
		f	1		b		?	:	?	:	-;	
		?	1		b		?	:	?	:	-;
	endtable
*/
/*
	table
	// 	clk	d	r	notif	:	state 	: 	next_state
		? 	? 	? 	* 		:	?		:	b;	
		?  	?	0	b		:	?		:	0;	
//		b	?	1	b		:	?		:	-;
		f	?	1	b		:	?		:	-;
		r	0	1	b		:	?		:	0;
		r	1	1	b		:	?		:	1;
	endtable	
	*/
		table
	// 	clk	d	r	notif	:	state 	: 	next_state
		? 	? 	? 	* 		:	?		:	x;	
		?  	?	0	b		:	?		:	0;	
//		b	?	1	b		:	?		:	-;
		f	?	1	b		:	?		:	-;
		r	0	1	b		:	?		:	0;
		r	1	1	b		:	?		:	1;
	endtable	
	
endprimitive		
