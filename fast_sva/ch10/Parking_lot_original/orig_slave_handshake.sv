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

module slave_handshake
  // #(parameter IDLE=2'b00, REQUEST=2'b01, ACQUISITION=2'b10, // State of slave
    
  (
   output logic req     ,             // bus request
   output logic start   ,             // start of data cycle 
   output logic valid   ,             // doing work
   output logic done    ,             // to arbiter
   input  ack     ,             // acknowledge
   input  reset_n ,             // reset active low
   input  clk     );
  timeunit 1ns;
  timeprecision 100ps;
   typedef enum {IDLE, REQUEST, ACQUISITION} hmode_t; // handshake modes 
   parameter ERROR=1;
   parameter FAIL=0;
   `define true 1 

  hmode_t state_r ;                // State reg
  logic [0:10] counter;            // count # valid cycles
 
  //**************************************************
  // Protocol Requirements
  // 1. slave issues a req, and holds request until ack
  // 2. Master to reply with 1 cycle ack within 3 cycles
  // 3. In response to ack, slave issues
  //    start for 1 cycle, used for sync purposes 
  //    valid for 4 cycles, used for data envelope 
  //    done  for 1 cycle, used for sync
  // 4. a reset or a cancel aborts any operation
  //**************************************************
  //            ASSERTIONS 
 
  //
  property p_req_ack_eventually;
    disable iff (!reset_n)  req && !ack |-> ## [0:$] ack;
  endproperty : p_req_ack_eventually

  always @(posedge clk) // always SystemVerilog block 
     ap_req_ack_eventually_1: assert property (p_req_ack_eventually);

  sequence qActive_request;(req && !ack); endsequence

  property p_req_ack_eventually_in_4_cycles;   
   @ (posedge clk) disable iff (!reset_n)  qActive_request |-> ##[0:3] ack;
  endproperty : p_req_ack_eventually_in_4_cycles
  ap_req_ack_eventually_in_4_cycles: assert property (p_req_ack_eventually_in_4_cycles);
  
  // req cannot be asserted in a cycle after the ack.  
  // In addition, there can only be one single acknowledge. 
  // There cannot be 2 sequential ack
     property p_no_req_after_ack;
       @ (posedge clk) disable iff (!reset_n) not (qActive_request ##1 ack ##1 (req || ack));
     endproperty : p_no_req_after_ack 
     ap_no_req_after_ack : assert property (p_no_req_after_ack);

   property p_ack_start_valid_done;
   @ (posedge clk) disable iff (!reset_n) 
        qActive_request ##1 ack |=>
           start && !ack && valid ##1 
          (!start && !ack && valid)[*3] ##1 
          !start && !valid && done;
  endproperty : p_ack_start_valid_done
  ap_ack_start_valid_done :assert property (p_ack_start_valid_done);

  sequence qValid; valid [*4]; endsequence : qValid
    // If in IDLE, then previous cycle must have been 
    //         either a reset or the end of a valid sequence.
    // If in REQUEST, then previous cycle must have been a request with state in IDLE.
    // If in ACQUISITION, then previous cycle must have been 
    //         either in REQUEST state and assertion of acknowledge
    //         or in ACQUISITION state and the end of the valid sequence was reached.
	//**** TEST OF CLOCKING
   property p_handshake;
      @ (posedge clk) disable iff (!reset_n) 
      if (state_r==IDLE) |-> $past(reset_n) || $past(qValid.ended);
      else if (state_r==REQUEST) |-> $past(req) && $past(state_r==IDLE);
      else if (state_r==ACQUISITION) |-> ($past(state_r==REQUEST) && $past(ack)) or 
                                          $past(state_r==ACQUISITION) && !$past(qValid.ended);
    endproperty : p_handshake
  endclocking 
  ap_handshake :  assert property (p_handshake);

				  

  
  // Request to acknowledge coverage, NO failure
   property p_req_ack_coverage;
      @ (posedge clk)  disable iff (!reset_n) 
     qActive_request ## [0:3] ##1 ack |-> `true;
   endproperty : p_req_ack_coverage
   cp_req_ack_coverage : cover property (p_req_ack_coverage);
  
  // Occurrence of a start and valid
   property p_start_valid_coverage;
    @ (posedge clk) disable iff (!reset_n)
        qActive_request |=>  ##[0:$] start ##1 valid;
   endproperty :  p_start_valid_coverage
	 cp_start_valid_coverage : cover property(p_start_valid_coverage);
  
  always @ (posedge clk, negedge reset_n) begin : ack_prc
    if (reset_n == 1'b0)  begin             // asynchronous reset (active low)
      state_r <= IDLE;
      counter <= 0;
      req   <= 1'b0;
      start <= 1'b0;
      valid <= 1'b0;
      done  <= 1'b0;
	end
    else   // rising clock edge
	  case (state_r) 
		IDLE: begin
          req   <= 1'b1;
          state_r <= REQUEST;
          done  <= 1'b0;
          counter <= 0;		  
		end
		REQUEST: begin
		  if (ack == 1'b1) begin 
            req   <= 1'b0;
            start <= 1'b1;
            valid <= 1'b1;
            state_r <= ACQUISITION;
		  end
		end
		ACQUISITION : begin 
		  counter <= (counter+1) % 4;
		  req   <= 1'b0;
		  start <= 1'b0;
		  valid <= 1'b1;
		  if (counter == (3 - ERROR)) begin 
            done  <= 1'b1;
            valid <= 1'b0;
            state_r <= IDLE;
		  end 
        end	  
	  endcase
  end // ack_prc
endmodule // slave_handshake












