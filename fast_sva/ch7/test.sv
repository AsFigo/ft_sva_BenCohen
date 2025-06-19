
module top;
  `include "uvm_macros.svh"   
   import uvm_pkg::*;
   bit clk, sig1, sig2, reset_n; 
   function  automatic void  fn_msg(int x);
        case (x)
            0:  `uvm_info(tID,$sformatf("%m : ap1_sig1_2 PASS %b", sig2), UVM_LOW)
            1:  `uvm_error(tID,$sformatf("%m : ap1_sig1_2error in sig2= %b", sig2))
            2:  `uvm_info(tID,$sformatf("%m : am_1_2 PASS %b", sig2), UVM_LOW)
            3:  `uvm_error(tID,$sformatf("%m : am_1_2 error in sig1=%b, sig2= %b", sig1, sig2))
            default:  $display("CODE ERROR");
        endcase
    endfunction
  string tID="AMBA";
      ap1_sig1_2: assert property(@ (posedge clk) sig1 |-> ##1 sig2)
              `uvm_info(tID,$sformatf("%m : PASS %b", sig2), UVM_LOW)  else  fn_msg(1);
           //   `uvm_error(tID,$sformatf("%m : error in a %b", sig2)); 

      am_1_2: assert #0 (sig1 && sig2)  fn_msg(2); else fn_msg(3);
        
  initial forever #10 clk = !clk; 

  initial begin
    bit v_a, v_b, v_err;
    $dumpfile("dump.vcd"); $dumpvars;
    // $dumpfile("Test_Adder_16.vcd");
   // $dumpvars(1, Test_Adder_16); 
    repeat (20) begin
      @(posedge clk);
      if (!randomize(v_a, v_b, v_err) with {
        v_a   dist {1'b1 := 1, 1'b0 := 1};
        v_b   dist {1'b1 := 1, 1'b0 := 2};
        v_err dist {1'b1 := 1, 1'b0 := 15};
      }) `uvm_error("MYERR", "This is a randomize error");
      sig1 <= v_a;
      sig2 <=!v_b; 
    end
    $finish;
  end
endmodule



