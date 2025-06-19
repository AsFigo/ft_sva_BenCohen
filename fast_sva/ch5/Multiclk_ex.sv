
// The request module
module mreq(input bit clk0, request0r,  ack1r,
            output bit  req0r, ack0r);
// request, req0r, ack0r are synced to clk0
// ack1r is synced to clk1
// Generating req0r 
bit ack0ar, ack0br; // reclocking stages of ack1r 
  always_ff @(posedge clk0) begin 
    if(request0r && !req0r) req0r <=  1; // !ack0r;
    if (ack0r) req0r<=0;   // hold req0r until ack0r 
  end
// BAD STYLE ap_req0r_hold: assert property(@ (posedge clk0) $rose(req0r) |->
//      req0r until_with ack0r);  
  ap_req0r_hold2: assert property(@ (posedge clk0) $rose(req0r) |-> 
      req0r[*1:$] intersect ack0r[->1]); 

// Generating ack0r 
  always @(posedge clk0) begin 
    ack0ar <= ack1r;  // recloking, 1st stage 
    ack0br <= ack0ar; // recloking, 2nd stage 
    ack0r <= ack0ar && ack0br; // ack0r is true when reclocking has 2 sequential recloks of ack1r
  end
  // Check that the reclocked ack0r with clk0 is same as what was sent withclk1
  ap_akc0r: assert property(@ (posedge top.clk1)  $rose(ack1r) |=> 
         @(posedge clk0) ##[2:3] ack0r);    
endmodule 

// The ack module
module mack(input bit clk1, req0r, rdy1r, 
           output bit ack1r);
  bit req1ar, req1br, req1r;
  always @(posedge clk1) begin
    req1ar <= req0r;   // 1st statge reclocking 
    req1br <= req1ar; // 2nd stage reclocking 
    if(req1ar && req1br)
      req1r <= 1'b1;
    if(ack1r) //  && !req0r)
      req1r <= 1'b0;
      ack1r <= req1r && rdy1r;
    end
   ap_req0r: assert property(@ (posedge top.clk0)  $rose(req0r) |=>
       @(posedge clk1) ##[2:3] req1r);
   ap_req1r_hold: assert property(@ (posedge clk1) $rose(req1r) |-> 
      req1r[*1:$]  intersect ack1r[->1]);  

   // Assume if new request then ready to arrive in 5 clk1 cycles, 
   //   and wil hold until ack1r 
   am_ready: assume property(@ (posedge clk1) $rose(req1r) |-> 
         ##[1:5] rdy1r  ##0  (rdy1r[*1:$] intersect ack1r[->1]));  
endmodule

module top;
  bit clk0=1, clk1, request0r, req0r, rdy1r, ack1r, ack0r; // clk0=1
  bit DotMatched;
  initial forever #1 clk0 = !clk0;
  initial forever #3 clk1 = !clk1; //#2 
  mreq mreq0(.*);  // module instance 
  mack mack1(.*);
  // with clk1, if there is a new request, then in 11 clk1 an acknowledge
  ap_req_to_ack0r: assert property(@(posedge clk0) $rose(mreq0.req0r) |->  
     @(posedge clk1) $rose(mack1.req1r)[->1] ##[1:11] mack1.ack1r ##0 
     @(posedge clk0)  ##[1:2] mreq0.ack0r); 

  sequence qack1b; @(posedge clk1) $rose(mack1.req1r)[->1] ##[1:11] mack1.ack1r; endsequence
  ap_req_to_ack0r2: assert property(@(posedge clk0) $rose(mreq0.req0r) |->            
                qack1b ##0 @(posedge clk0) ##[1:2] mreq0.ack0r);

  initial begin
  // $dumpfile("dump.vcd"); $dumpvars;
  // therequests
  repeat(2) @(posedge clk0);
  request0r <= 1; @(posedge clk0); request0r <= 0; // new request 
  repeat(4) @(posedge clk1); rdy1r <= 1'b1; 
  repeat(20) @(posedge clk1);
  $finish;
  end
endmodule 



