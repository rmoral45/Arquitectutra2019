`timescale 1ns/100ps
module control_unit
#(
    parameter                           NB_INSTRUCTION  = 16,
    parameter                           NB_ADDR         = 11,
    parameter                           NB_OPCODE       = 5,
    parameter                           NB_SELECTOR_A   = 2
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    input wire  [NB_OPCODE-1 : 0]       i_opcode,
    
    //signal for read from rom
    output wire [NB_ADDR-1 : 0]         o_address,
    //control signals
    output wire [NB_SELECTOR_A-1 : 0]   o_sel_a,
    output wire                         o_sel_b,
    output wire                         o_enb_acc,                      
    output wire                         o_operation,
    output wire                         o_wr_enb_ram,
    output wire                         o_program_done
);

    //signals from instruction_decoder module
    wire                                enb_program_counter;
    wire        [NB_SELECTOR_A-1 : 0]   sel_a;
    wire                                sel_b;
    wire                                enb_acc;
    wire                                operation;
    wire                                wr_enb_ram;
    wire                                rd_enb_ram;
    wire                                program_done;
    //internal signals
    reg         [NB_ADDR-1 : 0]         program_counter;

    assign                              o_address       = program_counter;
    assign                              o_sel_a         = sel_a;
    assign                              o_sel_b         = sel_b;
    assign                              o_enb_acc       = enb_acc;
    assign                              o_operation     = operation;
    assign                              o_wr_enb_ram    = wr_enb_ram;
    assign                              o_program_done  = program_done;

    always @(posedge i_clock)
    begin
        if(i_reset)
            program_counter <= {NB_INSTRUCTION{1'b0}};
        else if(i_opcode == {NB_OPCODE{1'b0}})
            program_counter <= program_counter;
        else if(enb_program_counter)
            program_counter <= program_counter + 1;
    end

instruction_decoder
#(
    .NB_OPCODE      (NB_OPCODE),
    .NB_SELECTOR_A  (NB_SELECTOR_A)
)
u_instruction_decoder
(
    .i_opcode       (i_opcode),
    .o_enb_pc       (enb_program_counter),
    .o_sel_a        (sel_a),
    .o_sel_b        (sel_b),
    .o_enb_acc      (enb_acc),
    .o_operation    (operation),
    .o_wr_enb_ram   (wr_enb_ram),
    .o_program_done (program_done)
);

endmodule