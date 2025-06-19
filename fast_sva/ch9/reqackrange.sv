/* ENDPOINT IN THE DISABLE 
   Loay_Mohamed@mentor.com sva Aug 29, 2021, 1:55 PM  Service Request # 3652827954 
   Code works with Aldec  Edit code - EDA Playground
   https://edaplayground.com/x/bZSH  */

/* 16.13.5 Detecting and using end point of a sequence in multiclock context
Method triggered can be applied to detect the end point of a multiclocked sequence. Method triggered
can also be applied to detect the end point of a sequence from within a multiclocked sequence. In both cases,
the ending clock of the sequence instance to which triggered is applied shall be the same as the clock in
the context where the application of method triggered appears. */
   
// What I am saying is that that the disable iff is asynchronous and requires as argument an expression, 
// thus (a_sequence.triggered) is legal.  

import uvm_pkg::*; `include "uvm_macros.svh" 
module top; 
    bit clk, req, grnt;
    event e, e0, e1; 
    initial forever #5 clk=!clk;  

    sequence s_req15;  @(posedge clk) req ##[1:5] 1;  endsequence
    ap_grnt_req15: assert property (
     @(posedge clk) $rose(grnt) |-> s_req15.triggered); 

      initial begin
         bit v_a, v_b;
         repeat (50) begin
           @(posedge clk);
           if (!randomize(v_a, v_b) with {
             v_a   dist {1'b1 := 1, 1'b0 := 10};
             v_b   dist {1'b1 := 1, 1'b0 := 5}; 
           }) `uvm_error("MYERR", "This is a randomize error");
           req <= v_a;
           grnt <=!v_b; 
         end
         $finish;
       end   
endmodule  
/* Aldec run
 KERNEL:                   30 SHOULD FAIL 1
# KERNEL:                   35 ap_glitch2 FAIL
# KERNEL:                   70 SHOULD FAIL 2

Questa Sim-64, Version 2021.3 win64 Jul 13 2021
# ** Error (suppressible): (vsim-8429) Ending clock of sequence 'c1' with method ended/triggered does not match with the clock of the context.
#    Time: 0 ns  Iteration: 0  Instance: /top File: C:/ben_play/questa_issues.sv Line: 15
# Error loading design
*/