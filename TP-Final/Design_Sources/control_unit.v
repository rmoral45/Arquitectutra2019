`timescale 1ns/100ps

module control_unit
#(
    parameter                           NB_ADDR         =   5,
    parameter                           NB_DATA         =   2**NB_ADDR,
    parameter                           NB_ALU_OP_SEL   =   2
)
(
    //Outputs
    output wire                         o_rf_wr_data_src,
    output wire                         o_rf_wr_addr_src,
    output wire                         o_rf_wr_enb,
    output wire                         o_branch,
    output wire                         o_data_mem_rd_enb,
    output wire                         o_data_mem_wr_enb,
    output wire                         o_alu_data_src,
    output wire [NB_ALU_OP_SEL-1 : 0]   o_alu_operation,
    output wire                         o_signed_operation,
    output wire                         o_inmediate_operation,

    //Inputs
    input wire  [NB_ADDR-1  : 0]        i_instruction_type
);

    /*                                              Localparameters                                                 */
    //ITYPE instructions
    localparam                          LB              =   6'b100000;
    localparam                          LH              =   6'b100001;
    localparam                          LW              =   6'b100011;
    localparam                          LWU             =   6'b100111;
    localparam                          LBU             =   6'b100100;
    localparam                          LHU             =   6'b100101;
    localparam                          SB              =   6'b101000;
    localparam                          SH              =   6'b101000;
    localparam                          ANDI            =   6'b111100;
    localparam                          ORI             =   6'b111101;
    localparam                          XORI            =   6'b111110;
    localparam                          LUI             =   6'b111111;
    localparam                          SLTI            =   6'b111001;
    localparam                          BEQ             =   6'b101100;
    localparam                          BNE             =   6'b101101;
    localparam                          J               =   6'b110010;
    localparam                          JAL             =   6'b110011;
    //JTYPE instructions
    localparam                          JR              =   6'b011000;
    localparam                          JALR            =   6'b011001;


    /*                                              Internal Signals                                                */
    reg                                 rf_wr_addr_src;     //0 to rt, 1 to rd
    reg                                 rf_wr_data_src;     //0 from alu, 1 from data_memory
    reg                                 rf_wr_enb;
    reg                                 branch;
    reg                                 data_mem_rd_enb;
    reg                                 data_mem_wr_enb;
    reg         [NB_ALU_OP_SEL-1 : 0]   alu_operation;      //00 RTYPE, 01 ADD, 01 SUB
    reg                                 alu_data_src;       //0 from rf, 1 from instruction
    reg                                 signed_operation;
    reg                                 inmediate_operation;
    

    always @ *
    begin
        casez(instruction_type)
        begin

            6'b00????   : RTYPE_CASE
            begin
                rf_wr_addr_src          = 1'b1;
                rf_wr_data_src          = 1'b0;
                rf_wr_enb               = 1'b1;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b0;
                alu_operation           = 2'b00;
                signed_operation        = 1'b0;
                inmediate_operation     = 1'b0;
            end         
            
            6'b1000??   : LOAD_SIGNED_CASE
            begin
                rf_wr_addr_src          = 1'b0;
                rf_wr_data_src          = 1'b1;
                rf_wr_enb               = 1'b1;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b1;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b1;
                alu_operation           = 2'b01;
                signed_operation        = 1'b1;
                inmediate_operation     = 1'b0;
            end

            6'b1001??   : LOAD_UNS_CASE
            begin
                rf_wr_addr_src          = 1'b0;
                rf_wr_data_src          = 1'b1;
                rf_wr_enb               = 1'b1;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b1;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b1;
                alu_operation           = 2'b01;
                signed_operation        = 1'b0;
                inmediate_operation     = 1'b0;
            end            

            6'b1010??   : STORE_CASE
            begin
                rf_wr_addr_src          = 1'b0; //indistinto
                rf_wr_data_src          = 1'b1; //indistinto
                rf_wr_enb               = 1'b0;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b1;
                alu_data_src            = 1'b1;
                alu_operation           = 2'b01;
                signed_operation        = 1'b1;
                inmediate_operation     = 1'b0;
            end 

            6'b111???   : INMEDIATE_CASE
            begin
                rf_wr_addr_src          = 1'b1;
                rf_wr_data_src          = 1'b0;
                rf_wr_enb               = 1'b1;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b1;
                alu_operation           = 2'b00;
                signed_operation        = 1'b1;
                inmediate_operation     = 1'b1;
            end
            
            6'b1011??   : BRANCH_CASE
            begin
                rf_wr_addr_src          = 1'b0;
                rf_wr_data_src          = 1'b1;
                rf_wr_enb               = 1'b0;
                branch                  = 1'b1;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b0;
                alu_operation           = 2'b10;
                signed_operation        = 1'b0;          
                inmediate_operation     = 1'b0;
            end

            
            default: 
            begin

            end
        endcase 
    end

endmodule