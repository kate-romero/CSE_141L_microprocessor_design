def convert(inFile, outFile1, outFile2):
	assembly_file = open(inFile, 'r')
	machine_file = open(outFile1, 'w')
	lut_file = open(outFile2, 'w')
	assembly = list(assembly_file.read().split('\n'))

	#keep track of index and file line number
	lineNum = 0
	labelsNum = 0

	#dictionaries to ease conversion of opcodes/operands to binary
	# Updated to match definitions.sv instruction set
	opcodes = {'LOAD' : '0000', 'STOR' : '0001', 'MOVF' : '0010', 'MOVT' : '0011',
	'MOVI' : '0100', 'CMPR' : '0101', 'BNOT' : '0110', 'BORR' : '0111',
	'BAND' : '1000', 'LSHL' : '1001', 'LSHR' : '1010', 'ADDR' : '1011', 
	'SUBR' : '1100'}
	
	# Branch opcodes (2-bit for b-type instructions)
	branch_opcodes = {'BEQ' : '00', 'BLT' : '01', 'BGT' : '10', 'BNE' : '11'}
	
	registers = {'r0' : '0000', 'r1' : '0001', 'r2' : '0010', 'r3' : '0011',
	'r4' : '0100', 'r5' : '0101', 'r6' : '0110', 'r7' : '0111',
	'r8' : '1000', 'r9' : '1001', 'r10' : '1010', 'r11' : '1011',
	'r12' : '1100', 'r13' : '1101', 'r14' : '1110', 'r15' : '1111'}
	
	#reads through assembly and collects labels to populate lookup table
	lut = {}
	for line in assembly:
		instr = line.split()
		lineNum += 1
		#check if it is a label (ends with ':') or branch instruction
		if instr[0].endswith(':') or (instr[0] not in opcodes and instr[0] not in branch_opcodes):
			lut[instr[0].replace(':', '')] = labelsNum
			lut_file.write(str(lineNum) + '\n')
			labelsNum += 1
	
	#reads through file to convert instructions to machine code
	for line in assembly:
		output = ""
		instr = line.split(); #split to get instruction and different operands
		#make sure it is an instruction, skip over labels
		if instr[0] in opcodes:
			# R-type instruction format: [instrType=0][opcode=4bits][reg=4bits]
			output = "0"  # instrType = 0 for R-type
			output += opcodes[instr[0]]  # 4-bit opcode
			
			# Handle different instruction formats
			if instr[0] in ['LOAD', 'STOR']:
				# LOAD/STOR
				reg = instr[1].replace(',', '')
				if reg in registers:
					output += registers[reg]
				else:
					output += '0000'
			elif instr[0] == 'MOVI':
				# MOVI: Move immediate 
				imm = bin(int(instr[1]))[2:]  # convert to binary
				# pad to 4 bits for immediate
				while len(imm) < 4:
					imm = '0' + imm
				output += imm
			elif instr[0] in ['MOVF', 'MOVT', 'CMPR', 'BNOT']:
				# Single register operand
				if len(instr) > 1:
					reg = instr[1].replace(',', '')
					if reg in registers:
						output += registers[reg]
					else:
						output += '0000'
				else:
					reg = 'r0'
					if reg in registers:
						output += registers[reg]
					else:
						output += '0000'
			elif instr[0] in ['BORR', 'BAND', 'LSHL', 'LSHR', 'ADDR', 'SUBR']:
				# Two register operands (second register)
				if len(instr) > 2:
					reg = instr[2].replace(',', '')
					if reg in registers:
						output += registers[reg]
					else:
						output += '0000'
				else:
					reg = 'r0'
					if reg in registers:
						output += registers[reg]
					else:
						output += '0000'
			else:
				output += '0000'  # default register
				
		elif instr[0] in branch_opcodes:
			# B-type instruction format: [instrType=1][bopcode=2bits][address=6bits]
			output = "1"  # instrType = 1 for B-type
			output += branch_opcodes[instr[0]]  # 2-bit branch opcode
			
			# Get branch target address
			target_label = instr[1]
			if target_label in lut:
				addr = lut[target_label]
				addr_bin = bin(addr)[2:]
				for i in range(0, 6 - len(addr_bin)):
					addr_bin = '0' + addr_bin
				output += addr_bin
			else:
				output += '000000'  # default address
		else:
			continue  # skip unknown instructions
			
		#write binary to machine code output file
		machine_file.write(str(output) + '\t// ' + line + '\n')

	assembly_file.close()
	machine_file.close()

#convert("assembly.txt", "machine.txt", "lut.txt")
convert("stringmatch.txt", "sm_machine.txt", "sm_lut.txt")
convert("cordic.txt", "c_machine.txt", "c_lut.txt")
convert("division.txt", "d_machine.txt", "d_lut.txt")