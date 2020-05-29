`timescale 1ns/100ps

module alu_ctrl
#(
    parameter                                           NB_DATA                 = 32,
    parameter                                           NB_ADDR                 = $clog2(NB_DATA), 
    parameter                                           NB_CTRL_OPCODE          = 6
)
(
    //Outputs
    output  wire            [NB_DATA-1          : 0]    o_result,
    output  wire                                        o_alu_zero,

    //Inputs
    input   wire            [NB_DATA-1          : 0]    i_instruction,
    input   wire            [NB_DATA-1          : 0]    i_rfile_rt,
    input   wire            [NB_DATA-1          : 0]    i_rfile_rs,
    input   wire                                        i_signed_operation
);
    //[IMPORTANT]:  The add and sub signed versions usage will be determined by 
    //              the assert of the i_signed_operation flag.

    /*                                              Localparameters                                                 */
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SLL                = 6'b000000;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SRL                = 6'b000010;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SRA                = 6'b000011;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SLLV               = 6'b000100;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SRLV               = 6'b000110;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SRAV               = 6'b000111;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_ADD                = 6'b100001;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SUB                = 6'b100011;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_AND                = 6'b100100;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_OR                 = 6'b100101;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_XOR                = 6'b100110;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_NOR                = 6'b100111;
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_SLT                = 6'b101010;  
    localparam              [NB_CTRL_OPCODE-1   : 0]    CTRL_JR                 = 6'b001000;
    
    localparam                                          NB_ALU_OPCODE           = 4;

    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_SLL                 = 4'b0000;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_SRL                 = 4'b0010;  
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_SRA                 = 4'b0011;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_ADD                 = 4'b0001;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_SUB                 = 4'b1101;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_AND                 = 4'b0100;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_OR                  = 4'b0101;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_XOR                 = 4'b0110;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_NOR                 = 4'b0111;
    localparam              [NB_ALU_OPCODE-1    : 0]    ALU_SLT                 = 4'b1111;

    localparam                                          RS_POS                  = NB_DATA-1-NB_CTRL_OPCODE;
    localparam                                          SA_POS                  = NB_DATA-1-NB_CTRL_OPCODE-3*NB_ADDR;
    localparam                                          OPCODE_POS              = NB_DATA-1-NB_CTRL_OPCODE-4*NB_ADDR;

    /*                                              Internal Signals                                                */
    wire                                                signed_operation;
    wire                    [NB_CTRL_OPCODE-1   : 0]    alu_ctrl_opcode;
    wire                    [NB_ADDR-1          : 0]    instruction_sa;
    wire                    [NB_DATA-1          : 0]    alu_result;
    wire                                                alu_zero_flag;

    reg                     [NB_DATA-1          : 0]    alu_first_operator;
    reg                     [NB_DATA-1          : 0]    alu_second_operator;
    reg                     [NB_ALU_OPCODE-1    : 0]    alu_opcode;


    /*                                              Alu control algorithm begins                                    */                                           
    assign                                              alu_ctrl_opcode         = i_instruction[OPCODE_POS  -: NB_OPCODE];
    assign                                              instruction_sa          = i_instruction[SA_POS      -: NB_ADDR];

    always @ *
    begin
        case(alu_ctrl_opcode)
        begin
            CTRL_SLL:
            begin
                alu_first_operator  = i_rfile_rt;
                alu_second_operator = instruction_sa;
                alu_opcode          = ALU_SLL;
            end

            CTRL_SRL:
            begin
                alu_first_operator  = i_rfile_rt;
                alu_second_operator = instruction_sa;
                alu_opcode          = ALU_SRL;
            end

            CTRL_SRA:
            begin
                alu_first_operator  = i_rfile_rt;
                alu_second_operator = instruction_sa;
                alu_opcode          = ALU_SRA;
            end

            CTRL_SLLV:
            begin
                alu_first_operator  = i_rfile_rt;
                alu_second_operator = i_rfile_rs[NB_ADDR-1 -: NB_ADDR];
                alu_opcode          = ALU_SLL;
            end

            CTRL_SRLV:
            begin
                alu_first_operator  = i_rfile_rt;
                alu_second_operator = i_rfile_rs[NB_ADDR-1 -: NB_ADDR];
                alu_opcode          = ALU_SRL;
            end

            CTRL_SRAV:
            begin
                alu_first_operator  = i_rfile_rt;
                alu_second_operator = i_rfile_rs[NB_ADDR-1 -: NB_ADDR];
                alu_opcode          = ALU_SRA;
            end

            CTRL_ADD:
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_ADD;                
            end

            CRTL_SUB:
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_SUB;                                
            end

            CTRL_AND:
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_AND;                                                
            end

            CTRL_OR:
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_OR;                                
            end

            CTRL_XOR:
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_XOR;                                
            end

            CTRL_NOR:
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_NOR;                                
            end

            CTRL_SLT
            begin
                alu_first_operator  = i_rfile_rs;
                alu_second_operator = i_rfile_rt;
                alu_opcode          = ALU_SLT;                                
            end
        endcase
    end

    //Alu instantiation
    alu
    u_alu
    (
                .o_result           (alu_result         ),
               
                .i_first_operator   (alu_first_operator ),
                .i_second_operator  (alu_second_operator),
                .i_opcode           (alu_opcode         ),
                .i_signed_operation (i_signed_operation )
    );

    //Module outputs
    assign      o_result            = alu_result;
    assign      o_alu_zero          = alu_zero_flag;

endmodule


