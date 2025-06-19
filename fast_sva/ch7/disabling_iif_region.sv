module top;  
  bit clk, a, b;
  bit[2:0] p0, f0; //  p1, f1, p2, f2;
  initial forever #3 clk = !clk;

  ap_0:  assert property(@(posedge clk) disable iff (b) 
                         a) p0++; else begin f0++; b=1; end 

    initial begin        
        $dumpfile("dump.vcd"); $dumpvars;
      a=1;
      repeat (2) begin
        @(posedge clk);   
        @(posedge clk); a <=0;  
        @(posedge clk); a<=1;
      end  
      $finish;
    end
    endmodule
