/*
`timescale 1ns / 1ps
module memoryModule(
		input [15:0] M[2^16-1:0],
		input [15:0] Abus,
		inout [15:0] Dbus,
		input rdM, wrM,
		output reg mfc);
	reg [15:0] MReg[2^16-1:0];
	reg [15:0] DbusReg;
	assign Dbus = DbusReg;
	assign M = MReg;
	always@(M)
		MReg = M;
	always@(Dbus)
		DbusReg = Dbus;
		
	always@(rdM)
		if(rdM) begin
			mfc <= 0;
			#31 Dbus <= M[Abus];
				 mfc <= 1;
		end
		
	always@(wrM)
		if(wrM) begin
			mfc <= 0;
			#31 M[Abus] <= Dbus;
				 mfc <= 1;
		end
endmodule
*/
/*
`timescale 100ps / 1ps
module memoryModule(
		//input [15:0] M[2^16-1:0],
		input [15:0] Abus,
		inout [15:0] Dbus,
		input rdM, wrM,
		output reg mfc);
//	reg [15:0] M[2^16-1:0];
	reg [15:0] M[0:655];//36];
	
	//Filling the instructions into memory
	initial
	begin
		M[0] = 16'b1000000110001111;
		M[1] = 16'b0000000111110100;
		M[2] = 16'b1001011111010101;
		M[3] = 16'b0000000000000000;
		
//		M[2] = 16'b1010011111000111;
//		M[3] = 16'b0000000000000000;
////		M[2] = 16'b1000000110001110;
//		M[3] = 16'b0000000111110101;

		M[4] = 16'b1000010111101110;
		M[5] = 16'b0000000000000001;
		M[6] = 16'b0000001110000101;
		M[7] = 16'b1010010111101110;
		M[8] = 16'b0000000000001010;
		M[9] = 16'b0100100111110101;
		M[10] = 16'b1111111111111000;
		M[11] = 16'b1101001101010101;
		M[12] = 16'b0000000001011000;
		M[100] = 16'b1001000111000001;
		M[101] = 16'b0000000001111001;
		M[499] = 16'b0000001000001000;
		M[500] = 16'b0000000000001111;
		M[516] = 16'b0000000000000111;
		M[520] = 16'b0000000000001010;
	end
	
	reg [15:0] DbusReg;
	assign Dbus = DbusReg;
	//assign M = MReg;
	//always@(M)
	//	MReg = M;
	always@(Dbus)
		DbusReg = Dbus;
		
	always@(posedge rdM)
		if(rdM == 1) begin
			mfc = 0;
			#21 DbusReg = M[Abus];
				 mfc = 1;
		end
		
	always@(wrM)
		if(wrM == 1) begin
			mfc <= 0;
			#21 M[Abus] <= Dbus;
				 mfc <= 1;
		end
endmodule
*/


