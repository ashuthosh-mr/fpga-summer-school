`timescale 1 ns/10 ps
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%% Project Name : FIFO Empty Design                                                           %%
//-----%% File Name    : fifo_empty.v                                                                %%
//-----%% Author       : CDAC Bangalore                                                              %%
//-----%%                                                                                            %%
//-----%% Description  : In this module we are determining whether a FIFO memory is empty and        %%
//-----%%                provide related outputs such as the empty flag (o_empty), read address      %%
//-----%%                (o_rd_addr), and read pointer (o_rd_ptr). It operates within a read clock   %%
//-----%%                domain with an active-low reset signal (i_rd_rst_n), read clock signal      %%
//-----%%                (i_rd_clk), read enable signal (i_rd_en), and a synchronized write pointer  %%
//-----%%                with respect to the read clock (i_wr_ptr_clx).                              %%
//-----%%                The module employs a binary read pointer (rd_bin_r), a binary read pointer  %%
//-----%%                for the next state (rd_bin_next_s), and a read pointer in Gray coding style %%
//-----%%                for the next state (rd_gray_next_s). The read pointer and empty flag are    %%
//-----%%                asynchronously asserted based on the read clock and the active-low reset.   %%
//-----%%                The empty flag is determined by comparing the next-state read pointer in    %%
//-----%%                Gray coding style with the synchronized write pointer (i_wr_ptr_clx).       %%
//-----%%                The read pointer is incremented based on the read enable signal and the     %%
//-----%%                inverse of the empty flag. The binary read pointer is converted to Gray     %%
//-----%%                coding style to suit the memory addressing scheme.                          %%
//-----%%                The module asserts the empty flag (o_empty) based on the active-low reset   %%
//-----%%                or the calculated empty signal (empty_s). The read address (o_rd_addr) is   %%
//-----%%                derived from the binary read pointer.                                       %%
//-----%%                This module effectively manages the empty condition of the FIFO memory and  %%
//-----%%                produces corresponding outputs.                                             %%
//-----%% Copyright    : CDAC Bangalore                                                              %%               
//-----%%                                                                                            %%              
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//-----%%%%%%%%%%%%%%%%% Modification / Updation History %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%%                                                                                            %%
//-----%% Date: 11-12-2023              Version: 1.0   Change Description:                           %%
//-----%%                                                                                            %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


module fifo_empty ( i_rd_clk                     ,
                    i_rd_rst_n                   ,
                    i_rd_en                      ,
                    i_wr_ptr_clx                 ,
                    o_empty                      ,
                    o_rd_addr                    ,
                    o_rd_ptr
                  )                              ;

// parameter declaration
parameter   ADDRSIZE = 4                         ;    // length of address

// input port declaration
input                       i_rd_clk             ;    // clock from read domain
input                       i_rd_rst_n           ;    // reset from read domain
input                       i_rd_en              ;    // read enable
input      [ADDRSIZE : 0]   i_wr_ptr_clx         ;    // synchronized write pointer wrt read clock
         
// output port declaration
output reg                  o_empty              ;    // empty flag
output     [ADDRSIZE-1 : 0] o_rd_addr            ;    // read address (binary coding style)
output reg [ADDRSIZE   : 0] o_rd_ptr             ;    // read pointer (Gray coding style)


// register declaration
reg        [ADDRSIZE : 0]   rd_bin_r             ;    // read pointer(binary)
reg                         empty_r              ;    // empty flag reg

// wire declaration
wire       [ADDRSIZE : 0]   rd_gray_next_s       ;    // read pointer(gray coding style)
wire                        empty_s              ;    // empty flag
wire       [ADDRSIZE : 0]   rd_bin_next_s        ;    // read pointer(binary coding style)


/*---------------------------------------------------------------------------------
 Use of asynchronous active low reset to assign read pointer to gray coding style 
----------------------------------------------------------------------------------*/ 
always @(posedge i_rd_clk or negedge i_rd_rst_n)
begin
   if (!i_rd_rst_n)
   begin
      rd_bin_r  <= 5'b0                                               ;
      o_rd_ptr  <= 5'b0                                               ;
   end
   else
   begin
      rd_bin_r  <= rd_bin_next_s                                      ;
      o_rd_ptr  <= rd_gray_next_s                                     ;
   end
end

// Memory read-address pointer (okay to use binary to address memory)
assign o_rd_addr = rd_bin_r[ADDRSIZE-1:0]                             ;

// read pointer increments depending upon the read enable and empty signal
assign rd_bin_next_s = {rd_bin_r + (i_rd_en & !empty_r)}              ;

// Converting binary coding into gray coding style
assign rd_gray_next_s = (rd_bin_next_s >> 1) ^ rd_bin_next_s          ;

// FIFO empty when the next rptr == synchronized wptr or on reset
assign empty_s = (rd_gray_next_s == i_wr_ptr_clx)                     ;


/*--------------------------------------------------------------------
* Assertion of empty flag
---------------------------------------------------------------------*/ 
always @(posedge i_rd_clk or negedge i_rd_rst_n)
begin 
   if (!i_rd_rst_n) 
      o_empty <= 1'b1                                                 ;
   else 
      o_empty <= empty_s                                              ;
end

/*---------------------------------------------------------------------------------
  Generation of empty flag that is used for read pointer increment
----------------------------------------------------------------------------------*/ 
always @(posedge i_rd_clk or negedge i_rd_rst_n)
begin 
   if (!i_rd_rst_n) 
      empty_r <= 1'b1                                                 ;
   else 
      empty_r <= empty_s                                              ;
end
 

endmodule
