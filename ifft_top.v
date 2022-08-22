/*************************************************************************/
/****        Block          :   IFFT                                  ****/
/****        Module         :   ifft_top                              ****/
/****        Project Name   :   NB-IOT LTE Transmitter                ****/
/****        Date           :   18 march  2022                        ****/
/****        Version        :   V.01                                  ****/
/*************************************************************************/
/************************ Module Definition  *****************************/ 
module ifft_top 
/************************ Module Interface   *****************************/

     (
         input   wire           clk           ,                // input clk
         input   wire           rst           ,                // input rst
		 input   wire           ifft_enable   ,                // input write enable from resource elements mapper
		 input   wire  [15:0]   in_0_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_1_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_2_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_3_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_4_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_5_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_6_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_7_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_8_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_9_real     ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_10_real    ,                // input data from resource elements mapper real
         input   wire  [15:0]   in_11_real    ,                // input data from resource elements mapper real
		 input   wire  [15:0]   in_0_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_1_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_2_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_3_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_4_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_5_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_6_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_7_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_8_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_9_imag     ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_10_imag    ,                // input data from resource elements mapper imag
         input   wire  [15:0]   in_11_imag    ,                // input data from resource elements mapper imag
		 output  wire  [15:0]   ifft_out_real ,                // output data from ifft to  interpolator real 
		 output  wire  [15:0]   ifft_out_imag ,                // output data from ifft to  interpolator imag 
		 output  wire           finish                         // output enable to  cyclic prefix
     );
	 
/************************  Module Body   *********************************/
/*Signals Decleration  */ 
wire [15:0] w_1 ;                                          // Output Data from parallel to serial real
wire [15:0] w_2 ;                                          // Output Data from parallel to serial imag
wire [15:0] w_3 ;                                          // Output Data from input_mux real
wire [15:0] w_4 ;                                          // Output Data from input_mux imag
wire [15:0] w_5 ;                                          // Output Data from control_mux real
wire [15:0] w_6 ;                                          // Output Data from control_mux imag
wire [15:0] w_7 ;                                          // Output Data from TF_Rom real
wire [15:0] w_8 ;                                          // Output Data from TF_Rom imag
wire [15:0] w_9 ;                                          // Output Data from RAM_1 real
wire [15:0] w_10 ;                                         // Output Data from RAM_1 imag
wire [15:0] w_11;                                          // Output Data from RAM_2 real
wire [15:0] w_12 ;                                         // Output Data from RAM_2 imag
wire [15:0] w_13;                                          // Output Data from RAM_3 real
wire [15:0] w_14 ;                                         // Output Data from RAM_3 imag
wire [15:0] w_15;                                          // Output Data from x real
wire [15:0] w_16 ;                                         // Output Data from x imag
wire [15:0] w_17;                                          // Output Data from + real
wire [15:0] w_18 ;                                         // Output Data from - real
wire [15:0] w_19;                                          // Output Data from + imag
wire [15:0] w_20 ;                                         // Output Data from - imag
wire [3:0]  wr_add_ram_1_2;                                // write add --- output from mux
wire [3:0]  wr_add_ctrl ;                                  // write add --- output from control unit
wire [3:0]  count ;                                        // counter value
wire [3:0]  ram_1_rd_add ;                                 // read  add ram 1--- output from control unit
wire [3:0]  ram_2_rd_add ;                                 // read  add ram 2--- output from control unit
wire [3:0]  rom_rd_add   ;                                 // read  add rom  --- output from control unit
wire [2:0]  ram_3_rd_add ;                                 // read  add ram 3--- output from control unit
wire [2:0]  ram_3_wr_add ;                                 // write add ram 3--- output from control unit
wire        shift ;                                        // shift P2s 
wire        sel ;                                          // write addres in ram 1&2 = 1 for counter output
wire        ctrl ;                                         // 1 for multiplier result
wire        count_en ;                                     // counter enable 
wire        wr_enable_ram_3  ;                             // write enable for ram 3
wire        wr_enable_ram_1_2;                             // write enable for ram 1&2
wire        i_o_ctrl ;                                     // 1 for mapper input
/*************************************************   Control Unit   ********************************************************/
ifft_controller  control_unit
     (
         .clk               (clk) ,
         .rst               (rst) ,
         .enable            (ifft_enable) ,
		 .count             (count) ,
         .wr_enable_ram_3   (wr_enable_ram_3) ,
         .wr_enable_ram_1_2 (wr_enable_ram_1_2) ,
         .i_o_ctrl          (i_o_ctrl) ,      //phase(a) //1
		 .ctrl              (ctrl) ,
         .shift             (shift) ,
		 .sel               (sel) ,           //phase(a) //1 write address mux
		 .count_en          (count_en) ,      //phase(a) //1
		 .done              (finish) ,      
		 .ram_1_rd_add      (ram_1_rd_add) ,
         .ram_2_rd_add      (ram_2_rd_add) ,
		 .ram_3_rd_add      (ram_3_rd_add) ,
		 .ram_1_2_wr_add    (wr_add_ctrl) ,
		 .ram_3_wr_add      (ram_3_wr_add) ,
		 .rom_rd_add        (rom_rd_add) 
     );
