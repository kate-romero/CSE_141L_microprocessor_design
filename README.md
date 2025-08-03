# Paccumulator - CSE 141L microprocessor project

![Top Level RTL](TopLevel.png)

## Assembler Usage:
1. Go to the designated directory for the program you want to assemble.
2. Type `python assembler.py` into the terminal and it will generate the files `lut.txt` and `mach_code.txt` based on the contents of `programX.txt`.

## To test: 
1. Ensure all SystemVerilog files are compiled and synthesizable as well as other necessary files such as `lut.txt` and `mach_code.txt` are in the same directory.
2. Open a new project in ModelSim and add the necessary files for the program you want to test, including all relevant testbench files (TopLevel0, data_mem0, testbench itself).
3. Compile and start simulation, and include waves for each signal you want to observe.

## Changes from Original testbench:
1. Program 1: "Top_level0.sv" line 51 changed from `#20000ns` to `#200ns`

## Program 1: 16 bit sign and magnitude (8 integer + 8 fractional) to 16 bit IEEE floating point format
### Score: 20/20

## Program 2: 16 bit IEEE floating point to 16 bit sign and magnitude (8 integer + 8 fractional)
### Score: 31/31

## Program 3: 16 bit floating point addition
### Score: 12/12
