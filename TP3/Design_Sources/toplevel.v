`timescale 1ns/100ps

module toplevel
#(
    parameter                               NB_INSTRUCTION  = 16,
    parameter                               NB_ADDR         = 11,
    parameter                               NB_OPCODE       = 5,
    parameter                               NB_OPERAND      = NB_INSTRUCTION-NB_OPCODE,
    parameter                               NB_DATA         = 8,
    parameter                               NB_STOP         = 1,
    parameter                               BAUD_RATE       = 9600,
    parameter                               SYS_CLOCK       = 100000000,
    parameter                               TICK_RATE       = SYS_CLOCK / (BAUD_RATE*16),
    parameter                               NB_TICK_COUNTER = $clog2(TICK_RATE),
    parameter                               NB_DATA_COUNTER = $clog2(NB_DATA)          
)
(
    input wire                              i_clock,
    input wire                              i_reset,
    output wire                             RsTx,
    output wire [NB_INSTRUCTION-1 : 0]      o_led

);

//----------------------(BIP - UART)---------------------- 
    wire                    bip_program_done;
    wire    [NB_ADDR-1 : 0] bip_program_counter_uart;
    reg                     program_done_reg;

//----------------------(UART - BIP)----------------------
    wire                    uart_tx_start;
    


    always @(posedge i_clock)
    begin
        if(i_reset)
            program_done_reg <= 1'b0;
        else
            program_done_reg <= bip_program_done;
    end
    
    assign uart_tx_start = bip_program_done & ~program_done_reg;


uart_toplevel
#(
    .NB_DATA            (NB_DATA),
    .NB_STOP            (NB_STOP),
    .BAUD_RATE          (BAUD_RATE),
    .SYS_CLOCK          (SYS_CLOCK),
    .TICK_RATE          (TICK_RATE),
    .NB_TICK_COUNTER    (NB_TICK_COUNTER),
    .NB_DATA_COUNTER    (NB_DATA_COUNTER)    
)
u_uart
(
    .i_clock            (i_clock),
    .i_reset            (i_reset),
    .i_tx_data          (bip_program_counter_uart[NB_DATA-1 -: NB_DATA]),
    .i_tx_start         (uart_tx_start),
    .o_tx_data          (RsTx)
);

bip
#(
    .NB_INSTRUCTION     (NB_INSTRUCTION),
    .NB_ADDR            (NB_ADDR),
    .NB_OPCODE          (NB_OPCODE),
    .NB_OPERAND         (NB_OPERAND)
)
u_bip
(
    .i_clock            (i_clock),
    .i_reset            (i_reset),
    .o_accumulator      (o_led),
    .o_program_counter  (bip_program_counter_uart),
    .o_program_done     (bip_program_done)
);

endmodule
