/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft mux address                      ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/
/************************ Module Definition  *****************************/ 
module ifft_mux_add  

/************************ Module Interface   *****************************/

     (
         input  wire [3:0] in_0,
         input  wire [3:0] in_1,
         input  wire        sel ,
         output reg  [3:0] out 
     );
	 
/************************  Module Body   *********************************/


always @(*)
     begin
	     case(sel)
			 2'b0:  
			     begin
				     out = in_0;
				 end
			 2'b1:  
			     begin
				     out = in_1;
				 end
         endcase		 
	 end	 


/****************************  Module End  ****************************/
endmodule