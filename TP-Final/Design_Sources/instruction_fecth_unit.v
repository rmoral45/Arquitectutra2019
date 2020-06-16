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
    output wire [NB_ADDR-1      : 0]        o_pc_ltchd,

    //Inputs
    input wire                              i_pc_source,                            //0: pc+4; 1:pc+4+inmediate
    input wire  [NB_DATA-1      : 0]        i_branch_addr,

    //Clocking
    input wire                              i_clock
);

    //Internal signals
    reg         [NB_DATA-1      : 0]        instruction_memory;
    reg         [NB_DATA-1      : 0]        instruction_fetched;
    reg         [NB_ADDR-1      : 0]        pc;
    reg         [NB_ADDR-1      : 0]        pc_next;
    reg         [NB_ADDR-1      : 0]        pc_inc;

    //PC Algorithm
    always @ (posedge i_clock)
    begin
        pc                      <=          pc_next;
    end

    assign                                  pc_inc                  =   pc + {(NB_DATA-1){1'b0}, 1'b1};
    assign                                  pc_next                 =   i_pc_source ? pc_inc + i_branch_addr : pc_inc;
                                                                        

    //Instruction fetching
    always @ (posedge i_clock)
    begin
        instruction_fetched     <=          instruction_memory;
    end

    //Module instantiation
    program_memory
    #(
        .FILE                               (FILE)
    )
    u_program_memory
    (
        .o_data                             (instruction_memory),
        
        .i_read_addr                        (pc)
    );                                                                                                                                


    //Outputs asignment
    assign                                  o_inst_fetched          =   instruction_fetched;                                                                 
    assign                                  o_pc_ltchd              =   pc_inc;

endmodule                                                            