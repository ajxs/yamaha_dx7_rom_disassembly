# Yamaha DX7 ROM Disassembly
This repository contains an annotated disassembly of the v1.8 Yamaha DX7 Firmware ROM.

## Overview
The DX7 runs on a Hitachi HD63B03RP CPU. Among other things, the DX7's firmware is responsible for handling user input, MIDI I/O, and processing the synth's LFO, pitch, and operator amplitude envelopes. This project provides a complete, annotated disassembly of the firmware ROM, with the aim to provide a resource for people researching the functionality of this iconic synthesiser.

### Introduction
The best place to start investigating the firmware is the *reset vector* located at `0xFFFE`. This specifies the location to begin execution upon reset. This points to the `HANDLER_RESET` subroutine, which is responsible for initialising the synth's peripherals, and the global variables stored in memory. Upon completion, execution falls through to the `MAIN_LOOP` subroutine, from which the synth's core functionality is facilitated. The `HANDLER_OCF` function is called periodically on timer interrupts. This is where the synth's periodic functionality is called, such as updating the synth's pitch, and amplitude modulation. The `HANDLER_SCI` subroutine is responsible for handling MIDI input, and output.

## Building the ROM
The project's `makefile` includes a recipe for building the binary from source using the [dasm](https://dasm-assembler.github.io/ "dasm") assembler. If you have dasm and GNU Make installed, you can run `make` in the source directory to assemble the binary.

A `make compare` script is provided, which will run a script comparing the newly built binary against the original. This was implemented with the purpose of testing the integrity of the build process. The original ROM binary (`DX7-V1-8.OBJ`) required for this purpose can be obtained at [this](https://dbwbp.com/index.php/9-misc/37-synth-eprom-dumps "this") fantastic site.

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

**Q: What kind of improvements can be made to the ROM? Is it possible to design new, and interesting functionality for the DX7?**

**A:** The bulk of the DX7's sound synthesis is performed by two proprietary LSI chips: The *YM21290 EGS*, and the *YM21280 OPS*. The fundamental role of the DX7's firmware ROM is to interface with these two chips.
A common question asked on mailing lists is whether the DX7 could potentially support multitimbrality. Unfortunately, the majority of the sound parameters on these two chips are *global.* The only *per-voice* setting the EGS chip appears to support is operator volume. The ability to alter the operator pitch on a per-voice basis would be required for any kind of useful multitimbrality.

One potential possibility for expanding the synth's functionality would be creating an operator pitch EG in the software. It's already known that the EGS supports arbitrary frequency values via the *'fixed operator frequency'* settings. The very real possibility exists that there could be timing, and latency issues related to loading the individual operator pitches to the EGS chip, however the possibility is worth investigating.
If you have a better imagination than I do for what to do with the firmware, feel free to create something new and amazing!

**Q: Why did you use the V1.8 ROM?**

**A:** For no other reason than this being the ROM version that I had available when I began the project. Version 1.8 is also the last *official* ROM from Yamaha to come included in factory units. If someone wanted to reverse-engineer the *Special Edition* ROM, or any other version, this annotated disassembly would make that task much easier. The v1.8, and 'Special Edition' ROMs share most of their code. The hardest part of the firmware to reverse-engineer is the voice, and pitch modulation code, which to the best of my understanding is fundamentally similar between these two versions.

**Q: What motivated you to do this?**

**A:** My initial motivation for this project was to understand how a digital synthesiser is engineered. The Yamaha DX7 has long held a special place in my heart, and my studio. Being nearly entirely digital, it seemed a great starting point. I come from a software-engineering background, so the synth's firmware seemed a good place to begin. I didn't set out to become an obsessive custodian of DX7 minutiae. However I greatly enjoy the idea that I can contribute my own small amount to the collective research, and preservation of this synthesiser's amazing technology. I hope that this work will prove useful for those working to emulate, and preserve the magic of the DX7.

**Q: Are contributions welcome?**

**A:** Absolutely! If you have any suggestions, corrections, or questions, please [get in touch](https://ajxs.me "get in touch")! Alteratively, feel free to fork the project, and make a pull request to the master branch.

**Q: Why target the source to the dasm assembler?**

**A:** That's a good question. By default, the graphical disassembler I used (loosely) targetted the [Motorola Freeware Assembler](http://stealth316.com/misc/motorola_cross_asm_manual.pdf "Motorola Freeware Assembler"). Since first publishing this project, I've done more research into what kind of development tools the original developers may have used. It's likely they used one of Hitachi's 6301/6801 cross-assemblers. A manual for a Hitachi 6301/6801 cross-assembler can be seen [here](http://www.bitsavers.org/components/hitachi/_dataBooks/U29_Hitachi_ISIS-II_6301_Cross_Assembler_Users_Manual.pdf). Another interesting manual for a Hitachi 6301/6801 assembler text-editor can be seen [here](http://www.bitsavers.org/components/hitachi/_dataBooks/U24_Hitachi_6301_6801_Assembler_Text_Editor_Users_Manual.pdf). These assemblers only allowed for labels with a maximum length of 6 characters, which would have made them incompatible with my original disassembly. The [leftover symbol table data](https://ajxs.me/blog/Hacking_the_Yamaha_DX9_To_Turn_It_Into_a_DX7.html#leftover_data) in the DX9 binary confirms this limitation. Besides this, I'm not even sure how to find a copy of these contemporary assemblers, or how to run one. If you know, please contact me!

After doing some research on what assembler would be best for the project, I settled on the [dasm](https://dasm-assembler.github.io/ "dasm") assembler. It has a great feature set, is free/open-source, and is available for a variety of platforms. I figure that keeping the modern format is more useful than trying to emulate the limitations of contemporary assemblers: Trying to understand how the firmware works is hard enough without being limited to six-character labels. I'm open to more discussion about this. If you have any insights, or opinions, please email me. I'd love to hear from you!

Initially this repository contained a build script which converted the disassembly to dasm's format, and then assembled the final binary. Since then I decided to convert the entire disassembly to dasm's format. In doing this, I decided *not* to use dasm's local labels, and keep each label globally unique, so that the source code could be converted to an alternate assembler that didn't support local labels.

## Acknowledgements

I would like to extend a sincere thank you to Jacques Mattheij for his contributions and insights, Ken Shirriff for his amazing research into the DX7's hardware, Rainer Buchty for providing invaluable advice on reverse-engineering, Acreil for generously lending his time to help me understand the synth's hardware, and Raph Levien, and the Dexed team for their amazing work emulating this inconic synthesiser.

## Outstanding Questions

* In the firmware there are two arrays used to track active key/note events: `M_MIDI_NOTE_EVENT_BUFFER`, which is used when adding/removing a note via MIDI, and `M_VOICE_STATUS`, which is used by the main `VOICE_ADD` and `VOICE_REMOVE` subroutines to track the status of individual voices. The MIDI voice status array is only checked when adding a voice via MIDI, but not used by the keyboard handlers. Was this part of some multitimbral functionality removed during development?

* What is the purpose of the `M_LAST_FRONT_PANEL_INPUT_ALTERNATE` variable? This seems to track the same information as `M_LAST_FRONT_PANEL_INPUT`, however the codes for the front-panel numeric buttons are incremented. This allows for a null value of `0`, which is tested against in some cases. Why weren't these two variables consolidated?
