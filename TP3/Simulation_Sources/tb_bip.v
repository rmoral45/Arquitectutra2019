`timescale 1ns/100ps

module tb_bip();

localparam                  NB_INSTRUCTION = 16;
localparam                  NB_ADDR        = 11;
localparam                  NB_OPCODE      = 5;
localparam                  NB_OPERAND     = NB_INSTRUCTION-NB_OPCODE;
localparam                  NB_SELECTOR_A  = 2;
localparam                  FILE           = "/home/ramiro/repos/Arquitectutra2019/TP3/Design_Sources/programas/programa1.txt";

reg                             tb_i_clock;
reg                             tb_i_reset;

wire    [NB_INSTRUCTION-1 : 0]  tb_o_accumulator;
wire    [NB_ADDR-1 : 0]         tb_o_program_counter;
wire                            tb_o_program_done;

initial
begin
    tb_i_clock              = 1'b0;
    tb_i_reset              = 1'b1;
#10
    tb_i_reset              = 1'b0;
end

always #2 tb_i_clock = ~tb_i_clock;

bip
#(
    .NB_INSTRUCTION(NB_INSTRUCTION),
    .NB_ADDR(NB_ADDR),
    .NB_OPCODE(NB_OPCODE),
    .NB_OPERAND(NB_OPERAND)
)
u_bip
(
    .i_clock(tb_i_clock),
    .i_reset(tb_i_reset),
    .o_accumulator(tb_o_accumulator),
    .o_program_counter(tb_o_program_counter),
    .o_program_done(tb_o_program_done)
);

endmodule