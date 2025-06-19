module reardyack;
import sva_delay_repeat_range_pkg::*;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, req, rdy, ack;
  bit[1:0] lo=0, hi=3;
  initial forever #10 clk = !clk;
  /* sequence dynamic_delay_lohi_sq(d1, d2, sq);
      int v1, vdiff;
        dynamic_delay(d1)##0 
        (sq or     
        (1, vdiff=d2-d1) ##0 (vdiff>0, vdiff=vdiff - 1)[*1:$] ##1 sq); 
    endsequence */ 
  ap_reqrdyack: assert property(@ (posedge clk) 
       req ##0 dynamic_delay_lohi_sq(lo, hi, rdy) |->  dynamic_delay_lohi_sq(lo, hi,ack));  

    generate
        genvar i, j;
        for (i = 0; i <= 3; i++) begin : outer_loop
            for (j = 0; j <= 3; j++) begin : inner_loop
                ap_reqrdyack: assert property(@ (posedge clk)
                    lo == i && req ##i rdy |-> ##j ack);
            end
        end
    endgenerate
        ap_reqrdyack00: assert property(@ (posedge clk) lo==0 && req ##0  rdy |->  ##0 ack);   
        ap_reqrdyack01: assert property(@ (posedge clk) lo==0 && req ##0  rdy |->  ##1 ack);     
        ap_reqrdyack02: assert property(@ (posedge clk) lo==0 && req ##0  rdy |->  ##2 ack);     
        ap_reqrdyack03: assert property(@ (posedge clk) lo==0 && req ##0  rdy |->  ##3 ack);    
        ap_reqrdyack10: assert property(@ (posedge clk) lo==1 && req ##0  rdy |->  ##0 ack);  
        ap_reqrdyack11: assert property(@ (posedge clk) lo==1 && req ##0  rdy |->  ##1 ack);    
        // ....   
        // .... 
        ap_reqrdyack23: assert property(@ (posedge clk) lo==2 && req ##0  rdy |->  ##3 ack);    
        // .... 
        // .... 
        // ... 
        ap_reqrdyack30: assert property(@ (posedge clk) lo==3 && req ##3  rdy |->  ##0 ack);   
        ap_reqrdyack31: assert property(@ (posedge clk) lo==3 && req ##3  rdy |->  ##1 ack);     
        ap_reqrdyack32: assert property(@ (posedge clk) lo==3 && req ##3  rdy |->  ##2 ack);     
        ap_reqrdyack33: assert property(@ (posedge clk) lo==3 && req ##3  rdy |->  ##3 ack);     


      

  
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
    bit v_a, v_b, v_c;
    repeat (1000) begin
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