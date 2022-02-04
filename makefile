.POSIX:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.PHONY: clean compare

BIN_OUTPUT     := dx7_rom_rebuild.bin
BIN_ORIGINAL   := DX7-V1-8.OBJ
INPUT_ASM      := yamaha_dx7_rom_v1.8.asm
DASM_INPUT_ASM := dasm_input.asm

all: ${BIN_OUTPUT}

${DASM_INPUT_ASM}:
	./convert_to_dasm_format --input_file ${INPUT_ASM} --output_file ${DASM_INPUT_ASM}

${BIN_OUTPUT}: ${DASM_INPUT_ASM}
	dasm ${DASM_INPUT_ASM} -f3 -v4 -o${BIN_OUTPUT} > dasm_verbose_output.txt

compare: ${BIN_OUTPUT}
	./compare_binary_files --original ${BIN_ORIGINAL} --rebuild ${BIN_OUTPUT}

clean:
	rm -f ${BIN_OUTPUT}
