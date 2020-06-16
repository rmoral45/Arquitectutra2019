`timescale 1ns/100ps

module alu_ctrl
#(
    parameter                                           NB_DATA                 = 32,
    parameter                                           NB_ADDR                 = $clog2(NB_DATA), 
    parameter                                           NB_CTRL_OPCODE          = 6,
    parameter                                           NB_ALU_OPCODE           = 4,
    parameter                                           NB_ALU_OP_SEL           = 2
)
(
    //Outputs
    output  wire                                        o_second_ope_sa,
    output  wire                                        o_first_ope_rt,
    output  wire            [NB_ALU_OPCODE-1    : 0]    o_alu_opcode,

    //Inputs
    input   wire            [NB_CTRL_OPCODE-1   : 0]    i_ctrl_opcode,
    input   wire            [NB_ALU_OP_SEL-1    : 0]    i_operation
);

    /*                                              Localparameters                                                 */
    localparam                                          CTRL_SLL        = 6'b000000;
    localparam                                          CTRL_SRL        = 6'b000010;
    localparam                                          CTRL_SRA        = 6'b000011;
    localparam                                          CTRL_SLLV       = 6'b001010;
    localparam                                          CTRL_SRLV       = 6'b000110;
    localparam                                          CTRL_SRAV       = 6'b000001;
    localparam                                          CTRL_ADD        = 6'b111100;
    localparam                                          CTRL_SUB        = 6'b001011;
    localparam                                          CTRL_AND        = 6'b100100;
    localparam                                          CTRL_OR         = 6'b111101;
    localparam                                          CTRL_XOR        = 6'b111110;
    localparam                                          CTRL_NOR        = 6'b100111;
    localparam                                          CTRL_SLT        = 6'b111001;  
    localparam                                          CTRL_JR         = 6'b001000;
    localparam                                          CTRL_LUI        = 6'b111111;

    localparam                                          ALU_ADD         = 4'b1100;
    localparam                                          ALU_SUB         = 4'b1011;
    localparam                                          ALU_SLL         = 4'b0000;
    localparam                                          ALU_SRL         = 4'b0010;  
    localparam                                          ALU_SRA         = 4'b0011;
    localparam                                          ALU_SLLV        = 4'b1010;
    localparam                                          ALU_SRLV        = 4'b0110;
    localparam                                          ALU_SRAV        = 4'b0001;

    localparam                                          RS_POS          = NB_DATA-1-NB_CTRL_OPCODE;
    localparam                                          SA_POS          = NB_DATA-1-NB_CTRL_OPCODE-3*NB_ADDR;
    localparam                                          OPCODE_POS      = NB_DATA-1-NB_CTRL_OPCODE-4*NB_ADDR;

    /*                                              Internal Signals                                                */
    wire                                                use_rf_sa;
    wire                                                use_rf_rt_first;
    reg                     [NB_ALU_OPCODE-1    : 0]    alu_opcode;
    


    /*                                              Alu control algorithm begins                                    */                                           
    assign                                              use_rf_sa               = ((alu_opcode == ALU_SLL) || (alu_opcode == ALU_SRL) || (alu_opcode == ALU_SRA));
    assign                                              use_rf_rt_first         = ((alu_opcode == ALU_SLLV) || (alu_opcode == ALU_SRLV) || (alu_opcode == ALU_SRAV));

    always @ *
    begin
        case(i_operation)
        begin
            2'b00:  RTYPE_INMEDIATE_INSTRUCTION_CASE
            begin
                alu_opcode = i_ctrl_opcode [NB_ALU_OPCODE-1 -: NB_ALU_OPCODE];
            end

            2'b01:  LOAD_STORE_INSTRUCTION_CASE
            begin
                alu_opcode = ALU_ADD;
            end
            
            2'b10:  BRANCH_INSTRUCTION_CASE
            begin
                alu_opcode = ALU_SUB;
            end

            default:
            begin
                alu_opcode = i_ctrl_opcode [NB_ALU_OPCODE-1 -: NB_ALU_OPCODE];
            end
        endcase
    end

    //Alu instantiation


    //Module outputs
    assign      o_alu_opcode    = alu_opcode;
    assign      o_second_ope_sa = use_rf_sa;
    assign      o_first_ope_rt  = use_rf_rt_first;

endmodule



