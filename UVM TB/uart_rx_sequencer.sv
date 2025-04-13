class uart_rx_sequencer extends uvm_sequencer #(seq_item);

`uvm_component_utils(uart_rx_sequencer)

function new (string name, uvm_component parent);
super.new(name,parent);
endfunction

function void build_phase(uvm_phase phase);
super.build_phase(phase);
endfunction
endclass 