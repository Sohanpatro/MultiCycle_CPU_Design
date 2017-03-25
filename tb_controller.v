
module tb_controller;
	
//	controller(
//		output rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst,
//		// as usual PCrst (to reset only the PC register in the datapath) is active low signal
//		/*//PCrst was previously active high signal*/
//		output [1:0] fnSel, selreg,
//		input Dcondn, clk, rstIn, mfc, //rstIn is also active low
//		input [6:0] irContr);

	wire rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst;
	wire [1:0] fnSel, selreg;
	reg Dcondn, clk, rstIn, mfc;
	reg [6:0] irContr;
	
	controller uut(rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, rdM, wrM, PCrst, fnSel, selreg, Dcondn, clk, rstIn, mfc, irContr);
	
	// Clock generator
	initial
	begin
		clk = 1;
		forever #5 clk = ~clk;
	end
	
	//Terminate simulation
//	initial #300 $finish;
	// Stimulus generator
	initial
	begin
////		$display("Dcondn = %b", Dcondn);
//		rstIn = 0; mfc = 0;
//		#10; 
//			rstIn = 1; irContr = 7'b1101000; $display("IR = %b", irContr);
////			repeat
////			begin
////				forever begin #1 irContr = irContr + 1; $display("IR = %b", irContr); end
////			end
//////		#(10+30+40+30+40);
//		#10; mfc = 0;
//		#10; 
//		#10;
//		#11; mfc=1;
//		#10;//f3
//		#10;
//		#10;//ai1
//		#10;
//		#10;
//		#10; Dcondn = 0;
//		#10;
//		#10;

/*		rstIn = 0; mfc = 0;
		#10; 
			rstIn = 1; irContr = 7'b0100000; $display("IR = %b", irContr);
		#10; mfc = 0;
		#10;
		#11; mfc=1;
		#10;//f3
		#10;
		#10;//ai1
		#10; mfc = 0;
		#10; //Dcondn = 1;
		#11; mfc=1;
		#10;//ai3
		#10; 
		#10;
		#10; 
		#10; $finish;
*/
		rstIn = 0;// mfc = 0;
		#10; 
			rstIn = 1; irContr = 7'b0010000; $display("IR = %b- {add, sub, and, or}i", irContr);
		#10; mfc = 0;
		#10;
		#11; mfc=1;
		#9;//f3
		#10;
		#10;//ai1
		#10; mfc = 0;
		#10; //Dcondn = 1;
		#11; mfc=1;
		#9;//ai3
		#10; 
		#10;
		#10; 
				//irContr = 7'b0100000; $display("IR = %b- mnsi", irContr);
		#10; irContr = 7'b0100000; $display("\nIR = %b- mnsi", irContr);
		#10; mfc = 0;
		#10;
		#11; mfc=1;
		#9;//f3
		#10;
		#10;//ai1
		#10; mfc = 0;
		#10; //Dcondn = 1;
		#11; mfc=1;
		#9;//ai3
		#10; 
		#10;
		#10; 
//				irContr = 7'b1000000; $display("IR = %b- li", irContr);
		#10; irContr = 7'b1000000; $display("\nIR = %b- li", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; //f3
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; //7
		#10;
		#10;
		
		#10; irContr = 7'b0000001; $display("\nIR = %b- {add, sub, and, or}r", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;
		#10;
		#10;
		
		#10; irContr = 7'b0100001; $display("\nIR = %b- mnsr", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;
		#10;
		#10;
		
		#10; irContr = 7'b1001001; $display("\nIR = %b- lr", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		
		#10; irContr = 7'b0001010; $display("\nIR = %b- {add,sub,&,|}x", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;
		#10;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10; 
		#11; mfc=1;
		#9;
		#10;
		#10;
		
		#10; irContr = 7'b0001011; $display("\nIR = %b- {add,sub,&,|}a", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		
		#10; irContr = 7'b0001100; $display("\nIR = %b- {add,sub,&,|}n", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		
		#10; irContr = 7'b1011100; $display("\nIR = %b- sx", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		
		#9; irContr = 7'b0101110; $display("\nIR = %b- cmp", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		
		#10; irContr = 7'b1101010; $display("\nIR = %b- jump instructions", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10; Dcondn=1;
		#10;
		
		#10; irContr = 7'b1110111; $display("\nIR = %b- jal", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		#10;
		#10;
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9;
		#10;
		#10;
		
		#10; irContr = 7'b1111000; $display("\nIR = %b- jr", irContr);
		#10; mfc=0;
		#10;
		#11; mfc=1;
		#9; 
		#10;//f4
		#10;
		
		#1; $finish;
		
	end
endmodule
