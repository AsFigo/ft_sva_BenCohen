import uvm_pkg::*;
`include "uvm_macros.svh"
 
module mclk2; 
	bit clk1=1, clk2=1, a=1, b=1; 
	initial forever #6 clk1=!clk1; 
	initial forever #18 clk2=!clk2; 
	always @(posedge clk1)  
		#2 if (!randomize(a, b))  `uvm_error("MYERR", "This is a randomize error");  

    ap0q: assert property(@(posedge clk1) $rose(a) ##0 @(posedge clk2)  b |-> 1);
    ap1q: assert property(@(posedge clk1) $rose(a) ##1 @(posedge clk2)  b |-> 1);
    ap2q: assert property(@(posedge clk1) $rose(a) ##0 @(posedge clk2)  ##1 b |-> 1);    
		
	ap0: assert property(@(posedge clk1) $rose(a) |-> @(posedge clk2)  b);
	ap1: assert property(@(posedge clk1) $rose(a) |=> @(posedge clk2)  b);
	ap2: assert property(@(posedge clk1) $rose(a) |-> @(posedge clk2)  ##1 b);
	initial begin
		$dumpfile("dump.vcd"); $dumpvars;
	end
	  
	/* always @(posedge clk)  begin 
       if (!randomize(a, b, c) with {a dist{1'b1:=20, 1'b0:=80};
				                     b dist{1'b1:=10, 1'b0:=90};
				                     })  
				                      `uvm_error("MYERR", "This is a randomize error");
    end  */
endmodule 
	