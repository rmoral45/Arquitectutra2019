`timescale 1ns/100ps

module  proyect_toplevel
#(
    parameter   NB_DATA             = 8,
    parameter   NB_OPCODE           = 6,
    parameter   NB_STOP             = 1,
    parameter   BAUD_RATE           = 9600,
    parameter   SYS_CLOCK           = 100000000,
    parameter   TICK_RATE           = SYS_CLOCK / (BAUD_RATE*16),
    parameter   NB_TICK_COUNTER     = $clog2(TICK_RATE),
    parameter   NB_DATA_COUNTER     = $clog2(NB_DATA),
    parameter   N_INPUTS            = 3  
)
(
    input wire  i_clock,
    input wire  i_reset,
    input wire  RsRx,
    output wire  RsTx,
    output wire [NB_DATA-1 : 0] o_led,
    output wire [N_INPUTS-1 : 0] o_led_dbg
    
);

    wire                        rx_data_valid;      
    wire    [NB_DATA-1 : 0]     rx_data;
    wire                        tx_start;
    wire    [NB_DATA-1 : 0]     tx_data;   
    wire    [NB_DATA-1 : 0]     first_operator;   
    wire    [NB_DATA-1 : 0]     second_operator;   
    wire    [NB_OPCODE-1 : 0]   opcode;  
    wire    [N_INPUTS-1 : 0]    dbg_uart;
    wire    [NB_DATA-1 : 0]     alu_data;
    wire                        data_valid_to_uart; 
    
    assign                      o_led     = rx_data;
    assign                      o_led_dbg = dbg_uart;

alu
#(
    .NB_DATA                (NB_DATA),
    .NB_OPCODE              (NB_OPCODE)
)
u_alu
(
    .i_first_operator       (first_operator),
    .i_second_operator      (second_operator),
    .i_opcode               (opcode),
    .o_result               (alu_data)
);

uart_toplevel
#(
    .NB_DATA                (NB_DATA),
    .NB_STOP                (NB_STOP),
    .BAUD_RATE              (BAUD_RATE),
    .SYS_CLOCK              (SYS_CLOCK),
    .TICK_RATE              (TICK_RATE),
    .NB_TICK_COUNTER        (NB_TICK_COUNTER),
    .NB_DATA_COUNTER        (NB_DATA_COUNTER)
)
u_uart_toplevel
(
    .i_clock                (i_clock),
    .i_reset                (i_reset),
    .i_rx                   (RsRx),
    .i_tx_data              (alu_data),
    .i_tx_start             (tx_start),
    .o_rx_data_valid        (rx_data_valid),
    .o_rx_data              (rx_data),
    .o_tx_data              (RsTx)
);

uart_interface
#(
    .NB_DATA                (NB_DATA),
    .NB_OPCODE              (NB_OPCODE)
)
u_uart_interface
(
    .i_clock                (i_clock),
    .i_reset                (i_reset),
    .i_uart_data            (rx_data),
    .i_uart_data_valid      (rx_data_valid),
    .o_dbg_uart             (dbg_uart),
    .o_tx_start             (tx_start),
    .o_first_operator       (first_operator),
    .o_second_operator      (second_operator),
    .o_opcode               (opcode)
);

endmodule