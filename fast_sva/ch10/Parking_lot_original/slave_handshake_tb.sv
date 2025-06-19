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
module slave_handshake_tb;
  timeunit 1ns;
  timeprecision 100ps;

  logic [0:10] counter;            // count # valid cycles
   logic req;               // bus request
   logic start;             // start of data cycle
   logic valid;             // doing work
   logic done;              // to arbiter
  logic ack       = 1'b0;  // acknowledge
  logic reset_n   = 1'b0;  // reset active low 
  logic clk       = 1'b1;
  logic [1:0]   ack_count;          // delay count for asserting the ack 

  initial begin // reset 
	 reset_n = 1'b0;
    ##1  reset_n = 1'b1;
    ##20 reset_n = 1'b0;
    ##50 reset_n = 1'b1;
  end
  default clocking @ ( posedge clk ); endclocking
  initial begin // clock 
	clk = 1'b1;
	forever #30 clk = ~clk;
  end


  always @ (posedge clk) 
    begin    // process GiveGrant_Proc
       @ (posedge clk);
       ack_count <= (ack_count + 1) % 4;
       if (reset_n == 1'b0) 
	 ack <= 1'b0;  // asynchronous reset (active low)
       else 
	 begin
	    if (req == 1'b1 &&  ack == 1'b0) 
	      begin // else if 
		 for (int i = 0; i <= ack_count; i++) @ (posedge clk);  // idle cycles
		 if (ack_count == 2) 
		   begin 
		      ack <= 1'b1;                     // 2 ack 
		      @ (posedge clk);           // idle cycles
		   end
		 else
		   begin
		      ack <= 1'b1;
		   end
	      end // if (req == 1'b1 &&  ack == 1'b0)
	    else
	      ack <= 1'b0;
	 end // else: !if(reset_n == 1'b0)
    end // always @ (posedge clk)
   
   slave_handshake slave_handshake (.*);
endmodule // slave_handshake_tb




