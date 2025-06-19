

module traffic;
bit clk, cond, ns_red, ns_green, ns_amber, ew_red, ew_green, ew_amber;
  typedef enum
          { RED, GREEN, AMBER } light_t;
  light_t state, n_s, e_w;

  am_ns_one_only: assert #0 ($count_one({ns_red, ns_green, ns_amber}));

  always_ff @(posedge clk ) begin  
    case (state)
      RED: begin 
        if(cond) ew_green <= 1;
        am_n_s:  assert(ns_red==1); 
      end

        $display("Stop");
      GREEN: 
      AMBER:
        $display("Caution");
      default:
        $display("Invalid state");
    endcase
  end
endmodule
