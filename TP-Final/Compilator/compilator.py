import sys
sys.path.append('./*')
import re
import instruction_dictionary as inst_dict


def main():

    program_coe = open('../test/coe/test0.coe', 'w')
    program_asm = open('../test/asm/test0.asm', 'r')
    instructions_per_line = program_asm.readlines()

    print("instructions_per_line: ", instructions_per_line)

    for instruction in instructions_per_line:

        print("typeof instruction: \n\n", type(instruction))
        
        raw_inst_list = filter(None, re.split(r'[,\s()]\n*', instruction))
        print("raw_inst_list: ", raw_inst_list)
        #print("typeof raw_inst_list: \n\n", type(raw_inst_list[0]))

        function = inst_dict.instructions.get(str(raw_inst_list[0]))

        print("ARG_LIST: ", raw_inst_list[1:])

        ##FALTA CONVERTIR A BINARIO LOS ARGUMENTOS!!!
        inst_to_coe = function(raw_inst_list[1:])
        print("INSTRUCCION DECODIFICADA: ", inst_to_coe)
            
        #pido la funcion del diccionario
        #function = inst_dict.instructions.get(inst_key)

        #ejecuto la funcion
        #inst_to_wr = function(arg_list)+"\n"
        

        #escribimos el archivo
        #program_coe.write(inst_to_wr)

    return 


if __name__ == '__main__':
        main()