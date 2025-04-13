class uart_rx_config extends uvm_object;
  `uvm_object_utils(uart_rx_config)

  bit parity_en;
  bit parity_type;
  bit [4:0] prescale;
  virtual uart_rx_intf vif;

  function new(string name = "uart_rx_config");
    super.new(name);
  endfunction
endclass