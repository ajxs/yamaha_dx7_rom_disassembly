.POSIX:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.PHONY: clean compare lint

BIN_OUTPUT     := dx7_rom_rebuild.bin
BIN_ORIGINAL   := DX7-V1-8.OBJ
INPUT_ASM      := yamaha_dx7_rom_v1.8.asm

all: ${BIN_OUTPUT}

${BIN_OUTPUT}:
	dasm ${INPUT_ASM} -f3 -v4 -o${BIN_OUTPUT}

compare: ${BIN_OUTPUT}
	./compare_binary_files --original ${BIN_ORIGINAL} --rebuild ${BIN_OUTPUT}

lint:
	./lint_source --input_file ${INPUT_ASM}

clean:
	rm -f ${BIN_OUTPUT}
