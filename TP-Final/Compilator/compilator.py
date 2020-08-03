import sys
sys.path.append('./*')
import re
import instruction_dictionary as inst_dict

NB_ADDR = 5
NB_IMM_OFF = 16
HALT = '0000000000000000'  
NB_INSTR_INDEX = 26

def main():

    test_case = raw_input('Ingrese test_case a compilar: ')

    testcase_asmfile = '../test/asm/' + test_case + '.asm'
    testcase_coefile = '../test/coe/' + test_case + '.txt'

    program_coe = open(testcase_coefile, 'w')
    program_asm = open(testcase_asmfile, 'r')
    instructions_per_line = program_asm.readlines()

    print("instructions_per_line: ", instructions_per_line)

    for instruction in instructions_per_line:
        
        raw_inst_list = filter(None, re.split(r'[,\s()]\n*', instruction))
        print("raw_inst_list: ", raw_inst_list)

        (function, code) = inst_dict.instructions.get(str(raw_inst_list[0]))

        bin_arg = [0]*len(raw_inst_list[1:])

        for index, arg in enumerate(raw_inst_list[1:]):
            if(code == 'rtype'):
                bin_arg[index] = bin(int(arg))[2:].zfill(NB_ADDR)
                #print(bin(int(arg))[2:].zfill(NB_ADDR))
            elif(code == 'itype'):
                if(index == 0 or index == 1):
                    bin_arg[index] = bin(int(arg))[2:].zfill(NB_ADDR)
                    #print(bin(int(arg))[2:].zfill(NB_ADDR))
                else:
                    bin_arg[index] = bin(int(arg))[2:].zfill(NB_IMM_OFF)
                    #print(bin(int(arg))[2:].zfill(NB_IMM_OFF))
            elif(code == 'itype2'):
                if(index == 0 or index == 2):
                    bin_arg[index] = bin(int(arg))[2:].zfill(NB_ADDR)
                else:
                    bin_arg[index] = bin(int(arg))[2:].zfill(NB_IMM_OFF)
            elif(code == 'jtype1'):
                bin_arg[index] = bin(int(arg))[2:].zfill(NB_INSTR_INDEX)
            elif(code == 'jtype2'):
                bin_arg[index] = bin(int(arg))[2:].zfill(NB_ADDR)
            elif(code == 'jtype3'):
                bin_arg[index] = bin(int(arg))[2:].zfill(NB_ADDR)
            elif(code == 'lui'):
                if(index == 0):
                    bin_arg[0] = bin(int(arg))[2:].zfill(NB_ADDR)
                else:
                    bin_arg[1] = bin(int(arg))[2:].zfill(NB_IMM_OFF)
            
        
        inst_to_coe = function(bin_arg)
        print("INSTRUCCION DECODIFICADA: %s | TAMANIO: %d ", (inst_to_coe, len(inst_to_coe)))
        program_coe.write(inst_to_coe+'\n')
        


    program_coe.write(str(0).zfill(32))

    program_asm.close()
    program_coe.close()
            
    return 


if __name__ == '__main__':
        main()