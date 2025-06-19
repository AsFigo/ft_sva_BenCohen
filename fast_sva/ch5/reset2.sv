module reset_n2;
	bit clk, req, ack, reset_n;   int data;
    property pXY(x,y, reset_n);  // active hi reset_n 
      int v;       
       disable iff (reset_n)  
        (x, v=0) |=> y && v==data;
    endproperty : pXY
	
	apP1: assert property ( 
        disable iff  ($rose(!reset_n, @(posedge clk)))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk) 
	apP2: assert property ( 
        disable iff  ( $sampled(!reset_n))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk2) 
    apXY_sampled: assert property (@(posedge clk) 
                pXY(req, ack, $sampled(!reset_n)));
endmodule 
	