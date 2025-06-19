module akill;
	bit clk, a,b;
	default clocking @(posedge clk); endclocking
    initial forever #10 clk=!clk;  
	ap_test_kill: assert property(@(posedge clk) 1 |=> 1) $assertkill(0, akill.ap_test_kill);  
	ap_test_kill0: assert property(@(posedge clk) 1 |=> 1) $assertcontrol(5, 15, 7, 0, akill.ap_test_kill0);  
	// $assertkill[(levels[, list])] is equivalent to $assertcontrol(5, 15, 7, levels [,list])
	
	ap_test_off: assert property(@(posedge clk) 1 |=> 1) $assertoff(0, akill.ap_test_off);  
	// $assertoff[(levels[, list])] is equivalent to $assertcontrol(4, 15, 7, levels [,list])
endmodule 