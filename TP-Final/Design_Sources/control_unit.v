`timescale 1ns/100ps

module control_unit
#(
    parameter                                   NB_ADDR                     =   5,
    parameter                                   NB_DATA                     =   2**NB_ADDR,
    parameter                                   NB_OPCODE                   =   6,
    parameter                                   NB_ALU_OP_SEL               =   2,
    parameter                                   NB_LOAD_STORE_SEL           =   2
)
(
    //Outputs
    output wire                                 o_rf_wr_data_src,
    output wire                                 o_rf_wr_addr_src,
    output wire                                 o_rf_wr_enb,
    output wire                                 o_branch,
    output wire                                 o_jump,
    output wire                                 o_link,
    output wire                                 o_data_mem_rd_enb,
    output wire                                 o_data_mem_wr_enb,
    output wire                                 o_alu_data_src,
    output wire [NB_ALU_OP_SEL-1        : 0]    o_alu_operation,
    output wire                                 o_signed_operation,
    output wire                                 o_inmediate_operation,
    output wire [NB_LOAD_STORE_SEL-1    : 0]    o_load_store_sel,
    
    //Inputs
    input wire  [NB_OPCODE-1            : 0]    i_instruction_opcode
);

    //Localparameters
    //ITYPE instructions
    localparam                                  LB                          =   6'b100000;
    localparam                                  LH                          =   6'b100001;
    localparam                                  LW                          =   6'b100011;
    localparam                                  LWU                         =   6'b100111;
    localparam                                  LBU                         =   6'b100100;
    localparam                                  LHU                         =   6'b100101;
    localparam                                  SB                          =   6'b101000;
    localparam                                  SH                          =   6'b101001;
    localparam                                  SW                          =   6'b101011;
    localparam                                  ADDI                        =   6'b111000;
    localparam                                  ANDI                        =   6'b111100;
    localparam                                  ORI                         =   6'b111101;
    localparam                                  XORI                        =   6'b111110;
    localparam                                  LUI                         =   6'b111111;
    localparam                                  SLTI                        =   6'b111001;
    localparam                                  BEQ                         =   6'b101100;
    localparam                                  BNE                         =   6'b101101;
    
    //jumps
    localparam                                  J                           =   6'b110010;
    localparam                                  JR                          =   6'b110001;
    localparam                                  JAL                         =   6'b011001;
    localparam                                  JALR                        =   6'b011011;


    localparam                                  LOAD_STORE_WORD             =   2'b00;
    localparam                                  LOAD_STORE_BYTE             =   2'b01;
    localparam                                  LOAD_STORE_HALF             =   2'b10;


    //Internal Signals
    reg                                         rf_wr_addr_src;     //0 to rt, 1 to rd
    reg                                         rf_wr_data_src;     //0 from alu, 1 from data_memory
    reg                                         rf_wr_enb;
    reg                                         branch;
    reg                                         jump;
    reg                                         data_mem_rd_enb;
    reg                                         data_mem_wr_enb;
    reg         [NB_ALU_OP_SEL-1        : 0]    alu_operation;      //00 RTYPE, 01 ADD, 01 SUB
    reg                                         alu_data_src;       //0 from rf, 1 from instruction
    reg                                         signed_operation;
    reg                                         inmediate_operation;
    wire                                        memory_operation_case;  //00 for load/store word; 01 for byte; 10 for halfword

    assign                                      memory_operation_case       =   (i_instruction_opcode == LH || i_instruction_opcode == SH)    ?   LOAD_STORE_HALF :
                                                                                (i_instruction_opcode == LB || i_instruction_opcode == SB)    ?   LOAD_STORE_BYTE :
                                                                                                                                                  LOAD_STORE_WORD ;

    //wire                                        link;
    //assign                                      link                        =   (i_instrruction_opcode == JAL) || (i_instrruction_opcode == JALR) ? 1'b1 : 1'b0;

    //Control logic algorithm
    always @ *
    begin
        casez(i_instruction_opcode)
            6'b0000??   : //RTYPE_CASE
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
                //load_operation          = 1'b0;
                jump                    = 1'b0;
            end         
            
            6'b1000??   :// LOAD_SIGNED_CASE
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
                //load_operation          = 1'b1;
                jump                    = 1'b0;
                
            end

            6'b1001??   :// LOAD_UNS_CASE
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
                //load_operation          = 1'b1;
                jump                    = 1'b0;
            end            

            6'b1010??   : //STORE_CASE
            begin
                rf_wr_addr_src          = 1'b0; //indistinto
                rf_wr_data_src          = 1'b1; 
                rf_wr_enb               = 1'b0;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b1;
                alu_data_src            = 1'b1;
                alu_operation           = 2'b01;
                signed_operation        = 1'b1;
                inmediate_operation     = 1'b0;
                //load_operation          = 1'b1;
                jump                    = 1'b0;
            end 

            6'b111???   : //INMEDIATE_CASE
            begin
                rf_wr_addr_src          = 1'b0; //to rt
                rf_wr_data_src          = 1'b0; //from alu
                rf_wr_enb               = 1'b1; //enabling writing in rf
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b1; //alu operand from instruction
                alu_operation           = 2'b00;//rtype alu_ctrl opcode
                signed_operation        = 1'b1; 
                inmediate_operation     = 1'b1; //is immediate operation
                //load_operation          = 1'b0;
                jump                    = 1'b0;
            end
            
            6'b1011??   :// BRANCH_CASE
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
                inmediate_operation     = 1'b1;
                //load_operation          = 1'b0;
                jump                    = 1'b0;
            end

            6'b1100??: //link JUMPS
            begin
                rf_wr_addr_src          = 1'b0;
                rf_wr_data_src          = 1'b0;
                rf_wr_enb               = 1'b1;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b0;
                alu_operation           = 2'b00;
                signed_operation        = 1'b0;
                inmediate_operation     = 1'b0;
                //load_operation          = 1'b0;
                jump                    = 1'b1;
            end

            6'b0110??: //JUMPS
            begin
                rf_wr_addr_src          = 1'b0;
                rf_wr_data_src          = 1'b0;
                rf_wr_enb               = 1'b0;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b0;
                alu_operation           = 2'b00;
                signed_operation        = 1'b0;
                inmediate_operation     = 1'b0;
                //load_operation          = 1'b0;
                jump                    = 1'b1;
            end

            
            default: //DEFAULT CASE ALL 0's
            begin
                rf_wr_addr_src          = 1'b0;
                rf_wr_data_src          = 1'b0;
                rf_wr_enb               = 1'b0;
                branch                  = 1'b0;
                data_mem_rd_enb         = 1'b0;
                data_mem_wr_enb         = 1'b0;
                alu_data_src            = 1'b0;
                alu_operation           = 2'b00;
                signed_operation        = 1'b0;
                inmediate_operation     = 1'b0;
                //load_operation          = 1'b0;
            end
        endcase 
    end

    //Outputs
    assign                              o_rf_wr_data_src        = rf_wr_data_src;
    assign                              o_rf_wr_addr_src        = rf_wr_addr_src;
    assign                              o_rf_wr_enb             = rf_wr_enb;
    assign                              o_branch                = branch;
    assign                              o_jump                  = jump;
    //assign                              o_link                  = link;
    assign                              o_data_mem_rd_enb       = data_mem_rd_enb;
    assign                              o_data_mem_wr_enb       = data_mem_wr_enb;
    assign                              o_alu_data_src          = alu_data_src;
    assign                              o_alu_operation         = alu_operation;
    assign                              o_signed_operation      = signed_operation;
    assign                              o_inmediate_operation   = inmediate_operation;     
    assign                              o_load_store_sel        = memory_operation_case;   
endmodule