`timescale 1 ns/10 ps
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%% Project Name : FIFO Full Design                                                            %%
//-----%% File Name    : fifo_full.v                                                                 %%
//-----%% Author       : CDAC Bangalore                                                              %%
//-----%%                                                                                            %%
//-----%% Description  : In this module we are determinining whether a FIFO memory is full and       %%
//-----%%                provides relevant outputs, including the full flag (o_full), write address  %%
//-----%%                (o_wr_addr), and write pointer (o_wr_ptr). The module operates within a     %% 
//-----%%                write clock domain with an active-low reset signal (i_wr_rst_n), write      %%
//-----%%                clock signal (i_wr_clk), write enable signal (i_wr_en), and a synchronized  %%
//-----%%                read pointer with respect to the write clock (i_rd_ptr_clx).                %%
//-----%%                The module employs a binary write pointer (wr_bin_r), a binary write        %%
//-----%%                pointer for the next state (wr_bin_next_s), and a write pointer in Gray     %%
//-----%%                coding style for the next state (wr_gray_next_s). The write pointer and full%%
//-----%%                flag are asynchronously asserted based on the write clock and the active    %%
//-----%%                low reset. The full flag is determined by comparing the next-state write    %%
//-----%%                pointer in Gray coding style with the synchronized read pointer.            %%
//-----%%                The write pointer is incremented based on the write enable signal and the   %%
//-----%%                inverse of the full flag. The binary write pointer is converted to Gray     %%
//-----%%                coding style to suit the memory addressing scheme.                          %%
//-----%%                The module asserts the full flag (o_full) based on the active-low reset or  %%
//-----%%                the calculated full signal (full_s). The write address (o_wr_addr) is       %% 
//-----%%                derived from the binary write pointer.                                      %%
//-----%%                This module effectively manages the full condition of the FIFO memory and   %%
//-----%%                produces corresponding outputs.                                             %%
//-----%% Copyright    : CDAC Bangalore                                                              %%
//-----%%                                                                                            %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//-----%%%%%%%%%%%%%%%%% Modification / Updation History %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%%                                                                                            %%
//-----%% Date: 11-12-2023              Version: 1.0   Change Description:                           %%
//-----%%                                                                                            %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

module fifo_full ( i_wr_clk                      ,
                   i_wr_rst_n                    ,
                   i_wr_en                       ,
                   i_rd_ptr_clx                  ,
                   o_full                        ,
                   o_wr_addr                     ,
                   o_wr_ptr
                 )                               ;

// parameter declaration
parameter   ADDRSIZE = 4                         ;    // length of address

// input port declaration
input                       i_wr_clk             ;    // clock from write domain
input                       i_wr_rst_n           ;    // reset from write domain
input                       i_wr_en              ;    // write enable
input      [ADDRSIZE : 0]   i_rd_ptr_clx         ;    // synchronized read pointer wrt write clock
         
// output port declaration
output reg                  o_full               ;    // full flag
output     [ADDRSIZE-1 : 0] o_wr_addr            ;    // write address (binary coding style)
output reg [ADDRSIZE   : 0] o_wr_ptr             ;    // write pointer (Gray coding style)


// register declaration
reg        [ADDRSIZE : 0]   wr_bin_r             ;    // write pointer(binary)
reg                         full_r               ;    // full flag reg

// wire declaration
wire       [ADDRSIZE : 0]   wr_gray_next_s       ;    // write pointer(gray coding style)
wire       [ADDRSIZE : 0]   wr_bin_next_s        ;    // write pointer(binary coding style)
wire                        full_s               ;    // full flag wire

/*---------------------------------------------------------------------------------
 Use of asynchronous active low reset to assign write pointer to gray coding style 
----------------------------------------------------------------------------------*/ 
always @(posedge i_wr_clk or negedge i_wr_rst_n )
begin
   if (!i_wr_rst_n)
   begin
      wr_bin_r  <= 5'b0                                                                      ;
      o_wr_ptr  <= 5'b0                                                                      ;
   end
   else
   begin
      wr_bin_r  <=  wr_bin_next_s                                                            ;
      o_wr_ptr  <=  wr_gray_next_s                                                           ;
   end
end

 
// Memory write-address pointer (use binary to address memory)
assign o_wr_addr      = wr_bin_r[ADDRSIZE-1:0]                                               ;

// write pointer increments depending upon the write enable and o_full signal
assign wr_bin_next_s  = {wr_bin_r + (i_wr_en & !full_r)}                                     ;

// Converting binary coding into gray coding style
assign wr_gray_next_s = (wr_bin_next_s >> 1) ^ wr_bin_next_s                                 ;

// FIFO full condition
assign full_s         = ((wr_gray_next_s[ADDRSIZE]     != i_rd_ptr_clx[ADDRSIZE] ) &&
                         (wr_gray_next_s[ADDRSIZE-1]   != i_rd_ptr_clx[ADDRSIZE-1]) &&
                         (wr_gray_next_s[ADDRSIZE-2:0] == i_rd_ptr_clx[ADDRSIZE-2:0]))       ;        

/*---------------------------------------------------------------------------------
  Assertion of full flag
----------------------------------------------------------------------------------*/ 
always @(posedge i_wr_clk or negedge i_wr_rst_n )
begin 
   if (!i_wr_rst_n) 
      o_full <= 1'b0                                                                         ;
   else 
      o_full <= full_s                                                                       ;
end

/*---------------------------------------------------------------------------------
  Generation of full flag that is used for write pointer increment
----------------------------------------------------------------------------------*/ 
always @(posedge i_wr_clk or negedge i_wr_rst_n)
begin 
   if (!i_wr_rst_n) 
      full_r <= 1'b0                                                                         ;
   else 
      full_r <= full_s                                                                       ;
end

endmodule

