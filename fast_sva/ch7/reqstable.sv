	import uvm_pkg::*;
	`include "uvm_macros.svh"
module reqstable; 
	timeunit 1ns;   timeprecision 100ps;
	logic clk=0,  req_valid, req_length, req_ready; 
	initial forever #10 clk=!clk; 	

	
	// Upon a rose of req_valid, req_length  is stable until the first occurence of a rose of req_ready. 
ap_version1: assert property(@(posedge clk) 
    $rose(req_valid) |=> $stable(req_length) until $rose(req_ready) [->1]);

// Upon a rose of req_valid, req_length  is repeated  until an occurence of a rose of req_ready
ap_version2: assert property(@(posedge clk) 
    $rose(req_valid) |=> $stable(req_length)[*0:$] ##1 $rose(req_ready) );

always @(posedge clk)  begin 
	   #1;
	   if (!randomize(req_valid, req_length, req_ready) with {req_valid dist{1'b1:=20, 1'b0:=80};
				                     req_length dist{1'b1:=40, 1'b0:=60};
				                     req_ready dist {1'b1 := 15, 1'b0:= 85};})  
				                      `uvm_error("MYERR", "This is a randomize error"); 
end 
endmodule 