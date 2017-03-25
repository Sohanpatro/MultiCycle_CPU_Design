`timescale 100ps / 1ps
/*
module memoryModule(
		//input [15:0] M[2^16-1:0],
		input [15:0] Abus,
		inout [15:0] Dbus,
		input rdM, wrM,
		output reg mfc);
		
module controller(
		output reg rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst,
		// as usual PCrst (to reset only the PC register in the datapath) is active low signal
		////PCrst was previously active high signal
		output reg [1:0] fnSel, selreg,
		input Dcondn, clk, rstIn, mfc, //rstIn is also active low
		input [6:0] irContr);

module datapath(
		output Dcondn,
		output [6:0] irContr,
		output [15:0] Abus,
		inout [15:0] Dbus,
		input rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, PCrst,
		input [1:0] fnSel,
		input [1:0] selreg);
*/
module topOverall_CPUmem(
		input clk, rstIn);// clk, rstIn
	 
	 wire Dcondn, rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst, mfc;
	 wire [6:0] irContr;
	 wire [15:0] Abus, Dbus;
	 wire [1:0] fnSel, selreg;
	 
	datapath dpO(Dcondn, irContr, Abus, Dbus, rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, PCrst, fnSel, selreg);
	controller contrO(rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst, fnSel, selreg, Dcondn, clk, rstIn, mfc, irContr);
	memoryModule memO(Abus, Dbus, rdM, wrM, mfc);

endmodule

module tb_topOverall_CPUmem;
	reg clk,rstIn;
	
	topOverall_CPUmem uutO(clk, rstIn);
	
	// Clock generator
	initial
	begin
		clk = 1;
		forever #5 clk = ~clk;
	end
	
	//Stimulus generator
	initial
	begin
		rstIn = 0;
		#5; rstIn = 1;
	end
endmodule
