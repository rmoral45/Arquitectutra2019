`timescale 1ns/100ps

module uart_interface
#(
    parameter                           NB_DATA         = 8,
    parameter                           NB_OPCODE       = 6,
    parameter                           N_INPUTS        = 3
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    input wire  [NB_DATA-1 : 0]         i_uart_data,
    input wire                          i_uart_data_valid,

    output wire                         o_tx_start

    );
  

    localparam                          NB_STATES               = 3;
    localparam  [NB_STATES-1 : 0]       SAVE_FIRST_OPERATOR     = 3'b001;
    localparam  [NB_STATES-1 : 0]       SAVE_SECOND_OPERATOR    = 3'b010;
    localparam  [NB_STATES-1 : 0]       SAVE_OPCODE             = 3'b100;

    reg         [NB_STATES-1 : 0]       state_alu_fsm;
    reg         [NB_STATES-1 : 0]       state_alu_fsm_next;

    reg                                 tx_start;
    reg                                 tx_start_next;

    reg         [NB_DATA-1 : 0]         uart_rx_data;

//Interface to ALU
    assign                              o_dbg_uart              = state_alu_fsm;
    assign                              o_tx_start              = tx_start;         

    always @(posedge i_clock)
    begin
        
        if(i_reset)
        begin
            state_alu_fsm   <=  SAVE_FIRST_OPERATOR;
        end
        else
        begin
            state_alu_fsm   <=  state_alu_fsm_next;
        end
    
    end    

endmodule

