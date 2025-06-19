module dmaxfrdone;
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, som, xfr, eom, done; // start of msg, transfer, end of msg, done 
  initial forever #10 clk = !clk;
  let SIZE=4;

  ap_som2xfr2done: assert property( @(posedge clk)
    $rose(som) |-> ##1 (xfr[*0:SIZE] ##1 eom ##1 done));


  ap_som_xfr_done: assert property(@ (posedge clk)  $rose(som) ##1
     first_match((xfr[*0:$] ##1 eom) intersect 1[*1:SIZE]) |-> ##1 done);

// with delay in eo e.g. xfr xfr ..xfr !eom eom done
  ap_som_xfr_done_delayed_eom: assert property(@ (posedge clk)  $rose(som) ##1
        ((xfr[*0:$] ##1 eom[->1]) intersect 1[*1:SIZE]) |-> ##1 done);

  ap_som_xfr_done_better: assert property(@ (posedge clk)  $rose(som) ##1
        ((xfr[*0:$] ##1 eom[->1]) intersect 1[*1:SIZE]) |-> ##1 done);
/*
(xft[*0] ##1 eom) or                         // eom 
(xfr[*1] ##1 !eom[*0] ##1  eom) or          // xfr ##0 1 ##1 eom
(xfr[*1] ##1 !eom[*0] ##1 !eom[*1] ##1 eom) or // xfr ##0 1 ##1 !eom ##1 eom
.. 
(xfr[*2] ##1 !eom[*0] ##1  eom) or          // xfr ##0 1 ##1 eom
(xfr[*2] ##1 !eom[*0] ##1 !eom[*1] ##1 eom) or // xfr ##0 1 ##1 !eom ##1 eom */

  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    bit v_a, v_b, v_c;
    static bit[3:0] field[0:24]=
      // som, xfr, eom, done
      {4'b0000, 4'b1000, 4'b0100, 4'b0001,  //4
       4'b0000, 4'b1000, 4'b0110, 4'b0001,  4'b0000,//4
       4'b1000, 4'b0100,  4'b0100,  4'b0100,  4'b0010, 4'b0001, // 6
       4'b1000, 4'b0100,  4'b0100,  4'b0100,  4'b0100, 4'b0100, 4'b0100,  4'b0100, 4'b0010, 4'b0001  //11
     };
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
    #50; 
    end*/
    $finish;
  end
endmodule