
module top; 
    import uvm_pkg::*; `include "uvm_macros.svh" 
    timeunit 1ns;     timeprecision 100ps;    
    bit clk,req, ack;  
    int ticket, now_serving; 
    default clocking @(posedge clk); 
    endclocking
    initial forever #10 clk=!clk;  
    
    function void inc_ticket(); 
        ticket = ticket + 1'b1; 
    endfunction 

    property reqack_unique;
        int v_serving_ticket;
        @(posedge clk) ($rose(req),  v_serving_ticket=ticket, inc_ticket()) |-> 
             first_match(##[1:10] now_serving==v_serving_ticket) ##0 ack; 
    endproperty
    ap_reqack_unique: assert property(reqack_unique) 
         now_serving =now_serving+1; else now_serving =now_serving+1; 
    
    
    initial begin 
        repeat(100) begin 
            @(posedge clk); #1;  
            if (!randomize(req, ack)  with 
            { req dist {1'b1:=1, 1'b0:=3};
            ack dist {1'b1:=1, 1'b0:=5};       
        }) `uvm_error("MYERR", "This is a randomize error")
    end 
    repeat(200) begin
        @(posedge clk); #1
        if (!randomize(req, ack)  with 
        { req dist {1'b1:=1, 1'b0:=3};
        ack dist {1'b1:=0, 1'b0:=1};       
    }) `uvm_error("MYERR", "This is a randomize error")
end
$stop; 
end 
endmodule   