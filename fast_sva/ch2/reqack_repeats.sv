module reqack_repeats;
  timeunit 1ns; timeprecision 100ps;
  `include "uvm_macros.svh"
  import uvm_pkg::*;
  bit clk, req, ack;
  bit [0:1] tv[0:15] =
  // req ack
  {
    0, 2, 2, 3, 3, 1, 0, 0, 2, 2, 2, 3, 3, 0, 0, 0
  };
  initial forever #10 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end

  ap_req_ack :
  assert property (@(posedge clk) $rose(
      req
  ) |->  // in the same cycle 
  req && !ack [* 3]  // req==1 and ack==0 for 3 cycles, including the current cycle     
  ##1 req && ack [* 2]  // at the next cycle, req==1 for 2 cycles, don’t care about req
  ##1 !req && !ack);  // at the next cycle, req==0 and ack==0 for 1 cycles


  ap_req_ack_range :
  assert property (@(posedge clk) $rose(
      req
  ) |->  // in the same cycle 
  req [* 1: 3]  // req==1 for 1 to 3 cycles  
  ##1 $rose(
      ack
  )  // until it is followed by a rise of ack, ack was 0    
  ##1 ack [* 1: 2]  // ack holds for a max of 2 cycles 
  ##0 $fell(
      req
  )  // until req==0    
  ##1 !req && !ack);  // at the next cycle, req==0 and ack==0 for 1 cycles





  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    bit v_a, v_b, v_c;

    for (int i = 0; i <= 15; i++) begin
      @(posedge clk);
      {req, ack} <= tv[i];
    end
    repeat (1000) begin
      @(posedge clk);
      if (!randomize(
              v_a, v_b, v_c
          ) with {
            v_a dist {
              1'b1 := 3,
              1'b0 := 1
            };
            v_b dist {
              1'b1 := 2,
              1'b0 := 1
            };
            v_c dist {
              1'b1 := 2,
              1'b0 := 1
            };
          })
        `uvm_error("MYERR", "This is a randomize error");
      req <= v_a;
      ack <= v_c;
    end
    $finish;
  end
endmodule
