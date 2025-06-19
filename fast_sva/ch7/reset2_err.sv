module reset2_err;
	bit clk, req, ack, reset, rst;   int data;
    // default disable iff (rst);
    property pXY(x,y, reset);  // active hi reset 
      int v;       
       disable iff (reset)  
        // Illegal disable in the expression. Only top level disable is allowed in System Verilog
        // property applied in line 18, ap_XY_sampled
        (x, v=0) |=> y && v==data;
    endproperty : pXY
	
	apP1: assert property ( 
        disable iff  ($rose(reset, @(posedge clk)))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk) 
	apP2: assert property ( 
        disable iff  ( $sampled(reset))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk2) 
    apXY_sampled: assert property (@(posedge clk) disable iff (rst)
                pXY(req, ack, $sampled(reset)));
   
endmodule 
	