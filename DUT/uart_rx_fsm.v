module FSM (

  input             clk,
  input             rst,
  input             rx_in,
  input    [2:0]    edge_cnt,
  input    [3:0]    bit_cnt,
  input             par_err,
  input             par_en,
  input             strt_glitch,
  input             stp_err,
  
  output reg        enable, // edge bit count enable 
  output reg        data_samp_en,
  output reg        par_chk_en,
  output reg        strt_chk_en,
  output reg        stp_chk_en,
  output reg        deser_en,
  output reg        data_valid

  );
  
  //5 STATES
  localparam        idle = 3'b000,
                    strt_chk = 3'b001,
                    deser = 3'b010, 
                    par_chk = 3'b011,
                    stp_chk = 3'b100,
                    err_chk = 3'b101,
                    data_vld = 3'b110;
					
	
  
  wire edge_7 , bit_8;
  wire [2:0] deser_cond;
  assign edge_7 = (edge_cnt == 3'b111)? 1'b1 : 1'b0;
  assign bit_8 = (bit_cnt == 4'b1000);
  assign deser_cond = {par_en,bit_8,edge_7};
  
  reg [2:0] cs,ns;  // CURRENT_STATE & NEXT_STATE
 
           					 
  always @ (posedge clk or negedge rst)
   begin
    if(!rst)
	    cs<=idle;
	else 
	    cs<=ns;
   end
   
   // NEXT STATE LOGIC & OUTPUT LOGIC
   always @ (*)
    begin
	    par_chk_en=0;
		deser_en=0;
		strt_chk_en=0;
		stp_chk_en=0;
		data_valid=0;
		enable=1;
		data_samp_en=1;
		
        case (cs)
		  idle :     begin
		              if(rx_in)
					   begin
		                 data_samp_en=0;
					     enable=0; 
						 ns=idle;
					   end
					  else
					   begin
					    ns=strt_chk;
					    strt_chk_en=1;
					   end 
					end
		  strt_chk : begin
					   strt_chk_en=1;
						if (bit_cnt=='b0 && edge_7) 
						 begin
						  if(strt_glitch)
					       ns=idle;
						  else
                           ns=deser;
						  end 
						else 
							ns = cs;
					 end	 
					 
          deser :    begin
					    deser_en=1;
		                case(deser_cond)
						3'b011 : begin
						            ns=stp_chk;
								 end 
						3'b111 : begin
						            ns=par_chk;
								 end
						default : ns=cs;
						endcase
		                
					 end	
						 
		  par_chk :  begin 
						par_chk_en=1;
						if (edge_7)
						 ns=stp_chk;
						else
						 ns=cs;
					 end
					
		  stp_chk :  begin
						stp_chk_en = 1;
						 if (edge_cnt == 3'b101)
						  ns=err_chk;
						 else 
						  ns = cs;
					 end 
		  
		  err_chk : begin
					enable=0;
					 if (par_err | stp_err)
					  ns = idle;
					 else 
					  ns = data_vld;
					end 
		  data_vld : begin
					data_valid =1;
					 enable =0;
					 data_samp_en =0;
 
					 if(!rx_in)
					  ns = strt_chk ;
					 else
					  ns = idle; 						
					end			  			
		  default : begin 
					 ns=idle;
					 enable=0;
					 deser_en=0;
					end 
		endcase
	end
	
endmodule 

						
				
						 
								    
							
							
                            		  
					
	
	
	
	
