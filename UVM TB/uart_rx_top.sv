`include "uvm_macros.svh"
import uvm_pkg::*;

`include "uart_rx_intf.sv"
`include "uart_rx_test.sv"

module tb_top;
bit rx_clk;
bit tx_clk;
bit rst;

always #5 rx_clk = ~rx_clk;
always #40 tx_clk = ~tx_clk;

initial begin
rx_clk = 1;
tx_clk = 0;
rst = 0;
#20; 
rst = 1;
end




uart_rx_intf vif (tx_clk,rx_clk,rst);

UART_RX dut(
.RST(rst),
.RX_CLK(rx_clk),
.RX_IN_S(vif.rx_in_s),
.RX_OUT_P(vif.rx_out_p),
.RX_OUT_V(vif.rx_out_v),
.Prescale(vif.prescale),
.parity_enable(vif.parity_en),
.parity_type(vif.parity_type),
.parity_error(vif.parity_err),
.framing_error(vif.framing_err)
);



/*// Monitor parity changes and trigger reset
bit parity_en_prev;
initial begin
parity_en_prev = vif.parity_en;

forever begin
@(posedge rx_clk);
if ((vif.parity_en !== parity_en_prev) ) begin
	`uvm_info ("TOP",$sformatf("Parity setting changed. Triggering reset "),UVM_LOW);
	rst = 0;
	#20;
	rst = 1;
end
parity_en_prev = vif.parity_en;
end
end*/
// bit count internal signal of UART RX 
assign vif.bit_count = dut.bit_count;

initial begin
//set interface in config_db
uvm_config_db#(virtual uart_rx_intf)::set(uvm_root::get(), "*", "vif", vif);
$dumpfile("dump.vcd");
$dumpvars;
end
initial begin
	run_test("uart_rx_test");
end
endmodule 

