`timescale 1 ns/10 ps
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%% Project Name : Asynchronous FIFO Design                                                       %%
//-----%% File Name    : fifo.v                                                                         %%
//-----%% Author       : CDAC Bangalore                                                                 %%
//---- %%                                                                                               %%
//-----%% Description  : In this design,we are passing the data from write clock domain to read clock   %%
//-----%%                domain. Two operations are supported, PUSH and POP.Whenever i_wr_en is logic   %%
//-----%%                HIGH, PUSH operation is performed on i_wr_data. Also,whenever i_rd_en is       %%
//-----%%                logic HIGH, POP operation is performed and data will be available in o_rd_data.%%
//-----%%                FULL (o_full) and EMPTY(o_empty) flags are generated to indicate the           %%
//-----%%                status of the FIFO.                                                            %%
//-----%%                In this module fifo represents a asynchronous FIFO memory with read and write  %%
//-----%%                operations synchronized to different clock domains. The module includes        %%
//-----%%                parameters for data size (DATASIZE), address size (ADDRSIZE), and memory depth %%
//-----%%                (MEM_DEPTH). It features input ports for write data (i_wr_data), write clock   %%
//-----%%                (i_wr_clk), write reset (i_wr_rst_n), write enable (i_wr_en), read clock       %%
//-----%%                (i_rd_clk), read reset (i_rd_rst_n), and read enable (i_rd_en).                %%
//-----%%                The outputs include read data (o_rd_data), full flag (o_full), and empty flag  %%
//-----%%                (o_empty).                                                                     %%
//-----%%                Within the reset_sync module, synchronized write and read reset signals        %%
//-----%%                (sync_wr_rst and sync_rd_rst) are generated using the reset_sync module. The   %%
//-----%%                write and read pointers are synchronized to the opposing clock domains using   %%
//-----%%                sync_ptr_clx modules, ensuring proper data transfer between clock domains.     %%
//-----%%                The memory itself is implemented using the fifo_mem module, which manages read %%
//-----%%                and write addresses, read and write data, and full flag logic.                 %%
//-----%%                The fifo_empty and fifo_full modules handle empty and full conditions,         %%
//-----%%                respectively, based on the synchronized read and write pointers.               %%
//-----%%                Overall, the fifo module provide asynchronized FIFO memory structure, allowing %%
//-----%%                reliable communication between different clock domains while efficiently       %%
//-----%%                managing read and write operations. The use of synchronization and proper flag %%
//-----%%                logic ensures the correct functioning of the FIFO memory in asynchronous clock %%
//-----%%                environments.                                                                  %%
//-----%% Copyright    : CDAC Bangalore                                                                 %%
//-----%%                                                                                               %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//-----%%%%%%%%%%%%%%%%% Modification / Updation History %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%%                                                                                               %%
//-----%% Date: 11-12-2023              Version: 1.0   Change Description:                              %%
//-----%%                                                                                               %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module fifo ( o_rd_data                                         ,
	      o_full                                            ,
	      o_empty                                           ,
	      i_wr_data                                         ,
	      i_wr_en                                           ,
	      i_wr_clk                                          ,
	      i_wr_rst_n                                        ,
	      i_rd_en                                           ,
	      i_rd_clk                                          ,
	      i_rd_rst_n    
            )                                                   ;

//parameter declaration
parameter DATASIZE    = 8                                       ;
parameter ADDRSIZE    = 4                                       ;
parameter MEM_DEPTH   = 16                                      ;
                             
//input declarations
input  [DATASIZE-1:0] i_wr_data                                 ;	//input write data 
input                 i_wr_clk                                  ;       //clock from write domain
input                 i_wr_rst_n                                ;	//active low reset of write domain 
input                 i_wr_en                                   ;	//enable for the write operation
input                 i_rd_clk                                  ;	//clock from read domain
input                 i_rd_rst_n                                ;	//active low reset of read domain
input                 i_rd_en                                   ;	//enable for read operation

//output declarations
output [DATASIZE-1:0] o_rd_data                                 ;	//output read data
output                o_full                                    ;	//full flag indictaing fifo is full
output                o_empty                                   ;       //empty flag indicating fifo is empty

//wire declaration
wire   [ADDRSIZE-1:0] wr_addr_s                                 ;       //wire for write address 
wire   [ADDRSIZE-1:0] rd_addr_s                                 ;	//wire for read address 
wire   [ADDRSIZE:0]   wr_ptr_s                                  ;	//wire of write pointer
wire   [ADDRSIZE:0]   rd_ptr_s                                  ;	//wire of read pointer
wire   [ADDRSIZE:0]   wr_ptr_clx                                ;	//wire for synchronized write signal
wire   [ADDRSIZE:0]   rd_ptr_clx                                ;       //wire for synchronized read  signal
wire                  sync_wr_rst                               ;       //synchronized write reset
wire                  sync_rd_rst                               ;       //synchronized read reset

//synchronous read reset
reset_sync     u_rd_reset_sync  (.i_clk(i_rd_clk)               ,
                                 .i_rst_n(i_rd_rst_n)           ,
                                 .o_sync_rst(sync_rd_rst)     
                                )                               ;

//synchronous write reset
reset_sync     u_wr_reset_sync  (.i_clk(i_wr_clk)               ,
                                 .i_rst_n(i_wr_rst_n)           ,
                                 .o_sync_rst(sync_wr_rst)
                                )                               ;
 


//read pointer synchronizing to write clock
sync_ptr_clx   #( .ADDRSIZE(ADDRSIZE))
               u_sync_rd2wr_clx (.o_ptr_clx(rd_ptr_clx)         , 
		                 .i_ptr(rd_ptr_s)               ,
 		                 .i_clk(i_wr_clk)               , 
		                 .i_rst_n(sync_wr_rst)
                                )                               ;

//write pointer synchronizing to read clock
sync_ptr_clx   #( .ADDRSIZE(ADDRSIZE))
               u_sync_wr2rd_clx (.o_ptr_clx(wr_ptr_clx)         , 
		                 .i_ptr(wr_ptr_s)               ,
		                 .i_clk(i_rd_clk)               , 
		                 .i_rst_n(sync_rd_rst) 
			        )                               ;

//memory module of fifo
fifo_mem       #( .DATASIZE(DATASIZE), .ADDRSIZE(ADDRSIZE), .MEM_DEPTH(MEM_DEPTH))
               u_fifo_mem       (.o_rd_data(o_rd_data)          , 
		                 .i_wr_data(i_wr_data)          ,
 		                 .i_wr_addr(wr_addr_s)          , 
		                 .i_rd_addr(rd_addr_s)          ,
     		                 .i_wr_en(i_wr_en)              , 
		                 .i_full(o_full)                ,
 		                 .i_wr_rst_n(sync_wr_rst)       ,
                                 .i_wr_clk(i_wr_clk)
		                )                               ;

//fifo empty logic module
fifo_empty     #( .ADDRSIZE(ADDRSIZE))
               u_fifo_empty     (.o_empty(o_empty)              ,
 		                 .o_rd_addr(rd_addr_s)          ,
 		                 .o_rd_ptr(rd_ptr_s)            , 
		                 .i_wr_ptr_clx(wr_ptr_clx)      ,
		                 .i_rd_en(i_rd_en)              ,
		                 .i_rd_clk(i_rd_clk)            ,
 	                         .i_rd_rst_n(sync_rd_rst)
		                )                               ;

//fifo full logic module
fifo_full      #( .ADDRSIZE(ADDRSIZE))
               u_fifo_full      (.o_full(o_full)                ,
		                 .o_wr_addr(wr_addr_s)          ,
		                 .o_wr_ptr(wr_ptr_s)            , 
		                 .i_rd_ptr_clx(rd_ptr_clx)      ,
		                 .i_wr_en(i_wr_en)              , 
		                 .i_wr_clk(i_wr_clk)            ,
		                 .i_wr_rst_n(sync_wr_rst)
		                )                               ;

endmodule
