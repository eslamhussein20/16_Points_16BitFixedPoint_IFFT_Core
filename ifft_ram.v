/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft ram                              ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

/************************ Module Definition  *****************************/ 
module ifft_ram  




/************************ Module Parameters  *****************************/ 
    #( 
	     parameter DATA_WIDTH = 16, 
	     parameter ADDR_WIDTH = 4, 
	     parameter DEPTH      = 16
     )

/************************ Module Interface   *****************************/

     (
         input   wire                        clk                       ,
         input   wire                        rst                       ,
         input   wire                        wr_en                     ,
         input   wire  [ADDR_WIDTH-1:0]      rd_add                    ,
         input   wire  [ADDR_WIDTH-1:0]      wr_add                    ,
		   input   wire  [DATA_WIDTH-1:0]      data_in                   ,
		   output  wire   [DATA_WIDTH-1:0]      data_out                  
     );
	 
/************************  Module Body   *********************************/
/* Signals Declaration */ 
reg   [DATA_WIDTH-1:0] mem [2**ADDR_WIDTH-1:0];



/*Always block for rest & write process */ 
always @(posedge clk )
     begin
         if(wr_en) 
		     begin
 			     mem[wr_add] <= data_in ;
			 end				 
	 end	 
 	 	 	
			assign	  data_out  = mem [rd_add] ;

endmodule
