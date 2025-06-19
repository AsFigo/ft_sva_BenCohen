// Here is a workaround for dynamic delays to be used for formal verification:
    module top; 
    import uvm_pkg::*; `include "uvm_macros.svh" 
    import sva_delay_repeat_range_pkg::*;
    timeunit 1ns;     timeprecision 100ps;  
    bit clk, a, b, c=1, w;  
    bit[1:0] v=2;  
       
    initial forever #10 clk=!clk;  
    
    // ******       DYNAMIC DELAY ##v **********
    // Application:  $rose(a)  |-> q_dynamic_delay(v) ##0 my_sequence;
    ap_dyn_delay: assert property(@ (posedge clk) 
       $rose(a) |-> q_dynamic_delay(v) ##0 b);  
    
    ap_fix_delay2: assert property(@ (posedge clk)   
       $rose(a) |-> ##2 b); 

    // For formal verification
    generate for (genvar i=0; i<=3; i++)
        begin 
            ap_fvi: assert property(@ (posedge clk) 
               v==i && $rose(a) |-> ##i b);  
        end
    endgenerate