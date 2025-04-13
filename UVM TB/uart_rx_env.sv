class uart_rx_env extends uvm_env;
`uvm_component_utils(uart_rx_env)
uart_rx_agent agt;
uart_rx_scoreboard sb;
 
function new(string name = "uart_rx_env", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
	agt = uart_rx_agent::type_id::create("agt", this);
	sb = uart_rx_scoreboard::type_id::create("sb", this);
endfunction

function void connect_phase(uvm_phase phase);
	agt.mon_in.item_collect_port.connect(sb.item_collect_export_in);
	agt.mon_out.item_collect_port_out.connect(sb.item_collect_export_out);
endfunction
endclass