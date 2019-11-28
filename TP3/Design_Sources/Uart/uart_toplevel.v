`timescale 1ns/100ps

module uart_toplevel
#(
    parameter                               NB_DATA             = 8,
    parameter                               NB_STOP             = 1,
    parameter                               BAUD_RATE           = 9600,
    parameter                               SYS_CLOCK           = 100*(10**6),
    parameter                               TICK_RATE           = SYS_CLOCK / (BAUD_RATE*16),
    parameter                               NB_TICK_COUNTER     = $clog2(TICK_RATE),
    parameter                               NB_DATA_COUNTER     = $clog2(NB_DATA) 
)
(
    input wire                              i_clock,
    input wire                              i_reset,
    input wire      [NB_DATA-1 : 0]         i_tx_data,
    input wire                              i_tx_start,

    output wire                             o_tx_data
);

    wire                                    baudrate_tick;

baudrate_generator
#(
    .BAUD_RATE              (BAUD_RATE),
    .SYS_CLOCK              (SYS_CLOCK),
    .TICK_RATE              (TICK_RATE),
    .NB_TICK_COUNTER        (NB_TICK_COUNTER)
)
u_baudrate_generator
(
    .i_clock                (i_clock),
    .i_reset                (i_reset),
    .o_tick                 (baudrate_tick)
);

uart_tx
#(
    .NB_DATA                (NB_DATA),
    .NB_STOP                (NB_STOP),
    .BAUD_RATE              (BAUD_RATE),
    .SYS_CLOCK              (SYS_CLOCK),
    .TICK_RATE              (TICK_RATE),
    .NB_TICK_COUNTER        (NB_TICK_COUNTER),
    .NB_DATA_COUNTER        (NB_DATA_COUNTER)    
)
u_uart_tx
(
    .i_clock                (i_clock),
    .i_reset                (i_reset),
    .i_tick                 (baudrate_tick),
    .i_data                 (i_tx_data),
    .i_start                (i_tx_start),
    .o_data                 (o_tx_data)
);

endmodule