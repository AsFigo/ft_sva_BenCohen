module  top2;
  bit  clk, en=1, en1=1, clk_tb;
  int err, err1;
  always #3 clk_tb=!clk_tb; 
  always clk = #1 clk_tb && en1;
  always en1 = #40 en;
    // When the en signal is pulled low, the clk can still jump normally for
    // a maximum of 3 times, and then it must be turned off, 
    // that is, it should remain unchanged.
    task automatic t_clk_en0();
       int count; 
       fork
          #30; // 5 clks
         forever @(posedge clk) if(!en) count=count+1;
       join_any
      am_3clk_after_en: assert(count < 3) else err=err+1;
    endtask
    // fire the task 
    // cover property(@(posedge clk_tb) !en |-> (1, t_clk_en0()));
    always @(!en) t_clk_en0(); 

    // Using the tb clock 
    property p_noclk_en; // adjust the max count allowed 
      int count=0; 
      @(posedge clk_tb) $fell(en) |-> ##1 @(posedge clk_tb) 1 ##1 @(clk_tb)
         (1, count=count+clk)[*1:$]  intersect  $rose(en)[->1]) ##0 count<8 ;
    endproperty
    ap_noclk_en: assert property(p_noclk_en) else err1=err1+1; 

    initial begin 
      $dumpfile("dump.vcd"); $dumpvars;
      #40 en=0;
      #75 en=1; 
      #30 en=0;
      #50 en=0;
      #30; $finish();
    end
endmodule

