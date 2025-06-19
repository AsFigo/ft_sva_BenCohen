/*ap_reqrdyack: assert property(@ (posedge clk) req ##[1:2] rdy |->  ##[1:2] ack);
ap_req_in2_rdy_ack: assert property(   // Preferred style for determinism                                                                 
     @(posedge clk) $rose(req) ##1 (rdy[->1] intersect 1[*1:2]) |->  ##[1:2] ack);   
ap_reqrdyack: assert property(@ (posedge clk) first_match(req ##[1:2] rdy) |->  ##[1:2] ack);
/* 
/* Consider the following set of requirements that express the property of an interface: 
1. Synchronous design with single clock (clk)
2. Signals: req, rdy, ack (one-bit each)
3. After req rises, rdy appears in 1-2 cycles
4. After rdy, ack must be 1 in 1-2 cycles
5. Assertion is vacuous if:
   - No new req occurs
   - rdy doesn't follow req within 2 cycles


ap_req_ack: assert property(@ (posedge clk)  $rose(req) |->   ##1 req[*2] ##1 ack[*2]);
ap_req_ack: assert property(@ (posedge clk)  $rose(req) |->  // in the same cycle 
         req && !ack[*3]  // req==1 and ack==0 for 3 cycles, including the current cycle     
    ##1          ack[*2]  // at the next cycle, req==1 for 2 cycles, don’t care about req
    ##1 !req && !ack);    // at the next cycle, req==0 and ack==0 for 1 cycles
ap_req_ack_range: assert property(@ (posedge clk)  $rose(req) |->  // in the same cycle 
        req[*1:3] // req==1 for 1 to 3 cycles  
        ##1 $rose(ack)  // until it is followed by a rise of ack, ack was 0    
        ##1 ack[*1:2]   // ack holds for a max of 2 cycles 
        ##0 $fell(req)  // until req==0    
        ##1 !req && !ack);    // at the next cycle, req==0 and ack==0 for 1 cycles

ap_req_ack_range: assert property(@ (posedge clk)  $rose(req) |->   req[*1:3]
assert property(@(posedge clk) start |-> (!data[*0:$] ##1 valid) );
ap_som2xfr2done: assert property( @(posedge clk) $rose(som) |->
                                ##1 (xfr[*0:SIZE] ##1 eom ##1 done));  
  $rose(som) ##1 ((xfr[*0:$] ##1 eom) intersect 1[*1:SIZE]) |-> ##1 done);
ap_som_xfr_done: assert property(@ (posedge clk)  $rose(som) ##1
     first_match((xfr[*0:$] ##1 eom) intersect 1[*1:SIZE]) |-> ##1 done);
ap_som_xfr_done_0fm: assert property(@ (posedge clk)  $rose(som) ##1
        ((xfr[*0:$] ##1 eom[->1]) intersect 1[*1:SIZE]) |-> ##1 done);
 */ 
 Paper: Understanding SVA Degeneracy
A MUST READ PAPER FOR SVA USERS!
https://systemverilog.us/vf/Degeneracy111723Ben.pdf