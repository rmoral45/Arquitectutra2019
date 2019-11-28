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


def main():

     raw_input()

     out_fpga = ser.read()  # leo salida de placaz
     print ('El resultado es:', bin(ord(out_fpga)))


if __name__ == '__main__':
		main()	
