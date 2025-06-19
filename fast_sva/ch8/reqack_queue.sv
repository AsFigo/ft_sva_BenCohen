

// ---------------------------------------------------------------
module m;  
  //`include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, rst_n, push, pop, full, empty;
  logic[31:0] data_in, data_out1, data_outq;  
  int p1a, p1b, f1a, f1b;   // type int is an example. Users may also select other types
  logic[31:0] q[$];// queue
  logic[31:0] q_size=0;
  logic[31:0] q_front, q_back;

  initial forever  #2 clk=!clk;

   

  always @(posedge clk) begin // Queue update and support logic 
    if(push) begin 
      q.push_front(data_in);     
    // $display ("%0t q_size: %0d", $time, q_size);
    end
    if(pop) begin 
      data_outq=q.pop_back(); 
    end 
    q_size = q.size(); 
    q_front = q[0];
    q_back = q[$];
    //   $display ("%0t q_front: 0x%0h q_back: 0x%0h", $time, q_front, q_back);    
  end 
    
    // requirements: If  a push then at the next cycle q[0]== pushed rtl pushed value  
    // RTL fifo same size as expected 
    // 
    ap_qpush0: assert property(@ (posedge clk)   push && !pop|-> 
          ##1 q.size()==fifo1.count ##0 q.size()>0 ##0 fifo1.empty==0
          ##0 q[0]==fifo1.mem[fifo1.wr_ptr-1]); //  p1a ++; else f1a ++;  

    ap_qpush1: assert property(@ (posedge clk)   push && !pop|-> 
          ##1 q_size==fifo1.count ##0 q_size >0 ##0 fifo1.empty==0
          ##0 $past(data_in)==fifo1.mem[fifo1.wr_ptr-1]); //  p1a ++; else f1a ++; 


    ap_qpop0: assert property(@ (posedge clk)   !push && pop|-> 
          ##1 q.size()==fifo1.count ##0 $past(q.size()) > 0  
          ##0 $past(q[$])==data_out1 ); // p1a ++; else f1a ++;   

    
    ap_qpop1: assert property(@ (posedge clk)   !push && pop|-> 
          ##1 q_size==fifo1.count ##0 $past(q_size) > 0  
          ##0 data_outq==(data_out1)); // p1a ++; else f1a ++;  
  
   initial begin : init1
    // $dumpfile("dump.vcd"); $dumpvars;
      bit[4:0] vdata;
      bit vpush, vpop; 
      rst_n <= 0; repeat(2) @(posedge clk); rst_n<=1; // reset 
      repeat (200) begin : brepeat
        @(posedge clk);
        if (!randomize(vdata, vpush, vpop) with {
           // vdata dist {vdata > 0, vdata < 128};
           vpush  dist {1'b1 := 1, 1'b0 := 3};
           vpop   dist {1'b1 := 1, 1'b0 := 2}; 
           }) $error("MYERR This is a randomize error");
      
        data_in <= vdata;
        if(vpush) push<=1; else push <= 0; 
        if(vpop && q.size() > 0)  pop <= 1; else pop <= 0; 
       end : brepeat 
       #20;
       $finish;
    end : init1
endmodule
  