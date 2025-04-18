module data_sampling (
  
  input                  clk,
  input                  rst,
  input                  rx_in,
  input       [4:0]      prescale,
  input       [2:0]      edge_cnt,
  input                  data_samp_en,
  output  reg            sampled_bit

  );
  
wire [3:0]	half_edge_before,half_edge,half_edge_after;

reg  [2:0] samples;

assign half_edge = (prescale >> 'b1) - 'b1;
assign half_edge_before = half_edge - 'b1;
assign half_edge_after = half_edge + 'b1;
  
  always @ (posedge clk or negedge rst)
    begin
	  if (!rst)
		samples<=0;
	  else if (data_samp_en)
       	begin
            if(edge_cnt == half_edge)
				samples[1] <= rx_in;
			else if (edge_cnt == half_edge_before)
				samples[0] <= rx_in;
			else if (edge_cnt == half_edge_after)
				samples[2] <= rx_in;
        end
	  else
		samples<=0;
	end	
	
//lets get the dominant sample zero or one of the three samples
always @ (posedge clk or negedge rst)
 begin
  if(!rst)
    sampled_bit <= 'b0 ;
  else
   begin
    if(data_samp_en) 
	 begin
      case (samples)
      3'b000 :  sampled_bit <= 1'b0 ;   	
      3'b001 :  sampled_bit <= 1'b0 ;
      3'b010 :  sampled_bit <= 1'b0 ;
      3'b011 :  sampled_bit <= 1'b1 ;
      3'b100 :  sampled_bit <= 1'b0 ;
      3'b101 :  sampled_bit <= 1'b1 ;
      3'b110 :  sampled_bit <= 1'b1 ;
      3'b111 :  sampled_bit <= 1'b1 ;
      endcase
     end
    else
      sampled_bit <= 1'b0 ;
   end
 end 

	
	
	
endmodule 	
              						  
