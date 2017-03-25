`timescale 1ns / 1ps

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
