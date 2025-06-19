/*
Code for use with the book
"SystemVerilog Assertions Handbook, 2nd edition"ISBN  878-0-9705394-8-7

Code is copyright of VhdlCohen Publishing & CVC Pvt Ltd., copyright 2009 

www.systemverilog.us  ben@systemverilog.us
www.cvcblr.com, info@cvcblr.com

All code provided in this book and in the accompanied website is distributed
 with *ABSOLUTELY NO SUPPORT* and *NO WARRANTY* from the authors.  Neither
the authors nor any supporting vendors shall be liable for damage in connection
with, or arising out of, the furnishing, performance or use of the models
provided in the book and website.
*/
// The steps involved in translating these requirements to SVA include the following:  
// 1.	Define objects and types for these objects 
// 2.	Define interfaces for module.
// 3.	Map English requirements to SVA.  Method used for this application is first copying each English requirement into the module as comments, and then mapping the requirements to SVA.   
// // Define objects and types for these objects
// package parking_pkg;
  timeunit 1ns;
  timeprecision 100ps;
// Type defintions
  typedef enum bit[1:0] {NEUTRAL, STOP, START} gate_override_t;
  typedef enum bit {CLOSED, OPEN} gate_t;
  typedef enum bit {ENABLE_COUNTER, BYPASS_COUNTER} counter_cntrl_t;
  // endpackage : parking_pkg

// Define interfaces for module.  
// compilation-unit scope
  // import parking_pkg:: *;
interface parking_structure_if (input wire clk, reset_n);
  timeunit 1ns;
  timeprecision 100ps;
  gate_t           gate_status;
  bit              parking_full;						  
  bit              entrance_sensor;
  bit              exit_sensor;
  gate_override_t  gate_override;
  counter_cntrl_t  counter_cntrl;

  modport parking_cntlr_if (
  output            gate_status,  
  output               parking_full,  
  input                entrance_sensor,
  input                exit_sensor,
  input    gate_override,
  input    counter_cntrl);
endinterface : parking_structure_if

// compilation-unit scope
  // import parking_pkg::*;
//Module definition 
module parking_structure (input clk, input reset_n, parking_structure_if.parking_cntlr_if p_if);

// Object definition that relate to requirements  
//  * The controller maintains the current COUNT of the total number of cars 
//    parked in the lot.
//  * The lot has a limited number of parking spots, for simplicity sixteen (16).
  logic [4:0] car_counter; // counter of parked cars 
  parameter  MAX_SPOTS = 16;
   
 
// A START/STOP input is also available to the attendant, 
// with the STOP input causing a CLOSED output signal.     
//  use the gate_override 

//  * There are two input sensors at the entrance and exit of the lot. 
//    The sensors provide input signals to the controller as cars pass by and 
//    the controller increments/decrements the current COUNT. What if two cars 
//    enter and exit simultaneously?
//  * If COUNT=16, then the controller issues a FULL output signal, 
//    otherwise the OPEN output signal is on.
//What if two cars enter and exit simultaneously?
  property parking_full_to_count_chk;
    @ (posedge clk) car_counter == MAX_SPOTS |-> p_if.parking_full;
  endproperty : parking_full_to_count_chk
  assert property (parking_full_to_count_chk);

// From Spec: Otherwise the OPEN output signal is on.
//  * There is a manual input for the lot attendant to override the COUNT 
//    for special vehicles.
//  * A START/STOP input is also available to the attendant, with the STOP 
//    input causing a CLOSED output signal. 
  property gate_open_status_chk;
    @ (posedge clk) p_if.gate_status == OPEN
    |-> (car_counter < MAX_SPOTS || $past(p_if.gate_override) == START);
  endproperty : gate_open_status_chk
  gate_open_status_chk_1 : assert property (gate_open_status_chk);
 
  property gate_closed_status_chk;
    @ (posedge clk) p_if.gate_status == CLOSED
     |-> (car_counter == MAX_SPOTS || $past(p_if.gate_override) == STOP);
  endproperty : gate_closed_status_chk
  gate_closed_status_chk_1 :  assert property (gate_closed_status_chk);

  // Value change in the car counter 
  property counter_val_change_chk;
	@ (posedge clk) (car_counter != $past(car_counter))
         |->  p_if.counter_cntrl==ENABLE_COUNTER &&  // control is enabled 
           !($past(p_if.entrance_sensor) && $past(p_if.exit_sensor)) && //No simulaneous entrance and exit
           ($past(p_if.entrance_sensor) || $past(p_if.exit_sensor)); // either an entrance or an exit 
  endproperty : counter_val_change_chk
  counter_val_change_chk_1 : assert property (counter_val_change_chk);

  // Counter has no change
   property    counter_val_no_change_chk;
     @ (posedge clk) (car_counter == $past(car_counter)) |->
      !($past(p_if.entrance_sensor) || $past(p_if.exit_sensor)) || // no entrance or exit
       ($past(p_if.entrance_sensor) && $past(p_if.exit_sensor)) || // simulaneous entrance and exit
       p_if.counter_cntrl==BYPASS_COUNTER; // in BYPASS  mode
  endproperty : counter_val_no_change_chk
  counter_val_no_change_chk_1 : assert property (counter_val_no_change_chk);

  // Overflow detection 
  property counter_overflow;
      @ (posedge clk)  not(car_counter == MAX_SPOTS + 1);
  endproperty : counter_overflow
  counter_overflow_1 : assert property  (counter_overflow) else
	  $display("\n %m counter overflew  Prev. value %d Cur Value %d ", 
                              (car_counter), car_counter);
  // $past(car_counter), car_counter);
endmodule : parking_structure

module top;
reg clk, reset_n;

parking_structure_if p_if();

parking_structure parking_structure (.*);
endmodule : top











