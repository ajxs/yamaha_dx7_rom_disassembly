# Yamaha DX7 ROM Disassembly
This repository contains an annotated disassembly of the v1.8 Yamaha DX7 Firmware ROM.

## Overview
The DX7 runs on a Hitachi 63B03RP CPU. Among other things, the DX7's firmware is responsible for handling user input, MIDI I/O, and processing the synth's LFO, pitch, and operator amplitude envelopes. This project provides a complete, annotated disassembly of the firmware ROM, with the aim to provide a resource for people researching the functionality of this iconic synthesiser.

### Introduction
The best place to start investigating the firmware is the *reset vector* located at `0xFFFE`. This specifies the location to begin execution upon reset. This points at the `HANDLER_RESET` subroutine. This subroutine is responsible for initialising the synth's peripherals, and the global variables stored in memory. Upon completion, execution falls through to the `MAIN_LOOP` subroutine, from which the synth's core functionality is initiated. The `HANDLER_OCF` function is called periodically on timer interrupts. This is where the synth's periodic functionality is called, such as updating the synth's pitch, and amplitude modulation. The `HANDLER_SCI` subroutine is responsible for handling MIDI input, and output.

A memory map of the synthesiser's peripherals, and its variables in memory are provided in the definitions at the start of the assembly listing.

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


## FAQ
**Q: Can this disassembly be directly recompiled into a new ROM?**

A: Unfortunately, this is not possible at the current time. A long-term goal of the project is to provide a way to create new DX7 firmware ROMS, using a freely available assembler. 
 This task would involve picking one of the available free-software 6303 assemblers, then amending the source code to its particular requirements. The annotated disassembly was done with understanding, and documenting the source code as the primary goal. As such, it's very likely that collisions exist in the naming of the *local labels*. This issue would need to be resolved. 
It's quite possible that the original developers used Motorola's 'FreeWare assembler', the source code of which is still available. Any suggestions would be appreciated. At any rate, if anyone was looking to create a new firmware ROM from scratch, this repository would be an invaluable resource.

**Q: What kind of improvements can be made to the ROM? Is it possible to design new, and interesting functionality for the DX7?**

A: The bulk of the DX7's sound synthesis is performed by two proprietary LSI chips: The *YM21290 EGS*, and the *YM21280 OPS*. The fundamental role of the DX7's firmware ROM is to interface with these two chips.
A common question asked on mailing lists is whether the DX7 could potentially support multitimbrality. Unfortunately, the majority of the sound parameters on these two chips are *'global'.* As far as we know, the OPS chip only has a single register specifying the algorithm, and oscillator sync settings for all voices. The only per-voice setting the EGS chip supports is operator volume. The ability to alter the operator pitch on a per-voice basis would be required for any kind of useful multitimbrality. 
One potential possibility for expanding the synth's functionality would be creating an operator pitch EG in the software. It's already known that the EGS supports arbitrary frequency values via the *'fixed operator frequency'* settings. The very real possibility exists that there could be timing, and latency issues related to loading the individual operator pitches to the EGS chip, however the possibility is worth investigating.
If you have a better imagination than I do for what to do with the firmware, feel free to create something new and amazing!

**Q: Why did you use the V1.8 ROM?**

A: For no other reason than this is the ROM version that I had available when I began the project. Version 1.8 is also the last *official* ROM from Yamaha to come included in factory units. If someone wanted to reverse-engineer the *Special Edition* ROM, or any other version, this annotated disassembly would make that task much easier. The v1.8, and 'Special Edition' ROMs have different locations for the same subroutines in memory, however the memory map is fundamentally similar. The hardest part of the firmware to reverse-engineer is the voice, and pitch modulation code, which to the best of my understanding is fundamentally similar between these two versions.

**Q: What motivated you to do this?**

A: My initial motivation for this project was to understand how a digital synthesiser is engineered. The Yamaha DX7 has long held a special place in my heart, and my studio. Being nearly entirely digital, it seemed a great starting point. I come from a software-engineering background, so the synth's firmware seemed a good place to begin. I didn't set out to become an obsessive custodian of DX7 minutiae. However I greatly enjoy the idea that I can contribute my own small amount to the collective research, and preservation of this synthesiser's amazing technology. I hope that this work will prove useful for those working to emulate, and preserve the magic of the DX7.

**Q: Are contributions welcome?**
A: Absolutely! If you have any suggestions, corrections, or questions, please get in touch!


## Acknowledgements

I would like to extend a sincere thank you to Jacques Matthiej for his contributions and insights, Ken Shiriff for his amazing research into the DX7's hardware, Rainer Buchty for providing invaluable advice on reverse-engineering, Acreil for generously lending his time to help me understand the synth's hardware, and Raph Levien, and the Dexed team for their amazing work emulating this inconic synthesiser.
