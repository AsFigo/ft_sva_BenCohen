module top;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, sig, a, b, c, d, e, f, g,  reset_n;
  initial forever #5 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end

  function  automatic void fn(int x);    
    case (x)
       1: b=1;
       2: c=1;
       3: d=1;
       4: e=1;
       5: f=1;
       6: g=1;
    endcase     
  endfunction
  ap_concurrent_direct: assert property(@ (posedge clk) ##1 sig  ) else a=1;  // a get 1
  ap_concurrent_fn: assert property(@ (posedge clk) ##2 sig  ) else fn(1);    // b get 1
  ap_concurrent_blk: assert property(@ (posedge clk) ##2 sig  ) else begin 
     g=1; 
     $display("%t $sampled(sig)=%b", $realtime, sig);
  end 
  always_comb begin
    am_sig: assert(sig) else begin  c=1;  f=1; end // c get 1
  end
  am_sig_deffered: assert #0 (sig) else  fn(3);  // d get 1
   // BAD am_sig_deffered2: assert #0 (sig) else  g=1; //only have a subroutine call
  am_final: assert final (c==0) else fn(4);  //  e get 1 
  // BADam_final2: assert final (c) else f=1; //only have a subroutine cal



  initial  begin
    $dumpfile("dump.vcd"); $dumpvars;
    // $dumpfile("Test_Adder_16.vcd");
   // $dumpvars(1, Test_Adder_16); 
    repeat (20) begin
      @(posedge clk);
    end
    $finish;
  end
endmodule