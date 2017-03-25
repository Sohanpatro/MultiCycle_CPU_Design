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
