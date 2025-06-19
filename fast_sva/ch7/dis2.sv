module dis2;
    bit clk, r, rst_n, a=1, b=1, c, c_ff, rst_an, rst_n_dly; 
    initial forever #10 clk=!clk; 
    always @(posedge clk) begin
        c_ff <= c; 
    end
    assign rst_n = r && c_ff; 
    assign #1  rst_n_dly = rst_n; 
    ap_1: assert property(@ (posedge clk)
        disable iff ($sampled(!rst_n))
        a |-> ##3 b);

    ap_dis_sync: assert property(@ (posedge clk)
        disable iff ($fell(!rst_n, @(posedge clk)))
        a |-> ##3 b);



    ap_eq: assert property(@ (posedge clk)
        disable iff (!rst_an)
        a |-> ##3 b);

    ap_eqv: assert property(@ (posedge clk)
        disable iff (!rst_n_dly)
        a |-> ##3 b);

    ap_sync: assert property(@ (posedge clk)
        sync_accept_on (!rst_n)
        a |-> ##3 b);



    function automatic bit reset();
        rst_an = 1'b0;
    endfunction : reset

    function automatic bit set();
        rst_an = 1'b1;
    endfunction : set

    assert #0(rst_n) set(); else reset(); 

    ap_2: assert property(@ (posedge clk)
        disable iff ((!rst_n))
        a |-> ##3 b);

    always @ (posedge clk) begin 
        // #3
        if(!randomize(rst_n, r, c))  $error("randomization failure"); 
    end

endmodule : dis2



