/*************************************************************************/
/****        Author         :   Eslam Hussein                         ****/
/****        Block          :   CRC Test Bench                        ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   1 march  2022                         ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

`timescale 1ns/1ps
/************************ Module Definition  *****************************/ 
module  ifft_tb

/************************ Module Interface   *****************************/
     (
     );
	 
/**********************        Parameters          ***********************/
localparam CLK_PERIOD = 10 ;

reg           clk_tb               ;
reg           rest_tb              ;
reg           enable_tb            ;
reg    [15:0] r_0_real_tb          ;
reg    [15:0] r_1_real_tb          ;
reg    [15:0] r_2_real_tb          ;
reg    [15:0] r_3_real_tb          ;
reg    [15:0] r_4_real_tb          ;
reg    [15:0] r_5_real_tb          ;
reg    [15:0] r_6_real_tb          ;
reg    [15:0] r_7_real_tb          ;
reg    [15:0] r_8_real_tb          ;
reg    [15:0] r_9_real_tb          ;
reg    [15:0] r_10_real_tb         ;
reg    [15:0] r_11_real_tb         ;
reg    [15:0] r_0_imag_tb          ;
reg    [15:0] r_1_imag_tb          ;
reg    [15:0] r_2_imag_tb          ;
reg    [15:0] r_3_imag_tb          ;
reg    [15:0] r_4_imag_tb          ;
reg    [15:0] r_5_imag_tb          ;
reg    [15:0] r_6_imag_tb          ;
reg    [15:0] r_7_imag_tb          ;
reg    [15:0] r_8_imag_tb          ;
reg    [15:0] r_9_imag_tb          ;
reg    [15:0] r_10_imag_tb         ;
reg    [15:0] r_11_imag_tb         ;
wire   [15:0] ifft_out_real           ;
wire   [15:0] ifft_out_imag           ;

wire          finish_tb            ;




/*************************** Initial Block *******************************/
initial
     begin
	     //$dumpfile("ifft_tb.vcd");
	     //$dumpvars;

	         rest_tb = 1'b1;
             enable_tb = 1'b0;			 
             clk_tb = 1'b0 ;
			 #10
			 rest_tb = 1'b0; 	
             #10
			 rest_tb = 1'b1;
             enable_tb = 1'b1;
			 r_0_real_tb    =16'b0000010000000000;
			 r_1_real_tb    =16'b0000001110001100;
			 r_2_real_tb    =16'b0000000010000110;
			 r_3_real_tb    =16'b1111110000100011;
			 r_4_real_tb    =16'b0000000001010101;
			 r_5_real_tb    =16'b0000001001110011;
			 r_6_real_tb    =16'b1111110011001111;
			 r_7_real_tb    =16'b0000001010011001;
			 r_8_real_tb    =16'b1111111111110011;
			 r_9_real_tb    =16'b1111110001010011;
			 r_10_real_tb   =16'b0000000101000101;
			 r_11_real_tb   =16'b0000001111100010;
			 r_0_imag_tb    =16'b0000000000000000;
			 r_1_imag_tb    =16'b1111111000100111;
			 r_2_imag_tb    =16'b1111110000001000;
			 r_3_imag_tb    =16'b1111111011110101;
			 r_4_imag_tb    =16'b0000001111111100;
			 r_5_imag_tb    =16'b1111110011010110;
			 r_6_imag_tb    =16'b0000001001101001;
			 r_7_imag_tb    =16'b1111110011110101;
			 r_8_imag_tb    =16'b0000001111111111;
			 r_9_imag_tb    =16'b1111111001101001;
			 r_10_imag_tb   =16'b1111110000110101;
			 r_11_imag_tb   =16'b1111111100001100;
			 #10
			 enable_tb = 1'b1;

			 
			 
			 
			 
		 #(80*CLK_PERIOD);
	     $finish; 
	 end

/************************* Clock Generator *******************************/
always 
     begin
	     #(5) 
	     clk_tb = ~clk_tb ;
	 end
	 
 
	 
	 
	 
	 
	 
/****************** Unit Under Test Instantion ***************************/	 
ifft_top  uut
/************************ Module Interface   *****************************/

     (
         .clk         (clk_tb      ) ,                // input clk
         .rst         (rest_tb     ) ,                // input rst
		 .ifft_enable (enable_tb   ) ,                // input write enable from resource elements mapper
		 .in_0_real   (r_0_real_tb ) ,                // input data from resource elements mapper real
         .in_1_real   (r_1_real_tb ) ,                // input data from resource elements mapper real
         .in_2_real   (r_2_real_tb ) ,                // input data from resource elements mapper real
         .in_3_real   (r_3_real_tb ) ,                // input data from resource elements mapper real
         .in_4_real   (r_4_real_tb ) ,                // input data from resource elements mapper real
         .in_5_real   (r_5_real_tb ) ,                // input data from resource elements mapper real
         .in_6_real   (r_6_real_tb ) ,                // input data from resource elements mapper real
         .in_7_real   (r_7_real_tb ) ,                // input data from resource elements mapper real
         .in_8_real   (r_8_real_tb ) ,                // input data from resource elements mapper real
         .in_9_real   (r_9_real_tb ) ,                // input data from resource elements mapper real
         .in_10_real  (r_10_real_tb) ,                // input data from resource elements mapper real
         .in_11_real  (r_11_real_tb) ,                // input data from resource elements mapper real
		 .in_0_imag   (r_0_imag_tb ) ,                // input data from resource elements mapper imag
         .in_1_imag   (r_1_imag_tb ) ,                // input data from resource elements mapper imag
         .in_2_imag   (r_2_imag_tb ) ,                // input data from resource elements mapper imag
         .in_3_imag   (r_3_imag_tb ) ,                // input data from resource elements mapper imag
         .in_4_imag   (r_4_imag_tb ) ,                // input data from resource elements mapper imag
         .in_5_imag   (r_5_imag_tb ) ,                // input data from resource elements mapper imag
         .in_6_imag   (r_6_imag_tb ) ,                // input data from resource elements mapper imag
         .in_7_imag   (r_7_imag_tb ) ,                // input data from resource elements mapper imag
         .in_8_imag   (r_8_imag_tb ) ,                // input data from resource elements mapper imag
         .in_9_imag   (r_9_imag_tb ) ,                // input data from resource elements mapper imag
         .in_10_imag  (r_10_imag_tb) ,                // input data from resource elements mapper imag
         .in_11_imag  (r_11_imag_tb) ,                // input data from resource elements mapper imag
		 .ifft_out_real      (ifft_out_real    ) ,                // output data from ifft to  interpolator real -- a
		 .ifft_out_imag      (ifft_out_imag    ) ,                // output data from ifft to  interpolator imag -- a
		 .finish      (finish_tb   )                  // output enable to  cyclic prefix
     );
	  
/****************************  Module End  *******************************/
endmodule
