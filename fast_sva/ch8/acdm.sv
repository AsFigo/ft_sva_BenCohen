module mx; 
 bit a, b, c, clk; 
 /* Signal “a” and “b” are independent. means no clock requited async signals
On the posedge of signal “a” then wait for negedge of signal “b” .
Once signal “b” goes low, check if it stays low for 5 cycles if not then check for subsequent negedge for signal b for this requirement.
When signal “b” stays low for more than 5 cycles, after the at posedge of signal “b”, check that signal “c” stays low for 2 clock cycles
*/

ap: assert property(@(posedge a) 1 // posedge of signal “a” then 
             ##0 @(negedge b) ##0 //  wait for negedge of signal “b” .
              @(posedge clk) !b[*6]  |->  // check if it stays low for 5 cycles
              // if not then check for subsequent negedge for signal b for this requirement.
              /*/ The looping if !b[*5] is
                  ##0 @(negedge b) ##0  @(posedge clk) !b[*5]   
                If !b[*6] fails, then the assertion is vacuous */
                   @(posedge b) 1  ##1 @(posedge clk) !c[*2]);
// Only the requirement on c should be in the consequent. The antecedent will trigger 
// on any !b lasting for >= 6 cycles . maybe even @(posedge b) could be in the antecedent.


ap: assert property( @(posedge a) 1|->  (1, t_abcd())); 
  //  first_match( (@(negedge b) ##0 @(posedge clk) !b[*5]) [*1:$]) ##0 @(posedge b)  ##1 @(posedge clk) !c[*2]); 



    
    task automatic t_abcd(); //
       int count; 
       bit is_matched, go; 
       @(negedge b) 
        fork 
          begin  : p1  // (@(negedge b) ##0 @(posedge clk) !b[*5]) [*1:20]                      
            repeat(20)begin 
              count =0;   
              repeat(5) @(negedge clk) if(!b)  count++;  
              if(count == 5) go=1; 
              disable p1; 
            end 
            am_no5b0: assert(0) else $display("assertion_debug NO count==5"); 
            disable p2; 
           end

           begin : p2
              wait(go);  // ##0 @(posedge b)  ##1 @(posedge clk) !c[*2]); 
                  @(posedge b);
                  repeat(2) begin 
                     @(negedge clk);
                     assert (!c)
                       $info("assertion_debug  PASSED");
                     else 
                       $error("assertion_debug FAILED");
                  end 
            end 
        join
    endtask

endmodule 




/* assertion where signal “a” and “b” are completely independent signals and when posedge of signal “a”
 is there then wait for signal “b” to go low irrespective of clock and any other signal once it goes low
 wait for 5 cycles to check if it stays low for that cycles if not then try again when signal “b” goes low 
eventually when signal b stays low more then 5 cycles then after the posedge of signal “b”
 check that signal “c” stays low for 2 clock cycles. I am not sure that below code will work
    */
/*  Requirements Breakdown
Signal "a" and "b" are independent.

On the posedge of signal "a", wait for signal "b" to go low.  
Once signal "b" goes low, check if it stays low for 5 cycles.
 $rose(a)|->  (##1 !b[->1]  ##1 !b[*5])[*1:$] ##1 c[*2]; 

If signal "b" does not stay low for 5 cycles, retry when signal "b" goes low again.

When signal "b" stays low for more than 5 cycles, after the posedge of signal "b", check that signal "c" stays low for 2 clock cycles. */
$rose(a)|->  first_match(##1 !b[->1]  ##1 !b[*5][*1:$]) ##1 c[*2]; 

 property check_signals;
  @(posedge a) // Trigger on posedge of signal 'a'
    disable iff (reset) // Disable assertion during reset
    b == 0 ##[0:$] // Wait until 'b' goes low
    ##5 (b == 0) |-> // Check if 'b' stays low for 5 cycles
    @(posedge b) // After posedge of 'b'
    c == 0 ##2 (c == 0); // Check if 'c' stays low for 2 cycles
endproperty

assert property (check_signals);

