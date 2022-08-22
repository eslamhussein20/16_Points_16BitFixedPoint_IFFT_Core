/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   Parallel to serial                    ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

/************************ Module Definition  *****************************/ 
module ifft_p2s  
/************************ Module Interface   *****************************/

     (
	     input   wire           clk      ,
	     input   wire           rst      ,
	     input   wire           wr_en    ,
	     input   wire           shift    ,
		 input   wire  [3:0]    count    ,   
         input   wire  [15:0]   in_0     ,
         input   wire  [15:0]   in_1     ,
         input   wire  [15:0]   in_2     ,
         input   wire  [15:0]   in_3     ,
         input   wire  [15:0]   in_4     ,
         input   wire  [15:0]   in_5     ,
         input   wire  [15:0]   in_6     ,
         input   wire  [15:0]   in_7     ,
         input   wire  [15:0]   in_8     ,
         input   wire  [15:0]   in_9     ,
         input   wire  [15:0]   in_10    ,
         input   wire  [15:0]   in_11    ,
		 output  wire  [15:0]   data_out     

     );
	 
/************************  Module Body   *********************************/
/*  */ 
reg    [15:0] r_0     ;
reg    [15:0] r_1     ;
reg    [15:0] r_2     ;
reg    [15:0] r_3     ;
reg    [15:0] r_4     ;
reg    [15:0] r_5     ;
reg    [15:0] r_6     ;
reg    [15:0] r_7     ;
reg    [15:0] r_8     ;
reg    [15:0] r_9     ;
reg    [15:0] r_10    ;
reg    [15:0] r_11    ;



/*  */ 
always @(posedge clk or negedge rst )
     begin
	     if(!rst)
		     begin
			     r_0   <= 16'h0000;
				 r_1   <= 16'h0000;
				 r_2   <= 16'h0000;
				 r_3   <= 16'h0000;
				 r_4   <= 16'h0000;
				 r_5   <= 16'h0000;
				 r_6   <= 16'h0000;
				 r_7   <= 16'h0000;
				 r_8   <= 16'h0000;
				 r_9   <= 16'h0000;
				 r_10  <= 16'h0000;
				 r_11  <= 16'h0000;
			 end
         else if(shift)
		     begin         
			     r_0   <= r_1      ;
			     r_1   <= r_2      ;
			     r_2   <= r_3      ;
			     r_3   <= r_4      ;
			     r_4   <= r_5      ;
			     r_5   <= r_6      ;
			     r_6   <= r_7      ;
			     r_7   <= r_8      ;
			     r_8   <= r_9      ;
			     r_9   <= r_10     ;
			     r_10  <= r_11     ;
			     r_11  <= 16'h0000 ;
             end			 
	     else if(wr_en) 
		     begin
 			     r_0   <= in_0 ;
			     r_1   <= in_1 ;
			     r_2   <= in_2 ;
			     r_3   <= in_3 ;
			     r_4   <= in_4 ;
			     r_5   <= in_5 ;
			     r_6   <= in_6 ;
			     r_7   <= in_7 ;
			     r_8   <= in_8 ;
			     r_9   <= in_9 ;
			     r_10  <= in_10;
			     r_11  <= in_11;	
			 end	
				 
	 end	 
 	 	 	
assign data_out = r_0 ;



/****************************  Module End  ****************************/
endmodule