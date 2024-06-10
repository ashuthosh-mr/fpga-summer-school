`timescale 1 ns/10 ps
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%% Project Name : Reset Synchronizer Design                                                     %%
//-----%% File Name    : reset_sync.v                                                                  %%
//-----%% Author       : Cdac Bangalore                                                                %%
//-----%%                                                                                              %%
//-----%% Description  : This module helps in synchronization of input resets (i_rst_n).It employs a   %%
//-----%%                Flip-flop based approach, often using a D Fipflop to synchronize reset signal.%% 
//-----%%                The purpose is to prevent metastability issues that can arise when applying   %%
//-----%%                directly to modules.                                                          %%
//-----%%                The synchronized reset output (o_rsync_rst) is merged by internalregister.    %%
//-----%%                When asynchronous reset is active (!i_rst_n) both registers and output is set %%             //-----%%                to logic low. In abscence of active reset, the register is set to logic high  %%
//-----%%                and output adopts the synchronous register value.                             %%             //-----%% Copyright    : CDAC Bangalore                                                                %%
//-----%%                                                                                              %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

//-----%%%%%%%%%%%%%%%%% Modification / Updation History %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
//-----%%                                                                                              %%
//-----%% Date: 11-12-2023              Version: 1.0   Change Description:                             %%
//-----%%                                                                                              %%
//-----%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                                                                                  
module reset_sync  ( o_sync_rst                         , // Synchronized Reset Output
                     i_clk                              , // Input clock
                     i_rst_n                              // Asynchronous Reset
                   )                                    ;

//input declaration
input      i_clk                                        ; //input clock
input      i_rst_n                                      ; //input active low reset

//output declaration
output reg o_sync_rst                                   ; //output reset synchronizer

//reg declaration
reg        syncrst_reg                                  ; //register for reset synchronizing

//****************************************************************************************
//The always block given below will synchronize reset using 2 D-FF synchronizer Scheme
//****************************************************************************************
always @(posedge i_clk or negedge i_rst_n)
begin
   if (!i_rst_n)
   begin
      syncrst_reg <= 1'b0                               ;   
      o_sync_rst  <= 1'b0                               ;
   end
   else 
   begin
      syncrst_reg <= 1'b1                               ;   
      o_sync_rst  <= syncrst_reg                        ; 
   end
end

endmodule






