module top;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, a, b, tb_a, tb_b, tb_c, tb_d;   
  initial forever #1 clk = !clk;
  

   
  always @(posedge clk) begina
  end

  always_comb ma_a2: assert(a); // tb_a=0; else tb_a<=1; 


 ma_a3: assert #0 (a); // tb_a=0; else tb_a<=1; 

  ap_ab: assert property(@(posedge clk)   a |-> b ) tb_b=0; else tb_b=1;  

  initial begin
    bit v_a, v_b, v_err;
    $dumpfile("dump.vcd"); $dumpvars;
    // $dumpfile("Test_Adder_16.vcd");
   // $dumpvars(1, Test_Adder_16);
       repeat (20) begin
      @(posedge clk);
      if (!randomize(v_a, v_b, v_err) with {
        v_a   dist {1'b1 := 1, 1'b0 := 1};
        v_b   dist {1'b1 := 1, 1'b0 := 2};
        v_err dist {1'b1 := 1, 1'b0 := 15};
      }) `uvm_error("MYERR", "This is a randomize error");
      a <= v_a;
      b<=v_b;  
    end
    $finish;
  end
endmodule
 