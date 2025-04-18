module stp_chk (

  input        clk,
  input        rst,
  input        en,
  input        sampled_bit,
  output  reg  stp_err

  );
  
  always @ (posedge clk or negedge rst)
   begin
     if (!rst)
	  stp_err<=0;
	  else 
	   begin
	    if(en)
		 begin
		  case(sampled_bit)
		    1'b0 : begin 
			         stp_err<=1;
			       end
			1'b1 : begin
			        stp_err<=0;
				   end
		  endcase 
		 end  
	   end
	end   
	
endmodule 
