`timescale 100ps / 1ps
/*
module datapath(
		output Dcondn,
		output [6:0] irContr,
		output [15:0] Abus,
		inout [15:0] Dbus,
		input rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, PCrst,
		input [1:0] fnSel,
		input [1:0] selreg);

module controller(
		output reg rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst,
		// as usual PCrst (to reset only the PC register in the datapath) is active low signal
		////PCrst was previously active high signal
		output reg [1:0] fnSel, selreg,
		input Dcondn, clk, rstIn, mfc, //rstIn is also active low
		input [6:0] irContr);
*/
module topCPU_DPContr(
		output rdM, wrM,
		output [15:0] Abus,
		input [15:0] Dbus,// chk,
		input clk, rstIn, mfc);//Abus, Dbus, rdM, wrM, clk, rstIn, mfc
	wire Dcondn, rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, PCrst;
	wire [6:0] irContr;
	wire [1:0] fnSel, selreg;
	//wire [15:0] Dbus;
	datapath dp(Dcondn, irContr, Abus, Dbus, /*chk,*/ rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, PCrst, fnSel, selreg);
	controller contr(rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst, fnSel, selreg, Dcondn, clk, rstIn, mfc, irContr);
endmodule

module tb_topCPU_DPContr;
	wire rdM,wrM;
	wire [15:0] Abus;
	reg [15:0] Dbus;// chk;
	reg clk, rstIn, mfc;
	
	topCPU_DPContr uut(rdM, wrM, Abus, Dbus,/* chk,*/ clk, rstIn, mfc);
	
	// Clock generator
	initial
	begin
		clk = 1;
		forever #5 clk = ~clk;
	end
	
	//Stimulus generator
	initial
	begin
		rstIn = 0;// chk = 0;
		#10; rstIn = 1; mfc=0; 
		$display("\nli r7 #500\n------------");
		//#10;mfc=0;
		#10;//chk = 4;
		#11; mfc=1; Dbus = 16'b1000000110001111;//16'b1001000111000001; //16'b1000000110001111;
		#9; //Dbus <= 16'b1000000000000101;
		#10;
		//#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 16'b0000000111110100; //16'b0000000001111001; //16'b0000000111110100;
		#10;
		#10;
		
		//#10;
		//#10;
		
//		#10; mfc=0;
//		//#10;mfc=0;
//		#10;//chk = 4;
//		#11; mfc=1; Dbus = /*16'b1001000111000001; */16'b1000000110001111;
//		#9; //Dbus <= 16'b1000000000000101;
//		#10;
//		#10;
//		#10; mfc=0;
//		#10;
//		#11; mfc=1;
//		#9; Dbus = /*16'b0000000001111001;*/ 16'b0000000111110100;
//		#10;
//		#10;
		
		
		#10; mfc=0; $display("\nla r5, 0(r7) // =15\n-------------------");
		#10;
		#11; mfc=1;
		#9; Dbus = 16'b1001011111010101;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus=16'b0000000000000000;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 15;
		#10;
		
		#10; mfc=0; $display("\nlx r6, 1(r7, r5) // =7\n------------------");
		#10;
		#11; mfc=1;
		#9; Dbus = 16'b1000010111101110;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 1;
		#10;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 7;
		#10;
		
		#10; mfc=0; $display("\naddr r5, r6 // r5=22\n-----------");
		#10;
		#11; mfc=1;
		#9; Dbus = 16'b0000001110101101;
		#10;
		#10;
		#10;
		
		#10; mfc=0; $display("\nmnsn r5, @-8(r7,r6) // z =12\n-----------------");
		#10;
		#11; mfc=1;
		#9; Dbus = 16'b0100100111110101;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus= -8;
		#10;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 520;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 10;
		#10;
		#10;
		
		#10; mfc=0; $display("\njnz #90  //pc=100\n------------");
		#10;
		#11; mfc=1;
		#9; Dbus = 16'b1101001101010101;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; Dbus = 90;
		#10;
		#10;
		
		#6; $finish;
	end
	
endmodule
