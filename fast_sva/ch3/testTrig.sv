 module m;
   bit a, b, c, clk;
   sequence s1; a ##1 b; endsequence  
   ap: assert property(@ (posedge clk) a |-> s1.triggered[->1]  intersect c[->1] );  
endmodule
