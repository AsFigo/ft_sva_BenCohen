module eqdlyack_dly;
`include "uvm_macros.svh"   import uvm_pkg::*;
import sva_delay_repeat_range_pkg::*;
  bit clk, req, rdy, ack;
  bit[1:0] dly; 
  initial forever #10 clk = !clk;

  // ap_reqrdyack_ILLEGAL: assert property(@ (posedge clk) ($rose(req) ##dly rdy) |-> ##1 ack);
  // ERROR: Range must be bounded by constant expressions.
    //----------------------------------------------------------------
    // ******       DYNAMIC DELAY ##d1 **********
    // Implements     ##[d1] 
    // Application: sq_1 ##0 dynamic_delay(d1) ##0 sq_2;
 /*  sequence dynamic_delay(count);
  int v;
    (count<=0) or ((1, v=count) ##0 (v>0, v=v-1) [*0:$] ##1 v<=0);
  endsequence // dynamic_delay */

  ap_reqrdyack: assert property(@ (posedge clk) ($rose(req) ##0 dynamic_delay(dly) ##0 rdy) |-> ##1 ack);

  // For formal verification
  generate for (genvar i=0; i<=3; i++)
    begin 
        ap_fv_reqrdyack: assert property(@ (posedge clk) 
           dly==i && $rose(req) ##i rdy|-> ##1 ack);  
    end
endgenerate

// Creates at elaboration 
ap_fv_reqrdyack_0: assert property(@ (posedge clk) dly==0 && $rose(req) ##0 rdy|-> ##1 ack);  
ap_fv_reqrdyack_1: assert property(@ (posedge clk) dly==1 && $rose(req) ##1 rdy|-> ##1 ack);    
ap_fv_reqrdyack_2: assert property(@ (posedge clk) dly==2 && $rose(req) ##2 rdy|-> ##1 ack);    
ap_fv_reqrdyack_3: assert property(@ (posedge clk) dly==3 && $rose(req) ##3 rdy|-> ##1 ack);  



    

  
  /*ap_reqrdyack: assert property(@ (posedge clk) ($rose(req) ##1 rdy) |-> ##1 ack);
  ap_reqrdyack_bad: assert property(@ (posedge clk) (req ##1 rdy) |->  ##1 ack);
  XXap_reqrdyack_bad: assert property(@ (posedge clk) (req ##1 rdy) |->  1 ##1 ack);
  XXXap_reqrdyack_bad: assert property(@ (posedge clk) (req ##1 rdy) |->  @ (posedge clk) @ (posedge clk) ack); */

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