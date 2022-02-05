# Yamaha DX7 ROM Disassembly
This repository contains an annotated disassembly of the v1.8 Yamaha DX7 Firmware ROM.

## Overview
The DX7 runs on a Hitachi HD63B03RP CPU. Among other things, the DX7's firmware is responsible for handling user input, MIDI I/O, and processing the synth's LFO, pitch, and operator amplitude envelopes. This project provides a complete, annotated disassembly of the firmware ROM, with the aim to provide a resource for people researching the functionality of this iconic synthesiser.

### Introduction
The best place to start investigating the firmware is the *reset vector* located at `0xFFFE`. This specifies the location to begin execution upon reset. This points to the `HANDLER_RESET` subroutine, which is responsible for initialising the synth's peripherals, and the global variables stored in memory. Upon completion, execution falls through to the `MAIN_LOOP` subroutine, from which the synth's core functionality is facilitated. The `HANDLER_OCF` function is called periodically on timer interrupts. This is where the synth's periodic functionality is called, such as updating the synth's pitch, and amplitude modulation. The `HANDLER_SCI` subroutine is responsible for handling MIDI input, and output.

## Building the ROM
The project's `makefile` includes a recipe for building the binary from source using the [dasm](https://dasm-assembler.github.io/ "dasm") assembler. Simply install dasm, and Python 3 if you don't already have it, and run `make` in the source directory.  The script will create an intermediate assembly file in dasm's required format (`dasm_input.asm`) and assemble the binary.

