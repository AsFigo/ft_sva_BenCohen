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
// Also legal: 
// checker k_m(logic req, ack,  rst1,rst2, clk1, clk2);
module m(logic req, ack,  rst1,rst2, clk1, clk2);
  timeunit 1ns;
  timeprecision 1ns;

  logic rst, reset2; 
	default clocking @(posedge clk1); endclocking
	default disable iff rst;
	property pReqAck(request, acknowledge,  
		reset = $inferred_disable, clk = $inferred_clock);

		@clk disable iff (reset)
		request |=> acknowledge;
	endproperty : pReqAck



	apReqAck1: assert property (pReqAck(req, ack ));   //  Equivalent to
	// apReqAck1: assert property (@(posedge clk1) disable iff (rst)  req |=> ack); 



apReqAck2: assert property (pReqAck(req, ack, rst2));  //  Equivalent to
	// apReqAck1: assert property (@(posedge clk1) disable iff (rst2)   req |=> ack); 




	apReqAck3: assert property (pReqAck(req, ack ,, negedge clk2));  //  Equivalent to
	// apReqAck1: assert property (@(negedge clk2) disable iff (rst)  req |=> ack); 

    // ILLEGAL use of $inferred_clock and $inferred_disable 
      property pERROR(request, acknowledge,  reset, clk);
		@($inferred_clock)                        //     not allowed here                
                             disable iff ($inferred_disable)      //     not allowed here                
		@ (posedge clk2) req  |=> @($inferred_clock) acknowledge;   //  
	endproperty : pERROR
	// line 50 Incorrect usage of '$inferred_clock'. It is valid only as default argument for a property, sequence or a checker.
	
   
            apReqAck3_ERR: assert property (pReqAck(req, ack ,, $inferred_clock));   //   
           // default clocking @(negedge clk1); endclocking   //  
           // default clocking cannot be specified multiple times.
           // default disable iff reset2;  //   cannot be specified multiple times
endmodule 
 // endchecker : k_m 
