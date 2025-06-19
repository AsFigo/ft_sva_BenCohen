module past;
    bit clk, regload=1'b0, load_enable; 
    int reg_data=5, load_data=0; 
    int count=0, data=0, data_if=0; 
    initial forever #10 clk=!clk; 
    default clocking cb_clk @ (posedge clk);  endclocking 
    ap_past1: assert property( 
        regload |-> ##2 reg_data==$past(data, 1, load_enable, @ (posedge clk) )
            );
    ap_past2: assert property( 
        regload |-> ##2 reg_data==$past(data, 2, load_enable, @ (posedge clk) )
            );
    ap_past3: assert property( 
        regload |-> ##2 reg_data==$past(data, 3, load_enable, @ (posedge clk) )
            );

    ap_past1a: assert property( 
        1 |-> ##2 1) $display("%t, data1a=%h, data_if=%h", $time, 
             $past(data, 1, load_enable, @ (posedge clk) ), data_if
            );
    ap_past2a: assert property( 
        1 |-> ##2 1) $display("%t, data2a=%h, data_if=%h", $time, 
             $past(data, 2, load_enable, @ (posedge clk) ), data_if
            );
    ap_past3a: assert property( 
        1 |-> ##2 1) $display("%t, data3a=%h, data_if=%h", 
             $time, $past(data, 3, load_enable, @ (posedge clk) ), data_if
            );
            
    always_ff @ (posedge clk iff load_enable)  begin : aly 
        count <= count+1; 
        data_if <= data; 
    end : aly

    always_ff @ (posedge clk)  begin : aly1 
        static int vdata; 
        if(!randomize(vdata))  $error("randomization failure"        ); 
        data <= vdata; 
        load_data <= vdata; 
    end : aly1

    initial begin
        @ (posedge clk) regload <=1'b1;
        ##4 load_data <= 5; 
        #2; ##1 load_enable <= 1'b1; 
        ##1 load_enable <= 1'b0; 
        ##2 load_enable <= 1'b1; 
        ##2 load_enable <= 1'b0; 
        ##1 load_enable <= 1'b1; 
        ##4 load_enable <= 1'b0; 
    end 
endmodule : past
