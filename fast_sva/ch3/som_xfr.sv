module som_xfr;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, som, xfr, eom, done; // start of msg, transfer, end of msg, done 
  initial forever #10 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end
  let LENGTH=10;
  // Used the goto and nonconsecute repetition Operators for demonstration 
  ap_som_xfr_done: assert property(@ (posedge clk)  
      $rose(som) ##1 (xfr[->2]  ##1 xfr[=1] ##1 eom  intersect 1[*1:LENGTH]) |-> ##1 done); 

// Could have been written just with the [=
      ap_som_xfr_done2: assert property(@ (posedge clk)  
      $rose(som) ##1 (xfr[=3] ##1 eom  intersect 1[*1:LENGTH]) |-> ##1 done); 
let SIZE=4;
  // TEST
      ap_som_xfr_done_0fm: assert property(@ (posedge clk)  $rose(som) ##1
      ((xfr[*0:$] ##1 eom[->1]) intersect 1[*1:SIZE]) |-> ##1 done);

      ap_som_xfr_done_0fm2: assert property(@ (posedge clk)  $rose(som) |-> ##1
        ((xfr[*0:$] ##1 eom[->1]) intersect 1[*1:SIZE])  ##1 done);



  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    bit v_a, v_b, v_c;
    static bit[3:0] field[0:24]=
      // som, xfr, eom, done
      {4'b0000, 4'b1000, 4'b0000, 4'b0100,  //4
       4'b0000, 4'b0100, 4'b0000, 4'b0100,  //4
       4'b0010, 4'b0001,  4'b0000,  4'b0000,  4'b0000, 4'b1000, // 6
       4'b0100, 4'b0010,  4'b0100,  4'b0100,  4'b0100, 4'b0100, 4'b0100, 4'b0100, 4'b0100, 4'b0010, 4'b0001  //11
     };
     /* {4'b0000, 4'b1000, 4'b0100, 4'b0001,  //4
       4'b0000, 4'b1000, 4'b0010, 4'b0001,  //4
       4'b1000, 4'b0100,  4'b0100,  4'b0100,  4'b0010, 4'b0001, // 6
       4'b1000, 4'b0100,  4'b0100,  4'b0100,  4'b0100, 4'b0100, 4'b0100, 4'b0100, 4'b0100, 4'b0010, 4'b0001  //11
     }; */
     for (int i = 0; i<21;i++ ) begin
        @(posedge clk) {som, xfr, eom, done} <= field[i];
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