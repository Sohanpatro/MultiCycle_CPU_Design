`timescale 1ns / 1ps

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
