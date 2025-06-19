module m_disable;
    bit clk, rst,a, b;
    default disable iff rst;
    // Using the default disable
    ap_ab: assert property (@(posedge clk) a |-> ##[1:3]b);
    ap_no_dis_ab: assert property (@(posedge clk) 
        disable iff (1'b0) // cancels the default disable
        a |-> ##[1:3]b);
endmodule : m_disable

module m;
   bit clk, a=1'b1, b=1'b1;
   initial forever #10 clk=!clk; 
   ap_test: assert property(@ (posedge clk) a|=> b);
endmodule : m

module nested;
    logic a=1'b1, b=1'b0, rst=1'b1, clk=1'b0; 
    initial forever #10 clk=!clk; 
    default clocking cb_clk @ (posedge clk);
    endclocking 
    default disable iff (rst);
    module m2;
        bit c=1'b1, dd, clk; 
        ap_t: assert property(c |-> a ##1 b && dd);   
    endmodule
    m m0(); // default disable does not propagate into m0
endmodule