/*********************************************  Butterfly  Unit    ********************************************************/
ifft_add_sub   butterfly_real 
     (
         .op_1    (w_9)   ,     /* RAM-1 Output       */
         .op_2    (w_11)  ,     /* RAM-2 Output       */
		 .sum_out (w_17)  ,     /* Addition    Result */
		 .sub_out (w_18)        /* Subtraction Result */
     );
ifft_add_sub   butterfly_imag 
     (
         .op_1    (w_10)  ,     /* RAM-1 Output       */
         .op_2    (w_12)  ,     /* RAM-2 Output       */
		 .sum_out (w_19)  ,     /* Addition    Result */
		 .sub_out (w_20)        /* Subtraction Result */
     );
/*********************************************  Complex Multipiler    ******************************************************/
ifft_complex_multipier  complex_multipier
     (
         .op_1_real   (w_13),
         .op_1_imag   (w_14),
         .op_2_real   (w_7),		 
         .op_2_imag   (w_8),
         .result_real (w_15),
         .result_imag (w_16)
     );
/**************************************************** ROM  *****************************************************************/
ifft_tf_rom  rom_tf
     (
         .rd_add        (rom_rd_add),
		 .data_out_imag (w_8),
		 .data_out_real (w_7)

     );
/**************************************************** RAM -1  ***************************************************************/
ifft_ram   
    #( 
	     .DATA_WIDTH(16) , 
	     .ADDR_WIDTH(4 ) , 
	     .DEPTH     (16) 
     )
	 ram_1_real
     (
         .clk       (clk)   ,
         .rst       (rst)   ,
         .wr_en     (wr_enable_ram_1_2)   ,
         .rd_add    (ram_1_rd_add)   ,
         .wr_add    (wr_add_ram_1_2)   ,
		 .data_in   (w_3)   ,
		 .data_out  (w_9)   
     );
ifft_ram   
    #( 
	     .DATA_WIDTH(16) , 
	     .ADDR_WIDTH(4 ) , 
	     .DEPTH     (16) 
     )
	 ram_1_imag
     (
         .clk       (clk)   ,
         .rst       (rst)   ,
         .wr_en     (wr_enable_ram_1_2)   ,
         .rd_add    (ram_1_rd_add)   ,
         .wr_add    (wr_add_ram_1_2)   ,
		 .data_in   (w_4)   ,
		 .data_out  (w_10)   
     );
/**************************************************** RAM -2  ***************************************************************/
ifft_ram   
    #( 
	     .DATA_WIDTH(16) , 
	     .ADDR_WIDTH(4 ) , 
	     .DEPTH     (16) 
     )
	 ram_2_real
     (
         .clk       (clk)   ,
         .rst       (rst)   ,
         .wr_en     (wr_enable_ram_1_2)   ,
         .rd_add    (ram_2_rd_add)   ,
         .wr_add    (wr_add_ram_1_2)   ,
		 .data_in   (w_3)   ,
		 .data_out  (w_11)   
     );
ifft_ram   
    #( 
	     .DATA_WIDTH(16) , 
	     .ADDR_WIDTH(4 ) , 
	     .DEPTH     (16) 
     )
	 ram_2_imag
     (
         .clk       (clk)   ,
         .rst       (rst)   ,
         .wr_en     (wr_enable_ram_1_2)   ,
         .rd_add    (ram_2_rd_add)   ,
         .wr_add    (wr_add_ram_1_2)   ,
		 .data_in   (w_4)   ,
		 .data_out  (w_12)   
     );
