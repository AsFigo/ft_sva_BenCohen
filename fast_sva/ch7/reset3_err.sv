module reset3_err;
	bit clk, clk1, req=1, ack=1, reset, rst;   int data;
    default disable iff (rst);
    initial forever #5 clk=!clk; 
    initial forever #3 clk1=!clk1; 

    ap_clk_clk1: assert property (@(posedge clk) @(posedge clk1) 
          req |=> ack); 
  
  ap_clk_0clk1: assert property (@(posedge clk) ##0  @(posedge clk1)  req |=> ack); 



    property pXY(x,y, reset);  // active hi reset 
      int v;       
       // disable iff (reset)  
        // Illegal disable in the expression. Only top leve  l disable is allowed in System Verilog
        // property applied in line 18, ap_XY_sampled
      @ (posedge clk1)
        (x, v=0) |=> y && v==data;
    endproperty : pXY
	
	apP1: assert property ( 
        disable iff  ($rose(reset, @(posedge clk)))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk) 
	apP2: assert property ( 
        disable iff  ( $sampled(reset))
          @ (posedge clk) req |=> ack); // disable sampled at @ (posedge clk) 
    //apXY_sampled: assert property (@(posedge clk) disable iff (rst)
     //           pXY(req, ack, $sampled(reset)));
    apXY_sampled: assert property (@(posedge clk) disable iff (rst)
                pXY(req, ack, $sampled(reset)));
  initial begin 
    repeat(20) @(posedge clk);
    $stop;
  end
   
endmodule 
	