`timescale 100ps / 1ps
module memoryModule(
		//input [15:0] M[2^16-1:0],
		input [15:0] Abus,
		inout [15:0] Dbus,
		input rdM, wrM,
		output reg mfc);
//	reg [15:0] M[2^16-1:0];
	reg [15:0] M[0:65535];
	
	//Filling the instructions into memory
	initial
	begin
		M[0] = 16'b1000000110001111;
		M[1] = 16'b0000000111110100;
		M[2] = 16'b1001011111010101;
		M[3] = 16'b0000000000000000;
		
//		M[2] = 16'b1010011111000111;
//		M[3] = 16'b0000000000000000;
////		M[2] = 16'b1000000110001110;
//		M[3] = 16'b0000000111110101;

		M[4] = 16'b1000010111101110;
		M[5] = 16'b0000000000000001;
		M[6] = 16'b0000001110000101;
		M[7] = 16'b1010010111101110;
		M[8] = 16'b0000000000001010;
		M[9] = 16'b0100100111110101;
		M[10] = 16'b1111111111111000;
		M[11] = 16'b1101001101010101;
		M[12] = 16'b0000000001011000;
		M[100] = 16'b1001000111000001;
		M[101] = 16'b0000000001111001;
		M[499] = 16'b0000001000001000;
		M[500] = 16'b0000000000001111;
		M[516] = 16'b0000000000000111;
		
//		M[516] = 16'b0000000000001010;
		
		M[520] = 16'b0000000000001010;
	end
	
	reg [15:0] DbusReg;
//	wire [15:0] DbusIn;
	assign Dbus = (rdM) ? DbusReg : 16'bzzzzzzzzzzzzzzzz;
//	assign DbusIn = (wrM) ? Dbus : 'bz;
	//assign M = MReg;
	//always@(M)
	//	MReg = M;
	//always@(Dbus)
		//DbusReg = Dbus;
		
	always@(posedge rdM or posedge wrM)
	begin
		if(rdM == 1) begin
		//	mfc = 0;
			//#21 
			DbusReg = M[Abus];
				// mfc = 1;
		end
		
	//always@(wrM)
		else if(wrM == 1) begin
//			mfc <= 0;
//			#21
			$display("\n****************************");
			$display("Abus= %d, Dbus= %d, M[Abus]= %d, wrM=%d- %0d(x100)ps", Abus, Dbus, M[Abus], wrM, $time);
			//M[Abus] = Dbus;
			#(1*0.01); $display("Abus= %d, Dbus= %d, M[Abus]= %d, wrM=%d- %0d(x100)ps", Abus, Dbus, M[Abus], wrM, $time);
			$display("****************************\n");
			M[Abus] = Dbus;
	//			 mfc <= 1;
		end
		
//		else
//		begin
//			DbusReg = 16'bz;
//		end
	end
	
	always @ (posedge rdM or posedge wrM)
	begin
		mfc = 0;
		#21;
		mfc = 1;
	end
endmodule

/*
`timescale 100ps / 1ps
module memoryModule(
		//input [15:0] M[2^16-1:0],
		input [15:0] Abus,
		inout [15:0] Dbus,
		input rdM, wrM,
		output reg mfc);
//	reg [15:0] M[2^16-1:0];
	reg [15:0] M[0:655];//36];
	
	//Filling the instructions into memory
	initial
	begin
		M[0] = 16'b1000000110001111;
		M[1] = 16'b0000000111110100;
		M[2] = 16'b1001011111010101;
		M[3] = 16'b0000000000000000;
		
//		M[2] = 16'b1010011111000111;
//		M[3] = 16'b0000000000000000;
////		M[2] = 16'b1000000110001110;
//		M[3] = 16'b0000000111110101;

		M[4] = 16'b1000010111101110;
		M[5] = 16'b0000000000000001;
		M[6] = 16'b0000001110000101;
		M[7] = 16'b1010010111101110;
		M[8] = 16'b0000000000001010;
		M[9] = 16'b0100100111110101;
		M[10] = 16'b1111111111111000;
		M[11] = 16'b1101001101010101;
		M[12] = 16'b0000000001011000;
		M[100] = 16'b1001000111000001;
		M[101] = 16'b0000000001111001;
		M[499] = 16'b0000001000001000;
		M[500] = 16'b0000000000001111;
		M[516] = 16'b0000000000000111;
		M[520] = 16'b0000000000001010;
	end
	
	//reg [15:0] DbusReg;
	//assign Dbus = DbusReg;
	//assign M = MReg;
	//always@(M)
	//	MReg = M;
	//always@(Dbus)
		//DbusReg = Dbus;
		
//	always@(rdM)
//		if(rdM) begin
//			mfc <= 0;
//			#21 DbusReg <= M[Abus];
//				 mfc <= 1;
//		end
		assign Dbus = (rdM) ? M[Abus] : 'bz;
/////////////		assign mfc = (~rdM) ? z
		
	always@(wrM)
		if(wrM) begin
			mfc <= 0;
			#21 M[Abus] <= Dbus;
				 mfc <= 1;
		end
endmodule*/

//module tb_memoryModule;
//	reg [15:0] M[2^16-1:0];
//endmodule
