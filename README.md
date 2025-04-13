# Verification-of-UART_RX-by-UVM
Design specifications are supervised by Eng. Ali El-Temsah
UART RX UVM environment  : 
  1) The RX clock runs 8 times faster than the TX clock (prescaling = 8).
  2) Active low reset
  3) Randomization is directed to generate valid frames as frequently as possible, since coverage is not a primary focus in this environment.
  4) An internal signal (bit_count) is used to track the reception process across the start bit, 8-bit data, optional parity bit, and stop bit.
  5) Some assertions are written specifically to verify the behavior of the internal bit_count signal, ensuring it increments correctly across the reception of the       start bit, data bits, optional parity bit, and stop bit, as per the design specification.
  6) Testing odd, even parity, and non-parity behaviours.
