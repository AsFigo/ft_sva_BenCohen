
module top;  
    timeunit 1ns;  timeprecision 100ps;    
   `include "uvm_macros.svh"   import uvm_pkg::*;
     bit clk_osc, clk_rtl, clk_tb;
     bit a1, b1, c1;
     bit a_tb, b_tb, A, r_rtl, B, C, k, m; 
     int count=10; 
     initial forever #10 clk_osc = !clk_osc; 
     always @(clk_osc) #2ns clk_rtl=clk_osc; 
     always @(clk_osc) #2ns clk_tb=clk_osc; 
     // SIgnal drivers 
     always @(posedge clk_osc) begin
        repeat(2) begin
          a1 <= 0; b1 <= 0; c1 <= 0; 
          @(posedge clk_osc) a1 <= 1; b1 <= 0; c1 <= 0;
        end    
        repeat(50) begin 
            @(posedge clk_osc) if (!randomize(a1, b1, c1)) 
                      `uvm_error("MYERR", "This is a randomize error"); 
        end
     end
    
    always_ff @(posedge clk_tb) begin 
         a_tb <= a1;  
         b_tb <= b1; 
         /* am_abrtl_OK: assert(a_rtl & !b_tb)  $display("%t line 15 am_abrtl_OK PASS a=%b b=%b", $realtime, a_rtl, b_tb);    
        // else  $display("%t line 16 am_abrtl_OK FAIL a=%b b=%b", $realtime, a_rtl, b_tb);   
         am_abrtlP0_OK: assert #0 (a_rtl & !b_tb)  $display("%t #0 line 15 am_abrtl_OK PASS a=%b b=%b", $realtime, a_rtl, b_tb);    
         else  $display("%t #0 line 16 am_abrtl_OK FAIL a=%b b=%b", $realtime, a_rtl, b_tb);   
         am_abrtlFNL_OK: assert final(a_rtl & !b_tb)  $display("%t final line 15 am_abrtl_OK PASS a=%b b=%b", $realtime, a_rtl, b_tb);    
         else  $display("%t final line 16 am_abrtl_OK FAIL a=%b b=%b", $realtime, a_rtl, b_tb);   */
         // sensitive to @(posedge clk) 
      end
      always_comb A=a_tb ^ b_tb; 
      always_comb am_A_p0: assert #0(a_tb ^ b_tb)  $display("%t #0 line 31 A PASS A=%b a_tb=%b b_tb=%b", $realtime, A, a_tb, b_tb);         
      else  $display("%t #0 line 32 A FAIL A=%b a_tb=%b b_tb=%b", $realtime, A, a_tb, b_tb);      
      always_comb am_A_f0: assert  (a_tb ^ b_tb)  $display("%t  line 33 A PASS A=%b a_tb=%b b_tb=%b", $realtime, A, a_tb, b_tb);         
      else  $display("%t  line 33 A FAIL A=%b a_tb=%b b_tb=%b", $realtime, A, a_tb, b_tb);      

      always_ff @(posedge clk_rtl) begin
          r_rtl <= c1;
      end

      always_comb  begin 
        B=A ^ r_rtl; 
        C=B ^ b_tb; 
      end
      am_B_p0: assert #0(A ^ r_rtl)  $display("%t #0 line 44 B PASS B=%b A=%b r_rtl=%b", $realtime, B, A, r_rtl);         
      else  $display("%t #0 line 45 B FAIL B=%b A=%b r_rtl=%b", $realtime, B, A, r_rtl);  
      always_comb am_B: assert (A ^ r_rtl)  $display("%t  line 44 B PASS B=%b A=%b r_rtl=%b", $realtime, B, A, r_rtl);         
      else  $display("%t  line 45 B FAIL B=%b A=%b r_rtl=%b", $realtime, B, A, r_rtl);  

      am_C_p0: assert #0(B ^ b_tb)  $display("%t #0 line 49 C PASS C=%b B=%b b_tb=%b", $realtime, C, B, b_tb);         
      else  $display("%t #0 line 50 C FAIL C=%b B=%b b_tb=%b", $realtime, C, B, b_tb); 
      always_comb am_C_fn: assert  (B ^ b_tb)  $display("%t  line 51 C PASS C=%b B=%b b_tb=%b", $realtime, C, B, b_tb);         
      else  $display("%t  line 52 C FAIL C=%b B=%b b_tb=%b", $realtime, C, B, b_tb);  

 
      initial begin 
       repeat (30) begin
         @(posedge clk_rtl);
       end
       $finish;
     end

     always_ff @(posedge clk_rtl) begin         
        automatic int v=count;
        for (int i = 0; i < 5; i++) begin 
            v=v+1; 
            am_v: assert #0(v <13) $display("%t PASS v=%d", $realtime, v); 
                     else $display("%t Error v=%d", $realtime, v);
        end
     end
       
   endmodule 
  