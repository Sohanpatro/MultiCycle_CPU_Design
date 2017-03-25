`timescale 100ps / 1ps

module datapath(
		output Dcondn,
		output [6:0] irContr,
		output [15:0] Abus,
		inout [15:0] Dbus,
		//inout [15:0] chk,
		input rd, wr, LPC, TPC, LT, TT, LMAR, TMAR, LIR, RMDRExt, RMDRInt, TMDR2X, TMDR2Ext, TMDR2IR, LMDR, LregY, T1, Lflag, PCrst,
		input [1:0] fnSel,
		input [1:0] selreg);

	wire [15:0] DbusOut;// Dbus10;
	wire [15:0] Xbus, Zbus, y, irOut, irIn, mdrIn, mdrOut, marOut, tOut, pcOut;
	//reg [15:0] irOut;
	wire [2:0] pa, wpa, rb, rx, rdst, aluSel, alusel1;
	wire c_n, c_n_minus_1;
	
	assign rb[0] = irOut[6];
	assign rb[1] = irOut[7];
	assign rb[2] = irOut[8];
	
	assign rx[0] = irOut[3];
	assign rx[1] = irOut[4];
	assign rx[2] = irOut[5];
	
	assign rdst[0] = irOut[0];
	assign rdst[1] = irOut[1];
	assign rdst[2] = irOut[2];
	
	assign wpa[0] = irOut[0];
	assign wpa[1] = irOut[1];
	assign wpa[2] = irOut[2];
	
	// IR, MDR, MAR- memory 
	register_16 ir(irOut, Dbus, LIR, rst),
					mdr(mdrOut, mdrIn, LMDR, rst),
					mar(marOut, Zbus, LMAR, rst);
	genvar fli;
	generate for(fli = 0; fli <= 6; fli = fli + 1)
	begin:loop
		assign irContr[fli] = irOut[fli+9];
	end
	endgenerate
	
//	triStateBuffer tmdr2ir(irIn, mdrOut, TMDR2IR),
	triStateBuffer rmdrext(mdrIn, Dbus, RMDRExt),
						rmdrint(mdrIn, Zbus, RMDRInt),
						tmdr2ext(DbusOut, mdrOut, TMDR2Ext),
						tmdr2x(Xbus, mdrOut, TMDR2X),
						tmar(Abus, marOut, TMAR);
	
	assign Dbus = (TMDR2Ext) ? DbusOut : 16'bzzzzzzzzzzzzzzzz;
	
	/*buf(Dbus[0], Dbus1[0]);
	buf(Dbus[1], Dbus1[1]);
	buf(Dbus[2], Dbus1[2]);
	buf(Dbus[3], Dbus1[3]);
	buf(Dbus[4], Dbus1[4]);
	buf(Dbus[5], Dbus1[5]);
	buf(Dbus[6], Dbus1[6]);
	buf(Dbus[7], Dbus1[7]);
	buf(Dbus[8], Dbus1[8]);
	buf(Dbus[9], Dbus1[9]);
	buf(Dbus[10], Dbus1[10]);
	buf(Dbus[11], Dbus1[11]);
	buf(Dbus[12], Dbus1[12]);
	buf(Dbus[13], Dbus1[13]);
	buf(Dbus[14], Dbus1[14]);
	buf(Dbus[15], Dbus1[15]);*/
//	triStateBuffer chkrmdrext(mdrIn, chk, RMDRExt),
				//		chktmdr2ext(chk, mdrOut, TMDR2Ext);
						
	// register bank, alu, status detectors & other registers
	//not(nrst, rst), (nrstPCsignal, rstPCsignal);
	//or(rstPCsignal, nrst, PCrst);	//rstPCsignal, PCrst are active high signals
	register_16 t(tOut, Zbus, LT, rst),
					//pc(pcOut, Zbus, LPC, nrstPCsignal),
					pc(pcOut, Zbus, LPC, PCrst),
					regy(y, Xbus, LregY, rst);
	triStateBuffer tt(Xbus, tOut, TT),
						tpc(Xbus, pcOut, TPC),
						t1(Xbus, 16'b0000000000000001, T1);
	regBank rgbnk(Xbus, Zbus, pa, wpa, rd, wr);
	mux4_1_3 muxpa(pa, rb, rx, rdst, , selreg);
	
	mux4_1_3 muxfnsel(alusel1, {irOut[14], irOut[13], irOut[12]}, 3'b110, 3'b000, 3'bXXX, fnSel);
	not(n2, alusel1[1]), (n3, alusel1[0]);
	and(mnsSel, alusel1[2], n2, n3);
	mux2_1_3 muxmns(aluSel, alusel1, 3'b001, mnsSel);
	alu aluop(Zbus, c_n, c_n_minus_1, Xbus, y, aluSel);
	statusDetectors condflag(Dcondn, Zbus, c_n, c_n_minus_1, Lflag, irOut[12:9]);
	
endmodule


module triStateBuffer(
		output [15:0] b,
		input[15:0] a,
		input enable);
	assign b = (enable) ? a : 16'bzzzzzzzzzzzzzzzz;
	/*always@(a or enable)
		begin
			if(enable)
				b=a;
			else
				b=16'bz;
		end*/
	// STRUCTURAL- DOES NOT WORK !!!
	/*not(nen, enable);
	wire [15:0] t1, t2;
	genvar i;
	generate for(i=0; i <= 15; i = i+1)
	begin:loop
		//and(t1[i], enable, a[i]), (t2[i], nen, 1'bZ);
		//or(b[i], t1[i], t2[i]);
		mux2_1 m(b[i], 1'bZ, a[i], enable);
	end
	endgenerate*/
endmodule

module tb_triStateBuffer;
	reg [15:0] a;
	reg en;
	wire [15:0] b;
	
	triStateBuffer m(b, a, en);
	
	initial
	begin
		a = 30;
		#10 en=0;
		#10 en=1;
		#10 a=2;
		#10 a=5; en=0;
		#10 a=10; en=1;
	end
endmodule



module alu(
		output[15:0] z,
		output c_n, c_n_minus_1,
		input[15:0] x, y,
		input [2:0] fnsel);

	wire [15:0] cmpOut, orOut, andOut, y1, addsubOut;
	
	xor_16_1 xm(y1, y, fnsel[0]);
	adder_16 addm(addsubOut, c_n, c_n_minus_1, x, y1, fnsel[0]);
	
	and_16 andm(andOut, x, y);
	
	or_16 om(orOut, x, y);
	
	cmp_16 cm(cmpOut, x);
	
	mux8_1_16 mm(z, addsubOut, addsubOut, andOut, orOut, 16'bXXXXXXXXXXXXXXXX, cmpOut, x, 16'bXXXXXXXXXXXXXXXX, fnsel);

endmodule

module tb_alu;
	reg[15:0] x, y;
	reg[2:0] fnsel;
	wire [15:0] z;
	wire c_n, c_n_minus_1;
	
	alu m(z, c_n, c_n_minus_1, x, y, fnsel);
	
	initial
	begin
		x = 5; y = 12;
		#10 fnsel = 0;
		#10 fnsel = 2;
		#10 fnsel = 1;
		#10 fnsel = 3;
		#10 fnsel = 0;
		#10 fnsel = 5;
		#10 fnsel = 4;
	end
endmodule



module dff(
		output reg q, nq,
		input d,
		input ld, rst);
	//reg q, nq;
	always @ (posedge ld or negedge rst)
	begin
		if(rst == 0)
			q <= 0;
		else
			begin
				q <= d;
				nq <= ~d;
			end
	end

	//assign nq <= q;
endmodule

module tb_dff;
	reg d;
	reg ld, rst;
	wire q, nq;
	
	dff m(q, nq, d, ld, rst);
	
	initial
	begin
		rst=0; d=1;
		#10 ld=1;
		#10 rst=1;
		#10 ld=0;
		#10 ld=1;
		#10 d=0;
		#10 ld=0;
		#10 ld=1;
		#10 ld=0; rst=0;
	end
endmodule


/*
module statusDetectors(
		output Zout, nZout, Cout, nCout, Vout, nVout, Sout, nSout,
		input [15:0] z,
		input c_n, c_n_minus_1, Lflag);
	//buf(Cin, c_n);
	
	// assign statement is allowed in Structural coding !!! :)
	assign Cin = c_n;
	
	xor(Vin, c_n, c_n_minus_1);
	
	assign Sin = z[15];
	
	nor(Zin, z[0], z[1], z[2], z[3], z[4], z[5], z[6], z[7], z[8], z[9], z[10], z[11], z[12], z[13], z[14], z[15]);

	dff m1(Zout, nZout, Zin, Lflag, rst),
		 m2(Cout, nCout, Cin, Lflag, rst),
		 m3(Vout, nVout, Vin, Lflag, rst),
		 m4(Sout, nSout, Sin, Lflag, rst);
endmodule*/

module statusDetectors(
		output Dcondn,
		input [15:0] z,
		input c_n, c_n_minus_1, Lflag,
		input [3:0] IR12_9);
	//buf(Cin, c_n);
	
	// assign statement is allowed in Structural coding !!! :)
	assign Cin = c_n;
	
	xor(Vin, c_n, c_n_minus_1);
	
	assign Sin = z[15];
	
	nor(Zin, z[0], z[1], z[2], z[3], z[4], z[5], z[6], z[7], z[8], z[9], z[10], z[11], z[12], z[13], z[14], z[15]);

	dff m1(Zout, nZout, Zin, Lflag, rst),
		 m2(Cout, nCout, Cin, Lflag, rst),
		 m3(Vout, nVout, Vin, Lflag, rst),
		 m4(Sout, nSout, Sin, Lflag, rst);

	muxDcondn DCon(Dcondn, 1'b1, Zout, nZout, Cout, nCout, Vout, nVout, Sout, nSout, IR12_9);
endmodule



module cmp_16(
		output [15:0] o,
		input[15:0] i);
	wire[15:0] t;
	genvar j;
	generate for(j=0; j <= 15; j=j+1)
	begin:loop
		not(t[j], i[j]);
	end
	endgenerate

	//module adder_16 (sum, c_n, c_n_minus_1, a, b, cin);
	adder_16 m(o, cn, cn1, t, 16'b0000000000000000, 1'b1);
endmodule

module tb_cmp_16;
	reg [15:0] i;
	wire [15:0] o;
	
	cmp_16 m(o, i);
	
	initial
	begin
		i=2;
		#10 i = 2**15 -1;
		#10 i = -5;
		#10 i=-2**15;
		#0.001 $finish;
	end
endmodule



module mux4_1_3(
		output reg [2:0] o,
		input [2:0] i0, i1, i2, i3,
		input [1:0] sel);
//	not(nsel, sel);
//	and(t1, i0, nsel), (t2, i1, sel);
//	or(o, t1, t2);
	always @(sel, i0, i1, i2, i3)
	case(sel)
		2'b00: o = i0;
		2'b01: o = i1;
		2'b10: o = i2;
		2'b11: o = i3;
	endcase
endmodule

module tb_mux4_1_3;
	reg [2:0] i0, i1, i2, i3;
	reg [1:0] sel;
	wire [2:0] o;
	
	mux4_1_3 m(o, i0, i1, i2, i3, sel);
	
	initial
	begin
		i0=0; i1=1; i2 = 2; i3 = 3;
		#10 sel=0;
		#10 sel=1;
		#10 sel=2;
		#10 sel=0;
		#10 sel=3;
		#10 sel=1;
	end
endmodule



module mux8_1_16(
		output reg [15:0] o,
		input[15:0] i0, i1, i2, i3, i4, i5, i6, i7,
		input[2:0] sel);
	//reg[15:0] o;
	
	always @ (i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7 or sel)
	case(sel)
		0: o= i0;
		1: o= i1;
		2: o= i2;
		3: o= i3;
		4: o= i4;
		5: o= i5;
		6: o= i6;
		7: o= i7;
	endcase

endmodule

module tb_mux8_1_16;
	reg[15:0] i0, i1, i2, i3, i4, i5, i6, i7;
	reg[2:0] sel;
	wire[15:0] o;
	
	mux8_1_16 m(o, i0, i1, i2, i3, i4, i5, i6, i7, sel);
	
	initial
	begin
		i0=0; i1=1; i2=2; i3=3; i4=4; i5 = 5; i6=6; i7=7;
		#10 sel=0;
		#10 sel=1;
		#10 sel=2;
		#10 sel=3;
		#10 sel=4;
		#10 sel=5;
		#10 sel=6;
		#10 sel=7;
		#10 sel=6;
		#10 sel=1;
	end
endmodule



module mux2_1_3(
		output reg [2:0] o,
		input [2:0] i0, i1,
		input sel);
//	not(nsel, sel);
//	and(t1, i0, nsel), (t2, i1, sel);
//	or(o, t1, t2);
	always @(sel, i0, i1)
	case(sel)
		0: o = i0;
		1: o = i1;
	endcase
endmodule

module tb_mux2_1_3;
	reg [2:0] i0, i1;
	reg sel;
	wire [2:0] o;
	
	mux2_1_3 m(o, i0, i1, sel);
	
	initial
	begin
		i0=0; i1=1;
		#10 sel=0;
		#10 sel=1;
		#10 sel=1;
		#10 sel=0;
		#10 sel=0;
		#10 sel=1;
	end
endmodule



module decoder3_8(out, sel);


  input [2:0] sel;
  output reg [7:0] out;

  always @(sel,out)
	 case (sel)
		 3'b000  : out = 8'b00000001;
		 3'b001  : out = 8'b00000010;
		 3'b010  : out = 8'b00000100;
		 3'b011  : out = 8'b00001000;
		 3'b100  : out = 8'b00010000;
		 3'b101  : out = 8'b00100000;
		 3'b110  : out = 8'b01000000;
		 3'b111	: out = 8'b10000000;
	 endcase

endmodule



module regBank(
		output [15:0] p,
		input [15:0] Din,
		input [2:0] pa, wpa,
		input rd, wr);
	wire[15:0] q0, q1, q2 ,q3 ,q4 ,q5 ,q6 ,q7;
	wire[7:0] wpaOut, t;
	decoder3_8 decm(wpaOut, wpa);
	
	and(ld0, wr, wpaOut[0]);
	and(ld1, wr, wpaOut[1]);
	and(ld2, wr, wpaOut[2]);
	and(ld3, wr, wpaOut[3]);
	and(ld4, wr, wpaOut[4]);
	and(ld5, wr, wpaOut[5]);
	and(ld6, wr, wpaOut[6]);
	and(ld7, wr, wpaOut[7]);
	
	register_16 r0(q0, Din, ld0, rst),
					r1(q1, Din, ld1, rst),
					r2(q2, Din, ld2, rst),
					r3(q3, Din, ld3, rst),
					r4(q4, Din, ld4, rst),
					r5(q5, Din, ld5, rst),
					r6(q6, Din, ld6, rst),
					r7(q7, Din, ld7, rst);
	
	demux1_8 dmm(t, rd, pa);
	
	triStateBuffer tsb0(p, q0, t[0]),
						tsb1(p, q1, t[1]),
						tsb2(p, q2, t[2]),
						tsb3(p, q3, t[3]),
						tsb4(p, q4, t[4]),
						tsb5(p, q5, t[5]),
						tsb6(p, q6, t[6]),
						tsb7(p, q7, t[7]);

endmodule



module full_adder ( a ,b ,c ,sum ,carry );

    output sum ;
    output carry ;

    input a ;
    input b ;
    input c ;
        
//    assign sum = a ^ b ^ c;  
//    assign carry = (a&b) | (b&c) | (c&a);
   // xor (t, a, b);
    //xor (sum, t1, c);
	 xor(sum, a, b, c);
    and (t1, a,b), (t2, b, c), (t3, c,a);
   // or (tt, t1, t2);
    or (carry, t1, t2, t3);
endmodule

module adder_16 (sum, c_n, c_n_minus_1, a, b, cin);

output [15:0] sum ;
output c_n, c_n_minus_1;

input [15:0] a ;
input [15:0] b ;
input cin;

wire [13:0] s;

full_adder u0 (a[0],b[0],cin,sum[0],s[0]);
full_adder u1 (a[1],b[1],s[0],sum[1],s[1]);
full_adder u2 (a[2],b[2],s[1],sum[2],s[2]);
//full_adder u3 (a[3],b[3],s[2],sum[3],carry);
full_adder u3 (a[3],b[3],s[2],sum[3],s[3]);
full_adder u4 (a[4],b[4],s[3],sum[4],s[4]);
full_adder u5 (a[5],b[5],s[4],sum[5],s[5]);
full_adder u6 (a[6],b[6],s[5],sum[6],s[6]);
full_adder u7 (a[7],b[7],s[6],sum[7],s[7]);

full_adder  u8(a[8],b[8],s[7],sum[8],s[8]);
full_adder  u9(a[9],b[9],s[8],sum[9],s[9]);
full_adder  u10(a[10],b[10],s[9],sum[10],s[10]);
full_adder  u11(a[11],b[11],s[10],sum[11],s[11]);
full_adder  u12(a[12],b[12],s[11],sum[12],s[12]);
full_adder  u13(a[13],b[13],s[12],sum[13],s[13]);
full_adder  u14(a[14],b[14],s[13],sum[14],c_n_minus_1);
full_adder  u15(a[15],b[15],c_n_minus_1, sum[15],c_n);

endmodule

module tb_adder_16;
	reg[15:0] a, b;
	reg cin;
	wire[15:0] sum;
	wire c_n, c_n_minus_1;
	
	adder_16 m(sum, c_n, c_n_minus_1, a, b, cin);
	
	initial
	begin
		cin=1;
		a = 2**15 - 1;
		b = 4;
		#10 a=3; b=5;
	end
	
	initial #10.001 $finish;
endmodule



module xor_16_1(
		output[15:0] c,
		input [15:0] a,
		input b);
	genvar i;
	generate for(i=0; i <= 15; i=i+1)
	begin:loop
		xor(c[i], a[i], b);
	end
	endgenerate

endmodule



module or_16(
		output[15:0] c,
		input [15:0] a, b);
	genvar i;
	generate for(i=0; i <= 15; i=i+1)
	begin:loop
		or(c[i], a[i], b[i]);
	end
	endgenerate

endmodule



module and_16(
		output[15:0] c,
		input [15:0] a, b);
	genvar i;
	generate for(i=0; i <= 15; i=i+1)
	begin:loop
		and(c[i], a[i], b[i]);
	end
	endgenerate

endmodule



module mux2_1(
		output o,
		input i0, i1, sel);
	not(nsel, sel);
	and(t1, i0, nsel), (t2, i1, sel);
	or(o, t1, t2);
endmodule

module tb_mux2_1;
	reg i0, i1, sel;
	wire o;
	
	mux2_1 m(o, i0, i1, sel);
	
	initial
	begin
		i0=0; i1=1;
		#10 sel=0;
		#10 sel=1;
		#10 sel=1;
		#10 sel=0;
		#10 sel=0;
		#10 sel=1;
	end
endmodule

module muxDcondn(
		output reg Dcondn,
		input iu, iz, inz, ic, inc, iv, inv, is, ins,
		input[3:0] IR12_9);
	//reg[15:0] o;
	
	always @ (iu, iz, inz, ic, inc, iv, inv, is, ins, IR12_9)
	case(IR12_9)
		4'b0000: begin Dcondn= iu; /*$display("Dcondn = iu\n");*/ end
		4'b1000: begin Dcondn= iz; /*$display("Dcondn = iz\n");*/ end
		4'b1001: begin Dcondn= inz; /*$display("Dcondn = inz\n");*/ end
		4'b1010: begin Dcondn= ic; /*$display("Dcondn = ic\n");*/ end
		4'b1011: begin Dcondn= inc; /*$display("Dcondn = inc\n");*/ end
		4'b1100: begin Dcondn= iv; /*$display("Dcondn = iv\n");*/ end
		4'b1101: begin Dcondn= inv; /*$display("Dcondn = inv\n");*/ end
		4'b1110: begin Dcondn= is; /*$display("Dcondn = is\n");*/ end
		4'b1111: begin Dcondn= ins; /*$display("Dcondn = ins\n");*/ end
	endcase

endmodule

module tb_muxDcondn;
	reg i0, i1, i2, i3, i4, i5, i6, i7, i8;
	reg[3:0] sel;
	wire o;
	
	muxDcondn m(o, i0, i1, i2, i3, i4, i5, i6, i7, i8, sel);
	
	initial
	begin
		i0=1;
		i1=1;
		i2=1;
		i3=1;
		i4=1;
		i5=1;
		i6=1;
		i7=1;
		i8=1;
		// i2=2; i3=3; i4=4; i5 = 5; i6=6; i7=7; i8
		//#10 sel=4'b0XXX;
		#10 sel=4'b1011;
		#10 sel=4'b1000;
		#10 sel=4'b1110;
		#10 sel=4'b1010;
		#10 sel=4'b1001;
		#10 sel=4'b0000;
		#10 sel=4'b1100;
		//#10 sel=4'b0111;
		#10 sel=4'b1101;
		#10 sel=4'b1111;
		//#10 sel=4'b0X1X;
		#10 sel=4'b1101;
		#10 sel=4'b1110;
	end
endmodule




module demux1_8(
		output reg [7:0] o,
		input i,
		input [2:0] sel);
	always @ (i or sel)
//	begin
//		case(sel)
//			0: begin o0 <= 1; o1 <= 0; o2 <= 0; o3 <= 0; o4 <= 0; o5 <= 0; o6 <= 0; o7 <= 0; end
//			1: begin o0 = 0; o1 = 1; o2 = 0; o3 = 0; o4 = 0; o5 = 0; o6 = 0; o7 = 0; end
//			2: begin o0 = 0; o1 = 0; o2 = 1; o3 = 0; o4 = 0; o5 = 0; o6 = 0; o7 = 0; end
//			3: begin o0 = 0; o1 = 0; o2 = 0; o3 = 1; o4 = 0; o5 = 0; o6 = 0; o7 = 0; end
//			4: begin o0 = 0; o1 = 0; o2 = 0; o3 = 0; o4 = 1; o5 = 0; o6 = 0; o7 = 0; end
//			5: begin o0 = 0; o1 = 0; o2 = 0; o3 = 0; o4 = 0; o5 = 1; o6 = 0; o7 = 0; end
//			6: begin o0 = 0; o1 = 0; o2 = 0; o3 = 0; o4 = 0; o5 = 0; o6 = 1; o7 = 0; end
//			7: begin o0 = 0; o1 = 0; o2 = 0; o3 = 0; o4 = 0; o5 = 0; o6 = 0; o7 = 1; end
//		endcase
		case(sel)
			7: o = {i, 7'b0000000};
			6: o = {1'b0, i, 6'b000000};
			5: o = {2'b00, i, 5'b00000};
			4: o = {3'b000, i, 4'b0000};
			3: o = {4'b0000, i, 3'b000};
			2: o = {5'b00000, i, 2'b00};
			1: o = {6'b000000, i, 1'b0};
			0: o = {7'b0000000, i};
			default: o = 8'b00000000;
		endcase
//	end

endmodule

module tb_demux1_8;
	reg [2:0] sel;
	reg i;
	wire [2:0] o;
	
	demux1_8 m(o, i, sel);
	
	initial
	begin
		i=1; sel=3;
		#10 sel=5;
		#10 i=0;
		#10 sel=4;
		#10 sel=7; i=1;
	end
endmodule


module register_16(
		output reg[15:0] q,
		input[15:0] d,
		input ld, rst);
	//reg[15:0] q;
	always @ (posedge ld or negedge rst)
	begin
		if(rst == 0)
			q <= 0;
		else
			q <= d;
	end

endmodule

module tb_register_16;
	reg [15:0] d;
	reg ld, rst;
	wire[15:0] q;
	
	register_16 m(q, d, ld, rst);
	
	initial
	begin
		rst=0; d=5;
		#10 ld=1;
		#10 rst=1;
		#10 ld=0;
		#10 ld=1;
		#10 d=3101;
		#10 ld=0;
		#10 ld=1;
		#10 ld=0; rst=0;
	end
endmodule
