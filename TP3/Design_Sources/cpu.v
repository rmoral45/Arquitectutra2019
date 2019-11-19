`timescale 1ns/100ps
module cpu
#(
    parameter                           NB_INSTRUCTION  = 16,
    parameter                           NB_ADDR         = 11,
    parameter                           NB_OPCODE       = 5,
    parameter                           NB_OPERAND      = NB_INSTRUCTION-NB_OPCODE,    
    parameter                           NB_SELECTOR_A   = 2
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    
    input wire  [NB_INSTRUCTION-1 : 0]  i_rom_data,
    input wire  [NB_INSTRUCTION-1 : 0]  i_ram_data,

    output wire [NB_ADDR-1 : 0]         o_rom_addr,
    output wire [NB_ADDR-1 : 0]         o_ram_addr,
    output wire [NB_INSTRUCTION-1 : 0]  o_ram_data,
    output wire                         o_ram_wr_enable,
    output wire                         o_ram_rd_enable
);

//----------------------(CPU - ROM)-----------------------------------------
    wire        [NB_ADDR-1 : 0]         cpu_addr_rom;
    assign                              o_rom_addr          = cpu_addr_rom;

//----------------------(CPU - ROM)-----------------------------------------
    assign                              o_ram_addr          = i_rom_data[NB_OPERAND-1 -: NB_OPERAND];

//----------------------(CPU - Control Unit)--------------------------------
    wire        [NB_OPCODE-1 : 0]       cpu_opcode_ctrlUnit;
    assign                              cpu_opcode_ctrlUnit = i_rom_data[NB_INSTRUCTION-1 -: NB_OPCODE];

//----------------------(Control Unit - Datapath Unit)----------------------
    wire        [NB_SELECTOR_A-1 : 0]   ctrlUnit_selectorA_datapath;
    wire                                ctrlUnit_selectorB_datapath;
    wire                                ctrlUnit_enableAcc_datapath;
    wire                                ctrlUnit_operation_datapath;

//----------------------(CPU - Datapath Unit)--------------------------------
    wire        [NB_OPERAND-1 : 0]      cpu_operand_datapath;
    assign                              cpu_operand_datapath = i_rom_data[NB_OPERAND-1 -: NB_OPERAND];


control_unit
#(
    .NB_INSTRUCTION (NB_INSTRUCTION),
    .NB_ADDR        (NB_ADDR),
    .NB_OPCODE      (NB_OPCODE),
    .NB_SELECTOR_A  (NB_SELECTOR_A)
)
u_control_unit
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_opcode       (cpu_opcode_ctrlUnit),
    .o_address      (cpu_addr_rom),
    .o_sel_a        (ctrlUnit_selectorA_datapath),
    .o_sel_b        (ctrlUnit_selectorB_datapath),
    .o_enb_acc      (ctrlUnit_enableAcc_datapath),
    .o_operation    (ctrlUnit_operation_datapath),
    .o_wr_enb_ram   (o_ram_wr_enable),
    .o_rd_enb_ram   (o_ram_rd_enable)
);

datapath_unit
#(
    .NB_INSTRUCTION (NB_INSTRUCTION),
    .NB_ADDR        (NB_ADDR),
    .NB_OPCODE      (NB_OPCODE),
    .NB_OPERAND     (NB_OPERAND),
    .NB_SELECTOR_A  (NB_SELECTOR_A)
)
u_datapath_unit
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_ram_data     (i_ram_data),
    .i_operand      (cpu_operand_datapath),
    .i_sel_a        (ctrlUnit_selectorA_datapath),
    .i_sel_b        (ctrlUnit_selectorB_datapath),
    .i_enb_acc      (ctrlUnit_enableAcc_datapath),
    .i_operation    (ctrlUnit_operation_datapath),
    .o_ram_data     (o_ram_data)
);

endmodule