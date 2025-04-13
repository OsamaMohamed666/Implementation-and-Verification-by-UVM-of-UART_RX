class uart_rx_agent extends uvm_agent;
`uvm_component_utils(uart_rx_agent)
uart_rx_driver drv;
uart_rx_sequencer seqr;
uart_rx_monitor_in mon_in;
uart_rx_monitor_out mon_out;

function new(string name = "uart_rx_agent", uvm_component parent = null);
super.new(name, parent);
endfunction

function void build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(get_is_active == UVM_ACTIVE) begin 
		drv = uart_rx_driver::type_id::create("drv", this);
		seqr = uart_rx_sequencer::type_id::create("seqr", this);
	end
	mon_in = uart_rx_monitor_in::type_id::create("mon_in", this); 
	mon_out = uart_rx_monitor_out::type_id::create("mon_out", this);
endfunction

function void connect_phase(uvm_phase phase);
	if(get_is_active == UVM_ACTIVE) begin 
		drv.seq_item_port.connect(seqr.seq_item_export);
	end
endfunction
endclass