`timescale 1ns/100ps

module tb_uart_tx();

localparam                  NB_DATA              =   8;
localparam                  NB_STOP              =   1;
localparam                  BAUD_RATE            =   9600;
localparam                  SYS_CLOCK            =   100*(10**6);
localparam                  TICK_RATE            =   SYS_CLOCK / (BAUD_RATE*16);
localparam                  NB_TICK_COUNTER      =   $clog2(TICK_RATE);
localparam                  NB_DATA_COUNTER      =   $clog2(NB_DATA); 
localparam                  NB_TB_COUNTER        =   10;

reg                         tb_i_clock;
reg                         tb_i_reset;
wire                        tb_tick;
reg [NB_DATA-1 : 0]         tb_i_data;
reg                         tb_i_start;
wire                        tb_o_data;
wire                        tb_o_data_valid;
wire                        tb_o_available_tx;
reg [NB_TB_COUNTER-1 : 0]   tb_counter;

initial
begin
    tb_i_clock              = 1'b0;
    tb_i_reset              = 1'b1;
    tb_i_start              = 1'b0;
    tb_counter              = {NB_TB_COUNTER{1'b0}};
#10
    tb_i_reset              = 1'b0;
#10
    tb_i_start              = 1'b1;  //start bit
    tb_i_data               = 8'b10101010;
end

always #2 tb_i_clock = ~tb_i_clock;

baudrate_generator
#(
    .BAUD_RATE(BAUD_RATE),
    .SYS_CLOCK(SYS_CLOCK),
    .TICK_RATE(TICK_RATE),
    .NB_TICK_COUNTER(NB_TICK_COUNTER)
)
u_baudrate_gen
(
    .i_clock(tb_i_clock),
    .i_reset(tb_i_reset),
    .o_tick(tb_tick)
);

uart_tx
#(
    .NB_DATA(NB_DATA),
    .NB_STOP(NB_STOP),
    .BAUD_RATE(BAUD_RATE),
    .SYS_CLOCK(SYS_CLOCK),
    .TICK_RATE(TICK_RATE),
    .NB_TICK_COUNTER(NB_TICK_COUNTER),
    .NB_DATA_COUNTER(NB_DATA_COUNTER)
)
u_uart_tx
(
    .i_clock(tb_i_clock),
    .i_reset(tb_i_reset),
    .i_tick(tb_tick),
    .i_data(tb_i_data),
    .i_start(tb_i_start),
    .o_data(tb_o_data),
    .o_data_valid(tb_o_data_valid),
    .o_available_tx(tb_o_available_tx)
);

endmodule