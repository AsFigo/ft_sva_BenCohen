module reset2;
	bit clk, req, ack, reset;   int data;
    property pXY(x,y, reset);  // active hi reset 
      int v;       
       disable iff (reset)  
        (x, v=0) |=> y && v==data;
    endproperty : pXY
	
	apP1: assert property ( 
        disable iff  ($rose(reset, @(posedge clk)))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk) 
	apP2: assert property ( 
        disable iff  ( $sampled(reset))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk2) 
    apXY_sampled: assert property (@(posedge clk) 
                pXY(req, ack, $sampled(reset)));
endmodule 
	