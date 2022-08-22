/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   control unit                          ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/

/************************ Module Definition  *****************************/ 
module ifft_controller  

/************************ Module Interface   *****************************/
     (
         input  wire       clk               ,
         input  wire       rst               ,
         input  wire       enable            ,
		 input wire [3:0]  count             ,
         output reg        wr_enable_ram_3   ,
         output reg        wr_enable_ram_1_2 ,
         output reg        i_o_ctrl          ,      //phase(a) //1
		 output reg        ctrl              ,
         output reg        shift             ,
		 output reg        sel               ,      //phase(a) //1 
		 output reg        count_en          ,      //phase(a) //1
		 output reg        done              ,    
		 output reg [3:0]  ram_1_rd_add      ,
         output reg [3:0]  ram_2_rd_add      ,
		 output reg [2:0]  ram_3_rd_add      ,
		 output reg [3:0]  ram_1_2_wr_add    ,
		 output reg [2:0]  ram_3_wr_add      ,
		 output reg [3:0]  rom_rd_add        
     );
	 
/************************  Module Body   *********************************/
/*  States Encoding  */ 
localparam  [6:0] idle            = 7'b0000000,
                  phase_a         = 7'b0000001,
                  phase_b_1       = 7'b0000011,
                  phase_b_2       = 7'b0000010,
                  phase_b_3       = 7'b0000110,
                  phase_b_4       = 7'b0000111,
                  phase_b_5       = 7'b0000101,
                  phase_b_6       = 7'b0000100,
                  phase_b_7       = 7'b0001100,
                  phase_b_8       = 7'b0001101,
                  phase_b_9       = 7'b0001111,
                  phase_b_10      = 7'b0001110,
                  phase_b_11      = 7'b0001010,
                  phase_b_12      = 7'b0001011,
                  phase_b_13      = 7'b0001001,
                  phase_b_14      = 7'b0001000,
                  phase_b_15      = 7'b0011000,
                  phase_b_16      = 7'b0011001,
                  phase_c_1       = 7'b0011011,
                  phase_c_2       = 7'b0011010,
                  phase_c_3       = 7'b0011110,
                  phase_c_4       = 7'b0011111,
                  phase_c_5       = 7'b0011101,
                  phase_c_6       = 7'b0011100,
                  phase_c_7       = 7'b0010100,
                  phase_c_8       = 7'b0010101,
                  phase_c_9       = 7'b0010111,
                  phase_c_10      = 7'b0010110,
                  phase_c_11      = 7'b0010010,
                  phase_c_12      = 7'b0010011,
                  phase_c_13      = 7'b0010001,
                  phase_c_14      = 7'b0010000,
                  phase_c_15      = 7'b0110000,
                  phase_c_16      = 7'b0110001,
                  phase_d_1       = 7'b0110011,
                  phase_d_2       = 7'b0110010,
                  phase_d_3       = 7'b0110110,
                  phase_d_4       = 7'b0110111,
                  phase_d_5       = 7'b0110101,
                  phase_d_6       = 7'b0110100,
                  phase_d_7       = 7'b0111100,
                  phase_d_8       = 7'b0111101,
                  phase_d_9       = 7'b0111111,
                  phase_d_10      = 7'b0111110,
                  phase_d_11      = 7'b0111010,
                  phase_d_12      = 7'b0111011,
                  phase_d_13      = 7'b0111001,
                  phase_d_14      = 7'b0111000,
                  phase_d_15      = 7'b0101000,
                  phase_d_16      = 7'b0101001,
                  phase_e_1       = 7'b0101011,
                  phase_e_2       = 7'b0101010,
                  phase_e_3       = 7'b0101110,
                  phase_e_4       = 7'b0101111,
                  phase_e_5       = 7'b0101101,
                  phase_e_6       = 7'b0101100,
                  phase_e_7       = 7'b0100100,
                  phase_e_8       = 7'b0100101,
                  phase_e_9       = 7'b0100111,
                  phase_e_10      = 7'b0100110,
                  phase_e_11      = 7'b0100010,
                  phase_e_12      = 7'b0100011,
                  phase_e_13      = 7'b0100001,
                  phase_e_14      = 7'b0100000,
                  phase_e_15      = 7'b1100000,
                  phase_e_16      = 7'b1100001;	

				  
