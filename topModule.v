`timescale 1ns / 1ps
module topModule(
    );

module datapath(
		output Dcondn,
		output [6:0] irContr,
		output [15:0] Abus,
		inout [15:0] Dbus,
		input rd,wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rst,
		input [1:0] fnSel,
		input [1:0] selreg);

module controller(
		output reg rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, rstDP,
		// as usual rstDP (to reset all registers in the datapath) is active low signal
		/*//PCrst is active high signal*/
		output reg [1:0] fnSel, selreg,
		input Dcondn, clk, rstIn, mfc, //rstIn is also active low
		input [6:0] irContr);

module memoryModule(
		input [15:0] Abus,
		inout [15:0] Dbus,
		input rdM, wrM,
		output reg mfc);

endmodule
