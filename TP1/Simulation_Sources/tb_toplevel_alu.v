`timescale 1ns/100ps

module tb_toplevel_alu();
//module tb_alu();


localparam NB_DATA_BUS  = 8;
localparam NB_DBG_LED   = 2;
localparam NB_OPCODE    = 6;

/**
    Descomentar las lineas comentadas para generar tb del modulo alu.
    Ademas, comentar la definicion del modulo tb_toplevel_alu().
**/
//reg [NB_DATA_BUS-1 : 0]       tb_i_first_operator;
//reg [NB_DATA_BUS-1 : 0]       tb_i_second_operator;
//reg [NB_OPCODE-1 : 0]         tb_i_opcode;
//reg [NB_DATA_BUS-1 : 0]       tb_o_result;


reg                             tb_i_clock;
reg                             tb_i_valid;
reg     [NB_DATA_BUS-1 : 0]     tb_i_switch;
reg                             tb_i_btnL;
reg                             tb_i_btnC;
reg                             tb_i_btnR;
reg                             tb_i_btnU;
reg     [NB_DATA_BUS-1 : 0]     tb_counter;         //contador utilizado para controlar case

wire    [NB_DATA_BUS-1 : 0]     tb_o_led;
wire    [NB_DBG_LED-1 : 0]      tb_o_led_dbg;

initial 
begin
    
    tb_i_clock  = 1'b0;
    tb_i_valid  = 1'b0;
    tb_i_switch = {NB_DATA_BUS{1'b0}};
    tb_i_btnL   = 1'b0;
    tb_i_btnC   = 1'b0;
    tb_i_btnR   = 1'b0;
    tb_i_btnU   = 1'b1;
    tb_counter  = {NB_DATA_BUS{1'b0}};
#11
    tb_i_btnU   = 1'b0;
    tb_i_valid  = 1'b1;
end

always #2 tb_i_clock = ~tb_i_clock;

always @ (posedge tb_i_clock)
begin

    tb_counter <= tb_counter + 1;
    tb_i_switch <= tb_i_switch;
    tb_i_btnL <= tb_i_btnL;
   tb_i_btnC <= tb_i_btnC;
    tb_i_btnR <= tb_i_btnR;

    case (tb_counter)

        //ADD
        10'D10:
        begin
            tb_i_switch <= 8'b10100000;
            tb_i_btnL   <= 1'b1;
        end
        10'd16:
        begin
            tb_i_switch <= 8'b00001010;
            tb_i_btnL   <= 1'b0;
            tb_i_btnC   <= 1'b1;
        end
        10'd18:
        begin
            tb_i_switch <= 8'b00100000;      //opcode
            tb_i_btnC   <= 1'b0;
            tb_i_btnR   <= 1'b1;
        end
        10'd22:
        begin
            tb_i_btnR   <= 1'b0;
        end
        
        //SUB
        10'd30:
        begin
            tb_i_switch <= 8'b01110000;
            tb_i_btnL   <= 1'b1;
        end
        10'd34:
        begin
            tb_i_switch <= 8'b00110000;
            tb_i_btnL   <= 1'b0;
            tb_i_btnC   <= 1'b1;
        end
        10'd38:
        begin
            tb_i_switch <= 8'b00100010;      //opcode
            tb_i_btnC   <= 1'b0;
            tb_i_btnR   <= 1'b1;
        end
        10'd42:
        begin
            tb_i_btnR   <= 1'b0;
        end
        
        //AND
        10'd50:
        begin
            tb_i_switch <= 8'b11001000;
            tb_i_btnL   <= 1'b1;
        end
        10'd54:
        begin
            tb_i_switch <= 8'b00110001;
            tb_i_btnL   <= 1'b0;            
            tb_i_btnC   <= 1'b1;
        end
        10'd58:
        begin
            tb_i_switch <= 8'b00100100;      //opcode
            tb_i_btnC   <= 1'b0;            
            tb_i_btnR   <= 1'b1;
        end
        10'd62:
        begin
            tb_i_btnR   <= 1'b0;  
        end
            
        //OR
        10'd70:
        begin
            tb_i_switch <= 8'b10110000;
            tb_i_btnL   <= 1'b1;
        end
        10'd74:
        begin
            tb_i_switch <= 8'b00001011;
            tb_i_btnL   <= 1'b0;            
            tb_i_btnC   <= 1'b1;
        end
        10'd78:
        begin
            tb_i_switch <= 8'b00100101;      //opcode
            tb_i_btnC   <= 1'b0;            
            tb_i_btnR   <= 1'b1;
        end
        10'd92:
        begin
            tb_i_btnR   <= 1'b0;
        end  
    
        //XOR
        10'd100:
        begin
            tb_i_switch <= 8'b10101010;
            tb_i_btnL   <= 1'b1;
        end
        10'd104:
        begin
            tb_i_switch <= 8'b01010101;
            tb_i_btnL   <= 1'b0;            
            tb_i_btnC   <= 1'b1;
        end
        10'd108:
        begin
            tb_i_switch <= 8'b00100110;      //opcode
            tb_i_btnC   <= 1'b0;          
            tb_i_btnR   <= 1'b1;
        end
        10'd112:
        begin
            tb_i_btnR   <= 1'b0;
        end
    
        //SRA
        10'd120:
        begin
            tb_i_switch <= 8'b10001011;
            tb_i_btnL   <= 1'b1;
        end
        10'd124:
        begin
            tb_i_switch <= 8'b00000010;
            tb_i_btnL   <= 1'b0;            
            tb_i_btnC   <= 1'b1;
        end
        10'd128:
        begin
            tb_i_switch <= 8'b00000011;      //opcode
            tb_i_btnC   <= 1'b0;            
            tb_i_btnR   <= 1'b1;
        end
        10'd132:
        begin
            tb_i_btnR   <= 1'b0;
        end  
    
        //SRL
        10'd140:
        begin
            tb_i_switch <= 8'b10100000;
            tb_i_btnL   <= 1'b1;
        end
        10'd144:
        begin
            tb_i_switch <= 8'b00000100;
            tb_i_btnL   <= 1'b0;            
            tb_i_btnC   <= 1'b1;
        end
        10'd148:
        begin
            tb_i_switch <= 8'b00000010;      //opcode
            tb_i_btnC   <= 1'b0;            
            tb_i_btnR   <= 1'b1;
        end
        10'd152:
        begin
            tb_i_btnR   <= 1'b0;
        end    
    
        //NOR
        10'd160:
        begin
            tb_i_switch <= 8'b10100000;
            tb_i_btnL   <= 1'b1;
        end
        10'd164:
        begin
            tb_i_switch <= 8'b00000100;
            tb_i_btnL   <= 1'b0;            
            tb_i_btnC   <= 1'b1;
        end
        10'd168:
        begin
            tb_i_switch <= 8'b00100111;      //opcode
            tb_i_btnC   <= 1'b0;            
            tb_i_btnR   <= 1'b1;
        end
        10'd172:
        begin
            tb_i_btnR   <= 1'b0;  
        end  

   
        default:
        begin
            tb_i_switch <= 8'b00000000;
            tb_i_btnL   <= 1'b0;
            tb_i_switch <= 8'b00001010;
            tb_i_btnC   <= 1'b0;
            tb_i_switch <= 8'b00000000;      //opcode
            tb_i_btnR   <= 1'b0;
        end
 
    endcase   

end



toplevel_alu#(
             .NB_DATA_BUS(NB_DATA_BUS),
             .NB_DBG_LED(NB_DBG_LED),
             .NB_OPCODE(NB_OPCODE)
             )
u_toplevel_alu
             (
             .i_clock(tb_i_clock),
             .i_switch(tb_i_switch),
             .i_btnL(tb_i_btnL),
             .i_btnC(tb_i_btnC),
             .i_btnR(tb_i_btnR),
             .i_btnU(tb_i_btnU),
             .o_led(tb_o_led),
             .o_led_dbg(tb_o_led_dbg)
             );
             
/*
alu#*()
(
.i_first_operator(),
.i_second_operator(),
.i_opcode(),
..o_result()
);

*/
endmodule





