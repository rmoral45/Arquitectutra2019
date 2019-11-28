`timescale 1ns/100ps
module tb_toplevel();

localparam      NB_INSTRUCTION  = 16;
localparam      NB_ADDR         = 11;
localparam      NB_OPCODE       = 5;
localparam      NB_OPERAND      = NB_INSTRUCTION-NB_OPCODE;
localparam      NB_DATA         = 8;
localparam      NB_STOP         = 1;
localparam      BAUD_RATE       = 9600;
localparam      SYS_CLOCK       = 100000000;
localparam      TICK_RATE       = SYS_CLOCK/(BAUD_RATE*16);
localparam      NB_TICK_COUNTER = $clog2(TICK_RATE);
localparam      NB_DATA_COUNTER = $clog2(NB_DATA);

reg                         tb_i_clock;
reg                         tb_i_reset;
wire                        tb_RsTx;
wire [NB_INSTRUCTION-1 : 0] tb_o_led;


initial
begin
    tb_i_clock              = 1'b0;
    tb_i_reset              = 1'b1;
#10
    tb_i_reset              = 1'b0;
end

always #2 tb_i_clock = ~tb_i_clock;

toplevel
#(
    .NB_INSTRUCTION(NB_INSTRUCTION),
    .NB_ADDR(NB_ADDR),
    .NB_OPCODE(NB_OPCODE),
    .NB_OPERAND(NB_OPERAND),
    .NB_DATA(NB_DATA),
    .NB_STOP(NB_STOP),
    .BAUD_RATE(BAUD_RATE),
    .SYS_CLOCK(SYS_CLOCK),
    .TICK_RATE(TICK_RATE),
    .NB_TICK_COUNTER(NB_TICK_COUNTER),
    .NB_DATA_COUNTER(NB_DATA_COUNTER)
)
u_toplevel
(
    .i_clock(tb_i_clock),
    .i_reset(tb_i_reset),
    .RsTx(tb_RsTx),
    .o_led(tb_o_led)
);

endmodule