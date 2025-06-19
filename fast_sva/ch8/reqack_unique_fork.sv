
module top; 
    import uvm_pkg::*; `include "uvm_macros.svh" 
    timeunit 1ns;     timeprecision 100ps;    
    bit clk,req, gnt, rst_n;  
    int req_count, gnt_count; 
    default clocking @(posedge clk); 
    endclocking
    initial forever #10 clk=!clk;  

    task automatic t_req_gnt();
      int v_count=0; // count for [*1:5], 
      int v_req; //  request ID to match grant ID
      bit done=0, pass=0;
      if(req) begin 
        req_count<= req_count+1; // update request count
        v_req= req_count;
        fork
            begin : wait_gnt
                while (v_count<=5 || done) begin
                    @(posedge clk) v_count++; 
                    if(gnt && gnt_count==v_req) begin
                        pass=1;
                        done=1; // grant received for this request
                    end                    
                end 
            end  
            // begin : aother process
            // end      
        join_any
        am_req_gnt: assert(pass); 
      end
    endtask

    
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          req_count <= 0;
          gnt_count <= 0;          
        end
        else 
            fork
                t_req_gnt();
            join_none
        end 

    property reqack_unique;
        int v_req;
        @(posedge clk) ($rose(req),  v_req=req_count) |-> 
             (##[1:5] gnt_count==v_req) ##0 gnt; 
    endproperty
    ap_reqack_unique: assert property(reqack_unique); 
    
    
    initial begin 
        repeat(100) begin 
            @(posedge clk); #1;  
            if (!randomize(req, gnt)  with 
            { req dist {1'b1:=1, 1'b0:=3};
            gnt dist {1'b1:=1, 1'b0:=5};       
        }) `uvm_error("MYERR", "This is a randomize error")
    end 
    repeat(200) begin
        @(posedge clk); #1
        if (!randomize(req, gnt)  with 
        { req dist {1'b1:=1, 1'b0:=3};
        gnt dist {1'b1:=0, 1'b0:=1};       
    }) `uvm_error("MYERR", "This is a randomize error")
end
$stop; 
end 
endmodule   