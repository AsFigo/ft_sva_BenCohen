module m;  
  `include "uvm_macros.svh"   import uvm_pkg::*;
  bit clk, a, wr;
  logic[31:0] addr, data;
  int p0a, p0b, f0a, f0b;   // type int is an example. Users may also select other types
  logic[31:0] aa[int]; // associative array (AA) to be used by property
  logic[31:0] mem[7:0]; // RTL mem to be tested 
  logic[31:0] raadata;  // data read from AA
  bit  aa_exists;  // exists at specified address
  initial forever  #2 clk=!clk;
  
  always @(posedge clk) begin 
     if(wr) begin 
       aa[addr] = data;
       mem[addr] <= data;
       raadata <= 32'hxxxx_xxxx;
       aa_exists <= 0; 
    end 
    else begin 
      raadata <= aa[addr];   
      aa_exists <= aa.exists(addr);
    end
  end

  
// Instead of 
      property p_aawr;
          int vaddr; 
           @ (posedge clk)  (wr, vaddr=addr)  ##1
                     (!(wr && addr==vaddr)[*0:$] ##1 (!wr && addr==vaddr))   |->
                             ##1 aa.exists(vaddr) && aa[addr]==mem[addr];
      endproperty 
      ap_aa1: assert property (p_aawr) p0a ++; else f0a ++; 
      // USE
      property p_aawr2;
        int vaddr; 
           @ (posedge clk)  (wr, vaddr=addr) ##1
               (!(wr && addr==vaddr)[*0:$] ##1 (!wr && addr==vaddr))   |->
                                  ##1 aa_exists && raadata==mem[addr]; 
      endproperty 
      ap_aawr2: assert property(p_aawr2) p0b ++; else f0b ++; ;
      
        

   initial begin : init1
    // $dumpfile("dump.vcd"); $dumpvars;
      int vaddr, vdata;
      bit va, vwr; 
      @(posedge clk) a<=1; 
      repeat(10) @(posedge clk);
      repeat (200) begin
        @(posedge clk);
        if (!randomize(va, vaddr, vdata, vwr) with {
          va    dist {1'b1 := 1, 1'b0 := 3};
          vaddr dist {122 := 1, 133 := 1, 444 :=1}; 
          vdata dist {5 := 1, 6 := 1, 8 :=1};
          vwr      dist {1'b1 := 1, 1'b0 := 1};
        }) `uvm_error("MYERR", "This is a randomize error");
        a <= va;
        addr <= vaddr; 
        data <= vdata;
        if(vwr) begin 
          wr <=1; 
        end else wr <=0; 
      end
      #20;
      $finish;
    end     
endmodule
