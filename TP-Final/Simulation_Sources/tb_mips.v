`timescale 1ns/100ps

module tb_mips;

localparam                              NB_ADDR         = 5;
localparam                              NB_DATA         = 32;
localparam                              NB_OPCODE       = 6;
localparam                              NB_ALU_OP_SEL   = 2;
localparam                              TEST_CASE       = "/home/ramiro/repos/Arquitectutra2019/TP-Final/test/coe/test2.coe"; 
localparam                              OPERATION_MODE  = 1;

reg                                     tb_clock, tb_reset, tb_enable;
//reg         [0          : NB_DATA-1]    instruction_from_file;      
//reg         [NB_DATA-1          : 0]    tb_instruction;
                                    

//integer                                 fid_test;
//integer                                 data_ptr;
//integer                                 errcode_rd_test;

initial
begin
        
    /*fid_test = $fopen(TEST_CASE, "r");
    if(fid_test == 0)
    begin
       $display("\n\nNO SE PUDO LEER EL TEST_CASE..\n\n");
       $stop;
    end*/

        tb_clock    = 1'b0;
        tb_reset    = 1'b1;
        tb_enable   = 1'b0;
    #10 tb_reset    = 1'b0;
    # 2 tb_enable   = 1'b1; 

end

always #1 tb_clock = ~tb_clock;

/*always @ (posedge tb_clock)
begin

    if(OPERATION_MODE)
    begin
        for(data_ptr = 0; data_ptr < NB_DATA; data_ptr = data_ptr + 1)
        begin
            errcode_rd_test <= $fscanf(fid_test, "%b\n", instruction_from_file[data_ptr]);
            if(errcode_rd_test != 1)
            begin
                $display("\n\nTEST_CASE: El caracter leido es invalido..\n\n");
                $stop;
            end
        end
    end

    tb_instruction <= instruction_from_file;
end*/

mips
#(
    .FILE(TEST_CASE)
)
u_mips
(
    //Outputs
    
    //Inputs
    .i_enable   (tb_enable),
    .i_clock    (tb_clock),
    .i_reset    (tb_reset)
);

endmodule