A `make compare` script is provided, which will run a script comparing the newly built binary against the original. This was implemented with the purpose of testing the integrity of the build process. The original ROM binary (`DX7-V1-8.OBJ`) required for this purpose can be obtained at [this](https://dbwbp.com/index.php/9-misc/37-synth-eprom-dumps "this") fantastic site.

**Note:** The script used to convert to dasm's format makes certain assumptions about the source code. It was written with the purpose of rebuilding the original binary from source *identically*. Particularly, it forces extended addressing in load/store instructions to match the encoding of the original binary. If you are modifying the source code this may or may not suit your purposes. If this is the case, edit the `convert_to_dasm_format` script as required. This file contains appropriate documentation, and should be easy to understand. If you have any questions, or concerns please feel free to email me.

## Subroutine Prefixes
The subroutine names are prefixed, to indicate the area of functionality.
|Prefix|Description|
|--|--|
|BTN|These subroutines contain code for handling the various front-panel button presses. These functions will typically be named by the button they handle the input of. Such as `BTN_EDIT`, or `BTN_FUNC`.|
|CRT|These subroutines contain the code for working with the synth's cartridge interface |
|DELAY|Various subroutines related to introducting an arbitrary delay in the software. These are used extensively when working with the peripheral hardware.|
|HANDLER|These subroutines are the 'top-level' handlers for the 6303 CPU's built-in functionality, such as the *reset vector*, and the various timer-related vectors  |
|INPUT|These functions concern the top-level handling of the synth's analog input. Such as input from the keyboard, modulation wheel, and external modulation controllers.|
|LED|Subroutines for interfacing with the synth's LED indicator.|
|LCD|Subroutines for interfacing with the synth's LCD screen.|
|LFO|Subroutines for processing the synth's LFO.|
|MAIN|These subroutines are related to the synth firmware's *main loop*.| 
|MIDI|Functions for handling MIDI input, and output.|
|MOD|Functions for working with the synth's software modulation. This includes the LFO amplitude, and pitch modulation.|
|PATCH|These subroutines are concerned with loading, saving, and parsing patch data.|
|PITCH|Functions for handling pitch modulation. These include the pitch EG, and handling pitch-bend input.|
|UI|These subroutines handle displaying the synth's user-interface via the LCD screen.|
|VOICE|These subroutines interface with the synth's *voices*. They are responsible for adding, and removing tones from the synth's internal chips.|


## Memory Map

|Address|Function|
|---|----|
|0x0|Internal Registers|
|0x1F|External|
|0x80|RAM (Internal)|
|0x1000|RAM (External)|
|0x2800|LCD Data|
|0x2801|LCD Control|
|0x2802|Sustain/Portamento Pedals, and LCD Busy Line|
|0x2803|8255 Peripheral Controller Control Register|
|0x2804|OPS Mode register|
|0x2805|OPS Algorithm/Feedback register|
|0x280A|DAC Volume|
|0x280E|LED1|
|0x280F|LED2|
|0x3000|EGS Voice Pitch Buffer|
|0x3020|EGS Operator Pitch Buffer|
|0x3030|EGS Operator Detune Buffer|
|0x3040|EGS Operator EG Rate Buffer|
|0x3060|EGS Operator EG Level Buffer|
|0x3080|EGS Operator Level Buffer|
|0x30E0|EGS Operator Keyboard Scaling Buffer|
|0x30F0|EGS Amplitude Modulation Register|
|0x30F1|EGS Voice Event Shift Register|
|0x30F2|EGS Pitch Mod High Register|
|0x30F3|EGS Pitch Mod Low Register|
|0x4000|Cartridge Interface|
|0x4800|Cartridge EPROM IC2 start|
|0x5000|Cartridge Memory End|
|0xC000|ROM Start|
|0xFFFF|ROM End|


## FAQ
**Q: Can this assembly be directly recompiled into a new ROM binary?**

**A:** ***Yes!*** 

When this disassembly was originally published it was not possible to assemble the source code back into the original binary. One challenge in doing so was finding a suitable assembler which fully supported the HD6303 instruction set, and amending the source code to its particular requirements. After some research, I've settled on the [dasm](https://dasm-assembler.github.io/ "dasm") assembler. Dasm is open-source, cross-platform, and supports the Motorola 6800 architecture upon which the Hitachi HD6303 is based. It has some issues with HD6303 support, however the developers were kind enough to provide pre-written macros to add support for the 6303's unique instructions.

In order to get the source to build, it's necessary to transform the source assembly's format to match dasm's specifications. This includes addressing the differences in how dasm encodes the source, compared with the original assembler used when building the factory ROM. Of particular note is the difference in addressing modes between the assemblers. With dasm defaulting to *direct addressing* of memory locations when possible, whereas the original ROM uses *extended addressing* in all cases.

**Q: What kind of improvements can be made to the ROM? Is it possible to design new, and interesting functionality for the DX7?**

**A:** The bulk of the DX7's sound synthesis is performed by two proprietary LSI chips: The *YM21290 EGS*, and the *YM21280 OPS*. The fundamental role of the DX7's firmware ROM is to interface with these two chips.
A common question asked on mailing lists is whether the DX7 could potentially support multitimbrality. Unfortunately, the majority of the sound parameters on these two chips are *global.* The only *per-voice* setting the EGS chip appears to support is operator volume. The ability to alter the operator pitch on a per-voice basis would be required for any kind of useful multitimbrality.

One potential possibility for expanding the synth's functionality would be creating an operator pitch EG in the software. It's already known that the EGS supports arbitrary frequency values via the *'fixed operator frequency'* settings. The very real possibility exists that there could be timing, and latency issues related to loading the individual operator pitches to the EGS chip, however the possibility is worth investigating.
If you have a better imagination than I do for what to do with the firmware, feel free to create something new and amazing!

**Q: Why did you use the V1.8 ROM?**

**A:** For no other reason than this is the ROM version that I had available when I began the project. Version 1.8 is also the last *official* ROM from Yamaha to come included in factory units. If someone wanted to reverse-engineer the *Special Edition* ROM, or any other version, this annotated disassembly would make that task much easier. The v1.8, and 'Special Edition' ROMs have different locations for the same subroutines in memory, however the memory map is fundamentally similar. The hardest part of the firmware to reverse-engineer is the voice, and pitch modulation code, which to the best of my understanding is fundamentally similar between these two versions.

**Q: What motivated you to do this?**

**A:** My initial motivation for this project was to understand how a digital synthesiser is engineered. The Yamaha DX7 has long held a special place in my heart, and my studio. Being nearly entirely digital, it seemed a great starting point. I come from a software-engineering background, so the synth's firmware seemed a good place to begin. I didn't set out to become an obsessive custodian of DX7 minutiae. However I greatly enjoy the idea that I can contribute my own small amount to the collective research, and preservation of this synthesiser's amazing technology. I hope that this work will prove useful for those working to emulate, and preserve the magic of the DX7.

**Q: Are contributions welcome?**

**A:** Absolutely! If you have any suggestions, corrections, or questions, please [get in touch](https://ajxs.me "get in touch")! Alteratively, feel free to fork the project, and make a pull request to the master branch.

**Q: Why not store the source code in dasm's format, instead of using an intermediate step in the build process?**

**A:** That's a good question. The tools I used for disassembling, and formatting the source code were apparently designed to match the format used by the [Motorola Freeware Assembler](http://stealth316.com/misc/motorola_cross_asm_manual.pdf "Motorola Freeware Assembler"). Every compiler has its particular quirks, however this format seems like a reasonable middle ground between the various 6800/6303 assembly dialects that exist in the wild. Dasm's particular format seems more novel, especially considering macros are required to support the 6303's immediate bitwise instructions (`AIM`, `OIM`, `TIM`), and how it handles arbitrarily specifying addressing modes.

## Acknowledgements

I would like to extend a sincere thank you to Jacques Mattheij for his contributions and insights, Ken Shirriff for his amazing research into the DX7's hardware, Rainer Buchty for providing invaluable advice on reverse-engineering, Acreil for generously lending his time to help me understand the synth's hardware, and Raph Levien, and the Dexed team for their amazing work emulating this inconic synthesiser.
