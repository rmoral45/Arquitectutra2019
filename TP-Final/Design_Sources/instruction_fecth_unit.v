`timescale 1ns/100ps

module instruction_fetch_unit
#(
    parameter                               NB_ADDR                 =   5,
    parameter                               NB_DATA                 =   2**NB_ADDR,
    parameter                               ROM_DEPTH               =   1024,
    parameter                               FILE                    =   ""    
)
(
    //Outputs
    output wire [NB_DATA-1      : 0]        o_inst_fetched,
    output wire [NB_DATA-1      : 0]        o_pc_ltchd,

    //Inputs
    input wire                              i_enable,
    input wire                              i_pc_source,                            //0: pc+4; 1:pc+4+inmediate
    input wire  [NB_DATA-1      : 0]        i_branch_addr,
    input wire                              i_stall,
    
    //Write mode
    input wire  [NB_DATA-1      : 0]        i_data,
    input wire  [NB_ADDR-1      : 0]        i_wr_addr,
    input wire                              i_wr_enb,

    //Clocking
    input wire                              i_clock,
    input wire                              i_reset
);

    //Internal signals
    wire        [NB_DATA-1      : 0]        instruction_from_memory;
    reg         [NB_DATA-1      : 0]        instruction_fetched;
    reg         [NB_DATA-1      : 0]        pc;
    wire        [NB_DATA-1      : 0]        pc_next;
    wire        [NB_DATA-1      : 0]        pc_inc;
    wire                                    halt_flag;
    
    assign                                  halt_flag               =  (i_enable) ?  (instruction_from_memory == {NB_DATA{1'b0}}) : halt_flag;
    
    //PC Algorithm
    always @ (posedge i_clock)
    begin
        if(i_reset)
            pc                  <=          {NB_DATA{1'b0}};
        else if(halt_flag || i_stall)
            pc                  <=          pc;
        else if (i_enable)
            pc                  <=          pc_next;
    end

    assign                                  pc_inc                  =   pc + {{(NB_DATA-1){1'b0}}, 1'b1};
    //assign                                  pc_next                 =   i_pc_source ? pc_inc + i_branch_addr : pc_inc;
    assign                                  pc_next                 =   i_pc_source ? i_branch_addr : pc_inc;
                                                                        

    //Instruction fetching
    always @ (posedge i_clock)
    begin
        if(i_reset || i_pc_source || halt_flag)
            instruction_fetched <=          {NB_DATA{1'b0}};
        else if(i_stall)
            instruction_fetched <=          instruction_fetched;
        else if(i_enable)
            instruction_fetched <=          instruction_from_memory;
    end

    //Module instantiation
    program_memory
    #(
        .FILE                               (FILE)
    )
    u_program_memory
    (
        .o_data                             (instruction_from_memory),
        
        .i_read_addr                        (pc),
        .i_wr_enable                        (i_wr_enb),
        .i_wr_addr                          (i_wr_addr),
        .i_data                             (i_data),
        
        .i_clock                            (i_clock)                        
    );                                                                                                                                


    //Outputs asignment
    assign                                  o_inst_fetched          =   instruction_fetched;                                                                 
    assign                                  o_pc_ltchd              =   pc_inc;

endmodule                                                            