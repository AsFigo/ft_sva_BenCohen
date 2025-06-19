module som_xfr;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, som, xfr, eom, done; // start of msg, transfer, end of msg, done 
  initial forever #10 clk = !clk;
  initial begin
    $timeformat(-9, 0, " ns", 10);
    $display("%t", $realtime);
  end
  let SIZE=4;  // can be 10, 20, etc
  // Used the goto and nonconsecute repetition Operators for demonstration 
  ap_som_xfr_done_gap: assert property(@ (posedge clk)  
      $rose(som) |=> ((xfr[*(SIZE-2)] ##1 eom ##1 1) or (##[1:(SIZE-1)] 1 ##1 eom ##1 1))
          intersect (1[*1:SIZE]) ##1 done);

  generate for (genvar i=0; i<=SIZE; i++)
     begin 
        if(i==0 || i==1)
        ap_som_xfr_done_gen0: assert property(@ (posedge clk)  $rose(som) ##1
               SIZE==i &&  eom  |-> ##1 done);
        else 
        ap_som_xfr_done_gen_sz: assert property(@ (posedge clk)  $rose(som) ##1
          ((SIZE==i  && xfr[*0:SIZE] ##1 eom[->1]) intersect 1[*1:SIZE]) |-> ##1 done);
        end
   endgenerate

      
  
  

  initial begin
    //$dumpfile("dump.vcd"); $dumpvars;
    bit v_a, v_b, v_c;
    static bit[3:0] field[0:24]=
      // som, xfr, eom, done
      {4'b0000, 4'b1000, 4'b0000, 4'b0000,  //4
       4'b0000, 4'b0010, 4'b0101, 4'b0001,  //4
       4'b1000, 4'b0100, 4'b0100, 4'b0010,  
       4'b0001, 4'b1000, 4'b0100, 4'b0010,  
       4'b0100, 4'b0100, 4'b0100, 4'b0100,
       4'b0100, 4'b0100, 4'b0100, 4'b0010, 4'b0001  //11
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