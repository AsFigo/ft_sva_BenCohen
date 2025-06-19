module  switch;
  timeunit 1ns;  timeprecision 100ps;    
  bit  clk, clk_ref, clk_gated, en=1;
  int pass0, pass1, err0, err1, tbcount0, tbcount1; 
  always #50ps clk_ref=!clk_ref; 
  always @(posedge clk_ref) clk<=!clk; 
  
  always @(clk_ref) begin    // gated clk generation
    bit v_enb;
    case ({v_enb, en})
       2'b00: clk_gated=0; 
       2'b01:  begin 
           for (int i = 0; i<=7;i++ ) begin
            clk_gated=0; 
           end  // to clk after 8 clk_ref
           clk_gated=clk;
        end
       2'b10: begin // disable after 5
           for (int i = 0; i<=5;i++ ) begin
            clk_gated=clk; 
           end  // to clk after 8 clk_ref
           clk_gated=0;
        end
       2'b11: begin 
           v_enb=1; 
           clk_gated=clk;
       end
    endcase
  end 

    task automatic t_clk_en0();
       int count; 
       fork
        #5.1ns ; // 5 clks
         forever @(posedge clk_gated) if(!en) begin 
            count=count+1;
            tbcount0=count; // debbug
         end 
       join_any
      am_3clk_after_en: assert(count < 5) pass0++; else err0=err0+1;
    endtask
    // fire the task 
    // cover property(@(posedge clk_tb) !en |-> (1, t_clk_en0()));
    always @(negedge(en)) t_clk_en0(); 

    task automatic t_clk_en1();
       int count; 
       fork
        #5.1ns ; // 5 clks
         forever @(posedge clk_gated) if(en) begin 
            count=count+1;
            tbcount1=count; // debbug
         end 
       join_any
      am_5clk_after_en: assert(count < 8) pass1++; else err1=err1+1;
    endtask
    // fire the task 
    // cover property(@(posedge clk_tb) !en |-> (1, t_clk_en0()));
    always @(posedge(en)) t_clk_en1(); 

   // Using the tb clock 
    property p_noclk_en; // adjust the max count allowed 
      int count=0; 
      @(posedge clk_ref) $fell(en) |-> ##1  
         ((1, count=count+clk)[*1:$]  intersect  $rose(en)[->1]) ##0 count<8 ;
    endproperty
    ap_noclk_en: assert property(p_noclk_en) else err1=err1+1;  

    
    initial begin 
      $dumpfile("dump.vcd"); $dumpvars;
      repeat(5) @(posedge clk_ref);
      en <=0;
      repeat(10) @(posedge clk_ref);
      en <= 1; 
      repeat(20) @(posedge clk_ref);
      #30; $finish();
    end
endmodule

