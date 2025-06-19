// Q. When Sig_a goes low then for next 1 or 2 clock cycle we need to disable the assertion.
//can we write it in disable iff condition. If yes, then how to write this condition inside disable iff ?

module top;
  timeunit 10ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, a, b, c=0, reset_n=1, disb0, disb1;
  default clocking @(posedge clk);
  endclocking
  initial forever #2 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end 

  task automatic t_disb(bit choice);
    disb0 =1;  disb1=1;
    if(choice==0) #1 disb0 =0;   
    else @(posedge clk) disb1 =0;    
  endtask

  ap_disb_async: assert property(@ (posedge clk)  
     disable iff(reset_n==0) accept_on(disb0) 
          $rose(a)  |-> ##[1:2] (b, t_disb(0))  ##5 c);  

  ap_disb_sync: assert property(@ (posedge clk)  
          disable iff(reset_n==0) sync_accept_on(disb1) 
               $rose(a)  |-> ##[1:2] (b, t_disb(1))  ##5 c);  

   

  initial begin
    bit v_a, v_b, v_err;
    $dumpfile("dump.vcd"); $dumpvars;
    // $dumpfile("Test_Adder_16.vcd");
   // $dumpvars(1, Test_Adder_16);
 
    repeat (200) begin
      @(posedge clk);
      if (!randomize(v_a, v_b, v_err) with {
        v_a   dist {1'b1 := 1, 1'b0 := 1};
        v_b   dist {1'b1 := 1, 1'b0 := 1};
      }) `uvm_error("MYERR", "This is a randomize error");
      a <= v_a;
      b <= v_b; 
    end
    $finish;
  end
endmodule