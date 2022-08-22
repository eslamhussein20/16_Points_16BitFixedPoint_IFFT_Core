/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft adder & subtractor               ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

/************************ Module Definition  *****************************/ 
module ifft_add_sub  

/************************ Module Interface   *****************************/

     (
         input  wire  signed [15:0]  op_1       ,     /* RAM-1 Output       */
         input  wire  signed [15:0]  op_2       ,     /* RAM-2 Output       */
		 output wire  signed [15:0]  sum_out    ,     /* Addition    Result */
		 output wire  signed [15:0]  sub_out          /* Subtraction Result */

     );
	 
/************************  Module Body   *********************************/


assign sum_out = op_1 + op_2 ;
assign sub_out = op_1 - op_2 ;



/****************************  Module End  ****************************/
endmodule