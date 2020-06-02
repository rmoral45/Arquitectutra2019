`timescale 1ns/100ps

module alu_ctrl
#(
    parameter                                           NB_DATA                 = 32,
    parameter                                           NB_ADDR                 = $clog2(NB_DATA), 
    parameter                                           NB_CTRL_OPCODE          = 6,
    parameter                                           NB_ALU_OP_SEL           = 2
)
(
    //Outputs
    output  wire            [NB_DATA-1          : 0]    o_result,
    output  wire                                        o_alu_zero,

    //Inputs
    input   wire            [NB_DATA-1          : 0]    i_instruction,
    input   wire            [NB_DATA-1          : 0]    i_rfile_rt,
    input   wire            [NB_DATA-1          : 0]    i_rfile_rs,
    input   wire            [NB_ALU_OP_SEL-1    : 0]    i_operation,
    input   wire                                        i_signed_operation,
    input   wire                                        i_inmediate_operation
);
    //[IMPORTANT]:  The add and sub signed versions usage will be determined by 
    //              the assert of the i_signed_operation flag.

    /*                                              Localparameters                                                 */
    localparam                                          CTRL_SLL        = 6'b000000;
    localparam                                          CTRL_SRL        = 6'b000010;
    localparam                                          CTRL_SRA        = 6'b000011;
    localparam                                          CTRL_SLLV       = 6'b000100;
    localparam                                          CTRL_SRLV       = 6'b000110;
    localparam                                          CTRL_SRAV       = 6'b000111;
    localparam                                          CTRL_ADD        = 6'b111100;
    localparam                                          CTRL_SUB        = 6'b001011;
    localparam                                          CTRL_AND        = 6'b100100;
    localparam                                          CTRL_OR         = 6'b111101;
    localparam                                          CTRL_XOR        = 6'b111110;
    localparam                                          CTRL_NOR        = 6'b100111;
    localparam                                          CTRL_SLT        = 6'b111001;  
    localparam                                          CTRL_JR         = 6'b001000;
    localparam                                          CTRL_LUI        = 6'b111111;

    
    localparam                                          NB_ALU_OPCODE   = 4;

    localparam                                          ALU_SLL         = 4'b0000;
    localparam                                          ALU_SRL         = 4'b0010;  
    localparam                                          ALU_SRA         = 4'b0011;
    localparam                                          ALU_ADD         = 4'b1100;
    localparam                                          ALU_SUB         = 4'b1011;
    localparam                                          ALU_AND         = 4'b0100;
    localparam                                          ALU_OR          = 4'b1101;
    localparam                                          ALU_XOR         = 4'b1110;
    localparam                                          ALU_NOR         = 4'b0111;
    localparam                                          ALU_SLT         = 4'b1001;
    localparam                                          ALU_LUI         = 4'b1111;

    localparam                                          RS_POS          = NB_DATA-1-NB_CTRL_OPCODE;
    localparam                                          SA_POS          = NB_DATA-1-NB_CTRL_OPCODE-3*NB_ADDR;
    localparam                                          OPCODE_POS      = NB_DATA-1-NB_CTRL_OPCODE-4*NB_ADDR;

    /*                                              Internal Signals                                                */
    wire                    [NB_CTRL_OPCODE-1   : 0]    alu_ctrl_opcode;
    wire                    [NB_ADDR-1          : 0]    instruction_sa;
    wire                    [NB_DATA-1          : 0]    alu_result;
    wire                                                alu_zero_flag;

    reg                     [NB_DATA-1          : 0]    alu_first_operator;
    reg                     [NB_DATA-1          : 0]    alu_second_operator;
    reg                     [NB_ALU_OPCODE-1    : 0]    alu_opcode;


    /*                                              Alu control algorithm begins                                    */                                           
    assign                                              alu_ctrl_opcode         = (i_inmediate_operation)   ? i_instruction[NB_DATA-1   -: NB_CTRL_OPCODE];
                                                                                                            : i_instruction[OPCODE_POS  -: NB_CTRL_OPCODE];
    assign                                              instruction_sa          = i_instruction[SA_POS      -: NB_ADDR];


    always @ *
    begin
        case(i_operation)
        begin
            2'b00:  RTYPE_INMEDIATE_INSTRUCTION_CASE
            begin
                alu_opcode = alu_ctrl_opcode [NB_ALU_OPCODE-1 -: NB_ALU_OPCODE];
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
                alu_opcode = alu_ctrl_opcode [NB_ALU_OPCODE-1 -: NB_ALU_OPCODE];
            end
        endcase
    end

    //Alu instantiation
    alu
    u_alu
    (
                .o_result           (alu_result         ),
                .o_zero             (alu_zero_flag)      ,
               
                .i_first_operator   (alu_first_operator ),
                .i_second_operator  (alu_second_operator),
                .i_opcode           (alu_opcode         ),
                .i_signed_operation (i_signed_operation )
    );

    //Module outputs
    assign      o_result            = alu_result;
    assign      o_alu_zero          = alu_zero_flag;

endmodule



