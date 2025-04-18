# Implementation-and-Verification-by-UVM-of-UART_RX
## Design specifications are supervised by Eng. Ali El-Temsah:
  1) UART RX receives a UART frame on S_DATA. 
  2) UART RX supports oversampling by 8.
  3) S_DATA is high in the IDLE case (No transmission).
  4) Starting bit = 0, Stop bit = 1.
  5) DATA is extracted from the received frame and then sent 
    through P_DATA bus associated with DATA_VLD signal only after 
    checking that the frame is received correctly and not corrupted.
    (PAR_ERR = 0 && STP_ERR(Frame error) = 0).


## Design Architecture:
![image](https://github.com/user-attachments/assets/a88fe078-fff5-4c6a-8580-10f55bda8de6)


## UART RX UVM environment: 
  1) The RX clock runs 8 times faster than the TX clock (prescaling = 8).
  2) Randomization is directed to generate valid frames as frequently as possible, since coverage is not a primary focus in this environment.
  3) An internal signal (bit_count) is used to track the reception process across the start bit, 8-bit data, optional parity bit, and stop bit.
  4) Some assertions are written specifically to verify the behavior of the internal bit_count signal, ensuring it increments correctly across the reception of the start bit, data bits, optional parity bit, and 
   stop bit, as per the design specification.
  5) Testing odd, even parity, and non-parity behaviours.
  6) The testbench is executed using Synopsys VCS (DVE); however, due to confidentiality constraints, simulation results cannot be shared. Alternatively, a representative version will be provided via EDA Playground by using run.bash file


## TESTBENCH Architecture:
![UART](https://github.com/user-attachments/assets/88bf3f8d-792e-4fa9-924b-f6b7472eeb27)


## UVM TOPOLOGY
![image](https://github.com/user-attachments/assets/89b7d8f8-7706-43a5-8711-65758642080f)



## Simulation results:
  ##### LOG
![image](https://github.com/user-attachments/assets/6f0474fd-362d-49d5-be81-23cfab7727d6)

 ##### Simulation of ODD PARITY (FRAME ERROR) rx input serial is 0 at bit count 10
![image](https://github.com/user-attachments/assets/8e8a5ee2-0ec2-49f2-b9a1-ebb9e2468a88)

 ##### Simulation of EVEN PARITY (VALID FRAME) data valid is high for one clock cycle before the bit count equals 0
![image](https://github.com/user-attachments/assets/342fe01f-04b1-4138-85c2-492520d5de30)

 ##### Simulation of NON PARITY (VALID FRAME) bit count only counts 9 in this situation
 ![image](https://github.com/user-attachments/assets/013c1931-b285-45a6-ae20-3eca4ab9cb74)


 ## Assertions coverage 
![image](https://github.com/user-attachments/assets/f1dde45c-a9ad-4e4b-be12-dcc7c3b45d59)
![image](https://github.com/user-attachments/assets/9cf609a9-42fe-4d70-9c0d-5a9850f60a2e)


  





