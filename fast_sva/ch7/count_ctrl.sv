module count_ctrl;
    logic [31:0] control_reg;
    logic [1:0] bad_bits;
    logic clk, init_done; 
    default clocking cb_clk @ (posedge clk); endclocking 
    initial begin
        wait(init_done); 
        bad_bits[0] = 'x;
        bad_bits[1] = 'z; 
    end
// X and Z allowed during initialization, but no Z or X allowed afterwards
    ap_control_reg: assert property(
        $countbits(control_reg, bad_bits[0], bad_bits[1]) == 0);
endmodule : count_ctrl
