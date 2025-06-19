module my_control (input bit clk, a, b);
	// Assertion controls
    let LOCK 	= 1;  // assertion control type
    let UNLOCK 	= 2; 	// assertion control type
    let ON 	= 3;	// assertion control type
    let OFF 	= 4;	// assertion control type
    let KILL 	= 5;	// assertion control type
    let PASSON 	= 6; 	// assertion control type
    let PASSOFF 	= 7; 	// assertion control type
    let FAILON 	= 8; 	// assertion control type
    let FAILOFF 	= 9;	// assertion control type 
    let NONVACUOUSON = 10;	// assertion control type 
    let VACUOUSOFF 	= 11; // assertion control type 

             
  initial begin : disable_assertions_during_reset
    $display ("%0t %m Disabling assertions during init..", $time);
    //$assertoff (0, top_tb.cpu_rtl_1);
    // $assertoff;
    $assertcontrol(OFF); // using default values of all other arguments  
    @ (top_tb.reset_n ==1'b1);
    $display ("%0t %m Enabling assertions after init..", $time);
    //$asserton (0, top_tb.cpu_rtl_1);
    //$asserton;
    $assertcontrol(ON);
   end
   always_comb  ap_0: assert property (@(posedge clk) a) else $display("fail, my control a==%b", $sampled(a)); 
endmodule : my_control

module cpu_rtl(input bit clk, a, b); 
	 ap_0rtl: assert property (@(posedge clk) a) 
	 	$display("PASS RTL at t-%t, a==%b", $time, $sampled(a)); 
	    else $display("FAIL RTL at t-%t, a==%b", $time, $sampled(a)); 
endmodule 

module top_tb;
	bit clk=1'b0, reset_n=1'b0, a=1, b=0; 
  initial forever #5 clk=!clk; 
  //bus_if b_if; 
 cpu_rtl cpu_rtl_1(clk, a, b); // Instantiation of cpu module
 my_control my_control_1(clk, a, b); // instantiation of assertion control
  always  
     begin 
       repeat(3) @(posedge clk); 
       a <=1'b0;
       repeat(3) @(posedge clk); 
       reset_n<=1'b1; 
       repeat(3) @(posedge clk); 
       a <=1'b1;
       repeat(3) @(posedge clk); 
       a <=1'b0;
     end 
// .. */
endmodule : top_tb
