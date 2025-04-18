`include "DESIGN_PACKAGE.v"
module UART_RX # ( parameter DATA_WIDTH = 8 , PRESCALE_WIDTH = 5 )

(
 input   wire                          RX_CLK,
 input   wire                          RST, // pragma coverage off
 input   wire   [PRESCALE_WIDTH-1:0]   Prescale, // pragma coverage off
 input   wire                          parity_enable,// pragma coverage on
 input   wire                          parity_type,
 input   wire                          RX_IN_S, 

 output  wire   [DATA_WIDTH-1:0]       RX_OUT_P, 
 output  wire                          RX_OUT_V,
 output  wire                          parity_error,
 output  wire                          framing_error
);


wire   [3:0]           bit_count ;
wire   [2:0]           edge_count ;

wire                   edge_bit_en; 
wire                   deser_en; 
wire                   par_chk_en; 
wire                   stp_chk_en; 
wire                   strt_chk_en; 
wire                   strt_glitch;
wire                   sampled_bit;
wire                   dat_samp_en;

 
FSM  U0_uart_fsm (
.clk(RX_CLK),
.rst(RST),
.rx_in(RX_IN_S),
.bit_cnt(bit_count),
.par_en(parity_enable),
.edge_cnt(edge_count), 
.strt_glitch(strt_glitch),
.par_err(parity_error),
.stp_err(framing_error), 
.strt_chk_en(strt_chk_en),
.enable(edge_bit_en), 
.deser_en(deser_en), 
.par_chk_en(par_chk_en), 
.stp_chk_en(stp_chk_en),
.data_samp_en(dat_samp_en),
.data_valid(RX_OUT_V)
);
 
 
edge_bit_counter U0_edge_bit_counter (
.clk(RX_CLK),
.rst(RST),
.en(edge_bit_en),
.bit_count(bit_count),
.edge_count(edge_count) 
); 

data_sampling U0_data_sampling (
.clk(RX_CLK),
.rst(RST),
.rx_in(RX_IN_S),
.prescale(Prescale),
.data_samp_en(dat_samp_en),
.edge_cnt(edge_count),
.sampled_bit(sampled_bit)
);

deserializer # ( .DATA_WIDTH(8)) U0_deserializer (
.clk(RX_CLK),
.rst(RST),
.sampled_bit(sampled_bit),
.en(deser_en),
.edge_count(edge_count), 
.P_DATA(RX_OUT_P)
);

strt_chk U0_strt_chk (
.clk(RX_CLK),
.rst(RST),
.sampled_bit(sampled_bit),
.en(strt_chk_en), 
.strt_glitch(strt_glitch)
);

par_chk # ( .DATA_WIDTH(8)) U0_par_chk (
.clk(RX_CLK),
.rst(RST),
.parity_type(parity_type),
.sampled_bit(sampled_bit),
.en(par_chk_en), 
.P_DATA(RX_OUT_P),
.par_err(parity_error)
);

stp_chk U0_stp_chk (
.clk(RX_CLK),
.rst(RST),
.sampled_bit(sampled_bit),
.en(stp_chk_en), 
.stp_err(framing_error)
);


endmodule
 
