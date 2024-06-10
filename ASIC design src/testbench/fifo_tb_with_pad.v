 `timescale 1 ns/10 ps
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%% Project Name : Asynchronous FIFO Tesetbench                                                 %%
//-----%% File Name    : fifo_tb.v                                                                    %%
//-----%% Author       : CDAC Bangalore                                                               %%
//     %%                                                                                             %%
//-----%% Description  : In this testbench module, fifo_tb is designed to verify the functionality of %%
//-----%%                the asynchronous FIFO module. It defines parameters such as data size        %%
//-----%%                (DATASIZE), address size (ADDRSIZE), and memory depth (MEM_DEPTH). The       %%
//-----%%                testbench includes input and output signals necessary for the FIFO module,   %%
//-----%%                along with a test memory (mem_tb) to simulate the FIFO's behavior.           %%
//-----%%                The testbench generates write and read clocks (i_wr_clk_pad and i_rd_clk_pad),       %%
//-----%%                write and read reset signals (i_wr_rst_n_pad and i_rd_rst_n_pad), write data         %%
//-----%%                (i_wr_data_pad), and control signals for write and read operations (i_wr_en_pad and  %%
//-----%%               i_rd_en_pad). It also has flags for FIFO full and empty states (o_full_pad and       %%
//-----%%               o_empty_pad) and the output read data (o_rd_data_pad).                               %%
//-----%%                The write clock is generated using an initial block. Similar initial blocks  %%
//-----%%                generate read clocks and initialize write and read reset signals. Random     %%
//-----%%                data is generated and written to the test memory when the FIFO is not full,  %%
//-----%%                and the write enable signal is asserted.                                     %%
//-----%%                The testbench captures the output read data and compares it with the data    %%
//-----%%                read from the test memory. If the data matches, a success message is         %%
//-----%%                displayed; otherwise, a failure message is printed. The testbench            %%
//-----%%                effectively checks the FIFO module's read and write operations and ensures   %%
//-----%%                proper synchronization between the clock domains while verifying the correct %%
//-----%%                functioning of the FIFO memory.                                              %%
//-----%% Copyright    : CDAC Bangalore                                                               %%
//-----%%                                                                                             %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//-----%%%%%%%%%%%%%%%%% Modification / Updation History %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%%                                                                                             %%
//-----%% Date: 11-12-23            Version 1.0  Change Description:                                  %%
//-----%%                                                                                             %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


module fifo_tb_with_pad()                                                   ;
parameter DATASIZE   = 8                                           ;
parameter ADDRSIZE   = 4                                           ;
parameter MEM_DEPTH  = 16                                          ;

//register declaration
reg                    i_wr_clk_pad                                    ;
reg                    i_wr_rst_n_pad                                  ;
reg  [DATASIZE-1 : 0]  i_wr_data_pad                                   ; 
reg                    i_rd_clk_pad                                    ;
reg                    i_rd_rst_n_pad                                  ;
reg                    rd_entmp                                    ;
reg                    wr_entmp                                    ;
reg  [DATASIZE-1 : 0]  rd_datatmp                                  ;
reg  [ADDRSIZE-1 : 0]  wr_addr_tb                                  ;
reg  [ADDRSIZE-1 : 0]  rd_addr_tb                                  ;
reg  [DATASIZE-1 : 0]  rd_data_tb                                  ;
reg                    wr_sync_rst_reg                             ;
reg                    rd_sync_rst_reg                             ;
reg                    o_wr_sync_rst                               ;
reg                    o_rd_sync_rst                               ;

//wire delaclaration
wire                   i_rd_en_pad                                     ;
wire                   i_wr_en_pad                                     ;
wire                   o_full_pad                                      ;
wire                   o_empty_pad                                     ;
wire [DATASIZE-1 : 0]  o_rd_data_pad                                   ;

// tb memory for checking functionality
reg  [DATASIZE-1 : 0]  mem_tb [MEM_DEPTH -1 : 0]                   ;




// instantiation of design under test
fifo fifo_inst(      .i_wr_clk_pad(i_wr_clk_pad)                          ,   // input write clock 
                      .i_wr_rst_n_pad(i_wr_rst_n_pad)                      ,   // input active low write reset
                      .i_wr_en_pad(i_wr_en_pad)                            ,   // input write enable
                      .i_wr_data_pad(i_wr_data_pad)                        ,   // input write data
                      .i_rd_clk_pad(i_rd_clk_pad)                          ,   // input read clock
                      .i_rd_rst_n_pad(i_rd_rst_n_pad)                      ,   // input active low read reset
                      .i_rd_en_pad(i_rd_en_pad)                            ,   // input read enable
                      .o_rd_data_pad(o_rd_data_pad)                        ,   // output read data
                      .o_full_pad(o_full_pad)                              ,   // full flag
                      .o_empty_pad(o_empty_pad)                                // empty flag
               )                                                   ;



// write clock genaration logic
initial
begin
   i_wr_clk_pad = 1'b0                                                 ;  // initialize write clock low
forever
#11 i_wr_clk_pad = ~i_wr_clk_pad                                           ;  // toggling of write clock
end

// read clock generation logic 
initial
begin
   i_rd_clk_pad = 1'b0                                                 ;   // initialize read clock low
forever
#7 i_rd_clk_pad = ~i_rd_clk_pad                                            ;   // toggling of read clock
end

// write reset generation logic 
initial
begin
#10   i_wr_rst_n_pad = 1'b0                                            ;   // initialize write reset low
#30   i_wr_rst_n_pad = 1'b1                                            ;
end

//read reset generation logic
initial
begin
#10   i_rd_rst_n_pad = 1'b0                                            ;   // initialize read reset low
#50   i_rd_rst_n_pad = 1'b1                                            ;
end

//*******************************************************************************************
//The always block given below will synchronize write reset using 2 D-FF synchronizer Scheme
//*******************************************************************************************
always @(posedge i_wr_clk_pad or negedge i_wr_rst_n_pad)
begin
   if (!i_wr_rst_n_pad)
   begin
      wr_sync_rst_reg         <= 1'b0                              ;   // Assertion of write reset 
      o_wr_sync_rst           <= 1'b0                              ;
   end
   else 
   begin
      wr_sync_rst_reg         <= 1'b1                              ;   // Deassertion of write reset
      o_wr_sync_rst           <= wr_sync_rst_reg                   ; 
   end
end

//*******************************************************************************************
//The always block given below will synchronize read reset using 2 D-FF synchronizer Scheme
//*******************************************************************************************
always @(posedge i_rd_clk_pad or negedge i_rd_rst_n_pad)
begin
   if (!i_rd_rst_n_pad)
   begin
      rd_sync_rst_reg         <= 1'b0                              ;   // Assertion of read reset
      o_rd_sync_rst           <= 1'b0                              ;
   end
   else 
   begin
      rd_sync_rst_reg         <= 1'b1                              ;   // Deassertion of read reset
      o_rd_sync_rst           <= rd_sync_rst_reg                   ; 
   end
end


//write enable genaration logic
assign i_wr_en_pad = (wr_entmp & (!o_full_pad) )                           ;

//***********************************************************************************************************
//  Initialization of random data and write enable as high at posegde of write clock depending on full flag
//***********************************************************************************************************
always @ (posedge i_wr_clk_pad or negedge o_wr_sync_rst)
begin
   if (! o_wr_sync_rst)
   begin
      wr_entmp                <=  1'b0                             ;   // Disable the write enable
   end
   else if (!o_full_pad)
   begin
#1      i_wr_data_pad               <=  $random                          ;   // Random data to FIFO
      wr_entmp                <=  1'b1                             ;   // Enbaling the FIFO write
   end 
   else 
   begin 
      wr_entmp                <=  1'b0                             ;   // Disable the write enable- FIFO is full
   end
end

//***********************************************************************************************************
// In this always block, we are initializing the TB RAM address at active low write reset.
// Write operation in TB RAM and TB RAM address starts incrementing only when write enable is active high.
//***********************************************************************************************************
always @ (posedge i_wr_clk_pad or negedge o_wr_sync_rst)
begin
   if (! o_wr_sync_rst)
      wr_addr_tb              <=  4'b0                             ;   // TB RAM address pointer initial value
   else
   begin
      if (i_wr_en_pad == 1'b1)
      begin
          mem_tb[wr_addr_tb]  <=  i_wr_data_pad                        ;   // Writing Data to TB RAM
          wr_addr_tb          <=  wr_addr_tb + 1'b1                ;   // TB RAM address increment
      end
   end
end

// Read Enable Generation logic
assign i_rd_en_pad = ( rd_entmp & (!o_empty_pad) )                         ;

//************************************************************************************************************
// Enables the FIFO read operation and getting the read enable temporary signal based on read reset and empty flag
//***********************************************************************************************************
always @ (posedge i_rd_clk_pad or negedge o_rd_sync_rst)
begin
   rd_datatmp                 <= o_rd_data_pad                         ;
   if (! o_rd_sync_rst)
   begin
      rd_entmp                <=  1'b0                             ;   // READ Enable is disbaled
   end
   else if (!o_empty_pad)
   begin
      rd_entmp                <=  1'b1                             ;   // READ enable to FIFO
   end
   else 
   begin
      rd_entmp                <=  1'b0                             ;
   end
end
 
// **********************************************************************************************************
//   Read the Data from TB RAM based on Read Enable signal to FIFO
// **********************************************************************************************************
always @ (posedge i_rd_clk_pad or negedge o_rd_sync_rst)
begin
  if (!o_rd_sync_rst)
      rd_addr_tb              <=  4'b0                             ;   // TB RAM address pointer initial value
   else
   begin
      rd_data_tb              <=  mem_tb[rd_addr_tb]               ;   // Writing in a TB RAM
      if (i_rd_en_pad == 1'b1)
         rd_addr_tb           <=  rd_addr_tb + 1'b1                ;   // Incrementing the address of TB RAM
   end
end

// **********************************************************************************************************
//   Output Data from design comparison with Reference Data from TB RAM
// **********************************************************************************************************
always @ (posedge i_rd_clk_pad)
begin
   if(i_rd_en_pad ==1'b1)
   begin
      if (rd_data_tb  == rd_datatmp)
      begin          
         $display ("[%t] FIFO OUT : %h TB RAM OUT = %h ----Matched---", $time(), rd_datatmp, rd_data_tb)      ;
      end
      else
      begin
         $display ("[%t] FIFO OUT : %h TB RAM OUT = %h ****FAILED****", $time(), rd_datatmp, rd_data_tb)      ; 
      end            
   end
end
 

endmodule 
