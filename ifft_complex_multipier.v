/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft complex multiplier               ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/
/************************ Module Definition  *****************************/ 
module ifft_complex_multipier  

/************************ Module Interface   *****************************/

     (
         input  wire signed [15:0] op_1_real   ,
         input  wire signed [15:0] op_1_imag   ,
         input  wire signed [15:0] op_2_real   ,		 
         input  wire signed [15:0] op_2_imag   ,
         output wire signed [15:0] result_real ,
         output wire signed [15:0] result_imag 
     );
	 
/************************  Module Body   *********************************/

reg signed [31:0] op1r_x_op2r ;
reg signed [31:0] op1r_x_op2i ;
reg signed [31:0] op1i_x_op2r ;
reg signed [31:0] op1i_x_op2i ;
reg signed [31:0] o_r ;
reg signed [31:0] o_i ;

always @(*)
     begin	 
	 
         op1r_x_op2r = op_1_real*op_2_real;  
         op1r_x_op2i = op_1_real*op_2_imag;  
         op1i_x_op2r = op_1_imag*op_2_real;  
         op1i_x_op2i = op_1_imag*op_2_imag; 
		 
         o_r = op1r_x_op2r-op1i_x_op2i;  
         o_i = op1i_x_op2r+op1r_x_op2i;

		 
	 end	 
assign result_real = o_r[25:10];
assign result_imag = o_i[25:10];



/****************************  Module End  ****************************/
endmodule