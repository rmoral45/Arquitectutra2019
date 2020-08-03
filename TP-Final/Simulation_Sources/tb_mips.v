`timescale 1ns/100ps

module tb_mips;

localparam                              NB_ADDR         = 5;
localparam                              NB_DATA         = 32;
localparam                              ROM_DEPTH       = 30;
localparam                              NB_OPCODE       = 6;
localparam                              NB_ALU_OP_SEL   = 2;
localparam                              TEST_CASE       = "/home/ramiro/repos/Arquitectutra2019/TP-Final/test/coe/test1.coe"; 
localparam                              OPERATION_MODE  = 2'b10;



reg                                     tb_clock, tb_reset;
reg         [NB_DATA-1      : 0]        tb_counter;
reg                                     tb_enable;
reg                                     tb_write_mode;
reg                                     tb_enable_sim;

reg         [NB_ADDR-1      : 0]        tb_prog_mem_wr_ptr;
reg         [NB_DATA-1   : 0]           rom [ROM_DEPTH-1 : 0];
reg         [NB_DATA-1      : 0]        instruction;

localparam                              STEP_BY_STEP_MODE = 2'b10;
localparam                              CONTINUOUS_MODE   = 2'b01;


initial
begin   
        $readmemb(TEST_CASE, rom, 0, ROM_DEPTH-1);
        
        tb_clock            = 1'b0;
        tb_reset            = 1'b1;
        tb_enable           = 1'b0;
        tb_counter          = {NB_DATA{1'b0}};
        tb_prog_mem_wr_ptr  = {NB_ADDR{1'b0}};
        instruction         = {NB_DATA{1'b1}};
        tb_enable_sim       = 1'b0;
        tb_write_mode       = 1'b0;
    #10 tb_reset            = 1'b0;
    # 2 tb_write_mode       = 1'b1;
end

always #1 tb_clock = ~tb_clock;

//######### PROGRAM MEMORY WRITE MODE ############
always @ (*)
begin
    instruction = rom[tb_prog_mem_wr_ptr];
end

always @ (posedge tb_clock)
begin
   if(tb_write_mode)
    begin
  
        tb_prog_mem_wr_ptr      <= tb_prog_mem_wr_ptr + 1'b1;
        
        if(instruction == {NB_DATA{1'b0}})
        begin
            tb_write_mode       <= 1'b0;
            tb_enable_sim       <= 1'b1;
        end
    end
end
//###################################################

//####### STEP BY STEP or CONTINUOUS MODE ###########
always @ (posedge tb_clock)
begin
    
    if(tb_enable_sim)
    begin
   
        if(OPERATION_MODE == STEP_BY_STEP_MODE)
        begin
        
            tb_counter <= tb_counter + 1'b1; 
        
            case(tb_counter)
                10'D5:
                    tb_enable <= 1'b1;
                10'D8:
                    tb_enable <= ~tb_enable;                    
                10'D15:
                    tb_enable <= ~tb_enable;
                10'D17:
                    tb_enable <= ~tb_enable;
                10'D25:
                    tb_enable <= ~tb_enable;  
                10'D27:
                    tb_enable <= ~tb_enable;            
                10'D35:
                    tb_enable <= ~tb_enable;     
                10'D37:
                    tb_enable <= ~tb_enable;  
                10'D45:
                    tb_enable <= ~tb_enable;              
                10'D47:
                    tb_enable <= ~tb_enable;   
                10'D55:
                    tb_enable <= ~tb_enable;
                10'D57:
                    tb_enable <= ~tb_enable;   
                10'D65:
                    tb_enable <= ~tb_enable;
                10'D67:
                    tb_enable <= ~tb_enable;   
                /*10'D75:
                    tb_enable <= ~tb_enable; */               
                                                                                                       
            endcase
       end
       else
       begin
                    tb_enable <= 1'b1;
       end
   end
end
//###################################################

mips
#(
    .FILE(TEST_CASE)
)
u_mips
(
    
    //Inputs
    .i_prog_mem_wr_enb  (tb_write_mode),
    .i_prog_mem_wr_addr (tb_prog_mem_wr_ptr),
    .i_data             (instruction),    
    .i_enable           (tb_enable),
    .i_clock            (tb_clock),
    .i_reset            (tb_reset)
);

endmodule


