

module top;
`include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk0=1, clk1=1, a, b;  
  initial forever #3 clk0 = !clk0;
  initial forever #1 clk1 = !clk1; //#2  
 
  
 ap_a_next_br: assert property(@(posedge clk0) $rose(a) |=>   @(posedge clk1) b);  
 ap_a01br_nx: assert property(@(posedge clk0) $rose(a) |-> 1 ##1 @(posedge clk1) b); 
 ap_a01br: assert property(@(posedge clk0) $rose(a) |->  ##1 1 ##0  @(posedge clk1) b);  
  
  initial begin

  // $dumpfile("dump.vcd"); $dumpvars;
  // therequests
  repeat(22) begin 
    @(posedge clk0); 
    if (!randomize(a, b) with {
      a   dist {1'b1 := 1, 1'b0 := 1};
      b   dist {1'b1 := 1, 1'b0 := 2}; 
     }) `uvm_error("MYERR", "This is a randomize error"); 
   end
  $finish;
  end
endmodule 



