/*
Code for use with the book
"SystemVerilog Assertions Handbook, 2nd edition"ISBN  878-0-9705394-8-7

Code is copyright of VhdlCohen Publishing & CVC Pvt Ltd., copyright 2009 

www.systemverilog.us  ben@systemverilog.us
www.cvcblr.com, info@cvcblr.com

All code provided in this book and in the accompanied website is distributed
 with *ABSOLUTELY NO SUPPORT* and *NO WARRANTY* from the authors.  Neither
the authors nor any supporting vendors shall be liable for damage in connection
with, or arising out of, the furnishing, performance or use of the models
provided in the book and website.
*/
module counter; 
  timeunit 1ns; 
  timeprecision 100ps;
  logic clk=0, reset_n=0, go = 0;
  int cntr =0;
  property pCounterMaxed;
    @ (posedge clk) disable iff (!reset_n)
     go |=> (cntr <= 3);
  endproperty : pCounterMaxed

  apCounterMaxed : assert property (pCounterMaxed) else 
      $display("%0t SVA_ERR: Counter exceeded 3, cntr %0d; sampled(cntr) %0d ",
              $time, cntr, $sampled(cntr));

  default clocking @(negedge clk); endclocking
  initial  
  begin : clk_gen
   clk <= 0;  forever #5 clk <= ~clk;
  end

  initial
   begin : stim
     
     @ (negedge clk); // sync to neg edge to avoid data change in active clk edge
     reset_n = 1;
     go = 1;
     repeat (10) @ (negedge clk);
     $stop;
   end // stim
  
  always_ff  @ (posedge clk)
    if (!reset_n)  cntr <= 'b0;
    else  cntr <= cntr + 1'b1;
  endmodule : counter