reg         [6:0] current_state , next_state ;
/* Next State Transition */ 
always @(posedge clk or negedge rst)
     begin
	     if(!rst)
	         begin			 
			     current_state <= idle ; 	
			 end	    
	     else 
		     begin
			     current_state <= next_state ; 	
			 end 			 
	 end	 
 
/* Output Logic */
always @(*)
     begin
         wr_enable_ram_3   = 1'b0 ;
         wr_enable_ram_1_2 = 1'b0 ;
         i_o_ctrl          = 1'b0 ;          //phase(a) = 1   -- for input .
		 ctrl              = 1'b0 ;          //ram-3 -or- bf  -- 1 for ram 3 .
         shift             = 1'b0 ;
         count_en          = 1'b0 ;
		 sel               = 1'b0 ;          //ram 1&2 add from counter or controller = 1 for counter phase(a).
		 done              = 1'b0 ;          //phase(f) = 1  . 
		 ram_1_rd_add      = 4'b0000 ;
         ram_2_rd_add      = 4'b0000 ;
		 ram_3_rd_add      = 3'b000  ;
		 ram_1_2_wr_add    = 4'b0000 ;
		 ram_3_wr_add      = 3'b000  ;
		 rom_rd_add        = 4'b0000  ;
	     case(current_state)
		     idle : 
			         begin
					     wr_enable_ram_3   = 1'b0 ;
					     wr_enable_ram_1_2 = 1'b0 ;
					     i_o_ctrl          = 1'b0 ;   
					     ctrl              = 1'b0 ;   
					     shift             = 1'b0 ;
					     count_en          = 1'b0 ;
					     sel               = 1'b0 ;   
					     done              = 1'b0 ;   
					     ram_1_rd_add      = 4'b0000 ;
					     ram_2_rd_add      = 4'b0000 ;
					     ram_3_rd_add      = 3'b000  ;
					     ram_1_2_wr_add    = 4'b0000 ;
					     ram_3_wr_add      = 3'b000  ;
						 rom_rd_add        = 4'b0000  ;
					 end
		     phase_a : 
			         begin
					     wr_enable_ram_1_2 = 1'b1 ;
					     i_o_ctrl          = 1'b1 ;   
					     shift             = 1'b1 ;
					     count_en          = 1'b1 ;
					     sel               = 1'b1 ;    
					 end					 
             phase_b_1 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0000 ;
                         ram_2_rd_add      = 4'b1000 ;
                         ram_1_2_wr_add    = 4'b0000 ;
                         ram_3_wr_add      = 3'b000  ;
					 end
             phase_b_2 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0001 ;
                         ram_2_rd_add      = 4'b1001 ;
                         ram_1_2_wr_add    = 4'b0001 ;
                         ram_3_wr_add      = 3'b001  ;
					 end
             phase_b_3 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0010 ;
						 ram_2_rd_add      = 4'b1010 ;
						 ram_1_2_wr_add    = 4'b0010 ;
						 ram_3_wr_add      = 3'b010  ;
					 end
             phase_b_4 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0011 ;
						 ram_2_rd_add      = 4'b1011 ;
						 ram_1_2_wr_add    = 4'b0011 ;
						 ram_3_wr_add      = 3'b011  ;
					 end
             phase_b_5 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0100 ;
						 ram_2_rd_add      = 4'b1100 ;
						 ram_1_2_wr_add    = 4'b1000 ;
						 ram_3_wr_add      = 3'b100  ;
					 end
             phase_b_6 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0101 ;
						 ram_2_rd_add      = 4'b1101 ;
						 ram_1_2_wr_add    = 4'b1001 ;
						 ram_3_wr_add      = 3'b101  ;					    
					 end
             phase_b_7 : 
			         begin						    
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0110 ;
						 ram_2_rd_add      = 4'b1110 ;
						 ram_1_2_wr_add    = 4'b1010 ;
						 ram_3_wr_add      = 3'b110  ;					  		 
					 end
             phase_b_8 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0111 ;
						 ram_2_rd_add      = 4'b1111 ;
						 ram_1_2_wr_add    = 4'b1011 ;
						 ram_3_wr_add      = 3'b111  ;	
					 end
             phase_b_9 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000  ;
						 ram_1_2_wr_add    = 4'b0100 ;
						 rom_rd_add        = 4'b0000  ;
					 end
             phase_b_10 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001  ;
						 ram_1_2_wr_add    = 4'b0101 ;
						 rom_rd_add        = 3'b001  ;
					 end
             phase_b_11 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b010  ;
						 ram_1_2_wr_add    = 4'b0110 ;
						 rom_rd_add        = 4'b0010  ;
					 end
             phase_b_12 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b011  ;
						 ram_1_2_wr_add    = 4'b0111 ;
						 rom_rd_add        = 4'b0011  ;
					 end
             phase_b_13 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b100  ;
						 ram_1_2_wr_add    = 4'b1100 ;
						 rom_rd_add        = 4'b0100  ;
					 end
             phase_b_14 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b101  ;
						 ram_1_2_wr_add    = 4'b1101 ;
						 rom_rd_add        = 4'b0101  ;				    
					 end
             phase_b_15 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b110  ;
						 ram_1_2_wr_add    = 4'b1110 ;
						 rom_rd_add        = 4'b0110  ;	
					 end
             phase_b_16 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b111  ;
						 ram_1_2_wr_add    = 4'b1111 ;
						 rom_rd_add        = 4'b0111  ;	
					 end
             phase_c_1 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0000 ;
                         ram_2_rd_add      = 4'b1000 ;
                         ram_1_2_wr_add    = 4'b0000 ;
                         ram_3_wr_add      = 3'b000  ;					     
					 end
             phase_c_2 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0001 ;
                         ram_2_rd_add      = 4'b1001 ;
                         ram_1_2_wr_add    = 4'b0001 ;
                         ram_3_wr_add      = 3'b001  ;						    
					 end
             phase_c_3 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0010 ;
                         ram_2_rd_add      = 4'b1010 ;
                         ram_1_2_wr_add    = 4'b1000 ;
                         ram_3_wr_add      = 3'b010  ;						    
					 end
             phase_c_4 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0011 ;
                         ram_2_rd_add      = 4'b1011 ;
                         ram_1_2_wr_add    = 4'b1001 ;
                         ram_3_wr_add      = 3'b011  ;
					 end
             phase_c_5 :                                           
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000  ;
						 ram_1_2_wr_add    = 4'b0010 ;
						 rom_rd_add        = 4'b1000  ;						    
					 end
             phase_c_6 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001  ;
						 ram_1_2_wr_add    = 4'b0011 ;
						 rom_rd_add        = 4'b1001  ;						    
					 end
             phase_c_7 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b010  ;
						 ram_1_2_wr_add    = 4'b1010 ;
						 rom_rd_add        = 4'b1010  ;						    
					 end
             phase_c_8 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b011  ;
						 ram_1_2_wr_add    = 4'b1011 ;
						 rom_rd_add        = 4'b1011  ;						    
					 end
             phase_c_9 :                                   
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0100 ;
                         ram_2_rd_add      = 4'b1100 ;
                         ram_1_2_wr_add    = 4'b0100 ;
                         ram_3_wr_add      = 3'b000  ;					    
					 end
             phase_c_10 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0101 ;
                         ram_2_rd_add      = 4'b1101 ;
                         ram_1_2_wr_add    = 4'b0101 ;
                         ram_3_wr_add      = 3'b001  ;						    
					 end
             phase_c_11 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0110 ;
                         ram_2_rd_add      = 4'b1110 ;
                         ram_1_2_wr_add    = 4'b1100 ;
                         ram_3_wr_add      = 3'b010  ;						    
					 end
             phase_c_12 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0111 ;
                         ram_2_rd_add      = 4'b1111 ;
                         ram_1_2_wr_add    = 4'b1101 ;
                         ram_3_wr_add      = 3'b011  ;						    
					 end
             phase_c_13 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000  ;
						 ram_1_2_wr_add    = 4'b0110 ;
						 rom_rd_add        = 4'b1000  ;							    
					 end
             phase_c_14 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001  ;
						 ram_1_2_wr_add    = 4'b0111 ;
						 rom_rd_add        = 4'b1001  ;						    
					 end
             phase_c_15 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b010  ;
						 ram_1_2_wr_add    = 4'b1110 ;
						 rom_rd_add        = 4'b1010  ;						    
					 end
             phase_c_16 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b011  ;
						 ram_1_2_wr_add    = 4'b1111 ;
						 rom_rd_add        = 4'b1011  ;						    
					 end
             phase_d_1 :                                        
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0000 ;
                         ram_2_rd_add      = 4'b1000 ;
                         ram_1_2_wr_add    = 4'b0000 ;
                         ram_3_wr_add      = 3'b000  ;
					 end
             phase_d_2 : 
			         begin
                         wr_enable_ram_3   = 1'b1 ;
                         wr_enable_ram_1_2 = 1'b1 ;  
                         ram_1_rd_add      = 4'b0001 ;
                         ram_2_rd_add      = 4'b1001 ;
                         ram_1_2_wr_add    = 4'b1000 ;
                         ram_3_wr_add      = 3'b001  ;					    
					 end
             phase_d_3 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000  ;
						 ram_1_2_wr_add    = 4'b0001;
						 rom_rd_add        = 4'b1100  ;						    
					 end
             phase_d_4 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001  ;
						 ram_1_2_wr_add    = 4'b1001 ;
						 rom_rd_add        = 4'b1101  ;						    
					 end
             phase_d_5 :                                          
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0010 ;
						 ram_2_rd_add      = 4'b1010 ;
						 ram_1_2_wr_add    = 4'b0010 ;
						 ram_3_wr_add      = 3'b000  ;	 
					 end
             phase_d_6 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0011 ;
						 ram_2_rd_add      = 4'b1011 ;
						 ram_1_2_wr_add    = 4'b1010 ;
						 ram_3_wr_add      = 3'b001  ;						    					  		 
					 end
             phase_d_7 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 ram_1_2_wr_add    = 4'b0011 ;
						 rom_rd_add        = 4'b1100  ;						    
					 end
             phase_d_8 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001 ;
						 ram_1_2_wr_add    = 4'b1011 ;
						 rom_rd_add        = 4'b1101  ;						    					  		 
					 end
             phase_d_9 :                                              
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0100 ;
						 ram_2_rd_add      = 4'b1100 ;
						 ram_1_2_wr_add    = 4'b0100 ;
						 ram_3_wr_add      = 3'b000  ;						    
					 end
             phase_d_10 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0101 ;
						 ram_2_rd_add      = 4'b1101 ;
						 ram_1_2_wr_add    = 4'b1100 ;
						 ram_3_wr_add      = 3'b001  ;					    
					 end
             phase_d_11 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 ram_1_2_wr_add    = 4'b0101 ;
						 rom_rd_add        = 4'b1100  ;						    
					 end
             phase_d_12 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001 ;
						 ram_1_2_wr_add    = 4'b1101 ;
						 rom_rd_add        = 4'b1101  ;	
					 end
             phase_d_13 :                                          
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0110 ;
						 ram_2_rd_add      = 4'b1110 ;
						 ram_1_2_wr_add    = 4'b0110 ;
						 ram_3_wr_add      = 3'b000  ;						    					  		 
					 end
             phase_d_14 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 wr_enable_ram_1_2 = 1'b1 ;  
						 ram_1_rd_add      = 4'b0111 ;
						 ram_2_rd_add      = 4'b1111 ;
						 ram_1_2_wr_add    = 4'b1110 ;
						 ram_3_wr_add      = 3'b001  ;						    					  		 
					 end
             phase_d_15 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 ram_1_2_wr_add    = 4'b0111 ;
						 rom_rd_add        = 4'b1100  ;						    
					  		 
					 end
             phase_d_16 : 
			         begin
						 wr_enable_ram_1_2 = 1'b1 ;
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b001 ;
						 ram_1_2_wr_add    = 4'b1111 ;
						 rom_rd_add        = 4'b1101  ;						    					  		 
					 end
             phase_e_1 :                                                    /////////////////////////////////                        
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0000 ;
						 ram_2_rd_add      = 4'b1000 ;
						 ram_3_wr_add      = 3'b000  ;
						 done              = 1'b1 ;						 
					 end
             phase_e_2 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_3 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0001 ;
						 ram_2_rd_add      = 4'b1001 ;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_4 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_5 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0010 ;
						 ram_2_rd_add      = 4'b1010 ;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_6 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_7 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0011 ;
						 ram_2_rd_add      = 4'b1011;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_8 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_9 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0100 ;
						 ram_2_rd_add      = 4'b1100 ;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_10 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_11 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0101 ;
						 ram_2_rd_add      = 4'b1101 ;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_12 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_13 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0110 ;
						 ram_2_rd_add      = 4'b1110 ;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_14 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;	
						 done              = 1'b1 ;						 
					 end
             phase_e_15 : 
			         begin
					     wr_enable_ram_3   = 1'b1 ;
						 ram_1_rd_add      = 4'b0111 ;
						 ram_2_rd_add      = 4'b1111 ;
						 ram_3_wr_add      = 3'b000  ;	
						 done              = 1'b1 ;			
						 done              = 1'b1 ;						 
					 end
             phase_e_16 : 
			         begin
						 ctrl              = 1'b1 ;    
						 ram_3_rd_add      = 3'b000 ;
						 rom_rd_add        = 4'b1110  ;
						 done              = 1'b1 ;						 
					 end				 
             default :
			 	     begin
					     wr_enable_ram_3   = 1'b0 ;
					     wr_enable_ram_1_2 = 1'b0 ;
					     i_o_ctrl          = 1'b0 ;   
					     ctrl              = 1'b0 ;   
					     shift             = 1'b0 ;
					     count_en          = 1'b0 ;
					     sel               = 1'b0 ;   
					     done              = 1'b0 ;   
					     ram_1_rd_add      = 4'b0000 ;
					     ram_2_rd_add      = 4'b0000 ;
					     ram_3_rd_add      = 3'b000  ;
					     ram_1_2_wr_add    = 4'b0000 ;
					     ram_3_wr_add      = 3'b000  ;
					     rom_rd_add        = 3'b000  ;
					 end						 
		 endcase
     end		 
