#for r-type format is: 000000+args+alu_ctrl_opcode (last defined in alu_ctrl.v as localparams)

def sll(arg_list):
    return '000000'+'00000'+arg_list[1]+arg_list[0]+arg_list[2]+'000000'
    #return '000000'+'00000'+arg_1+arg_0+arg_2+'000000'

def srl(arg_list):
    return '000000'+'00000'+arg_list[1]+arg_list[0]+arg_list[2]+'000010'
    #return '000000'+'00000'+arg_1+arg_0+arg_2+'000010'

def sra(arg_list):
    return '000000'+'00000'+arg_list[1]+arg_list[0]+arg_list[2]+'000011'

def sllv(arg_list):
    return '000000'+arg_list[2]+arg_list[1]+arg_list[0]+'00000'+'001010'
    
def srlv(arg_list):
    return '000000'+arg_list[2]+arg_list[1]+arg_list[0]+'00000'+'000110'

def srav(arg_list):
    return '000000'+arg_list[2]+arg_list[1]+arg_list[0]+'00000'+'000001'

def add(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'111000'

def sub(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'001011'

def andinst(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'111100'

def orinst(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'111101'

def xor(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'111110'

def nor(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'100111'

def slt(arg_list):
    return '000000'+arg_list[1]+arg_list[2]+arg_list[0]+'00000'+'111001'

# instruction will be decoded by the compiller as follows: rt,offset(base) --> rt: arg_0, offset: arg_1, base: arg_2
# for i-type format is: alu_ctrl_opcode+arg_2+arg_0+arg_1
def lb(arg_list): #alu_ctrl_opcode: load - alu_opcode: add
    return '100000'+arg_list[2]+arg_list[0]+arg_list[1]

def lh(arg_list): #alu_ctrl_opcode: load - alu_opcode: add
    return '100001'+arg_list[2]+arg_list[0]+arg_list[1]

def lw(arg_list): #alu_ctrl_opcode: load - alu_opcode: add
    return '100011'+arg_list[2]+arg_list[0]+arg_list[1]

def lwu(arg_list): #alu_ctrl_opcode: load - alu_opcode: add
    return '100111'+arg_list[2]+arg_list[0]+arg_list[1]

def lbu(arg_list): #alu_ctrl_opcode: load - alu_opcode: add
    return '100100'+arg_list[2]+arg_list[0]+arg_list[1]

def lhu(arg_list): #alu_ctrl_opcode: load - alu_opcode: add
    return '100101'+arg_list[2]+arg_list[0]+arg_list[1]    

def sb(arg_list): #alu_ctrl_opcode: store - alu_opcode: add
    return '101000'+arg_list[2]+arg_list[0]+arg_list[1] 

def sh(arg_list): #alu_ctrl_opcode: store - alu_opcode: add   
    return '101001'+arg_list[2]+arg_list[0]+arg_list[1] 

def sw(arg_list): #alu_ctrl_opcode: store - alu_opcode: add
    return '101011'+arg_list[2]+arg_list[0]+arg_list[1]    
 
# immediate instructions will be decoded by the compiller as follows: rt,rs,immediate --> rt: arg_0, rs: arg_1, immediate: arg_2
def addi(arg_list): #alu_ctrl_opcode: add   
    return '111000'+arg_list[2]+arg_list[0]+arg_list[1]    

def andi(arg_list): #alu_ctrl_opcode: and   
    return '111100'+arg_list[2]+arg_list[0]+arg_list[1]     

def ori(arg_list): #alu_ctrl_opcode: or   
    return '111101'+arg_list[2]+arg_list[0]+arg_list[1]         

def xori(arg_list): #alu_ctrl_opcode: xor   
    return '111110'+arg_list[2]+arg_list[0]+arg_list[1]         

def slti(arg_list): #alu_ctrl_opcode: slt 
    return '111001'+arg_list[2]+arg_list[0]+arg_list[1]     

#lui: rt,immediate --> rt: arg_0, immediate: arg_1
def lui(arg_list): #alu_ctrl_opcode: his own  
    return '111111'+'00000'+arg_list[0]+arg_list[1] 

#branchs: rs,rt,offset --> rs: arg_0, rt: arg_1, offset: arg_2
def beq(arg_list): #alu_ctrl_opcode: his own - alu_opcode: sub
    return '101100'+arg_list[0]+arg_list[1]+arg_list[2]

def bne(arg_list): #alu_ctrl_opcode: his own - alu_opcode: sub
    return '101101'+arg_list[0]+arg_list[1]+arg_list[2]

#falta implementar: jr, jalr, j, jal

instructions = {
        'SLL': (sll, 'rtype'),
        'SRL': (srl, 'rtype'),
        'SRA': (sra, 'rtype'),
        'SLLV': (sllv, 'rtype'),
        'SRLV': (srlv, 'rtype'), 
        'SRAV': (srav, 'rtype'),
        'ADD': (add, 'rtype'),
        'SUB': (sub, 'rtype'),
        'AND': (andinst, 'rtype'), 
        'OR': (orinst, 'rtype'),
        'XOR': (xor, 'rtype'),
        'NOR': (nor, 'rtype'),
        'SLT': (slt, 'rtype'),
        #'JR': jr, 
        #'JALR': jalr,
        'LB': (lb, 'itype'),
        'LH': (lh, 'itype'),
        'LW': (lw, 'itype'), 
        'LWU': (lwu, 'itype'),
        'LBU': (lbu, 'itype'),
        'LHU': (lhu, 'itype'),
        'SB': (sb, 'itype'),
        'SH': (sh, 'itype'),
        'SW': (sw, 'itype'),
        'ADDI': (addi, 'itype'),
        'ANDI': (andi, 'itype'), 
        'ORI': (ori, 'itype'),
        'XORI': (xori, 'itype'),
        'LUI': (lui, 'lui'), 
        'SLTI': (slti, 'itype'),
        'BEQ': (beq, 'itype'),
        'BNE': (bne, 'itype')
        #'J': j,
        #'JAL': jal
}