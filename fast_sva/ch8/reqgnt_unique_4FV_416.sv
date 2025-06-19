
module top; 
    import uvm_pkg::*; `include "uvm_macros.svh" 
    timeunit 1ns;     timeprecision 100ps;    
    bit clk,req, gnt, rst_n;  
    int req_count, gnt_count;  
    initial forever #10 clk=!clk;  
    
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
          req_count <= 0;
          gnt_count <= 0;
        end
        else begin
          if ($rose(req)) req_count <= req_count + 1;
          if (gnt) gnt_count <= gnt_count + 1;
        end
      end

    property reqgnt_unique;
        int v_serving_req_count;
        @(posedge clk) ($rose(req),  v_serving_req_count=req_count) |-> 
             (##[1:10] gnt_count==v_serving_req_count) ##0 gnt; 
    endproperty
    ap_reqgnt_unique: assert property(reqgnt_unique); 
    
    
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