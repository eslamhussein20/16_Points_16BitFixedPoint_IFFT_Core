/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft twidlle factors rom              ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

/************************ Module Definition  *****************************/ 
module ifft_tf_rom  

/************************ Module Interface   *****************************/

     (
         input  wire  [3 :0]   rd_add    ,
		 output reg   [15:0]   data_out_imag ,
		 output reg   [15:0]   data_out_real

     );
	 
/************************  Module Body   *********************************/

always @(*)
     begin
	     case(rd_add)
             4'b0000: data_out_imag=16'b0000000000000000;    /* WN16_imag_1 */
             4'b0001: data_out_imag=16'b0000000110000111;    /* WN16_imag_2 */
             4'b0010: data_out_imag=16'b0000001011010100;    /* WN16_imag_3 */
             4'b0011: data_out_imag=16'b0000001110110010;    /* WN16_imag_4 */
             4'b0100: data_out_imag=16'b0000010000000000;    /* WN16_imag_5 */
             4'b0101: data_out_imag=16'b0000001110110010;    /* WN16_imag_6 */
             4'b0110: data_out_imag=16'b0000001011010100;    /* WN16_imag_7 */
             4'b0111: data_out_imag=16'b0000000110000111;    /* WN16_imag_8 */
             4'b1000: data_out_imag=16'b0000000000000000;    /* WN8_imag_1  */
             4'b1001: data_out_imag=16'b0000001011010100;    /* WN8_imag_2  */
             4'b1010: data_out_imag=16'b0000010000000000;    /* WN8_imag_3  */
             4'b1011: data_out_imag=16'b0000001011010100;    /* WN8_imag_4  */
             4'b1100: data_out_imag=16'b0000000000000000;    /* WN4_imag_1  */
             4'b1101: data_out_imag=16'b0000010000000000;    /* WN4_imag_2  */
             4'b1110: data_out_imag=16'b0000000000000000;    /* WN2_imag_1  */
			 default: data_out_imag=16'b0000000000000000;    /* Avoid Latch */
         endcase    
	 end
always @(*)
     begin
	     case(rd_add)
             4'b0000: data_out_real=16'b0000010000000000;    /* WN16_real_1 */
             4'b0001: data_out_real=16'b0000001110110010;    /* WN16_real_2 */
             4'b0010: data_out_real=16'b0000001011010100;    /* WN16_real_3 */
             4'b0011: data_out_real=16'b0000000110000111;    /* WN16_real_4 */
             4'b0100: data_out_real=16'b0000000000000000;    /* WN16_real_5 */
             4'b0101: data_out_real=16'b1111111001111000;    /* WN16_real_6 */
             4'b0110: data_out_real=16'b1111110100101011;    /* WN16_real_7 */
             4'b0111: data_out_real=16'b1111110001001101;    /* WN16_real_8 */
             4'b1000: data_out_real=16'b0000010000000000;    /* WN8_real_1  */
             4'b1001: data_out_real=16'b0000001011010100;    /* WN8_real_2  */
             4'b1010: data_out_real=16'b0000000000000000;    /* WN8_real_3  */
             4'b1011: data_out_real=16'b1111110100101011;    /* WN8_real_4  */
             4'b1100: data_out_real=16'b0000010000000000;    /* WN4_real_1  */
             4'b1101: data_out_real=16'b0000000000000000;    /* WN4_real_2  */
             4'b1110: data_out_real=16'b0000010000000000;    /* WN2_real_1  */
			 default: data_out_real=16'b0000000000000000;    /* Avoid Latch */
         endcase    
	 end


/****************************  Module End  ****************************/
endmodule