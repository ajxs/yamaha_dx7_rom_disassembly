.POSIX:
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

.PHONY: clean compare lint

BIN_OUTPUT     := dx7_rom_rebuild.bin
BIN_ORIGINAL   := DX7-V1-8.OBJ
INPUT_ASM      := yamaha_dx7_rom_v1.8.asm
ROM_CHECKSUM   := "6580f668fa67e63c22ad2617a0aaebd7"

all: ${BIN_OUTPUT}

${BIN_OUTPUT}:
	dasm ${INPUT_ASM} -f3 -v4 -o${BIN_OUTPUT}

lint:
	./lint_source --input_file ${INPUT_ASM}

clean:
	rm -f ${BIN_OUTPUT}

compare: ${BIN_OUTPUT}
# Compares the checksum of the rebuilt ROM with the original ROM.
# If the original ROM is present, it will also show the differences between the original and rebuilt ROM.
	@if [ "$$(md5sum ${BIN_OUTPUT} | awk '{print $$1}')" = "${ROM_CHECKSUM}" ]; then \
		echo "Build is correct!"; \
	else \
		echo "Build is not correct!"; \
		echo "Differences:"; \
		if [ -f ${BIN_ORIGINAL} ]; then \
			cmp -l ${BIN_ORIGINAL} ${BIN_OUTPUT} | gawk '{printf "Offset: '0x%04X' Original: '0x%02X' Rebuild: '0x%02X'\n", $$1, strtonum(0$$2), strtonum(0$$3)}'; \
		fi; \
		exit 1; \
	fi
