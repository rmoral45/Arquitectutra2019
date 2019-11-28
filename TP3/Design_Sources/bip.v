`timescale 1ns/100ps
module bip
#(
    parameter                           NB_INSTRUCTION  = 16,
    parameter                           NB_ADDR         = 11,
    parameter                           NB_OPCODE       = 5,
    parameter                           NB_OPERAND      = NB_INSTRUCTION-NB_OPCODE    
)
(
    input wire                          i_clock,
    input wire                          i_reset,
    
    output wire [NB_INSTRUCTION-1 : 0]  o_accumulator,
    output wire [NB_ADDR-1 : 0]         o_program_counter,
    output wire                         o_program_done
);

    localparam                          FILE = "/home/ramiro/repos/Arquitectutra2019/TP3/programas/programa4.txt";

//----------------------(BIP - TOPLEVEL)---------------------- 
    wire                                program_done;
    assign                              o_program_done = program_done;


//----------------------(ROM - CPU)---------------------- 
    wire        [NB_INSTRUCTION-1 : 0]  rom_data_cpu;

//----------------------(RAM - CPU)---------------------- 
    wire        [NB_INSTRUCTION-1 : 0]  ram_data_cpu;

//----------------------(CPU - RAM/ROM)------------------ 
    wire        [NB_ADDR-1 : 0]         cpu_addr_rom;
    wire        [NB_ADDR-1 : 0]         cpu_addr_ram;
    wire        [NB_INSTRUCTION-1 : 0]  cpu_data_ram;
    wire                                cpu_wrEnable_ram;
    wire                                cpu_rdEnable_ram;
    
    //mostramos el resultado de la operacion (acumulador) en los leds
    assign                              o_accumulator       = cpu_data_ram;
    assign                              o_program_counter   = cpu_addr_rom;

rom
#(
    .NB_INSTRUCTION (NB_INSTRUCTION),
    .NB_ADDR        (NB_ADDR),
    .FILE           (FILE)
)
u_rom
(
    .i_read_addr    (cpu_addr_rom),
    .o_data         (rom_data_cpu)
);

ram
#(
    .NB_INSTRUCTION (NB_INSTRUCTION),
    .NB_ADDR        (NB_ADDR)
)
u_ram
(
    .i_clock        (i_clock),
    .i_write_enable (cpu_wrEnable_ram),
    .i_write_address(cpu_addr_ram),
    .i_read_address (cpu_addr_ram),
    .i_data         (cpu_data_ram),
    .o_data         (ram_data_cpu)
);

cpu
#(
    .NB_INSTRUCTION (NB_INSTRUCTION),
    .NB_ADDR        (NB_ADDR),
    .NB_OPCODE      (NB_OPCODE),
    .NB_OPERAND     (NB_OPERAND)
)
u_cpu
(
    .i_clock        (i_clock),
    .i_reset        (i_reset),
    .i_rom_data     (rom_data_cpu),
    .i_ram_data     (ram_data_cpu),
    .o_rom_addr     (cpu_addr_rom),
    .o_ram_addr     (cpu_addr_ram),
    .o_ram_data     (cpu_data_ram),
    .o_ram_wr_enable(cpu_wrEnable_ram),
    .o_program_done (program_done)
);

endmodule