module reardyack;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, req, rdy, ack;
  initial forever #10 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end
  ap_reqrdyack: assert property(@ (posedge clk) ($rose(req) ##1 rdy) |-> ##1 ack);
  ap_reqrdyack_bad: assert property(@ (posedge clk) (req ##1 rdy) |->  ##1 ack);
  XXap_reqrdyack_bad: assert property(@ (posedge clk) (req ##1 rdy) |->  1 ##1 ack);
  XXXap_reqrdyack_bad: assert property(@ (posedge clk) (req ##1 rdy) |->  @ (posedge clk) @ (posedge clk) ack);

  always  @(posedge clk)  begin // emulate the task to evaluate the property 
    fork 
        t_req_rdy_ack ();  // Evaluate the property concurrently
    join_none
end
task automatic t_req_rdy_ack(); // the property 
    bit match, pass; // results: 
    // The manager launching threads (other automatic tasks) and processing results 
    fork t_req_rdy(match);  join
    if(match) begin //  antecedent thread matches
        fork 
          t_ack(pass); // continue to the evaluation of the ack
        join
        am_reqrdyack:  assert(pass) $display("%t req rdy ack assertion is PASS", $realtime); 
                      else $display("%t req rdy ack assertion is FAIL", $realtime); 
    end
    else  $display("%t req rdy ack assertion is vacuous", $realtime);  
endtask 

task automatic  t_req_rdy (inout bit match);
    // ($rose(req) ##1 rdy) 
    if($rose(req))  @(posedge clk) if(rdy) match=1;  else match=0;
endtask 

task automatic t_ack (inout bit pass); // ack after 1 cycle
   @(posedge clk) if(ack) pass=1; else pass=0;    
endtask  

  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    static bit[2:0] test[0:9] =
    // rea rdy ack
      {0, 3'b100, 3'b110, 3'b011, 0, 
       0, 3'b100, 3'b010, 3'b001, 0};
    bit v_a, v_b, v_c;
    for (int i=0; i<11; i++) begin
        @(posedge clk)  {req, rdy, ack} <= test[i];     
    end
    repeat (20) begin
      @(posedge clk);
      if (!randomize(v_a, v_b, v_c) with {
        v_a   dist {1'b1 := 1, 1'b0 := 1};
        v_b   dist {1'b1 := 1, 1'b0 := 1};
        v_c   dist {1'b1 := 1, 1'b0 := 1};
      }) `uvm_error("MYERR", "This is a randomize error");
      req <= v_a; rdy<=v_b; ack<=v_c; 
    end
    $finish;
  end
endmodule