/* Next State Logic */ 	
always @(*)
     begin
	     case(current_state)
		     idle : 
			         begin
					     if (enable==1'b1)
					         begin
					 	  	     next_state = phase_a ;			 							 
					         end
					     else 
						     begin
							     next_state = idle ;							 							 
							 end					 
					 end
		     phase_a : 
			         begin
					     if (count == 4'b1111)
					         begin
					 	  	     next_state = phase_b_1 ;			 	  					 
					         end
					     else 
						     begin
							     next_state = phase_a ;							 							 
							 end					 
					 end					 
             phase_b_1 : 
			         begin
					    
					 	 next_state = phase_b_2 ;			 							 
					  		 
					 end
             phase_b_2 : 
			         begin
					    
					 	 next_state = phase_b_3 ;			 							 
					  		 
					 end
             phase_b_3 : 
			         begin
					    
					 	 next_state = phase_b_4 ;			 							 
					  		 
					 end
             phase_b_4 : 
			         begin
					    
					 	 next_state = phase_b_5 ;			 							 
					  		 
					 end
             phase_b_5 : 
			         begin
					    
					 	 next_state = phase_b_6 ;			 							 
					  		 
					 end
             phase_b_6 : 
			         begin
					    
					 	 next_state = phase_b_7 ;			 							 
					  		 
					 end
             phase_b_7 : 
			         begin
					    
					 	 next_state = phase_b_8 ;			 							 
					  		 
					 end
             phase_b_8 : 
			         begin
					    
					 	 next_state = phase_b_9 ;			 							 
					  		 
					 end
             phase_b_9 : 
			         begin
					    
					 	 next_state = phase_b_10 ;			 							 
					  		 
					 end
             phase_b_10 : 
			         begin
					    
					 	 next_state = phase_b_11 ;			 							 
					  		 
					 end
             phase_b_11 : 
			         begin
					    
					 	 next_state = phase_b_12 ;			 							 
					  		 
					 end
             phase_b_12 : 
			         begin
					    
					 	 next_state = phase_b_13 ;			 							 
					  		 
					 end
             phase_b_13 : 
			         begin
					    
					 	 next_state = phase_b_14 ;			 							 
					  		 
					 end
             phase_b_14 : 
			         begin
					    
					 	 next_state = phase_b_15 ;			 							 
					  		 
					 end
             phase_b_15 : 
			         begin
					    
					 	 next_state = phase_b_16 ;			 							 
					  		 
					 end
             phase_b_16 : 
			         begin
					    
					 	 next_state = phase_c_1 ;		                 							 
					  		 
					 end
             phase_c_1 : 
			         begin
					    
					 	 next_state = phase_c_2 ;			 							 
					  		 
					 end
             phase_c_2 : 
			         begin
					    
					 	 next_state = phase_c_3 ;			 							 
					  		 
					 end
             phase_c_3 : 
			         begin
					    
					 	 next_state = phase_c_4 ;			 							 
					  		 
					 end
             phase_c_4 : 
			         begin
					    
					 	 next_state = phase_c_5 ;			 							 
					  		 
					 end
             phase_c_5 : 
			         begin
					    
					 	 next_state = phase_c_6 ;			 							 
					  		 
					 end
             phase_c_6 : 
			         begin
					    
					 	 next_state = phase_c_7 ;			 							 
					  		 
					 end
             phase_c_7 : 
			         begin
					    
					 	 next_state = phase_c_8 ;			 							 
					  		 
					 end
             phase_c_8 : 
			         begin
					    
					 	 next_state = phase_c_9 ;			 							 
					  		 
					 end
             phase_c_9 : 
			         begin
					    
					 	 next_state = phase_c_10 ;			 							 
					  		 
					 end
             phase_c_10 : 
			         begin
					    
					 	 next_state = phase_c_11 ;			 							 
					  		 
					 end
             phase_c_11 : 
			         begin
					    
					 	 next_state = phase_c_12 ;			 							 
					  		 
					 end
             phase_c_12 : 
			         begin
					    
					 	 next_state = phase_c_13 ;			 							 
					  		 
					 end
             phase_c_13 : 
			         begin
					    
					 	 next_state = phase_c_14 ;			 							 
					  		 
					 end
             phase_c_14 : 
			         begin
					    
					 	 next_state = phase_c_15 ;			 							 
					  		 
					 end
             phase_c_15 : 
			         begin
					    
					 	 next_state = phase_c_16 ;			 							 
					  		 
					 end
             phase_c_16 : 
			         begin
					    
					 	 next_state = phase_d_1 ;			 							 
					  		 
					 end
             phase_d_1 : 
			         begin
					    
					 	 next_state = phase_d_2 ;			 							 
					  		 
					 end
             phase_d_2 : 
			         begin
					    
					 	 next_state = phase_d_3 ;			 							 
					  		 
					 end
             phase_d_3 : 
			         begin
					    
					 	 next_state = phase_d_4 ;			 							 
					  		 
					 end
             phase_d_4 : 
			         begin
					    
					 	 next_state = phase_d_5 ;			 							 
					  		 
					 end
             phase_d_5 : 
			         begin
					    
					 	 next_state = phase_d_6 ;			 							 
					  		 
					 end
             phase_d_6 : 
			         begin
					    
					 	 next_state = phase_d_7 ;			 							 
					  		 
					 end
             phase_d_7 : 
			         begin
					    
					 	 next_state = phase_d_8 ;			 							 
					  		 
					 end
             phase_d_8 : 
			         begin
					    
					 	 next_state = phase_d_9 ;			 							 
					  		 
					 end
             phase_d_9 : 
			         begin
					    
					 	 next_state = phase_d_10 ;			 							 
					  		 
					 end
             phase_d_10 : 
			         begin
					    
					 	 next_state = phase_d_11 ;			 							 
					  		 
					 end
             phase_d_11 : 
			         begin
					    
					 	 next_state = phase_d_12 ;			 							 
					  		 
					 end
             phase_d_12 : 
			         begin
					    
					 	 next_state = phase_d_13 ;			 							 
					  		 
					 end
             phase_d_13 : 
			         begin
					    
					 	 next_state = phase_d_14 ;			 							 
					  		 
					 end
             phase_d_14 : 
			         begin
					    
					 	 next_state = phase_d_15 ;			 							 
					  		 
					 end
             phase_d_15 : 
			         begin
					    
					 	 next_state = phase_d_16 ;			 							 
					  		 
					 end
             phase_d_16 : 
			         begin
					    
					 	 next_state = phase_e_1 ;			 							 
					  		 
					 end
             phase_e_1 : 
			         begin
					    
					 	 next_state = phase_e_2 ;			 							 
					  		 
					 end
             phase_e_2 : 
			         begin
					    
					 	 next_state = phase_e_3 ;			 							 
					  		 
					 end
             phase_e_3 : 
			         begin
					    
					 	 next_state = phase_e_4 ;			 							 
					  		 
					 end
             phase_e_4 : 
			         begin
					    
					 	 next_state = phase_e_5 ;			 							 
					  		 
					 end
             phase_e_5 : 
			         begin
					    
					 	 next_state = phase_e_6 ;			 							 
					  		 
					 end
             phase_e_6 : 
			         begin
					    
					 	 next_state = phase_e_7 ;			 							 
					  		 
					 end
             phase_e_7 : 
			         begin
					    
					 	 next_state = phase_e_8 ;			 							 
					  		 
					 end
             phase_e_8 : 
			         begin
					    
					 	 next_state = phase_e_9 ;			 							 
					  		 
					 end
             phase_e_9 : 
			         begin
					    
					 	 next_state = phase_e_10 ;			 							 
					  		 
					 end
             phase_e_10 : 
			         begin
					    
					 	 next_state = phase_e_11 ;			 							 
					  		 
					 end
             phase_e_11 : 
			         begin
					    
					 	 next_state = phase_e_12 ;			 							 
					  		 
					 end
             phase_e_12 : 
			         begin
					    
					 	 next_state = phase_e_13 ;			 							 
					  		 
					 end
             phase_e_13 : 
			         begin
					    
					 	 next_state = phase_e_14 ;			 							 
					  		 
					 end
             phase_e_14 : 
			         begin
					    
					 	 next_state = phase_e_15 ;			 							 
					  		 
					 end
             phase_e_15 : 
			         begin
					    
					 	 next_state = phase_e_16 ;			 							 
					  		 
					 end
             phase_e_16 : 
			         begin
					    
					 	 next_state = idle ;			 							 
					  		 
					 end					 
             default :
			 	     begin
				         next_state = idle ;			 							 
					 end						 
		 endcase
	 end			 
/****************************  Module End  ****************************/
endmodule