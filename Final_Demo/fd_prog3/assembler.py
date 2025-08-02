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
	'SUBR' : '1100', 'HALT' : '1101', 'ADDC ' : '1110', 'SUBC' : '1111'}
	
	# Branch opcodes (2-bit for b-type instructions)
	branch_opcodes = {'BREQ' : '00', 'BRLT' : '01', 'BRGT' : '10', 'BNEQ' : '11'}
	
	registers = {'R0' : '0000', 'R1' : '0001', 'R2' : '0010', 'R3' : '0011',
	'R4' : '0100', 'R5' : '0101', 'R6' : '0110', 'R7' : '0111',
	'R8' : '1000', 'R9' : '1001', 'R10' : '1010', 'R11' : '1011',
	'R12' : '1100', 'R13' : '1101', 'R14' : '1110', 'R15' : '1111'}
	
	#reads through assembly and collects labels to populate lookup table
	lut = []
	label_names = []
	machine_line_num = 0
	for line in assembly:
		instr = line.split()
		#skip empty lines and comments
		if not instr or instr[0].startswith('//'):
			continue
		#check if it is a label (ends with ':')
		if instr[0].endswith(':'):
			label_name = instr[0].replace(':', '')
			# Handle both $label_X and label formats
			if label_name.startswith('$'):
				label_name = label_name[1:]  # Remove the $ prefix
			label_names.append(label_name)
			lut.append(machine_line_num)
			if (len(lut) > 63):
				lut_file.write("ERROR: too many labels for lut")
			lut_file.write(format(machine_line_num, '012b') + '\t// ' + str(label_name) + '\t//line: ' + str(machine_line_num) + '\t//op2: ' + format(len(lut)-1, '04b') + '\n')
		# Only increment machine_line_num for actual instructions (not labels)
		elif instr[0] in opcodes or instr[0] in branch_opcodes:
			machine_line_num += 1
	
	#reads through file to convert instructions to machine code
	for line in assembly:
		output = ""
		instr = line.split(); #split to get instruction and different operands
		#skip empty lines and comments
		if not instr or instr[0].startswith('//') or instr[0].startswith('$') or instr[0].endswith(':'):
			continue
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
					output += 'ERROR'
			elif instr[0] == 'MOVI':
				# MOVI: Move immediate 
				imm_value = int(instr[1])
				# Validate 4-bit immediate range (0-15)
				if imm_value < 0 or imm_value > 15:
					imm_value = imm_value & 0xF  # Truncate to 4 bits
				
				imm = bin(imm_value)[2:]  # convert to binary
				# pad to exactly 4 bits for immediate
				while len(imm) < 4:
					imm = '0' + imm
				output += imm
			elif instr[0] in ['MOVF', 'MOVT', 'CMPR', 'BNOT', 'BORR', 'BAND', 
					 'LSHL', 'LSHR', 'ADDR', 'SUBR', 'HALT', 'ADDC', 'SUBC']:
				# Single register operand
				if len(instr) > 1:
					reg = instr[1].replace(',', '')
					if reg in registers:
						output += registers[reg]
					else:
						output += 'ERROR'
				else:
					reg = 'R0'
					if reg in registers:
						output += registers[reg]
					else:
						output += 'ERROR'
			# elif instr[0] in ['BORR', 'BAND', 'LSHL', 'LSHR', 'ADDR', 'SUBR']:
			# 	# Two register operands (second register)
			# 	if len(instr) > 2:
			# 		reg = instr[2].replace(',', '')
			# 		if reg in registers:
			# 			output += registers[reg]
			# 		else:
			# 			output += '0000'
			# 	else:
			# 		reg = 'R0'
			# 		if reg in registers:
			# 			output += registers[reg]
			# 		else:
			# 			output += '0000'
			else:
				output += 'ERROR'  # default register
				
		elif instr[0] in branch_opcodes:
			# B-type instruction format: [instrType=1][bopcode=2bits][address=6bits]
			output = "1"  # instrType = 1 for B-type
			output += branch_opcodes[instr[0]]  # 2-bit branch opcode
			
			# Get branch target address
			target_label = instr[1]
			# Handle both $label_X and label formats
			if target_label.startswith('$'):
				target_label = target_label[1:]  # Remove the $ prefix
			
			if target_label in label_names:
				# addr = lut[target_label]
				addr = label_names.index(target_label)
				# Ensure address fits in 6 bits (0-63)
				# if addr > 63:
				# 	print(f"ERROR: Label {instr[1]} address {addr} exceeds 6-bit limit (63)")
					# addr = addr & 0x3F  # Truncate to 6 bits
				addr_bin = bin(addr)[2:]
				for i in range(0, 6 - len(addr_bin)):
					addr_bin = '0' + addr_bin
				output += addr_bin
			else:
				# print(f"Warning: Label {instr[1]} not found")
				output += 'ERROR'  # default address
		else:
			# continue  # skip unknown instructions
			output += 'ERROR'
			
		#write binary to machine code output file
		machine_file.write(str(output) + '\t// ' + line + '\n')

	assembly_file.close()
	machine_file.close()

# convert("program1.txt", "mach_code1.txt", "lut1.txt")
# convert("program2.txt", "mach_code2.txt", "lut2.txt")
convert("program3.txt", "mach_code.txt", "lut.txt")
