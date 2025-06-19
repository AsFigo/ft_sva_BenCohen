module dmaxfrdone;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, som, xfr, eom, done; // start of msg, transfer, end of msg, done 
  initial forever #10 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end
  let SIZE=4;
  sequence s_xfr2done;  @(posedge clk) xfr[*0:4] ##1 eom; endsequence  

  ap_som_xfr_done: assert property(@ (posedge clk)  $rose(som) ##1
                       ((xfr[*0:$] ##1 eom) intersect 1[*1:SIZE) |-> ##1 done;

    // ((xfr[*0:$] ##1 eom) intersect 1[*1:SIZE]) is eauivalent to 
    // (xfr[*0] ##1 eom) or (xfr[*1:$] ##1 eom)    // equivalent to 
    // (  1     ##0 eom) or (xfr[*1:$] ##1 eom)

  // same as ap_som_xfr_done using the declared sequence 
  ap_som_xfr_done2: assert property(@ (posedge clk)  $rose(som) ##1  
                       (s_xfr2done intersect 1[*1:SIZE]) |-> ##1 done;



  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    bit v_a, v_b, v_c;
    bit[3:0] field[0:20]= 
      // som, xfr, eom, done
      {4'b0000, 4'b1000, 4'b0100, 4'b0001,  //4
       4'b1000, 4'b0100,  4'b0100,  4'b0100,  4'b0010, 4'b0001, // 6
       4'b1000, 4'b0100,  4'b0100,  4'b0100,  4'b0100, 4'b0100, 4'b0100, 4'b0100, 4'b0100, 4'b0010, 4'b0001, //11
     };
     for (int i = 0; i<21;i++ ) begin
        @(posedge clk) ( som, xfr, eom, done) <= field[i];
     end
   /*
    repeat (10 begin
      @(posedge clk);
      if (!randomize(v_a, v_b, v_c) with {
        v_a   dist {1'b1 := 1, 1'b0 := 1};
        v_b   dist {1'b1 := 1, 1'b0 := 1};
        v_c   dist {1'b1 := 1, 1'b0 := 1};
      }) `uvm_error("MYERR", "This is a randomize error");
      som */
    //end
    $finish;
  end
endmodule