module  top2;
  bit  clk_gated, clk_ref, en=1, en1=1;
  int pass, pass2, err, err2, tbcount;
  always #1 clk_ref=!clk_ref; 
  always_comb clk_gated = clk_ref && en1;
  always en1 = #4 en;
    // When the en signal is pulled low, the clk_gated can still jump normally for
    // a maximum of 3 times, and then it must be turned off, 
    // that is, it should remain unchanged.
    task automatic t_clk_en0();
       int count; 
       fork
        #10; // 5 clk_gateds, modify as needed
         forever @(posedge clk_gated) if(!en) begin 
            count=count+1;
            tbcount=count; // debbug
         end 
       join_any
      am_3clk_after_en: assert(count <= 3) pass2++; else err2=err2+1;
    endtask
    // fire the task 
    // cover property(@(posedge clk_ref) !en |-> (1, t_clk_en0()));
    always @(negedge(en)) t_clk_en0(); 

    // Using the tb clock 
    property p_noclk_en; // adjust the max count allowed 
      int count=0; 
      @(posedge clk_ref) $fell(en) |-> ##1 
         ((1, count=count+clk_gated)[*1:$]  intersect  $rose(en)[->1]) ##0 count<=3 ;
    endproperty
    ap_noclk_en: assert property(p_noclk_en) pass++; else err=err+1; 

    
    initial begin 
      $dumpfile("dump.vcd"); $dumpvars;      
      en1=1;en=1;
      repeat(5) @(posedge clk_ref);
      en<=0;
      repeat(15) @(posedge clk_ref);
      en<=1;  
      repeat(15) @(posedge clk_ref);
      #30; $finish();
    end
endmodule

