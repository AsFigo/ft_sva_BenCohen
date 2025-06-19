module m;
bit clk, req, ack;
bit[2:0] count_dly;
bit[1:0] service; 

always_ff @(posedge clk) begin
    if(ack || count_dly==3'b111) begin 
        count_dly<= 3'b000;
        service<= service + 1'b1;
    end
    else  count_dly<= count_dly + 1'b1;     
end


generate for (genvar i=0; i<=4; i++)  begin
      property p_reqack;
        bit[1:0] id;
         ($rose(req), id=i)  |-> ##[1:7] ack && service==id;
      endproperty : p_reqack 
      ap_reqack: assert property(@(posedge clk) p_reqack);
    end  
endgenerate

endmodule : m
