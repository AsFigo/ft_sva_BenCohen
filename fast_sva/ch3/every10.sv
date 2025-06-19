module m;
  bit clk, enb, a;
  bit[2:0] p0, f0, p1, f1; //  p2, f2;
  initial forever #3 clk = !clk;

 // Need to handle border cases on "a" after the fist rise of enb.
  // if new enb then ##1 a then no a 9 more times 
 ap_a9enb: assert property(@ (posedge clk)  $rose(enb) |-> ##1 a ##1 !a[*9]); 
 
 // if stable enb && a then a==0 9 more times  
  ap_a9: assert property(@ (posedge clk) $stable( enb) && a |-> ##1 !a[*9]);
 
 // never a==0 occurring 10 times in a row
  ap_no10a: assert property(@ (posedge clk)   enb |-> not(!a[*10]));


  initial begin 
    @(posedge clk) enb <= 1; 
      repeat(3) begin 
        @(posedge clk) a<=1; 
         repeat(9)  @(posedge clk) a<=0; 
      end
  end
endmodule
