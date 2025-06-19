module endpoint;
   bit a=1, b=1, c, clk, clk1, rst_n, reset_n, myrst_n;
   logic k;
   int data;
   event e; 
   function automatic void set_e();
     -> e;     
   endfunction
   initial forever #10 clk = !clk;
   sequence s_ab; @(posedge clk) a ##1 b; endsequence  
   ap_c: assert property(@ (posedge clk) (s_ab.triggered, set_e()) |-> 1 );  
   am_c: assert #0 (c); 
   am_cd: assert final (c); 
always_ff @(posedge clk ) begin
   am1:  assert  (c);
  if(c) disable am_c; 
  if(c) disable am_cd;
  if(c) disable am1; 

end

  am: assert #0 (k==1);
  assign #0  k=0;  

  default clocking cb_clk @ (posedge clk);
endclocking
default disable iff ($fell(reset_n, @(posedge clk))); // (rst_n); 

property pXY(x,y, reset); // active hi reset
int v;
 disable iff (reset)
  @(posedge clk) (x, v=0) |=> y && v==data;
endproperty : pXY
ap2: assert property(@ (posedge clk1)  disable iff(myrst_n) a|-> b); // (pXY(a,b, myrst_n)) );  
//ndpoint.sv(19): Illegal disable in the expression. Only top level disable is allowed in System Verilog

p2a: assert property(@ (posedge clk1)  disable iff(myrst_n) a|-> b);

p2b: assert property(@ (posedge clk1)  (pXY(a,b, myrst_n)) ); 



   initial begin 
     @(posedge clk) {a, b} <= 2'b00;
     @(posedge clk) {a, b} <= 2'b10;
     @(posedge clk) {a, b} <= 2'b01;
     @(posedge clk) {a, b} <= 2'b00;
     @(posedge clk) {a, b} <= 2'b11;
     @(posedge clk) {a, b} <= 2'b11;
     @(posedge clk) {a, b} <= 2'b00;
     @(posedge clk) {a, b} <= 2'b00;
     $finish;
   end 
endmodule

