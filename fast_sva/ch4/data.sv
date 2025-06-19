module top;
  timeunit 1ns;  timeprecision 100ps;    
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, rd, wr, reset_n=1, err; 
  bit [1:0] addr;
  bit[7:0] mem [3:0]; 
  bit[7:0] datain, dataout; 
  always_comb if(err) dataout=500; else dataout=mem[addr];
  always_ff @(posedge clk) if(wr) mem[addr] <= datain; 

  initial forever #2 clk = !clk;
   
  property p_mem_wr; 
    int v_data; 
    bit [1:0] v_addr;
    @(posedge clk) disable iff(reset_n==0) 
      (wr, v_addr=addr, v_data=datain) ##1
      ((rd && addr==v_addr)[->1] intersect !(wr && addr==v_addr)[*1:$]) |->      
             dataout==v_data;
   endproperty 
   ap_mem_wr: assert property(@ (posedge clk) p_mem_wr );   

  initial begin
    $dumpfile("dump.vcd"); $dumpvars;
    // $dumpfile("Test_Adder_16.vcd");
   // $dumpvars(1, Test_Adder_16); 
    repeat (100) begin
      @(posedge clk);
        
      if (!randomize(rd, wr, addr,datain, err) with {
        rd   dist {1'b1 := 1, 1'b0 := 1};
        wr   dist {1'b1 := 1, 1'b0 := 1}; 
        err  dist {1'b1 := 0, 1'b0 := 3};
        addr;
        datain <100; datain >=0; 
      }) `uvm_error("MYERR", "This is a randomize error"); 
    end
    $finish;
  end
endmodule