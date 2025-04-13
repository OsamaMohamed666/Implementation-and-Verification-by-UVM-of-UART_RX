interface uart_rx_intf #(parameter DATA_WIDTH =8, PRESCALE_WIDTH =5)
(input tx_clk,rx_clk,rst_n);

// inputs
bit parity_en;
bit parity_type;
bit		rx_in_s;
bit [PRESCALE_WIDTH-1 : 0] prescale;
//OUTPUT
logic	parity_err;
logic	framing_err;
logic	rx_out_v;
logic [DATA_WIDTH-1 :0] rx_out_p;

//An internal signal from the DUT is required to assist with verification and to indicate when 
//a frame should be received
//when bit count equal to one this means that the starting bit of the frame was sent in the pervious cycle
//and this bit is the MSB of the parallel data
bit [3:0] bit_count;
	
//***************************ASSERTIONS***************************
//1) RESET 
property reset_checking;
	@(negedge rx_clk)
	!rst_n |-> rx_out_p==0;
endproperty 

assert property(reset_checking)
	else `uvm_error("ASSERTIONS" ,$sformatf(" RESET STATE IS VIOLATED AT %0t ns",$time));
RESET_CHECKING:cover property(reset_checking);


//2)BIT_COUNT CHANGED: if rx input equals zero it means that bit count will always change, if first bit is zero then rx will start receiving
//and bit count will start increasing From zero to one, if its inside frame also bit count changes every 8 cycles of rx clk(1 tx clk cycle).
property bit_count_changed;
	@(negedge tx_clk) disable iff(!rst_n)
	!rx_in_s |=> !$stable(bit_count);
endproperty
	
assert property(bit_count_changed)
	else `uvm_error("ASSERTIONS" ,$sformatf(" BIT COUNT CHANGED IS VIOLATED AT %0t ns",$time));
BIT_COUNT_CHANGED : cover property(bit_count_changed);


//3) STARTING BIT: once bit count starts to count pervious value of serial input must be 0(starting bit)
property starting_bit_checking;
	@(negedge tx_clk) disable iff(!rst_n)
	$rose((bit_count == 4'b0001)) |-> ($past(rx_in_s) == 0);
endproperty	

assert property(starting_bit_checking)
	else `uvm_error("ASSERTIONS" ,$sformatf(" STARTING BIT IS VIOLATED AT %0t ns",$time));
STARTING_BIT_CHECKING : cover property(starting_bit_checking);

//4) IDLE MODE
property idle_mode_checking;
	@(negedge tx_clk) disable iff(!rst_n)
	!bit_count |-> rx_in_s |=> $stable(bit_count);
endproperty

assert property(idle_mode_checking)
	else `uvm_error("ASSERTIONS" ,$sformatf(" IDLE MODE CHECKING IS VIOLATED AT %0t ns",$time));
IDLE_MODE_CHECKING : cover property(idle_mode_checking);

//5) DATA VALID 
property valid_checking;
	@(negedge rx_clk) disable iff(!rst_n) 
	$rose(rx_out_v) |-> !(framing_err | parity_err);
endproperty

assert property(valid_checking)
	else `uvm_error("ASSERTIONS" ,$sformatf(" VALID CHECKING IS VIOLATED AT %0t ns",$time));
VALID_CHECKING : cover property(valid_checking);

//6) DATA VALID STAYS HIGH FOR ONE PULSE
property valid_high_pulse;
	@(negedge rx_clk) disable iff(!rst_n) 
	$rose(rx_out_v) |=> $fell(rx_out_v);
endproperty

assert property(valid_high_pulse)
	else `uvm_error("ASSERTIONS" ,$sformatf(" VALID HIGH ONE PULSE IS VIOLATED AT %0t ns",$time));
VALID_HIGH_PULSE : cover property(valid_high_pulse);	

//7) CHECKING THAT BIT COUNT COUNTS FROM 0 TO 10 DURING RECEIVING PARITY FRAME:
// zero for starting bit, [1:8] data, 9 parity bit, 10 ending bit
property parity_frame_size;
	@(negedge tx_clk) disable iff(!rst_n)
	$rose((bit_count == 4'b0)) |-> parity_en |-> ($past(bit_count) == 4'b1010);
endproperty

assert property(parity_frame_size)
	else `uvm_error("ASSERTIONS" ,$sformatf(" PARITY FRAME SIZE IS VIOLATED AT %0t ns",$time));
PARITY_FRAME_SIZE : cover property(parity_frame_size);

//8) CHECKING THAT BIT COUNT COUNTS FROM 0 TO 9 DURING RECEIVING NON PARITY FRAME:
// zero for starting bit, [1:8] data, 9 ending bit
property non_parity_frame_size;
	@(negedge tx_clk) disable iff(!rst_n)
	$rose((bit_count == 4'b0)) |-> !parity_en |-> !$past(parity_en ==1) |-> ($past(bit_count) == 4'b1001);
endproperty

assert property(non_parity_frame_size)
	else `uvm_error("ASSERTIONS" ,$sformatf(" NON PARITY FRAME SIZE IS VIOLATED AT %0t ns",$time));
NON_PARITY_FRAME_SIZE : cover property(non_parity_frame_size);

endinterface 