/**************************************************** RAM -3  ***************************************************************/
ifft_ram   
    #( 
	     .DATA_WIDTH(16) , 
	     .ADDR_WIDTH(3 ) , 
	     .DEPTH     (16) 
     )
	 ram_3_real
     (
         .clk       (clk)   ,
         .rst       (rst)   ,
         .wr_en     (wr_enable_ram_3)   ,
         .rd_add    (ram_3_rd_add)   ,
         .wr_add    (ram_3_wr_add)   ,
		 .data_in   (w_18)   ,
		 .data_out  (w_13)   
     );
ifft_ram   
    #( 
	     .DATA_WIDTH(16) , 
	     .ADDR_WIDTH(3 ) , 
	     .DEPTH     (16) 
     )
	 ram_3_imag
     (
         .clk       (clk)   ,
         .rst       (rst)   ,
         .wr_en     (wr_enable_ram_3)   ,
         .rd_add    (ram_3_rd_add)   ,
         .wr_add    (ram_3_wr_add)   ,
		 .data_in   (w_20)   ,
		 .data_out  (w_14)   
     );
/*********************************************** Parallel To Serial ******************************************************/
ifft_p2s  p2s_real
     (
	     .clk      (clk),
	     .rst      (rst),
	     .wr_en    (ifft_enable),
	     .shift    (shift),
		 .count    (count),   
         .in_0     (in_0_real ),
         .in_1     (in_1_real ),
         .in_2     (in_2_real ),
         .in_3     (in_3_real ),
         .in_4     (in_4_real ),
         .in_5     (in_5_real ),
         .in_6     (in_6_real ),
         .in_7     (in_7_real ),
         .in_8     (in_8_real ),
         .in_9     (in_9_real ),
         .in_10    (in_10_real),
         .in_11    (in_11_real),
		 .data_out (w_1)    
     );
ifft_p2s  p2s_imag
     (
	     .clk      (clk),
	     .rst      (rst),
	     .wr_en    (ifft_enable),
	     .shift    (shift),
		 .count    (count),   
         .in_0     (in_0_imag ),
         .in_1     (in_1_imag ),
         .in_2     (in_2_imag ),
         .in_3     (in_3_imag ),
         .in_4     (in_4_imag ),
         .in_5     (in_5_imag ),
         .in_6     (in_6_imag ),
         .in_7     (in_7_imag ),
         .in_8     (in_8_imag ),
         .in_9     (in_9_imag ),
         .in_10    (in_10_imag),
         .in_11    (in_11_imag),
		 .data_out (w_2)    
     );
/*************************************************     Counter      *******************************************************/
counter_4_bit  counter_phase_a
     (
         .clk      (clk)         ,
         .rst      (rst)         ,
         .enable   (count_en)    ,
		 .count    (count)   
     );
/************************************************ Write Address MUX   ******************************************************/
ifft_mux_add   wr_address_mux_ram_1
     (
         .in_0 (wr_add_ctrl) ,
         .in_1 (count) ,
         .sel  (sel) ,
         .out  (wr_add_ram_1_2)
     );
/************************************************       Input MUX   R-E-Mapper  ********************************************/
ifft_mux  input_mux_real
     (
         .in_0 (w_5),
         .in_1 (w_1),
         .sel  (i_o_ctrl),
         .out  (w_3)
     );
ifft_mux  input_mux_imag
     (
         .in_0 (w_6),
         .in_1 (w_2),
         .sel  (i_o_ctrl),
         .out  (w_4)
     );	 
/************************************************      control MUX   ram-3   ***********************************************/
ifft_mux  ctrl_mux_real
     (
         .in_0 (w_17),
         .in_1 (w_15),
         .sel  (ctrl),
         .out  (w_5)
     );
ifft_mux  ctrl_mux_imag
     (
         .in_0 (w_19),
         .in_1 (w_16),
         .sel  (ctrl),
         .out  (w_6)
     );	 
assign ifft_out_real = w_3 ;                                          // Input to ram 1&2 real
assign ifft_out_imag = w_4 ;                                          // Input to ram 1&2 imag

/**********************************************************  Module End  ***************************************************/
endmodule





 
 
 
 