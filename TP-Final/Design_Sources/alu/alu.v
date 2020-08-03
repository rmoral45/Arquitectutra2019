`timescale 1ns/100ps

module alu
#(
    parameter                                           NB_DATA         = 32,
    parameter                                           NB_ALU_OPCODE   = 4    
)
(
    //Outputs
    output wire             [NB_DATA-1          : 0]    o_result            ,
    output wire                                         o_zero              ,

    //Inputs
    input wire              [NB_DATA-1          : 0]    i_first_operator    ,
    input wire              [NB_DATA-1          : 0]    i_second_operator   ,
    input wire              [NB_ALU_OPCODE-1    : 0]    i_opcode            ,
    input wire                                          i_signed_operation
);
    /*                              Localparameters                                 */
    
    localparam                                          ALU_SLL         = 4'b0000;
    localparam                                          ALU_SRL         = 4'b0010;
    localparam                                          ALU_SRA         = 4'b0011;
    localparam                                          ALU_SLLV        = 4'b1010;
    localparam                                          ALU_SRLV        = 4'b0110;
    localparam                                          ALU_SRAV        = 4'b0001;
    localparam                                          ALU_ADD         = 4'b1000;
    localparam                                          ALU_SUB         = 4'b1011;
    localparam                                          ALU_AND         = 4'b1100;
    localparam                                          ALU_OR          = 4'b1101;
    localparam                                          ALU_NOR         = 4'b0111;
    localparam                                          ALU_SLT         = 4'b1001;
    localparam                                          ALU_LUI         = 4'b1111;
    localparam                                          ALU_XOR         = 4'b1110;

    /*                              Internal Signals                                */
    reg                     [NB_DATA-1      : 0]        result;
    reg signed              [NB_DATA-1      : 0]        signed_first_operator;
    reg signed              [NB_DATA-1      : 0]        signed_second_operator;


    /*                              Alu algorithm begins                            */                                           
    always @ * 
    begin

        signed_first_operator                   =           i_first_operator;
        signed_second_operator                  =           i_second_operator;

            case(i_opcode)
                ALU_SLL             :   result  =           i_first_operator        <<      i_second_operator; 
                ALU_SLLV            :   result  =           i_first_operator        <<      i_second_operator; 
                ALU_SRL             :   result  =           i_first_operator        >>      i_second_operator; 
                ALU_SRLV            :   result  =           i_first_operator        >>      i_second_operator; 
                ALU_SRA             :   result  =           i_first_operator        >>>     i_second_operator;
                ALU_SRAV            :   result  =           i_first_operator        >>>     i_second_operator;
                ALU_ADD             :   result  =           (i_signed_operation)    ?       (signed_first_operator  + signed_second_operator) 
                                                                                    :       (i_first_operator       + i_second_operator);
                ALU_SUB             :   result  =           (i_signed_operation)    ?       (signed_first_operator  - signed_second_operator) 
                                                                                    :       (i_first_operator       - i_second_operator);
                ALU_AND             :   result  =           i_first_operator        &       i_second_operator;
                ALU_OR              :   result  =           i_first_operator        |       i_second_operator;
                ALU_XOR             :   result  =           i_first_operator        ^       i_second_operator;
                ALU_NOR             :   result  =           ~(i_first_operator      |       i_second_operator);
                //ALU_SLT             :   result  = {31'b0,   {(signed_first_operator <       signed_second_operator)}};
                ALU_SLT             :   result  = {31'b0,   {(i_first_operator <       i_second_operator)}};
                ALU_LUI             :   result  = {i_second_operator[(NB_DATA/2)-1 -: NB_DATA/2], {NB_DATA/2{1'b0}}};
                
                default             :   result  = {NB_DATA{1'b0}};
            
            endcase
    end

    //Module outputs
    assign      o_result                = result;
    assign      o_zero                  = (result == 32'b0);

endmodule
