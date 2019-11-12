import serial

#ser = serial.serial_for_url('loop://', timeout=1)

ser = serial.Serial(
     port     = '/dev/ttyUSB1',	#Configurar con el puerto
     baudrate = 9600,
     parity   = serial.PARITY_NONE,
     stopbits = serial.STOPBITS_ONE,
     bytesize = serial.EIGHTBITS
)

ser.isOpen()
ser.timeout=None
ser.flushInput() 
ser.flushOutput()

codes = {
        '+': 0b100000,
        '-': 0b100010,
        '&': 0b100100,
        '|': 0b100101,
        '^': 0b100110,
        '>': 0b000011,
        '<': 0b000010,
        '~': 0b100111
}



def main():
	#ser = serial.Serial('/dev/ttyUSB1')


	while True:
		
		ope1 = raw_input("Ingrese el primer operando, recuerde que el tamanio de palabra es de 8 bits: ")
		ope1 = int(ope1,2)
		sent = ser.write(chr(ope1))  # envio op1, op2, opcode


		ope2 = raw_input("Ahora, ingrese el segundo operando, recuerde que el tamanio de palabra es de 8 bits: ")
		ope2 = int(ope2,2)
		sent = ser.write(chr(ope2))


		operador = raw_input("Ingrese el operador, recuerde que el tamanio de palabra es de 6 bits: ")
		
		while operador not in codes.keys():
			print 'Ingrese el operador nuevamente'
			operador = raw_input("Ingrese el operador, recuerde que el tamanio de palabra es de 6 bits: ")


		operador = codes[operador]
		sent = ser.write(chr(operador))

		out_fpga = ser.read()  # leo salida de placa
		print 'El resultado es:', bin(ord(out_fpga))


if __name__ == '__main__':
		main()	
