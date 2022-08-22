/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft   counter                        ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

/************************ Module Definition  *****************************/ 
module counter_4_bit  

/************************ Module Interface   *****************************/
     (
         input  wire       clk          ,
         input  wire       rst          ,
         input  wire       enable       ,
		 output wire [3:0] count       
     );
	 
/************************  Module Body   *********************************/
/* Signals Decleration */ 
reg [3:0] data ;

/* Counter Implementation */ 
always @(posedge clk or negedge rst)
     begin
	     if(!rst)
	         begin			 
			     data <= 4'b0000 ; 	
			 end
	     else if (enable)
		     begin
                 data <= data + 4'b0001  ; 					     
	         end	

	 end
assign count =  data ;
/****************************  Module End  ****************************/
endmodule