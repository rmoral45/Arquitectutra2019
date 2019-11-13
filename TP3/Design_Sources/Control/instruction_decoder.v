`timescale 1ns/100ps
module instruction_decoder
#(
    parameter                           NB_OPCODE       = 5,
    parameter                           NB_SELECTOR_A   = 2
)
(
    input wire  [NB_OPCODE-1 : 0]       i_opcode,
    output wire                         o_enb_pc,                       //en el paper es la señal wr_pc
    output wire [NB_SELECTOR_A-1 : 0]   o_sel_a,
    output wire                         o_sel_b,
    output wire                         o_enb_acc,                      //en el paper es la señal wr_acc
    output wire                         o_operation,
    output wire                         o_wr_enb_ram,
    output wire                         o_rd_enb_ram
);

    //OPCODES
    localparam  [NB_OPCODE-1 : 0]       HALT            = 5'b00000;
    localparam  [NB_OPCODE-1 : 0]       STORE           = 5'b00001;
    localparam  [NB_OPCODE-1 : 0]       LOAD            = 5'b00010;
    localparam  [NB_OPCODE-1 : 0]       LOADI           = 5'b00011;
    localparam  [NB_OPCODE-1 : 0]       ADD             = 5'b00100;
    localparam  [NB_OPCODE-1 : 0]       ADDI            = 5'b00101;
    localparam  [NB_OPCODE-1 : 0]       SUB             = 5'b00110;
    localparam  [NB_OPCODE-1 : 0]       SUBI            = 5'b00111;

    /*--SELECTOR A 
    *   Default state - do nothing = 2'b11
    *   Read from ram - write on acc = 2'b00
    *   Read from i_data - write on acc = 2'b1
    *   
    *
    *************/

    reg                                 enb_pc;
    reg [NB_SELECTOR_A-1 : 0]           sel_a;
    reg                                 sel_b;
    reg                                 enb_acc;
    reg                                 operation;                      //1'b1 = suma, 1'b0 = resta
    reg                                 wr_enb_ram;
    reg                                 rd_enb_ram;

    always @ *
    begin
        enb_pc      = 1'b0;
        sel_a       = 2'b11;
        sel_b       = 1'b0;
        enb_acc     = 1'b0;
        operation   = 1'b0;
        wr_enb_ram  = 1'b0;
        rd_enb_ram  = 1'b0;

        case(i_opcode)

            HALT:
            begin
                enb_pc      =   1'b0;
                enb_acc     =   1'b0;
            end

            STORE:
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
            end

            LOAD:
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
                sel_a       =   2'b00;
            end

            LOADI:
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
                sel_a       =   2'b01;
            end

            ADD:
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
                operation   =   1'b1;
                sel_a       =   2'b10;
                sel_b       =   1'b1;
            end

            ADDI:
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
                operation   =   1'b1;
                sel_a       =   2'b10;
                sel_b       =   1'b0;
            end

            SUB:                
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
                operation   =   1'b0;
                sel_a       =   2'b10;
                sel_b       =   1'b1;
            end

            SUBI:                
            begin
                enb_pc      =   1'b1;
                enb_acc     =   1'b1;
                operation   =   1'b0;
                sel_a       =   2'b10;
                sel_b       =   1'b0;
            end                

            default:
            begin
            enb_pc          = 1'b0;
            sel_a           = 2'b11;
            sel_b           = 1'b0;
            enb_acc         = 1'b0;
            operation       = 1'b0;
            wr_enb_ram      = 1'b0;
            rd_enb_ram      = 1'b0;
            end
        endcase

    end