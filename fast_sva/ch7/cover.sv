module m;
 bit clk, a, b=1; 
 initial forever #10 clk=!clk; 
cp_1: cover property (@(posedge clk) a |-> ##1 b);
c_sq: cover sequence (@(posedge clk)a ##1 b);    

initial begin 
    repeat(100) begin
        @(posedge clk); 
        $finish;  
    end
endmodule