; ==============================================================================
; YAMAHA DX7 V1.8 ROM DISASSEMBLY
; Annotated by AJXS: https://ajxs.me/ https://github.com/ajxs
; ==============================================================================


; ==============================================================================
; Hitachi 6303 IO Port Registers.
; The addresses of the Hitachi 6303 CPU's internal IO port registers.
; ==============================================================================
IO_PORT_1_DIR:                            equ  0
IO_PORT_2_DIR:                            equ  1
IO_PORT_1_DATA:                           equ  2
IO_PORT_2_DATA:                           equ  3
IO_PORT_3_DIR:                            equ  4
IO_PORT_4_DIR:                            equ  5
IO_PORT_3_DATA:                           equ  6
IO_PORT_4_DATA:                           equ  7
TIMER_CTRL_STATUS:                        equ  8
FREE_RUNNING_COUNTER:                     equ  9
OUTPUT_COMPARE:                           equ  $B
RATE_MODE_CTRL:                           equ  $10
SCI_CTRL_STATUS:                          equ  $11
SCI_RECEIVE:                              equ  $12
SCI_TRANSMIT:                             equ  $13


; ==============================================================================
; Peripheral Addresses.
; These constants are the addresses of the synth's various peripherals.
; Decoder IC23 maps the $28xx address range for peripherals into the CPU's address space.
; Decoder IC24 selects a specific peripheral based on low-order address bits A3-A1.
; The peripheral can use A0.
; ==============================================================================

; These use an Intel 8255 Peripheral Interface Controller, IO Ports A and B
P_LCD_DATA:                               equ  $2800
P_LCD_CTRL:                               equ  $2801

; This peripheral is the 8255's 'IO Port C'. It is used to read the
; cartridge's state, as well as the portamento, and sustain pedal state.
; The 8255's C7 line is multiplexed with Port A's A7. This is used to read
; the LCD's ready state.
P_CRT_PEDALS_LCD:                         equ  $2802

; The control register for the 8255 Programmable Peripheral Interface chip
; used to interface with the various peripherals on the address bus.
P_8255_CTRL:                              equ  $2803

; The OPS 'Mode' register.
; Bit 7 = Mute. Bit 6 = Clear OSC Key Sync. Bit 5 = Set OSC Key Sync.
P_OPS_MODE:                               equ  $2804

; The Ops Algorithm/Feedback register.
; Bits 0-2 = Feedback, Bits 3-7 = Algorithm Select.
P_OPS_ALG_FDBK:                           equ  $2805

; Used to send the 3-bit analog volume value to the DAC.
P_DAC:                                    equ  $280A
P_ACEPT:                                  equ  $280C
P_LED1:                                   equ  $280E
P_LED2:                                   equ  $280F

; Address range $30xx is decoded to the EPS chip.

; The EGS Voice Pitch register. Length: 32.
P_EGS_VOICE_PITCH:                        equ  $3000

; The EGS Operator Pitch register. Length: 16.
P_EGS_OP_PITCH:                           equ  $3020
P_EGS_OP_DETUNE:                          equ  $3030
P_EGS_OP_EG_RATES:                        equ  $3040
P_EGS_OP_EG_LEVELS:                       equ  $3060

; Length: 6.
P_EGS_OP_LEVELS:                          equ  $3080
P_EGS_OP_SENS_SCALING:                    equ  $30E0
P_EGS_AMP_MOD:                            equ  $30F0

; The 'Voice Events' register.
; This is not a buffer, it is the input to a shift register. Writing to this
; register triggers a key event on the EGS chip.
; Bit 0 = Key On, Bit 1 = Key Off, Bit 2-5 = Voice # 0-15.
P_EGS_VOICE_EVENTS:                       equ  $30F1
P_EGS_PITCH_MOD_HIGH:                     equ  $30F2
P_EGS_PITCH_MOD_LOW:                      equ  $30F3

; The cartridge address range, decoded by IC63
P_CRT_START:                              equ  $4000
P_CRT_START_IC2:                          equ  $4800
P_CRT_END:                                equ  $5000


; ==============================================================================
; Intel 8255 'Control Words'.
; These constants are the 'Control Words' for the Intel 8255 Peripheral
; Interface Controller chip. This chip is used in the DX7 to interface with
; its various peripherals over the CPU's address bus.
; When sent to the control register, these constants control the chip's
; functionality, such as the 'direction' of the PIC's IO ports.
; ==============================================================================
I8255_CONTROL_WORD_5:                     equ  %10001001
I8255_CONTROL_WORD_13:                    equ  %10011001


; ==============================================================================
; LCD Controller Constants.
; The DX7 uses a KS0066U-compatible LCD module. These bitmasks are used to
; interface with the LCD controller.
; ==============================================================================
LCD_CTRL_RS:                              equ  1
LCD_CTRL_RW:                              equ  2
LCD_CTRL_RW_RS:                           equ  3

; RS=Low, RW=Low := Instruction Write.
LCD_CTRL_E:                               equ  4
LCD_CTRL_E_RS:                            equ  5
LCD_CTRL_E_RW:                            equ  6
LCD_BUSY_FLAG:                            equ  $80


; ==============================================================================
; LCD Instruction Constants.
; The DX7 uses a KS0066U-compatible LCD module. These constants are instruction
; masks to be written to the LCD controller's instruction register.
; ==============================================================================
LCD_INSTR_CLEAR:                          equ  1
LCD_INSTR_SET_DIR:                        equ  6
LCD_INSTR_SET_BLINK_OFF:                  equ  $C
LCD_INSTR_SET_BLINK_ON:                   equ  $D
LCD_INSTR_SHIFT_CURSOR_LEFT:              equ  $10
LCD_INSTR_SHIFT_CURSOR_RIGHT:             equ  $14
LCD_INSTR_FUNC_SET_8BIT_2_LINE:           equ  $38
LCD_INSTR_SET_CURSOR_POSITION:            equ  $80
LCD_INSTR_SET_CURSOR_TO_LINE_2:           equ  $C0


; ==============================================================================
; General Bitmasks.
; These general bitmask constants are used throughout the ROM.
; ==============================================================================
VOICE_STATUS_SUSTAIN:                     equ  1
VOICE_STATUS_ACTIVE:                      equ  %10
SCI_RIE_RE_TE:                            equ  %111010
SCI_RIE_RE_TIE_TE:                        equ  %111110
KEY_EVENT_ACTIVE:                         equ  %10000000


; ==============================================================================
; Cartridge Status.
; These bitmasked flags indicate the physical status of the synth's cartridge
; interface. They are read from the 8255 peripheral controller's IO port C.
; ==============================================================================
CRT_FLAG_INSERTED:                        equ  %100000
CRT_FLAG_PROTECTED:                       equ  %1000000


; ==============================================================================
; Memory Protect Status.
; These bitmasked flags are used to store the status of the synth's
; firmware level memory protection.
; ==============================================================================
MEM_PROTECT_INT:                          equ  %1000000
MEM_PROTECT_CRT:                          equ  %10000000


; ==============================================================================
; Modulation Pedal Input Status.
; These bitmasked flags are used to determine the status of the synth's
; modulation pedal inputs. These are read from the 8255 peripheral
; controller's IO port C.
; ==============================================================================
PEDAL_STATUS_SUSTAIN_ACTIVE:              equ  1
PEDAL_STATUS_PORTAMENTO_ACTIVE:           equ  %10

; Used to mask both pedal inputs, when reading both is necessary.
PEDAL_STATUS_MASK:                        equ  %11


; ==============================================================================
; Patch Edit Buffer Status Flags.
; These flags determine the status of the synth's 'Patch Edit Buffer'.
; They determine whether the currently held patch has been edited, or whether
; it has been moved to the compare buffer.
; ==============================================================================
EDITED_PATCH_IN_WORKING:                  equ  1
EDITED_PATCH_IN_COMPARE:                  equ  2


; ==============================================================================
; MIDI Error Status.
; These constants are used to track the status of the MIDI buffers. If an error
; condition occurs, these constants will be written to the appropriate memory
; location. They are referenced in printing error messages.
; ==============================================================================
MIDI_STATUS_ERROR:                        equ  1
MIDI_STATUS_BUFFER_FULL:                  equ  2


; ==============================================================================
; Firmware Variables.
; These are the synth's firmware variables located in its internal memory.
; Locations from 0x80 to 0xFF are located in the CPU's internal memory. These
; memory locations are initialised by the synth's reset handler, and should be
; considered volatile. The remaining memory locations are persistent. This
; includes the internal patch memory.
; ==============================================================================

; The last key pressed on the synth's keyboard.
M_NOTE_KEY:                               equ  $81

; The velocity of the last keyboard keypress.
M_NOTE_VEL:                               equ  $82

; The status of the portamento, and sustain modulation pedals.
; Bit 0 = Sustain, Bit 1 = Portamento.
M_PEDAL_INPUT_STATUS:                     equ  $83

; The incoming analog data read from the synth's various analog inputs.
; This variable is set in the main IRQ handler.
M_ANALOG_DATA:                            equ  $84

; The source of the last read analog input event.
; The source will be one of the synth's analog inputs, such as the modulation
; wheel, keyboard, aftertouch, etc.
; This variable is set in the main IRQ handler.
M_ANALOG_DATA_SRC:                        equ  $85
M_INPUT_ANALOG_UPDATE_MOD_TOGGLE:         equ  $86

; This variable stores the synth's up/down increment/decrement value.
; These values are set by either the up/down buttons, or the slider input.
; These value are to be considered a signed 8-bit value, and are used
; for arithmetic purposes. e.g: A numeric value with the 'No/Down'
; value added will be decremented by one.
M_UP_DOWN_INCREMENT:                      equ  $87

; Bit 7 = CRT mem protect. Bit 6 = INT mem protect.
M_MEM_PROTECT_FLAGS:                      equ  $88

; This flag states whether the last input event originated from the slider.
M_SLIDER_INPUT_EVENT:                     equ  $89

; This variable holds which memory (Internal/Cartridge) is currently being
; changed when selecting memory protection ON/OFF.
M_MEM_PROTECT_MODE:                       equ  $8A

; This flag variable is used suring cartridge saving and loading.
; It stores a 'Confirm' bit, which is used to indicate whether the user has
; 'confirmed' the current operation.
; Bit 7 = Read(0)/Write(1). Bit 0 = Confirm.
M_CRT_SAVE_LOAD_FLAGS:                    equ  $8B

; This flag holds whether the 'Function' button is currently being held down.
M_BTN_FUNC_STATE:                         equ  $8C

; When this flag is set the next keypress event will be used to set the
; synth's key transpose.
M_EDIT_KEY_TRANSPOSE_ACTIVE:              equ  $8D
M_MONO_ACTIVE_VOICE_COUNT:                equ  $8E

; The direction of legato, when the synth is in monophonic mode.
; 1 = Up, 0 = Down.
M_LEGATO_DIRECTION:                       equ  $8F
M_NOTE_KEY_LAST:                          equ  $90
M_MONO_SUSTAIN_PEDAL_ACTIVE:              equ  $91
M_SUB_CPU_READ_KEY:                       equ  $92

; This flag stores whether the patch serialise/deserialise operation in the
; 'PATCH_READ_WRITE' subroutine is reading from memory, or writing to it.
; This is set by pressing the 'STORE' button.
M_PATCH_READ_OR_WRITE:                    equ  $93

; 'Toggle' variable used to determine whether the keyboard scaling
; 'depth', or 'curve' values are currently being edited.
; This value is either 0x0, or 0xFF.
M_EDIT_KBD_SCALE_TOGGLE:                  equ  $94
M_EDIT_EG_RATE_LVL_SUB_FN:                equ  $95

; Osc Mode/Sync Flag.
; This flag is used to determine whether the synth UI is currently editing
; the Oscillator Mode, or Oscillator Sync, based on cycling through these
; values using Button 17.
M_EDIT_OSC_MODE_SYNC_FLAG:                equ  $96
M_TEST_MODE_BUTTON_CHECK:                 equ  $97

; This variable seems to hold the source of the last analog input event.
M_LAST_ANALOG_INPUT_EVENT:                equ  $98

; This flag is set when the 'Edit/Char' button is held down during
; editing a patch name. It causes the front panel buttons to input
; characters when pressed.
; Refer to page 46 of the DX7 manual.
M_EDIT_ASCII_MODE:                        equ  $99

; This flag controls whether the synth checks for incoming 'Active Sensing'
; MIDI messages.
M_MIDI_ACTV_SENS_RX_ENABLE:               equ  $9A

; The incoming 'Active Sensing' check counter.
M_MIDI_ACTV_SENS_RX_CTR:                  equ  $9B

; The computed frequency value of the last-pressed key.
; This is used when adding new voice events.
; All of the frequency values passed to the EGS' internal registers are stored
; in logarithmic format, with 1024 units per octave. The key transpose,
; and pitch EG values are stored in the same format.
M_KEY_PITCH:                              equ  $9D
M_KEY_PITCH_LOW:                          equ  $9E
M_KEY_EVENT_CURRENT:                      equ  $AA
M_VOICE_NOTE_CURRENT:                     equ  $AE
M_PITCH_BEND_INPUT_SIGNED:                equ  $B8
M_PITCH_BEND_STEP_VALUE:                  equ  $B9
M_EG_BIAS_TOTAL_RANGE:                    equ  $BA
M_VOICE_PITCH_GLISS_CURRENT:              equ  $BB
M_PORTA_PROCESS_LOOP_IDX:                 equ  $BD
M_VOICE_PORTA_PITCH_FINAL:                equ  $BE
M_VOICE_PITCH_TARGET_PTR:                 equ  $C0
M_VOICE_PITCH_PORTA_PTR:                  equ  $C2
M_VOICE_PITCH_EG_CURR_LVL_PTR:            equ  $C4
M_PORTA_PITCH_INCREMENT:                  equ  $C6
M_GLISSANDO_PITCH_LSB:                    equ  $C7
M_EGS_PITCH_PTR:                          equ  $C8
M_VOICE_PITCH_GLISS_PTR:                  equ  $CA

; This variable is used as a loop counter when processing the pitch EG.
M_PITCH_EG_VOICE_INDEX:                   equ  $CC
M_PITCH_EG_VOICE_LEVELS_PTR:              equ  $CD
M_PITCH_EG_VOICE_STEP_PTR:                equ  $CF
M_PITCH_EG_INCREMENT:                     equ  $D1
M_PITCH_EG_NEXT_LVL:                      equ  $D3
M_MOD_AMP_EG_BIAS_TOTAL:                  equ  $D5
M_MOD_AMP_FACTOR:                         equ  $D6

; The phase accumulator for the synth's LFO.
; This is set to its maximum value of 0x7FFF during the handling of a
; keypress if 'LFO Sync' is enabled.
M_LFO_PHASE_ACCUMULATOR:                  equ  $D7

; The current amplitude of the synth's LFO wave.
M_LFO_CURR_AMPLITUDE:                     equ  $D9
M_LFO_SAMPLE_HOLD_ACCUMULATOR:            equ  $DA

; The amount that LFO modulation should be scaled by during 'fade in'
; after the LFO delay elapses.
M_LFO_FADE_IN_SCALE_FACTOR:               equ  $DB
M_LFO_TRI_ACCUMULATOR:                    equ  $DC
M_LFO_DELAY_COUNTER:                      equ  $DD

; This flag variable is used to track whether the 'Sample+Hold' LFO needs to
; be 'resampled'. Each time the LFO counter overflows, the MSB is set/cleared.
M_LFO_SAMPLE_HOLD_RESET_FLAG:             equ  $DF

; The portamento rate increment.
; This is used when transitioning a voice's pitch during portamento
; processing. It is the increment/decrement calculated from the portamento
; 'rate' variable.
M_PORTA_RATE_INCREMENT:                   equ  $E0

; The last read MIDI data byte.
M_MIDI_INCOMING_DATA:                     equ  $E1
M_MIDI_SYSEX_CHECKSUM:                    equ  $E2

; The number of MIDI data bytes processed during an incoming MIDI message.
; Specifically this is used to store the number of bytes that have been
; processed so far in the subroutine to handle incoming buffered MIDI data.
M_MIDI_PROCESSED_DATA_COUNT:              equ  $E7
M_MIDI_BUFFER_ERROR_CODE:                 equ  $E8

; The MIDI transmit ring buffer's read, and write pointers.
M_MIDI_TX_BFR_WRITE_PTR:                  equ  $EA
M_MIDI_TX_BFR_READ_PTR:                   equ  $EC

; The MIDI receive ring buffer's read, and write pointers.
M_MIDI_RX_BFR_WRITE_PTR:                  equ  $EE
M_MIDI_RX_BFR_READ_PTR:                   equ  $F0
M_MIDI_SUBSTATUS:                         equ  $F2
M_MIDI_SYSEX_PARAM_GRP:                   equ  $F3
M_MIDI_SYSEX_RX_COUNT:                    equ  $F4
M_MIDI_SYSEX_RX_DATA_COUNT:               equ  $F5

; This flag indicates whether there is pending received MIDI to be processed.
M_MIDI_RX_BUFFER_PENDING:                 equ  $F6

; The last received MIDI status byte.
M_MIDI_STATUS_BYTE:                       equ  $F7

; Whether 'SYS INFO AVAIL' is enabled on the synth.
M_MIDI_SYS_INFO_AVAIL:                    equ  $F8

; These variables are used as pointers for the block copy subroutine.
; They point to the source, and destination addresses to copy from/to.
M_COPY_SRC_PTR:                           equ  $F9
M_COPY_DEST_PTR:                          equ  $FB
M_TEST_AD_STAGE_FLAGS:                    equ  $FF

; The start address of the synth's external RAM chips.
M_EXTERNAL_RAM_START:                     equ  $1000

; The address of the synth's 'Patch Edit Buffer'.
; This is where the currently loaded patch is stored in memory.
M_PATCH_CURRENT_BUFFER:                   equ  $2000
M_PATCH_CURRENT_ALG:                      equ  $2086
M_PATCH_CURRENT_LFO_DELAY:                equ  $208A
M_PATCH_CURRENT_LFO_SYNC:                 equ  $208D
M_PATCH_CURRENT_TRANSPOSE:                equ  $2090
M_PATCH_CURRENT_NAME:                     equ  $2091
M_PATCH_CURRENT_NAME_LAST_CHAR:           equ  $209A
M_PATCH_CURRENT_OPS_ON_OFF:               equ  $209B

; When the synth is placed in 'Compare Mode' the status of the operators for
; the current patch are stored here.
M_PATCH_COMPARE_OPS_ON_OFF:               equ  $209C
M_PATCH_CURRENT_NUMBER:                   equ  $209D

; When the synth is placed in 'Compare Mode' the currently edited patch number
; will be stored in this variable.
M_PATCH_COMPARE_NUMBER:                   equ  $209E
M_SELECTED_OPERATOR:                      equ  $209F

; This variable holds the last input event source.
; In contrast to the last button variable, this variable also tracks input
; events from the front-panel slider.
M_LAST_INPUT_EVENT:                       equ  $20A0

; The 'Input Mode' the synth is currently in.
; This is either, 'Play Mode', 'Edit Mode', or 'Function Mode'.
M_INPUT_MODE:                             equ  $20A1

; The 0 indexed number of the last pressed button.
M_LAST_PRESSED_BTN:                       equ  $20A2

; The parameter currently selected to be edited while in 'EDIT' mode.
M_EDIT_PARAM_CURRENT:                     equ  $20A3

; This variable holds both whether Internal, or cartridge memory is selected,
; and the current 'UI Mode'. A value of 0 selects internal memory, a value of
; 1 selects cartridge. The other 'UI Mode' values are used to determine
; what specific function is being performed by the UI.
M_MEM_SELECT_UI_MODE:                     equ  $20A4

; This variable holds the current patch's 'modified' state.
; A non-zero value here indicates that this patch has been edited.
; 0x2 = Edited patch in compare buffer. 0x1 = Currently editing patch.
M_PATCH_CURRENT_MODIFIED_FLAG:            equ  $20A5
M_PATCH_COMPARE_MODIFIED_FLAG:            equ  $20A6
M_PEDAL_INPUT_STATUS_PREVIOUS:            equ  $20A7

; The parameter currently selected to be edited while the synth is in
; 'Function' mode.
M_FN_PARAM_CURRENT:                       equ  $20A8

; Whether the synth is configured to be polyphonic, or monophonic.
; 0 = Poly, 1 = Mono.
M_MONO_POLY:                              equ  $20A9

; The synth's 'portamento mode'.
; Poly: 0 = Retain, 1 = Follow.
; Mono: 0 = Fingered, 1 = Full.
M_PORTA_MODE:                             equ  $20AA

; This variable holds whether Glissando is ON/OFF.
M_PORTA_GLISS_ENABLED:                    equ  $20AB

; The purpose of this variable is unknown, however it is set once to
; 0x7F on reset, and set to 0x7F on MIDI error.
M_ERR_HANDLING_FLAG:                      equ  $20AC

; This variable holds the which 'sub-function' of button 8 in
; 'Function Mode' is currently selected.
; *0 = Edit MIDI RX ch.
; *1 = SYS INFO AVAIL?
; *2 = Transmit MIDI.
M_EDIT_BTN_8_SUB_FN:                      equ  $20AD
M_PATCH_NAME_EDIT_ACTIVE:                 equ  $20AE

; Whether the currently loaded patch is from internal, or cartridge memory.
; A non-zero value indicates the patch is loaded from the cartridge.
M_PATCH_CURRENT_CRT_OR_INT:               equ  $20AF

; Voice 'Status' buffer.
; This buffer stores the current status for each of the synth's voices.
; There are 2 byte entries for each of the 16 voices.
; The first byte stores the MIDI note that this voice is currently playing,
; the second byte stores the status of the note.
; The entry is cleared when a voice is removed in monophonic mode.
; Bit 0 = Sustain Active, Bit 1 = Note currently being held.
M_VOICE_STATUS:                           equ  $20B0

; This section of RAM is used to store incoming MIDI performance data
; received over SYSEX.
; While this area normally holds the current voice event data, since this
; cannot be used while receiving a bulk SYSEX transfer, this area in memory
; doubles as a buffer to store incoming SYSEX data.
M_MIDI_PERF_DATA_BUFFER:                  equ  $20B0

; This buffer holds the 'target' pitch of each of the synth's 16 voices.
; During the portamento/glissando processing subroutine, the individual
; voices transition from their 'current' pitch towards this pitch.
; This pitch is set by the main 'Voice add' subroutines.
M_VOICE_PITCH_TARGET:                     equ  $20D0

; This buffer holds the 'portamento' pitch of each of the synth's 16 voices.
; During the portamento/glissando processing subroutine, if portamento is
; currently active the individual voices transition from this pitch towards
; their target pitch value. This pitch is set by the main
; 'Voice add' subroutines.
M_VOICE_PITCH_PORTAMENTO:                 equ  $20F0

; This buffer holds the 'glissando' pitch of each of the synth's 16 voices.
; During the portamento/glissando processing subroutine, if glissando is
; currently active the individual voices transition from this pitch towards
; their target pitch value. This pitch is set by the main 'Voice add'
; subroutines.
M_VOICE_PITCH_GLISSANDO:                  equ  $2110

; The current Pitch EG step for each of the synth's voices.
M_VOICE_PITCH_EG_CURR_STEP:               equ  $2130

; The current Pitch EG level for each of the synth's voices.
M_VOICE_PITCH_EG_CURR_LEVEL:              equ  $2140

; This array contains the quantised pitch EG rate and level values.
; Entries 0-3 contain the RATE values, 4-7 contain the LEVEL values.
; Length: 8.
M_PATCH_PITCH_EG_VALUES:                  equ  $2160

; The final pitch EG level for the current patch.
; This doubles as the INITIAL pitch EG level.
M_PATCH_PITCH_EG_VALUES_FINAL_LEVEL:      equ  $2167

; This buffer holds the active 'Key Events'. Each of the 16 entries are a
; single byte storing the note in bits 0..6, with bit 7 holding the key
; state, whether it is active or not.
; Length: 16.
M_KEY_EVENT_BUFFER:                       equ  $2168

; Options Flag Variable for CRT Read/Write Functions.
; Bit 7 is used to store whether the operation is read, or write.
; Refer to the 'CRT_READ_WRITE_ALL' subroutine for more information.
M_CRT_RW_FLAGS:                           equ  $2178
M_CRT_WRITE_PATCH_COUNTER:                equ  $2179
M_CRT_FORMAT_PATCH_INDEX:                 equ  $217A

; These variables are used during the conversion of a stored integer into its
; ASCII representation. They are used to hold the powers-of-ten of an integer.
; For more specific information, refer to the 'CONVERT_INT_TO_STR' function.
M_PARSED_INT_DIGITS:                      equ  $217C
M_PARSED_INT_TENS:                        equ  $217D
M_PARSED_INT_HNDRDS:                      equ  $217E
M_PARSED_INT_THSNDS:                      equ  $217F

; During the patch loading process, this variable is used as a pointer to
; hold a function address, which is called once for each of the synth's six
; operators. Refer to the patch loading subroutine for more information.
M_PATCH_LOAD_FUNC_PTR:                    equ  $2183

; The operator keyboard scaling curve data.
; When the keyboard scaling for an operator is parsed from the patch data,
; this curve data is created with the amplitude scaling factor for the full
; keyboard range.
; The MSB of the note pitch word is used as an index into this curve data
; when looking up the scaling factor for a particular note.
; Length: 6 * 43.
M_OPERATOR_KEYBOARD_SCALING:              equ  $2187
M_OPERATOR_KEYBOARD_SCALING_2:            equ  $21B2

; Parsed Individual Operator Volume. Length: 6.
M_OP_VOLUME:                              equ  $228B

; This buffer is temporary storage for a serialised patch, prior to being
; written to memory. Length: 128.
M_PATCH_SERIALISED_TEMP:                  equ  $2291

; The synth's 'Master Tune' setting.
M_MASTER_TUNE:                            equ  $2311
M_MASTER_TUNE_LOW:                        equ  $2312
M_KBD_SCALE_CURVE_INDEX:                  equ  $2313
M_PATCH_OP_SENS:                          equ  $2314

; This 16-bit variable is the LFO's phase increment.
M_LFO_PHASE_INCREMENT:                    equ  $2320
M_LFO_DELAY_INCREMENT:                    equ  $2322
M_LFO_WAVEFORM:                           equ  $2324
M_LFO_PITCH_MOD_DEPTH:                    equ  $2325
M_LFO_AMP_MOD_DEPTH:                      equ  $2326
M_LFO_PITCH_MOD_SENS:                     equ  $2327
M_PITCH_BND_RANGE:                        equ  $2328
M_PITCH_BND_STEP:                         equ  $2329
M_PITCH_BEND_INPUT:                       equ  $232A

; This flag acts as a 'toggle' switch to control which voices are processed
; in the portamento update function.
; If this flag is set, then voices 8-15 are processed, otherwise voices 0-7
; are processed.
M_PORTA_UPDATE_VOICE_SWITCH:              equ  $232B

; This flag is used to determine whether pitch modulation should be updated
; in the interrupt cycle. The effect is that pitch-mod is processed once
; every two periodic timer interrupts.
M_PITCH_UPDATE_TOGGLE:                    equ  $232C

; The counter used to 'blink' the LED dot.
M_COMPARE_PATCH_LED_BLINK_COUNTER:        equ  $232D

; Modulation-source control flags variable.
; Bit 0 = Pitch, Bit 1 = Amplitude, Bit 2 = EG Bias.
M_MOD_WHEEL_ASSIGN_FLAGS:                 equ  $232E

; These 'scaled input' variables refer to the raw analog input 'scaled' by
; this particular modulation-source's 'range' parameter.
M_MOD_WHEEL_SCALED_INPUT:                 equ  $232F
M_FT_CTRL_ASSIGN_FLAGS:                   equ  $2330
M_FT_CTRL_SCALED_INPUT:                   equ  $2331
M_BRTH_CTRL_ASSIGN_FLAGS:                 equ  $2332
M_BRTH_CTRL_SCALED_INPUT:                 equ  $2333
M_AFTERTOUCH_ASSIGN_FLAGS:                equ  $2334
M_AFTERTOUCH_SCALED_INPUT:                equ  $2335
M_MOD_WHEEL_RANGE:                        equ  $2336

; These 'Analog Input' variables are used to store the raw analog input for
; each of these analog modulation sources. These will be scaled according
; to the 'range' of each input source, and stored in the associated
; 'scaled input' variables.
M_MOD_WHEEL_ANALOG_INPUT:                 equ  $2337
M_FOOT_CTRL_RANGE:                        equ  $2338
M_FOOT_CTRL_ANALOG_INPUT:                 equ  $2339
M_BRTH_CTRL_RANGE:                        equ  $233A
M_BRTH_CTRL_ANALOG_INPUT:                 equ  $233B
M_AFTERTOUCH_RANGE:                       equ  $233C
M_AFTERTOUCH_ANALOG_INPUT:                equ  $233D
M_PITCH_BEND_VALUE:                       equ  $233E

; The outgoing MIDI transmit ring buffer.
M_MIDI_TX_BUFFER:                         equ  $2340

; The incoming MIDI received ring buffer.
M_MIDI_RX_BUFFER:                         equ  $23F4
M_MIDI_TX_DATA_PRESENT:                   equ  $2570

; The 'format' of incoming SYSEX MIDI data.
; 1 = Receive perf data, 0 = Receive patch, 9 = Receive bulk.
M_MIDI_SYSEX_FORMAT:                      equ  $2571

; This flag determines whether an 'Active Sensing' signal is due to be sent.
M_MIDI_ACTV_SENS_TX_TRIGGER:              equ  $2572
M_MIDI_RX_CH:                             equ  $2573
M_MIDI_TX_CH:                             equ  $2574
M_EDIT_PARAM_MAX_VALUE:                   equ  $2576
M_EDIT_RATIO_FREQ_PRINT_VALUE:            equ  $2577
M_EDIT_PARAM_MAX_AND_OFFSET:              equ  $2579
M_OP_CURRENT:                             equ  $257B
M_BATTERY_VOLTAGE:                        equ  $257C
M_PORTA_TIME:                             equ  $257D
M_EDIT_PARAM_STR_INDEX:                   equ  $257E

; The currently active diagnostic test stage.
; This is only used when the synth is in diagnostic test mode.
M_TEST_STAGE:                             equ  $257F
M_TEST_STAGE_SUB:                         equ  $2580
M_TEST_STAGE_2:                           equ  $2581

; This variable is a timer for triggering the 'Active Sensing' MIDI message.
M_MIDI_ACTV_SENS_TX_CNTR:                 equ  $2582
M_TEST_LAST_ANALOG_INPUT:                 equ  $2582

; The synth's 'Compare Patch' buffer.
; When an edited patch is 'compared' with the original, stored patch, this is
; the memory location where the edited patch is copied to.
M_PATCH_COMPARE_BUFFER:                   equ  $2584

; The first line buffer for the synth's LCD screen. Length: 16.
M_LCD_BUFFER_LN_1:                        equ  $261F
M_LCD_BUFFER_LN_2:                        equ  $262F

; This buffer stores the LCD screen's current contents.
; During writing the string buffer to the LCD, if the current char to be
; written matches the one in there, the copy process is skipped.
; Length: 32.
M_LCD_BUFFER_CONTENTS:                    equ  $263F
M_STACK_TOP:                              equ  $27FF


; ==============================================================================
; MIDI Error Status.
; These constants are used to track the status of the MIDI buffers. If an error
; condition occurs, these constants will be written to the appropriate memory
; location. They are referenced in printing error messages.
; ==============================================================================
MIDI_SYSEX_FMT_PATCH:                     equ  0
MIDI_SYSEX_FMT_PERF:                      equ  1
MIDI_SUBSTATUS_BULK:                      equ  1
MIDI_SYSEX_PARAM_GRP_VOICE:               equ  1
MIDI_SYSEX_PARAM_GRP_FUNCTION:            equ  2
MIDI_SYSEX_FMT_BULK:                      equ  9
MIDI_SYSEX_SUB_PARAM_CHG:                 equ  $10
MIDI_SUBSTATUS_PARAM:                     equ  $11
MIDI_SYSEX_MANUFACTURER_ID:               equ  $43
MIDI_STATUS_NOTE_OFF:                     equ  $80
MIDI_STATUS_NOTE_ON:                      equ  $90
MIDI_STATUS_MODE_CHANGE:                  equ  $B0
MIDI_STATUS_PROG_CHANGE:                  equ  $C0
MIDI_STATUS_AFTERTOUCH:                   equ  $D0
MIDI_STATUS_PITCH_BEND:                   equ  $E0
MIDI_STATUS_SYSEX_START:                  equ  $F0
MIDI_STATUS_SYSEX_END:                    equ  $F7
MIDI_STATUS_STOP:                         equ  $FC
MIDI_STATUS_ACTIVE_SENSING:               equ  $FE
MIDI_STATUS_RESET:                        equ  $FF


; ==============================================================================
; Front Panel Buttons.
; These constants are used when referencing front-panel button input.
; ==============================================================================
BUTTON_1:                                 equ  0
BUTTON_2:                                 equ  1
BUTTON_3:                                 equ  2
BUTTON_4:                                 equ  3
BUTTON_5:                                 equ  4
BUTTON_6:                                 equ  5
BUTTON_7:                                 equ  6
BUTTON_8:                                 equ  7
BUTTON_9:                                 equ  8
BUTTON_10:                                equ  9
BUTTON_11:                                equ  $A
BUTTON_12:                                equ  $B
BUTTON_13:                                equ  $C
BUTTON_14:                                equ  $D
BUTTON_15:                                equ  $E
BUTTON_16:                                equ  $F
BUTTON_17:                                equ  $10
BUTTON_18:                                equ  $11
BUTTON_19:                                equ  $12
BUTTON_20:                                equ  $13
BUTTON_21:                                equ  $14
BUTTON_22:                                equ  $15
BUTTON_23:                                equ  $16
BUTTON_24:                                equ  $17
BUTTON_25:                                equ  $18
BUTTON_26:                                equ  $19
BUTTON_27:                                equ  $1A
BUTTON_28:                                equ  $1B
BUTTON_29:                                equ  $1C
BUTTON_30:                                equ  $1D
BUTTON_31:                                equ  $1E
BUTTON_32:                                equ  $1F
BUTTON_STORE:                             equ  $20
BUTTON_MEM_PROTECT_INT:                   equ  $21
BUTTON_MEM_PROTECT_CRT:                   equ  $22
BUTTON_OP_SELECT:                         equ  $23
BUTTON_EDIT_CHAR:                         equ  $24
BUTTON_MEM_SELECT_INT:                    equ  $25
BUTTON_MEM_SELECT_CRT:                    equ  $26
BUTTON_FUNCTION:                          equ  $27
BUTTON_NO_DOWN:                           equ  $28
BUTTON_YES_UP:                            equ  $29


; ==============================================================================
; User-Interface 'Sub-Modes'.
; These user-interface 'sub-modes' are used by various user-interface
; subroutines. In addition to controlling the current mode of the UI, the
; associated 'M_MEM_SELECT_UI_MODE' memory variable also controls which patch
; memory is selected: Internal, or Cartridge. Refer to the documentation of
; the 'M_MEM_SELECT_UI_MODE' variable for more information.
; ==============================================================================
UI_MODE_CRT_INSERTED:                     equ  1
UI_MODE_EDIT:                             equ  2
UI_MODE_EDIT_PATCH_NAME:                  equ  3
UI_MODE_CRT_LOAD_SAVE:                    equ  4
UI_MODE_FUNCTION:                         equ  5
UI_MODE_SET_MEM_PROTECT:                  equ  6


; ==============================================================================
; Synth 'Input Mode'.
; This is the main 'Input Mode' for the synthesiser. This controls the main
; functionality of the synth's front-panel buttons. These constant values are
; stored in the 'M_INPUT_MODE' memory variable. Refer to the documentation for
; this variable for more information.
; ==============================================================================
INPUT_MODE_PLAY:                          equ  0
INPUT_MODE_EDIT:                          equ  1
INPUT_MODE_FN:                            equ  2


; ==============================================================================
; 'VOICE_REMOVE' Specific Variables.
; The memory locations in 0xAx, to 0xBx are typically scratch registers, which
; serve multiple uses between the different periodic functions, such as the
; synth's voice subroutines. These are the variable definitions specific to
; the 'VOICE_REMOVE' function.
; ==============================================================================
VR_REMOVE_VOICE_CMD:                      equ  $9F
VR_VOICE_PITCH_EG_CURR_STEP_PTR:          equ  $A6
VR_VOICE_STATUS_PTR:                      equ  $A8


; ==============================================================================
; 'VOICE_ADD' Specific Variables.
; The memory locations in 0xAx, to 0xBx are typically scratch registers, which
; serve multiple uses between the different periodic functions, such as the
; synth's voice subroutines. These are the variable definitions specific to
; the 'VOICE_ADD' function.
; ==============================================================================
VA_VOICE_INDEX:                           equ  $9F
VA_FIND_VOICE_LOOP_INDEX:                 equ  $A0
VA_CURR_VOICE_INDEX:                      equ  $A1
VA_BUFFER_OFFSET:                         equ  $A3
VA_VOICE_PITCH_LAST:                      equ  $A4
VA_VOICE_PITCH_TARGET_PTR:                equ  $A6
VA_VOICE_STATUS_PTR:                      equ  $A8
VA_VOICE_PITCH_NEW:                       equ  $AB
VA_OPERATOR_ON_OFF:                       equ  $AD
VA_VOICE_CURRENT:                         equ  $AE
VA_LOOP_INDEX:                            equ  $AF
VA_OP_SENS_PTR:                           equ  $B0
VA_OP_VOLUME_PTR:                         equ  $B2


; ==============================================================================
; 'LFO Waves.
; These constants are the values corresponding to the various LFO Waves.
; ==============================================================================
LFO_WAVE_TRIANGLE:                        equ  0
LFO_WAVE_SAW_DOWN:                        equ  1
LFO_WAVE_SAW_UP:                          equ  2
LFO_WAVE_SQUARE:                          equ  3
LFO_WAVE_SINE:                            equ  4
LFO_WAVE_S_H:                             equ  5


; ==============================================================================
; 'PATCH_LOAD_OPERATOR_KBD_SCALING' Specific Variables.
; The memory locations in 0xAx, to 0xBx are typically scratch registers, which
; serve multiple uses between the different periodic functions, such as the
; synth's voice subroutines. These are the variable definitions specific to
; the 'PATCH_LOAD_OPERATOR_KBD_SCALING' function.
; ==============================================================================
K_BREAKPOINT:                             equ  $AB
K_DEPTH_LEFT:                             equ  $AC
K_DEPTH_RIGHT:                            equ  $AD
K_CURVE_TABLE_LEFT_PTR:                   equ  $AE
K_CURVE_TABLE_RIGHT_PTR:                  equ  $B0
K_KBD_SCALING_POLARITY:                   equ  $B2
K_OPERATOR_OUTPUT_LVL:                    equ  $B3
K_OPERATOR_CURRENT_PTR:                   equ  $F9


; ==============================================================================
; ROM Disassembly.
; This is the beginning of the ROM's code section, starting at 0xC000.
; ==============================================================================
ORG $C000


; ==============================================================================
; TEST_ENTRY
; ==============================================================================
; LOCATION: 0xC000
;
; DESCRIPTION:
; Entry point to the synth's diagnostic test mode.
; Interrupts are disabled by the 'sei' instruction during this subroutine,
; and restored by 'cli'.
;
; ==============================================================================

TEST_ENTRY:
    SEI
    CLR     TIMER_CTRL_STATUS
    CLR     M_PATCH_CURRENT_MODIFIED_FLAG

.RESET_TEST_STAGE:
    LDD     #0
    STD     M_TEST_STAGE

.RESET_INPUT_VARIABLES:
    CLR     P_EGS_PITCH_MOD_HIGH
    CLR     P_EGS_PITCH_MOD_LOW
    CLR     P_EGS_AMP_MOD
    CLR     M_LAST_INPUT_EVENT
    CLR     M_TEST_AD_STAGE_FLAGS
    CLR     M_TEST_STAGE_2
    LDAA    #7
    STAA    M_TEST_LAST_ANALOG_INPUT
    STAA    <M_TEST_MODE_BUTTON_CHECK
    LDS     #M_STACK_TOP
    BSR     TEST_RESET_VOICE_PARAMS
    CLI
    BRA     .BEGIN_TESTS


; ==============================================================================
; TEST_RESET_VOICE_PARAMS
; ==============================================================================
; LOCATION: 0xC02E
;
; DESCRIPTION:
; This function is called in-between tests in the synth's diagnostic mode. It
; resets various synth parameters to their default value, such as polyphony,
; pitch EG levels, and portamento rate.
;
; ==============================================================================

TEST_RESET_VOICE_PARAMS:
    LDAA    #$FF

; Reset portamento increment to instantaneous.
    STAA    <M_PORTA_RATE_INCREMENT
    LDD     #$100
    STD     M_MASTER_TUNE                       ; Reset master tune.
    CLR     M_MONO_POLY                         ; Reset synth to polyphonic.
    LDAA    #%11000000
    STAA    M_PEDAL_INPUT_STATUS

; The following loop resets the current pitch EG levels for all 16 voices.
; It sets each of the pitch EG levels to 0x4000.

.RESET_PITCH_EG_LEVELS:
    LDAB    #16
    LDX     #M_VOICE_PITCH_EG_CURR_LEVEL

.RESET_PITCH_EG_LOOP:
    LDAA    #64
    STAA    0,x
    INX
    CLR     0,x
    INX
    DECB
    BNE     .RESET_PITCH_EG_LOOP                ; if ACCB > 0, loop.
    RTS


.BEGIN_TESTS:
    JSR     TEST_RAM
    JSR     TEST_PRINT_STAGE_NAME

; Falls-through to begin the full diagnostic test run.
    JSR     TEST_STAGE_1_TONE


; ==============================================================================
; TEST_MAIN_LOOP
; ==============================================================================
; LOCATION: 0xC05A
;
; DESCRIPTION:
; This is the synth's diagnostic test mode's main loop.
; This subroutine will loop continuously, running the currently selected
; diagnostic test stage.
; The series of two 'main' test functions will check the current test function.
; This loop is exited by the 'Test Stage Increment' function, called by the
; first main test function. If the test stage is incremented beyond 8, control
; will jump to the reset handler.
;
; ==============================================================================

TEST_MAIN_LOOP:
    BSR     TEST_MAIN_FUNCTIONS_1
    BSR     TEST_MAIN_FUNCTIONS_2
    BRA     TEST_MAIN_LOOP


; ==============================================================================
; TEST_MAIN_FUNCTIONS_1
; ==============================================================================
; LOCATION: 0xC060
;
; DESCRIPTION:
; The first of the two main diagnostic test functions.
; This subroutine initialises the currently selected diagnotic test function.
;
; ==============================================================================

TEST_MAIN_FUNCTIONS_1:
    TST     M_LAST_ANALOG_INPUT_EVENT
    BNE     .IS_LAST_BTN_NO?
    RTS

; If the last button was 'DOWN' decrement the test stage.

.IS_LAST_BTN_NO?:
    LDAB    M_LAST_INPUT_EVENT
    CMPB    #BUTTON_NO_DOWN
    BNE     .IS_LAST_BTN_YES?
    JSR     TEST_STAGE_DECREMENT
    BRA     .END_TEST_MAIN_FUNCTIONS_1

; If the last button was 'UP' increment the test stage.

.IS_LAST_BTN_YES?:
    CMPB    #BUTTON_YES_UP
    BNE     .IS_TEST_STG_7?

.ADVANCE_STAGE:
    JSR     TEST_STAGE_INCREMENT
    BRA     .END_TEST_MAIN_FUNCTIONS_1

.IS_TEST_STG_7?:
    LDAB    M_TEST_STAGE
    CMPB    #7
    BNE     .IS_TEST_STG_2?
    LDAB    <M_LAST_ANALOG_INPUT_EVENT
    CMPB    #1
    BNE     .IS_BUTTON_16_PRESSED?
    JSR     TEST_STAGE_8_CRT_EEPROM
    BRA     .END_TEST_MAIN_FUNCTIONS_1

.IS_BUTTON_16_PRESSED?:
    CMPB    #16
    BNE     .END_TEST_MAIN_FUNCTIONS_1
    JSR     TEST_STAGE_8_COPY_CRT_TO_RAM
    BRA     .END_TEST_MAIN_FUNCTIONS_1

.IS_TEST_STG_2?:
    CMPB    #2
    BNE     .IS_TEST_STG_3?
    JSR     TEST_STAGE_3_SWITCHES
    BRA     .END_TEST_MAIN_FUNCTIONS_1

.IS_TEST_STG_3?:
    CMPB    #3
    BNE     .IS_TEST_STG_5?
    JSR     TEST_STAGE_4_KBD
    BRA     .END_TEST_MAIN_FUNCTIONS_1

.IS_TEST_STG_5?:
    CMPB    #4
    BNE     .END_TEST_MAIN_FUNCTIONS_1

.IS_LAST_BTN_FUNC?:
    LDAB    M_LAST_INPUT_EVENT
    CMPB    #BUTTON_FUNCTION
    BNE     .TEST_5
    CLR     M_TEST_AD_STAGE_FLAGS
    BRA     .ADVANCE_STAGE

.TEST_5:
    JSR     TEST_STAGE_5_AD

.END_TEST_MAIN_FUNCTIONS_1:
    CLR     M_LAST_ANALOG_INPUT_EVENT
    CLR     M_LAST_INPUT_EVENT
    RTS


; ==============================================================================
; TEST_MAIN_FUNCTIONS_2
; ==============================================================================
; LOCATION: 0xC0C2
;
; DESCRIPTION:
; The second of the two main diagnostic test functions.
; This subroutine initialises the currently selected diagnotic test function.
;
; ==============================================================================

TEST_MAIN_FUNCTIONS_2:
    LDAA    M_TEST_STAGE
    CMPA    #1
    BNE     .NOT_TEST_STAGE_2

.TEST_STAGE_2:
    JSR     TEST_STAGE_2_LCD
    RTS

.NOT_TEST_STAGE_2:
    CMPA    M_TEST_STAGE_2
    BNE     .IS_TEST_STAGE_6?
    BRA     .IS_TEST_STAGE_3?

.IS_TEST_STAGE_6?:
    STAA    M_TEST_STAGE_2
    CMPA    #5
    BNE     .IS_TEST_STAGE_7?
    JSR     TEST_STAGE_6_CRT_READ
    RTS

.IS_TEST_STAGE_7?:
    CMPA    #6
    BNE     .IS_TEST_STAGE_3?
    JSR     TEST_STAGE_7_CRT_WRITE
    RTS

.IS_TEST_STAGE_3?:
    CMPA    #2
    BNE     .END_TEST_MAIN_FUNCTIONS_2

; The following section deals with completing the A/D input tests.
; This code deals specifically with the sustain, and portamento
; pedal input.

.TEST_STAGE_3_PEDAL_CHECK:
    JSR     MAIN_PORTA_SUS_PDL_STATE_UPDATE
    LDAA    M_TEST_STAGE_SUB
    CMPA    #40
    BNE     .TEST_STAGE_3_CHECK_PORTA_PDL

.TEST_STAGE_3_CHECK_SUSTAIN_PDL:
    LDAB    M_PEDAL_INPUT_STATUS
    BITB    #1
    BEQ     .END_TEST_MAIN_FUNCTIONS_2

; If the sustain pedal check was successful, advance the A/D test,
; and proceed to testing the portamento pedal input.
    INCA
    STAA    M_TEST_STAGE_SUB
    LDX     #aPushPortamanto


; ==============================================================================
; LCD_CLR_WRITE_LINE_2_THEN_PRINT
; ==============================================================================
; LOCATION: 0xC103
;
; DESCRIPTION:
; Clears the LCD string buffer's second line, then writes the null-terminated
; string pointed to by IX. The contents of the string buffer are then printed
; to the LCD screen.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the string to print to the 2nd line of the LCD.
;
; ==============================================================================

LCD_CLR_WRITE_LINE_2_THEN_PRINT:
    PSHX
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    PULX
    JMP     LCD_WRITE_LINE_2_THEN_PRINT


.TEST_STAGE_3_CHECK_PORTA_PDL:
    CMPA    #41
    BNE     .END_TEST_MAIN_FUNCTIONS_2

.TEST_IS_PORTA_PEDAL_ACTIVE?:
    LDAB    M_PEDAL_INPUT_STATUS
    BITB    #%10
    BEQ     .END_TEST_MAIN_FUNCTIONS_2
    LDX     #aOk
    BRA     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.END_TEST_MAIN_FUNCTIONS_2:
    RTS


; ==============================================================================
; TEST_COPY_CRT_TO_RAM
; ==============================================================================
; LOCATION: 0xC11C
;
; DESCRIPTION:
; Copies the contents of the cartridge into the synth's patch memory in RAM.
; Used as part of the synth's diagnostic tests.
;
; ==============================================================================

TEST_STAGE_8_COPY_CRT_TO_RAM:
    LDD     #P_CRT_START
    STD     <M_COPY_DEST_PTR
    LDD     #M_EXTERNAL_RAM_START
    STD     <M_COPY_SRC_PTR
    CLR     M_CRT_RW_FLAGS
    JSR     CRT_READ_WRITE_ALL
    RTS


; ==============================================================================
; TEST_STAGE_INCREMENT
; ==============================================================================
; LOCATION: 0xC12D
;
; DESCRIPTION:
; Handles incrementing the current test stage number.
;
; ==============================================================================

TEST_STAGE_INCREMENT:
    JSR     TEST_STAGE_1_TONE_STOP

; If the synth is currently at test stage 8, then advancing the test stage
; will call the reset handler, and exit the diagnostic mode.

.ARE_TESTS_FINISHED?:
    LDAA    M_TEST_STAGE
    CMPA    #7
    BEQ     .TESTS_FINISHED

.TESTS_NOT_FINISHED:
    BSR     TEST_STAGE_5_AD_CHECK_COMPLETE_FLAG
    INC     M_TEST_STAGE
    LDAA    M_TEST_STAGE

.IS_TEST_STAGE_4?:
    CMPA    #3
    BNE     .STOP_TEST_TONE
    INCA

; Stores the test stage in memory at this location.
; This is never referenced explicitly anywhere else.
    STAA    $2078
    JSR     PATCH_LOAD_DATA

; Falls-through to stop tone, and return.

.STOP_TEST_TONE:
    BSR     TEST_CLEAR_FLAGS


; ==============================================================================
; TEST_1_TONE_STOP
; ==============================================================================
; LOCATION: 0xC14C
;
; DESCRIPTION:
; Stops the 440hz test tone produced by diagnostic test 1.
;
; ==============================================================================

TEST_STAGE_1_TONE_STOP:
    LDAA    #69
    STAA    <M_NOTE_KEY
    JSR     VOICE_REMOVE_KEY
    RTS


.TESTS_FINISHED:
    JMP     HANDLER_RESET


; ==============================================================================
; TEST_CLEAR_FLAGS
; ==============================================================================
; LOCATION: 0xC157
;
; DESCRIPTION:
; This subroutine clears the diagnostic test flags.
; This function is called between test stages. It clears specific flags involved
; in the individual diagnostic tests.
;
; ==============================================================================

TEST_CLEAR_FLAGS:
    CLR     M_TEST_STAGE_SUB
    CLR     M_PATCH_CURRENT_MODIFIED_FLAG
    CLR     M_TEST_AD_STAGE_FLAGS
    LDAA    #6
    STAA    M_MIDI_ACTV_SENS_TX_CNTR
    JSR     TEST_PRINT_STAGE_NAME
    JSR     TEST_RESET_VOICE_PARAMS
    RTS


; ==============================================================================
; TEST_STAGE_DECREMENT
; ==============================================================================
; LOCATION: 0xC16C
;
; DESCRIPTION:
; Handles decrementing the current test stage number.
;
; ==============================================================================

TEST_STAGE_DECREMENT:
    TST     M_TEST_STAGE

; Check if we're at test stage 1.
    BEQ     .END_TEST_STAGE_DECREMENT
    BSR     TEST_STAGE_5_AD_CHECK_COMPLETE_FLAG
    DEC     M_TEST_STAGE
    BSR     TEST_CLEAR_FLAGS

; Check if we're back at test stage 1 after decrementing the current test
; stage number. If so, the test 1 subroutine is initiated. This check is
; performed since test 1 is not part of the main diagnostic test loop.

.IS_TEST_STAGE_1?:
    TST     M_TEST_STAGE
    BNE     .END_TEST_STAGE_DECREMENT
    JSR     TEST_STAGE_1_TONE

.END_TEST_STAGE_DECREMENT:
    RTS


; ==============================================================================
; TEST_5_AD_CHECK_COMPLETE_FLAG
; ==============================================================================
; LOCATION: 0xC181
;
; DESCRIPTION:
; Tests whether each stage of the AD test has been completed.
; The state of each AD test stage is stored in a bitmask in the flag at address
; 0xFF. A value of 63 (0b111111) indicates that all 6 tests have been run.
; If the AD tests have not been completed, a message is printed to the LCD.
; Otherwise if complete the AD test stage flags are cleared.
;
; MEMORY USED:
; * 0xFF: The AD test stage complete flag.
;
; ==============================================================================

TEST_STAGE_5_AD_CHECK_COMPLETE_FLAG:
    LDAB    <M_TEST_AD_STAGE_FLAGS
    BEQ     .TEST_5_COMPLETE
    CMPB    #%111111
    BEQ     .TEST_5_COMPLETE

.TEST_5_INCOMPLETE:
    PULX
    LDX     #aNotCompleted
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.TEST_5_COMPLETE:
    CLR     M_TEST_AD_STAGE_FLAGS
    RTS

aNotCompleted:       FCC "NOT COMPLETED !", 0


; ==============================================================================
; TEST_PRINT_STAGE_NAME
; ==============================================================================
; LOCATION: 0xC1A4
;
; DESCRIPTION:
; Prints the current diagnostic test stage name.
; This is responsible for printing the string seen on the top line of the LCD
; during the diagnostic tests, such as: "TEST5 A/D".
;
; Test two clears the LCD screen, so nothing is printed.
;
; ==============================================================================

TEST_PRINT_STAGE_NAME:
    JSR     LCD_CLEAR_STR_BUFFER
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR

; This strin pointer points to ' TEST '.
    LDX     #(aInitVoiceTest+$A)
    JSR     LCD_WRITE_STR_TO_BUFFER

; Check if this is test stage 2.
; Test two clears the LCD, so this is skipped.

.IS_TEST_STAGE_2?:
    LDAB    M_TEST_STAGE
    CMPB    #2
    BNE     .PRINT_TEST_NAME_TO_BUFFER

; In the case of test 2, the LED contents are cleared.
    CLR     M_PATCH_CURRENT_NUMBER
    JSR     LED_PRINT_PATCH_NUMBER

.PRINT_TEST_NAME_TO_BUFFER:
    LDAB    M_TEST_STAGE
    ASLB
    LDX     #TABLE_TEST_STAGE_NAMES
    ABX
    LDX     0,x
    JMP     LCD_WRITE_BFR_AND_PRINT

; ==============================================================================
; Test Stage Names.
; This table contains pointers to the null-terminated test stage names.
; These strings are used during the individual diagnostic test stages to print
; the test names to the LCD.
; ==============================================================================
TABLE_TEST_STAGE_NAMES:
    FDB a1Level
    FDB a1Level
    FDB a3Sw
    FDB a4Kbd
    FDB a5AD
    FDB a6CrtR
    FDB a7CrtW
    FDB a8CrtRw
a1Level:             FCC "1 LEVEL", 0
a3Sw:                FCC "3 SW", 0
a4Kbd:               FCC "4 KBD", 0
a5AD:                FCC "5 A/D", 0
a6CrtR:              FCC "6 CRT R", 0
a7CrtW:              FCC "7 CRT W", 0
a8CrtRw:             FCC "8 CRT RW", 0


; ==============================================================================
; TEST_1_TONE
; ==============================================================================
; DESCRIPTION:
; This test stage plays a 440hz test sine tone to test the synthesiser's sound
; generation ability.
;
; ==============================================================================

TEST_STAGE_1_TONE:
    JSR     EGS_RESET_VOICES

; The following lines initialise the 'Edit Patch' buffer with the default
; patch data so that a pure sine wave can be synthesised during the test.
    LDD     #PATCH_INIT_VOICE_BUFFER
    JSR     PATCH_DESERIALISE
    JSR     PATCH_LOAD_DATA

; Add the note A4 (440hz) to the active note buffer. This note is
; then removed, presumably to reset it in some way, and then re-added.
    LDAA    #69
    STAA    <M_NOTE_KEY
    JSR     VOICE_ADD_CHECK_KEY_EVENT_COUNT
    JSR     VOICE_REMOVE_KEY
    JSR     VOICE_ADD_CHECK_KEY_EVENT_COUNT

.PRINT_ROM_VERSION:
    LDX     #aAdjVr3M1018
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

aAdjVr3M1018:        FCC "ADJ VR3 M1.0-1.8", 0
aV1824Oct85Test:     FCC " V1.8 24-Oct-85  Test Entry ?", 0

; ==============================================================================
; Initialise Patch Buffer.
; This buffer contains the data to initialise the patch 'Edit Buffer'.
; ==============================================================================
PATCH_INIT_VOICE_BUFFER:
    FCB $63, $63, $63, $63, $63
    FCB $63, $63, 0, 0, 0, 0
    FCB 0, $38, 0, 0, 2, 0, $63
    FCB $63, $63, $63, $63, $63
    FCB $63, 0, 0, 0, 0, 0, $38
    FCB 0, 0, 2, 0, $63, $63
    FCB $63, $63, $63, $63, $63
    FCB 0, 0, 0, 0, 0, $38, 0
    FCB 0, 2, 0, $63, $63, $63
    FCB $63, $63, $63, $63, 0
    FCB 0, 0, 0, 0, $38, 0, 0
    FCB 2, 0, $63, $63, $63
    FCB $63, $63, $63, $63, 0
    FCB 0, 0, 0, 0, $38, 0, 0
    FCB 2, 0, $63, $63, $63
    FCB $63, $63, $63, $63, 0
    FCB 0, 0, 0, 0, $38, 0, $63
    FCB 2, 0, $63, $63, $63
    FCB $63, $32, $32, $32, $32
    FCB 0, 8, $23, 0, 0, 0, $31
    FCB $18
aInitVoiceTest:      FCC "INIT VOICE TEST ", 0


; ==============================================================================
; TEST_3_SWITCHES
; ==============================================================================
; LOCATION: 0xC2E3
;
; DESCRIPTION:
; Tests the device's switches.
;
; MEMORY USED:
; * 0x2580: The 'target switch', which is the next expected.
;
; ==============================================================================

TEST_STAGE_3_SWITCHES:
    LDAA    <M_LAST_ANALOG_INPUT_EVENT
    CMPA    #40
    BLS     .IS_TEST_ALREADY_COMPLETE?
    RTS

; This flag is reset in the clear test flags function.

.IS_TEST_ALREADY_COMPLETE?:
    LDAA    M_TEST_STAGE_SUB
    CMPA    #40
    BNE     .TEST_SWITCHES
    RTS

; Print the current button number to the LED.

.TEST_SWITCHES:
    STAA    M_PATCH_CURRENT_NUMBER
    JSR     LED_PRINT_PATCH_NUMBER

; Test whether the last pressed button is equal to the expected test
; switch number.
    LDAA    M_TEST_STAGE_SUB
    SUBA    M_LAST_INPUT_EVENT
    BEQ     .CORRECT_BUTTON_PRESSED

; If the incorrect button has been pressed, the number corresponding to
; this key will be shown on the LED output, and the appropriate message
; printed to the LCD.

.INCORRECT_BUTTON_PRESSED:
    LDAA    #60
    STAA    M_TEST_STAGE_SUB
    LDX     #aErrorSeeLed

.PRINT_MESSAGE_SEE_LED:
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.CORRECT_BUTTON_PRESSED:
    INC     M_TEST_STAGE_SUB
    LDAA    M_TEST_STAGE_SUB

; Increment the test switch, and store to the currently selected
; patch number register, so that it will display on the LED.
    STAA    M_PATCH_CURRENT_NUMBER
    CMPA    #40
    BEQ     .TEST_SUSTAIN
    JSR     LED_PRINT_PATCH_NUMBER
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    JMP     LCD_PRINT_STR_BUFFER

.TEST_SUSTAIN:
    LDX     #aPushSustain
    BRA     .PRINT_MESSAGE_SEE_LED

aErrorSeeLed:        FCC "ERROR SEE LED", 0
aOk:                 FCC " OK", 0
aPushSustain:        FCC "push sustain", 0
aPushPortamanto:     FCC "push portamanto", 0


; ==============================================================================
; TEST_4_KBD
; ==============================================================================
; LOCATION: 0xC355
;
; DESCRIPTION:
; Performs the keyboard diagnostic test.
;
; MEMORY USED:
; * 0x2580: The 'target key', which is the next expected.
;
; ==============================================================================

TEST_STAGE_4_KBD:
    LDAA    <M_LAST_ANALOG_INPUT_EVENT

; This comparison checks whether the last analog input event
; was '44', indicating a 'Key Down' event.
    CMPA    #44
    BEQ     .LAST_INPUT_IS_KEY_DOWN
    RTS

.LAST_INPUT_IS_KEY_DOWN:
    LDAA    M_TEST_STAGE_SUB
    CMPA    #61
    BNE     .IS_CORRECT_KEYPRESS_SEQUENCE?
    RTS

; Test if the keys were pressed in the correct sequence.
; This is performed by storing the next expected key number in 0x2580,
; This value, plus 36, is subtracted from the last key event recorded.
; If the resulting number is zero, that indicates the correct key in the
; sequence was pressed.

.IS_CORRECT_KEYPRESS_SEQUENCE?:
    LDAA    <M_NOTE_KEY
    SUBA    #36
    SUBA    M_TEST_STAGE_SUB
    BEQ     .KEY_IS_CORRECT
    LDX     #aKbdError

.CLEAR_LCD_LINE_2:
    JSR     LCD_CLR_WRITE_LINE_2_THEN_PRINT
    JMP     .PRINT_NOTES

.KEY_IS_CORRECT:
    LDAA    <M_NOTE_VEL
    CMPA    #80
    BLS     .VELOCITY_IS_OK
    LDX     #aTouchErr
    BRA     .CLEAR_LCD_LINE_2

.VELOCITY_IS_OK:
    INC     M_TEST_STAGE_SUB

; Check whether the test just finished the final key, and the test
; is finished.
    LDAA    M_TEST_STAGE_SUB
    CMPA    #61
    BEQ     .TEST_4_COMPLETE

; Store the next key number in the patch number register, so
; that it is printed to the LED output. Clear the second line
; of the string buffer.

.TEST_4_INCOMPLETE:
    STAA    M_PATCH_CURRENT_NUMBER
    JSR     LED_PRINT_PATCH_NUMBER
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    JMP     .PRINT_NOTES

.TEST_4_COMPLETE:
    LDX     #aKbdOk
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; LCD_CLEAR_STR_BUFFER_LINE_2
; ==============================================================================
; LOCATION: 0xC39D
;
; DESCRIPTION:
; Clears the second line of the LCD string buffer, then returns to the caller.
;
; ==============================================================================

LCD_CLEAR_STR_BUFFER_LINE_2:
    LDAB    #16
    LDX     #M_LCD_BUFFER_LN_2

; Load ASCII space to ACCA.
    LDAA    #' '

.CLR_2ND_LINE_LOOP:
    STAA    0,x
    INX
    DECB
    BNE     .CLR_2ND_LINE_LOOP                  ; If b > 0, loop.
    RTS


; Print to LCD Buffer Line 2 + 10.

.PRINT_NOTES:
    LDX     #$2639
    STX     <M_COPY_DEST_PTR
    LDAB    M_TEST_STAGE_SUB
    ADDB    #24
    JSR     PRINT_MUSICAL_NOTES
    JMP     LCD_PRINT_STR_BUFFER
aKbdError:           FCC "KBD ERROR", 0
aKbdOk:              FCC "KBD OK", 0
aTouchErr:           FCC "TOUCH ERR", 0


; ==============================================================================
; TEST_5_AD
; ==============================================================================
; LOCATION: 0xC3D6
;
; DESCRIPTION:
; Performs a diagnostic test of the synth's various analog inputs.
;
; MEMORY USED:
; * 0x2582: The last analog data source that data was received from.
;
; ==============================================================================

TEST_STAGE_5_AD:
    LDAB    <M_ANALOG_DATA_SRC

; If the last analog data source touched has not changed, then
; do not re-print its name to the LCD.
    CMPB    $2582
    BEQ     .QUANTISE_OUTPUT
    CMPB    #6
    BEQ     .END_TEST_STAGE_5_AD
    PSHB
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    PULB

; The last-touched analog data source is stored in B. This is then used as
; an input into a string table, to display the name of the control being
; touched.
    STAB    $2582
    ASLB
    LDX     #STR_PTRS_TEST_AD
    ABX
    LDX     0,x
    JSR     LCD_WRITE_LINE_2_THEN_PRINT
    LDAB    $2582

; The following code uses the data source number as an input to a table of
; powers of two. This value is then OR'd with the AD test stage flag
; variable to set the corresponding stage as having been complete. Once all
; 6 stages have been complete the value is 0b111111.
    LDX     #TABLE_TEST_AD
    ABX
    LDAA    0,x
    ORAA    <M_TEST_AD_STAGE_FLAGS
    ANDA    #%111111
    STAA    <M_TEST_AD_STAGE_FLAGS

; The following subroutine quantises the raw analog input value (0-255) to
; the final output range (0-99).

.QUANTISE_OUTPUT:
    LDAA    <M_ANALOG_DATA
    LDAB    #99
    MUL
    STAA    M_PATCH_CURRENT_NUMBER
    JSR     LED_PRINT_PATCH_NUMBER

.END_TEST_STAGE_5_AD:
    RTS

STR_PTRS_TEST_AD:
    FDB aDataEntry
    FDB aPBend
    FDB aMWheel
    FDB aFoot
    FDB aBreath
    FDB aAfter
TABLE_TEST_AD:
    FCB 1
    FCB 2
    FCB 4
    FCB 8
    FCB 16
    FCB 32
aDataEntry:          FCC "DATA ENTRY", 0
aPBend:              FCC "P BEND", 0
aMWheel:             FCC "M WHEEL", 0


; ==============================================================================
; TEST_CRT_EEPROM
; ==============================================================================
; LOCATION: 0xC43A
;
; DESCRIPTION:
; This diagnostic test checks the cartridge EEPROM for errors.
; It begins by clearing the cartridge contents. It then loops through each byte
; of the cartridge, checking that its contents have been successfully cleared.
; It then tests whether each byte can be written to, and then read from
; successfully. The cartridge is then cleared again.
;
; ==============================================================================

TEST_STAGE_8_CRT_EEPROM:
    JSR     TEST_CRT_CHECK_INSERTED
    JSR     TEST_CRT_CHECK_MEM_PROTECTION
    LDX     #aJustCheck
    JSR     LCD_CLR_WRITE_LINE_2_THEN_PRINT
    JSR     TEST_CRT_CLEAR_CARTRIDGE

.BEGIN_READ_WRITE_TEST:
    LDX     #P_CRT_START

.CRT_RW_TEST_LOOP:
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x

.IS_BYTE_CLEARED?:
    BEQ     .CLEAR_BYTE_SUCCESS
    JMP     PRINT_TEST_CRT_ERROR_MSG

.CLEAR_BYTE_SUCCESS:
    BSR     TEST_CRT_WRITE_BYTE
    INX
    CPX     #P_CRT_END
    BNE     .CRT_RW_TEST_LOOP                   ; If IX < 0x5000, loop.
    JSR     TEST_CRT_CLEAR_CARTRIDGE
    LDX     #aEepromOk
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; TEST_CRT_WRITE_BYTE
; ==============================================================================
; LOCATION: 0xC46A
;
; DESCRIPTION:
; Tests writing two different bytes to a single location in memory.
; The subroutines called inside this function will perform error-checking to
; determine whether the bytes could be successfully written. If an error occurs,
; a message will be printed to the LCD.
;
; ARGUMENTS:
; Registers:
; * IX:   The address in cartidge memory to write to.
;
; RETURNS:
; * The carry flag is set to indicate an error condition.
;
; ==============================================================================

TEST_CRT_WRITE_BYTE:
    LDAA    #$55                                ; 'U'
    JSR     CRT_WRITE_BYTE

; If the carry-bit is set after the previous function call, it indicates an
; error condition has occurred.
    BCS     CRT_PRINT_TEST_ERROR
    LDAA    #$AA
    JSR     CRT_WRITE_BYTE
    BCS     CRT_PRINT_TEST_ERROR
    RTS


; ==============================================================================
; TEST_CRT_CLEAR_CARTRIDGE
; ==============================================================================
; LOCATION: 0xC479
;
; DESCRIPTION:
; Clears every byte in cartridge memory to 0x0. Used as part of the synth's
; diagnostic tests.
;
; ==============================================================================

TEST_CRT_CLEAR_CARTRIDGE:
    LDX     #P_CRT_START
    CLRA

.CRT_CLEAR_LOOP:
    JSR     CRT_WRITE_BYTE

; If the carry bit is set, this indicates an error condition.
    BCS     CRT_PRINT_TEST_ERROR
    INX
    CPX     #P_CRT_END
    BNE     .CRT_CLEAR_LOOP                     ; If IX < 0x5000, loop.
    RTS

CRT_PRINT_TEST_ERROR:
    PULX
    BRA     PRINT_TEST_CRT_ERROR_MSG


; ==============================================================================
; TEST_STAGE_6_CRT_READ
; ==============================================================================
; LOCATION: 0xC48C
;
; DESCRIPTION:
; Tests the ability of the synth to read each byte of the cartridge memory.
;
; ==============================================================================

TEST_STAGE_6_CRT_READ:
    BSR     TEST_CRT_CHECK_INSERTED
    LDX     #P_CRT_START
    LDD     #0

; Tests the ability to read each byte by setting ACCA to an arbitrary value
; by adding the LSB of the destination address to the MSB, then loading
; ACCB from cartridge memory, copying ACCB to ACCA, then testing if the
; values are equal.
; If they're not equal, an error message is printed.

.CRT_READ_LOOP:
    STD     <M_COPY_DEST_PTR
    ABA
    LDAB    0,x
    CBA
    BEQ     .INCREMENT_POINTER
    JMP     PRINT_TEST_CRT_ERROR_MSG

; Increment the copy destination, and source pointers.

.INCREMENT_POINTER:
    LDD     <M_COPY_DEST_PTR
    ADDD    #1
    INX
    CPX     #P_CRT_END
    BNE     .CRT_READ_LOOP                      ; If IX < 0x5000, loop.
    LDX     #aReadOk
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; TEST_STAGE_7_CRT_WRITE
; ==============================================================================
; LOCATION: 0xC4B0
;
; DESCRIPTION:
; Tests that both cartridge EEPROM ICs can be written to. If this test fails
; an error message will be printed to the LCD, otherwise 'WRITE OK' will be
; written.
;
; ==============================================================================

TEST_STAGE_7_CRT_WRITE:
    BSR     TEST_CRT_CHECK_INSERTED
    BSR     TEST_CRT_CHECK_MEM_PROTECTION
    LDX     #P_CRT_START
    BSR     TEST_CRT_WRITE_BYTE
    LDX     #P_CRT_START_IC2
    BSR     TEST_CRT_WRITE_BYTE
    LDX     #aWriteOk
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; TEST_CRT_CHECK_INSERTED
; ==============================================================================
; LOCATION: 0xC4C4
;
; DESCRIPTION:
; Checks if the cartridge is inserted by reading line 5 of 8255 port C. If this
; line is pulled low, it indicates that a cartidge is inserted.
; In the case it is not inserted, the 'INSERT CARTRIDGE' message is printed to
; the LCD screen.
;
; ==============================================================================

TEST_CRT_CHECK_INSERTED:
    LDAA    P_CRT_PEDALS_LCD
    BITA    #CRT_FLAG_INSERTED
    BNE     .PRINT_INSERT_CRT_MSG
    RTS

.PRINT_INSERT_CRT_MSG:
    PULX
    LDX     #(aNotReadyInsert+$10)
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; TEST_CRT_CHECK_MEM_PROTECTION
; ==============================================================================
; LOCATION: 0xC4D3
;
; DESCRIPTION:
; Used as part of the diagnostic tests specific to testing cartridge
; functionality. This is called directly after checking whether the CRT is
; inserted to check the status of the physical memory protection on the
; cartridge.
;
; ==============================================================================

TEST_CRT_CHECK_MEM_PROTECTION:
    BITA    #CRT_FLAG_PROTECTED
    BNE     .PRINT_MSG_MEM_PROTECTED
    RTS

.PRINT_MSG_MEM_PROTECTED:
    PULX
    LDX     #aMemoryProtecte
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


PRINT_TEST_CRT_ERROR_MSG:
    LDX     #aError
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT
aJustCheck:          FCC "JUST CHECK", 0
aEepromOk:           FCC "EEPROM OK ", 0
aError:              FCC " ! ERROR ! ", 0
aReadOk:             FCC "READ OK", 0
aWriteOk:            FCC "WRITE OK", 0


; ==============================================================================
; TEST_2_LCD
; ==============================================================================
; LOCATION: 0xC518
;
; DESCRIPTION:
; Tests the LCD, and LED output by printing a test pattern to each.
;
; ==============================================================================

TEST_STAGE_2_LCD:
    TST     $20A5

; Branch if 0x20A5 is non-zero.
; This value is used as a 'toggle' to decide whether the LCD screen
; should be filled or cleared.
    BNE     .FILL_SCREEN

; Load 0xFF into ACCB, which is used to clear the LED contents.
; Load 0x20 into ACCA, which is an ASCII space value, used to clear
; the LCD screen buffer contents.
    LDAB    #$FF
    STAB    M_PATCH_CURRENT_NUMBER
    LDAA    #' '
    STAA    M_TEST_STAGE_SUB
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG

.PRINT_LED_PATTERN:
    STAB    P_LED2
    STAB    P_LED1

; Clears the LCD string buffer with the contents of ACCA.
; This is either space, or 0xFF, as seen above.

.PRINT_LCD_PATTERN:
    LDAB    #32
    LDX     #M_LCD_BUFFER_LN_1

.CLEAR_LCD_LOOP:
    STAA    0,x
    INX
    DECB
    BNE     .CLEAR_LCD_LOOP                     ; If ACCB > 0, loop.

.WRITE_LCD_CONTENTS:
    LDX     #M_LCD_BUFFER_LN_1
    JSR     LCD_PRINT_STR_BUFFER

; Create an artificial delay to 'blink' the LCD screen.

.DELAY:
    LDAB    #33

DELAY_LOOP:
    JSR     DELAY_450_CYCLES
    DECB
    BNE     DELAY_LOOP                          ; If ACCB > 0, loop.
    RTS

.FILL_SCREEN:
    LDAB    M_PATCH_CURRENT_NUMBER
    BEQ     .TEST_2_RESET_LED

; Shift ACCB left one bit.
; The effect of this operation is to increment the LED 'pattern'.
    ASLB

.STORE_LED_CONTENTS:
    STAB    M_PATCH_CURRENT_NUMBER
    LDAA    M_TEST_STAGE_SUB

.SET_LCD_CONTENTS:
    CMPA    #32
    BNE     .CLEAR_LCD
    LDAA    #$FF

.STORE_LCD_CONTENTS:
    STAA    M_TEST_STAGE_SUB
    BRA     .PRINT_LED_PATTERN

.CLEAR_LCD:
    LDAA    #' '
    BRA     .STORE_LCD_CONTENTS

.TEST_2_RESET_LED:
    LDAB    #$FF
    BRA     .STORE_LED_CONTENTS


; ==============================================================================
; TEST_RAM
; ==============================================================================
; LOCATION: 0xC569
;
; This subroutine tests the internal RAM ICs.
; It writes, and then reads back arbitrary data in 32 byte blocks between
; addresses 0x1000, and 0x27C0, storing the current memory in a temporary
; location.
;
; ==============================================================================

TEST_RAM:
    LDX     #M_EXTERNAL_RAM_START
    STX     <M_COPY_SRC_PTR
    LDX     #$27C0
    STX     <M_COPY_DEST_PTR

; Copy the 32 byte block pointed to by the origin pointer to
; the temporary address.

.TEST_RAM_LOOP:
    BSR     TEST_RAM_COPY_BLOCK_TO_TEMP
    BSR     TEST_RAM_BLOCK
    BSR     TEST_RAM_COPY_BLOCK_FROM_TEMP
    LDX     <M_COPY_SRC_PTR
    CPX     #$27C0
    BCS     .TEST_RAM_LOOP                      ; If ORIGIN < 0x27C0, loop.
    RTS


; ==============================================================================
; TEST_RAM_COPY_BLOCK_TO_TEMP
; ==============================================================================
; LOCATION: 0xC581
;
; DESCRIPTION:
; Copies a 32 byte block from the address in the pointer at 0xF9 to the
; temporary storage location pointed to by 0xFB.
;
; ARGUMENTS:
; Memory:
; * 0xF9:   The source buffer pointer.
; * 0xFB:   The destination buffer pointer.
;
; MEMORY USED:
; * 0x2183: The data source pointer used as an argument to memcpy.
; * 0x2185: The data dest pointer used as an argument to memcpy.
;
; ==============================================================================

TEST_RAM_COPY_BLOCK_TO_TEMP:
    LDX     <M_COPY_SRC_PTR
    STX     $2183
    LDX     <M_COPY_DEST_PTR
    STX     $2185
    BSR     TEST_RAM_MEMCPY
    RTS


; ==============================================================================
; TEST_RAM_COPY_BLOCK_FROM_TEMP
; ==============================================================================
; LOCATION: 0xC58E
;
; DESCRIPTION:
; Copies the RAM contents copied to the temporary location back
; to their original location in memory.
;
; ==============================================================================

TEST_RAM_COPY_BLOCK_FROM_TEMP:
    LDX     <M_COPY_DEST_PTR
    STX     $2183
    LDX     <M_COPY_SRC_PTR
    STX     $2185
    BSR     TEST_RAM_MEMCPY
    LDX     <M_COPY_SRC_PTR
    ABX
    STX     <M_COPY_SRC_PTR                     ; Increment ORIGIN by 32.
    RTS


; ==============================================================================
; TEST_RAM_MEMCPY
; ==============================================================================
; LOCATION: 0xC5A0
;
; DESCRIPTION:
; This function is used when performing the diagnostic tests on the RAM ICs.
; It copies a 32 byte block from  the address in stored in the pointer at
; 0x2183 to the address stored in the pointer at 0x2185.
;
; ARGUMENTS:
; Memory:
; * 0x2185:   Pointer to the destination in memory.
; * 0x2183:   Pointer to the origin in memory.
;
; ==============================================================================

TEST_RAM_MEMCPY:
    CLRB

.TEST_RAM_MEMCPY_LOOP:
    LDX     $2183
    ABX
    LDAA    0,x
    LDX     $2185
    ABX
    STAA    0,x

.INCREMENT_TEST_RAM_LOOP_COUNTER:
    INCB
    CMPB    #32
    BNE     .TEST_RAM_MEMCPY_LOOP
    RTS


; ==============================================================================
; TEST_RAM_BLOCK
; ==============================================================================
; LOCATION: 0xC5B3
;
; DESCRIPTION:
; Tests a 32 byte block of RAM, starting at the address in IX.
; Tests whether the RAM at each byte address can be written, and subsequently
; read without errors. If the same data is not read back, an error condition
; occurs.
;
; ARGUMENTS:
; Registers:
; * IX:   The starting address of the test.
;
; ==============================================================================

TEST_RAM_BLOCK:
    CLRB                                        ; B is used as the loop index.

TEST_RAM_BLOCK_LOOP:
    LDX     <M_COPY_SRC_PTR
    ABX
    LDAA    #$55                                ; 'U'

; Test writing 0x55 to 0xF9+ACCB.
    BSR     TEST_RAM_ADDRESS
    LDAA    #$AA

; Test writing 0xAA to 0xF9+ACCB.
    BSR     TEST_RAM_ADDRESS

.INCREMENT_TEST_BLOCK_LOOP_COUNTER:
    INCB
    CMPB    #32
    BNE     TEST_RAM_BLOCK_LOOP                 ; If ACCB < 32, loop.
    RTS


; ==============================================================================
; TEST_RAM_ADDRESS
; ==============================================================================
; LOCATION: 0xC5C5
;
; DESCRIPTION:
; Tests reading and writing RAM address pointed to by IX.
; The test functions by storing the contents of ACCA to this address, and then
; testing whether the memory read back is identical.
;
; If the memory does not match, an error message is printed to the screen, and
; program execution returns to the main diagnostic test loop.
;
; ARGUMENTS:
; Registers:
; * IX:   The starting address of the test.
; * ACCA: The byte to be written.
;
; ==============================================================================

TEST_RAM_ADDRESS:
    STAA    0,x

; Check whether the memory read back at *(IX) matches ACCA.
    CMPA    0,x
    BNE     .TEST_RAM_FAIL
    RTS

.TEST_RAM_FAIL:
    LDX     #aErrorRamIc
    JSR     LCD_CLR_WRITE_LINE_2_THEN_PRINT

; The following lines pop the return subroutine addresses from the
; stack, and then jump to the main diagnostic loop.

.CLEAR_RETURN_ADDRESSES:
    PULX
    PULX
    PULX
    JMP     TEST_MAIN_LOOP

aErrorRamIc:         FCC "ERROR RAM IC", 0


; ==============================================================================
; HNDLR_RESET
; ==============================================================================
; LOCATION: 0xC5E5
;
; DESCRIPTION:
; Main system reset handler, and firmware program entry point.
; This subroutine resets the internal RAM, and is responsible for ensuring that
; all parameters are set to acceptable values.
;
; ==============================================================================

HANDLER_RESET:
    LDAA    #$FF

; Set all fields in CCR (Condition Code Register).
    TAP

; Set up the synth's IO ports.
; Set all lines in IO Port 4 to function as outputs.
; Set IO Port 1 as an input.
; Set lines 0, and 4 of IO Port 2 to function as outputs.
; For more information refer to page 142 of the Hitachi HD6303 series handbook.

.RESET_IO_PORTS:
    STAA    <IO_PORT_4_DIR
    CLR     IO_PORT_1_DIR
    LDAA    #%10001
    STAA    <IO_PORT_2_DIR
    CLR     IO_PORT_2_DATA

.SET_STACK_TOP:
    LDS     #M_STACK_TOP

; The following memory address is never directly referenced in the code.
; Likely it was used manually for debugging purposes by external tools.
    LDAA    #1
    STAA    $2575

; Ensure that the 'Master Tune' value is within the 0 - 0x1FF range.

.CLAMP_MASTER_TUNE:
    LDD     M_MASTER_TUNE
    LSRD
    CLRA
    LSLD
    STD     M_MASTER_TUNE

.RESET_PITCH_BEND_RANGE:
    LDAA    #13
    CMPA    M_PITCH_BND_RANGE
    BHI     .RESET_PITCH_BEND_STEP
    CLR     M_PITCH_BND_RANGE

.RESET_PITCH_BEND_STEP:
    CMPA    M_PITCH_BND_STEP
    BHI     .RESET_MIDI_CH
    CLR     M_PITCH_BND_STEP

.RESET_MIDI_CH:
    LDAA    #16
    CMPA    M_MIDI_RX_CH
    BHI     .RESET_MIDI_TX_CH                   ; If 16 > MIDI_CH, branch.
    CLR     M_MIDI_RX_CH

.RESET_MIDI_TX_CH:
    CLR     M_MIDI_TX_CH

.RESET_PORTA_TIME:
    LDAA    #100
    CMPA    M_PORTA_TIME
    BHI     .SET_EDIT_PARAM_ABOVE_5
    CLR     M_PORTA_TIME

.SET_EDIT_PARAM_ABOVE_5:
    LDAA    M_EDIT_PARAM_CURRENT
    ANDA    #31
    CMPA    #5
    BHI     .RESET_PATCH_INFO
    LDAA    #6

.RESET_PATCH_INFO:
    STAA    M_EDIT_PARAM_CURRENT

; Set all operators as being enabled.
    LDAA    #%111111
    STAA    M_PATCH_CURRENT_OPS_ON_OFF

; If the currently selected operator is a value above 5, reset to
; the default of 5.

.RESET_SELECTED_OPERATOR:
    LDAA    #5
    CMPA    M_SELECTED_OPERATOR
    BHI     .RESET_SWITCH_MODE
    STAA    M_SELECTED_OPERATOR

; Checks that the synth's input mode is set to a valid value.
; If it's set to an invalid value, the synth is set to a default value
; of 'Function Mode'.

.RESET_SWITCH_MODE:
    LDAA    #INPUT_MODE_FN
    CMPA    M_INPUT_MODE
    BHI     .RESET_UI_MODE
    STAA    M_INPUT_MODE

; Resets the current UI mode. Ensures it has a valid value.

.RESET_UI_MODE:
    LDAA    #UI_MODE_SET_MEM_PROTECT
    CMPA    M_MEM_SELECT_UI_MODE
    BHI     .RESET_LAST_PRESSED_BUTTON
    STAA    M_MEM_SELECT_UI_MODE

.RESET_LAST_PRESSED_BUTTON:
    LDAA    #BUTTON_FUNCTION
    CMPA    M_LAST_PRESSED_BTN
    BHI     .RESET_CURRENT_PATCH_NUMBER
    STAA    M_LAST_PRESSED_BTN

.RESET_CURRENT_PATCH_NUMBER:
    LDAA    #31
    CMPA    M_PATCH_CURRENT_NUMBER
    BHI     .RESET_CURRENT_EDIT_PARAM           ; If <= 31, branch.
    STAA    M_PATCH_CURRENT_NUMBER

.RESET_CURRENT_EDIT_PARAM:
    CMPA    M_FN_PARAM_CURRENT
    BHI     .RESET_INT_RAM                      ; If <= 31, branch.
    STAA    M_FN_PARAM_CURRENT

; This subroutine clears all 128 bytes of internal RAM.

.RESET_INT_RAM:
    LDX     #$80
    LDAB    #128

.RESET_INT_RAM_BYTE:
    CLR     0,x
    INX
    DECB
    BNE     .RESET_INT_RAM_BYTE                 ; If ACCB > 0, loop.

; Reset memory protection flags.
; Sets protection for both CRT and INT memory ON.

.RESET_MEM_PROTECT:
    LDAA    #%11000000
    STAA    <M_MEM_PROTECT_FLAGS
    LDAA    #$F7
    STAA    M_ERR_HANDLING_FLAG

.RESET_VOICES:
    JSR     VOICE_RESET_EVENT_AND_PITCH_BUFFERS
    LDAA    #7
    STAA    P_DAC

.RESET_ANALOG_INPUT_VALUES:
    CLRA
    STAA    M_MOD_WHEEL_ANALOG_INPUT
    STAA    M_BRTH_CTRL_ANALOG_INPUT
    STAA    M_AFTERTOUCH_ANALOG_INPUT
    STAA    M_FOOT_CTRL_ANALOG_INPUT
    JSR     VOICE_DEACTIVATE_ALL
    JSR     MOD_PROCESS_INPUT_SOURCES
    JSR     PORTA_COMPUTE_RATE_VALUE

; Resets the LCD screen buffers, initialises the LCD controller,
; then prints the synth's 'Welcome Message'.
    JSR     LCD_CLEAR_STR_BUFFER
    JSR     LCD_INIT
    JSR     MIDI_INIT
    LDAA    #1
    STAA    <IO_PORT_2_DATA

.RESET_LED:
    CLRA
    STAA    P_LED2
    STAA    P_LED1
    TAP                                         ; Clear CCR.

; Delay for 100x450 cycles to display the synth's welcome message.
    LDAB    #100

.RESET_WELCOME_DELAY:
    JSR     DELAY_450_CYCLES
    DECB
    BNE     .RESET_WELCOME_DELAY                ; If ACCB > 0, loop.
; Enable OCF IRQ.

.RESET_TIMER_INT:
    LDAA    #%1000
    STAA    <TIMER_CTRL_STATUS
    TST     M_INPUT_MODE
    BNE     .LOAD_PATCH_FROM_WRK_BFR

; The following code loads whatever patch was previously selected.
; If it has been edited, the patch is loaded from the edit buffer,
; otherwise it is reloaded from its original location in RAM.

.LOAD_PATCH:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_WORKING
    BEQ     .LOAD_PATCH_FROM_WRK_BFR

.LOAD_PATCH_FROM_RAM:
    LDAA    M_PATCH_CURRENT_NUMBER
    STAA    M_LAST_PRESSED_BTN
    TST     M_MEM_SELECT_UI_MODE
    BEQ     .SWITCH_TO_PATCH
    JSR     MEMORY_SELECT_CRT
    TST     M_MEM_SELECT_UI_MODE
    BEQ     .BATTERY_CHECK

.SWITCH_TO_PATCH:
    JSR     PATCH_PROGRAM_CHANGE
    BRA     .BATTERY_CHECK

.LOAD_PATCH_FROM_WRK_BFR:
    JSR     UI_PRINT_MAIN
    JSR     PATCH_LOAD_DATA
    JSR     LED_PRINT_PATCH_NUMBER

.BATTERY_CHECK:
    JSR     BATTERY_CHECK

.RESET_PORTA_SUS_PDL_STATUS:
    LDAA    P_CRT_PEDALS_LCD
    ANDA    #PEDAL_STATUS_MASK
    STAA    M_PEDAL_INPUT_STATUS_PREVIOUS
    STAA    <M_PEDAL_INPUT_STATUS               ; Falls-through to main loop.


; ==============================================================================
; MAIN_LOOP
; ==============================================================================
; LOCATION: 0xC708
;
; DESCRIPTION:
; The synth's executive main loop.
; This loop calls some of the synth's main core functionality, such as
; processing button input. After it has been received, and buffered, the
; synth's incoming MIDI data is processed here.
; The other point of interest for the synth's core functionality is the OCF
; timer interrupt handler, which handles the periodic updating of the synth's
; sound chips.
;
; ==============================================================================

MAIN_LOOP:
    BSR     MAIN_PROCESS_INPUT
    JSR     MIDI_PROCESS_RECEIVED_DATA
    JSR     MAIN_PORTA_SUS_PDL_STATE_UPDATE
    JSR     MAIN_ACTV_SENS_TX_CHECK
    JSR     MAIN_VALIDATE_PORTAMENTO
    JSR     MAIN_CHECK_MIDI_ERROR_FLAG
    BRA     MAIN_LOOP


; ==============================================================================
; MAIN_PROCESS_BUTTON_INPUT
; ==============================================================================
; LOCATION: 0xC71B
;
; DESCRIPTION:
; Handles the button input recorded in the interrupt function.
;
; ==============================================================================

MAIN_PROCESS_INPUT:
    LDAA    <M_LAST_ANALOG_INPUT_EVENT

; Check whether there is a button event that needs processing.
; If the last analog input source value is '0', or above '43', then the last
; physical user action was something other than a button press.
; In this case, return.
    BEQ     .END_MAIN_PROCESS_INPUT
    CLR     M_LAST_ANALOG_INPUT_EVENT
    CMPA    #43
    BHI     .END_MAIN_PROCESS_INPUT             ; If A > 43, branch.

.IS_LAST_INPUT_SOURCE_SLIDER?:
    BEQ     .IS_UI_MODE_MEM_PROTECT?
    CLR     M_SLIDER_INPUT_EVENT

.IS_UI_MODE_MEM_PROTECT?:
    LDAB    M_MEM_SELECT_UI_MODE
    CMPB    #UI_MODE_SET_MEM_PROTECT
    BNE     .IS_EDITING_PATCH_NAME?

.IS_BUTTON_ABOVE_33?:
    CMPA    #33
    BCS     MAIN_PROCESS_INPUT_END              ; If A > 33, return.

; If the user is in the process of editing a patch name, and is in
; 'ASCII Input Mode' capture all button input, and handle it in this
; handler. The 'Key Transpose Active' flag is cleared at this point.

.IS_EDITING_PATCH_NAME?:
    CLR     M_EDIT_KEY_TRANSPOSE_ACTIVE
    TST     M_EDIT_ASCII_MODE
    BNE     .EDIT_PATCH_NAME

; Test if the 'Function' button is being pressed.
; If so, test whether the diagnostic mode button combination is active.
    TST     M_BTN_FUNC_STATE
    BNE     .FN_IS_DOWN
    LDAB    M_INPUT_MODE
    TST     M_PATCH_READ_OR_WRITE
    BEQ     .LOOKUP_BTN_FN_TABLE
    CMPB    #INPUT_MODE_EDIT
    BNE     .LOOKUP_BTN_FN_TABLE
    CMPA    #6
    BHI     MAIN_PROCESS_INPUT_END

; Load the table of button mode pointers, and use the current 'Input Mode'
; as an index into the table. From this table, the table of function pointers
; used to facilitate the button functions is loaded.

.LOOKUP_BTN_FN_TABLE:
    ASLB
    LDX     #TABLE_SWITCH_MODES
    ABX
    LDX     0,x
    LDAB    M_LAST_INPUT_EVENT
    TST     M_INPUT_MODE
    BNE     .LOAD_BTN_FUNCTION_PTR

; If the synth is in 'Play Mode', start at index 31, since buttons 0-30 all
; perform the identical task of loading a patch. For this reason, if the
; triggering button is below, or equal to 31, set to 0.
    SUBB    #31
    BPL     .LOAD_BTN_FUNCTION_PTR
    CLRB

; Use the current button as an index into this mode's table of function
; pointers, then jump to the appropriate subroutine associated with the
; last-pressed button.

.LOAD_BTN_FUNCTION_PTR:
    PSHB
    ASLB
    ABX
    LDX     0,x
    JSR     0,x
    PULB
    LDAA    M_INPUT_MODE
    BEQ     .BTN_MODE_PLAY
    CMPA    #INPUT_MODE_EDIT
    BEQ     .BTN_MODE_EDIT
    BRA     LCD_SET_CURSOR_BLINK_OFF

; If the synth is in 'Play Mode', and the patch in the 'Edit Buffer' has
; not been modified, then turn the LCD blinking cursor off.

.BTN_MODE_PLAY:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_WORKING
    BNE     LCD_SET_CURSOR_BLINK_OFF

.END_MAIN_PROCESS_INPUT:
    RTS

; The following sequence checks the various scenarios in which the LCD
; blinking effect should NOT be turned off. The following sequence
; falls-through to turn the LCD blink off.

.BTN_MODE_EDIT:
    BNE     LCD_SET_CURSOR_BLINK_OFF
    CMPB    #BUTTON_6
    BLS     MAIN_PROCESS_INPUT_END
    CMPB    #BUTTON_32
    BEQ     MAIN_PROCESS_INPUT_END
    CMPB    #BUTTON_STORE
    BEQ     MAIN_PROCESS_INPUT_END
    CMPB    #BUTTON_EDIT_CHAR
    BEQ     MAIN_PROCESS_INPUT_END
    CMPB    #BUTTON_FUNCTION
    BHI     MAIN_PROCESS_INPUT_END


; ==============================================================================
; LCD_SET_CURSOR_BLINK_OFF
; ==============================================================================
; LOCATION: 0xC798
;
; DESCRIPTION:
; Sends an instruction to the LCD controller to disable the blinking cursor
; effect.
;
; ==============================================================================

LCD_SET_CURSOR_BLINK_OFF:
    LDAA    #LCD_INSTR_SET_BLINK_OFF
    JSR     LCD_WRITE_INSTRUCTION
    CLR     M_PATCH_NAME_EDIT_ACTIVE

MAIN_PROCESS_INPUT_END:
    RTS


.EDIT_PATCH_NAME:
    JSR     INPUT_EDIT_PATCH_NAME_ASCII_MODE
    RTS

.FN_IS_DOWN:
    JSR     INPUT_CHECK_TEST_BTN_COMBO
    RTS

; ==============================================================================
; Pointers to the tables of button handling function pointers for each of the
; synth's three button modes.
; ==============================================================================
TABLE_SWITCH_MODES:
    FDB TABLE_BTN_MODE_PLAY
    FDB TABLE_BTN_MODE_EDIT
    FDB TABLE_BTN_MODE_FUNC

; ==============================================================================
; 'Play Mode' (Mode 0) button function pointers.
; This table starts at button 32, since in play mode buttons 0-31 initiate
; loading a patch from memory.
; ==============================================================================
TABLE_BTN_MODE_PLAY:
    FDB PATCH_PROGRAM_CHANGE
    FDB BTN_STORE
    FDB BTN_MEMORY_PROTECT
    FDB BTN_MEMORY_PROTECT
    FDB BTN_CLEAR_RW_FLAG_AND_EXIT
    FDB BTN_EDIT                                ; Index 8.
    FDB MEMORY_SELECT_INT
    FDB MEMORY_SELECT_CRT
    FDB BTN_FUNC
    FDB BTN_YES_NO_SEND_MIDI
    FDB BTN_YES_NO_SEND_MIDI
    FDB BTN_HNDLR_42
    FDB BTN_SLIDER

; ==============================================================================
; Function pointers for the button handlers for each of the synth's buttons
; when in 'Edit Mode'.
; ==============================================================================
TABLE_BTN_MODE_EDIT:
    FDB BTN_EDIT_COPY_OP                        ; Button 1.
    FDB BTN_EDIT_COPY_OP
    FDB BTN_EDIT_COPY_OP
    FDB BTN_EDIT_COPY_OP
    FDB BTN_EDIT_COPY_OP
    FDB BTN_EDIT_COPY_OP
    FDB BTN_EDIT_PARAM                          ; Button 7.
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_OSC_MODE_SYNC                  ; Button 17.
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_EG_RATE_LVL                    ; Button 21.
    FDB BTN_EDIT_EG_RATE_LVL
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_KBD_SCALING                    ; Button 24.
    FDB BTN_EDIT_KBD_SCALING
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_PARAM
    FDB BTN_EDIT_EG_RATE_LVL
    FDB BTN_EDIT_EG_RATE_LVL
    FDB BTN_EDIT_KEY_TRANSPOSE                  ; Button 31.
    FDB BTN_EDIT_VOICE_NAME
    FDB BTN_STORE
    FDB BTN_MEMORY_PROTECT
    FDB BTN_MEMORY_PROTECT
    FDB BTN_EDIT_OP_SELECT
    FDB BTN_EDIT
    FDB MEMORY_SELECT_INT
    FDB MEMORY_SELECT_CRT
    FDB BTN_FUNC
    FDB BTN_YES_NO_SEND_MIDI                    ; Index 40.
    FDB BTN_YES_NO_SEND_MIDI
    FDB BTN_HNDLR_42
    FDB BTN_SLIDER

; ==============================================================================
; Function pointers for the button handlers for each of the synth's buttons
; when in 'Function Mode'.
; ==============================================================================
TABLE_BTN_MODE_FUNC:
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_MIDI
    FDB BTN_FN_PARAM                            ; Index 8.
    FDB BTN_FN_PARAM
    FDB SET_UI_TO_FN_MODE
    FDB BTN_CLEAR_RW_FLAG_AND_EXIT
    FDB BTN_CLEAR_RW_FLAG_AND_EXIT
    FDB BTN_FN_PARAM
    FDB BTN_CRT_LOAD_SAVE
    FDB BTN_CRT_LOAD_SAVE
    FDB BTN_FN_PARAM                            ; Index 16.
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM                            ; Index 24.
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_FN_PARAM
    FDB BTN_CLEAR_RW_FLAG_AND_EXIT              ; Index 32.
    FDB BTN_MEMORY_PROTECT
    FDB BTN_MEMORY_PROTECT
    FDB BTN_CLEAR_RW_FLAG_AND_EXIT
    FDB BTN_EDIT
    FDB MEMORY_SELECT_INT
    FDB MEMORY_SELECT_CRT
    FDB BTN_FUNC
    FDB BTN_YES_NO_SEND_MIDI                    ; Index 40.
    FDB BTN_YES_NO_SEND_MIDI
    FDB BTN_CLEAR_RW_FLAG_AND_EXIT
    FDB BTN_SLIDER


; ==============================================================================
; MAIN_PORTA_SUS_PDL_STATE_UPDATE
; ==============================================================================
; LOCATION: 0xC879
;
; DESCRIPTION:
; Checks the current status of the Portamento/Sustain pedal, checking whether
; it has changed since the last time this subroutine was run. If it has, it
; sends the appropriate Portamento/Sustain mode change message over MIDI.
; The Portamento/Sustain pedal state flags are set here.
;
; ==============================================================================

MAIN_PORTA_SUS_PDL_STATE_UPDATE:
    LDAA    P_CRT_PEDALS_LCD
    ANDA    #PEDAL_STATUS_MASK
    PSHA

; Compare IO Port C's current state to that of the sustain/porta pedal
; status recorded on the previous iteration.

.CHECK_SUSTAIN_PEDAL_STATUS:
    ANDA    #1

; Check whether the current state differs from the previous state.
    EORA    M_PEDAL_INPUT_STATUS_PREVIOUS
    BITA    #1
    BEQ     .CHECK_PORTA_PEDAL_STATUS
    PULA
    PSHA                                        ; Restore, and save A.
    BITA    #1

; If the state has changed, set the appropriate bit in the
; Portamento/Sustain pedal flags register.
; Set ACCB to 127 if the status changed to 'ON', otherwise 0 for 'OFF'.
; The next method will then transfer the appropriate mode change data
; to the MIDI TX buffer.
    BEQ     .SUSTAIN_STATE_CHANGED_OFF

.SUSTAIN_STATE_CHANGED_ON:
    OIM     #1, M_PEDAL_INPUT_STATUS
    LDAB    #127
    BRA     .SEND_SUSTAIN_MIDI_MSG

.SUSTAIN_STATE_CHANGED_OFF:
    AIM     #%11111110, M_PEDAL_INPUT_STATUS
    JSR     MAIN_PROCESS_SUSTAIN_PEDAL
    CLRB

.SEND_SUSTAIN_MIDI_MSG:
    JSR     MIDI_SEND_CC_64

.CHECK_PORTA_PEDAL_STATUS:
    PULA
    PSHA                                        ; Restore, and save A.

; Check whether the current state differs from the previous state.
    EORA    M_PEDAL_INPUT_STATUS_PREVIOUS

; Refer to documentation above regarding handling the state change,
; and sending the appropriate MIDI message.
    BITA    #%10
    BEQ     .END_MAIN_PORTA_SUS_PDL_STATE_UPDATE
    PULA
    PSHA
    BITA    #%10
    BEQ     .PORTA_STATE_CHANGED_OFF

.PORTA_STATE_CHANGED_ON:
    OIM     #%10, M_PEDAL_INPUT_STATUS
    LDAB    #127
    BRA     .SEND_PORTA_MIDI_MSG

.PORTA_STATE_CHANGED_OFF:
    AIM     #%11111101, M_PEDAL_INPUT_STATUS
    CLRB

.SEND_PORTA_MIDI_MSG:
    JSR     MIDI_SEND_CC_65

.END_MAIN_PORTA_SUS_PDL_STATE_UPDATE:
    PULA
    STAA    M_PEDAL_INPUT_STATUS_PREVIOUS
    RTS


; ==============================================================================
; MAIN_ACTV_SENS_TX_CHECK
; ==============================================================================
; LOCATION: 0xC8C1
;
; DESCRIPTION:
; Checks whether the active sensing signal trigger is set. If so, an
; 'active sensing' MIDI message is pushed to the synth's MIDI TX buffer.
;
; ==============================================================================

MAIN_ACTV_SENS_TX_CHECK:
    TST     M_MIDI_ACTV_SENS_TX_TRIGGER
    BEQ     .END_MAIN_ACTV_SENS_TX_CHECK
    JSR     MIDI_SEND_ACTIVE_SENSING
    CLR     M_MIDI_ACTV_SENS_TX_TRIGGER

.END_MAIN_ACTV_SENS_TX_CHECK:
    RTS


; ==============================================================================
; MAIN_VALIDATE_PORTAMENTO
; ==============================================================================
; LOCATION: 0xC8CD
;
; DESCRIPTION:
; Validates that the portamento rate increment value is set to a non-zero
; value.
; If this value is zero, then the portamento increment value is calculated.
;
; ==============================================================================

MAIN_VALIDATE_PORTAMENTO:
    TST     M_PORTA_RATE_INCREMENT
    BEQ     .PORTA_RATE_INVALID
    RTS

.PORTA_RATE_INVALID:
    JMP     PORTA_COMPUTE_RATE_VALUE


; ==============================================================================
; MAIN_CHECK_MIDI_ERROR_FLAG
; ==============================================================================
; LOCATION: 0xC8D6
;
; DESCRIPTION:
; Checks whether the MIDI error flag has been set. If so, it prints the
; appropriate message to the LCD screen.
;
; ==============================================================================

MAIN_CHECK_MIDI_ERROR_FLAG:
    LDAA    <M_MIDI_BUFFER_ERROR_CODE
    CMPA    #MIDI_STATUS_ERROR
    BNE     .STATUS_NON_ZERO
    LDX     #aMidiDataError
    BRA     .PRINT_MIDI_ERROR

.STATUS_NON_ZERO:
    CMPA    #MIDI_STATUS_BUFFER_FULL
    BNE     .END_MAIN_CHECK_MIDI_ERROR_FLAG
    LDX     #aMidiBufferFull

.PRINT_MIDI_ERROR:
    JSR     LCD_CLR_WRITE_LINE_2_THEN_PRINT
    CLR     M_MIDI_BUFFER_ERROR_CODE
    LDAA    #$F7
    STAA    M_ERR_HANDLING_FLAG

.END_MAIN_CHECK_MIDI_ERROR_FLAG:
    RTS


; ==============================================================================
; HNDLR_IRQ
; ==============================================================================
; LOCATION: 0xC8F4
;
; DESCRIPTION:
; The synth's main interrupt handling routine.
; Button, and Key input is handled here.
; This subroutine is responsible for 'reading' analog data from the synth's
; 'Sub-CPU'. This data arrives in two-byte packets.
; The first byte of which indicates the source of the analog data, the second
; byte indicates the value.
; The source of the data determines how the synth handles this data.
;
; Refer to the Service Manual for more information regarding the handshake
; mechanism used to communicate with the synth's 'Sub-CPU'.
;
; ==============================================================================

HANDLER_IRQ:
    LDAB    <IO_PORT_2_DATA
    PSHB
    JSR     READ_BYTE_FROM_SUB_CPU
    CMPA    #158
    BLS     .IS_BTN_DOWN_EVENT?                 ; If A <= 158, branch.

; An 'origin' value above 158 indicates that this data originates from a
; keyboard event. The first data byte is the source, indicating which key
; was pressed, the second data byte indicates the velocity.
; The DX7 considers a key event with zero velocity to be a 'Key Up' event.

.KEYBOARD_INPUT:
    STAA    <M_SUB_CPU_READ_KEY

; Subtract 123, since the keyboard starts at C2 (MIDI 36).
; @TODO: Verify.
    SUBA    #123
    STAA    <M_NOTE_KEY
    JSR     READ_BYTE_FROM_SUB_CPU
    STAA    <M_NOTE_VEL
    BEQ     .HANDLE_KEY_UP_EVENT

.HANDLE_KEY_DOWN_EVENT:
    CLI
    LDAA    #44
    STAA    <M_LAST_ANALOG_INPUT_EVENT
    JSR     INPUT_KEY_DOWN
    JMP     HNDLR_IRQ_EXIT

.HANDLE_KEY_UP_EVENT:
    CLI
    JSR     INPUT_KEY_UP
    JMP     HNDLR_IRQ_EXIT
; A value of '152' indicates a 'Button Pressed' event.
; Subtract 80 from the 'source' value to properly index the buttons.

.IS_BTN_DOWN_EVENT?:
    CMPA    #152
    BNE     .IS_BTN_UP_EVENT?

.HANDLE_BTN_DOWN:
    JSR     READ_BYTE_FROM_SUB_CPU
    CLI
    SUBA    #80
    JSR     INPUT_BTN_PRESSED
    JMP     HNDLR_IRQ_EXIT


; ==============================================================================
; INPUT_BTN_PRESSED
; ==============================================================================
; LOCATION: 0xC92D
;
; DESCRIPTION:
; Input handler function for when a front-panel button is pressed.
;
; ==============================================================================

INPUT_BTN_PRESSED:
    STAA    M_LAST_INPUT_EVENT
    INCA
    STAA    <M_LAST_ANALOG_INPUT_EVENT
    DECA
    PSHA

; Check if the 'Begin Test Yes/No?' dialog is active.
; This is the point where the user selects whether they want to enter the
; synth's diagnostic mode. Selecting 'Yes' at this point jumps to the main
; diagnostic mode entry point.

.INIT_TEST_MODE_CHECK?:
    LDAA    <M_TEST_MODE_BUTTON_CHECK
    CMPA    #2
    BNE     .PULL_A_AND_END

.IS_BTN_YES?:
    PULA
    CMPA    #BUTTON_YES_UP
    BNE     .BTN_NOT_YES

.YES_TO_TEST?:
    CLR     M_LAST_ANALOG_INPUT_EVENT
    LDAB    #1
    STAB    <IO_PORT_2_DATA
    JMP     TEST_ENTRY

; If 'No' is pressed, clear the test trigger flags, and restore the
; previous state.

.BTN_NOT_YES:
    CLR     M_TEST_MODE_BUTTON_CHECK
    LDAA    M_FN_PARAM_CURRENT
    STAA    M_LAST_INPUT_EVENT
    INCA
    STAA    <M_LAST_ANALOG_INPUT_EVENT
    BRA     .END_INPUT_BTN_PRESSED

.PULL_A_AND_END:
    PULA

.END_INPUT_BTN_PRESSED:
    LDAA    M_LAST_INPUT_EVENT
    STAA    M_LAST_PRESSED_BTN
    RTS

; A value of '152' indicates a 'Button Released' event.
; Subtract 80 from the 'source' value to properly index the buttons.


.IS_BTN_UP_EVENT?:
    CMPA    #153
    BNE     .IS_ANALOG_INPUT_EVENT?

.HANDLE_BTN_UP:
    JSR     READ_BYTE_FROM_SUB_CPU
    CLI
    SUBA    #80
    JSR     INPUT_BTN_RELEASED
    JMP     HNDLR_IRQ_EXIT


; ==============================================================================
; INPUT_BTN_RELEASED
; ==============================================================================
; LOCATION: 0xC970
;
; DESCRIPTION:
; Input handler for when a front-panel button is released.
;
; ==============================================================================

INPUT_BTN_RELEASED:
    CMPA    #BUTTON_STORE
    BEQ     .UI_FN_STORE

.IS_BTN_EDIT?:
    CMPA    #BUTTON_EDIT_CHAR
    BEQ     .BTN_EDIT

.IS_BTN_FUNC?:
    CMPA    #BUTTON_FUNCTION
    BEQ     .CLEAR_FUNC_BUTTON_STATE

; Check if the released button is button 16. If so, check if the test mode
; button check counter is 1. If it is, reset it to 0. Refer to the input
; 'Test button combo' check function for more information.

.IS_BTN_16?:
    CMPA    #BUTTON_16
    BEQ     .BTN_IS_16
    RTS

; Test if the synth is currently in the process of using the
; 'Edit/Char' key to input characters. If so, exit here. Since in this
; mode this button is used to enter a character.

.UI_FN_STORE:
    TST     M_EDIT_ASCII_MODE
    BNE     .UI_FN_STORE_ABORT
    CLR     M_PATCH_READ_OR_WRITE
    LDAA    #42
    STAA    M_LAST_INPUT_EVENT
    STAA    <M_LAST_ANALOG_INPUT_EVENT

.UI_FN_STORE_ABORT:
    RTS

; If the 'Edit' button is being released, then clear the 'ASCII Edit Mode'
; flag used for inputting chars from the front-panel buttons.

.BTN_EDIT:
    CLR     M_EDIT_ASCII_MODE
    RTS

.CLEAR_FUNC_BUTTON_STATE:
    CLR     M_BTN_FUNC_STATE
    RTS

.BTN_IS_16:
    LDAA    <M_TEST_MODE_BUTTON_CHECK
    CMPA    #1
    BEQ     .RESET_TEST_MODE_BTN_CHECK
    RTS

.RESET_TEST_MODE_BTN_CHECK:
    CLR     M_TEST_MODE_BUTTON_CHECK
    RTS


; Handle any other non-button, non-keyboard analog input event.

.IS_ANALOG_INPUT_EVENT?:
    CMPA    #143
    BLS     INPUT_ANALOG_STORE_EVENT

.HANDLE_ANALOG_INPUT_EVENT:
    ANDA    #%111
    STAA    <M_ANALOG_DATA_SRC
    JSR     READ_BYTE_FROM_SUB_CPU
    CLI
    ASLA
    STAA    <M_ANALOG_DATA
    LDAB    <M_ANALOG_DATA_SRC
    ANDB    #%111
    JSR     JUMP_TO_RELATIVE_OFFSET

; ==============================================================================
; The following is a table of relative-addressed pointers to
; the functions which handle the various analog input events.
; The first byte is the relative byte offset, the second byte is
; the event number.
; e.g. If the event number was 3, the offet from 0xC9BE to the handler
; function is 0x1E.
; ==============================================================================
TABLE_ANALOG_EVENT_HANDLER_OFFSETS:
    FCB $4F
    FCB 1                                       ; Jumps to 0xCA09.
    FCB $15
    FCB 2                                       ; Jumps to 0xC9D1.
    FCB $1E
    FCB 3                                       ; Jumps to 0xC9DC.
    FCB $2C
    FCB 4                                       ; Jumps to 0xC9EC.
    FCB $32
    FCB 5                                       ; Jumps to 0xC9F4.
    FCB $38
    FCB 6                                       ; Jumps to 0xC9FC.
    FCB $3E
    FCB 7                                       ; Jumps to 0xCA04.
    FCB 2
    FCB 0                                       ; Jumps to 0xC9CA.


INPUT_ANALOG_STORE_EVENT:
    LDAA    #45
    STAA    <M_LAST_ANALOG_INPUT_EVENT
    JMP     HNDLR_IRQ_EXIT


; ==============================================================================
; INPUT_ANALOG_SRC_2
; ==============================================================================
; LOCATION: 0xC9D1
;
; DESCRIPTION:
; Input handler function for when the source of a particular analog event
; is '2': The synth's pitch bend wheel.
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_2:
    STAA    M_PITCH_BEND_INPUT
    JSR     MIDI_SEND_PITCH_BEND
    JSR     PITCH_BEND_PARSE
    BRA     INPUT_ANALOG_STORE_EVENT


; ==============================================================================
; INPUT_ANALOG_SRC_3
; ==============================================================================
; LOCATION: 0xC9DC
;
; DESCRIPTION:
; Input handler function for when the source of a particular analog event
; is '3': the synth's mod wheel.
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_3:
    STAA    M_MOD_WHEEL_ANALOG_INPUT
    JSR     MIDI_SEND_CC_1_FROM_ANALOG_INPUT


; ==============================================================================
; INPUT_ANALOG_UPDATE_MODULATION
; ==============================================================================
; LOCATION: 0xC9E2
;
; DESCRIPTION:
; This subroutine is responsible for updating the synth's modulation after
; receiving an analog input event from a modulation source. Such as the mod
; wheel, aftertouch, foot, or breath control.
;
; ==============================================================================

INPUT_ANALOG_UPDATE_MODULATION:
    COM     M_INPUT_ANALOG_UPDATE_MOD_TOGGLE
    BNE     .STORE_ANALOG_INPUT
    JSR     MOD_PROCESS_INPUT_SOURCES

.STORE_ANALOG_INPUT:
    BRA     INPUT_ANALOG_STORE_EVENT


; ==============================================================================
; INPUT_ANALOG_SRC_4
; ==============================================================================
; LOCATION: 0xC9EC
;
; DESCRIPTION:
; Input handler function for when the source of a particular analog event
; is '2': The synth's foot control input.
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_4:
    STAA    M_FOOT_CTRL_ANALOG_INPUT
    JSR     MIDI_SEND_CC_4_FROM_ANALOG_INPUT
    BRA     INPUT_ANALOG_UPDATE_MODULATION


; ==============================================================================
; INPUT_ANALOG_SRC_5
; ==============================================================================
; LOCATION: 0xC9F4
;
; DESCRIPTION:
; Input handler function for when the source of a particular analog event
; is '2': The synth's breath control input.
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_5:
    STAA    M_BRTH_CTRL_ANALOG_INPUT
    JSR     MIDI_SEND_CC_2_FROM_ANALOG_INPUT
    BRA     INPUT_ANALOG_UPDATE_MODULATION


; ==============================================================================
; INPUT_ANALOG_SRC_6
; ==============================================================================
; LOCATION: 0xC9FC
;
; DESCRIPTION:
; Input handler function for when the source of a particular analog event
; is '2': The synth's keys' aftertouch.
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_6:
    STAA    M_AFTERTOUCH_ANALOG_INPUT
    JSR     MIDI_SEND_AFTERTOUCH
    BRA     INPUT_ANALOG_UPDATE_MODULATION


; ==============================================================================
; INPUT_ANALOG_SRC_7
; ==============================================================================
; LOCATION: 0xCA04
;
; DESCRIPTION:
; Input handler function for when the source of a particular analog event
; is '2': The synth's battery voltage.
; This is where the battery voltage is updated.
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_7:
    STAA    M_BATTERY_VOLTAGE
    BRA     INPUT_ANALOG_STORE_EVENT


; ==============================================================================
; INPUT_ANALOG_SRC_1
; ==============================================================================
; LOCATION: 0xCA09
;
; DESCRIPTION:
; Handles an analog input event originating from
; source 1 (the synth's front-panel slider).
; This function is reached via the 'JUMP_TO_RELATIVE_OFFSET' subroutine,
; called from the main IRQ handler.
;
; ==============================================================================

INPUT_ANALOG_SRC_1:
    JSR     MIDI_SEND_SLIDER_EVENT
    JSR     INPUT_SLIDER
    JMP     HNDLR_IRQ_EXIT


; ==============================================================================
; INPUT_SLIDER
; ==============================================================================
; LOCATION: 0xCA12
;
; DESCRIPTION:
; Handler function for parsing, and acting upon analog input from the
; synth's front-panel slider. The currently selected parameter will be altered
; from this function.
;
; ==============================================================================

INPUT_SLIDER:
    LDAA    #1

; Set this flag to '1' to indicate that this 'Up/Down' event came from
; slider input. If the synth's input mode is 0 ('Play' Mode), set
; to 2 ('Function' Mode) as a default.
    STAA    <M_SLIDER_INPUT_EVENT
    LDAB    M_INPUT_MODE
    BNE     .LOAD_EDIT_PARAM
    LDAB    #INPUT_MODE_FN

; Load a pointer to the 'Slider Edit Parameters' table.
; This table contains pointers to a pointer to the current parameter in
; memory that's being edited, depending on what input mode the synth is in.

.LOAD_EDIT_PARAM:
    ASLB
    LDX     #TABLE_SLIDER_EDIT_PARAMS
    ABX

; Load a pointer to the current parameter for this 'Input Mode' into IX,
; and then load this parameter's value into ACCB.
    LDX     0,x
    LDAB    0,x
    PSHB

; If the synth's input mode is 0 ('Play' Mode), set to
; mode 2 ('Function' Mode) as a default.

.CHECK_INPUT_MODE:
    LDAB    M_INPUT_MODE
    BNE     .LOAD_MAX_VALUE_TABLE
    LDAB    #INPUT_MODE_FN

; Load the pointer to the correct maximum value table, depending on what
; 'Input Mode' the synth is currently in.

.LOAD_MAX_VALUE_TABLE:
    ASLB
    LDX     #TABLE_SLIDER_MAX_VALUES
    ABX
    LDX     0,x

; Load the currently edited parameter's maximum value into ACCA.

.LOAD_MAX_VALUE:
    PULB
    ABX
    LDAA    0,x
    INCA

.CALCULATE_INCREMENT:
    LDAB    <M_ANALOG_DATA
    MUL
    STAA    <M_UP_DOWN_INCREMENT

.END_INPUT_SLIDER:
    LDAA    #43
    STAA    <M_LAST_ANALOG_INPUT_EVENT
    STAA    M_LAST_INPUT_EVENT
    RTS


; ==============================================================================
; Slider Edit Param Table.
; This table contains pointers to the current variable being edited by the
; synth's front-panel slider input, depending on what 'Input Mode' the synth
; is currently in.
; ==============================================================================
TABLE_SLIDER_EDIT_PARAMS:
    FDB 0
    FDB M_EDIT_PARAM_CURRENT
    FDB M_FN_PARAM_CURRENT

; ==============================================================================
; Pointers to the tables of maximum values for the current parameter being
; edited by the front-panel slider, depending on what 'Input Mode' the synth
; is currently in.
; ==============================================================================
TABLE_SLIDER_MAX_VALUES:
    FDB 0
    FDB TABLE_MAX_VALUE_EDIT_MODE
    FDB TABLE_MAX_VALUE_FUNC_MODE

HNDLR_IRQ_EXIT:
    PULB

; Restore interrupt status.
    STAB    <IO_PORT_2_DATA


; ==============================================================================
; HANDLER_NMI
; ==============================================================================
; LOCATION: 0xCA56
;
; DESCRIPTION:
; Generic interrupt handler for all non-maskable, and
; otherwise unhandled interrupts.
;
; ==============================================================================

HANDLER_NMI:
    RTI


; ==============================================================================
; READ_BYTE_FROM_SUB_CPU
; ==============================================================================
; LOCATION: 0xCA57
;
; DESCRIPTION:
; Reads a byte from the sub-CPU into ACCA. This function waits until the CPU
; line 21 goes high to indicate the end of transmission, as per the service
; manual.
;
; ==============================================================================

READ_BYTE_FROM_SUB_CPU:
    TIM     #%10, IO_PORT_2_DATA

; Loop if CPU line 21 has not yet gone low.
    BNE     READ_BYTE_FROM_SUB_CPU

; Read byte from IO Port 1.
    LDAA    <IO_PORT_1_DATA
    CLR     IO_PORT_2_DATA

; Reset port 2 status?
    STAB    P_ACEPT
    RTS


; ==============================================================================
; BTN_EDIT
; ==============================================================================
; LOCATION: 0xCA65
;
; DESCRIPTION:
; This is the handler for the 'Edit' button being pressed.
; This is where functionality for comparing a working patch is facilitated.
;
; ==============================================================================

BTN_EDIT:
    LDAA    #INPUT_MODE_EDIT
    STAA    M_INPUT_MODE

.IS_NAME_EDIT_ACTIVE?:
    TST     M_PATCH_NAME_EDIT_ACTIVE
    BEQ     .BTN_EDIT_DISABLE_INTERRUPTS

; If the synth is currently in patch name edit mode, then holding down the
; 'Char/Edit' button will change the synth's front panel buttons to input
; characters directly.
; This flag is cleared in the 'Button Up' event handler.
; Refer to page 46 of the DX7 manual.

.SET_PATCH_EDIT_FLAG:
    LDAA    #1
    STAA    <M_EDIT_ASCII_MODE
    RTS

; Save IRQ state.

.BTN_EDIT_DISABLE_INTERRUPTS:
    LDAA    <IO_PORT_2_DATA
    PSHA

; Save timer state.
    LDAA    <TIMER_CTRL_STATUS
    PSHA

; Clear timer and port 2 interrupts.
    CLR     IO_PORT_2_DATA
    CLR     TIMER_CTRL_STATUS
    LDAA    #LCD_INSTR_SET_BLINK_OFF
    JSR     LCD_WRITE_INSTRUCTION

; If we're not in the process of editing the synth parameters, exit.
; Otherwise fall-through to 'PATCH_COMPARE'.
    LDAA    M_MEM_SELECT_UI_MODE
    CMPA    #UI_MODE_EDIT
    BNE     RESTORE_IRQ_AND_EXIT


; ==============================================================================
; PATCH_COMPARE
; ==============================================================================
; LOCATION: 0xCA8C
;
; DESCRIPTION:
; This subroutine handles the patch edit/compare functionality.
; If the patch in the working buffer has currently been edited, this function
; will recall the original patch from the compare buffer. If there is currently
; an edited patch in the compare buffer, it will be recalled to the edit buffer.
; If the patch has not been modified, nothing  will happen.
;
; ==============================================================================

PATCH_COMPARE:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG

; If the patch has not been modified, exit.
    BEQ     RESTORE_IRQ_AND_EXIT
    CMPA    #EDITED_PATCH_IN_WORKING
    BNE     .COPY_PATCH_FROM_COMPARE

; The following subroutine copies the edit buffer to the compare
; buffer, and then reloads the current patch from its original source.

.COPY_PATCH_TO_COMPARE:
    JSR     PATCH_COPY_TO_COMPARE
    LDAA    #EDITED_PATCH_IN_COMPARE
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    LDAA    M_PATCH_CURRENT_NUMBER
    TST     M_PATCH_CURRENT_CRT_OR_INT
    BEQ     .PATCH_IN_INT_MEMORY

; If the patch is loaded from the CRT, check the port input to determine
; if the cartridge is present. If not, print an error message.

.PATCH_IN_CRT_MEMORY:
    LDAB    P_CRT_PEDALS_LCD
    ANDB    #CRT_FLAG_INSERTED
    BNE     .PRINT_NOT_READY_MSG
    JSR     PATCH_LOAD_FROM_CRT
    BRA     .END_PATCH_COMPARE

.PRINT_NOT_READY_MSG:
    LDX     #aNotReadyInsert
    JSR     LCD_WRITE_LINE_1_THEN_PRINT
    BRA     RESTORE_IRQ_STATUS_FROM_STACK

.PATCH_IN_INT_MEMORY:
    JSR     PATCH_LOAD_FROM_INT

.END_PATCH_COMPARE:
    JSR     PATCH_LOAD_DATA


RESTORE_IRQ_AND_EXIT:
    LDAA    #UI_MODE_EDIT
    STAA    M_MEM_SELECT_UI_MODE
    JSR     UI_PRINT_MAIN
    JSR     LED_PRINT_PATCH_NUMBER


RESTORE_IRQ_STATUS_FROM_STACK:
    PULA
    STAA    <TIMER_CTRL_STATUS
    PULA
    STAA    <IO_PORT_2_DATA
    RTS


.COPY_PATCH_FROM_COMPARE:
    JSR     PATCH_COPY_FROM_COMPARE
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    BRA     .END_PATCH_COMPARE


; ==============================================================================
; MEMORY_SELECT_INT
; ==============================================================================
; LOCATION: 0xCADB
;
; DESCRIPTION:
; Selects the synthesiser's internal memory as the current source for loading
; patches in 'Play Mode'.
; This function sets the 'UI Mode' flag accordingly.
;
; ==============================================================================

MEMORY_SELECT_INT:
    CLR     M_INPUT_MODE
    CLR     M_MEM_SELECT_UI_MODE


.CLR_PATCH_NAME_EDIT_FLAG:
    CLR     M_PATCH_NAME_EDIT_ACTIVE

MENU_PRINT_UI_LED:
    JSR     UI_PRINT_MAIN
    JMP     LED_PRINT_PATCH_NUMBER


; ==============================================================================
; MEMORY_SELECT_CRT
; ==============================================================================
; LOCATION: 0xCAEA
;
; DESCRIPTION:
; Selects the synthesiser's cartridge memory as the current source for loading
; patches in 'Play Mode'.
; This function sets the 'UI Mode' flag accordingly.
; If the cartridge is not inserted, an error message is printed.
;
; ==============================================================================

MEMORY_SELECT_CRT:
    LDAA    P_CRT_PEDALS_LCD
    ANDA    #CRT_FLAG_INSERTED
    BEQ     .CRT_IS_INSERTED

CRT_SET_PRINT_NOT_INSERTED:
    CLR     M_MEM_SELECT_UI_MODE

CRT_PRINT_NOT_INSERTED:
    LDX     #aNotReadyInsert
    JMP     LCD_WRITE_LINE_1_THEN_PRINT

.CRT_IS_INSERTED:
    CLR     M_INPUT_MODE
    LDAA    #UI_MODE_CRT_INSERTED
    STAA    M_MEM_SELECT_UI_MODE
    BRA     .CLR_PATCH_NAME_EDIT_FLAG


; ==============================================================================
; BTN_FN_PARAM
; ==============================================================================
; LOCATION: 0xCB04
;
; DESCRIPTION:
; This subroutine is a button handler for the front-panel buttons being pressed
; while the synth is in 'Function Mode'.
; This subroutine loads the last pressed button index into the register
; associated with the current 'Function Mode Parameter'. This will become the
; parameter currently modified by user input.
;
;
; ==============================================================================

BTN_FN_PARAM:
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_FN_PARAM_CURRENT
    BRA     INPUT_RESET_TO_FN_MODE


; ==============================================================================
; BTN_FUNC
; ==============================================================================
; LOCATION: 0xCB0C
;
; DESCRIPTION:
; Button press handler for the 'Function' button.
; The 'Func' button active flag is set here, and the synth's input function
; is set to 'Function Mode'.
;
; ==============================================================================

BTN_FUNC:
    LDAA    #2
    STAA    <M_BTN_FUNC_STATE
    CLR     M_TEST_MODE_BUTTON_CHECK


INPUT_RESET_TO_FN_MODE:
    LDAA    #INPUT_MODE_FN
    STAA    M_INPUT_MODE
    LDAA    #UI_MODE_FUNCTION
    STAA    M_MEM_SELECT_UI_MODE
    CLR     M_CRT_SAVE_LOAD_FLAGS
    BRA     MENU_PRINT_UI_LED


; ==============================================================================
; BTN_EDIT_PARAM
; ==============================================================================
; LOCATION: 0xCB22
;
; DESCRIPTION:
; This subroutine is a button handler for the front-panel buttons being
; pressed while the synth is in 'Edit Mode'.
; This subroutine loads the last pressed button index into the register
; associated with the current 'Edit Mode Parameter'. This will become the
; parameter currently modified by user input.
;
;
; ==============================================================================

BTN_EDIT_PARAM:
    LDAA    #UI_MODE_EDIT
    STAA    M_MEM_SELECT_UI_MODE
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_EDIT_PARAM_CURRENT

BTN_PRINT_UI_AND_EXIT:
    BRA     MENU_PRINT_UI_LED


; ==============================================================================
; BTN_EDIT_COPY_OP
; ==============================================================================
; LOCATION: 0xCB2F
;
; DESCRIPTION:
; This subroutine handles one of the front-panel buttons corresponding to
; copying an operator (1-6) being pressed.
;
; ==============================================================================

BTN_EDIT_COPY_OP:
    TST     M_PATCH_READ_OR_WRITE
    BEQ     MENU_PRINT_UI_LED

; Set the flag indicating the patch currently in the synth's 'Edit Buffer'
; has been modified.
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    JSR     LED_PRINT_PATCH_NUMBER
    JMP     PATCH_COPY_OPERATOR


; ==============================================================================
; BTN_EDIT_VOICE_NAME
; ==============================================================================
; LOCATION: 0xCB3F
;
; DESCRIPTION:
; This subroutine handles the 'Edit Voice Name' button (32) being pressed while
; the synth is in 'Edit Mode'. It sets the flag indicating that the synth is
; in 'Voice Edit Mode'. This affects how user input is captured.
;
; ==============================================================================

BTN_EDIT_VOICE_NAME:
    LDAA    #UI_MODE_EDIT_PATCH_NAME
    STAA    M_MEM_SELECT_UI_MODE

; Set the flag indicating that patch name editing is active.
    STAA    M_PATCH_NAME_EDIT_ACTIVE
    BRA     BTN_PRINT_UI_AND_EXIT


; ==============================================================================
; BTN_CRT_LOAD_SAVE
; ==============================================================================
; LOCATION: 0xCB49
;
; DESCRIPTION:
; Button handler for buttons 15/16.
;
; ==============================================================================

BTN_CRT_LOAD_SAVE:
    LDAA    M_LAST_PRESSED_BTN
    CLRB

; The following lines 'shift' the LSB from A into the MSB from B. This is used
; to indicate whether the intended function was to 'Save' (Button 15),
; or 'Load' (Button 16).
    LSRD
    STAB    <M_CRT_SAVE_LOAD_FLAGS
    LDAA    #UI_MODE_CRT_LOAD_SAVE
    STAA    M_MEM_SELECT_UI_MODE
    BRA     BTN_PRINT_UI_AND_EXIT


; ==============================================================================
; BTN_EDIT_KEY_TRANSPOSE
; ==============================================================================
; LOCATION: 0xCB57
;
; DESCRIPTION:
; This subroutine is a button handler for the front-panel button (31)
; corresponding to editing the current patch's 'Key Transpose' value being
; pressed while the synth is in 'Edit Mode'.
; This sets the associated flag, which will capture the next key press.
;
; ==============================================================================

BTN_EDIT_KEY_TRANSPOSE:
    LDAA    #1
    STAA    <M_EDIT_KEY_TRANSPOSE_ACTIVE
    JMP     BTN_EDIT_PARAM


; ==============================================================================
; BTN_HANDLR_STORE
; ==============================================================================
; LOCATION: 0xCB5E
;
; DESCRIPTION:
; Handles the 'store' front-panel button being pressed.
;
; ==============================================================================

BTN_STORE:
    LDAA    #$FF
    STAA    <M_PATCH_READ_OR_WRITE

; Check which button mode we're in.
; If we're in 'Play' mode, then this button handler will initiate storing the
; working patch. If we're in any other mode, it will initiate operator EG copy.
    TST     M_INPUT_MODE
    BEQ     .BTN_MODE_0

; Check if we're currently in 'compare' mode.
; If there's an edited patch in the compare buffer, exit.

.BTN_STORE_IS_IN_COMPARE_MODE?:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_COMPARE
    BNE     .PRINT_EG_COPY
    RTS

.PRINT_EG_COPY:
    JSR     LCD_CLEAR_STR_BUFFER
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR
    LDX     #aEgCopyFromOp
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDAA    #5
    SUBA    M_SELECTED_OPERATOR
    ADDA    #'1'
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     #aToOp_0
    JMP     LCD_WRITE_BFR_AND_PRINT
aToOp_0:             FCC " to OP?", 0


; ==============================================================================
; BTN_HNDLR_42
; ==============================================================================
; LOCATION: 0xCB99
;
; DESCRIPTION:
; I currently don't know what input triggers this handler. It's triggered from
; 'button input 42'.
;
; ==============================================================================

BTN_HNDLR_42:
    LDAA    M_INPUT_MODE
    CMPA    #INPUT_MODE_FN
    BEQ     BTN_CLEAR_RW_FLAG_AND_EXIT

.IS_INPUT_MODE_EDIT?:
    CMPA    #INPUT_MODE_EDIT
    BNE     .BTN_HANDLER_42_INPUT_MODE_PLAY
    LDAA    M_EDIT_PARAM_CURRENT

.END_BTN_HANDLER_42:
    STAA    M_LAST_PRESSED_BTN
    JSR     UI_PRINT_MAIN
    RTS

.BTN_HANDLER_42_INPUT_MODE_PLAY:
    LDAA    M_PATCH_CURRENT_NUMBER
    BRA     .END_BTN_HANDLER_42

BTN_CLEAR_RW_FLAG_AND_EXIT:
    CLR     M_PATCH_READ_OR_WRITE
    RTS


.BTN_MODE_0:
    TST     M_MEM_SELECT_UI_MODE
    BEQ     .CHECK_INT_MEM_PROTECT_STATE
    JSR     CRT_CHECK_PROTECTION
    JSR     MEMORY_CHECK_CRT_PROTECT
    BRA     .PRINT_STORE_MSG

.CHECK_INT_MEM_PROTECT_STATE:
    JSR     MEMORY_CHECK_INT_PROTECT

.PRINT_STORE_MSG:
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    LDX     #aMemoryStore
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT
aMemoryStore:        FCC " MEMORY STORE", 0


; ==============================================================================
; BTN_FN_MIDI
; ==============================================================================
; LOCATION: 0xCBDE
;
; DESCRIPTION:
; Handles button 8 being pressed while the synth is in 'Function Mode'.
; There are multiple 'sub-functions' that are cycled through by pressing this
; button.
; These modes are listed below:
; *0 = Edit MIDI RX ch.
; *1 = SYS INFO AVAIL?
; *2 = Transmit MIDI.
;
; ==============================================================================

BTN_FN_MIDI:
    LDAA    M_LAST_PRESSED_BTN

; If the last-pressed button is already the same as the currently selected
; 'Edit Parameter' it means that this button has been pressed multiple
; sequential times. In this case, increment the sub-function mode.
    CMPA    M_FN_PARAM_CURRENT
    BNE     .RESET_SUB_FN

.INCREMENT_SUB_FN:
    INC     M_EDIT_BTN_8_SUB_FN
    LDAA    M_EDIT_BTN_8_SUB_FN
    TST     M_MIDI_SYS_INFO_AVAIL
    BEQ     .IS_SUB_FN_2?

.IS_SUB_FN_AT_MAX?:
    CMPA    #3
    BNE     SET_UI_TO_FN_MODE

.RESET_SUB_FN:
    CLR     M_EDIT_BTN_8_SUB_FN
    BRA     SET_UI_TO_FN_MODE

; Advancing to the third 'function' is not available if 'SYS INFO AVAIL'
; is not enabled.

.IS_SUB_FN_2?:
    CMPA    #2
    BNE     SET_UI_TO_FN_MODE
    BRA     .RESET_SUB_FN

SET_UI_TO_FN_MODE:
    LDAA    #UI_MODE_FUNCTION
    STAA    M_MEM_SELECT_UI_MODE
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_FN_PARAM_CURRENT
    JSR     UI_PRINT_MAIN
    RTS


; ==============================================================================
; BTN_EDIT_OSC_MODE_SYNC
; ==============================================================================
; DESCRIPTION:
; Subroutine for handling the button for 'Oscillator Mode/Sync' being pressed.
; As this button has multiple functions, this subroutine handles cycling
; through these with sequential presses.
;
; ==============================================================================

BTN_EDIT_OSC_MODE_SYNC:
    LDAA    M_LAST_PRESSED_BTN
    CMPA    M_EDIT_PARAM_CURRENT

; If the last-pressed button is already the same as the currently selected
; 'Edit Parameter' it means that this button has been pressed multiple
; sequential times. In this case, increment the flag.
    BNE     .CLEAR_OSC_MODE_SYNC_FLAG
    INC     M_EDIT_OSC_MODE_SYNC_FLAG
    LDAA    <M_EDIT_OSC_MODE_SYNC_FLAG
    CMPA    #2
    BNE     BTN_SET_INPUT_MODE_EDIT

.CLEAR_OSC_MODE_SYNC_FLAG:
    CLR     M_EDIT_OSC_MODE_SYNC_FLAG

BTN_SET_INPUT_MODE_EDIT:
    LDAA    #UI_MODE_EDIT
    STAA    M_MEM_SELECT_UI_MODE
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_EDIT_PARAM_CURRENT

PRINT_UI_AND_RETURN:
    JSR     UI_PRINT_MAIN
    RTS


; ==============================================================================
; BTN_MEMORY_PROTECT
; ==============================================================================
; DESCRIPTION:
; Handles the Internal/Cartridge memory protect front-panel buttons
; being pressed.
;
; ==============================================================================

BTN_MEMORY_PROTECT:
    LDAA    M_LAST_PRESSED_BTN
    STAA    <M_MEM_PROTECT_MODE
    LDAA    #LCD_INSTR_SET_BLINK_OFF
    JSR     LCD_WRITE_INSTRUCTION
    LDAA    #UI_MODE_SET_MEM_PROTECT
    BRA     BTN_SAVE_UI_MODE_AND_RETURN


; ==============================================================================
; BTN_EDIT_OP_SELECT
; ==============================================================================
; DESCRIPTION:
; Button handler for the 'Operator Select' front-panel button being pressed
; while the synth is in 'Edit Mode'.
;
; ==============================================================================

BTN_EDIT_OP_SELECT:
    DEC     M_SELECTED_OPERATOR

; Decrement the currently selected operator.
; If the resulting value would be negative, rotate back to operator 6.
    BPL     .END_BTN_EDIT_OP_SELECT
    LDAA    #5
    STAA    M_SELECTED_OPERATOR

.END_BTN_EDIT_OP_SELECT:
    LDAA    #UI_MODE_EDIT

BTN_SAVE_UI_MODE_AND_RETURN:
    STAA    M_MEM_SELECT_UI_MODE
    BRA     PRINT_UI_AND_RETURN


; ==============================================================================
; BTN_EDIT_KBD_SCALING
; ==============================================================================
; LOCATION: 0xCC51
;
; DESCRIPTION:
; Button handler for the buttons related to keyboard scaling being pressed
; (24, or 25). Successive presses set a 'toggle' variable, which is used
; elsewhere in the UI functions to determine which parameter is being edited.
;
; ==============================================================================

BTN_EDIT_KBD_SCALING:
    LDAA    M_LAST_PRESSED_BTN
    CMPA    M_EDIT_PARAM_CURRENT
    BNE     BTN_SET_INPUT_MODE_EDIT
    COM     M_EDIT_KBD_SCALE_TOGGLE
    BRA     BTN_SET_INPUT_MODE_EDIT


; ==============================================================================
; BTN_EDIT_EG_RATE_LVL
; ==============================================================================
; LOCATION: 0xCC5E
;
; DESCRIPTION:
; Button handler for buttons 21, 22, 29, and 30 being pressed. Successive
; presses to this button increment a variable used to 'cycle' through the
; different modes.
;
; ==============================================================================

BTN_EDIT_EG_RATE_LVL:
    LDAA    M_LAST_PRESSED_BTN
    CMPA    M_EDIT_PARAM_CURRENT

; If the last-pressed button is already the same as the currently selected
; 'Edit Parameter' it means that this button has been pressed multiple
; sequential times. In this case, increment the 'sub-function' flag.
    BNE     .RESET_SUB_FN_FLAG
    INC     M_EDIT_EG_RATE_LVL_SUB_FN
    LDAA    <M_EDIT_EG_RATE_LVL_SUB_FN

; If the incremented value is now equal to '4', fall-through to clear
; the value, set the synth's 'Input Mode', and return.
    CMPA    #4
    BNE     BTN_SET_INPUT_MODE_EDIT

.RESET_SUB_FN_FLAG:
    CLR     M_EDIT_EG_RATE_LVL_SUB_FN
    BRA     BTN_SET_INPUT_MODE_EDIT


; ==============================================================================
; PATCH_PROGRAM_CHANGE
; ==============================================================================
; DESCRIPTION:
; Creates a 'Program Change' event from the last button pushed, while the
; synth is in 'Play Mode, and then falls-through to load the associated patch.
; This is the main entry point for loading a patch.
;
; ==============================================================================

PATCH_PROGRAM_CHANGE:
    JSR     MIDI_SEND_PROG_CHG                  ; Falls-through to patch r/w.


; ==============================================================================
; PATCH_READ_WRITE
; ==============================================================================
; DESCRIPTION:
; This subroutine either reads, or writes a patch from RAM into the current
; 'edit' patch buffer, or vice-versa.
;
; ==============================================================================

PATCH_READ_WRITE:
    JSR     LCD_SET_CURSOR_BLINK_OFF
    LDAB    <IO_PORT_2_DATA
    PSHB
    LDAB    <TIMER_CTRL_STATUS
    PSHB

; Save the state of the timer control register on the stack.
; Disable all timer interrupts prior to entering the function.
    CLR     IO_PORT_2_DATA
    CLR     TIMER_CTRL_STATUS
    LDAA    M_MEM_SELECT_UI_MODE
    BNE     .PATCH_RW_IS_CRT_INSERTED?

.READ_OR_WRITE_INT?:
    LDAA    <M_PATCH_READ_OR_WRITE
    BNE     .WRITE_SELECTED_INT

; Check if the patch in the working buffer has been modified.
; If so, copy it into the compare buffer before loading the new patch.

.IS_PATCH_MODIFIED_INT?:
    TST     M_PATCH_CURRENT_MODIFIED_FLAG
    BEQ     .LOAD_PATCH_INT
    LDAA    M_PATCH_CURRENT_NUMBER
    STAA    M_PATCH_COMPARE_NUMBER
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    STAA    M_PATCH_COMPARE_MODIFIED_FLAG
    LDAA    M_PATCH_CURRENT_OPS_ON_OFF
    STAA    M_PATCH_COMPARE_OPS_ON_OFF
    JSR     PATCH_COPY_TO_COMPARE

.LOAD_PATCH_INT:
    CLR     M_PATCH_CURRENT_CRT_OR_INT
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_PATCH_CURRENT_NUMBER
    JSR     PATCH_LOAD_FROM_INT

.PATCH_LOAD_SUCCESS:
    TST     M_MIDI_SYS_INFO_AVAIL
    BEQ     .PATCH_LOAD_TO_EGS
    JSR     MIDI_SYSEX_DUMP_CURRENT_VOICE

.PATCH_LOAD_TO_EGS:
    JSR     PATCH_LOAD_DATA

.PATCH_READ_WRITE_SUCCESS:
    JSR     UI_PRINT_MAIN
    CLR     M_PATCH_CURRENT_MODIFIED_FLAG
    CLR     M_PATCH_READ_OR_WRITE
    JSR     LED_PRINT_PATCH_NUMBER
    LDAA    #%111111
    STAA    M_PATCH_CURRENT_OPS_ON_OFF

; Restore the saved timer control register values.
; Re-enable interrupts.

.END_PATCH_READ_WRITE:
    PULB
    STAB    <TIMER_CTRL_STATUS
    PULB
    STAB    <IO_PORT_2_DATA
    RTS

.WRITE_SELECTED_INT:
    BRA     .PATCH_WRITE_TO_INT

.PATCH_RW_IS_CRT_INSERTED?:
    LDAA    P_CRT_PEDALS_LCD
    ANDA    #CRT_FLAG_INSERTED
    BEQ     .READ_OR_WRITE_CRT?

; Restore the saved timer control register values.
; Re-enable interrupts.
    PULB
    STAB    <TIMER_CTRL_STATUS
    PULB
    STAB    <IO_PORT_2_DATA
    JMP     CRT_SET_PRINT_NOT_INSERTED

.READ_OR_WRITE_CRT?:
    LDAA    <M_PATCH_READ_OR_WRITE
    BNE     .WRITE_SELECTED_CRT
    JSR     CRT_CHECK_FORMAT
    BEQ     .IS_PATCH_MODIFIED_CRT?
    PULB
    STAB    <TIMER_CTRL_STATUS
    PULB
    STAB    <IO_PORT_2_DATA
    JMP     CRT_FORMAT_CONFLICT

; Check if the patch in the working buffer has been modified.
; If so, copy it into the compare buffer before loading the new patch.

.IS_PATCH_MODIFIED_CRT?:
    TST     M_PATCH_CURRENT_MODIFIED_FLAG
    BEQ     .LOAD_PATCH_CRT
    LDAA    M_PATCH_CURRENT_NUMBER
    STAA    M_PATCH_COMPARE_NUMBER
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    STAA    M_PATCH_COMPARE_MODIFIED_FLAG
    LDAA    M_PATCH_CURRENT_OPS_ON_OFF
    STAA    M_PATCH_COMPARE_OPS_ON_OFF
    JSR     PATCH_COPY_TO_COMPARE

.LOAD_PATCH_CRT:
    LDAA    #1
    STAA    M_PATCH_CURRENT_CRT_OR_INT
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_PATCH_CURRENT_NUMBER
    JSR     PATCH_LOAD_FROM_CRT
    BRA     .PATCH_LOAD_SUCCESS

.PATCH_WRITE_TO_INT:
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_PATCH_CURRENT_NUMBER
    JSR     PATCH_WRITE_TO_INT
    BRA     .PATCH_READ_WRITE_SUCCESS

.WRITE_SELECTED_CRT:
    JSR     CRT_CHECK_FORMAT
    BEQ     .PATCH_WRITE_TO_CRT
    PULB
    STAB    <TIMER_CTRL_STATUS
    PULB
    STAB    <IO_PORT_2_DATA
    JMP     CRT_FORMAT_CONFLICT

.PATCH_WRITE_TO_CRT:
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR
    LDX     #aCartridgeVoice
    JSR     LCD_WRITE_STR_TO_BUFFER
    JSR     PRINT_MSG_UNDER_WRITING

.SERIALISE_PATCH_DATA:
    LDD     #M_PATCH_SERIALISED_TEMP
    JSR     PATCH_SERIALISE

; Multiply the patch number by 128 to get the byte offset. Add this offset
; to 0x4000 to get the memory address in the cartridge to store the data at.
; Then write from the temp serialised patch address.
    LDAA    M_LAST_PRESSED_BTN
    STAA    M_PATCH_CURRENT_NUMBER
    LDAB    #128
    MUL
    ADDD    #P_CRT_START
    STD     <M_COPY_DEST_PTR
    LDX     #M_PATCH_SERIALISED_TEMP
    STX     <M_COPY_SRC_PTR
    JSR     PATCH_WRITE_TO_CRT

; If the carry flag is set, an error condition has occurred.
    BCS     .CRT_WRITE_ERR
    JMP     .PATCH_READ_WRITE_SUCCESS

.CRT_WRITE_ERR:
    LDX     #aWriteError
    JSR     LCD_CLR_WRITE_LINE_2_THEN_PRINT
    JMP     .END_PATCH_READ_WRITE


; ==============================================================================
; PRING_MSG_MEM_PROTECTED
; ==============================================================================
; DESCRIPTION:
; Prints a message to the 2nd line of the synth's LCD screen indicating that
; the currently selected memory is protected.
; This is called by various functions related to memory.
;
; ==============================================================================

PRINT_MSG_MEMORY_PROTECTED:
    CLR     M_PATCH_READ_OR_WRITE
    LDX     #aMemoryProtecte
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; PATCH_LOAD_FROM_CRT
; ==============================================================================
; DESCRIPTION:
; Loads a patch from cartridge memory into the synth's 'Edit Buffer'.
; Loads the patch number in ACCA.
;
; ARGUMENTS:
; Registers:
; * ACCA: The patch number to load.
;
; ==============================================================================

PATCH_LOAD_FROM_CRT:
    LDAB    #128
    MUL

; Calculate the offset from the start of patch memory.
    ADDD    #P_CRT_START
    STD     <M_COPY_DEST_PTR
    LDX     #M_PATCH_SERIALISED_TEMP
    STX     <M_COPY_SRC_PTR
    JSR     CRT_READ_PATCH
    LDD     #M_PATCH_SERIALISED_TEMP
    JSR     PATCH_DESERIALISE
    RTS


; ==============================================================================
; CRT_CHECK_FORMAT
; ==============================================================================
; LOCATION: 0xCD97
;
; DESCRIPTION:
; Checks the format of cartridge.
; It functions by checking the last 32 bytes (0x4FE0 - 0x4FFF) of cartridge
; memory, checking whether the MSB is set for any byte. This indicates that
; the cartridge format does not match that of the DX7, since the MSB is never
; used in DX7 patch data.
;
; The result is set in CCR, with a non-zero result indicating a bad format.
;
; RETURNS:
; * CCR[Z]: Whether badly formatted bytes were found on the cartridge.
;
; ==============================================================================

CRT_CHECK_FORMAT:
    LDX     #$4FE0                              ; Start address.
    CLRA

.CRT_FORMAT_CHECK_LOOP:
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x

; Load the current byte from the cartridge into ACCB, and mask the
; most-significant bit.
    LDAB    0,x
    ANDB    #%10000000

; Clear the carry bit.
; Rotate the read value to the left twice to move the MSB into the LSB.
; This value is then added to the accumulated number of badly formatted
; bytes stored in ACCA.
    CLC                                         ; Clear carry bit.
    ROLB
    ROLB
    ABA
    INX
    CPX     #$5000
    BNE     .CRT_FORMAT_CHECK_LOOP              ; If IX < 0x5000, loop.
    TSTA
    RTS


CRT_FORMAT_CONFLICT:
    LDX     #aFormatConflict
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT
aFormatConflict:     FCC "FORMAT CONFLICT!", 0


; ==============================================================================
; LED_PRINT_PATCH_NUMBER
; ==============================================================================
; LOCATION: 0xCDCA
;
; DESCRIPTION:
; Prints the numeric contents of the current patch number register to the two
; digit LED. It first splits this value into its individual digits, converts
; these to their LED encoding, and sends this data to the appropriate
; LED panel.
;
; ARGUMENTS:
; Memory:
; * 0x209D: The current patch number to print to the LED.
;
; ==============================================================================

LED_PRINT_PATCH_NUMBER:
    LDAB    M_PATCH_CURRENT_NUMBER

; Increment to index from 1-32.
    INCB
    CLRA
    JSR     CONVERT_INT_TO_STR

; If the 'tens' slot is empty, don't display a number on LED2.
    LDAB    M_PARSED_INT_TENS
    BEQ     .CLEAR_LED2
    LDX     #TABLE_LED_SEGMENT_MAPPING
    ABX
    LDAA    0,x

.PRINT_DIGITS:
    STAA    P_LED2
    LDAB    M_PARSED_INT_DIGITS
    LDX     #TABLE_LED_SEGMENT_MAPPING
    ABX
    LDAA    0,x

; If the patch in the working buffer has been edited, then print the
; trailing '.' char on the LED.
    LDAB    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPB    #EDITED_PATCH_IN_WORKING
    BNE     .ENABLE_LED1_DOT
    ANDA    #%1111111

.STORE_LED1_DATA:
    STAA    P_LED1
    RTS

.ENABLE_LED1_DOT:
    ORAA    #%10000000
    BRA     .STORE_LED1_DATA

.CLEAR_LED2:
    LDAA    #%11111111
    BRA     .PRINT_DIGITS


; ==============================================================================
; LED Segment Codes.
; The following values represent the values to be sent to the LED
; controller to render the numbers 0-9.
; ==============================================================================
TABLE_LED_SEGMENT_MAPPING:
    FCB $C0
    FCB $F9
    FCB $A4
    FCB $B0
    FCB $99
    FCB $92
    FCB $82
    FCB $F8
    FCB $80
    FCB $98


; ==============================================================================
; BTN_YES_NO_SEND_MIDI
; ==============================================================================
; LOCATION: 0xCE08
;
; DESCRIPTION:
; Button handler for 'Yes/No/Up/Down' buttons being pressed from the front
; panel. This button handler will send the corresponding MIDI event, and
; then fall through to the main button handler.
;
; ==============================================================================

BTN_YES_NO_SEND_MIDI:
    JSR     MIDI_SEND_YES_NO


; ==============================================================================
; BTN_YES_NO
; ==============================================================================
; DESCRIPTION:
; Button handler for 'Yes/No/Up/Down' buttons.
; This subroutine is reached from the main 'Yes/No' button handler, as well as
; the MIDI CC functions corresponding to 'Yes/No'. This subroutine clears the
; flag indicating whether the 'Up/Down' event came from the slider.
;
; ==============================================================================

BTN_YES_NO:
    CLR     M_SLIDER_INPUT_EVENT

; If the pressed button was 'NO', then 0xFF is stored in the increment
; variable. Otherwise the value for 'YES' is 0x1. These values are used in
; various places for arithmetic purposes.
    LDAA    M_LAST_PRESSED_BTN
    SUBA    #BUTTON_NO_DOWN
    BNE     .STORE_INCREMENT
    LDAA    #$FF

.STORE_INCREMENT:
    STAA    <M_UP_DOWN_INCREMENT

; This label is referenced by the main slider input handler.
; In this case the 'Up/Down' increment will have already been set by the
; analog event handler.

BTN_SLIDER:
    LDAA    M_MEM_SELECT_UI_MODE
    CMPA    #UI_MODE_CRT_LOAD_SAVE
    BNE     .IS_MODE_MEM_PROTECT?
    JMP     BTN_YES_NO_CRT_READ_WRITE

.IS_MODE_MEM_PROTECT?:
    CMPA    #UI_MODE_SET_MEM_PROTECT
    BNE     .IS_SYNTH_IN_PLAY_MODE?
    JMP     BTN_YES_NO_SET_MEM_PROTECT_STATUS

.IS_SYNTH_IN_PLAY_MODE?:
    LDAA    M_INPUT_MODE
    BNE     .IS_SYNTH_IN_EDIT_MODE?

; If the synth is in 'Play Mode', treat the Up/Down press as though it is
; in 'Function Mode'.
    BRA     .FUNCTION_MODE

.IS_SYNTH_IN_EDIT_MODE?:
    CMPA    #INPUT_MODE_EDIT
    BEQ     .IS_NAME_EDIT_MODE?

.IS_SYNTH_IN_FN_MODE?:
    CMPA    #INPUT_MODE_FN
    BEQ     .FUNCTION_MODE
    RTS

.FUNCTION_MODE:
    JMP     .FUNC_MODE_IS_BUTTON_ABOVE_16

; If the synth is in 'Name Edit' mode, Up/Down button input will be
; captured, and handled by the name editing handler function, and not
; processed further here.

.IS_NAME_EDIT_MODE?:
    TST     M_PATCH_NAME_EDIT_ACTIVE
    BNE     .END_BTN_YES_NO

.IS_EDITED_PATCH_IN_COMPARE?:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_COMPARE
    BNE     .EDIT_MODE

.END_BTN_YES_NO:
    RTS

.EDIT_MODE:
    LDAB    M_EDIT_PARAM_CURRENT
    CMPB    #27
    BHI     .IS_PARAM_20?                       ; Branch if B > 27.

; The following section deals with incrementing/decrementing the actual
; data values in patch memory. This is facilitated by loading either the
; offset of the parameter relative to patch memory (0..155), or the offset
; relative to a single operator in patch memory (0..20), depending on what
; kind of parameter this is.

.LOAD_EDIT_PARAM_TABLE:
    SUBB    #6
    ASLB
    LDX     #TABLE_EDIT_PARAM_VALUES
    ABX
    LDD     0,x
    LDX     #M_PATCH_CURRENT_BUFFER

; If the location of this parameter in memory is above 133 it's a
; patch-wide parameter, and not an operator parameter.

.BTN_YES_NO_IS_OPERATOR_PARAM?:
    CMPB    #133
    BHI     .EDIT_VALUE                         ; If B > 133, branch.

.IS_PARAM_8?:
    CMPB    #8
    BEQ     .SAVE_B_GET_OP_INDEX
    CMPB    #12
    BLS     .IS_PARAM_20?

.SAVE_B_GET_OP_INDEX:
    PSHB

.LOAD_OFFSET_OPERATOR_PTR:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    PULB

.EDIT_VALUE:
    ABX
    JSR     BTN_INC_DEC_PARAM_VALUES
    LDAA    M_EDIT_PARAM_CURRENT
    STAA    M_LAST_PRESSED_BTN
    LDAA    <IO_PORT_2_DATA
    PSHA
    LDAA    <TIMER_CTRL_STATUS
    PSHA

.BTN_YES_NO_DISABLE_INTERRUPTS:
    CLR     TIMER_CTRL_STATUS
    CLR     IO_PORT_2_DATA

.RELOAD_EDIT_PARAM:
    JSR     PATCH_LOAD_EDIT_PARAM
    JSR     UI_PRINT_MAIN

.SET_PATCH_AS_EDITED:
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    JSR     LED_PRINT_PATCH_NUMBER

.RE_ENABLE_INTERRUPTS:
    PULA
    STAA    <TIMER_CTRL_STATUS
    PULA
    STAA    <IO_PORT_2_DATA
    RTS

.IS_PARAM_20?:
    LDAB    <M_EDIT_EG_RATE_LVL_SUB_FN
    LDAA    M_EDIT_PARAM_CURRENT
    CMPA    #20
    BNE     .IS_PARAM_21?
    PSHB
    BRA     .LOAD_OFFSET_OPERATOR_PTR

.IS_PARAM_21?:
    CMPA    #21
    BNE     .IS_PARAM_28?
    ADDB    #4
    PSHB
    BRA     .LOAD_OFFSET_OPERATOR_PTR

.IS_PARAM_28?:
    CMPA    #28
    BNE     .IS_PARAM_29?

.EDIT_PARAM_PITCH_EG_RATE:
    ADDB    #126
    BRA     .LOAD_OFFSET_PATCH_PTR

.IS_PARAM_29?:
    CMPA    #29
    BNE     .IS_PARAM_23?

.EDIT_PARAM_PITCH_EG_LVL:
    ADDB    #130

.LOAD_OFFSET_PATCH_PTR:
    LDX     #M_PATCH_CURRENT_BUFFER
    BRA     .EDIT_VALUE

; The keyboard scaling 'toggle' variable is either 0x0, or 0xFF.
; This value will be incremented to then test against zero, to determine
; which parameter is being edited.

.IS_PARAM_23?:
    LDAB    <M_EDIT_KBD_SCALE_TOGGLE
    CMPA    #23
    BNE     .IS_PARAM_24?
    INCB
    BEQ     .EDIT_PARAM_KBD_SCALE_RHT_CURVE

.EDIT_PARAM_KBD_SCALE_LFT_CURVE:
    LDAB    #11
    PSHB
    JMP     .LOAD_OFFSET_OPERATOR_PTR

.EDIT_PARAM_KBD_SCALE_RHT_CURVE:
    LDAB    #12
    PSHB
    JMP     .LOAD_OFFSET_OPERATOR_PTR

.IS_PARAM_24?:
    CMPA    #24
    BNE     .IS_PARAM_OSC_MODE_SYNC?
    INCB
    BEQ     .EDIT_PARAM_KBD_SCALE_RHT_DEPTH

.EDIT_PARAM_KBD_SCALE_LFT_DEPTH:
    LDAB    #9
    PSHB
    JMP     .LOAD_OFFSET_OPERATOR_PTR

.EDIT_PARAM_KBD_SCALE_RHT_DEPTH:
    LDAB    #10
    PSHB
    JMP     .LOAD_OFFSET_OPERATOR_PTR

.IS_PARAM_OSC_MODE_SYNC?:
    CMPA    #16
    BEQ     .EDIT_PARAM_OSC_MODE_SYNC
    RTS

.EDIT_PARAM_OSC_MODE_SYNC:
    LDAB    <M_EDIT_OSC_MODE_SYNC_FLAG
    BNE     .LOAD_OSC_SYNC_OFFSET

.LOAD_OSC_MODE_OFFSET:
    LDAB    #17
    PSHB
    JMP     .LOAD_OFFSET_OPERATOR_PTR

.LOAD_OSC_SYNC_OFFSET:
    LDAB    #136
    JMP     .EDIT_VALUE


; ==============================================================================
; BTN_INC_DEC_PARAM_VALUES
; ==============================================================================
; LOCATION: 0xCEFD
;
; DESCRIPTION:
; This subroutine handles the incrementing/decrementing of a specific edit, or
; function parameter value.
; This subroutine determines the value being altered based upon the current
; 'Input Mode' that the synthesiser is in. If the synthesiser is in
; 'Edit Mode', then the current edit mode parameter set in the main loop
; input handler.
;
; ==============================================================================

BTN_INC_DEC_PARAM_VALUES:
    LDAA    <M_UP_DOWN_INCREMENT
    LDAB    <M_SLIDER_INPUT_EVENT
    BNE     .END_BTN_INC_DEC_PARAM_VALUES
    PSHX

.IS_UP_OR_DOWN?:
    LDAA    <M_UP_DOWN_INCREMENT
    BMI     .BTN_NO

.BTN_YES:
    LDAA    0,x

; If the synth is in 'Play Mode', switch to 'Function Mode'.
    LDAB    M_INPUT_MODE
    BNE     .GET_PARAM_SRC
    LDAB    #2

; Depending on the button mode we're in, select which parameter the value
; to be edited is indexed by.

.GET_PARAM_SRC:
    ASLB
    LDX     #TABLE_EDIT_PARAM_SRC
    ABX
    LDX     0,x

; Load the number of the parameter into ACCB.
    LDAB    0,x
    PSHB

; Depending on which 'Input Mode' the synth is in, select the appropriate
; table containing the maximum values by using the current input mode as an
; index into this lookup table containing pointers to the different maximum
; value tables.

.GET_PARAM_TABLE:
    LDX     #TABLE_MAX_VALUE_TBL_PTRS
    LDAB    M_INPUT_MODE
    BNE     .LOAD_TABLE
    LDAB    #2

; Load the maximum value table, and then use the parameter value retrieved
; earlier as an index into this table, to get the maximum value for
; this parameter.

.LOAD_TABLE:
    ASLB
    ABX
    LDX     0,x
    PULB
    ABX

; Check if the current value is at the maximum value. If so, return.
; Otherwise, increment the value by adding the 'YES' value of '1'.
; If this causes it to overflow the maximum, then set the value to
; its maximum.

.IS_VALUE_AT_MAXIMUM?:
    CMPA    0,x
    BEQ     .RESTORE_IX_AND_EXIT
    ADDA    <M_UP_DOWN_INCREMENT
    CMPA    0,x
    BHI     .RESET_TO_MAX

.RESTORE_IX_AND_EXIT:
    PULX

; Store the incremented/decremented value.

.END_BTN_INC_DEC_PARAM_VALUES:
    STAA    0,x
    RTS

.RESET_TO_MAX:
    LDAA    0,x
    BRA     .RESTORE_IX_AND_EXIT

; All of the numeric parameters that are edited through this function
; have a minimum of zero, so if the value is already zero, then the
; function exits here.

.BTN_NO:
    LDAA    0,x
    BEQ     .RESTORE_IX_AND_EXIT

; Since a value indicating a decrement will have its MSB set, adding this
; value to a numeric value will constitute a subtraction operation.
; If the resulting decrement underflows, set the result to 0.

.HANDLE_DECREMENT:
    ADDA    <M_UP_DOWN_INCREMENT
    BPL     .RESTORE_IX_AND_EXIT
    CLRA
    BRA     .RESTORE_IX_AND_EXIT


; ==============================================================================
; PATCH_LOAD_EDIT_PARAM
; ==============================================================================
; LOCATION: 0xCF48
;
; DESCRIPTION:
; This subroutine is used to parse, and re-load a single, modified patch
; parameter. The parameter to be re-loaded is decided based on the currently
; selected 'Edit Parameter'. The appropriate patch loading function for this
; parameter is then looked up in a table, and called.
;
; ==============================================================================

PATCH_LOAD_EDIT_PARAM:
    LDAB    M_EDIT_PARAM_CURRENT
    SUBB    #6
    ASLB
    LDX     #TABLE_PATCH_LOAD_FN
    ABX
    LDX     0,x
    JSR     0,x

PATCH_LOAD_PARAM_EDIT_RETURN:
    RTS


PATCH_LOAD_OP_PITCH_AND_ALG:
    JSR     PATCH_LOAD_OPERATOR_PITCH
    JSR     PATCH_LOAD_ALG_MODE
    RTS


; ==============================================================================
; Current Edit Parameter Pointers.
; This table contains pointers to the current parameter being edited. This
; table is indexed based upon the current 'Input Mode' that the synthesiser
; is in.
; e.g. If the synthesiser is in 'Function Mode', the parameter will be
; loaded from index 1 = M_FN_CURRENT_PARAM.
; This is used in various functions, such as the increment/decrement
; functions.
; ==============================================================================
TABLE_EDIT_PARAM_SRC:
    FDB 0
    FDB M_EDIT_PARAM_CURRENT
    FDB M_FN_PARAM_CURRENT

; ==============================================================================
; Max Edit Parameter Value Pointers.
; This table contains pointers to the tables of maximum values for the
; current parameter being edited. This table is indexed based upon the
; current 'Input Mode' the synthesiser is in.
; ==============================================================================
TABLE_MAX_VALUE_TBL_PTRS:
    FDB 0
    FDB TABLE_MAX_VALUE_EDIT_MODE
    FDB TABLE_MAX_VALUE_FUNC_MODE

; ==============================================================================
TABLE_MAX_VALUE_EDIT_MODE:
    FCB 0
    FCB 0
    FCB 0
    FCB 0
    FCB 0
    FCB 0
    FCB $1F
    FCB 7
    FCB 5                                       ; Index 8.
    FCB $63
    FCB $63
    FCB $63
    FCB $63
    FCB 1
    FCB 7
    FCB 3
    FCB 1                                       ; Index 16.
    FCB $1F
    FCB $63
    FCB $E
    FCB $63
    FCB $63
    FCB $63
    FCB 3
    FCB $63                                     ; Index 24.
    FCB 7
    FCB $63
    FCB 7
    FCB $63
    FCB $63

; ==============================================================================
TABLE_MAX_VALUE_FUNC_MODE:
    FCB 0
    FCB 1
    FCB $C
    FCB $C
    FCB 1
    FCB 1
    FCB $63
    FCB $F
    FCB 0                                       ; Index 8.
    FCB 0
    FCB 0
    FCB $10
    FCB $F
    FCB 0
    FCB 0
    FCB 0
    FCB $63                                     ; Index 16.
    FCB 1
    FCB 1
    FCB 1
    FCB $63
    FCB 1
    FCB 1
    FCB 1
    FCB $63                                     ; Index 24.
    FCB 1
    FCB 1
    FCB 1
    FCB $63
    FCB 1
    FCB 1
    FCB 1

; ==============================================================================
; Patch Load Parameter Functions.
; These functions are used to re-load individual patch parameters after
; they've been edited.
; ==============================================================================
TABLE_PATCH_LOAD_FN:
    FDB PATCH_LOAD_ALG_MODE
    FDB PATCH_LOAD_ALG_MODE
    FDB PATCH_LOAD_LFO
    FDB PATCH_LOAD_LFO
    FDB PATCH_LOAD_LFO
    FDB PATCH_LOAD_LFO
    FDB PATCH_LOAD_LFO
    FDB PATCH_LOAD_PARAM_EDIT_RETURN
    FDB PATCH_LOAD_LFO                          ; Index 8.
    FDB PATCH_LOAD_OPERATOR_KBD_RATE_SCALING
    FDB PATCH_LOAD_OP_PITCH_AND_ALG
    FDB PATCH_LOAD_OPERATOR_PITCH
    FDB PATCH_LOAD_OPERATOR_PITCH
    FDB PATCH_LOAD_OPERATOR_DETUNE
    FDB PATCH_LOAD_OPERATOR_EG_RATES
    FDB PATCH_LOAD_OPERATOR_EG_LEVELS
    FDB PATCH_LOAD_OPERATOR_KBD_SCALING         ; Index 16.
    FDB PATCH_LOAD_OPERATOR_KBD_SCALING
    FDB PATCH_LOAD_OPERATOR_KBD_SCALING
    FDB PATCH_LOAD_OPERATOR_KBD_RATE_SCALING
    FDB PATCH_LOAD_OPERATOR_KBD_SCALING
    FDB PATCH_LOAD_OPERATOR_KBD_VEL_SENS
    FDB PATCH_LOAD_PITCH_EG_VALUES
    FDB PATCH_LOAD_PITCH_EG_VALUES

.FUNC_MODE_IS_BUTTON_ABOVE_16:
    LDAB    M_FN_PARAM_CURRENT
    STAB    M_LAST_PRESSED_BTN
    CMPB    #BUTTON_16
    BHI     BTN_YES_NO_FN_16_TO_32

.BTN_16_OR_LESS:
    CMPB    #BUTTON_8
    BNE     .IS_BTN_LESS_THAN_8?

; If there is an active voice event (Key Up/Key Down), then don't
; process this event.

.BTN_8:
    JSR     VOICE_SEARCH_FOR_ACTIVE_KEY_EVENT
    BNE     BTN_YES_NO_END
    JMP     BTN_YES_NO_FN_8

.IS_BTN_LESS_THAN_8?:
    BCS     .BTN_LESS_THAN_8

.IS_BTN_12?:
    CMPB    #BUTTON_12
    BEQ     BTN_YES_NO_END

.IS_BTN_13?:
    CMPB    #BUTTON_13
    BEQ     BTN_YES_NO_END

; In 'Function Mode' button 14 is the battery check.
; There's no additional functionality associated with this button in this mode.

.IS_BTN_14?:
    CMPB    #BUTTON_14
    BNE     .BTN_9_TO_11
    RTS

.BTN_9_TO_11:
    JMP     BTN_YES_NO_FN_9_TO_11


; ==============================================================================
; INPUT_UNKNOWN
; ==============================================================================
; DESCRIPTION:
; This subroutine does not appear to be referenced, or called from anywhere.
;
; ==============================================================================

INPUT_UNKNOWN?:
    JSR     VOICE_SEARCH_FOR_ACTIVE_KEY_EVENT
    BNE     BTN_YES_NO_END


.BTN_LESS_THAN_8:
    ASLB
    LDX     #TABLE_FN_PARAMS
    ABX
    LDX     0,x
    LDAB    M_FN_PARAM_CURRENT
    BNE     BTN_YES_NO_INC_DEC

; Set the synth's 'Master Tune' parameter.
; Editing this parameter only responds to slider input.
    TST     M_SLIDER_INPUT_EVENT
    BEQ     MASTER_TUNE_EXIT

; Falls-through to store the master tune setting, and return.
    LDAB    <M_ANALOG_DATA


; ==============================================================================
; MASTER_TUNE_SET
; ==============================================================================
; LOCATION: 0xD018
;
; DESCRIPTION:
; Sets the synth's 'Master Tune' parameter.
;
; ARGUMENTS:
; Registers:
; * ACCB: The value to input into the master tune 'register'.
;
; ==============================================================================

MASTER_TUNE_SET:
    CLRA
    LSLD
    STD     M_MASTER_TUNE

MASTER_TUNE_EXIT:
    RTS


BTN_YES_NO_INC_DEC:
    JSR     BTN_INC_DEC_PARAM_VALUES
    STAA    0,x
    JSR     PORTA_COMPUTE_RATE_VALUE
    JSR     UI_PRINT_MAIN
    LDAB    M_FN_PARAM_CURRENT
    CMPB    #1
    BNE     BTN_YES_NO_END
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA
    JSR     VOICE_RESET
    PULA
    STAA    <IO_PORT_2_DATA

BTN_YES_NO_END:
    RTS


; ==============================================================================
; BTN_YES_NO_FN_ABOVE_16
; ==============================================================================
; LOCATION: 0xD03D
;
; DESCRIPTION:
; Button handler for when the 'Up/Down' buttons are pressed while the synth
; is in 'Function Mode', and the 'active parameter' is between 16-32.
; This subroutine is where all of the 'Modulation Source'-related flags
; are set.
;
; The 'Function Mode' buttons 16-32 are grouped into 4 groups of 4. These
; groups correspond to the four modulation 'sources': The Mod Wheel, Foot
; Controller, Breath Controller, and Aftertouch.
; This function has separate subroutines depending on whether button 1 in the
; group was pressed, which controls the input range, and buttons 2-4 are
; pressed, which control flags related to the modulation target
; (Pitch, Amplitude, EG Bias).
;
; ==============================================================================

BTN_YES_NO_FN_16_TO_32:
    LDAB    M_FN_PARAM_CURRENT

; Subtract 16, and use as index into param table.
    SUBB    #16
    ASLB
    LDX     #TABLE_FUNC_PARAMS_16_32
    ABX

; Load IX from params table.
    LDX     0,x
    LSRB

; Perform a modulus operation here to get the index into the current
; 4-button grouping.
; If the resulting value is non-zero, this means it corresponds to one of
; the 'Modulation-Source' toggle variables. If this is the case, branch.
    ANDB    #%11                                ; B = B % 4.
    BNE     .NON_RANGE_VALUE

.RANGE_VALUE:
    LDAA    <M_UP_DOWN_INCREMENT

; If the originating input event came from the slider, exit.
    TST     M_SLIDER_INPUT_EVENT
    BNE     .STORE_AND_UPDATE_PITCH_MOD?

.IS_INCREMENT_POSITIVE?:
    TSTA
    BMI     .INCREMENT_NEGATIVE

.IS_VALUE_AT_MAX?:
    LDAA    0,x
    CMPA    #99
    BEQ     .END_BTN_YES_NO_FN_16_TO_32

; Add the increment value. If the parameter value overflows the maximum
; value of 99, clamp it at 99.
    ADDA    <M_UP_DOWN_INCREMENT
    CMPA    #99
    BHI     .CLAMP_VALUE_AT_MAX

.STORE_AND_UPDATE_PITCH_MOD?:
    STAA    0,x
    JSR     MOD_PROCESS_INPUT_SOURCES
    TST     M_INPUT_MODE
    BEQ     .END_BTN_YES_NO_FN_16_TO_32
    JSR     UI_PRINT_MAIN

.END_BTN_YES_NO_FN_16_TO_32:
    RTS

.CLAMP_VALUE_AT_MAX:
    LDAA    #99
    BRA     .STORE_AND_UPDATE_PITCH_MOD?

.INCREMENT_NEGATIVE:
    LDAA    0,x
    BEQ     .END_BTN_YES_NO_FN_16_TO_32

; Add the increment value. This is effectively a subtraction operation.
; If the parameter value underflows the minimum value of 0, clamp it at 0.
    ADDA    <M_UP_DOWN_INCREMENT
    BMI     .CLAMP_VALUE_AT_MIN
    BRA     .STORE_AND_UPDATE_PITCH_MOD?

.CLAMP_VALUE_AT_MIN:
    CLRA
    BRA     .STORE_AND_UPDATE_PITCH_MOD?

.NON_RANGE_VALUE:
    LDAA    <M_SLIDER_INPUT_EVENT
    BNE     .FN_16_TO_32_SLIDER_EVENT

; If the button pressed is the fourth in the grouping (EG Bias)
; then increment ACCB to create a usable bitmask by causing value 3
; to occupy bit 3.

.IS_BIAS_BUTTON?:
    CMPB    #3
    BNE     .STORE_VALUE
    INCB

.STORE_VALUE:
    LDAA    <M_UP_DOWN_INCREMENT
    BMI     .CLEAR_PARAM_FLAG

; Set the corresponding flag with a logical OR using the modulo'd
; button input as a bitmask.

.SET_PARAM_FLAG:
    ORAB    0,x
    TBA
    BRA     .STORE_AND_UPDATE_PITCH_MOD?

; The following section creates a negative bitmask from the
; modulo'd button input number, and then uses a logical AND to clear
; the corresponding bit in the flag variable.

.CLEAR_PARAM_FLAG:
    COMB
    ANDB    0,x
    TBA
    BRA     .STORE_AND_UPDATE_PITCH_MOD?

.FN_16_TO_32_SLIDER_EVENT:
    LDAA    <M_UP_DOWN_INCREMENT
    BNE     .NON_RANGE_BTN_YES
    LDAA    #$FF

.STORE_SLIDER_NO_YES_FLAG:
    STAA    <M_UP_DOWN_INCREMENT
    BRA     .IS_BIAS_BUTTON?

.NON_RANGE_BTN_YES:
    LDAA    #1
    BRA     .STORE_SLIDER_NO_YES_FLAG


; ==============================================================================
; VOICE_RESET
; ==============================================================================
; LOCATION: 0xD0A9
;
; DESCRIPTION:
; Resets all synth voice data, and clears the EGS' voice data buffers.
;
; ==============================================================================

VOICE_RESET:
    JSR     EGS_RESET_VOICES                    ; Falls-through below.


; ==============================================================================
; VOICE_RESET_DATA
; ==============================================================================
; LOCATION: 0xD0AC
;
; DESCRIPTION:
; Clears the voice event buffer, then clears the voice pitch buffers.
; This subroutine is called during the main reset handler to set the voice
; pitch buffers to valid values. This is important as in the case of
; portamento, and glissando, the 'Voice Add' routine cannot initialise these
; values.
; This subroutine is also called after receiving a bulk SYSEX dump, since this
; data is stored temporarily in the same location as the voice buffers.
;
; MEMORY USED:
; * 0x86:  Used as a loop index when clearing buffers.
;
; ==============================================================================

VOICE_RESET_EVENT_AND_PITCH_BUFFERS:
    LDAB    #32
    LDX     #M_VOICE_STATUS

.CLEAR_VOICE_EVENTS_LOOP:
    CLR     0,x
    INX
    DECB
    BNE     .CLEAR_VOICE_EVENTS_LOOP            ; If ACCB > 0, loop.

; The following code clears the three sequential 'Voice Pitch Buffers'
; by setting the entry for each voice pitch to 0x2EA8.

.CLEAR_PITCH_BUFFERS:
    LDAA    #48
    STAA    <$86                                ; Loop index.
    LDD     #$2EA8

.CLEAR_PITCH_BUFFERS_LOOP:
    STD     0,x
    INX
    INX
    DEC     $86
    BNE     .CLEAR_PITCH_BUFFERS_LOOP           ; If *(0x86) > 0, loop.
    CLR     M_MONO_ACTIVE_VOICE_COUNT
    CLR     M_LEGATO_DIRECTION
    CLR     M_NOTE_KEY_LAST
    RTS


; ==============================================================================
; BTN_YES_NO_FN_8
; ==============================================================================
; LOCATION: 0xD0D1
;
; DESCRIPTION:
; In 'Function Mode', pressing button 8 'scrolls' through several
; sub-functions. This handler controls the pressing of 'NO/YES/DOWN/UP' when
; the UI is in this mode, depending on what function is currently selected.
; Refer to the 'sub-function' flag variable for more information.
;
; ==============================================================================

BTN_YES_NO_FN_8:
    LDAA    M_EDIT_BTN_8_SUB_FN
    BNE     .IS_SUB_FN_1?

.SUB_FN_0:
    JSR     VOICE_RESET
    LDX     #M_MIDI_RX_CH
    JMP     BTN_YES_NO_INC_DEC

.IS_SUB_FN_1?:
    CMPA    #1
    BNE     .SUB_FN_2

.SUB_FN_1:
    TST     M_SLIDER_INPUT_EVENT
    BNE     .READ_SLIDER_UP_DWN?
    TST     M_UP_DOWN_INCREMENT
    BMI     .SET_SYS_INFO_UNAVAIL

.SET_SYS_INFO_AVAIL:
    LDAA    #1
    STAA    M_MIDI_SYS_INFO_AVAIL
    BRA     .END_BTN_YES_NO_FN_8

.SET_SYS_INFO_UNAVAIL:
    CLR     M_MIDI_SYS_INFO_AVAIL
    BRA     .END_BTN_YES_NO_FN_8

.READ_SLIDER_UP_DWN?:
    LDAA    <M_UP_DOWN_INCREMENT
    CMPA    #7
    BHI     .SET_SYS_INFO_AVAIL
    BRA     .SET_SYS_INFO_UNAVAIL

.SUB_FN_2:
    TST     M_SLIDER_INPUT_EVENT
    BEQ     .IS_YES_PRESSED?
    RTS

.IS_YES_PRESSED?:
    TST     M_UP_DOWN_INCREMENT
    BPL     .MIDI_TRANSMIT
    RTS

.MIDI_TRANSMIT:
    JSR     LCD_CLEAR_STR_BUFFER
    JSR     LCD_PRINT_STR_BUFFER
    JSR     MIDI_SYSEX_DUMP_BULK

.END_BTN_YES_NO_FN_8:
    JMP     UI_PRINT_MAIN


; ==============================================================================
; BTN_YES_NO_FN_9_TO_11
; ==============================================================================
; LOCATION: 0xD119
;
; DESCRIPTION:
; Button handler for buttons 9, to 11 when the synth is in 'Function Mode.
; This is where patch initialisation happens, as well the patch 'Edit Recall'
; function, and cartridge formatting.
;
; ==============================================================================

BTN_YES_NO_FN_9_TO_11:
    TST     M_INPUT_MODE
    BNE     .IS_SLIDER_INPUT?

.INPUT_MODE_PLAY:
    RTS

; Exit if this event came from the slider.

.IS_SLIDER_INPUT?:
    TST     M_SLIDER_INPUT_EVENT
    BEQ     .IS_BUTTON_YES_OR_NO
    RTS

.IS_BUTTON_YES_OR_NO:
    TST     M_UP_DOWN_INCREMENT
    BPL     .IS_CONFIRM_FLAG_SET?

.FN_9_TO_11_BTN_NO:
    JMP     INPUT_RESET_TO_FN_MODE

; Test if the 'Confirm' flag in the 'Load/Save Flags' register is set.

.IS_CONFIRM_FLAG_SET?:
    TST     M_CRT_SAVE_LOAD_FLAGS
    BNE     .CONFIRM_FLAG_SET

; This sets bit 0, which indicates that the device is in a
; 'confirmation' state.

.SET_CONFIRM_FLAG:
    INC     M_CRT_SAVE_LOAD_FLAGS

; Falls-through below to print and return.

MENU_PRINT_MSG_CONFIRMATION:
    LDX     #aAreYouSure


MENU_PRINT_LINE_2:
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.CONFIRM_FLAG_SET:
    LDAB    M_FN_PARAM_CURRENT
    SUBB    #8
    BNE     .IS_BTN_10?

; Copy the 'Recall Buffer' into the 'Edit Buffer', and restore the
; modified flag, the patch number, and the status of the individual
; operators.

.BTN_9_EDIT_RECALL:
    JSR     PATCH_COPY_FROM_COMPARE
    LDAA    M_PATCH_COMPARE_NUMBER
    STAA    M_PATCH_CURRENT_NUMBER
    LDAA    M_PATCH_COMPARE_MODIFIED_FLAG
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    LDAA    M_PATCH_COMPARE_OPS_ON_OFF
    STAA    M_PATCH_CURRENT_OPS_ON_OFF

; Save timer and IRQ status to recall later.
    LDAA    <IO_PORT_2_DATA
    PSHA
    LDAA    <TIMER_CTRL_STATUS
    PSHA

.EDIT_RECALL_DISABLE_IRQ:
    CLR     IO_PORT_2_DATA
    CLR     TIMER_CTRL_STATUS
    BRA     .LOAD_PATCH_TO_EGS

.IS_BTN_10?:
    CMPB    #1
    BNE     .IS_BTN_11?

.BTN_10_VOICE_INIT:
    LDAA    <IO_PORT_2_DATA
    PSHA
    LDAA    <TIMER_CTRL_STATUS
    PSHA

.VOICE_INIT_DISABLE_IRQ:
    CLR     IO_PORT_2_DATA
    CLR     TIMER_CTRL_STATUS

; Load, and deserialise the initialise voice buffer into the
; 'Edit Buffer', then reset the status of the individual operators.

.DESERIALISE_INIT_BUFFER:
    LDD     #PATCH_INIT_VOICE_BUFFER
    JSR     PATCH_DESERIALISE
    CLR     M_PATCH_CURRENT_MODIFIED_FLAG
    LDAA    #%111111
    STAA    M_PATCH_CURRENT_OPS_ON_OFF

.LOAD_PATCH_TO_EGS:
    JSR     MIDI_SYSEX_DUMP_CURRENT_VOICE
    JSR     PATCH_LOAD_DATA
    LDAA    #1
    STAA    M_INPUT_MODE
    LDAA    M_EDIT_PARAM_CURRENT
    STAA    M_LAST_PRESSED_BTN
    JMP     RESTORE_IRQ_AND_EXIT

.IS_BTN_11?:
    CMPB    #2
    BEQ     CRT_FORMAT
    RTS

; ==============================================================================
; CRT_FORMAT
; ==============================================================================
; LOCATION: 0xD19C
;
; DESCRIPTION:
; Performs a user-initiated, button driven format of the cartridge.
; This function is reached via button 11 while the synth is in
; 'Function Mode'.
;
; ==============================================================================

CRT_FORMAT:
    JSR     CRT_CHECK_INSERTED
    JSR     CRT_CHECK_PROTECTION
    JSR     MEMORY_CHECK_CRT_PROTECT
    JSR     PRINT_MSG_UNDER_WRITING
    LDX     #P_CRT_START
    STX     <M_COPY_DEST_PTR

.SET_FORMAT_LOOP_INDEX:
    LDAB    #32
    STAB    M_CRT_FORMAT_PATCH_INDEX

.CRT_FORMAT_LOOP:
    LDX     #PATCH_INIT_VOICE_BUFFER
    STX     <M_COPY_SRC_PTR
    JSR     PATCH_WRITE_TO_CRT

; If CCR[c] is set, an error has occurred.
    BCS     .CRT_FORMAT_FAIL
    DEC     M_CRT_FORMAT_PATCH_INDEX
    BNE     .CRT_FORMAT_LOOP                    ; If *(0x217A) > 0, loop.
    LDX     #aFormattingEnd

.END_BTN_YES_NO_FN_9_TO_11:
    CLR     M_CRT_SAVE_LOAD_FLAGS
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.CRT_FORMAT_FAIL:
    LDX     #aWriteError
    BRA     .END_BTN_YES_NO_FN_9_TO_11
aFormattingEnd:      FCC " FORMATTING END ", 0


; ==============================================================================
; CRT_CHECK_INSERTED
; ==============================================================================
; LOCATION: 0xD1E0
;
; DESCRIPTION:
; Checks if the cartridge is inserted by reading line 5 of 8255 port C. If
; this line is pulled low, it indicates that a cartidge is inserted.
; In the case it is not inserted, the 'INSERT CARTRIDGE' message is printed
; to the LCD screen.
;
; ==============================================================================

CRT_CHECK_INSERTED:
    LDAA    P_CRT_PEDALS_LCD
    ANDA    #CRT_FLAG_INSERTED
    BEQ     .END_CRT_CHECK_INSERTED
    JSR     CRT_PRINT_NOT_INSERTED
    PULX

.END_CRT_CHECK_INSERTED:
    RTS


; ==============================================================================
; CRT_CHECK_PROTECTION
; ==============================================================================
; LOCATION: 0xD1EC
;
; DESCRIPTION:
; Checks whether cartridge memory is protected at the hardware level, by
; reading the appropriate line on the cartridge's IO port connected to the
; protection switch.
; An error message to the LCD output buffer if memory protection is enabled.
;
; ==============================================================================

CRT_CHECK_PROTECTION:
    LDAA    P_CRT_PEDALS_LCD
    ANDA    #CRT_FLAG_PROTECTED
    BEQ     .END_CRT_CHECK_PROTECTION
    JSR     PRINT_MSG_MEMORY_PROTECTED
    PULX

.END_CRT_CHECK_PROTECTION:
    RTS


; ==============================================================================
; MEMORY_CHECK_CRT_PROTECT
; ==============================================================================
; DESCRIPTION:
; Checks whether cartridge memory is protected, printing an error message to
; the LCD if it is.
; This subroutine reports the protection status by reading the flag stored
; at 0x88.
;
; ==============================================================================

MEMORY_CHECK_CRT_PROTECT:
    LDAA    <M_MEM_PROTECT_FLAGS
    ANDA    #MEM_PROTECT_CRT
    BEQ     .END_MEMORY_CHECK_CRT_PROTECT
    JSR     PRINT_MSG_MEMORY_PROTECTED
    PULX

.END_MEMORY_CHECK_CRT_PROTECT:
    RTS


; ==============================================================================
; MEMORY_CHECK_INT_PROTECT
; ==============================================================================
; LOCATION: 0xD203
;
; DESCRIPTION:
; Checks whether internal memory is protected, printing an error message to
; the LCD if it is.
; This subroutine reports the protection status by reading the flag stored
; at 0x88.
;
; ==============================================================================

MEMORY_CHECK_INT_PROTECT:
    LDAA    <M_MEM_PROTECT_FLAGS
    ANDA    #MEM_PROTECT_INT
    BEQ     .END_MEMORY_CHECK_INT_PROTECT
    JSR     PRINT_MSG_MEMORY_PROTECTED
    PULX

.END_MEMORY_CHECK_INT_PROTECT:
    RTS


; ==============================================================================
; BTN_YES_NO_CRT_READ_WRITE
; ==============================================================================
; LOCATION: 0xD20E
;
; DESCRIPTION:
; 'Yes/No' button handler for when the synthesiser's UI Mode is set to
; handle cartridge functionality.
;
; ==============================================================================

BTN_YES_NO_CRT_READ_WRITE:
    TST     M_SLIDER_INPUT_EVENT

; If this input originated from the slider, exit.
    BNE     .CRT_RW_SLIDER_EVENT

.IS_BUTTON_UP_OR_DOWN:
    TST     M_UP_DOWN_INCREMENT
    BMI     .CRT_RW_BTN_NO

; Checks the 'confirmation bit' (bit 0) in the flag variable.

.CHECK_CONFIRMATION?:
    LDAA    <M_CRT_SAVE_LOAD_FLAGS
    BITA    #1
    BNE     .CONFIRMED
    INC     M_CRT_SAVE_LOAD_FLAGS
    JMP     MENU_PRINT_MSG_CONFIRMATION

.CONFIRMED:
    JSR     CRT_CHECK_INSERTED
    JSR     CRT_CHECK_FORMAT
    BEQ     .CRT_FORMAT_OK
    JMP     CRT_FORMAT_CONFLICT

.CRT_FORMAT_OK:
    TST     M_CRT_SAVE_LOAD_FLAGS
    BMI     .TEST_MEM_PROTECT_INT

.TEST_MEM_PROTECT_CRT:
    JSR     CRT_CHECK_PROTECTION
    JSR     MEMORY_CHECK_CRT_PROTECT
    BSR     PRINT_MSG_UNDER_WRITING
    BRA     .MEM_PROTECT_OK

.TEST_MEM_PROTECT_INT:
    JSR     MEMORY_CHECK_INT_PROTECT

.MEM_PROTECT_OK:
    LDD     #P_CRT_START
    STD     <M_COPY_DEST_PTR
    LDD     #M_EXTERNAL_RAM_START
    STD     <M_COPY_SRC_PTR
    TST     M_CRT_SAVE_LOAD_FLAGS
    BMI     .READ_OPERATION

; Set CRT_RW_FLAGS to 'Write'.
    LDAA    #%10000000
    STAA    M_CRT_RW_FLAGS

.BEGIN_CRT_RW:
    JMP     CRT_READ_WRITE_ALL

.CRT_RW_BTN_NO:
    JMP     INPUT_RESET_TO_FN_MODE

.CRT_RW_SLIDER_EVENT:
    RTS


; ==============================================================================
; PRINT_MSG_UNDER_WRITING
; ==============================================================================
; LOCATION: 0xD25C
;
; DESCRIPTION:
; Prints the 'UNDER WRITING' message to the second line of the synth's LCD.
;
; ==============================================================================

PRINT_MSG_UNDER_WRITING:
    LDX     #aUnderWriting
    JMP     MENU_PRINT_LINE_2


; Set CRT_RW_FLAGS to 'Read'.

.READ_OPERATION:
    CLR     M_CRT_RW_FLAGS
    BRA     .BEGIN_CRT_RW


; ==============================================================================
; BTN_YES_NO_SET_MEM_PROTECT_STATUS
; ==============================================================================
; LOCATION: 0xD267
;
; DESCRIPTION:
; Handles the 'Yes/No' menu input when changing the memory protect status.
;
; ==============================================================================

BTN_YES_NO_SET_MEM_PROTECT_STATUS:
    LDAA    <M_MEM_PROTECT_FLAGS
    LDAB    <M_SLIDER_INPUT_EVENT
    BNE     .END_BTN_YES_NO_SET_MEM_PROTECT_STATUS

.IS_BUTTON_YES_OR_NO?:
    LDAB    <M_UP_DOWN_INCREMENT
    BMI     .SET_MEM_PROTECT_BTN_NO

.SET_MEM_PROTECT_BTN_YES:
    LDAB    <M_MEM_PROTECT_MODE
    CMPB    #BUTTON_MEM_PROTECT_INT
    BNE     .ENABLE_MEM_PROTECT_CRT

.ENABLE_MEM_PROTECT_INT:
    ORAA    #MEM_PROTECT_INT
    BRA     .STORE_MEM_PROTECT_STATUS

.ENABLE_MEM_PROTECT_CRT:
    ORAA    #MEM_PROTECT_CRT

.STORE_MEM_PROTECT_STATUS:
    STAA    <M_MEM_PROTECT_FLAGS
    LDAA    <M_MEM_PROTECT_MODE
    STAA    M_LAST_PRESSED_BTN
    JSR     UI_PRINT_MAIN

.END_BTN_YES_NO_SET_MEM_PROTECT_STATUS:
    RTS

.SET_MEM_PROTECT_BTN_NO:
    LDAB    <M_MEM_PROTECT_MODE
    CMPB    #BUTTON_MEM_PROTECT_INT
    BNE     .DISABLE_MEM_PROTECT_CRT

.DISABLE_MEM_PROTECT_INT:
    ANDA    #MEM_PROTECT_CRT
    BRA     .STORE_MEM_PROTECT_STATUS

.DISABLE_MEM_PROTECT_CRT:
    ANDA    #MEM_PROTECT_INT
    BRA     .STORE_MEM_PROTECT_STATUS


; ==============================================================================
; INPUT_EDIT_PATCH_NAME_ASCII_MODE
; ==============================================================================
; LOCATION: 0xD296
;
; DESCRIPTION:
; This subroutine facilitates user interaction during the patch name edit
; process, when it is in 'ASCII Input Mode'. This function handles using all
; of the front-panel buttons to enter the patch name as ASCII keys, and
; the 'Up/Down' front-panel buttons to move the cursor.
;
; Memory:
; * 0xFB:   Pointer to the location in the LCD buffer to print
;           the name chars to.
; * 0xF9:   Pointer to the location in the current patch edit
;           buffer to print the name chars to.
;
; ==============================================================================

INPUT_EDIT_PATCH_NAME_ASCII_MODE:
    LDAB    $20A2
    CMPB    #39
    BHI     .IS_BTN_DOWN?                       ; If B > 39, branch.

; If the user pressed a key to enter a specific letter.
; If we're currently in 'compare' mode, do nothing.

.PRESSED_ASCII_KEY:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_COMPARE
    BEQ     .END_INPUT_EDIT_PATCH_NAME_ASCII_MODE

; Use the last pressed front-panel button as an index into the ASCII table.
; Write this char to the LCD screen, and then write it to the destination
; name buffer.
    LDX     #TABLE_ASCII_CHARS
    ABX

; Write the selected char to the LCD.
    LDAA    0,x
    JSR     LCD_WRITE_DATA

; Write the selected char to the LCD buffer.
    LDAA    0,x
    LDX     <M_COPY_DEST_PTR
    STAA    0,x

; Write the selected char to the name buffer.
    LDX     <M_COPY_SRC_PTR
    STAA    0,x
    BSR     MIDI_SYSEX_SEND_NAME_EDIT
    CPX     #M_PATCH_CURRENT_NAME_LAST_CHAR
    BEQ     .SHIFT_LCD_CURSOR_LEFT

.INCREMENT_NAME_EDIT_PTR:
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    INX
    STX     <M_COPY_DEST_PTR
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    RTS

.IS_BTN_DOWN?:
    CMPB    #BUTTON_NO_DOWN
    BNE     .IS_BTN_UP?

.BTN_DOWN:
    LDX     <M_COPY_SRC_PTR
    CPX     #M_PATCH_CURRENT_NAME

; If cursor is decreased past the name start.
    BEQ     .END_INPUT_EDIT_PATCH_NAME_ASCII_MODE
    DEX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    DEX
    STX     <M_COPY_DEST_PTR
    BSR     MIDI_SYSEX_SEND_NAME_EDIT

.SHIFT_LCD_CURSOR_LEFT:
    LDAA    #LCD_INSTR_SHIFT_CURSOR_LEFT

.SET_LCD_CURSOR:
    JSR     LCD_WRITE_INSTRUCTION

.END_INPUT_EDIT_PATCH_NAME_ASCII_MODE:
    RTS

.IS_BTN_UP?:
    CMPB    #BUTTON_YES_UP
    BNE     .END_INPUT_EDIT_PATCH_NAME_ASCII_MODE

.BTN_UP:
    LDX     <M_COPY_SRC_PTR
    CPX     #M_PATCH_CURRENT_NAME_LAST_CHAR

; If cursor is increased past the name end.
    BEQ     .END_INPUT_EDIT_PATCH_NAME_ASCII_MODE
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    INX
    STX     <M_COPY_DEST_PTR
    BSR     MIDI_SYSEX_SEND_NAME_EDIT

.SHIFT_LCD_CURSOR_RIGHT:
    LDAA    #LCD_INSTR_SHIFT_CURSOR_RIGHT
    BRA     .SET_LCD_CURSOR


; ==============================================================================
; MIDI_SYSEX_SEND_NAME_EDIT
; ==============================================================================
; LOCATION: 0xD300
;
; DESCRIPTION:
; This subroutine sends a particular voice name edit action over SYSEX.
; This subroutine will send a single edited character over SYSEX to another
; DX7 synthesiser.
;
; ARGUMENTS:
; Registers:
; * IX:   The address of the edited character in the patch 'Edit buffer'.
;
; ==============================================================================

MIDI_SYSEX_SEND_NAME_EDIT:
    PSHX
    JSR     MIDI_SYSEX_SEND_PARAM_CHG
    PULX
    RTS


; ==============================================================================
; ASCII Character Table.
; Used in patch name editing.
; ==============================================================================
TABLE_ASCII_CHARS:   FCC "1234567890ABCDEFGHIJKLMNOPQRSTUVWX"
    FCC "YZ -. "


; ==============================================================================
; INPUT_CHECK_TEST_BTN_COMBO
; ==============================================================================
; LOCATION: 0xD32E
;
; DESCRIPTION:
; This subroutine checks whether the button combination necessary to initiate
; the synth's diagnostic mode is active. The calling subroutine has already
; checked the state of the 'function' button. This subroutine checks whether
; button 16, and button 31 are pressed. If either is pressed, a counter is
; incremented. This counter value is checked by the button down input handler.
; If it's equal to '2', diagnostic mode is initiated.
;
; MEMORY USED:
; * 0x97: The 'test mode' button counter.
;
; ==============================================================================

INPUT_CHECK_TEST_BTN_COMBO:
    LDAB    M_LAST_PRESSED_BTN
    CMPB    #BUTTON_16
    BEQ     .BUTTON_15_DOWN
    CMPB    #BUTTON_32
    BEQ     .BUTTON_32_DOWN
    RTS

.BUTTON_15_DOWN:
    INC     M_TEST_MODE_BUTTON_CHECK
    RTS

.BUTTON_32_DOWN:
    LDAA    <M_TEST_MODE_BUTTON_CHECK
    CMPA    #1
    BEQ     .INIT_TEST_MODE
    RTS

.INIT_TEST_MODE:
    INC     M_TEST_MODE_BUTTON_CHECK
    JSR     LCD_CLEAR_STR_BUFFER
    LDX     #aV1824Oct85Test
    JMP     LCD_WRITE_LINE_1_THEN_PRINT


; ==============================================================================
; VOICE_SEARCH_FOR_ACTIVE_KEY_EVENT
; ==============================================================================
; LOCATION: 0xD351
;
; DESCRIPTION:
; Searches through the voice 'Key Event' buffer searching for a voice with an
; active key event being processed.
;
; RETURNS:
; The boolean result is returned in the CCR register's 'Zero' flag.
; The returned result is set by the 'ANDA', and 'DECB' instruction calls.
; This means that a result of 0 indicates that an active voice was not found,
; and a non-zero result (indicated by CCR[Z] not being set) indicates one was
; found.
;
; ==============================================================================

VOICE_SEARCH_FOR_ACTIVE_KEY_EVENT:
    PSHX
    PSHB
    PSHA
    LDAB    #16
    LDX     #M_VOICE_STATUS

; If either of the two lowest bits are set it indicates that either a
; 'Key Down', or 'Key Up' event is currently being processed for this key.

.ACTIVE_KEY_EVENT_SEARCH_LOOP:
    LDAA    1,x
    ANDA    #%11
    BNE     .END_VOICE_SEARCH_FOR_ACTIVE_KEY_EVENT
    INX
    INX
    DECB
    BNE     .ACTIVE_KEY_EVENT_SEARCH_LOOP       ; If B > 0, loop.

.END_VOICE_SEARCH_FOR_ACTIVE_KEY_EVENT:
    PULA
    PULB
    PULX
    RTS


; ==============================================================================
; INPUT_KEY_DOWN
; ==============================================================================
; DESCRIPTION:
; The main keyboard 'Key Down' event handler.
; This subroutine sends a MIDI 'Note On' event, and then initiates playing the
; triggering note on the synthesiser.
; This function falls-through to the voice add function.
;
; ==============================================================================

INPUT_KEY_DOWN:
    JSR     MIDI_SEND_NOTE_ON


; ==============================================================================
; VOICE_ADD
; ==============================================================================
; LOCATION: 0xD36B
;
; DESCRIPTION:
; This subroutine is the main entry point to 'adding' a new voice event.
; It is effectively the entry point to actually playing a note over one of the
; synth's voices. This function branches to more specific functions, depending
; on whether the synth is in monophonic, or polyphonic mode.
; This subroutine is where a note keycode is converted to the EGS chip's
; internal representation of pitch. The various voice buffers related to pitch
; transitions are set, and reset here.
; This is also where the master tune is set.
;
; ==============================================================================

VOICE_ADD:
    LDAB    <M_NOTE_KEY

; Add the current transpose value, and subtract 24,  to take into account
; that this is a -24 - 24 range.
    ADDB    M_PATCH_CURRENT_TRANSPOSE
    SUBB    #24

; If the result is > 127, set to 127.
    CMPB    #127
    BLS     .GET_KEY_PITCH
    LDAB    #127

.GET_KEY_PITCH:
    JSR     VOICE_CONVERT_NOTE_TO_PITCH
    LDAB    M_PATCH_CURRENT_MODIFIED_FLAG

; Check if the patch is modified. If it is, check if the synth is currently
; waiting for the next key event to modify the key transpose value.

.IS_PATCH_MODIFIED?:
    CMPB    #EDITED_PATCH_IN_COMPARE
    BEQ     .IS_SYNTH_MONO?

; If the synth is set to 'Key Transpose' mode, then the next key pressed
; will be used to set the transpose amount.

.IS_KEY_TRANSPOSE_ACTIVE?:
    LDAB    <M_EDIT_KEY_TRANSPOSE_ACTIVE
    BNE     KEY_TRANSPOSE_SET

.IS_SYNTH_MONO?:
    LDAB    M_MONO_POLY
    BNE     .VOICE_ADD_SYNTH_IS_MONO
    JMP     VOICE_ADD_POLY

.VOICE_ADD_SYNTH_IS_MONO:
    JMP     VOICE_ADD_MONO


; ==============================================================================
; KEY_TRANSPOSE_SET
; ==============================================================================
; LOCATION: 0xD391
;
; DESCRIPTION:
; This subroutine sets the 'Key Transpose' centre-note value.
; This function is called as part of the 'Voice Add' routine if the appropriate
; flag is set to indicate that the synth is in 'Set Key Tranpose' mode,
; indicating that next key note value is to be stored as the centre-note value.
;
; ==============================================================================

KEY_TRANSPOSE_SET:
    LDAB    <M_NOTE_KEY

; Enforce the centre-note value being between 36, and 84.
    CMPB    #36
    BCS     .VALUE_UNDER_36
    CMPB    #84
    BLS     .SAVE_KEY_TRANSPOSE_VALUE

.VALUE_OVER_84:
    LDAB    #84
    BRA     .SAVE_KEY_TRANSPOSE_VALUE

.VALUE_UNDER_36:
    LDAB    #36

.SAVE_KEY_TRANSPOSE_VALUE:
    SUBB    #36
    STAB    M_PATCH_CURRENT_TRANSPOSE

.SAVE_INPUT_VALUE:
    LDAA    M_EDIT_PARAM_CURRENT
    STAA    M_LAST_PRESSED_BTN
    JSR     UI_PRINT_MAIN

.SET_PATCH_MODIFIED_FLAG:
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    JSR     LED_PRINT_PATCH_NUMBER

; Clear the 'Key Tranpose Mode' flag.
    CLR     M_EDIT_KEY_TRANSPOSE_ACTIVE
    RTS


; ==============================================================================
; Length: 128.
; ==============================================================================

TABLE_KEY_PITCH:
    FCB 0, 0, 1, 2, 4, 5, 6
    FCB 8, 9, $A, $C, $D, $E
    FCB $10, $11, $12, $14, $15
    FCB $16, $18, $19, $1A, $1C
    FCB $1D, $1E, $20, $21, $22
    FCB $24, $25, $26, $28, $29
    FCB $2A, $2C, $2D, $2E, $30
    FCB $31, $32, $34, $35, $36
    FCB $38, $39, $3A, $3C, $3D
    FCB $3E, $40, $41, $42, $44
    FCB $45, $46, $48, $49, $4A
    FCB $4C, $4D, $4E, $50, $51
    FCB $52, $54, $55, $56, $58
    FCB $59, $5A, $5C, $5D, $5E
    FCB $60, $61, $62, $64, $65
    FCB $66, $68, $69, $6A, $6C
    FCB $6D, $6E, $70, $71, $72
    FCB $74, $75, $76, $78, $79
    FCB $7A, $7C, $7D, $7E, $80
    FCB $81, $82, $84, $85, $86
    FCB $88, $89, $8A, $8C, $8D
    FCB $8E, $90, $91, $92, $94
    FCB $95, $96, $98, $99, $9A
    FCB $9C, $9D, $9E, $A0, $A1
    FCB $A2, $A4, $A5, $A6, $A8


; ==============================================================================
; VOICE_ADD_POLY
; ==============================================================================
; LOCATION: 0xD43B
;
; DESCRIPTION:
; Handles adding a new voice event when the synth is in polyphonic mode.
; This subroutine is responsible for setting the entry in the voice event,
; and voice target pitch buffers for the currently selected voice.
;
; ==============================================================================

VOICE_ADD_POLY:
    LDAA    #16
    STAA    <VA_FIND_VOICE_LOOP_INDEX
    DECA
    STAA    <VA_VOICE_INDEX
; Search for an entry in 0x20B0 where bit 1 is 0.

.FIND_INACTIVE_VOICE_LOOP:
    LDX     #M_VOICE_STATUS
    LDAB    <VA_CURR_VOICE_INDEX
    ANDB    <VA_VOICE_INDEX                     ; 0xA1 % 16.
    ASLB
    ABX
    LDAA    1,x

.IS_KEY_EVENT_OFF?:
    BITA    #VOICE_STATUS_ACTIVE
    BEQ     .VOICE_KEY_EVENT_OFF

.VOICE_ADD_POLY_INCREMENT_INDEX:
    INC     VA_CURR_VOICE_INDEX
    DEC     VA_FIND_VOICE_LOOP_INDEX
    BNE     .FIND_INACTIVE_VOICE_LOOP

.EXIT_NO_INACTIVE_VOICE_EVENTS:
    RTS

.VOICE_KEY_EVENT_OFF:
    LDAA    <TIMER_CTRL_STATUS
    PSHA
    CLR     TIMER_CTRL_STATUS                   ; Clear timer interrupt.

; Store ACCB into the 'Buffer Offset' value. This value will be the
; current voice number * 2, used as an offset into the voice buffers.

; Shift the buffer offset value to the left, and add '1' to create the
; bitmask for sending a 'Note Off' event for this voice to the EGS chip.

.SEND_NOTE_OFF_TO_EGS:
    STAB    <VA_BUFFER_OFFSET
    INCB
    ASLB
    STAB    P_EGS_VOICE_EVENTS

; Increment this value back to '16', so that it can serve as an iterator
; value for the portamento mode 'Follow' loop.

.SET_INDEX:
    INC     VA_VOICE_INDEX

; Increment the 'current voice' index so that the next 'Voice Add'
; command starts at the most likely free voice.
    INC     VA_CURR_VOICE_INDEX

.VOICE_ADD_POLY_SETUP_POINTERS:
    LDX     #M_VOICE_PITCH_TARGET
    STX     <VA_VOICE_PITCH_TARGET_PTR
    LDX     #M_VOICE_STATUS
    STX     <VA_VOICE_STATUS_PTR

.VOICE_ADD_POLY_IS_PORTA_PDL_ACTIVE?:
    LDAA    <M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_PORTAMENTO_ACTIVE
    BEQ     .VOICE_ADD_POLY_NO_PORTAMENTO

; If the portamento rate is at maximum (0xFF), no pitch transition occurs.

.VOICE_ADD_POLY_IS_PORTA_RATE_MAX?:
    LDAA    <M_PORTA_RATE_INCREMENT
    CMPA    #$FF
    BEQ     .VOICE_ADD_POLY_NO_PORTAMENTO

; If the synth's portamento mode is set to 'Follow', in which all active
; notes transition to the latest note event, update all of the voices that
; are currently being sustained by the sustain pedal, setting their target
; pitch to the new value. This will cause the main portamento handler to
; transition their pitches towards that of the new note.

.PORTAMENTO_ACTIVE:
    TST     M_PORTA_MODE
    BEQ     .SET_PORTA_GLISS_PITCH

.PORTA_FOLLOW_UPDATE_VOICE_LOOP:
    LDX     <VA_VOICE_STATUS_PTR
    LDAA    1,x

; Check if this voice is being sustained. If so, update its target pitch.

.IS_VOICE_ACTIVE?:
    BITA    #VOICE_STATUS_ACTIVE
    BNE     .INCREMENT_KEY_EVENT_POINTER

; The new key pitch is stored in the 'Target Pitch' entry for this voice.

.STORE_NEW_KEY_TARGET_PITCH:
    LDX     <VA_VOICE_PITCH_TARGET_PTR
    BSR     VOICE_ADD_POLY_GET_14_BIT_PITCH
    STD     0,x

.INCREMENT_KEY_EVENT_POINTER:
    LDAB    #2
    LDX     <VA_VOICE_STATUS_PTR
    ABX
    STX     <VA_VOICE_STATUS_PTR

.INCREMENT_VOICE_TARGET_PITCH_POINTER:
    LDX     <VA_VOICE_PITCH_TARGET_PTR
    ABX
    STX     <VA_VOICE_PITCH_TARGET_PTR
    DEC     VA_VOICE_INDEX
    BNE     .PORTA_FOLLOW_UPDATE_VOICE_LOOP
    BRA     .STORE_VOICE_EVENT

; In the event that there is no portamento, the 'last' note pitch is set
; to the current target pitch. The effect of this is that when the
; portamento, and glissando buffers are set, no pitch transition will occur.

.VOICE_ADD_POLY_NO_PORTAMENTO:
    BSR     VOICE_ADD_POLY_GET_14_BIT_PITCH
    STD     <VA_VOICE_PITCH_LAST

; If portamento is currently enabled, the 'current' portamento, and
; glissando pitches for the new note will be set to the target pitch
; of the 'last' note pressed.
; In the event that there is no portamento. The portamento and glissando
; pitch buffers will have been set to the current voice's target pitch
; above. The effect of this is that there will be no pitch transition.
; After these buffers have been set, the 'new' current pitch is set, which
; will be loaded to the EGS below.

.SET_PORTA_GLISS_PITCH:
    JSR     VOICE_ADD_POLY_SET_PORTA_PITCH
    STD     <VA_VOICE_PITCH_NEW

; Load the target pitch buffer, add offset, and store the target pitch
; for the current voice.

.STORE_CURRENT_VOICE_TARGET_PITCH:
    LDX     <VA_VOICE_PITCH_TARGET_PTR
    LDAB    <VA_BUFFER_OFFSET
    ABX
    LSRB
    STAB    <VA_VOICE_CURRENT

; Store the pitch of this note as the 'last' pitch.
    BSR     VOICE_ADD_POLY_GET_14_BIT_PITCH
    STD     0,x
    STD     <VA_VOICE_PITCH_LAST

; Load the new pitch to the EGS here.
; It will be loaded again below. However if the portamento pedal is active
; this will be the place the pitch is initially loaded.
    JSR     VOICE_ADD_LOAD_PITCH_TO_EGS
    BRA     .STORE_VOICE_EVENT


; ==============================================================================
; VOICE_ADD_POLY_GET_14_BIT_PITCH
; ==============================================================================
; LOCATION: 0xD4C5
;
; DESCRIPTION:
; Loads and truncates the 'Key Pitch' value to its final 14-bit format, as
; required by the EGS chip.
;
; RETURNS:
; * ACCD: The truncated 14-bit pitch
;
; ==============================================================================

VOICE_ADD_POLY_GET_14_BIT_PITCH:
    LDD     <M_KEY_PITCH
    ANDB    #%11111100
    RTS


; ==============================================================================
; VOICE_ADD_POLY_SET_PORTA_PITCH
; ==============================================================================
; LOCATION: 0xD4CA
;
; DESCRIPTION:
; This subroutine sets the current portamento, and glissando pitch values for
; the current voice from the pitch of the 'last' note.
;
; ==============================================================================

VOICE_ADD_POLY_SET_PORTA_PITCH:
    LDAB    <VA_BUFFER_OFFSET
    LDX     #M_VOICE_PITCH_PORTAMENTO
    ABX

; This 'load IX, add B to index, push, repeat, store, pull' routine
; here avoids needing to load ACCD twice.
    PSHX
    LDX     #M_VOICE_PITCH_GLISSANDO
    ABX
    LDD     <VA_VOICE_PITCH_LAST

; Store 14-bit key pitch.
    STD     0,x
    PULX
    STD     0,x
    RTS


; Store the 'Voice Event' for the current voice.
; This is a 16-bit value in the format: (Key_Number << 8) | Flags.
; The flags field has two bits:
;  * '0b10' indicates this voice is actively playing a note.
;  * '0b1' indicates sustain is active.

.STORE_VOICE_EVENT:
    LDX     #M_VOICE_STATUS
    LDAB    <VA_BUFFER_OFFSET
    ABX
    LDAA    <M_NOTE_KEY
    LDAB    #VOICE_STATUS_ACTIVE
    STD     0,x

; Reset the current pitch EG level to its initial value.
; In the DX7, the final value, and the initial value are identical. So when
; adding a voice, the initial level is set to the final value.
    LDX     #M_VOICE_PITCH_EG_CURR_LEVEL
    LDAB    <VA_BUFFER_OFFSET
    ABX
    LDAA    M_PATCH_PITCH_EG_VALUES_FINAL_LEVEL
    CLRB
    LSRD
    STD     0,x

; Reset the 'Current Pitch EG Step' for this voice.
    LDX     #M_VOICE_PITCH_EG_CURR_STEP
    LDAB    <VA_BUFFER_OFFSET
    LSRB
    ABX
    CLR     0,x
    LDAA    M_PATCH_CURRENT_LFO_DELAY
    BEQ     .VOICE_ADD_POLY_IS_LFO_SYNC_ON?

.VOICE_ADD_POLY_RESET_LFO:
    LDD     #0
    STD     <M_LFO_DELAY_COUNTER
    CLR     M_LFO_FADE_IN_SCALE_FACTOR

; If 'LFO Key Sync' is enabled, reset the LFO phase accumulator to its
; maximum positive value to coincide with the 'Key On' event.

.VOICE_ADD_POLY_IS_LFO_SYNC_ON?:
    LDAA    M_PATCH_CURRENT_LFO_SYNC
    BEQ     .VOICE_ADD_POLY_LOAD_PITCH_TO_EGS
    LDD     #$7FFF
    STD     <M_LFO_PHASE_ACCUMULATOR

.VOICE_ADD_POLY_LOAD_PITCH_TO_EGS:
    LDAA    <VA_BUFFER_OFFSET
    LSRA

; The key pitch is stored again in this subroutine call.
    LDX     <M_KEY_PITCH
    JSR     VOICE_ADD_LOAD_OPERATOR_DATA_TO_EGS

; Construct a 'Note On' event for this voice from the buffer offset, same
; as before, and load it to the EGS voice event register.

.SEND_NOTE_ON_EVENT_TO_EGS:
    LDAB    <VA_BUFFER_OFFSET
    ASLB
    INCB
    STAB    P_EGS_VOICE_EVENTS

.RE_ENABLE_TIMER_INTERRUPT:
    PULA
    STAA    <TIMER_CTRL_STATUS
    RTS


; ==============================================================================
; INPUT_KEY_UP
; ==============================================================================
; LOCATION: 0xD529
;
; DESCRIPTION:
; The main keyboard 'Key Down' event handler.
; This subroutine sends a MIDI 'Note On' event (which will have a velocity of
; zero, indicating 'Note Off'), and then initiates removing the voice related
; to the released note on the synthesiser.
; This function falls-through to the voice remove function.
;
; ==============================================================================

INPUT_KEY_UP:
    JSR     MIDI_SEND_NOTE_ON


; ==============================================================================
; VOICE_REMOVE
; ==============================================================================
; LOCATION: 0xD52C
;
; DESCRIPTION:
; Handles 'removing' an active voice. Typically when a key is released.
; When the synth is in monophonic mode, this subroutine deals with setting the
; correct legato 'target pitch'.
;
; MEMORY USED:
; * 0x9F: The EGS voice event buffer command for a 'Key Off' event.
;         The full format of this command is:
;           ('Voice Number' << 2) | 'Event Mask'.
;         The event mask is:
;           * 'Key Off' = 0b10
;           * 'Key On'  = 0b01
;
;         NOTE: This is the opposite of the format of the local voice
;         key event buffer.
;
; ==============================================================================

VOICE_REMOVE:
    LDAA    <M_NOTE_KEY
    LDAB    M_MONO_POLY
    BEQ     .SYNTH_IS_POLY
    JMP     .VOICE_REMOVE_SYNTH_IS_MONO

.SYNTH_IS_POLY:
    LDAB    #2
    LDX     #M_VOICE_STATUS
    STX     <VR_VOICE_STATUS_PTR
    LDX     #M_VOICE_PITCH_EG_CURR_STEP
    STX     <VR_VOICE_PITCH_EG_CURR_STEP_PTR

.FIND_KEY_EVENT_LOOP:
    STAB    <VR_REMOVE_VOICE_CMD
    LDX     <VR_VOICE_STATUS_PTR

; Does the current entry in the 'Voice Key Events' buffer match the note
; being removed?
    CMPA    0,x
    BNE     .ITERATE_LOOP

; Check if the matching key event is active.

.IS_KEY_EVENT_ACTIVE?:
    LDAB    1,x
    BITB    #VOICE_STATUS_ACTIVE
    BNE     .POLY_IS_SUSTAIN_PEDAL_ACTIVE?

; Increment the loop pointers, and voice number, then loop back.

.ITERATE_LOOP:
    INX
    INX
    STX     <VR_VOICE_STATUS_PTR
    LDX     <VR_VOICE_PITCH_EG_CURR_STEP_PTR
    INX
    STX     <VR_VOICE_PITCH_EG_CURR_STEP_PTR

; Increase the voice number in the 'Remove Voice Event' command by one.
; This is done by adding 4, since this field uses bytes 7..2.

.SET_REMOVE_VOICE_COMMAND:
    LDAB    <VR_REMOVE_VOICE_CMD
    ADDB    #4

; If the voice index exceeds 16, exit.
    BITB    #%1000000
    BEQ     .FIND_KEY_EVENT_LOOP

.EXIT_MATCHING_VOICE_NOT_FOUND:
    RTS

.POLY_IS_SUSTAIN_PEDAL_ACTIVE?:
    LDAA    <M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_SUSTAIN_ACTIVE
    BNE     .POLY_SUSTAIN_PEDAL_ACTIVE

; Mask the appropriate bit of the 'flag byte' of the Key Event buffer entry
; to indicate a 'Key Off' event.

.SET_KEY_OFF_EVENT:
    LDAA    1,x
    ANDA    #~VOICE_STATUS_ACTIVE
    STAA    1,x

; The following lines set this voice's pitch EG step to 4, to indicate
; that it's in the release phase.

.SET_ENV_STEP:
    LDAA    #4
    LDX     <VR_VOICE_PITCH_EG_CURR_STEP_PTR
    STAA    0,x

.SEND_VOICE_OFF_EVENT_TO_EGS:
    LDAB    <VR_REMOVE_VOICE_CMD
    STAB    P_EGS_VOICE_EVENTS
    RTS

.POLY_SUSTAIN_PEDAL_ACTIVE:
    LDAA    #1
    ORAA    1,x
    ANDA    #%11111101
    STAA    1,x
    RTS


; ==============================================================================
; VOICE_ADD_MONO
; ==============================================================================
; LOCATION: 0xD583
;
; DESCRIPTION:
; Handles adding a new voice event when the synth is in monophonic mode.
; This subroutine is responsible for setting the entry in the voice event,
; and voice target pitch buffers for the currently selected voice.
;
; ==============================================================================

VOICE_ADD_MONO:
    CLR     M_MONO_SUSTAIN_PEDAL_ACTIVE
    LDX     #M_VOICE_STATUS

.IS_ACTIVE_VOICE_COUNT_16?:
    LDAB    <M_MONO_ACTIVE_VOICE_COUNT
    CMPB    #16
    BEQ     .END_VOICE_ADD_MONO
    LDAB    #16

; In MONO mode, the active key event is CLEARED when removed.
; This occurs in the VOICE_REMOVE subroutine.
; This loop searches for a voice key event with a clear NOTE field.

.FIND_CLEAR_KEY_EVENT_LOOP:
    TST     0,x
    BEQ     .KEY_NUMBER_IS_CLEAR
    INX
    INX
    DECB
    BNE     .FIND_CLEAR_KEY_EVENT_LOOP          ; If B > 0, loop.
    RTS

; Write ((NOTE_KEY << 8) & 2) to the first entry in the 'Voice Event'
; buffer to indicate that this voice is actively playing this key.

.KEY_NUMBER_IS_CLEAR:
    LDAA    <M_NOTE_KEY
    LDAB    #VOICE_STATUS_ACTIVE
    STD     0,x

.INCREMENT_VOICE_COUNT:
    INC     M_MONO_ACTIVE_VOICE_COUNT
    LDAA    <M_MONO_ACTIVE_VOICE_COUNT
    CMPA    #1

; If there's more than one active voice at this point, the existing
; portamento needs to be taken into account. This branch falls-through
; to return.
    BNE     VOICE_ADD_MONO_MULTIPLE_VOICES

.VOICE_COUNT_IS_1:
    TST     M_PATCH_CURRENT_LFO_DELAY
    BEQ     .VOICE_ADD_MONO_IS_LFO_SYNC_ON?

.VOICE_ADD_MONO_RESET_LFO:
    LDD     #0
    STD     <M_LFO_DELAY_COUNTER
    CLR     M_LFO_FADE_IN_SCALE_FACTOR

; If 'LFO Key Sync' is enabled, reset the LFO phase accumulator to its
; maximum positive value to coincide with the 'Key On' event.

.VOICE_ADD_MONO_IS_LFO_SYNC_ON?:
    TST     M_PATCH_CURRENT_LFO_SYNC
    BEQ     .RESET_EGS_VOICE_EVENT
    LDD     #$7FFF
    STD     <M_LFO_PHASE_ACCUMULATOR

; Write 'Key Off' event to EGS.

.RESET_EGS_VOICE_EVENT:
    LDAB    #2
    STAB    P_EGS_VOICE_EVENTS

; The voice's target pitch, and 'Previous Key' data is stored here.
; If portamento is not currently active, the target pitch will be set a
; second time, together with the voice pitch buffers specific to
; portamento, and glissando.
    BSR     VOICE_ADD_MONO_STORE_KEY_AND_PITCH

.VOICE_ADD_MONO_IS_PORTA_RATE_MAX?:
    LDAA    <M_PORTA_RATE_INCREMENT
    CMPA    #$FF
    BEQ     .VOICE_ADD_MONO_NO_PORTAMENTO
    TST     M_PORTA_MODE
    BEQ     .VOICE_ADD_MONO_NO_PORTAMENTO
    LDAA    <M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_PORTAMENTO_ACTIVE
    BNE     .RESET_PITCH_EG_LEVEL

; If there's no portamento. The portamento and glissando pitch buffers
; will be set to the same value as the current voice's target pitch.
; The effect of this will be that there is no voice transition computed by
; the 'PORTA_PROCESS' subroutine, which is responsible for updating the
; synth's voice pitch periodically.

.VOICE_ADD_MONO_NO_PORTAMENTO:
    BSR     VOICE_ADD_MONO_CLEAR_PORTA_PITCH

; Reset the current pitch EG level to its initial value.
; In the DX7, the final value, and the initial value are identical.
; So when adding a voice, the initial level is set to the final value.

.RESET_PITCH_EG_LEVEL:
    LDAA    M_PATCH_PITCH_EG_VALUES_FINAL_LEVEL
    CLRB
    LSRD
    STD     M_VOICE_PITCH_EG_CURR_LEVEL

; Reset the 'Current Pitch EG Step' for this voice.

.RESET_PITCH_EG_STEP:
    CLR     M_VOICE_PITCH_EG_CURR_STEP
    CLRA

; Send the pitch, and amplitude information to the EGS registers,
; then send a 'KEY ON' event for Voice #0.

.SET_EGS_KEY_EVENT:
    LDX     <M_KEY_PITCH
    JSR     VOICE_ADD_LOAD_OPERATOR_DATA_TO_EGS
    LDAA    #1
    STAA    P_EGS_VOICE_EVENTS

.END_VOICE_ADD_MONO:
    RTS


; ==============================================================================
; VOICE_ADD_MONO_MULTIPLE_VOICES
; ==============================================================================
; LOCATION: 0xD5F2
;
; DESCRIPTION:
; Handles adding a new voice event when the synth is in monophonic mode, and
; there is more than one active voice.
; This subroutine is responsible for parsing the legato direction, and setting
; the voice pitch buffers accordingly.
;
; ==============================================================================

VOICE_ADD_MONO_MULTIPLE_VOICES:
    CMPA    #2
    BNE     .MORE_THAN_2_VOICES

.GET_PORTAMENTO_DIRECTION:
    LDAA    <M_NOTE_KEY
    SUBA    <M_NOTE_KEY_LAST
    BCC     .NEW_NOTE_HIGHER
    CLR     M_LEGATO_DIRECTION
    BRA     .STORE_LAST_KEY_EVENT

.NEW_NOTE_HIGHER:
    LDAA    #1
    STAA    <M_LEGATO_DIRECTION

; The voice's target pitch, and 'Previous Key' data is stored here.
; If portamento is not currently active, the target pitch will be set a
; second time, together with the voice pitch buffers specific to
; portamento, and glissando.

.STORE_LAST_KEY_EVENT:
    BSR     VOICE_ADD_MONO_STORE_KEY_AND_PITCH

.ADD_MONO_MULTIPLE_IS_PORTA_RATE_MAX?:
    LDAA    <M_PORTA_RATE_INCREMENT
    CMPA    #$FF

; If portamento rate is at maximum, ignore portamento. The voice's target
; pitch is set here, and then the subroutine returns.
    BEQ     VOICE_ADD_MONO_CLEAR_PORTA_PITCH

.IS_PORTA_MODE_FULL?:
    TST     M_PORTA_MODE
    BEQ     .END_VOICE_ADD_MONO_MULTIPLE_VOICES

.IS_PORTA_PEDAL_ACTIVE?:
    LDAA    <M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_PORTAMENTO_ACTIVE

; If portamento is not active, clear the portamento and glissando pitch
; buffers here, by setting them to this voice's 'target pitch'.
    BEQ     VOICE_ADD_MONO_CLEAR_PORTA_PITCH

.END_VOICE_ADD_MONO_MULTIPLE_VOICES:
    RTS


; ==============================================================================
; VOICE_ADD_MONO_CLEAR_PORTA_PITCH
; ==============================================================================
; LOCATION: 0xD619
;
; DESCRIPTION:
; If there is no portamento, this subroutine sets the target pitch for
; voice#0, then sets the same pitch in the associatged portamento, and
; glissando pitch buffers. The effect of this is effectively disabling the
; pitch transition for this voice.
;
; ==============================================================================

VOICE_ADD_MONO_CLEAR_PORTA_PITCH:
    LDD     M_VOICE_PITCH_TARGET
    STD     M_VOICE_PITCH_PORTAMENTO
    STD     M_VOICE_PITCH_GLISSANDO
    RTS


; If there's more than two active voices, check the legato direction,
; and then check whether the new note is further in that direction than the
; previous. If so, the legato target note will need to be updated.

.MORE_THAN_2_VOICES:
    LDAA    <M_LEGATO_DIRECTION
    BEQ     .IS_NEW_NOTE_LOWER?

; If the current legato direction is upwards, and the new note is HIGHER,
; then update the stored 'Last Key Event'. Otherwise exit.

.IS_NEW_NOTE_HIGHER?:
    LDAA    <M_NOTE_KEY
    SUBA    <M_NOTE_KEY_LAST
    BCS     .END_VOICE_ADD_MONO_MULTIPLE_VOICES
    BRA     .STORE_LAST_KEY_EVENT

; If the current legato direction is downwards, and the new note is LOWER,
; then update the stored 'Last Key Event'. Otherwise exit.

.IS_NEW_NOTE_LOWER?:
    LDAA    <M_NOTE_KEY
    SUBA    <M_NOTE_KEY_LAST
    BCC     .END_VOICE_ADD_MONO_MULTIPLE_VOICES
    BRA     .STORE_LAST_KEY_EVENT


; ==============================================================================
; VOICE_ADD_MONO_STORE_KEY_AND_PITCH
; ==============================================================================
; LOCATION: 0xD637
;
; DESCRIPTION:
; Stores the currently triggered key note in the register for the PREVIOUS
; key note. This is used when adding a voice in monophonic mode.
; This falls-through to set the target pitch for the first voice.
;
; ==============================================================================

VOICE_ADD_MONO_STORE_KEY_AND_PITCH:
    LDAA    <M_NOTE_KEY
    STAA    <M_NOTE_KEY_LAST                    ; Falls-through below.


; ==============================================================================
; VOICE_STORE_TARGET_PITCH_MONO
; ==============================================================================
; LOCATION: 0xD63B
;
; DESCRIPTION:
; Stores the target pitch for the first voice entry.
; This is used during voice adding, and removal, when the synth is monophonic.
;
; ==============================================================================

VOICE_ADD_MONO_SET_TARGET_PITCH:
    LDD     <M_KEY_PITCH
    STD     M_VOICE_PITCH_TARGET
    RTS


; Search the voice event buffer for an entry with the same key as the one
; being released.

.VOICE_REMOVE_SYNTH_IS_MONO:
    JSR     VOICE_REMOVE_FIND_VOICE_WITH_KEY
    TSTA
    BEQ     .END_VOICE_REMOVE

; In monophonic mode, the associated entry in the voice event buffer is
; completely cleared.

.CLEAR_VOICE_EVENT:
    LDD     #0
    STD     0,x

; Ensure that the number of voices is valid before decrementing it.
    TST     M_MONO_ACTIVE_VOICE_COUNT
    BEQ     .END_VOICE_REMOVE

.IS_THIS_LAST_ACTIVE_VOICE?:
    DEC     M_MONO_ACTIVE_VOICE_COUNT
    BNE     .LEGATO_ACTIVE

.IS_SUSTAIN_PEDAL_ACTIVE?:
    LDAA    <M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_SUSTAIN_ACTIVE
    BNE     .SUSTAIN_PEDAL_ACTIVE
    LDAA    #4
    STAA    M_VOICE_PITCH_EG_CURR_STEP

; Write 'Key Off' event to EGS.
    LDAB    #2
    STAB    P_EGS_VOICE_EVENTS

.END_VOICE_REMOVE:
    RTS

.SUSTAIN_PEDAL_ACTIVE:
    LDAA    #1
    STAA    <M_MONO_SUSTAIN_PEDAL_ACTIVE
    RTS

; Since there's still another voice active after removing this one, the
; following section deals with finding the pitch of the 'last' active key,
; and depending on the legato direction, finding the lowest, or highest
; note remaining, and setting its pitch as the target pitch for the
; monophonic voice.
; This will cause the synth's legato/portamento to transition towards this
; pitch in the 'PORTA_PROCESS' subroutine.

.LEGATO_ACTIVE:
    LDAA    <M_LEGATO_DIRECTION
    BNE     .LEGATO_HIGH

.LEGATO_LOW:
    JSR     VOICE_REMOVE_FIND_ACTIVE_KEY_EVENT
    JSR     VOICE_REMOVE_MONO_FIND_LOWEST_KEY
    BRA     .STORE_LEGATO_TARGET_PITCH

.LEGATO_HIGH:
    JSR     VOICE_REMOVE_FIND_ACTIVE_KEY_EVENT
    JSR     VOICE_REMOVE_MONO_FIND_HIGHEST_KEY

.STORE_LEGATO_TARGET_PITCH:
    LDAB    <M_NOTE_KEY_LAST

; Add the patch transpose value, and subtract 24 to take unsigned transpose
; range into account.
    ADDB    M_PATCH_CURRENT_TRANSPOSE
    SUBB    #24

; Now that the legato target key has been found, and the pitch computed,
; set the 'target pitch' of the monophonic voice to this value.
    JSR     VOICE_CONVERT_NOTE_TO_PITCH
    BSR     VOICE_ADD_MONO_SET_TARGET_PITCH

.VOICE_REMOVE_IS_PORTA_RATE_MAX?:
    LDAA    <M_PORTA_RATE_INCREMENT
    CMPA    #$FF
    BEQ     .MONO_END_PORTA_PEDAL_INACTIVE

.VOICE_REMOVE_IS_PORTA_MODE_FINGERED?:
    TST     M_PORTA_MODE
    BEQ     .MONO_END_PORTA_PEDAL_ACTIVE

.IS_PORTA_SWITCH_ACTIVE?:
    LDAA    <M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_PORTAMENTO_ACTIVE
    BEQ     .MONO_END_PORTA_PEDAL_INACTIVE

.MONO_END_PORTA_PEDAL_ACTIVE:
    RTS

.MONO_END_PORTA_PEDAL_INACTIVE:
    JMP     VOICE_ADD_MONO_CLEAR_PORTA_PITCH


; ==============================================================================
; VOICE_REMOVE_FIND_VOICE_WITH_KEY
; ==============================================================================
; LOCATION: 0xD69F
;
; Searches each word-length entry in the voice status buffer to find an entry
; matching the current key.
;
; RETURNS:
; * ACCA: The match, or zero if not found.
; * ACCB: The voice number the match was found in, or zero if not found.
; * IX:   A pointer to the location in the voice event buffer.
;
; ==============================================================================

VOICE_REMOVE_FIND_VOICE_WITH_KEY:
    LDAB    #16
    LDX     #M_VOICE_STATUS

.VOICE_REMOVE_KEY_LOOP:
    LDAA    <M_NOTE_KEY
    CMPA    0,x
    BEQ     .IF_FOUND
    INX
    INX
    DECB
    BNE     .VOICE_REMOVE_KEY_LOOP              ; If ACCB > 0, loop.

.VOICE_WITH_KEY_NOT_FOUND:
    CLRA
    RTS

.IF_FOUND:
    LDAA    0,x
    RTS


; ==============================================================================
; VOICE_REMOVE_FIND_ACTIVE_KEY_EVENT
; ==============================================================================
; LOCATION: 0xD6B4
;
; DESCRIPTION:
; Searches through the 'Voice Status Buffer', searching for the first entry with
; a non-cleared 'Note' field. This is used during the process of removing a
; voice when the synth is in monophonic mode.
;
; MEMORY USED:
; * 0x90:   The found entry is stored here.
;
; RETURNS:
; * ACCB: The voice number where the entry was found, or zero if not found.
;
; ==============================================================================

VOICE_REMOVE_FIND_ACTIVE_KEY_EVENT:
    LDAB    #16
    LDX     #M_VOICE_STATUS

.FIND_LAST_KEY_LOOP:
    LDAA    0,x
    BNE     .ENTRY_NON_ZERO
    INX
    INX
    DECB
    BNE     .FIND_LAST_KEY_LOOP                 ; If B > 0, loop.

.ACTIVE_KEY_EVENT_NOT_FOUND:
    RTS

.ENTRY_NON_ZERO:
    BSR     VOICE_REMOVE_MONO_STORE_LEGATO_NOTE
    INX
    INX
    RTS


; ==============================================================================
; VOICE_REMOVE_MONO_FIND_HIGHEST_KEY
; ==============================================================================
; LOCATION: 0xD6C8
;
; DESCRIPTION:
; Searches through the 'Voice Events' buffer searching the active voice event
; with the highest key number.
; This is used when removing a voice in monophonic mode.
;
; ==============================================================================

VOICE_REMOVE_MONO_FIND_HIGHEST_KEY:
    DECB
    BNE     .FIND_HIGHEST_IS_VOICE_EVENT_CLEAR?
    RTS

.FIND_HIGHEST_IS_VOICE_EVENT_CLEAR?:
    LDAA    0,x
    BEQ     .FIND_HIGHEST_KEY_LOOP_INCREMENT

; If the current entry's key number is higher than the presently stored
; entry, store this key number instead.

.IS_NOTE_HIGHER?:
    SUBA    <M_NOTE_KEY_LAST
    BMI     .FIND_HIGHEST_KEY_LOOP_INCREMENT
    BSR     VOICE_REMOVE_MONO_SET_LEGATO_NOTE

.FIND_HIGHEST_KEY_LOOP_INCREMENT:
    INX
    INX
    BRA     VOICE_REMOVE_MONO_FIND_HIGHEST_KEY


; ==============================================================================
; VOICE_REMOVE_MONO_FIND_LOWEST_KEY
; ==============================================================================
; LOCATION: 0xD6DA
;
; DESCRIPTION:
; Searches through the 'Voice Events' buffer searching the active voice event
; with the lowest key number.
; This is used when removing a voice in monophonic mode.
;
; ==============================================================================

VOICE_REMOVE_MONO_FIND_LOWEST_KEY:
    DECB
    BNE     .FIND_LOWEST_IS_VOICE_EVENT_CLEAR?

.END_VOICE_REMOVE_MONO_FIND_LOWEST_KEY:
    RTS

.FIND_LOWEST_IS_VOICE_EVENT_CLEAR?:
    LDAA    0,x
    BEQ     .FIND_LOWEST_KEY_INCREMENT_INDEX

; If the current entry's key number is lower than the presently stored
; entry, store this key number instead.

.IS_NOTE_LOWER?:
    SUBA    <M_NOTE_KEY_LAST
    BPL     .FIND_LOWEST_KEY_INCREMENT_INDEX
    BSR     VOICE_REMOVE_MONO_SET_LEGATO_NOTE

.FIND_LOWEST_KEY_INCREMENT_INDEX:
    INX
    INX
    BRA     VOICE_REMOVE_MONO_FIND_LOWEST_KEY


; ==============================================================================
; VOICE_REMOVE_MONO_SET_LEGATO_NOTE
; ==============================================================================
; LOCATION: 0xD6EC
;
; DESCRIPTION:
; Loads the legato 'target' note from IX, and stores it.
;
; Registers:
; * IX:   The legato 'target' note is loaded from here.
;
; MEMORY USED:
; * 0x90:   The legato 'target' entry is stored here.
;
; ==============================================================================

VOICE_REMOVE_MONO_SET_LEGATO_NOTE:
    LDAA    0,x                                 ; Falls-through below.


; ==============================================================================
; VOICE_REMOVE_MONO_STORE_LEGATO_NOTE
; ==============================================================================
; LOCATION: 0xD6EE
;
; DESCRIPTION:
; Stores the legato note.
; This is also used when searching for the first active key event.
;
; MEMORY USED:
; * 0x90:   The legato 'target' entry is stored here.
;
; ==============================================================================

VOICE_REMOVE_MONO_STORE_LEGATO_NOTE:
    STAA    <M_NOTE_KEY_LAST
    RTS


; ==============================================================================
; VOICE_ADD_CHECK_KEY_EVENT_COUNT
; ==============================================================================
; LOCATION: 0xD6F1
;
; DESCRIPTION:
; Tests whether there is an inactive voice available to use for the new note
; being added.
;
; ==============================================================================

VOICE_ADD_CHECK_KEY_EVENT_COUNT:
    LDAA    #16

; This variable is the index into the key event array.
    LDAB    <M_KEY_EVENT_CURRENT

.INACTIVE_VOICE_SEARCH_LOOP:
    LDX     #M_KEY_EVENT_BUFFER
    ABX
    TIM     #KEY_EVENT_ACTIVE, 0,x
    BEQ     .SETUP_LOOP_2
    INCB
    ANDB    #%1111                              ; B = B % 16.
    DECA
    BNE     .INACTIVE_VOICE_SEARCH_LOOP         ; If A > 0, loop.
    RTS

.SETUP_LOOP_2:
    STAB    <M_KEY_EVENT_CURRENT
    LDAA    #16
    LDAB    <M_KEY_EVENT_CURRENT

; @TODO: Why does this loop twice?

.INACTIVE_VOICE_SEARCH_LOOP_2:
    INCB
    ANDB    #%1111                              ; B = B % 16.
    LDX     #M_KEY_EVENT_BUFFER
    ABX
    TIM     #KEY_EVENT_ACTIVE, 0,x
    BEQ     .ADD_KEY_EVENT
    DECA
    BNE     .INACTIVE_VOICE_SEARCH_LOOP_2       ; If A > 0, loop.
    BRA     *+2

.ADD_KEY_EVENT:
    LDX     #M_KEY_EVENT_BUFFER
    LDAB    <M_KEY_EVENT_CURRENT
    ABX
    LDAA    <M_NOTE_KEY
    ORAA    #KEY_EVENT_ACTIVE
    STAA    0,x

.INCREMENT_CURR_VOICE:
    LDAB    <M_KEY_EVENT_CURRENT
    INCB
    ANDB    #%1111                              ; Voice_Current % 16.
    STAB    <M_KEY_EVENT_CURRENT
    JSR     VOICE_ADD
    RTS


; ==============================================================================
; VOICE_REMOVE_KEY
; ==============================================================================
; LOCATION: 0xD733
;
; DESCRIPTION:
; Searches through the 'Key Event' buffer for an entry where the note matches
; the provided key code. If it is found, the key event is set as inactive,
; and the voice is removed.
; This subroutine is called when a MIDI 'Note Off' event is received.
;
; ARGUMENTS:
; Memory:
; * 0x81:   The note key to search for.
;
; ==============================================================================

VOICE_REMOVE_KEY:
    LDAB    #16
    LDAA    <M_NOTE_KEY
    ORAA    #KEY_EVENT_ACTIVE
    LDX     #M_KEY_EVENT_BUFFER

.ACTIVE_VOICE_SEARCH_LOOP:
    CMPA    0,x
    BEQ     .ACTIVE_VOICE_FOUND
    INX
    DECB
    BNE     .ACTIVE_VOICE_SEARCH_LOOP           ; If ACCB > 0, loop.
    RTS

; Mask the active voice flag bit.

.ACTIVE_VOICE_FOUND:
    AIM     #~KEY_EVENT_ACTIVE, 0,x
    JSR     VOICE_REMOVE
    RTS


; ==============================================================================
; VOICE_DEACTIVATE_ALL
; ==============================================================================
; LOCATION: 0xD74C
;
; DESCRIPTION:
; Deactivates all active key events.
;
; ==============================================================================

VOICE_DEACTIVATE_ALL:
    CLRB

.DEACTIVATE_VOICE_LOOP:
    STAB    <M_KEY_EVENT_CURRENT
    LDX     #M_KEY_EVENT_BUFFER
    ABX

.DEACTIVATE_ALL_IS_KEY_EVENT_ACTIVE?:
    TIM     #KEY_EVENT_ACTIVE, 0,x
    BEQ     .DEACTIVATE_VOICE_LOOP_INCREMENT
    LDAB    0,x

; Load the note from the 'Key Event' buffer, and mask the 'active' bit in
; the entry to leave only the 'note' portion of the entry.
    ANDB    #%1111111
    STAB    <M_NOTE_KEY
    BSR     VOICE_REMOVE_KEY

.DEACTIVATE_VOICE_LOOP_INCREMENT:               ; Restore iterator.
    LDAB    <M_KEY_EVENT_CURRENT
    INCB
    CMPB    #16
    BNE     .DEACTIVATE_VOICE_LOOP              ; If B < 16, loop.
    CLR     M_KEY_EVENT_CURRENT
    RTS


; ==============================================================================
; JUMP_TO_RELATIVE_OFFSET
; ==============================================================================
; LOCATION: 0xD76B
;
; DESCRIPTION:
; This subroutine pops a reference to a jump-table from the subroutine's
; return pointer on the stack, then unconditionally 'jumps' to the relative
; offset in the entry associated with the number in ACCB.
; The table is stored in a two-byte format (Entry Number):(Relative Offset).
; Once the correct entry in the table has been found, the relative offset is
; added to the pointer in IX, and then jumped to.
; This is effectively a switch statement, with a relative jump.
;
; ARGUMENTS:
; Registers:
; * IX:   The 'return address' is popped off the stack into IX.
; * ACCB: The 'number' of the entry to jump to.
;
; ==============================================================================

JUMP_TO_RELATIVE_OFFSET:
    PULX                                        ; Restore return addr into IX.

; If the current jump table entry number is '0', the end of the jump table has
; been reached, so exit.

.IS_END_OF_JUMP_TABLE?:
    TST     1,x
    BEQ     .END_JUMP_TO_RELATIVE_OFFSET

; If the value in the entry 'index' is higher than the value in ACCB being
; tested, jump to the relative offset.
    CMPB    1,x
    BCS     .END_JUMP_TO_RELATIVE_OFFSET
    INX
    INX
    BRA     .IS_END_OF_JUMP_TABLE?

; Load the relative offset, add it to the pointer in IX, and then jump.

.END_JUMP_TO_RELATIVE_OFFSET:
    PSHB
    LDAB    0,x
    ABX
    PULB
    JMP     0,x
    ASLA
    LDAB    #165
    MUL
    RTS


; ==============================================================================
; PATCH_LOAD_QUANTISE_VALUE
; ==============================================================================
; LOCATION: 0xD784
;
; DESCRIPTION:
; Quantises a particular patch value from its serialised range of 0-99, to its
; scaled 16-bit representation. Returning the result in ACCD.
; e.g.
;   Quantise(50) = 33000
;   Quantise(99) = 65340
;
; ARGUMENTS:
; Registers:
; * ACCA: The value to quantise.
;
; RETURNS:
; * ACCD: The 16-bit quantised value.
;
; ==============================================================================

PATCH_LOAD_QUANTISE_VALUE:
    ASLA
    LDAB    #165
    MUL
    ASLB
    ROLA
    RTS


; ==============================================================================
; CONVERT_INT_TO_STR
; ==============================================================================
; LOCATION: 0xD78B
;
; DESCRIPTION:
; Splits up a number, placing the individual digits into the memory offsets
; starting from 0x217F and working backwards in powers of ten.
; For example, if the number passed to the function was '1724':
; - 0x217C: 0x4
; - 0x217D: 0x2
; - 0x217E: 0x7
; - 0x217F: 0x1
;
; ARGUMENTS:
; Registers:
; * ACCD: The number to convert.
;
; MEMORY USED:
; * 0x217F: The first character of the converted string.
;
; ==============================================================================

CONVERT_INT_TO_STR:
    PSHX
    STD     <$B4
    LDX     #TABLE_POWERS_OF_TEN
    STX     <$B6
    LDAB    #4
    STAB    $217B                               ; Iterator = 4.
    LDD     <$B4

.LOOP_RESET:
    CLR     $2180

.CONVERT_INT_TO_STR_LOOP:
    LDX     <$B6
    SUBD    0,x
    BCS     .ITERATE
    INC     $2180
    BRA     .CONVERT_INT_TO_STR_LOOP

.ITERATE:
    LDX     <$B6
    ADDD    0,x
    INX
    INX
    STX     <$B6
    STD     $2181
    LDAA    $2180
    LDAB    $217B
    LDX     #$217B
    ABX
    STAA    0,x
    LDD     $2181
    DEC     $217B
    BNE     .LOOP_RESET                         ; If *(0x217B) > 0, loop.

.END_CONVERT_INT_TO_STR:
    PULX
    RTS

TABLE_POWERS_OF_TEN:
    FDB 1000
    FDB 100
    FDB 10
    FDB 1


; ==============================================================================
; BATTERY CHECK
; ==============================================================================
; LOCATION: 0xD7D1
;
; DESCRIPTION:
; Checks battery voltage against a constant. Prints an error
; message if too low.
;
; ==============================================================================

BATTERY_CHECK:
    LDAA    #110
    SUBA    M_BATTERY_VOLTAGE
    BPL     .PRINT_LOW_BTTRY_MSG
    RTS

.PRINT_LOW_BTTRY_MSG:
    LDX     #aChangeBattery
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; VOICE_CONVERT_NOTE_TO_PITCH
; ==============================================================================
; LOCATION: 0xD7DF
;
; DESCRIPTION:
; This is the main subroutine responsible for converting the key number value
; shared by the keyboard controller, and MIDI input, to the frequency value
; used internally by the EGS chip. The resulting frequency value is represented
; in logarithmic format, with 1024 values per octave.
;
; The conversion works by using the note number as an index into a lookup
; table, from which the most-significant byte of the pitch is retrieved. The
; lower byte is then created by shifting this value.
;
; The mechanism used in this subroutine is referenced in patent US4554857:
; "It is known in the art that a frequency number expressed in logarithm can
; be obtained by frequently adding data of two low bits of the key code KC to
; lower bits (e.g., Japanese Patent Preliminary Publication No. 142397/1980)."
;
; ARGUMENTS:
; Registers:
; * ACCB: The note number value to get the pitch value of.
;
; MEMORY USED:
; * 0x9D: The two-byte (14-bit) key frequency value is stored here.
;
; ==============================================================================

VOICE_CONVERT_NOTE_TO_PITCH:
    LDX     #TABLE_KEY_PITCH
    ABX
    LDAA    0,x
    STAA    <M_KEY_PITCH
    LDAB    #3                                  ; Loop index = 3.
    ANDA    #%11
    STAA    <M_KEY_PITCH_LOW

.CONVERT_NOTE_TO_PITCH_LOOP_START:
    ORAA    <M_KEY_PITCH_LOW
    ASLA
    ASLA
    DECB
    BNE     .CONVERT_NOTE_TO_PITCH_LOOP_START   ; If B > 0, loop.

; Truncate to the final 14-bit value.
    ANDA    #%11111100
    STAA    <M_KEY_PITCH_LOW
    RTS


; ==============================================================================
; CRT_READ_WRITE_ALL
; ==============================================================================
; LOCATION: 0xD7F9
;
; DESCRIPTION:
; Reads, or writes all patches to/from the cartridge.
;
; ARGUMENTS:
; Memory:
; * 0xF9:   The base address in RAM to write to/from.
; * 0xFB:   The base address on the cartridge.
; * 0x2178: The option flags for this function:
;           When MSB is set, this indicates a WRITE operation.
;
; MEMORY USED:
; * 0x8B:   Cleared on completed WRITE operation.
;           MSB set on finished READ operation.
;
; ==============================================================================

CRT_READ_WRITE_ALL:
    TST     M_CRT_RW_FLAGS
    BPL     .IS_CRT_READ_OPERATION?             ; Branch if bit 7 is set.

.CRT_RW_LOOP:
    TST     M_CRT_RW_FLAGS
    BPL     .IS_CRT_READ_OPERATION?
    CLR     M_CRT_FORMAT_PATCH_INDEX
    BSR     PATCH_WRITE_TO_CRT

; If carry bit set, an error has occurred.
    BCS     .COPY_PATCH_ERROR
    BRA     .FINISHED?

.IS_CRT_READ_OPERATION?:
    JSR     CRT_READ_PATCH

.FINISHED?:
    INC     M_CRT_RW_FLAGS
    LDAA    M_CRT_RW_FLAGS

; Branch if RW_FLAGS & 32 = 0.
; The RW flags register stores the loop index in the lower 5 bits.
    BITA    #%100000
    BEQ     .CRT_RW_LOOP
    TST     M_CRT_RW_FLAGS
    BPL     .END_READ_OPERATION
    CLRA
    BRA     .END_CRT_READ_WRITE_ALL

.END_READ_OPERATION:
    LDAA    #128

.END_CRT_READ_WRITE_ALL:
    STAA    <M_CRT_SAVE_LOAD_FLAGS
    LDX     #aCompleted
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.COPY_PATCH_ERROR:
    LDX     #aWriteError
    CLR     M_CRT_SAVE_LOAD_FLAGS
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

aCompleted:          FCC " COMPLETED", 0


; ==============================================================================
; PATCH_WRITE_TO_CRT
; ==============================================================================
; LOCATION: 0xD83F
;
; DESCRIPTION:
; Copies a patch (128 bytes) from the address in pointer 0xF9, to the
; cartridge memory pointed at by 0xFB.
; The carry bit is set if an error condition has occurred.
;
; ARGUMENTS:
; Memory:
; * 0xF9: Origin ptr.
; * 0xFB: Destination ptr.
;
; MEMORY USED:
; * 0x2179: Loop iterator.
;
; RETURNS:
; * The carry flag is set to indicate an error condition.
;
; ==============================================================================

PATCH_WRITE_TO_CRT:
    LDAA    #128
    STAA    M_CRT_WRITE_PATCH_COUNTER

CRT_COPY_BYTES_LOOP?:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x

; Every byte stored on the cartridge is maximum 7bits.
    ANDA    #%1111111

; Load write value to ACCA, and increment origin ptr.
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    BSR     CRT_WRITE_BYTE
    BCS     CRT_COPY_END
    INX
    STX     <M_COPY_DEST_PTR
    DEC     M_CRT_WRITE_PATCH_COUNTER
    BNE     CRT_COPY_BYTES_LOOP?

CRT_COPY_END:
    RTS


; ==============================================================================
; CRT_WRITE_BYTE
; ==============================================================================
; LOCATION: 0xD85C
;
; DESCRIPTION:
; Writes the byte in ACCA to the memory address on the cartridge in IX.
; Tests whether the destination byte is equal to the byte to be written.
; If so, no write is performed. After the byte is written, it will test that
; the byte can be successfully read back.
;
; ARGUMENTS:
; Registers:
; * IX:   The address in cartidge memory to write to.
; * ACCA: The byte to be written.
;
; RETURNS:
; * The carry flag is set to indicate an error condition.
;
; ==============================================================================

CRT_WRITE_BYTE:
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x

; Read the byte at this address in the cartridge, if it's already
; equal to the byte to be written, exit.
    CMPA    0,x
    BEQ     .EXIT_SUCCESS

; Write the data byte to the cartridge. The data value is then checked
; to see if it is 0xFF. If it is, a delay is introduced, then a
; graceful exit. Otherwise, the written data is tested to ensure it was
; correctly stored.

.WRITE_BYTE_TO_CRT:
    STAA    0,x
    CMPA    #$FF
    BNE     .TEST_WRITTEN_BYTE
    JSR     DELAY_450_CYCLES
    RTS

.TEST_WRITTEN_BYTE:
    LDAB    #100

; This seems to be a test-read after each byte written.
; It appears to delay for one clock cycle, then attempt to re-read
; the written contents. This is then compared with ACCA.
; If it is equal, exit successfully.
; If not equal after 100 iterations, exit with a fail flag set.

.CRT_WRITE_BYTE_TEST_LOOP:
    JSR     DELAY_7_CYCLES
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x

; Compare this byte at dest addr to ACCA. If equal, go to good exit.
    CMPA    0,x
    BEQ     .EXIT_SUCCESS

; Decrement the counter until it reaches zero. Or until the data can
; be successfully read back.
    DECB
    BEQ     .EXIT_FAILURE
    BRA     .CRT_WRITE_BYTE_TEST_LOOP

; Clear the carry bit to 1 to return a success condition, and exit.

.EXIT_SUCCESS:
    CLC
    RTS

; Set the carry bit to 1 to return an error condition, and exit.

.EXIT_FAILURE:
    SEC
    RTS

aWriteError:         FCC " WRITE ERROR !", 0


; ==============================================================================
; CRT_READ_PATCH
; ==============================================================================
; LOCATION: 0xD89F
;
; DESCRIPTION:
; Reads a patch(128 bytes) from the cartidge memory address stored in the
; pointer at 0xFB, to the memory location in RAM stored in the pointer
; at 0xF9.
;
; ARGUMENTS:
; Memory:
; * 0xF9:   The destination address, in RAM.
; * 0xFB:   The source address, on the cartridge.
;
; ==============================================================================

CRT_READ_PATCH:
    LDAA    #128

; 0x4000 + (patch_num * 128) should be in 0xFB.

.CRT_READ_PATCH_LOOP:
    LDX     <M_COPY_DEST_PTR
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x
    TST     0,x
    LDAB    0,x
    ANDB    #%1111111                           ; Remove MSB.
    INX
    STX     <M_COPY_DEST_PTR

; Store ACCB at pointer 0xF9, Increment 0xF9 and store.
    LDX     <M_COPY_SRC_PTR
    STAB    0,x
    INX
    STX     <M_COPY_SRC_PTR
    DECA
    BNE     .CRT_READ_PATCH_LOOP                ; If ACCA > 0, loop.
    RTS


; ==============================================================================
; DELAY
; ==============================================================================
; LOCATION: 0xD8BF
;
; DESCRIPTION:
; Creates an artificial 'delay' in the system by pushing, and pulling from the
; stack repeatedly.
; The loop within this function is called by other delay functions, with
; arbitrary delay lengths, set via the ACCB register.
;
; ==============================================================================

DELAY:
    PSHA
    PSHB

; This function only delays for a single 'cycle'.
    LDAB    #1

DELAY_LOOP_START:
    PSHX
    PULX
    DECB
    BNE     DELAY_LOOP_START                    ; If ACCB > 0, loop.
    PULB
    PULA
    RTS


; ==============================================================================
; MIDI_PROCESS_DELAY
; ==============================================================================
; LOCATION: 0xD8CB
;
; DESCRIPTION:
; Arbitrary delay subroutine used during the MIDI processing functions.
;
; ==============================================================================

MIDI_PROCESS_DELAY:
    PSHA
    PSHB
    LDAB    #3
    BRA     DELAY_LOOP_START


; ==============================================================================
; DELAY_7_CYCLES
; ==============================================================================
; DESCRIPTION:
; Delays for 7 'cycles'.
;
; ==============================================================================

DELAY_7_CYCLES:
    PSHA
    PSHB
    LDAB    #7
    BRA     DELAY_LOOP_START


; ==============================================================================
; DELAY_90_CYCLES
; ==============================================================================
; DESCRIPTION:
; Delays for 90 'cycles'.
;
; ==============================================================================

DELAY_90_CYCLES:
    PSHA
    PSHB

; Set the delay function to loop for 90 cycles.
    LDAB    #90
    BRA     DELAY_LOOP_START


; This appears to be unused code. It was most likely part of a delay
; subroutine that ended up not being used. Although the code appears
; to be valid, it is not referenced in the ROM.
    PSHB
    LDAB    #5

.DELAY_450_LOOP:
    BSR     DELAY_90_CYCLES
    DECB
    BNE     .DELAY_450_LOOP                     ; If b > 0, loop.
    PULB                                        ; Restore ACCB.
    RTS


; ==============================================================================
; DELAY_450_CYCLES
; ==============================================================================
; DESCRIPTION:
; Delays 450 'cycles'.
; This subroutine calls the 'delay' subroutine 15 times, with a delay iteration
; of 90.
;
; ==============================================================================

DELAY_450_CYCLES:
    PSHB
    LDAB    #15
    BRA     .DELAY_450_LOOP


; ==============================================================================
; PATCH_COPY_FROM_COMPARE
; ==============================================================================
; DESCRIPTION:
; Copies patch data from the synth's 'Compare Buffer' into the 'Edit Buffer'.
;
; ==============================================================================

PATCH_COPY_FROM_COMPARE:
    LDX     #M_PATCH_COMPARE_BUFFER
    STX     <M_COPY_SRC_PTR
    LDX     #M_PATCH_CURRENT_BUFFER
    STX     <M_COPY_DEST_PTR
    LDAB    #155
    JMP     MEMCPY


; ==============================================================================
; MAIN_PROCESS_SUSTAIN_PEDAL
; ==============================================================================
; DESCRIPTION:
; Processes any change in the sustain pedal's status.
; If the sustain pedal is currently switched off, this subroutine will
; iterate over all active voices, checking if they currently had sustain
; active. In the case sustain was active, the flag is cleared, their pitch EG
; step is set to release, and a 'Voice Off' event for this voice is sent to
; the EGS to indicate it is now ending.
;
; ==============================================================================

MAIN_PROCESS_SUSTAIN_PEDAL:
    LDAA    M_PEDAL_INPUT_STATUS

; Check if the sustain pedal is currently inactive.
    BITA    #PEDAL_STATUS_SUSTAIN_ACTIVE
    BNE     .END_MAIN_PROCESS_SUSTAIN_PEDAL

.SUSTAIN_PEDAL_OFF:
    LDAA    M_MONO_POLY
    BNE     .SYNTH_IS_MONO

.SUSTAIN_PDL_SYNTH_IS_POLY:
    LDX     #M_VOICE_STATUS
    LDAB    #2

; Tests each voice in the 'Voice Event' buffer, checking whether the sustain
; flag was active. If it was, the sustain flag is cleared.

.TEST_VOICE_LOOP:
    LDAA    1,x

; Test whether sustain is active for the current voice event.
    BITA    #1
    BEQ     .PROCESS_SUSTAIN_PDL_LOOP_INCREMENT

; The following subroutine clears bit 1 in this voice event entry to set
; sustain for this key event as being finshed.
; ACCB is then stored in the EGS' 'Voice Event' register.
; ACCB starts at 2, which is the bitmask value for a 'KEY OFF' event.
; ACCB is then incremented by 4, which will increment the voice number
; (Bits 2-5) without changing the bitmask for 'KEY OFF'.
; A value of '4' is then loaded to the 'Pitch EG Current Step' register to
; indicate the note is now in its release phase.
    ANDA    #%11111110
    STAA    1,x
    STAB    P_EGS_VOICE_EVENTS
    PSHB
    PSHX

.SET_PITCH_EG_STEP:
    LDX     #M_VOICE_PITCH_EG_CURR_STEP
    LSRB
    LSRB
    ABX
    LDAB    #4
    STAB    0,x
    PULX
    PULB

.PROCESS_SUSTAIN_PDL_LOOP_INCREMENT:
    INX
    INX

; Increment ACCB by 4 to increment the current voice number.
    ADDB    #4
    CMPB    #66
    BNE     .TEST_VOICE_LOOP

.END_MAIN_PROCESS_SUSTAIN_PEDAL:
    RTS

; Check if the sustain pedal was previously active. If so, then
; clear the appropriate flag, and send a 'KEY OFF' event for Voice#0
; to the EGS voice events register.

.SYNTH_IS_MONO:
    LDAA    <M_MONO_SUSTAIN_PEDAL_ACTIVE
    BEQ     .END_MAIN_PROCESS_SUSTAIN_PEDAL
    LDAB    #2
    STAB    P_EGS_VOICE_EVENTS
    CLR     M_MONO_SUSTAIN_PEDAL_ACTIVE
    LDAB    #4
    STAB    M_VOICE_PITCH_EG_CURR_STEP
    RTS


; ==============================================================================
; PATCH_WRITE_TO_INT
; ==============================================================================
; LOCATION: 0xD942
;
; DESCRIPTION:
; Writes the 'Patch Edit Buffer' to internal memory, in the entry provided.
;
; ARGUMENTS:
; Registers:
; * ACCA: The internal memory entry to write the patch in (0-31).
;
;
; ==============================================================================

PATCH_WRITE_TO_INT:
    LDAB    #128
    MUL
    ADDD    #M_EXTERNAL_RAM_START               ; Falls-through below.


; ==============================================================================
; PATCH_SERIALISE
; ==============================================================================
; LOCATION: 0xD948
;
; DESCRIPTION:
; Serialises a patch from the synth's patch 'Edit Buffer' to a
; specified address in RAM. This converts the patch in memory to the abridged
; format used when storing the patch. This subroutine is used when saving a
; patch.
; Refer to the following for the patch format:
; https://github.com/asb2m10/dexed/blob/master/Documentation/sysex-format.txt
;
; ARGUMENTS:
; Registers:
; * ACCD: The location in memory to serialise the patch to.
;
; MEMORY USED:
; * 0xAB:   Iterator.
; * 0xAD:   Temp register.
; * 0xAE:   Temp register.
; * 0xFB:   Dest ptr.
; * 0xF9:   Origin ptr.
;
; ==============================================================================

PATCH_SERIALISE:
    STD     <M_COPY_DEST_PTR
    LDX     #M_PATCH_CURRENT_BUFFER
    LDAB    #6
    STAB    <$AB
    STX     <M_COPY_SRC_PTR

; Copy the first 11 bytes.

.SERIALISE_COPY_OPERATOR_LOOP:
    LDAB    #11
    JSR     MEMCPY

.COPY_KBD_SCALE_CURVES:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STAA    <$AD

; Load the 'Right Curve' value, shift this value left twice, and combine to
; create the serialised format.
    LDAA    0,x
    ASLA
    ASLA
    ADDA    <$AD

; Increment source pointer.
    INX
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Copy 'Keyboard Rate Scale', and 'Oscillator detune'.

.COPY_KBD_RATE_SCALING:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    STAA    <$AD

; Load the Osc detune value, shift left three times, and combine.
    LDAA    7,x
    ASLA
    ASLA
    ASLA
    ADDA    <$AD

; Increment source pointer.
    INX
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Copy 'Amp Mod Sensitivity', and 'Key Velocity Sensitivity'.

.COPY_AMP_MOD_SENS:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STAA    <$AD

; Load the 'Key Velocity Sens' value, shift left three times, and combine.
    LDAA    0,x
    INX
    ASLA
    ASLA
    ADDA    <$AD
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Copy 'Output Level'.

.COPY_OUTPUT_LEVEL:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x

; Increment source pointer.
    INX
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Copy 'Coarse Frequency', and 'Oscillator Mode'.

.COPY_FREQ_COARSE_OSC_MODE:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STAA    <$AD

; Load 'Coarse Frequency', shift left, and combine.
    LDAA    0,x
    INX
    ASLA
    ADDA    <$AD
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

.COPY_FREQ_FINE:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x

; Increment source pointer.
    INX
    INX
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

.SERIALISE_DECREMENT_LOOP_INDEX:
    DEC     $AB
    BEQ     .SERIALISE_COPY_PATCH_VALUES        ; If 0xAB > 0, loop.
    JMP     .SERIALISE_COPY_OPERATOR_LOOP

; Copy the 8 pitch EG values, then copy the algorithm value.

.SERIALISE_COPY_PATCH_VALUES:
    LDAB    #8
    JSR     MEMCPY

; Copy 'Feedback', and 'Key Sync'.
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Load value.
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STAA    <$AD

; Load value, increment origin pointer, shift left 3 times, and combine.
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    ASLA
    ASLA
    ASLA
    ADDA    <$AD

; Store value and increment destination pointer.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Copy the LFO values:
; * LFO Speed.
; * LFO Delay.
; * LFO Pitch Mod Depth.
; * LFO Amp Mod Depth.

.COPY_LFO_VALUES:
    LDAB    #4
    JSR     MEMCPY

; Copy, and combine into one byte:
; * LFO Sync.
; * LFO Wave.
; * LFO Pitch Mod Sensitivity.
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STAA    <$AD

; Load value, shift left 1 and store in 0xAE.
    LDAA    0,x
    INX
    ASLA
    STAA    <$AE

; Load value, shift left 4. Combine with 0xAD.
    LDAA    0,x
    INX
    ASLA
    ASLA
    ASLA
    ASLA

; Combine 0xAD with 0xAE.
    ADDA    <$AD
    ADDA    <$AE

; Store incremented origin ptr.
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR

; Store value, and increment destination pointer.
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Load value, and increment origin pointer.
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR

; Store value, and increment dest ptr.
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Copy char* PATCH_NAME[10].

.SERIALISE_COPY_PATCH_NAME:
    LDAB    #10
    JMP     MEMCPY


; ==============================================================================
; PATCH_LOAD_FROM_INT
; ==============================================================================
; LOCATION: 0xDA3C
;
; DESCRIPTION:
; Loads a patch from internal memory into the synth's patch edit buffer.
; Loads the patch number in ACCA.
;
; ARGUMENTS:
; Registers:
; * ACCA: The patch number to load.
;
; ==============================================================================

PATCH_LOAD_FROM_INT:
    LDAB    #128

; Compute the index into patch memory.
    MUL

; Falls-through to patch deseralise.
    ADDD    #M_EXTERNAL_RAM_START


; ==============================================================================
; PATCH_DESERIALISE
; ==============================================================================
; LOCATION: 0xDA42
;
; DESCRIPTION:
; Deserialises, and copies a patch from the address in ACCD to 0x2000.
; Refer to the following for the patch format:
; https://github.com/asb2m10/dexed/blob/master/Documentation/sysex-format.txt
;
; For additional, more specific documentation, refer to the 'PATCH_SERIALISE'
; subroutine.
;
; ARGUMENTS:
; Registers:
; * ACCD: The address to deserialise the patch data from.
;
; MEMORY USED:
; * 0xAB:   Iterator.
; * 0xAD:   Temp register.
; * 0xAE:   Temp register.
; * 0xFB:   Dest ptr.
; * 0xF9:   Origin ptr.
;
; ==============================================================================

PATCH_DESERIALISE:
    STD     <M_COPY_SRC_PTR
    JSR     DELAY
    LDX     #M_PATCH_CURRENT_BUFFER
    STX     <M_COPY_DEST_PTR
    LDAB    #6
    STAB    <$AB

.DESERIALISE_COPY_OPERATOR_LOOP:
    LDAB    #11
    JSR     MEMCPY
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    STAA    <$AC
    ANDA    #3
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    LDAA    <$AC
    ANDA    #$C
    LSRA
    LSRA
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    STAA    <$AC
    ANDA    #7
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    LDAA    <$AC
    LSRA
    LSRA
    LSRA
    STAA    7,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    STAA    <$AC
    ANDA    #3
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    LDAA    <$AC
    LSRA
    LSRA
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    STAA    <$AC
    ANDA    #1
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    LDAA    <$AC
    LSRA
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    INX
    STX     <M_COPY_DEST_PTR
    DEC     $AB
    BEQ     .DESERIALISE_COPY_PATCH_VALUES      ; If 0xAB > 0, loop.
    JMP     .DESERIALISE_COPY_OPERATOR_LOOP

.DESERIALISE_COPY_PATCH_VALUES:
    LDAB    #8
    JSR     MEMCPY
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    STAA    <$AC
    ANDA    #7
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    LDAA    <$AC
    LSRA
    LSRA
    LSRA
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDAB    #4
    JSR     MEMCPY
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    STAA    <$AC
    ANDA    #1
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    LDAA    <$AC
    LSRA
    ANDA    #7
    STAA    0,x
    INX
    LDAA    <$AC
    LSRA
    LSRA
    LSRA
    LSRA
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

.DESERIALISE_COPY_PATCH_NAME:
    LDAB    #10
    JMP     MEMCPY


; ==============================================================================
; PATCH_COPY_TO_COMPARE
; ==============================================================================
; LOCATION: 0xDB47
;
; DESCRIPTION:
; Copies a patch from the synth's 'Edit Buffer' into the compare buffer.
;
; ==============================================================================

PATCH_COPY_TO_COMPARE:
    LDX     #M_PATCH_CURRENT_BUFFER
    STX     <M_COPY_SRC_PTR
    LDX     #M_PATCH_COMPARE_BUFFER
    STX     <M_COPY_DEST_PTR
    LDAB    #155                                ; Falls-through below to MEMCPY.


; ==============================================================================
; MEMCPY
; ==============================================================================
; LOCATION: 0xDB53
;
; DESCRIPTION:
; Copies ACCB bytes from the address in pointer 0xF9, to the address in
; pointer 0xFB.
; The pointers in 0xF9, and 0xFB are incremented with each iteration.
;
; ARGUMENTS:
; Registers:
; * ACCB: The number of bytes to copy.
;
; Memory:
; * 0xF9:   The source memory address.
; * 0xFB:   The destination memory address.
;
; ==============================================================================

MEMCPY:
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR
    DECB
    BNE     MEMCPY                              ; if b > 0, loop.
    RTS


; ==============================================================================
; PATCH_LOAD_OPERATOR_KBD_VEL_SENS
; ==============================================================================
; LOCATION: 0xDB65
;
; Parses the 'Key Velocity Sensitivity' for the currently selected operator.
; Once this value is transformed, it's stored in the global 'Op Sens' buffer.
;
; This transformation is equivalent to:
; def transform_key_vel_sens(op_kvs):
;     B = op_kvs * 32
;     A = (op_kvs << 1) | 0xF0
;     A = (~A) & 0xFF
;
;     return (A << 8) | B
;
; Values:
;  0: 3840
;  1: 3360
;  2: 2880
;  3: 2400
;  4: 1920
;  5: 1440
;  6: 960
;  7: 480
;
; ==============================================================================

PATCH_LOAD_OPERATOR_KBD_VEL_SENS:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    LDAB    #15
    ABX

; Load KEY_VEL_SENS into A.
; Multiply by 32, and push.
    LDAA    0,x
    LDAB    #32
    MUL
    PSHB

.PARSE_OP_SENS_HIGH:
    LDAA    0,x
    ASLA
    ORAA    #%11110000
    COMA

.STORE_OP_SENS:
    LDX     #M_PATCH_OP_SENS
    LDAB    M_SELECTED_OPERATOR
    ASLB
    ABX
    PULB
    STAA    0,x
    STAB    1,x
    RTS


; ==============================================================================
; PATCH_LOAD_OPERATOR_DETUNE
; ==============================================================================
; OPERATOR: 0xDB85
;
; DESCRIPTION:
; Loads operator detune values to the EGS operator detune buffer.
;
; ==============================================================================

PATCH_LOAD_OPERATOR_DETUNE:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    LDAB    #20
    ABX

; Load the current operator's detune value.
    LDAB    0,x

; The following routine reads the bitmask corresponding to this detune
; value from the associated table. Refer to this table for additional
; documentation regarding the format of these values.

.LOAD_BITMASK_FROM_TABLE:
    LDX     #TABLE_DETUNE_VALUE
    ABX
    LDAA    0,x                                 ; A = TABLE_DETUNE_VALUE[B].
    LDAB    M_SELECTED_OPERATOR
    LDX     #P_EGS_OP_DETUNE
    ABX
    STAA    0,x                                 ; Store at 0x3030[OP].
    RTS


; ==============================================================================
; EGS Operator Detune Value Table.
; These values are the operator detune values loaded to the EGS' operator
; detune buffer. They represent the possible positive and negative detune
; values.
; Bits 0..2 Represent the operator detune value (0..7), and bit 3 represents
; whether the value is positive, or negative. With this bit being set
; indicating that the value is negative.
; ==============================================================================
TABLE_DETUNE_VALUE:
    FCB $F
    FCB $E
    FCB $D
    FCB $C
    FCB $B
    FCB $A
    FCB 9
    FCB 0
    FCB 1
    FCB 2
    FCB 3
    FCB 4
    FCB 5
    FCB 6
    FCB 7


; ==============================================================================
; PATCH_COPY_OPERATOR
; ==============================================================================
; LOCATION: 0xDBAC
;
; DESCRIPTION:
; Copies the currently selected operator to the operator selected by the last
; button press in 'Edit Mode'.
;
; ARGUMENTS:
; Memory:
; * 0x209F: The currently selected operator, used as the source operator.
;
; ==============================================================================

PATCH_COPY_OPERATOR:
    BSR     PATCH_GET_PTR_TO_SELECTED_OP
    STX     <M_COPY_SRC_PTR
    LDAB    #5

; Since this subroutine always originates with a button press, this variable
; holds the selected operator.
    SUBB    M_LAST_PRESSED_BTN

; Calculate the memory address of the target operator, and copy the memory
; to this address. Once this is complete, reload the patch data.

.GET_TARGET_OPERATOR_ADDRESS:
    LDAA    #21
    MUL
    LDX     #M_PATCH_CURRENT_BUFFER
    ABX
    STX     <M_COPY_DEST_PTR

.COPY_OPERATOR:
    LDAB    #14
    JSR     MEMCPY
    JSR     PATCH_LOAD_DATA

.PRINT_TO_OP_STRING:                            ; LCD Buffer Line 2 + 9.
    LDX     #$2638
    STX     <M_COPY_DEST_PTR
    LDX     #aToOp
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDAA    M_LAST_PRESSED_BTN

; Add ASCII '1' to the operator number, and write the target operator
; number in the LCD buffer.
    ADDA    #'1'
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    JMP     LCD_PRINT_STR_BUFFER


; ==============================================================================
; PATCH_GET_PTR_TO_SELECTED_OP
; ==============================================================================
; LOCATION: 0xDBDD
;
; DESCRIPTION:
; This method returns a pointer to the currently selected operator in the
; current patch's edit buffer, returning it in IX.
;
; ARGUMENTS:
; Memory:
; * 0x209F: The currently selected operator.
;
; RETURNS:
; * IX: A pointer to the selected operator.
;
; ==============================================================================

PATCH_GET_PTR_TO_SELECTED_OP:
    LDX     #$2000
    LDAA    #21
    LDAB    M_SELECTED_OPERATOR
    MUL
    ABX
    RTS


; ==============================================================================
; PATCH_LOAD_OPERATOR_KBD_SCALING
; ==============================================================================
; LOCATION: 0xDBE8
;
; DESCRIPTION:
; Parses the serialised keyboard scaling values, and constructs the operator
; keyboard scaling curve for the selected operator.
;
; MEMORY USED:
; For a detailed list of the registers used in this subroutine, refer to the
; list of associated register definitions.
;
; ==============================================================================

PATCH_LOAD_OPERATOR_KBD_SCALING:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    STX     <K_OPERATOR_CURRENT_PTR

.LOAD_BREAKPOINT:
    LDAB    8,x
    PSHX

; Add 20 on account of the lowest breakpoint value being A(-1).
; This is the 21st note starting from C(-2).
; Store quantised breakpoint value in 0xAB.
    ADDB    #20
    LDX     #TABLE_KEY_PITCH
    ABX
    LDAA    0,x
    LSRA
    LSRA
    STAA    <K_BREAKPOINT
    PULX

; Store the most-significant byte of the quantised results.

.LOAD_DEPTH_LEFT:
    LDAA    9,x
    JSR     PATCH_LOAD_QUANTISE_VALUE
    STAA    <K_DEPTH_LEFT

.LOAD_DEPTH_RIGHT:
    LDAA    10,x
    JSR     PATCH_LOAD_QUANTISE_VALUE
    STAA    <K_DEPTH_RIGHT

; Load the left curve value into A, and parse.
; The result, returned in CCR[z], will be 0 if the curve is negative.

.LOAD_CURVE_LEFT:
    LDAA    11,x
    JSR     PATCH_PARSE_CURVE_LEFT

.IS_CURVE_NEGATIVE?:
    BEQ     .LEFT_CURVE_IS_NEGATIVE

; The keyboard scaling polarity value for both left, and right curves is
; stored in this variable. Bit 6 indicates the polarity of the left curve,
; with 1 indicating it's positive. Bit 7 indicates the polarity of the
; right curve.

.LEFT_CURVE_NON_NEGATIVE:
    LDAB    #%1000000
    BRA     .LOAD_CURVE_RIGHT

.LEFT_CURVE_IS_NEGATIVE:
    CLRB

.LOAD_CURVE_RIGHT:
    STAB    <K_KBD_SCALING_POLARITY
    LDAA    12,x
    JSR     PATCH_PARSE_CURVE_RIGHT
    BEQ     .PARSE_OPERATOR_OUTPUT_LEVEL

; Set bit 7 in the keyboard scaling polarity register if the right curve
; is non-negative.

.CURVE_NON_NEGATIVE:
    LDAB    #%10000000
    ADDB    <K_KBD_SCALING_POLARITY
    STAB    <K_KBD_SCALING_POLARITY

.PARSE_OPERATOR_OUTPUT_LEVEL:
    LDAB    16,x
    LDX     #TABLE_LOG
    ABX
    LDAA    0,x
    STAA    <K_OPERATOR_OUTPUT_LVL

.GET_POINTER_TO_END_OF_CURVE:
    LDAA    #43
    STAA    M_KBD_SCALE_CURVE_INDEX
    LDX     #M_OPERATOR_KEYBOARD_SCALING_2
    LDAB    M_SELECTED_OPERATOR
    LDAA    #43
    MUL
    ABX

; The following loop computes the 43 byte keyboard scaling curve for the
; currently selected operator.
; It checks whether each index is above, or below the breakpoint, loading
; the scaling curve accordingly. It then multiplies the scaling curve value
; by the appropriate depth value to compute the final keyboard scaling
; value. This value is then stored in the 43 byte keyboard scaling curve.

.COMPUTE_SCALING_CURVE_LOOP_START:
    STX     <K_OPERATOR_CURRENT_PTR
    LDAB    M_KBD_SCALE_CURVE_INDEX
    SUBB    <K_BREAKPOINT

; Is this index into the parsed curve data above the breakpoint?
; If ACCB > K_BREAKPOINT, branch.

.IS_ABOVE_BREAKPOINT?:
    BHI     .SET_KEYBOARD_SCALE_CURVE_RIGHT

.SET_KEYBOARD_SCALE_CURVE_LEFT:
    LDX     <K_CURVE_TABLE_LEFT_PTR

; Get two's compliment negation of ACCB to invert the index into the
; curve data. Inverting the curve.
    NEGB
    ABX
    LDAB    0,x
    LDAA    <K_DEPTH_LEFT

; Get product of curve * depth.
    MUL

; Branch if product is non-negative.
    TSTA
    BPL     .GET_LEFT_CURVE_POLARITY
    LDAA    #127

.GET_LEFT_CURVE_POLARITY:
    LDAB    <K_KBD_SCALING_POLARITY
    ASLB
    BRA     .IS_CURVE_POSITIVE?

.SET_KEYBOARD_SCALE_CURVE_RIGHT:
    LDX     <K_CURVE_TABLE_RIGHT_PTR
    ABX
    LDAB    0,x                                 ; Load ACCB from CURVE[ACCB].
    LDAA    <K_DEPTH_RIGHT

; Get product of curve * depth.
    MUL
    TSTA

; If the MSB of the result is less than 127, clamp.
    BPL     .GET_RIGHT_CURVE_POLARITY
    LDAA    #127

.GET_RIGHT_CURVE_POLARITY:
    LDAB    <K_KBD_SCALING_POLARITY

.IS_CURVE_POSITIVE?:
    BPL     .CURVE_IS_NEGATIVE

.CURVE_IS_POSITIVE:
    NEGA
    ADDA    <K_OPERATOR_OUTPUT_LVL
    BPL     .STORE_CURVE_DATA
    CLRA
    BRA     .STORE_CURVE_DATA

.CURVE_IS_NEGATIVE:
    ADDA    <K_OPERATOR_OUTPUT_LVL
    BPL     .STORE_CURVE_DATA
    LDAA    #127

.STORE_CURVE_DATA:
    ASLA
    LDX     <K_OPERATOR_CURRENT_PTR
    DEX

; Store the computed scaling value at *(0xF9 + *(0x2313)).
    STAA    0,x
    DEC     M_KBD_SCALE_CURVE_INDEX
    BNE     .COMPUTE_SCALING_CURVE_LOOP_START
    RTS


; ==============================================================================
; PATCH_PARSE_CURVE_LEFT
; ==============================================================================
; LOCATION: 0xDC86
;
; DESCRIPTION:
; Loads a pointer to the keyboard scaling left curve data into 0xAE.
; After the function call CCR[z] will be set if curve is negative.
;
; MEMORY USED:
; * 0xAE:   A pointer to the LEFT keyboard scaling curve data.
;
; RETURNS:
; * CCR[z]: The zero flag will be set if this curve is negative.
;
; ==============================================================================

PATCH_PARSE_CURVE_LEFT:
    STX     <$F9
    TSTA

; If the curve value is 0, or 3 this indicates that the EG curve is linear.
    BEQ     .CURVE_IS_LINEAR
    CMPA    #3
    BEQ     .CURVE_IS_LINEAR
    LDX     #TABLE_KBD_SCALING_CURVE_EXP
    BRA     .STORE_LEFT_CURVE_POINTER

.CURVE_IS_LINEAR:
    LDX     #TABLE_KBD_SCALING_CURVE_LIN

.STORE_LEFT_CURVE_POINTER:
    STX     <K_CURVE_TABLE_LEFT_PTR
    LDX     <$F9                                ; Restore saved IX.

; Tests whether this is a positive, or negative curve.
    BITA    #2
    RTS


; ==============================================================================
; PATCH_PARSE_CURVE_RIGHT
; ==============================================================================
; LOCATION: 0xDC9E
;
; DESCRIPTION:
; Loads a pointer to the keyboard scaling right curve data into 0xB0.
; After the function call CCR[z] will be set if curve is negative.
;
; MEMORY USED:
; * 0xB0:   A pointer to the RIGHT keyboard scaling curve data.
;
; RETURNS:
; * CCR[z]: The zero flag will be set if this curve is negative.
;
; ==============================================================================

PATCH_PARSE_CURVE_RIGHT:
    STX     <$F9
    TSTA

; If the curve value is 0, or 3 this indicates that the EG curve is linear.
    BEQ     .RIGHT_CURVE_IS_LINEAR
    CMPA    #3
    BEQ     .RIGHT_CURVE_IS_LINEAR
    LDX     #TABLE_KBD_SCALING_CURVE_EXP
    BRA     .STORE_RIGHT_CURVE_POINTER

.RIGHT_CURVE_IS_LINEAR:
    LDX     #TABLE_KBD_SCALING_CURVE_LIN

.STORE_RIGHT_CURVE_POINTER:
    STX     <K_CURVE_TABLE_RIGHT_PTR
    LDX     <$F9                                ; Restore saved IX.

; Tests whether this is a positive, or negative curve.
    BITA    #2
    RTS


; ==============================================================================
; Exponential Keyboard Scaling Curve Table.
; Used when parsing the operator keyboard scaling.
; Length: 36.
; ==============================================================================
TABLE_KBD_SCALING_CURVE_EXP:
    FCB 0, 1, 2, 3, 4, 5, 6
    FCB 7, 8, 9, $B, $E, $10
    FCB $13, $17, $1C, $21, $27
    FCB $2F, $39, $43, $50, $5F
    FCB $71, $86, $A0, $BE, $E0
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF

; ==============================================================================
; Linear Keyboard Scaling Curve Table.
; Used when parsing the operator keyboard scaling.
; Length: 36.
; ==============================================================================
TABLE_KBD_SCALING_CURVE_LIN:
    FCB 0, 8, $10, $18
    FCB $20, $28, $30, $38, $40
    FCB $48, $50, $58, $60, $68
    FCB $70, $78, $80, $88, $90
    FCB $98, $A0, $A8, $B2, $B8
    FCB $C0, $C8, $D0, $D8, $E0
    FCB $E8, $F0, $F8, $FF, $FF
    FCB $FF, $FF

; ==============================================================================
; Logarithmic Curve Table.
; Used in parsing various operator values.
; Length: 100.
; ==============================================================================
TABLE_LOG:
    FCB $7F, $7A, $76, $72, $6E
    FCB $6B, $68, $66, $64, $62
    FCB $60, $5E, $5C, $5A, $58
    FCB $56, $55, $54, $52, $51
    FCB $4F, $4E, $4D, $4C, $4B
    FCB $4A, $49, $48, $47, $46
    FCB $45, $44, $43, $42, $41
    FCB $40, $3F, $3E, $3D, $3C
    FCB $3B, $3A, $39, $38, $37
    FCB $36, $35, $34, $33, $32
    FCB $31, $30, $2F, $2E, $2D
    FCB $2C, $2B, $2A, $29, $28
    FCB $27, $26, $25, $24, $23
    FCB $22, $21, $20, $1F, $1E
    FCB $1D, $1C, $1B, $1A, $19
    FCB $18, $17, $16, $15, $14
    FCB $13, $12, $11, $10, $F
    FCB $E, $D, $C, $B, $A, 9
    FCB 8, 7, 6, 5, 4, 3, 2
    FCB 1, 0


; ==============================================================================
; EGS_RESET_VOICES
; ==============================================================================
; LOCATION: 0xDD62
;
; DESCRIPTION:
; Resets all operator levels to 0xFF for all voices, then triggers a 'KEY OFF',
; and then 'KEY ON' event for all 16 voices.
;
; ==============================================================================

EGS_RESET_VOICES:
    LDAB    #96                                 ; 6 operators * 16 voices.
    LDAA    #$FF
    LDX     #P_EGS_OP_LEVELS

.RESET_OP_LEVELS_LOOP:
    JSR     DELAY

; Store 0xFF in the Operator Level register to effectively disable output.
    STAA    0,x
    INX
    DECB
    BNE     .RESET_OP_LEVELS_LOOP               ; If ACCB > 0, loop.

; The following sequence starts by writing 0x2 to the voice events buffer
; to signal a 'KEY OFF' event for voice 0.
; The value is decremented, and written again to signal a 'KEY ON' event
; for voice 0.
; Since the voice number in this register is stored at bits 2-5, the value
; is incremented by 4 to increment the voice number.
    LDAB    #16
    LDAA    #2

.RESET_VOICE_EVENT_LOOP:
    JSR     DELAY
    STAA    P_EGS_VOICE_EVENTS
    JSR     DELAY
    DECA
    STAA    P_EGS_VOICE_EVENTS
    JSR     DELAY
    INCA
    STAA    P_EGS_VOICE_EVENTS
    ADDA    #4
    DECB
    BNE     .RESET_VOICE_EVENT_LOOP             ; If ACCB > 0, loop
    RTS


; ==============================================================================
; VOICE_ADD_LOAD_OPERATOR_DATA_TO_EGS
; ==============================================================================
; LOCATION: 0xDD90
;
; DESCRIPTION:
; Calculates the final operator volume values, applying the patch's keyboard
; scaling, and then loads them to the EGS. After this has been done, the final
; voice pitch values are loaded to the EGS.
;
; ARGUMENTS:
; Registers:
; * ACCA: The current voice number.
; * IX:   The note pitch, as calculated in the 'VOICE_ADD' function.
;
; ==============================================================================

VOICE_ADD_LOAD_OPERATOR_DATA_TO_EGS:
    STX     <VA_VOICE_PITCH_NEW
    STAA    <VA_VOICE_CURRENT

.LOAD_OP_DATA_SETUP_POINTERS:
    LDX     #M_PATCH_OP_SENS
    STX     <VA_OP_SENS_PTR
    LDX     #M_OP_VOLUME
    STX     <VA_OP_VOLUME_PTR

; Load the 'Operator Volume Velocity Scale Factor' value into ACCB.
; This value is used to scale the operator volume according to the
; velocity of the last note.

.GET_OPERATOR_VELOCITY_SCALE:
    LDAB    <M_NOTE_VEL
    LSRB
    LSRB
    LDX     #TABLE_OP_VOLUME_VELOCITY_SCALE
    ABX
    LDAB    0,x

; Use this scaling factor to scale the output volume of each of the
; synth's six operators.

.LOAD_OP_DATA_SET_LOOP_INDEX:
    LDAA    #6
    STAA    <VA_LOOP_INDEX

.GET_OP_VOLUME_LOOP:
    LDX     <VA_OP_SENS_PTR
    PSHB

; Multiply the lower byte of the 'Op Key Sens' value with the log table value
; in B, and then add the higher byte of the 'Op Key Sens' back to this value.
    LDAA    1,x
    MUL
    ADDA    0,x

; If this value overflows, clamp at 0xFF.
    BCC     .INCREMENT_OP_SENS_PTR
    LDAA    #$FF

.INCREMENT_OP_SENS_PTR:
    INX
    INX
    STX     <VA_OP_SENS_PTR

.STORE_OP_VOLUME:
    LDX     <VA_OP_VOLUME_PTR
    STAA    0,x
    INX
    STX     <VA_OP_VOLUME_PTR

.DECREMENT_INDEX:
    PULB
    DEC     VA_LOOP_INDEX
    BNE     .GET_OP_VOLUME_LOOP                 ; If *(0xAF) > 0, loop.

.LOAD_OPERATOR_LEVELS:
    CLR     VA_LOOP_INDEX
    LDAA    M_PATCH_CURRENT_OPS_ON_OFF
    STAA    <VA_OPERATOR_ON_OFF

; Logically shift the 'Operator On/Off' register value right with each
; iteration. This loads the previous bit 0 into the carry flag, which is
; then checked to determined whether the operator is enabled, or disabled.

.CHECK_OP_ENABLED_LOOP:
    LSR     VA_OPERATOR_ON_OFF
    BCS     .APPLY_KEYBOARD_SCALING
    JSR     DELAY
    BRA     .CLEAR_OP_VOLUME

.APPLY_KEYBOARD_SCALING:
    LDAB    <VA_LOOP_INDEX
    LDAA    #43
    MUL
    LDX     #M_OPERATOR_KEYBOARD_SCALING
    ABX

; Use the MSB of the note pitch as an index into the keyboard scaling curve.

.GET_OPERATOR_SCALING:
    LDAB    <VA_VOICE_PITCH_NEW
    LSRB
    LSRB
    ABX
    LDAA    0,x

; Add the operator scaling value to the logarithmic operator volume value.
; Clamp the resulting value at 0xFF.

.ADD_TO_BASE_OP_VOLUME:
    LDX     #M_OP_VOLUME
    LDAB    <VA_LOOP_INDEX
    ABX
    ADDA    0,x
    BCC     .GET_EGS_OPERATOR_VOL_REGISTER_INDEX

.CLEAR_OP_VOLUME:
    LDAA    #$FF

; Calculate the index into the EGS' 'Operator Levels' register.
; This register is 96 bytes long, arranged in the format of:
;   Operator[number][voice].
; The index is calculated by: (Current Operator * 16 + Current Voice).

.GET_EGS_OPERATOR_VOL_REGISTER_INDEX:
    PSHA
    LDAA    #16
    LDAB    <VA_LOOP_INDEX
    MUL
    ADDB    <VA_VOICE_CURRENT
    LDX     #P_EGS_OP_LEVELS
    ABX
    PULA

; If the resulting amplitude value is less than 4, clamp at 4.

.CLAMP_MINIMUM_TO_4:
    CMPA    #3
    BHI     .STORE_OP_DATA_TO_EGS
    LDAA    #4

.STORE_OP_DATA_TO_EGS:
    STAA    0,x

.LOAD_OP_DATA_INCREMENT_INDEX:
    INC     VA_LOOP_INDEX
    LDAA    <VA_LOOP_INDEX
    CMPA    #6
    BNE     .CHECK_OP_ENABLED_LOOP              ; If *(0xAF) < 6, loop.

; If the portamento rate is instantaneous, then write the pitch value to
; the EGS, and exit.

.LOAD_OP_DATA_IS_PORTA_RATE_MAX?:
    LDAA    M_PORTA_RATE_INCREMENT
    CMPA    #$FE
    BHI     VOICE_ADD_LOAD_PITCH_TO_EGS

; Check if the synth is in monophonic mode. If it is, then perform an
; additional check to determine the portamento mode.
; If the synth is monophonic, and in fingered portamento mode, load the
; pitch value for the current voice immediately.

.LOAD_OP_DATA_IS_SYNTH_MONO?:
    LDAA    M_MONO_POLY
    BEQ     .LOAD_OP_DATA_IS_PORTA_PDL_ACTIVE?

.IS_PORTA_MODE_FINGERED?:
    LDAA    M_PORTA_MODE
    BEQ     VOICE_ADD_LOAD_PITCH_TO_EGS

.LOAD_OP_DATA_IS_PORTA_PDL_ACTIVE?:
    LDAA    M_PEDAL_INPUT_STATUS
    BITA    #PEDAL_STATUS_PORTAMENTO_ACTIVE

; If the portamento pedal is active, exit.
; Otherwise this falls-through below to 'load pitch'.
    BNE     VOICE_ADD_LOAD_CURR_VOICE_PITCH_END


; ==============================================================================
; VOICE_ADD_LOAD_PITCH_TO_EGS
; ==============================================================================
; LOCATION: 0xDE2D
;
; DESCRIPTION:
; This function calculates the final current pitch value for the current
; voice, and loads it to the appropriate register in the EGS chip.
;
; MEMORY USED:
; * 0xDCBA: Temp
; * 0xAB:   The current note's pitch value, before applying the pitch EG level.
; * 0xAE:   The current voice number.
; * 0xB0:   This scratch register is used for temporary storage.
;
; ==============================================================================

VOICE_ADD_LOAD_PITCH_TO_EGS:
    LDAB    <VA_VOICE_CURRENT
    ASLB

.LOAD_PITCH_EG_LEVEL_TO_EGS:
    LDX     #M_VOICE_PITCH_EG_CURR_LEVEL
    ABX
    LDD     0,x

.ADD_KEY_PITCH:
    ADDD    <VA_VOICE_PITCH_NEW
    SUBD    #$1BA8

; Clamp the pitch value to a minimum of zero.
; If it is below this minumum value, set to zero.
; If the current vaue of D > 0x1BA8, branch.
    BCC     .ADD_MASTER_TUNE
    LDD     #0

.ADD_MASTER_TUNE:
    ADDD    M_MASTER_TUNE
    STAB    <$B0                                ; Store the LSB temporarily.

.WRITE_PITCH_TO_EGS:
    LDX     #P_EGS_VOICE_PITCH
    LDAB    <VA_VOICE_CURRENT
    ASLB
    ABX
    STAA    0,x
    LDAB    <$B0
    STAB    1,x                                 ; Store previously saved LSB.

VOICE_ADD_LOAD_CURR_VOICE_PITCH_END:
    RTS


; ==============================================================================
; Velocity to operator volume mapping table.
; Used when scaling an operator's amplitude value according to its volume.
; Length: 32.
; ==============================================================================
TABLE_OP_VOLUME_VELOCITY_SCALE:
    FDB 4
    FCB $C
    FCB $15
    FCB $1E
    FCB $28
    FCB $2E
    FCB $34
    FCB $3A
    FCB $40
    FCB $46
    FCB $4C
    FCB $52
    FCB $58
    FCB $5E
    FCB $64
    FCB $67
    FCB $6A
    FCB $6D
    FCB $70
    FCB $72
    FCB $74
    FCB $76
    FCB $78
    FCB $7A
    FCB $7C
    FCB $7E
    FCB $80
    FCB $82
    FCB $83
    FCB $84
    FCB $85


; ==============================================================================
; PATCH_LOAD_OPERATOR_EG_LEVELS
; ==============================================================================
; LOCATION: 0xDE73
;
; DESCRIPTION:
; Parses and loads the EG levels for the current operator, then loads these
; values to the EGS' internal registers.
;
; ==============================================================================

PATCH_LOAD_OPERATOR_EG_LEVELS:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    LDAB    #7
    ABX
    STX     <$AF
    LDAA    #4
    STAA    <$B1

; This loop retrieves the logarithmic values of the operator EG levels.
; Variables used in the loop:
;  * 0xAF: Pointer to curve values.
;  * 0xB1: Loop index = 4.
;  * 0xAB..0xAE: Used as storage for the 4 parsed EG level values.

.QUANTISE_OPERATOR_EG_LEVELS_LOOP:
    LDX     <$AF

; Load the EG level value into ACCB, and decrement the pointer to the
; operator EG level values in patch memory.

.LOAD_PATCH_EG_LEVEL:
    LDAB    0,x
    DEX
    STX     <$AF

; Use the loaded operator EG level value as an index into the logarithmic
; table to get the full operator EG volume level.

.LOOKUP_LOG_EG_LEVEL:
    LDX     #TABLE_LOG
    ABX
    LDAA    0,x
    LSRA

; Use the loop index in 0xB1(0 .. 3) as an offset from 0xAB, to decide where
; to store the parsed EG level value.
; Afterwards decrement the loop index.

.STORE_PARSED_EG_LEVEL_TO_EGS:
    LDAB    <$B1
    LDX     #$AB
    DECB
    ABX
    STAA    0,x

.LOAD_OP_EG_DECREMENT_LOOP_INDEX:
    DEC     $B1
    BNE     .QUANTISE_OPERATOR_EG_LEVELS_LOOP
    LDAA    M_SELECTED_OPERATOR
    LDAB    #4
    MUL
    STAB    <$AF
    LDAB    #4
    CLR     $B1

; Loads the Operator EG level values into the EGS envelope levels register.
; Variables used in the loop:
;  * 0xAF: Selected operator * 4.
;  * 0xB1: 0.
;  * 0xAB: 4 Log values.
;  * ACCB: Loop index = 4.

.STORE_OPERATOR_EG_LEVELS_LOOP:
    PSHB
    JSR     DELAY

.LOAD_PARSED_EG_LEVEL:
    LDX     #$AB
    LDAB    <$B1
    ABX
    LDAA    0,x

.STORE_IN_EGS_REGISTER:
    LDX     #P_EGS_OP_EG_LEVELS
    LDAB    <$AF
    ABX
    STAA    0,x
    INC     $AF

.INCREMENT_LOOP_INDEX:
    INC     $B1
    PULB
    DECB
    BNE     .STORE_OPERATOR_EG_LEVELS_LOOP      ; If b > 0, loop.
    RTS


; ==============================================================================
; PATCH_LOAD_OPERATOR_EG_RATES
; ==============================================================================
; LOCATION: 0xDEC7
;
; DESCRIPTION:
; Loads and parses the current operator's EG rate values, then loads these
; values to the appropriate registers in the EGS.
;
; MEMORY USED:
; * 0xAB:   Pointer to the selected OP in the working buffer.
; * 0xAE:   The number of the selected operator * 4.
; * 0xAD:   Loop index = 4.
;
; ==============================================================================

PATCH_LOAD_OPERATOR_EG_RATES:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    STX     <$AB
    LDAA    M_SELECTED_OPERATOR
    LDAB    #4
    MUL
    STAB    <$AE
    LDAA    #4
    STAA    <$AD

.LOAD_OPERATOR_EG_RATE_LOOP:
    JSR     DELAY
    LDX     <$AB
    LDAB    0,x
    INX

; The EG rate value (stored in range 0 - 99) is multiplied by 164, and then
; (effectively) shifted >> 8. This quantises it to a value between 0-64.
    LDAA    #164
    MUL

; Increment source ptr.
    STX     <$AB
    LDX     #P_EGS_OP_EG_RATES
    LDAB    <$AE

; Current operator * 4 is the index into this EGS register.
    ABX
    STAA    0,x

; Increment operator number.
    INC     $AE

; Decrement index.
    DEC     $AD
    BNE     .LOAD_OPERATOR_EG_RATE_LOOP
    RTS


; ==============================================================================
; PATCH_LOAD_CALL_FUNC_PTR
; ==============================================================================
; LOCATION: 0xDEF6
;
; DESCRIPTION:
; This subroutine calls the specified function passed in the function pointer
; six times, once for each operator.
; This is used as part of the patch loading process to parse, and load values
; for all six operators.
;
; ARGUMENTS:
; Memory:
; * 0x2183: A pointer to the function to call.
;
; ==============================================================================

PATCH_LOAD_CALL_FUNC_PTR:
    PSHX

; Save memory at 0x209F.
    LDAA    M_SELECTED_OPERATOR
    PSHA
    CLRB

.CALL_FP_START:
    STAB    M_SELECTED_OPERATOR
    LDX     M_PATCH_LOAD_FUNC_PTR
    PSHB
    PSHX
    JSR     0,x
    PULX
    PULB
    INCB
    CMPB    #6
    BNE     .CALL_FP_START                      ; If ACCB < 6, loop.

; Restore contents of the memory at 0x209F.
    PULA
    STAA    M_SELECTED_OPERATOR
    PULX
    RTS


; ==============================================================================
; PORTA_COMPUTE_RATE_VALUE
; ==============================================================================
; LOCATION: 0xDF13
;
; DESCRIPTION:
; Computes the Portamento/Glissando 'rate' value from the portamento time
; function parameter value.
;
; ==============================================================================

PORTA_COMPUTE_RATE_VALUE:
    LDAB    #99
    SUBB    M_PORTA_TIME

; The 'Portamento Time' value (0-99) is subtracted from a value of 99
; to yield the rate value.
; i.e. A time of '0' is rate '0xFF', an instant switch to the next note.
    LDX     #TABLE_PITCH_EG_RATE
    ABX
    LDAB    0,x
    STAB    M_PORTA_RATE_INCREMENT
    RTS

; ==============================================================================
; This is used to quantise the patch pitch EG rate values from
; their native 0-99 range, to the 0-255 range of values required by the EGS.
; ==============================================================================
TABLE_PITCH_EG_RATE:
    FCB 1, 2, 3, 3, 4, 4, 5
    FCB 5, 6, 6, 7, 7, 8, 8
    FCB 9, 9, $A, $A, $B, $B
    FCB $C, $C, $D, $D, $E, $E
    FCB $F, $10, $10, $11, $12
    FCB $12, $13, $14, $15, $16
    FCB $17, $18, $19, $1A, $1B
    FCB $1C, $1E, $1F, $21, $22
    FCB $24, $25, $26, $27, $29
    FCB $2A, $2C, $2E, $2F, $31
    FCB $33, $35, $36, $38, $3A
    FCB $3C, $3E, $40, $42, $44
    FCB $46, $48, $4A, $4C, $4F
    FCB $52, $55, $58, $5B, $5E
    FCB $62, $66, $6A, $6E, $73
    FCB $78, $7D, $82, $87, $8D
    FCB $93, $99, $9F, $A5, $AB
    FCB $B2, $B9, $C1, $CA, $D3
    FCB $E8, $F3, $FE, $FF


; ==============================================================================
; PATCH_LOAD_OPERATOR_KBD_RATE_SCALING
; ==============================================================================
; LOCATION: 0xDF86
;
; DESCRIPTION:
; Loads the 'Keyboard Rate Scaling' value for the current operator, and combines
; it with the 'Amp Mod Sensitivity' value to create the 'combined' value
; expected by the EGS' internal registers.
;
; ==============================================================================

PATCH_LOAD_OPERATOR_KBD_RATE_SCALING:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    LDAB    #13
    ABX
    LDAB    0,x                                 ; Load KBD_RATE_SCALING into B.
    LDAA    1,x                                 ; Load AMP_MOD_SENS into A.

; Combine the values into the format expected by the EGS.

.COMBINE_VALUES:
    ASLA
    ASLA
    ASLA
    ABA
    LDAB    M_SELECTED_OPERATOR

; Store the combined value in the appropriate EGS register: 0x30E0[OP].

.WRITE_RATE_SCALING_TO_EGS:
    LDX     #P_EGS_OP_SENS_SCALING
    ABX
    STAA    0,x
    RTS


; ==============================================================================
; PATCH_LOAD_OPERATOR_PITCH
; ==============================================================================
; LOCATION: 0xDF9E
;
; DESCRIPTION:
; Parses the pitch values for the currently selected operator, and loads it to
; the appropriate register inside the EGS chip.
;
; MEMORY USED:
; * AB: Pointer to selected op in patch working buffer.
; * AD: Operator Coarse Freq.
; * AF: Operator Fine Freq.
;
; ==============================================================================

PATCH_LOAD_OPERATOR_PITCH:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    STX     <$AB
    LDAB    17,x                                ; Load 'Osc Mode' into B.
    BNE     .OSC_MODE_FIXED

; Use the serialised 'Op Freq Coarse' value (0-31) as an index into the
; coarse frequency lookup table.
; Store the resulting coarse freq value in 0xAD.

.OSC_MODE_RATIO:
    LDAB    18,x
    ASLB
    LDX     #TABLE_OP_FREQ_COARSE
    ABX
    LDD     0,x
    STD     <$AD

.PARSE_RATIO_FREQ_FINE:
    LDX     <$AB
    LDAB    19,x
    LDAA    #2
    MUL

; Store 'Op Freq Fine' (0-99) * 2 in 0xAF.
; This value will be used as an index into the fine frequency lookup table.
; The resulting value will be added to the coarse frequency to produce
; the final result.
    STD     <$AF
    LDD     #TABLE_OP_FREQ_FINE
    ADDD    <$AF
    STD     <$AB
    LDX     <$AB
    LDD     0,x

; The final ratio frequency value is:
; Ratio_Frequency = 0x232C + FREQ_COARSE + FREQ_FINE.

.CALCULATE_FINAL_RATIO_FREQ:
    ADDD    <$AD
    ADDD    #$232C

; The final frequency value is a 14-bit integer, shifted left two bits.
; Bit 0 holds the flag indicating whether this is a fixed frequency value.
; Clear this bit to indicate this operator uses a ratio frequency.
    ANDB    #%11111110
    JMP     .LOAD_OP_PITCH_TO_EGS

; Use the serialised 'Op Freq Coarse' value (0-31) % 3, as an index
; into the fixed frequency lookup table.
; Store the resulting frequency value in 0xAD.

.OSC_MODE_FIXED:
    LDX     <$AB
    LDAB    18,x
    ANDB    #3
    ASLB
    LDX     #TABLE_OP_FREQ_FIXED
    ABX
    LDD     0,x
    STD     <$AD

; Quantise the fine fixed frequency by multipying by 136.

.PARSE_FIXED_FREQ_FINE:
    LDX     <$AB
    LDAA    19,x
    LDAB    #136
    MUL

; The final fixed frequency value is:
; Fixed_Frequency = 0x16AC + FREQ_FIXED + FREQ_FINE.

.CALCULATE_FINAL_FIXED_FREQ:
    ADDD    #$16AC
    ADDD    <$AD

; The final frequency value is a 14-bit integer, shifted left two bits.
; Bit 0 holds the flag indicating whether this is a fixed frequency value.
; Set this bit to indicate this operator uses a fixed frequency.
    ORAB    #1
    JMP     .LOAD_OP_PITCH_TO_EGS

; ==============================================================================
; Coarse Frequency Lookup Table.
; ==============================================================================
TABLE_OP_FREQ_COARSE:
    FDB $F000
    FDB 0
    FDB $1000
    FDB $195C
    FDB $2000
    FDB $2528
    FDB $295C
    FDB $2CEC
    FDB $3000
    FDB $32B8
    FDB $3528
    FDB $375A
    FDB $395C
    FDB $3B34
    FDB $3CEC
    FDB $3E84
    FDB $4000
    FDB $4168
    FDB $42B8
    FDB $43F8
    FDB $4528
    FDB $4648
    FDB $475A
    FDB $4860
    FDB $495C
    FDB $4A4C
    FDB $4B34
    FDB $4C14
    FDB $4CEC
    FDB $4DBA
    FDB $4E84
    FDB $4F44

; ==============================================================================
; Fixed Frequency Lookup Table.
; ==============================================================================
TABLE_OP_FREQ_FIXED:
    FDB 0
    FDB $3526
    FDB $6A4C
    FDB $9F74

; ==============================================================================
; Fine Frequency Lookup Table.
; ==============================================================================
TABLE_OP_FREQ_FINE:
    FDB 0
    FDB $3A
    FDB $75
    FDB $AE
    FDB $E7
    FDB $120
    FDB $158
    FDB $18F
    FDB $1C6
    FDB $1FD
    FDB $233
    FDB $268
    FDB $29D
    FDB $2D2
    FDB $306
    FDB $339
    FDB $36D
    FDB $39F
    FDB $3D2
    FDB $403
    FDB $435
    FDB $466
    FDB $497
    FDB $4C7
    FDB $4F7
    FDB $526
    FDB $555
    FDB $584
    FDB $5B2
    FDB $5E0
    FDB $60E
    FDB $63B
    FDB $668
    FDB $695
    FDB $6C1
    FDB $6ED
    FDB $719
    FDB $744
    FDB $76F
    FDB $799
    FDB $7C4
    FDB $7EE
    FDB $818
    FDB $841
    FDB $86A
    FDB $893
    FDB $8BC
    FDB $8E4
    FDB $90C
    FDB $934
    FDB $95C
    FDB $983
    FDB $9AA
    FDB $9D1
    FDB $9F7
    FDB $A1D
    FDB $A43
    FDB $A69
    FDB $A8F
    FDB $AB4
    FDB $AD9
    FDB $AFE
    FDB $B22
    FDB $B47
    FDB $B6B
    FDB $B8F
    FDB $BB2
    FDB $BD6
    FDB $BF9
    FDB $C1C
    FDB $C3F
    FDB $C62
    FDB $C84
    FDB $CA7
    FDB $CC9
    FDB $CEA
    FDB $D0C
    FDB $D2E
    FDB $D4F
    FDB $D70
    FDB $D91
    FDB $DB2
    FDB $DD2
    FDB $DF3
    FDB $E13
    FDB $E33
    FDB $E53
    FDB $E72
    FDB $E92
    FDB $EB1
    FDB $ED0
    FDB $EEF
    FDB $F0E
    FDB $F2D
    FDB $F4C
    FDB $F6A
    FDB $F88
    FDB $FA6
    FDB $FC4
    FDB $FE2
    FDB $1000

.LOAD_OP_PITCH_TO_EGS:
    PSHB
    LDAB    M_SELECTED_OPERATOR
    ASLB
    LDX     #P_EGS_OP_PITCH
    ABX

; Store the 16-bit pitch, and fixed-frequency flag value at 0x3020[OP * 2].
    STAA    0,x
    PULB
    STAB    1,x
    RTS


; ==============================================================================
; PATCH_LOAD_PITCH_EG_VALUES
; ==============================================================================
; LOCATION: 0xE111
;
; DESCRIPTION:
; Parses the current patch's pitch EG rate, and level values. These are then
; stored in the synth's RAM, since they are needed for the synth's various
; voice operations.
;
; MEMORY USED:
; * 0xAB:   A pointer to the parsed pitch EG values location in memory.
;
; ==============================================================================

PATCH_LOAD_PITCH_EG_VALUES:
    LDX     #M_PATCH_PITCH_EG_VALUES
    STX     <$AB

; A is used as the loop index for both loops.
    CLRA

; The address 0x207E is a pointer to the current patch's pitch EG data.

.PARSE_PITCH_EG_RATE_VALUES:
    LDX     #$207E

; Use ACCB as an index into the current patch's Pitch EG rate values.
    TAB
    ABX
    LDAB    0,x
    INCA

; Use this value as an index into the pitch EG rate table, and load the
; corresponding value.
    LDX     #TABLE_PITCH_EG_RATE
    ABX
    LDAB    0,x

; Store the parsed EG rate value at 0x2160[a].

.STORE_PARSED_EG_RATE:
    LDX     <$AB
    STAB    0,x
    INX
    STX     <$AB
    CMPA    #4
    BNE     .PARSE_PITCH_EG_RATE_VALUES

.PARSE_PITCH_EG_LVL_VALUES:
    LDX     #$207E

; Use ACCB as an index into the current patch's Pitch EG level values.
    TAB
    ABX
    LDAB    0,x
    INCA

; Use this value as an index into the pitch EG level table, and load the
; corresponding value.
    LDX     #TABLE_PITCH_EG_LEVEL
    ABX
    LDAB    0,x

; Store the parsed EG level value at 0x2160[a].

.STORE_PARSED_EG_LEVEL:
    LDX     <$AB
    STAB    0,x
    INX
    STX     <$AB
    CMPA    #8
    BNE     .PARSE_PITCH_EG_LVL_VALUES
    RTS

; ==============================================================================
; This table is used to quantise the patch pitch EG level values from their
; 0-99 range,to the 0-255 range of values required for the final
; frequency calculation.
; ==============================================================================
TABLE_PITCH_EG_LEVEL:
    FCB 0, $C, $18, $21, $2B
    FCB $34, $3C, $43, $48, $4C
    FCB $4F, $52, $55, $57, $59
    FCB $5B, $5D, $5F, $60, $61
    FCB $62, $63, $64, $65, $66
    FCB $67, $68, $69, $6A, $6B
    FCB $6C, $6D, $6E, $6F, $70
    FCB $71, $72, $73, $74, $75
    FCB $76, $77, $78, $79, $7A
    FCB $7B, $7C, $7D, $7E, $7F
    FCB $80, $81, $82, $83, $84
    FCB $85, $86, $87, $88, $89
    FCB $8A, $8B, $8C, $8D, $8E
    FCB $8F, $90, $91, $92, $93
    FCB $94, $95, $96, $97, $98
    FCB $99, $9A, $9B, $9C, $9D
    FCB $9E, $9F, $A0, $A1, $A2
    FCB $A3, $A6, $A8, $AB, $AE
    FCB $B1, $B5, $BA, $C1, $C9
    FCB $D2, $DC, $E7, $F3, $FF


; ==============================================================================
; PATCH_LOAD_ALG_MODE
; ==============================================================================
; LOCATION: 0xE1AE
;
; DESCRIPTION:
; Loads the algorithm, oscillator sync, and feedback variables from the
; current patch's working buffer, and writes these to the OPS chip's internal
; registers.
;
; ==============================================================================

PATCH_LOAD_ALG_MODE:
    LDAA    $2087                               ; Feedback level.

; Load the 'Algorithm' value, shift left 3 bits, and combine with the
; 'Feedback' value to create the final bitmask.
    LDAB    M_PATCH_CURRENT_ALG
    ASLB
    ASLB
    ASLB
    ABA

; Test the patch's 'Oscillator Sync' value, and create the final value
; accordingly.
    TST     $2088
    BEQ     .SYNC_DISABLED
    LDAB    #48
    BRA     .WRITE_TO_OPS_REGISTERS

.SYNC_DISABLED:
    LDAB    #80

.WRITE_TO_OPS_REGISTERS:
    STAB    P_OPS_MODE
    STAA    P_OPS_ALG_FDBK
    RTS


; ==============================================================================
; PATCH_LOAD_LFO
; ==============================================================================
; LOCATION: 0xE1CA
;
; DESCRIPTION:
; Loads, and parses the LFO speed, delay, pitch, and modulation depth values.
; The parsed values are stored in the appropriate internal registers.
;
; ==============================================================================

PATCH_LOAD_LFO:
    LDX     #$2089
    JSR     PATCH_LOAD_QUANTISE_LFO_SPEED
    STD     M_LFO_PHASE_INCREMENT

.PARSE_LFO_DELAY:
    LDX     #M_PATCH_CURRENT_LFO_DELAY
    JSR     PATCH_LOAD_QUANTIZE_LFO_DELAY
    STD     M_LFO_DELAY_INCREMENT

.PARSE_LFO_PITCH_MOD_DEPTH:
    LDX     #$208B
    LDAA    0,x
    JSR     PATCH_LOAD_QUANTISE_VALUE
    STAA    M_LFO_PITCH_MOD_DEPTH

.PARSE_LFO_AMP_MOD_DEPTH:
    LDAA    1,x
    JSR     PATCH_LOAD_QUANTISE_VALUE
    STAA    M_LFO_AMP_MOD_DEPTH

.PARSE_LFO_WAVEFORM:
    LDAA    3,x
    STAA    M_LFO_WAVEFORM

.PARSE_LFO_PITCH_MOD_SENS:
    LDAB    4,x
    LDX     #TABLE_PITCH_MOD_SENS
    ABX
    LDAA    0,x
    STAA    M_LFO_PITCH_MOD_SENS
    RTS

; ==============================================================================
; Pitch Mod Sensitivity Table.
; ==============================================================================
TABLE_PITCH_MOD_SENS:
    FCB 0
    FCB 10
    FCB 20
    FCB 33
    FCB 55
    FCB 92
    FCB 153
    FCB 255


; ==============================================================================
; MOD_PROCESS_INPUT_SOURCES
; ==============================================================================
; LOCATION: 0xE208
;
; DESCRIPTION:
; Processes the input from the synth's four modulation input sources (mod wheel,
; aftertouch, breath control, and foot control). This subroutine calculates the
; 'scaled input' for each source, being the analog input scaled by the source's
; respective 'range' value.
; This subroutine also computes the total 'Amplitude Modulation Factor', which
; will be sent to the EGS, and the total 'EG Bias'.
;
; ==============================================================================

MOD_PROCESS_INPUT_SOURCES:
    CLR     M_EG_BIAS_TOTAL_RANGE

; This subroutine is where the modulation-source analog input values are scaled
; according to their range parameters, and stored.
; Load the first of the 'Modulation Source'-related parameters.

.CALCULATE_MOD_SOURCE_SCALED_INPUTS:
    LDX     #M_MOD_WHEEL_ASSIGN_FLAGS
    LDD     M_MOD_WHEEL_RANGE
    BSR     MOD_CALCULATE_SOURCE_SCALED_INPUT
    LDD     M_FOOT_CTRL_RANGE
    BSR     MOD_CALCULATE_SOURCE_SCALED_INPUT
    LDD     M_BRTH_CTRL_RANGE
    BSR     MOD_CALCULATE_SOURCE_SCALED_INPUT
    LDD     M_AFTERTOUCH_RANGE
    BSR     MOD_CALCULATE_SOURCE_SCALED_INPUT
    COM     M_EG_BIAS_TOTAL_RANGE

.CALCULATE_AMP_MOD:
    LDAA    #4
    CLRB
    LDX     #M_MOD_WHEEL_ASSIGN_FLAGS

; Loop over the four modulation sources.
; If 'Amplitude Modulation' is enabled for this source, then add this
; modulation-source's scaled input value to the total amplitude
; modulation factor.

.CALCULATE_AMP_MOD_LOOP:
    PSHA
    BSR     MOD_AMP_SUM_MOD_SOURCE
    BCS     .CALCULATE_AMP_MOD_OVERFLOW
    INX
    PULA
    DECA
    BNE     .CALCULATE_AMP_MOD_LOOP             ; If A > 0, loop.
    BRA     .STORE_AMP_MOD_FACTOR

.CALCULATE_AMP_MOD_OVERFLOW:
    PULA

.STORE_AMP_MOD_FACTOR:
    STAB    <M_MOD_AMP_FACTOR

; Loop over each of the four modulation-sources, testing the flags for each
; one to determine whether 'EG Bias' is enabled. If so, the 'scaled input'
; for each is added to a sum total. The 'EG Bias Range' total is added to
; this amount. If it overflows, it's clamped at 0xFF.

.CALCULATE_EG_BIAS:
    LDAA    #4
    CLRB
    LDX     #M_MOD_WHEEL_ASSIGN_FLAGS

.CALCULATE_EG_BIAS_LOOP:
    PSHA
    BSR     MOD_SUM_MOD_SOURCE_EG_BIAS
    BCS     .CALCULATE_EG_BIAS_OVERFLOW
    INX
    PULA
    DECA
    BNE     .CALCULATE_EG_BIAS_LOOP
    BRA     .ADD_EG_BIAS

; In case of overflow, clear the pushed value on the stack.

.CALCULATE_EG_BIAS_OVERFLOW:
    PULA

.ADD_EG_BIAS:
    ADDB    <M_EG_BIAS_TOTAL_RANGE
    BCC     .END_MOD_PROCESS_INPUT_SOURCES
    LDAB    #$FF

.END_MOD_PROCESS_INPUT_SOURCES:
    COMB
    STAB    <M_MOD_AMP_EG_BIAS_TOTAL
    RTS


; ==============================================================================
; MOD_CALCULATE_SOURCE_SCALED_INPUT
; ==============================================================================
; LOCATION: 0xE257
;
; DESCRIPTION:
; This subroutine is responsible for calculating the 'scaled input' value of a
; particular modulation-source input. This 'scaled input' is the analog input
; scaled by the modulation-source's 'range' value.
;
; This subroutine quantises the range value of a particular modulation
; source, and adds this quantised value to the total EG Bias value, if EG bias
; is enabled for this particular modulation source.
; This quantised range value is then used to calculate the final modulation
; value for this modulation source by multiplying the stored analog input value
; for this source with the quantised range as the coefficient.
;
; ARGUMENTS:
; Registers:
; * ACCA: Modulation-Source RANGE.
; * ACCB: Modulation-Source ANALOG INPUT.
; * IX:   A pointer to the modulation-source assign flags value. This pointer
;         is then incremented to point to the adjacent value register, then
;         incremented again to point to the next modulation-source.
;
; MEMORY USED:
; * 0xBA:   The total EG Bias value.
;
; ==============================================================================

MOD_CALCULATE_SOURCE_SCALED_INPUT:
    PSHB
    JSR     PATCH_LOAD_QUANTISE_VALUE
    PSHA
    LDAB    0,x

; Load the relevant modulation flags into B.
; Check the bitmask corresponding to EG Bias.
    BITB    #%100
    BEQ     .STORE_SCALED_INPUT

; If EG Bias is enabled for this modulation-source, then add the
; quantised range value to the EG Bias register.
; Set to 0xFF in the case of overflow.
    ADDA    <M_EG_BIAS_TOTAL_RANGE
    BCC     .STORE_EG_BIAS
    LDAA    #$FF

.STORE_EG_BIAS:
    STAA    <M_EG_BIAS_TOTAL_RANGE

.STORE_SCALED_INPUT:
    PULA
    PULB

; Multiply the MSB of the quantised RANGE value together with the raw input
; value, and increment the pointer to store the MSB of the result in the
; adjacent register.
    MUL
    INX
    STAA    0,x
    INX
    RTS


; ==============================================================================
; MOD_AMP_SUM_MOD_SOURCE
; ==============================================================================
; LOCATION: 0xE272
;
; DESCRIPTION:
; This function parses the 'modulation factor' for a particular modulation
; source (Mod Wheel, Foot Controller, Breath Controller). It checks the flags
; associated with this modulation source to see if this source is assigned to
; modulate amplitude. If so, the computed 'modulation factor' for this source
; is added to the total amplitude modulation amount.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the modulation-source flags value, which is incremented
;         to point to its adjacent modulation value register.
;
; RETURNS:
; * ACCB: The total amplitude modulation amount.
;
; ==============================================================================

MOD_AMP_SUM_MOD_SOURCE:
    LDAA    0,x

; Increment so IX points to the modulation value register.
    INX

; Load the 'Modulation-Source' flags into A, and check if the flag
; corresponding to 'Amp Modulation' is set.
    BITA    #%10
    BEQ     .END_MOD_AMP_SUM_MOD_SOURCE

; If the flag corresponding to enabling amplitude modulation is set,
; then add the modulation-source value to ACCB, which is used to set
; the amplitude modulation amount register.
    ADDB    0,x

; If the value overflows, set to 0xFF.
    BCC     .END_MOD_AMP_SUM_MOD_SOURCE
    LDAB    #$FF

.END_MOD_AMP_SUM_MOD_SOURCE:
    RTS


; ==============================================================================
; MOD_SUM_MOD_SOURCE_EG_BIAS
; ==============================================================================
; LOCATION: 0xE280
;
; DESCRIPTION:
; Checks if 'EG Bias' is enabled for a particular modulation-source. If so,
; the modulation-source's scaled input is added to ACCB.
;
; The carry flag is set on overflow, and indicate to the caller that an
; arithmetic overflow has occurred.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the modulation-source flags value, which is incremented
;         to point to its adjacent modulation value register.
;
; RETURNS:
; * ACCB: The total EG Bias amount.
;
; ==============================================================================

MOD_SUM_MOD_SOURCE_EG_BIAS:
    LDAA    0,x
    INX
    BITA    #%100
    BEQ     .END_MOD_SUM_MOD_SOURCE_EG_BIAS
    ADDB    0,x
    BCC     .END_MOD_SUM_MOD_SOURCE_EG_BIAS
    LDAB    #$FF

.END_MOD_SUM_MOD_SOURCE_EG_BIAS:
    RTS


; ==============================================================================
; PATCH_LOAD_QUANTISE_LFO_SPEED
; ==============================================================================
; LOCATION: 0xE28E
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the LFO speed, in patch memory.
;
; DESCRIPTION:
; Parses, and quantises the LFO speed value. This subroutine is called during
; the loading of patch data.
;
; RETURNS:
; * ACCD: The parsed LFO speed value.
;
; ==============================================================================

PATCH_LOAD_QUANTISE_LFO_SPEED:
    LDAA    0,x

; If the LFO speed is set to zero, clamp it to a minimum of '1'. This is
; done so that the LFO software arithmetic works.
    BNE     .LFO_SPEED_NON_ZERO
    INCA
    BRA     .SET_TO_MINIMUM

.LFO_SPEED_NON_ZERO:
    JSR     PATCH_LOAD_QUANTISE_VALUE
    CMPA    #160

; If the result is less than 160, branch.
    BCS     .SET_TO_MINIMUM
    TAB
    SUBB    #160
    LSRB
    LSRB
    ADDB    #11
    BRA     .END_PATCH_LOAD_QUANTISE_LFO_SPEED

.SET_TO_MINIMUM:
    LDAB    #11

.END_PATCH_LOAD_QUANTISE_LFO_SPEED:
    MUL
    RTS


; ==============================================================================
; PATCH_LOAD_QUANTIZE_LFO_DELAY
; ==============================================================================
; LOCATION: 0xE2A9
;
; DESCRIPTION:
; Processes the patch's LFO delay value to compute the LFO delay increment.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the synth's LFO delay value in patch memory.
;
; MEMORY USED:
; * 0xAB:   Scratch register used to compute the quantised value.
; * 0xAC:   Scratch register used to compute the quantised value.
;
; RETURNS:
; * ACCD: The parsed LFO delay value.
;
; ==============================================================================

PATCH_LOAD_QUANTIZE_LFO_DELAY:
    LDAA    #99
    SUBA    0,x
    STAA    <$AB
    ANDA    #%1110000
    LDAB    #16
    MUL
    STAA    <$AC
    LDAA    #7
    SUBA    <$AC
    STAA    <$AC
    LDAA    <$AB
    ANDA    #15
    ORAA    #16
    ASLA
    CLRB

; Performs a rotate right of ACCA, and ACCB.

.ROTATE_LOOP:
    LSRA
    RORB
    DEC     $AC
    BNE     .ROTATE_LOOP
    RTS


; ==============================================================================
; PITCH_BEND_PARSE
; ==============================================================================
; LOCATION: 0xE2CC
;
; DESCRIPTION:
; Parses the incoming pitch-bend value, which has come from analog, or MIDI
; input. Converting it to a pitch increment, which is used when computing the
; final pitch modulation values which are loaded to the EGS' pitch modulation
; register.
;
; ==============================================================================

PITCH_BEND_PARSE:
    LDAB    M_PITCH_BEND_INPUT

; Shift right to quantise the incoming pitch-bend value to 0-127.
; Use this as an index into the pitch-bend table.
    LSRB
    LDX     #TABLE_PITCH_BEND
    ABX
    LDAA    0,x

; Shift left, and invert the sign bit (bit 7).
; This has the effect of 'correcting' the signedness of the pitch shift
; value. Since (after shifting) 0-127 represent a negative shift, and
; 128-255 positive.
; This signedness wil be used in the following calculations.
    ASLA
    EORA    #%10000000
    STAA    <M_PITCH_BEND_INPUT_SIGNED

.IS_PITCH_BEND_STEP_ZERO?:
    LDAB    M_PITCH_BND_STEP
    BNE     .BEND_STEP_NOT_0

.IS_BEND_RANGE_12?:
    LDAB    M_PITCH_BND_RANGE
    CMPB    #12
    BEQ     .BEND_RANGE_12

.LOAD_BEND_CENTS:
    LDX     #TABLE_PITCH_BEND_CENTS
    ABX
    LDAB    0,x

.IS_BEND_NEGATIVE?:
    TSTA
    BMI     .BEND_IS_NEGATIVE
    ASLA
    MUL
    BRA     .QUANTISE_PITCH_BEND

.BEND_IS_NEGATIVE:
    COMA
    ASLA
    MUL
    COMB

.RESET_NEGATIVE_BEND_VALUE:
    COMA

.QUANTISE_PITCH_BEND:
    LSRD
    LSRD

.IS_PITCH_BEND_NEGATIVE?:
    TST     M_PITCH_BEND_INPUT_SIGNED
    BPL     .STORE_PITCH_BEND_VALUE
    ORAA    #%11000000
    BRA     .STORE_PITCH_BEND_VALUE

.BEND_RANGE_12:
    CLRB
    TSTA
    BMI     .RANGE_12_BEND_IS_NEGATIVE

; I'm not sure what the purpose of this clamping here is.
; If the quantised pitch bend value is 126, the final pitch bend value
; effectively becomes 0x3FFF.
    CMPA    #126
    BNE     .SCALE_VALUE
    LDD     #$7FFF

.SCALE_VALUE:
    LSLD
    BRA     .QUANTISE_PITCH_BEND

.RANGE_12_BEND_IS_NEGATIVE:
    COMA
    SEC
    ROLA
    BRA     .RESET_NEGATIVE_BEND_VALUE

.BEND_STEP_NOT_0:                               ; B = B % 16.
    ANDB    #%1111

.IS_BEND_POSITIVE?:
    TSTA
    BPL     .BEND_IS_POSITIVE
    COMA

.BEND_IS_POSITIVE:
    LDX     #TABLE_PITCH_BEND_STEP
    STAB    <M_PITCH_BEND_STEP_VALUE
    ASLB
    ADDB    <M_PITCH_BEND_STEP_VALUE
    ABX
    LDAB    0,x
    INX
    MUL
    TSTA
    BNE     .STORE_PITCH_BEND_STEP
    LDD     #0
    BRA     .STORE_PITCH_BEND_VALUE

.STORE_PITCH_BEND_STEP:
    STAA    <M_PITCH_BEND_STEP_VALUE
    LDD     0,x

.SETUP_PITCH_BEND_STEP_LOOP:
    DEC     M_PITCH_BEND_STEP_VALUE
    BEQ     .IS_PITCH_BEND_POSITIVE?
    ADDD    0,x
    BRA     .SETUP_PITCH_BEND_STEP_LOOP

.IS_PITCH_BEND_POSITIVE?:
    TST     M_PITCH_BEND_INPUT_SIGNED
    BPL     .STORE_PITCH_BEND_VALUE
    COMA
    COMB

.STORE_PITCH_BEND_VALUE:
    STD     M_PITCH_BEND_VALUE
    RTS


; ==============================================================================
; Length: 48.
; ==============================================================================
TABLE_PITCH_BEND_STEP:
    FDB 0
    FDB $19
    FDB $555
    FDB $D0A
    FDB $AA09
    FDB $1000
    FDB $715
    FDB $5505
    FDB $1AAA
    FDB $520
    FDB 3
    FDB $2555
    FDB $32A
    FDB $AA03
    FDB $3000
    FDB $335
    FDB $5503
    FDB $3AAA
    FDB $33F
    FDB $FF00
    FDB 0
    FDB 0
    FDB 0
    FDB 0

; ==============================================================================
; Length: 13.
; ==============================================================================
TABLE_PITCH_BEND_CENTS:
    FCB 0
    FCB $16
    FCB $2B
    FCB $41
    FCB $56
    FCB $6B
    FCB $81
    FCB $97
    FCB $AC
    FCB $C2
    FCB $D7
    FCB $EC
    FCB $FF

; ==============================================================================
; Length: 128.
; ==============================================================================
TABLE_PITCH_BEND:
    FCB 0, 1, 2, 3, 4, 5, 6
    FCB 7, 8, 9, $A, $B, $C
    FCB $D, $E, $F, $10, $11
    FCB $12, $13, $14, $15, $16
    FCB $17, $18, $19, $1A, $1B
    FCB $1C, $1D, $1E, $1F, $20
    FCB $21, $22, $23, $24, $25
    FCB $26, $27, $28, $2A, $2B
    FCB $2C, $2D, $2E, $2F, $30
    FCB $31, $32, $33, $34, $35
    FCB $36, $37, $38, $39, $3A
    FCB $3B, $3C, $3D, $3E, $3F
    FCB $40, $40, $40, $41, $42
    FCB $43, $44, $45, $46, $47
    FCB $48, $49, $4A, $4B, $4C
    FCB $4D, $4E, $4F, $50, $51
    FCB $52, $53, $54, $55, $56
    FCB $58, $59, $5A, $5B, $5C
    FCB $5D, $5E, $5F, $60, $61
    FCB $62, $63, $64, $65, $66
    FCB $67, $68, $69, $6A, $6B
    FCB $6C, $6D, $6E, $6F, $70
    FCB $71, $72, $73, $74, $75
    FCB $76, $77, $78, $79, $7A
    FCB $7B, $7C, $7D, $7E
    FCB $7F


; ==============================================================================
; PATCH_LOAD_DATA
; ==============================================================================
; DESCRIPTION:
; This subroutine loads data from the patch 'Edit Buffer', parses it, and loads
; it into the synth memory, and peripheral registers specific to the currently
; loaded patch. This function is called as part of the patch loading process.
; It is responsible for loading pitch, and amplitude modulation data, as well
; as operator keyboard scaling, and the LFO.
;
; ==============================================================================

PATCH_LOAD_DATA:
    JSR     EGS_RESET_VOICES

.LOAD_EG_RATES:
    LDD     #PATCH_LOAD_OPERATOR_EG_RATES
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR

.LOAD_EG_LEVELS:
    LDD     #PATCH_LOAD_OPERATOR_EG_LEVELS
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR

.LOAD_KEYBOARD_SCALING:
    LDD     #PATCH_LOAD_OPERATOR_KBD_SCALING
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR

.LOAD_KEYBOARD_VEL_SENS:
    LDD     #PATCH_LOAD_OPERATOR_KBD_VEL_SENS
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR

.LOAD_OPERATOR_PITCH:
    LDD     #PATCH_LOAD_OPERATOR_PITCH
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR

.LOAD_RATE_SCALING:
    LDD     #PATCH_LOAD_OPERATOR_KBD_RATE_SCALING
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR

.LOAD_DETUNE:
    LDD     #PATCH_LOAD_OPERATOR_DETUNE
    STD     M_PATCH_LOAD_FUNC_PTR
    JSR     PATCH_LOAD_CALL_FUNC_PTR
    JSR     PATCH_LOAD_PITCH_EG_VALUES
    JSR     PATCH_LOAD_ALG_MODE
    JSR     PATCH_LOAD_LFO
    RTS


; ==============================================================================
; HANDLER_OCF
; ==============================================================================
; LOCATION: 0xE453
;
; DESCRIPTION:
; Handles the OCF (Output Compare Counter) timer interrupt (IRQ2).
; This is where all of the synth's periodicly repeated functions are called.
;
; ==============================================================================

HANDLER_OCF:
    CLR     TIMER_CTRL_STATUS
    LDAA    <TIMER_CTRL_STATUS                  ; Clear OCF IRQ.

.RESET_FRC:
    LDX     #0
    STX     <FREE_RUNNING_COUNTER

.RESET_OCF:
    LDX     #3140
    STX     <OUTPUT_COMPARE
    CLI

; Test if the synth is checking for incoming active sensing messages.
    TST     M_MIDI_ACTV_SENS_RX_ENABLE
    BEQ     .PROCESS_MODULATION

.PROCESS_RX_ACTV_SENSING:
    LDAA    <M_MIDI_SUBSTATUS
    CMPA    #MIDI_SUBSTATUS_BULK

; If the synth is processing a bulk SYSEX dump, ignore active sensing.
    BEQ     .PROCESS_MODULATION

; Increment the active sensing counter.
; If an active sensing message has not been received in 250 'checks',
; then proceed to stopping all voices.
    INC     M_MIDI_ACTV_SENS_RX_CTR
    LDAA    <M_MIDI_ACTV_SENS_RX_CTR
    CMPA    #250
    BNE     .PROCESS_MODULATION
    JSR     MIDI_ACTIVE_SENSING_STOP
    LDAA    #7
    STAA    P_DAC
    CLR     M_MIDI_PROCESSED_DATA_COUNT
    CLR     M_MIDI_ACTV_SENS_RX_ENABLE

; The variable at 0x232C is 'toggled' On/Off with each interrupt.
; This flag is used to determine whether pitch modulation should be
; updated in this interrupt. The effect is that pitch-mod is processed once
; every two interrupts.

.PROCESS_MODULATION:
    COM     M_PITCH_UPDATE_TOGGLE
    JSR     LFO_GET_AMPLITUDE
    JSR     MOD_AMP_LOAD_TO_EGS

; If there is received MIDI data pending processing, then ignore
; updating the EGS with modulation data.
    TST     M_MIDI_RX_BUFFER_PENDING
    BNE     .PROCESS_TX_ACTV_SENSING

.COMPUTE_PORTA?:
    JSR     PORTA_PROCESS
    TST     M_PITCH_UPDATE_TOGGLE
    BPL     .PROCESS_TX_ACTV_SENSING
    JSR     PITCH_EG_PROCESS
    JSR     MAIN_COMPARE_PATCH_LED_BLINK

.PROCESS_TX_ACTV_SENSING:
    INC     M_MIDI_ACTV_SENS_TX_CNTR
    LDAA    M_MIDI_ACTV_SENS_TX_CNTR
    CMPA    #50
    BLS     .HANDLER_OCF_LOAD_PITCH_MOD_TO_EGS
    CLR     M_MIDI_ACTV_SENS_TX_CNTR
    LDAA    #1
    STAA    M_MIDI_ACTV_SENS_TX_TRIGGER

.HANDLER_OCF_LOAD_PITCH_MOD_TO_EGS:
    JSR     MOD_PITCH_LOAD_TO_EGS

.RESET_TIMER:
    LDAA    #%1000
    STAA    <TIMER_CTRL_STATUS                  ; Re-enable OCF IRQ.
    RTI                                         ; Return from interrupt.


; ==============================================================================
; MAIN_COMPARE_PATCH_LED_BLINK
; ==============================================================================
; LOCATION: 0xE4BB
;
; DESCRIPTION:
; Uses a counter in memory to 'toggle' the LED patch number, creating a
; 'blinking' effect when the synth is in 'compare patch' mode.
; This functions by incrementing a counter with each timer interrupt, until it
; overflows. If bit 6 of the counter is set (counter <= 127), then the LED
; contents will be cleared.
;
; ==============================================================================

MAIN_COMPARE_PATCH_LED_BLINK:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG

; If we're not in 'Patch Compare' mode, exit.
    CMPA    #EDITED_PATCH_IN_COMPARE
    BNE     .END_MAIN_COMPARE_PATCH_LED_BLINK
    INC     M_COMPARE_PATCH_LED_BLINK_COUNTER
    LDAA    M_COMPARE_PATCH_LED_BLINK_COUNTER
    ANDA    #%11111
    BNE     .END_MAIN_COMPARE_PATCH_LED_BLINK   ; If A % 32 != 0, exit.
    LDAA    M_COMPARE_PATCH_LED_BLINK_COUNTER

; If Bit 6 is set, show the number.
    BITA    #%100000
    BNE     .PRINT_PATCH_NUMBER_AND_EXIT

.CLEAR_LED:
    LDAA    #$FF
    STAA    P_LED2
    STAA    P_LED1

.END_MAIN_COMPARE_PATCH_LED_BLINK:
    RTS

.PRINT_PATCH_NUMBER_AND_EXIT:
    JMP     LED_PRINT_PATCH_NUMBER


; ==============================================================================
; MIDI_ACTIVE_SENSING_STOP
; ==============================================================================
; LOCATION: 0xE4DF
;
; DESCRIPTION:
; This subroutine handles the scenario where MIDI active sensing is enabled,
; and the synth times out while awaiting an active sensing update.
; It deactivates all active voices.
;
; ==============================================================================

MIDI_ACTIVE_SENSING_STOP:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA
    JSR     VOICE_DEACTIVATE_ALL
    PULA
    STAA    <IO_PORT_2_DATA
    RTS


; ==============================================================================
; PORTA_PROCESS
; ==============================================================================
; DESCRIPTION:
; This subroutine is where the current portamento, and glissando pitches for
; each of the synth's voices are updated, and loaded to the EGS chip.
; Only half of the synth's voices are updated at a time. Refer to the
; comments below regarding the switch variable that controls this.
;
; ==============================================================================

PORTA_PROCESS:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     DELAY

; This flag acts as a 'toggle' switch to control which voices are processed.
; If this flag is set, then process voices 8-15, then clear the flag.
; If this flag is not set, process voices 0-7, then set the flag.
; ACCB is used as an index into the 32 byte voice buffers, so setting
; it to '16' will start the processing at voice 8.
    TST     M_PORTA_UPDATE_VOICE_SWITCH
    BNE     .PROCESS_VOICE_8_TO_15
    COM     M_PORTA_UPDATE_VOICE_SWITCH
    CLRB
    BRA     .PORTA_PROCESS_SETUP_POINTERS

.PROCESS_VOICE_8_TO_15:
    CLR     M_PORTA_UPDATE_VOICE_SWITCH
    LDAB    #16

; Initialiase the pointers used within the function.

.PORTA_PROCESS_SETUP_POINTERS:
    LDX     #M_VOICE_PITCH_EG_CURR_LEVEL
    ABX
    STX     <M_VOICE_PITCH_EG_CURR_LVL_PTR

.SETUP_POINTERS_PORTA:
    LDX     #M_VOICE_PITCH_PORTAMENTO
    ABX
    STX     <M_VOICE_PITCH_PORTA_PTR

.SETUP_POINTERS_GLISS:
    LDX     #M_VOICE_PITCH_GLISSANDO
    ABX
    STX     <M_VOICE_PITCH_GLISS_PTR

.SETUP_POINTERS_EGS:
    LDX     #P_EGS_VOICE_PITCH
    ABX
    STX     <M_EGS_PITCH_PTR

.SETUP_POINTERS_TARGET:
    LDX     #M_VOICE_PITCH_TARGET
    ABX
    STX     <M_VOICE_PITCH_TARGET_PTR

.PORTA_PROCESS_SET_LOOP_INDEX:
    LDAA    #8
    STAA    <M_PORTA_PROCESS_LOOP_IDX

.PORTA_PROCESS_VOICE_LOOP_START:
    LDD     0,x
    STD     <M_VOICE_PORTA_PITCH_FINAL
    LDX     <M_VOICE_PITCH_PORTA_PTR
    LDD     0,x

; Check whether this voice's current portamento pitch is above or below
; the voice's target pitch.
; If *(0xVOICE_PITCH_PORTA[B]) - *(VOICE_PITCH_TARGET[B]) < 0, branch.

.IS_PITCH_ABOVE_OR_BELOW_TARGET?:
    SUBD    <M_VOICE_PORTA_PITCH_FINAL
    BMI     .PITCH_BELOW_TARGET

; If the current glissando pitch is above the target pitch, calculate
; the portamento pitch decrement, and subtract it from the current pitch.

.PITCH_ABOVE_TARGET:
    LDAB    <M_PORTA_RATE_INCREMENT

.CALCULATE_PITCH_DECREMENT:
    TST     M_PORTA_GLISS_ENABLED
    BEQ     .GLISSANDO_OFF
    LDAA    #3
    BRA     .STORE_PITCH_DECREMENT

.GLISSANDO_OFF:
    LSRA
    LSRA
    INCA

.STORE_PITCH_DECREMENT:
    MUL
    STD     <M_PORTA_PITCH_INCREMENT

.SUBTRACT_DECREMENT:
    LDX     <M_VOICE_PITCH_PORTA_PTR
    LDD     0,x
    SUBD    <M_PORTA_PITCH_INCREMENT

; If subtracting the decrement causes the resulting pitch to be below the
; target pitch value, clamp at the target pitch.

.IS_BELOW_TARGET?:
    XGDX
    CPX     <M_VOICE_PORTA_PITCH_FINAL
    XGDX
    BCC     .STORE_PORTA_PITCH
    LDD     <M_VOICE_PORTA_PITCH_FINAL

.STORE_PORTA_PITCH:
    LDX     <M_VOICE_PITCH_PORTA_PTR
    STD     0,x
    STD     <M_VOICE_PORTA_PITCH_FINAL
    INX
    INX
    STX     <M_VOICE_PITCH_PORTA_PTR

.IS_GLISSANDO_ENABLED?:
    TST     M_PORTA_GLISS_ENABLED
    BNE     .GLISSANDO_ON
    JMP     .ADD_PITCH_EG_LEVEL

.GLISSANDO_ON:
    LDX     <M_VOICE_PITCH_GLISS_PTR
    LDD     0,x

.IS_GLISS_ABOVE_OR_BELOW?:
    STD     <M_VOICE_PITCH_GLISS_CURRENT
    SUBD    <M_VOICE_PORTA_PITCH_FINAL
    BMI     .GLISS_PITCH_BELOW

.GLISS_PITCH_ABOVE:
    SUBD    #$154
    BPL     .MORE_THAN_HALF_STEP
    JMP     .LOAD_GLISS_PITCH

; Reload current gliss pitch.

.MORE_THAN_HALF_STEP:
    LDD     0,x
    SUBD    #$154
    BRA     .SET_GLISSANDO_INCREMENT

; If the current glissando pitch is below the target pitch, calculate
; the portamento pitch increment, and add it to the current pitch.

.PITCH_BELOW_TARGET:
    LDAB    <M_PORTA_RATE_INCREMENT

.CALCULATE_PITCH_INCREMENT:
    TST     M_PORTA_GLISS_ENABLED
    BEQ     .NEG_GLISSANDO_OFF
    LDAA    #3
    BRA     .GET_PITCH_INCREMENT

.NEG_GLISSANDO_OFF:
    NEGA
    LSRA
    LSRA
    INCA

.GET_PITCH_INCREMENT:
    MUL

.ADD_INCREMENT:
    LDX     <M_VOICE_PITCH_PORTA_PTR
    ADDD    0,x

; If adding the increment causes the resulting pitch to be above the
; target pitch value, clamp at the target pitch.

.IS_ABOVE_TARGET?:
    XGDX
    CPX     <M_VOICE_PORTA_PITCH_FINAL
    XGDX
    BCS     .STORE_PORTA_PITCH_2
    LDD     <M_VOICE_PORTA_PITCH_FINAL

.STORE_PORTA_PITCH_2:
    LDX     <M_VOICE_PITCH_PORTA_PTR
    STD     0,x
    STD     <M_VOICE_PORTA_PITCH_FINAL
    INX
    INX
    STX     <M_VOICE_PITCH_PORTA_PTR

.IS_GLISSANDO_ENABLED_2?:
    TST     M_PORTA_GLISS_ENABLED
    BEQ     .ADD_PITCH_EG_LEVEL

.GLISS_PITCH_BELOW:
    LDX     <M_VOICE_PITCH_GLISS_PTR
    LDD     0,x
    STD     <M_VOICE_PITCH_GLISS_CURRENT
    LDD     <M_VOICE_PORTA_PITCH_FINAL
    SUBD    0,x
    SUBD    #$154
    BMI     .LOAD_GLISS_PITCH
    LDD     0,x
    ADDD    #$155

.SET_GLISSANDO_INCREMENT:
    STAA    <M_PORTA_PITCH_INCREMENT
    INCA
    ANDA    #3
    BNE     .GET_GLISSANDO_PITCH
    LDAA    <M_PORTA_PITCH_INCREMENT
    INCA
    STAA    <M_PORTA_PITCH_INCREMENT

.GET_GLISSANDO_PITCH:
    LDAA    <M_PORTA_PITCH_INCREMENT
    LDAB    #3
    ANDA    #3
    STAA    <M_GLISSANDO_PITCH_LSB

.GET_GLISSANDO_PITCH_LSB:
    ORAA    <M_GLISSANDO_PITCH_LSB
    ASLA
    ASLA
    DECB
    BNE     .GET_GLISSANDO_PITCH_LSB
    STAA    <M_GLISSANDO_PITCH_LSB
    LDD     <M_PORTA_PITCH_INCREMENT
    STD     0,x
    BRA     .INCREMENT_PTR

.LOAD_GLISS_PITCH:
    LDD     <M_VOICE_PITCH_GLISS_CURRENT

.INCREMENT_PTR:
    LDX     <M_VOICE_PITCH_GLISS_PTR
    INX
    INX
    STX     <M_VOICE_PITCH_GLISS_PTR

.ADD_PITCH_EG_LEVEL:
    LDX     <M_VOICE_PITCH_EG_CURR_LVL_PTR
    ADDD    0,x
    SUBD    #$1BA8

; If the result after this subtraction would be negative, clamp at 0.
    BCC     .INCREMENT_PITCH_EG_LVL_PTR
    LDD     #0

.INCREMENT_PITCH_EG_LVL_PTR:
    INX
    INX
    STX     <M_VOICE_PITCH_EG_CURR_LVL_PTR

; Add the master tune offset, and then store this final pitch value to
; the EGS pitch buffer.
    ADDD    M_MASTER_TUNE

.PORTA_PROCESS_WRITE_PITCH_TO_EGS:
    LDX     <M_EGS_PITCH_PTR
    STAA    0,x
    INX
    STAB    0,x
    INX
    STX     <M_EGS_PITCH_PTR

.INCRMENT_VOICE_PTR:
    LDX     <M_VOICE_PITCH_TARGET_PTR
    INX
    INX
    STX     <M_VOICE_PITCH_TARGET_PTR

.PORTA_PROCESS_DECREMENT_LOOP_INDEX:
    DEC     M_PORTA_PROCESS_LOOP_IDX
    BEQ     .END_PORTA_PROCESS                  ; If *(0xBD) > 0, loop.
    JMP     .PORTA_PROCESS_VOICE_LOOP_START

.END_PORTA_PROCESS:
    PULA
    STAA    <IO_PORT_2_DATA                     ; Re-enable IRQ.
    RTS


; ==============================================================================
; PITCH_EG_PROCESS
; ==============================================================================
; LOCATION: 0xE616
;
; DESCRIPTION:
; Processes the pitch EG for all voices.
; This subroutine loads the levels of each of the synth's 16 voices, testing
; whether each of them is above, or below the final level for its current
; step. Adding or subtracting the pitch EG rate's corresponding increment
; accordingly.
;
; ==============================================================================

PITCH_EG_PROCESS:
    LDX     #M_VOICE_PITCH_EG_CURR_LEVEL
    STX     <M_PITCH_EG_VOICE_LEVELS_PTR
    LDX     #M_VOICE_PITCH_EG_CURR_STEP
    STX     <M_PITCH_EG_VOICE_STEP_PTR
    LDAB    #16
    STAB    <M_PITCH_EG_VOICE_INDEX

; Check whether the current pitch EG step is '3'. This indicates that the
; pitch EG for this voice is has reached its 'sustain' value.
; When a voice is removed, the pitch EG step for that voice is set to '4',
; which places the voice's pitch EG into its 'release' phase.
; This check ensures that a voice that's in its 'note on' phase does not
; process the pitch EG past the sustain phase.

.VOICE_PROCESS_EG_LOOP:
    LDAA    0,x
    CMPA    #3
    BNE     .IS_ENV_STEP_5?
    JMP     .INCREMENT_POINTERS

; As noted above, when a voice is removed its pitch EG step is set to '4'.
; This places the voice in its 'release' phase.
; This check ensures that if the voice has reached step '5' (the end), it
; will not be processed further.

.IS_ENV_STEP_5?:
    CMPA    #5
    BNE     .PROCESS_EG_STAGE
    JMP     .INCREMENT_POINTERS

; Load the pitch EG values, clamping the index at 3.

.PROCESS_EG_STAGE:
    LDX     #M_PATCH_PITCH_EG_VALUES
    CMPA    #3
    BCS     .LOAD_PITCH_EG_RATE
    LDAA    #3

; The following section loads the current patch's parsed pitch EG rate,
; using ACCB as an index into the 4 entry array.
; This value is used to compute the 'Pitch EG increment' value, which is
; the delta for each iteration of processing the pitch EG.
; It then loads the current patch's parsed pitch EG level, using ACCB as an
; index into this array, and uses this to compute the 'next' EG level, which
; the current level is compared against.

.LOAD_PITCH_EG_RATE:
    TAB
    ABX
    LDAB    0,x                                 ; Load PITCH_EG_RATE[B].
    CLRA
    STD     <M_PITCH_EG_INCREMENT

.LOAD_PITCH_EG_LEVEL:                           ; Load PITCH_EG_LEVEL[B].
    LDAA    4,x
    CLRB
    LSRD
    STD     <M_PITCH_EG_NEXT_LVL

; Compare the current pitch EG level against the 'next' level.
; If it is equal, the incrementing/decrementing step is skipped.

.COMPARE_TO_CURRENT:
    LDX     <M_PITCH_EG_VOICE_LEVELS_PTR
    LDX     0,x
    CPX     <M_PITCH_EG_NEXT_LVL
    BEQ     .EG_STEP_FINISHED

; Test whether the current level is above or below the final, target level.

.IS_LEVEL_HIGHER?:
    BCS     .PITCH_EG_LEVEL_HIGHER


; Subtract the increment value from the current level. If the value goes
; below 0, this means that the current step is finished.

.PITCH_EG_LEVEL_LOWER:
    LDX     <M_PITCH_EG_VOICE_LEVELS_PTR
    LDD     0,x
    SUBD    <M_PITCH_EG_INCREMENT
    BMI     .EG_STEP_FINISHED

.IS_PITCH_EG_LEVEL_LOWER_FINISHED?:
    CMPA    <M_PITCH_EG_NEXT_LVL
    BHI     .EG_STEP_NOT_FINISHED
    BRA     .EG_STEP_FINISHED

; If the target pitch EG level is higher than the current level, add the
; pitch EG increment to the current level, and compare.

.PITCH_EG_LEVEL_HIGHER:
    LDX     <M_PITCH_EG_VOICE_LEVELS_PTR
    LDD     0,x
    ADDD    <M_PITCH_EG_INCREMENT
    CMPA    <M_PITCH_EG_NEXT_LVL

; If the value is still higher than the target, branch.
; Otherwise we know we're at the final level for this step.
    BCS     .EG_STEP_NOT_FINISHED

; If this EG step has finished, store the 'next' pitch EG level in the
; 'current' level. This has the purpose of allowing the value to overflow,
; or underflow during the increment stage without causing any ill-effects.

.EG_STEP_FINISHED:
    LDD     <M_PITCH_EG_NEXT_LVL
    LDX     <M_PITCH_EG_VOICE_LEVELS_PTR
    STD     0,x

; Increment the EG step. If the step is 6 after incrementing, set to 0.

.INCREMENT_EG_STEP:
    LDX     <M_PITCH_EG_VOICE_STEP_PTR
    LDAA    0,x
    INCA
    CMPA    #6
    BNE     .STORE_ENV_STEP
    CLRA

.STORE_ENV_STEP:
    STAA    0,x
    BRA     .INCREMENT_POINTERS

; If the current step is not finished, save the current level.

.EG_STEP_NOT_FINISHED:
    LDX     <M_PITCH_EG_VOICE_LEVELS_PTR
    STD     0,x

; Increment the pointers to point to the next voice.

.INCREMENT_POINTERS:
    LDX     <M_PITCH_EG_VOICE_LEVELS_PTR
    INX
    INX
    STX     <M_PITCH_EG_VOICE_LEVELS_PTR

.INCREMENT_EG_STEP_PTR:
    LDX     <M_PITCH_EG_VOICE_STEP_PTR
    INX
    STX     <M_PITCH_EG_VOICE_STEP_PTR

.DECREMENT_EG_VOICE_LOOP_COUNTER:
    DEC     M_PITCH_EG_VOICE_INDEX
    BEQ     .END_PITCH_EG_PROCESS               ; If CC > 0, loop.
    JMP     .VOICE_PROCESS_EG_LOOP

.END_PITCH_EG_PROCESS:
    RTS


; ==============================================================================
; MOD_AMP_LOAD_TO_EGS
; ==============================================================================
; LOCATION: 0xE698
;
; DESCRIPTION:
; This subroutine calculates the final amplitude modulation value, and loads
; it to the appropriate register in the EGS.
;
; ==============================================================================

MOD_AMP_LOAD_TO_EGS:
    LDAB    <M_LFO_FADE_IN_SCALE_FACTOR
    LDAA    M_LFO_AMP_MOD_DEPTH

; Calculate the LFO 'Fade-In factor'. Add the amplitude modulation factor to
; this value. If it overflows, clamp at 0xFF.
    MUL
    ADDA    <M_MOD_AMP_FACTOR
    BCC     .CLAMP_EG_BIAS
    LDAA    #$FF

; Add the 'EG Bias' value to test whether this value overflows.
; If it does, clamp at 0xFF. Afterwards, in all cases, subtract the EG
; Bias value.

.CLAMP_EG_BIAS:
    ADDA    <M_MOD_AMP_EG_BIAS_TOTAL
    BCC     .CALCULATE_AM_MOD_TOTAL
    LDAA    #$FF

.CALCULATE_AM_MOD_TOTAL:
    SUBA    <M_MOD_AMP_EG_BIAS_TOTAL
    LDAB    <M_LFO_CURR_AMPLITUDE

; Perform the two's complement of the LFO amplitude, and clear the sign bit
; to convert this to a value suitable for multiplication, then multiply
; this value with the total amplitude modulation factor.
    COMB
    EORB    #128
    MUL

; Add the 'EG Bias' value. If it overflows, clamp at 0xFF.

.MOD_AMP_LOAD_ADD_EG_BIAS:
    ADDA    <M_MOD_AMP_EG_BIAS_TOTAL
    BCC     .LOAD_AMP_MOD_TO_EGS
    LDAA    #$FF

; Perform two's complement negation to get the correct index into the
; amp modulation table. Load this value, an then transmit it to the EGS'
; amp modulation register.

.LOAD_AMP_MOD_TO_EGS:
    COMA
    LDX     #TABLE_AMP_MOD
    TAB
    ABX
    LDAA    0,x
    STAA    P_EGS_AMP_MOD
    RTS


; ==============================================================================
; Amplitude Modulation Value Lookup Table.
; This is used to get the final amplitude modulation value to load to the EGS.
; Length: 256.
; ==============================================================================
TABLE_AMP_MOD:
    FCB $FF, $FF, $E0, $CD, $C0
    FCB $B5, $AD, $A6, $A0, $9A
    FCB $95, $91, $8D, $89, $86
    FCB $82, $80, $7D, $7A, $78
    FCB $75, $73, $71, $6F, $6D
    FCB $6B, $69, $67, $66, $64
    FCB $62, $61, $60, $5E, $5D
    FCB $5B, $5A, $59, $58, $56
    FCB $55, $54, $53, $52, $51
    FCB $50, $4F, $4E, $4D, $4C
    FCB $4B, $4A, $49, $48, $47
    FCB $46, $46, $45, $44, $43
    FCB $42, $42, $41, $40, $40
    FCB $3F, $3E, $3D, $3D, $3C
    FCB $3B, $3B, $3A, $39, $39
    FCB $38, $38, $37, $36, $36
    FCB $35, $35, $34, $33, $33
    FCB $32, $32, $31, $31, $30
    FCB $30, $2F, $2F, $2E, $2E
    FCB $2D, $2D, $2C, $2C, $2B
    FCB $2B, $2A, $2A, $2A, $29
    FCB $29, $28, $28, $27, $27
    FCB $26, $26, $26, $25, $25
    FCB $24, $24, $24, $23, $23
    FCB $22, $22, $22, $21, $21
    FCB $21, $20, $20, $20, $1F
    FCB $1F, $1E, $1E, $1E, $1D
    FCB $1D, $1D, $1C, $1C, $1C
    FCB $1B, $1B, $1B, $1A, $1A
    FCB $1A, $19, $19, $19, $18
    FCB $18, $18, $18, $17, $17
    FCB $17, $16, $16, $16, $15
    FCB $15, $15, $15, $14, $14
    FCB $14, $13, $13, $13, $13
    FCB $12, $12, $12, $12, $11
    FCB $11, $11, $11, $10, $10
    FCB $10, $10, $F, $F, $F
    FCB $F, $E, $E, $E, $E, $D
    FCB $D, $D, $D, $C, $C, $C
    FCB $C, $B, $B, $B, $B, $A
    FCB $A, $A, $A, 9, 9, 9
    FCB 9, 8, 8, 8, 8, 8, 7
    FCB 7, 7, 7, 6, 6, 6, 6
    FCB 6, 5, 5, 5, 5, 5, 4
    FCB 4, 4, 4, 4, 3, 3, 3
    FCB 3, 3, 2, 2, 2, 2, 2
    FCB 2, 1, 1, 1, 1, 1, 0
    FCB 0, 0, 0, 0, 0


; ==============================================================================
; MOD_PITCH_LOAD_TO_EGS
; ==============================================================================
; LOCATION: 0xE7C4
;
; DESCRIPTION:
; Calculates the final 'pitch modulation' value, which is then loaded to the
; EGS chip's global pitch modulation register.
; First a value is computed from a combination of the various modulation input
; sources (mod wheel, aftertouch, breath controller, foot controller),
; checking if each of them is assigned to modulate pitch. This value is then
; added to the scaled 'LFO Fade In' amount. This final 8-bit 'Pitch Modulation
; Factor' is then multiplied by the LFO amplitude, which is scaled by the
; 'LFO Pitch Modulation Sensitivity' value. This is then added to the
; quantised pitch bend amount to yield the final pitch modulation amount
; loaded to the EGS.
;
; ==============================================================================

MOD_PITCH_LOAD_TO_EGS:
    LDAA    #4
    CLRB

; Load the first of the sequential modulation sources into IX.
; The loop below iterates through each of these, checking whether each
; of these modulation sources is assigned to modulate pitch. If so,
; the modulation factor for this source is added to the total.
    LDX     #M_MOD_WHEEL_ASSIGN_FLAGS

.LOAD_MOD_SOURCE_LOOP:
    PSHA
    BSR     MOD_PITCH_SUM_MOD_SOURCE

; If the previous operation overflowed, exit.
    BCS     .VALUE_OVERFLOWED
    INX
    PULA
    DECA
    BNE     .LOAD_MOD_SOURCE_LOOP               ; If A > 0, loop.
    BRA     .GET_LFO_FADE_IN_FACTOR

; Clear the ACCA value pushed onto the stack.

.VALUE_OVERFLOWED:
    PULA

; Calculate the LFO 'Fade in' factor, and add this value to the total
; pitch modulation factor computed from the modulation sources above.

.GET_LFO_FADE_IN_FACTOR:
    PSHB
    LDAB    <M_LFO_FADE_IN_SCALE_FACTOR
    LDAA    M_LFO_PITCH_MOD_DEPTH
    MUL
    PULB
    ABA

; If this addition overflows, clamp at 0xFF.
    BCC     .GET_LFO_PITCH_MOD_AMOUNT
    LDAA    #$FF

; Calculate the total amount of the LFO's pitch modulation.
; This is the product of the LFO 'Pitch Mod Sensitivity' factor multiplied
; by the LFO's current amplitude.

.GET_LFO_PITCH_MOD_AMOUNT:
    PSHA
    LDAB    M_LFO_PITCH_MOD_SENS
    LDAA    <M_LFO_CURR_AMPLITUDE

; If the wave is currently in its negative phase, invert before and after
; the multiplication operation.

.IS_LFO_WAVE_NEGATIVE?:
    BMI     .LFO_WAVE_NEGATIVE

.LFO_WAVE_POSITIVE:
    MUL
    BRA     .IS_FINAL_LFO_AMP_NEGATIVE?

.LFO_WAVE_NEGATIVE:
    NEGA
    MUL
    NEGA

; Pull the total modulation factor computed earlier, and multiply this by
; the quantised LFO amplitude.

.IS_FINAL_LFO_AMP_NEGATIVE?:
    PULB
    TSTA
    BMI     .LFO_MOD_NEGATIVE

.LFO_MOD_POSITIVE:
    MUL
    BRA     .LOAD_PITCH_MOD_TO_EGS

.LFO_MOD_NEGATIVE:
    NEGA
    MUL
    COMA
    COMB
    ADDD    #1

; Compute the final pitch modulation value, and write this value to the
; EGS' two 8-bit pitch modulation registers.

.LOAD_PITCH_MOD_TO_EGS:
    ASRA
    RORB
    ADDD    M_PITCH_BEND_VALUE
    STAA    P_EGS_PITCH_MOD_HIGH
    STAB    P_EGS_PITCH_MOD_LOW
    RTS


; ==============================================================================
; MOD_PITCH_LOAD_MOD_SOURCE
; ==============================================================================
; DESCRIPTION:
; This function parses the 'modulation factor' for a particular modulation
; source (Mod Wheel, Foot Controller, Breath Controller). It checks the flags
; associated with this modulation source to see if this source is assigned to
; modulate pitch. If so, the computed 'modulation factor' for this source is
; added to the total pitch modulation amount.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the modulation source assignment flags.
;
; RETURNS:
; * ACCB: The TOTAL modulation source.
;
; ==============================================================================

MOD_PITCH_SUM_MOD_SOURCE:
    LDAA    0,x
    INX
    BITA    #1

; Load the 'Assign Flags' for this modulation source.
; If the flag for 'Pitch' is not set, return.
    BEQ     .END_MOD_PITCH_SUM_MOD_SOURCE

; If the flag corresponding to enabling pitch modulation is set,
; then add the modulation-source value to ACCB, which is used to set
; the enabling modulation amount register.

.ADD_TO_PITCH_MOD_AMOUNT:
    ADDB    0,x

; If this overflows, set to 0xFF.
    BCC     .END_MOD_PITCH_SUM_MOD_SOURCE
    LDAB    #$FF

.END_MOD_PITCH_SUM_MOD_SOURCE:
    RTS


; ==============================================================================
; LFO_GET_AMPLITUDE
; ==============================================================================
; LOCATION: 0xE81A
;
; DESCRIPTION:
; Calculates the instantaneous amplitude of the synth's LFO at its current
; phase, depending on the LFO delay, and LFO type.
;
; ==============================================================================

LFO_GET_AMPLITUDE:
    LDD     <M_LFO_DELAY_COUNTER
    ADDD    M_LFO_DELAY_INCREMENT

; After adding the increment, does this overflow?
    BCC     .STORE_LFO_DELAY_COUNTER

; If the LFO delay counter has overflowed its 16-bit register, then the
; 'Fade In' counter becomes active. This counter constitutes a
; 'scale factor' for the overall LFO modulation amount.
; This value is incremented by the MSB of the delay increment, which is
; clamped to a value of '1' if it is 0.
; The LFO delay counter is clamped at 0xFFFF. This means that once this
; value overflows 16-bits once it is effectively locked at 0xFFFF until
; reset by the voice add trigger.

; Use the MSB of the delay increment to increment the LFO Fade In
; counter. If the LSB is '0', it is set to '1'.
    LDAB    M_LFO_DELAY_INCREMENT
    BNE     .INCREMENT_FADE_IN_COUNTER
    LDAB    #1

.INCREMENT_FADE_IN_COUNTER:
    ADDB    <M_LFO_FADE_IN_SCALE_FACTOR
    BCC     .STORE_FADE_IN_COUNTER
    LDAB    #$FF

.STORE_FADE_IN_COUNTER:
    STAB    <M_LFO_FADE_IN_SCALE_FACTOR
    LDD     #$FFFF

.STORE_LFO_DELAY_COUNTER:
    STD     <M_LFO_DELAY_COUNTER
    LDD     <M_LFO_PHASE_ACCUMULATOR
    ADDD    M_LFO_PHASE_INCREMENT

; If the phase counter overflows, then clear the 'Sample+Hold Reset Flag'.
; This flag is used to determine whether a new value needs to be 'sampled'
; for a Sample+Hold LFO.
    BVC     .CLEAR_SH_FLAG

; To set the MSB of this flag the carry-bit is set, and then 'rotated' into
; the highest bit of the flag variable.
    SEC
    ROR     M_LFO_SAMPLE_HOLD_RESET_FLAG
    BRA     .IS_LFO_WAVE_0?

.CLEAR_SH_FLAG:
    CLR     M_LFO_SAMPLE_HOLD_RESET_FLAG

.IS_LFO_WAVE_0?:
    STD     <M_LFO_PHASE_ACCUMULATOR
    LDAA    M_LFO_WAVEFORM
    BNE     .IS_LFO_WAVE_4?

; For the Triangle LFO The two-byte LFO phase accumulator is shifted to the
; left. If the MSB is set, then the one's complement of the accumulator's MSB
; is taken to invert the wave vertically.
; 128 is then added to centre the wave around 0.

.LFO_TRIANGLE:
    LDD     <M_LFO_PHASE_ACCUMULATOR
    STAA    <M_LFO_TRI_ACCUMULATOR

; These two instructions essentially form one rotation left of D,
; shifting the bit 7 from B into bit 0 of A.
    ASLB
    ROLA
    TST     M_LFO_TRI_ACCUMULATOR
    BPL     .LFO_TRIANGLE_STORE
    COMA

.LFO_TRIANGLE_STORE:
    ADDA    #128
    BRA     .STORE_AND_EXIT

.IS_LFO_WAVE_4?:
    CMPA    #LFO_WAVE_SINE
    BNE     .IS_LFO_WAVE_1?

; The following sequence computes the index into the Sine LFO LUT.
; This performs a modulo operation limiting the accumulator to the length of
; the sine table (64), and then inverts the resulting index horizontally if
; the accumulator value had bit 6 set.
; The corresponding instantaneous amplitude is then looked up in the Sine LFO
; table. If bit 7 of the accumulator's MSB is set, indicating that the
; accumulator was in the second-half of its phase, then the one's complement
; of the amplitude is computed to invert the amplitude.

.LFO_SINE:
    LDAA    <M_LFO_PHASE_ACCUMULATOR
    TAB
    ANDB    #63                                 ; B = B % 64.
    BITA    #64
    BEQ     .LFO_SINE_LOOKUP_TABLE
    EORB    #63

.LFO_SINE_LOOKUP_TABLE:
    LDX     #TABLE_LFO_SIN
    ABX
    LDAB    0,x
    TSTA

; If bit 7 of the accumulator MSB is set, indicating the LFO is in the
; second-half of its phase, then invert the wave amplitude.
    BPL     .LFO_SINE_STORE
    COMB

.LFO_SINE_STORE:
    TBA
    BRA     .STORE_AND_EXIT

.IS_LFO_WAVE_1?:
    CMPA    #LFO_WAVE_SAW_DOWN
    BNE     .IS_LFO_WAVE_2?

; If the LFO wave is 'Saw Down' invert the phase counter register to achieve
; a decreasing saw wave.

.LFO_SAW_DOWN:
    LDD     <M_LFO_PHASE_ACCUMULATOR
    COMA
    BRA     .STORE_AND_EXIT

.IS_LFO_WAVE_2?:
    CMPA    #LFO_WAVE_SAW_UP
    BNE     .IS_LFO_WAVE_3?

; If the LFO wave is 'Saw Up' the most-significant byte of the LFO phase
; accumulator register can be used as an increasing saw wave value.

.LFO_SAW_UP:
    LDAA    <M_LFO_PHASE_ACCUMULATOR
    BRA     .STORE_AND_EXIT

.IS_LFO_WAVE_3?:
    CMPA    #LFO_WAVE_SQUARE
    BNE     .LFO_S_H

; If the MSB of the phase counter is not set, then an amplitude value
; representing a negative pulse is returned (-128). Otherwise the maximum
; 8-bit positive value is returned to indicate a positive pulse (127).

.LFO_SQUARE:
    LDAA    <M_LFO_PHASE_ACCUMULATOR
    BPL     .SQUARE_POSITIVE
    LDAA    #$80
    BRA     .STORE_AND_EXIT

.SQUARE_POSITIVE:
    LDAA    #$7F
    BRA     .STORE_AND_EXIT

; First test the 'Reset Flag' to determine whether a new 'random' Sample+Hold
; value needs to be sampled.
; If the MSB is set, then the 'Sample+Hold Accumulator' register is multiplied
; by a prime number (179), and the lower-byte has another prime (11) added to
; it. The effect is a cheap pseudo-random value.

.LFO_S_H:
    TST     M_LFO_SAMPLE_HOLD_RESET_FLAG
    BPL     .END_LFO_GET_AMPLITUDE
    LDAA    <M_LFO_SAMPLE_HOLD_ACCUMULATOR
    LDAB    #179
    MUL
    ADDB    #$11
    STAB    <M_LFO_SAMPLE_HOLD_ACCUMULATOR
    TBA

.STORE_AND_EXIT:
    STAA    <M_LFO_CURR_AMPLITUDE

.END_LFO_GET_AMPLITUDE:
    RTS

; ==============================================================================
; LFO Sine Table.
; Length: 64.
; ==============================================================================
TABLE_LFO_SIN:
    FCB 2, 5, 8, $B, $E, $11
    FCB $14, $17, $1A, $1D, $20
    FCB $23, $26, $29, $2C, $2F
    FCB $32, $35, $38, $3A, $3D
    FCB $40, $43, $45, $48, $4A
    FCB $4D, $4F, $52, $54, $56
    FCB $59, $5B, $5D, $5F, $61
    FCB $63, $65, $67, $69, $6A
    FCB $6C, $6E, $6F, $71, $72
    FCB $73, $75, $76, $77, $78
    FCB $79, $7A, $7B, $7C, $7C
    FCB $7D, $7D, $7E, $7E, $7F
    FCB $7F, $7F, $7F


; ==============================================================================
; MIDI_INIT
; ==============================================================================
; LOCATION: 0xE8EB
;
; DESCRIPTION:
; This subroutine initialises the device's Serial Communication Interface.
; The SCI Rate/Control register is initialised here. This subroutine also sets
; the correct data transfer rate for MIDI.
;
; Clock source set to EXTERNAL.
; Transfer rate set to E/16.
;
; ==============================================================================

MIDI_INIT:
    LDAA    #%1100
    STAA    <RATE_MODE_CTRL
    LDAA    #SCI_RIE_RE_TE
    STAA    <SCI_CTRL_STATUS

; Reading STATUS, then reading RECEIVE will clear Status[RDRF].

MIDI_RESET_BUFFERS:
    LDAA    <SCI_CTRL_STATUS
    LDAA    <SCI_RECEIVE
    LDX     #M_MIDI_TX_BUFFER
    STX     <M_MIDI_TX_BFR_WRITE_PTR
    STX     <M_MIDI_TX_BFR_READ_PTR
    JSR     MIDI_RESET_RX_BUFFER
    RTS


; ==============================================================================
; HANDLER_SCI
; ==============================================================================
; LOCATION: 0xE902
;
; DESCRIPTION:
; Top-level handler for all hardware Serial Communication Interface events.
; This subroutine handles the buffering of all incoming, and outgoing MIDI
; messages.
;
; ==============================================================================

HANDLER_SCI:
    LDAA    <SCI_CTRL_STATUS

; If Status[RDRF] is set, it means there is data in the receive
; register. If so, branch.
    ASLA
    BCS     .STORE_MIDI_DATA
    ASLA

; Branch if Status[ORFE] is set.
    BCS     .SET_MIDI_DATA_ERROR

; Checks if Status[TDRE] is clear.
    BMI     .MIDI_TDR_NOT_EMPTY
    RTI

.STORE_MIDI_DATA:
    LDAA    #1
    STAA    <M_MIDI_RX_BUFFER_PENDING

; Store received data into RX buffer, and increment pointer.
    LDX     <M_MIDI_RX_BFR_WRITE_PTR
    LDAA    <SCI_RECEIVE
    STAA    0,x
    INX

; Reset the RX data ring buffer if it has reached the end.
    CPX     #M_MIDI_TX_DATA_PRESENT
    BNE     .HAS_BUFFER_OVERFLOWED?
    LDX     #M_MIDI_RX_BUFFER

; If the TX write pointer wraps around to the read pointer this indicates
; a MIDI buffer overflow.

.HAS_BUFFER_OVERFLOWED?:
    CPX     <M_MIDI_RX_BFR_READ_PTR
    BNE     .SAVE_WRITE_PTR_AND_EXIT
    LDAA    #MIDI_STATUS_BUFFER_FULL
    STAA    <M_MIDI_BUFFER_ERROR_CODE
    BSR     MIDI_RESET_BUFFERS
    JSR     VOICE_DEACTIVATE_ALL
    RTI

; Save incremented MIDI TX buffer write ptr.

.SAVE_WRITE_PTR_AND_EXIT:
    STX     <M_MIDI_RX_BFR_WRITE_PTR
    RTI

.MIDI_TDR_NOT_EMPTY:
    LDX     <M_MIDI_TX_BFR_READ_PTR
    CPX     <M_MIDI_TX_BFR_WRITE_PTR
    BEQ     .TX_BUFFER_EMPTY
    LDAA    0,x
    STAA    <SCI_TRANSMIT
    INX

; Check whether the read pointer has reached the end of the MIDI RX buffer,
; if so, the read pointer is reset to the start.
    CPX     #M_MIDI_RX_BUFFER
    BNE     .END_HANDLER_SCI
    LDX     #M_MIDI_TX_BUFFER

.END_HANDLER_SCI:
    STX     <M_MIDI_TX_BFR_READ_PTR
    RTI

.TX_BUFFER_EMPTY:
    LDAA    #SCI_RIE_RE_TE
    STAA    <SCI_CTRL_STATUS
    CLR     M_MIDI_TX_DATA_PRESENT
    RTI

.SET_MIDI_DATA_ERROR:
    LDAA    #MIDI_STATUS_ERROR
    STAA    <M_MIDI_BUFFER_ERROR_CODE
    BSR     MIDI_RESET_RX_BUFFER
    LDAA    <SCI_RECEIVE
    RTI


; ==============================================================================
; MIDI_RESET_RX_BUFFER
; ==============================================================================
; LOCATION: 0xE958
;
; DESCRIPTION:
; This subroutine resets the MIDI receieve buffer.
; It sets the ring buffer's read and write pointers to their initial values.
; This function is called by the synth's reset handler, and as the result of
; an error while receiving MIDI.
;
; ==============================================================================

MIDI_RESET_RX_BUFFER:
    LDAA    #$F7
    STAA    <M_MIDI_STATUS_BYTE
    LDX     #M_MIDI_RX_BUFFER
    STX     <M_MIDI_RX_BFR_WRITE_PTR
    STX     <M_MIDI_RX_BFR_READ_PTR
    RTS


; ==============================================================================
; MIDI_NOTE_ON
; ==============================================================================
; LOCATION: 0xE964
;
; DESCRIPTION:
; Pushes a MIDI 'Note On' event to the device's TX buffer.
; The DX7 does not send 'Note Off' MIDI events. It instead sends 'Note On'
; MIDI events with 0 velocity.
;
; ARGUMENTS:
; Memory:
; * 0x81:  The note key to send.
; * 0x82:  The note velocity to send.
;
; ==============================================================================

MIDI_SEND_NOTE_ON:
    LDAA    #MIDI_STATUS_NOTE_ON
    ADDA    M_MIDI_TX_CH
    LDAB    <M_NOTE_KEY
    BSR     MIDI_TX_PUSH_TWO_BYTES
    CLRA
    LDAB    <M_NOTE_VEL
    BEQ     .END_MIDI_SEND_NOTE_ON

; Quantize the raw velocity value.
; This looks up the corresponding entry in the velocity table, and uses
; this value.
    LDX     #TABLE_DEVICE_TO_MIDI_VELOCITY
    LSRB
    LSRB
    ABX
    LDAA    0,x

.END_MIDI_SEND_NOTE_ON:
    BRA     MIDI_TX_PUSH


; ==============================================================================
; MIDI_TX_PUSH_TWO_BYTES
; ==============================================================================
; LOCATION: 0xE97C
;
; DESCRIPTION:
; Pushes the contents of ACCA to the TX buffer, transfers ACCB->ACCA, and
; pushes ACCA again to the TX buffer.
;
; ARGUMENTS:
; Registers:
; * ACCA: The first byte to transfer.
; * ACCB: The second byte to transfer.
;
; ==============================================================================

MIDI_TX_PUSH_TWO_BYTES:
    BSR     MIDI_TX_PUSH

; Falls-through to push again, and return.
    TBA


; ==============================================================================
; MIDI_TX_PUSH
; ==============================================================================
; LOCATION: 0xE97F
;
; DESCRIPTION:
; Adds a byte to the MIDI Transmit Buffer, to be transmitted at the next SCI
; interrupt.
;
; ARGUMENTS:
; Registers:
; * ACCA: The byte to add to the MIDI Transmit Buffer.
;
; ==============================================================================

MIDI_TX_PUSH:
    LDX     <M_MIDI_TX_BFR_WRITE_PTR
    STAA    0,x

; 0x23F3 is the last address within the TX buffer.
; If the loop hasn't reached the last address, branch.
    CPX     #$23F3
    BNE     .INCREMENT_TX_PTR

; 0x233F is the byte BEFORE the TX buffer.
    LDX     #$233F

.INCREMENT_TX_PTR:
    INX

; Check for a MIDI buffer overflow.
    CPX     <M_MIDI_TX_BFR_READ_PTR
    BEQ     MIDI_TX_PUSH
    STX     <M_MIDI_TX_BFR_WRITE_PTR
    LDAA    #1
    STAA    M_MIDI_TX_DATA_PRESENT

; Enable TX, and RX.
; Enable TX interrupts, and RX interrupts.
    LDAA    #SCI_RIE_RE_TIE_TE
    STAA    <SCI_CTRL_STATUS
    RTS


; ==============================================================================
; Device To MIDI Velocity Table.
; Used when converting between the synth's internal velocity representation
; and the MIDI velocity data to send out.
; ==============================================================================
TABLE_DEVICE_TO_MIDI_VELOCITY:
    FCB $7F
    FCB $76
    FCB $6D
    FCB $64
    FCB $5B
    FCB $52
    FCB $49
    FCB $40
    FCB $3C
    FCB $38
    FCB $34
    FCB $30
    FCB $2C
    FCB $28
    FCB $24
    FCB $20
    FCB $1F
    FCB $1E
    FCB $1D
    FCB $1C
    FCB $1B
    FCB $1A
    FCB $19
    FCB $18
    FCB $17
    FCB $16
    FCB $15
    FCB $14
    FCB $13
    FCB $12
    FCB $11
    FCB $10


; ==============================================================================
; MIDI_SYSEX_DUMP_CURRENT_VOICE
; ==============================================================================
; LOCATION: 0xE9BC
;
; DESCRIPTION:
; Dumps the voice data in the device's working patch buffer to SYSEX out.
; The TX7 Service Manual contains additional information regarding the bulk
; dump format for a single voice.
;
; MEMORY USED:
; * 0xE3:  Src ptr = Patch wrk buffer.
; * 0xE5:  Loop counter = 155.
; * 0xE6:  Checksum
;
; ==============================================================================

MIDI_SYSEX_DUMP_CURRENT_VOICE:
    TST     M_MIDI_PROCESSED_DATA_COUNT

; If the device is currently processing a request, return.
    BNE     .END_MIDI_SYSEX_DUMP_CURRENT_VOICE
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     DELAY
    LDAB    #155
    STAB    <$E5
    LDD     #M_PATCH_CURRENT_BUFFER
    STD     <$E3
    CLR     $E6
    BSR     MIDI_SYSEX_SEND_HEADER
    LDAA    M_MIDI_TX_CH
    CLRB
    JSR     MIDI_TX_PUSH_TWO_BYTES

; Send the two 'Byte Count' data bytes.
    LDAA    #1
    LDAB    #$1B
    JSR     MIDI_TX_PUSH_TWO_BYTES

.PUSH_BYTE_LOOP:
    LDX     <$E3
    LDAA    0,x
    INX
    STX     <$E3                                ; Increment source ptr.
    ANDA    #%1111111
    PSHA
    ADDA    <$E6
    STAA    <$E6
    PULA
    JSR     MIDI_TX_PUSH
    DEC     $E5
    BNE     .PUSH_BYTE_LOOP                     ; If E5 > 0, loop.

MIDI_SYSEX_SETUP_CHKSUM:
    LDAA    <$E6
    NEGA
    ANDA    #%1111111
    JSR     MIDI_TX_PUSH

MIDI_SYSEX_SEND_END:
    LDAA    #MIDI_STATUS_SYSEX_END
    JSR     MIDI_TX_PUSH

RE_ENABLE_INTERRUPTS:
    PULA
    STAA    <IO_PORT_2_DATA

.END_MIDI_SYSEX_DUMP_CURRENT_VOICE:
    RTS


; ==============================================================================
; MIDI_SYSEX_SEND_HEADER
; ==============================================================================
; LOCATION: 0xEA0E
;
; DESCRIPTION:
; This subroutine sends the SYSEX header, and manufacturer ID bytes to the
; MIDI transmit buffer. This subroutine is called when sending SYSEX data out
; from the synth to construct the header for the full SYSEX message.
;
; ==============================================================================

MIDI_SYSEX_SEND_HEADER:
    LDAA    #MIDI_STATUS_SYSEX_START
    LDAB    #MIDI_SYSEX_MANUFACTURER_ID
    JMP     MIDI_TX_PUSH_TWO_BYTES


; ==============================================================================
; MIDI_SYSEX_DUMP_BULK
; ==============================================================================
; LOCATION: 0xEA15
;
; DESCRIPTION:
; Sends a bulk voice dump out over SYSEX.
;
; MEMORY USED:
; * 0x2291: Send loop counter.
; * 0xE3:   A pointer to store the source of the data in RAM being sent.
; * 0xE6:   The SYSEX checksum.
;
; ==============================================================================

MIDI_SYSEX_DUMP_BULK:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     DELAY
    LDD     #$1000
    STD     $2291
    LDD     #M_EXTERNAL_RAM_START
    STD     <$E3
    CLR     $E6
    BSR     MIDI_SYSEX_SEND_HEADER
    LDAA    M_MIDI_TX_CH
    LDAB    #MIDI_SYSEX_FMT_BULK
    JSR     MIDI_TX_PUSH_TWO_BYTES
    LDAA    #32
    CLRB
    JSR     MIDI_TX_PUSH_TWO_BYTES

; Load the value to transmit, and increment the source pointer.
; This value is then masked to remove the MSB, if it exists incorrectly.

.SYSEX_TRANSMIT_LOOP:
    LDX     <$E3
    LDAA    0,x
    INX
    STX     <$E3
    ANDA    #%1111111

; Add the sent value to the total checksum.
    PSHA
    ADDA    <$E6
    STAA    <$E6
    PULA

; Push the byte to the MIDI transmit buffer.
    JSR     MIDI_TX_PUSH

.DECREMENT_BULK_SYSEX_LOOP_COUNTER:
    LDD     $2291
    SUBD    #1
    STD     $2291
    BNE     .SYSEX_TRANSMIT_LOOP
    JMP     MIDI_SYSEX_SETUP_CHKSUM


; Test whether the sending of SYSEX parameters is enabled globally.

IS_SYSINFO_AVAILABLE?:
    TST     M_MIDI_SYS_INFO_AVAIL
    BNE     .SEND_SYSEX

ENABLE_INTERRUPTS_AND_EXIT:
    JMP     RE_ENABLE_INTERRUPTS

.SEND_SYSEX:
    PSHB
    XGDX
    PSHB
    PSHA
    JSR     MIDI_SYSEX_SEND_HEADER
    LDAA    #MIDI_SYSEX_SUB_PARAM_CHG
    ADDA    M_MIDI_TX_CH
    PULB
    JSR     MIDI_TX_PUSH_TWO_BYTES
    PULA
    PULB
    ANDB    #%1111111

; Send the function parameter data.
; Pushing the SYSEX end bytes falls-through to enable IRQ, and return.
    JSR     MIDI_TX_PUSH_TWO_BYTES
    JMP     MIDI_SYSEX_SEND_END


; ==============================================================================
; MIDI_SYSEX_SEND_FN_PARAM
; ==============================================================================
; LOCATION: 0xEA7E
;
; DESCRIPTION:
; Sends a SYSEX message containing a specific function parameter.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the data to send.
; * ACCB: The parameter number.
;
; ==============================================================================

MIDI_SYSEX_SEND_FN_PARAM:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     DELAY

; If the synth is currently processing MIDI input, exit.
    TST     M_MIDI_PROCESSED_DATA_COUNT
    BNE     ENABLE_INTERRUPTS_AND_EXIT

; If this originated from a slider input event, exit.
    TST     M_SLIDER_INPUT_EVENT
    BNE     ENABLE_INTERRUPTS_AND_EXIT

; Load the param value to A, and push to the stack.
    LDAA    0,x
    PSHA

; Construct the first param byte.
; Add 0x40 to B, to construct the param number.
    LDAA    #8
    ADDB    #$40
    XGDX
    PULB
    BRA     IS_SYSINFO_AVAILABLE?


; ==============================================================================
; MIDI_SYSEX_SEND_PARAM_CHG
; ==============================================================================
; LOCATION: 0xEA9C
;
; DESCRIPTION:
; Sends a 'Parameter Change' SYSEX message.
;
; ARGUMENTS:
; Registers:
; * IX:   The address of the parameter to send. Refer to the comment below
;         regarding how the parameter number is constructed from this value.
;
; ==============================================================================

MIDI_SYSEX_SEND_PARAM_CHG:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     DELAY

; If the synth is currently processing MIDI input, exit.
    TST     M_MIDI_PROCESSED_DATA_COUNT
    BNE     ENABLE_INTERRUPTS_AND_EXIT

; If this originated from a slider input event, exit.
    TST     M_SLIDER_INPUT_EVENT
    BNE     ENABLE_INTERRUPTS_AND_EXIT

; If the synth is currently in 'Patch Compare' mode, do nothing.

.SYSEX_PARAM_CHG_IS_IN_COMPARE_MODE?:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_COMPARE
    BEQ     ENABLE_INTERRUPTS_AND_EXIT

; The following code uses the pointer passed to the function in the IX
; register to determine the 'Parameter Number' to send.
; The parameter number is determined by the address in IX's offset from the
; start of the 'Patch Edit' buffer.
; e.g. If IX = 0x2091 (the first char of the patch name), then the parameter
; number will be 0x91.
; The actual data to send is saved in ACCB, and pushed/restored  on the
; stack.
; This format of the SYSEX, and parameter numbers can be seen here:
; https://homepages.abdn.ac.uk/d.j.benson/pages/dx7/sysex-format.txt

    LDAB    0,x
    PSHB
    XGDX
    SUBD    #M_PATCH_CURRENT_BUFFER
    LSLD
    LSRB
    ANDB    #%1111111
    XGDX
    PULB
    BRA     IS_SYSINFO_AVAILABLE?


; ==============================================================================
; MIDI_SEND_ACTIVE_SENSING
; ==============================================================================
; LOCATION: 0xEAC5
;
; DESCRIPTION:
; Sends an 'Active Sensing' message to the MIDI output channel.
;
; ==============================================================================

MIDI_SEND_ACTIVE_SENSING:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     DELAY
    LDAA    #MIDI_STATUS_ACTIVE_SENSING
    JSR     MIDI_TX_PUSH
    PULA
    STAA    <IO_PORT_2_DATA                     ; Re-enable IRQ.
    RTS


; ==============================================================================
; MIDI_SEND_CC_1_FROM_ANALOG_INPUT
; ==============================================================================
; LOCATION: 0xEAD7
;
; DESCRIPTION:
; Sends a MIDI CC '1' message with the data as the synth's last read analog
; input data.
;
; ==============================================================================

MIDI_SEND_CC_1_FROM_ANALOG_INPUT:
    LDAB    #1
    BRA     MIDI_SEND_ANALOG_DATA_EVENT


; ==============================================================================
; MIDI_SEND_CC_2_FROM_ANALOG_INPUT
; ==============================================================================
; LOCATION: 0xEADB
;
; DESCRIPTION:
; Sends a MIDI CC '2' message with the data as the synth's last read analog
; input data.
;
; ==============================================================================

MIDI_SEND_CC_2_FROM_ANALOG_INPUT:
    LDAB    #2
    BRA     MIDI_SEND_ANALOG_DATA_EVENT


; ==============================================================================
; MIDI_SEND_CC_4_FROM_ANALOG_INPUT
; ==============================================================================
; LOCATION: 0xEADF
;
; DESCRIPTION:
; Sends a MIDI CC '4' message with the data as the synth's last read analog
; input data.
;
; ==============================================================================

MIDI_SEND_CC_4_FROM_ANALOG_INPUT:
    LDAB    #4
    BRA     MIDI_SEND_ANALOG_DATA_EVENT


; ==============================================================================
; MIDI_SEND_SLIDER_EVENT
; ==============================================================================
; LOCATION: 0xEAE3
;
; DESCRIPTION:
; Sends a MIDI event output with the last data input from the synth's
; front-panel slider.
;
; ==============================================================================

MIDI_SEND_SLIDER_EVENT:
    LDAB    #6
    BRA     MIDI_SEND_ANALOG_DATA_EVENT


; ==============================================================================
; MIDI_SEND_CC_65
; ==============================================================================
; LOCATION: 0xEAE7
;
; DESCRIPTION:
; Sends a MIDI CC message with a control code of '65'.
; This is a portamento message. This is triggered when the main portamento,
; and sustain handler detects a change in the pedal input state.
;
; ==============================================================================

MIDI_SEND_CC_65:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA
    JSR     DELAY
    TBA

; Load '65' into ACCB to set the MIDI CC parameter to the correct value
; to send a portamento event.
    LDAB    #65
    BRA     MIDI_SEND_MSG_AND_EXIT


; ==============================================================================
; MIDI_SEND_CC_65
; ==============================================================================
; LOCATION: 0xEAE7
;
; DESCRIPTION:
; Sends a MIDI CC message with a control code of '65'.
; This is a sustain message. This is triggered when the main portamento,
; and sustain handler detects a change in the pedal input state.
;
; ==============================================================================

MIDI_SEND_CC_64:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA
    JSR     DELAY
    TBA

; Load '64' into ACCB to set the MIDI CC parameter to the correct value
; to send a sustain event.
    LDAB    #64

MIDI_SEND_MSG_AND_EXIT:
    JSR     MIDI_SEND_MODE_CHG
    JMP     RE_ENABLE_INTERRUPTS


; ==============================================================================
; MIDI_SEND_YES_NO
; ==============================================================================
; LOCATION: 0xEB07
;
; DESCRIPTION:
; Sends a MIDI CC message, with control code number 0x60 for a 'No' message,
; or 0x61 for 'Yes'.
;
; ==============================================================================

MIDI_SEND_YES_NO:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA
    JSR     DELAY
    LDAA    M_LAST_PRESSED_BTN
    SUBA    #40
    BNE     .BUTTON_WAS_NO

.BUTTON_WAS_YES:
    LDAB    #$61                                ; 'a'
    BRA     .END_MIDI_SEND_YES_NO

.BUTTON_WAS_NO:
    LDAB    #$60                                ; '`'

.END_MIDI_SEND_YES_NO:
    LDAA    #$7F
    BRA     MIDI_SEND_MSG_AND_EXIT

; ==============================================================================
; MIDI_SEND_ANALOG_DATA_EVENT
; ==============================================================================
; LOCATION: 0xEB21
;
; DESCRIPTION:
; Sends a 'Mode Change' MIDI message with the synth's last read analog input
; data as the message's data.
;
; ARGUMENTS:
; Registers:
; * ACCB: The MIDI CC parameter to send this data with.
;
; ==============================================================================

MIDI_SEND_ANALOG_DATA_EVENT:
    LDAA    <M_ANALOG_DATA

; Falls-through below to send MIDI mode change event.
    LSRA


; ==============================================================================
; MIDI_SEND_MODE_CHG
; ==============================================================================
; LOCATION: 0xEB24
;
; DESCRIPTION:
; Sends a 'Mode Change' MIDI message with ACCB as the parameter, and ACCA as
; the value.
;
; ARGUMENTS:
; Registers:
; * ACCA: The value to send.
; * ACCB: The parameter to send the value for.
;
; ==============================================================================

MIDI_SEND_MODE_CHG:
    PSHA
    PSHB
    LDAA    #MIDI_STATUS_MODE_CHANGE
    ADDA    M_MIDI_TX_CH
    PULB
    JSR     MIDI_TX_PUSH_TWO_BYTES
    PULA
    JSR     MIDI_TX_PUSH
    RTS


; ==============================================================================
; MIDI_SEND_PITCH_BEND
; ==============================================================================
; LOCATION: 0xEB34
;
; DESCRIPTION:
; Sends a MIDI event with pitch-bend data.
; This subroutine is called from the main analog input handler corresponding
; to the pitch bend wheel's input.
;
; ==============================================================================

MIDI_SEND_PITCH_BEND:
    LDAA    #MIDI_STATUS_PITCH_BEND

; Construct the MIDI status byte, and send this.
    ADDA    M_MIDI_TX_CH
    JSR     MIDI_TX_PUSH
    LDAB    <M_ANALOG_DATA
    LSRB
    CMPB    #64
    BHI     .PITCH_BEND_POSITIVE
    CLRA

.SEND_MIDI_EVENT:
    JSR     MIDI_TX_PUSH_TWO_BYTES
    RTS

.PITCH_BEND_POSITIVE:
    TBA
    SUBA    #64
    ASLA
    BRA     .SEND_MIDI_EVENT


; ==============================================================================
; MIDI_SEND_PROG_CHG
; ==============================================================================
; LOCATION: 0xEB4E
;
; DESCRIPTION:
; Sends a MIDI 'Program Change' event from the last button pushed.
; This subroutine is called from a front-panel button push while the synth is
; in 'Play Mode.
;
; ==============================================================================

MIDI_SEND_PROG_CHG:
    TST     M_MIDI_SYS_INFO_AVAIL

; If 'SYS INFO AVAIL' not enabled, exit.
    BNE     .END_SYS_INFO_UNAVAIL

.DISABLE_IRQ:
    LDAA    <IO_PORT_2_DATA
    PSHA
    CLR     IO_PORT_2_DATA

.SEND_MIDI_PROG_CHG:
    JSR     DELAY
    LDAA    #MIDI_STATUS_PROG_CHANGE
    ADDA    M_MIDI_TX_CH

; If the synth is currently set to load patches from the cartridge, add 32
; to the last-pressed button number, and then use this value as the patch
; index when sending the message.

.IS_PATCH_IN_INT_MEMORY?:
    TST     M_MEM_SELECT_UI_MODE
    BEQ     .INT_MEM_SELECTED

.CRT_MEM_SELECTED:
    LDAB    #32
    BRA     .SEND_MIDI_DATA

.INT_MEM_SELECTED:
    CLRB

.SEND_MIDI_DATA:
    ADDB    M_LAST_PRESSED_BTN
    JSR     MIDI_TX_PUSH_TWO_BYTES
    JMP     RE_ENABLE_INTERRUPTS

.END_SYS_INFO_UNAVAIL:
    RTS


; ==============================================================================
; MIDI_SEND_AFTERTOUCH
; ==============================================================================
; LOCATION: 0xEB75
;
; DESCRIPTION:
; Transfers the analog aftertouch data to MIDI out.
;
; ARGUMENTS:
; Memory:
; * 0x84:   The analog aftertouch data to transfer.
;
; ==============================================================================

MIDI_SEND_AFTERTOUCH:
    LDAB    <M_ANALOG_DATA
    LSRB
    LDAA    #MIDI_STATUS_AFTERTOUCH
    ADDA    M_MIDI_TX_CH
    JMP     MIDI_TX_PUSH_TWO_BYTES


; ==============================================================================
; MIDI_PROCESS_RECEIVED_DATA
; ==============================================================================
; LOCATION: 0xEB80
;
; DESCRIPTION:
; Processes the received, and buffered MIDI data.
; This is the main entry point where all MIDI functionality is initiated. This
; includes playing/stopping notes, receiving MIDI CC messages, and receiving
; SYSEX messages.
;
; ==============================================================================

MIDI_PROCESS_RECEIVED_DATA:
    LDX     <M_MIDI_RX_BFR_READ_PTR
    CPX     <M_MIDI_RX_BFR_WRITE_PTR

; If the MIDI RX read buffer ptr, and write buffer ptr are not equal, this
; indicates that there is data to be processed in the MIDI RX buffer.
    BNE     .READ_RX_BUFFER

.NO_RECEIVED_DATA:
    CLR     M_MIDI_RX_BUFFER_PENDING
    RTS

.READ_RX_BUFFER:
    LDD     #0

; Reset the incoming active sensing counter.
    STD     <M_MIDI_ACTV_SENS_RX_CTR
    LDAA    0,x

; 0x256F is the last byte in the MIDI RX buffer.
    CPX     #$256F
    BNE     .READ_RX_BUFFER_ITERATE

; 0x23F3 is the last byte before the MIDI RX buffer.
    LDX     #$23F3

.READ_RX_BUFFER_ITERATE:
    INX
    STX     <M_MIDI_RX_BFR_READ_PTR

; Check if the incoming MIDI byte represents a status message
; or a data message.

.IS_STATUS_MSG?:
    TSTA
    BPL     .PROCESS_DATA_BYTE

; Is this status the start of an 'Active Sensing' message?

.PROCESS_STATUS_BYTE:
    CMPA    #MIDI_STATUS_ACTIVE_SENSING
    BEQ     .ACTIVE_SENSING

; Is this status the end of a SYSEX MIDI message?

.IS_SYSEX_END?:
    CMPA    #MIDI_STATUS_SYSEX_END
    BHI     .PROCEED_TO_NEXT_MESSAGE            ; If A > 0xF7, branch.

; If a non-sysex end, non-active sensing status byte has been received,
; store it and proceed to processing the next byte.

.STORE_STATUS_MSG:
    STAA    <M_MIDI_STATUS_BYTE
    CLR     M_MIDI_PROCESSED_DATA_COUNT

.PROCEED_TO_NEXT_MESSAGE:
    BRA     MIDI_PROCESS_RECEIVED_DATA

; Does this status byte represent the end of a SYSEX message?
; If so, reset, and continue processing the received MIDI data.

.PROCESS_DATA_BYTE:
    LDAB    <M_MIDI_STATUS_BYTE
    CMPB    #MIDI_STATUS_SYSEX_END
    BEQ     .PROCEED_TO_NEXT_MESSAGE

; Is this the start of a SYSEX message?

.IS_SYSEX_DATA?:
    CMPB    #MIDI_STATUS_SYSEX_START
    BNE     .IS_DATA_CORRECT_RX_CH?
    JMP     .SYSEX_DATA_COUNT_CHECK

; Check if this MIDI message is on the same channel as the DX7.
; Use XOR to check whether this byte matches the current MIDI RX channel.
; If the result is zero, the channel matches. If not, this message is
; intended for another device, and can be ignored.

.IS_DATA_CORRECT_RX_CH?:
    LDAB    M_MIDI_RX_CH
    EORB    <M_MIDI_STATUS_BYTE
    ANDB    #%1111
    BNE     .PROCEED_TO_NEXT_MESSAGE

; Is this data part of a 'Note Off' MIDI message?
; Remove the bytes signifying the MIDI channel, and compare only
; the status type.

.IS_NOTE_OFF?:
    LDAB    <M_MIDI_STATUS_BYTE
    ANDB    #%11110000
    CMPB    #MIDI_STATUS_NOTE_OFF
    BNE     .IS_NOTE_ON?

; Check if another data byte for this message has previously been parsed.
; The device is expecting a status, and two data bytes.
; The pending byte count refers to the number of processed bytes PRIOR to
; this incoming data byte.
; If the two data bytes have not been received, return, and wait for the
; next data byte.

.NOTE_OFF_DATA_CHECK:
    LDAB    <M_MIDI_PROCESSED_DATA_COUNT
    BNE     .NOTE_OFF
    INC     M_MIDI_PROCESSED_DATA_COUNT
    STAA    <M_MIDI_INCOMING_DATA
    RTS

; Process a 'Note Off' MIDI message.

.NOTE_OFF:
    LDAB    <IO_PORT_2_DATA
    PSHB
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     MIDI_PROCESS_DELAY                  ; Falls-through below.

.PROCESS_NOTE_OFF_3:
    LDAA    <M_MIDI_INCOMING_DATA
    STAA    <M_NOTE_KEY
    JSR     VOICE_REMOVE_KEY
    BRA     .CLEAR_AND_REPEAT

; If this status byte is the start of an 'Active Sensing' message
; reset the active sensing counter, and enable the active sensing check.

.ACTIVE_SENSING:
    LDAA    #1
    STAA    M_MIDI_ACTV_SENS_RX_ENABLE
    LDD     #0
    STD     <M_MIDI_ACTV_SENS_RX_CTR
    RTS

; Is this data part of a 'Note On' MIDI message?

.IS_NOTE_ON?:
    CMPB    #MIDI_STATUS_NOTE_ON
    BNE     .IS_MODE_CHG?

; Check whether we have both the status and the two data bytes that make
; up a  MIDI 'Note On' message.
; If not, return and process the next message when it arrives.

.NOTE_ON_DATA_CHECK:
    LDAB    <M_MIDI_PROCESSED_DATA_COUNT
    BNE     .NOTE_ON
    INC     M_MIDI_PROCESSED_DATA_COUNT
    STAA    <M_MIDI_INCOMING_DATA
    RTS

; Process a 'Note on' MIDI message.

.NOTE_ON:
    LDAB    <IO_PORT_2_DATA
    PSHB
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    CLR     M_MIDI_PROCESSED_DATA_COUNT
    JSR     MIDI_PROCESS_DELAY

; The third byte of a 'Note On' MIDI message indicates the note's velocity.
; If this is zero, consider this to be a 'Note Off' message.
    TSTA
    BEQ     .PROCESS_NOTE_OFF_3

; Transfer the data byte denoting the MIDI note velocity to B.
; Shift it right twice to quantise the 0-127 velocity value to an index
; into the 32 entry MIDI velocity array.

.PROCESS_NOTE_ON_4:
    TAB
    LSRB
    LSRB
    LDX     #TABLE_MIDI_VEL
    ABX
    LDAA    0,x
    STAA    <M_NOTE_VEL
    LDAA    <M_MIDI_INCOMING_DATA
    STAA    <M_NOTE_KEY
    JSR     VOICE_ADD_CHECK_KEY_EVENT_COUNT

.CLEAR_AND_REPEAT:
    CLR     M_MIDI_PROCESSED_DATA_COUNT
    PULB
    STAB    <IO_PORT_2_DATA                     ; Restore IRQ.
    JMP     MIDI_PROCESS_RECEIVED_DATA

; Is this data part of a 'Mode Change' MIDI message?

.IS_MODE_CHG?:
    CMPB    #MIDI_STATUS_MODE_CHANGE
    BEQ     .MODE_CHG
    JMP     .IS_PROG_CHG?

; Check whether we have both the status and the two data bytes that make up
; the message. If not, return and process the next byte.

.MODE_CHG:
    LDAB    <M_MIDI_PROCESSED_DATA_COUNT
    BNE     .MODE_CHG_2
    INC     M_MIDI_PROCESSED_DATA_COUNT
    STAA    <M_MIDI_INCOMING_DATA
    RTS

; ==============================================================================
; MIDI Velocity Table.
; This table is used to translate between the incoming MIDI velocity value
; (0..127) to the synth's internal velocity value.
; ==============================================================================
TABLE_MIDI_VEL:
    FCB $6E, $64, $5A, $55, $50
    FCB $4B, $46, $41, $3A, $36
    FCB $32, $2E, $2A, $26, $22
    FCB $1E, $1C, $1A, $18, $16
    FCB $14, $12, $10, $E, $C
    FCB $A, 8, 6, 4, 2, 1, 0

.MODE_CHG_2:
    LDAB    <IO_PORT_2_DATA
    PSHB
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    JSR     MIDI_PROCESS_DELAY
    ASLA
    LDAB    <M_MIDI_INCOMING_DATA
    DECB
    JSR     JUMP_TO_RELATIVE_OFFSET

; ==============================================================================
; The following is a table of relative-addressed pointers to the functions
; which handle the various MIDI CC events. The first byte is the relative byte
; offset, the second byte is the event number.
; e.g. If the event number was 3, the offet from 0xEC70 to the handler
; function is 0x20.
; ==============================================================================

TABLE_MIDI_CC_HANDLER_OFFSETS:
    FCB $26
    FCB 1                                       ; Jumps to 0xEC92.
    FCB $2C
    FCB 2                                       ; Jumps to 0xEC9B.
    FCB $20
    FCB 3                                       ; Jumps to 0xEC90.
    FCB $2D
    FCB 4                                       ; Jumps to 0xEC9F.
    FCB -$8E
    FCB 5                                       ; Jumps to 0xEBE6.
    FCB $7D
    FCB 6                                       ; Jumps to 0xECF3.
    FCB $79
    FCB 7                                       ; Jumps to 0xECF1.
    FCB $16
    FCB 63                                      ; Jumps to 0xEC90.
    FCB $28
    FCB 64                                      ; Jumps to 0xECA4.
    FCB $3D
    FCB 65                                      ; Jumps to 0xECBB.
    FCB $10
    FCB 95                                      ; Jumps to 0xEC90.
    FCB $83
    FCB 96                                      ; Jumps to 0xED05.
    FCB $85
    FCB 97                                      ; Jumps to 0xED09.
    FCB $A
    FCB 122                                     ; Jumps to 0xEC90.
    FCB $8E
    FCB 123                                     ; Jumps to 0xED16.
    FCB 6
    FCB 125                                     ; Jumps to 0xEC90.
    FCB $3A
    FCB 126                                     ; Jumps to 0xECC6.
    FCB $4E
    FCB 127                                     ; Jumps to 0xECDC.

MIDI_RESET_AND_PROCESS_INCOMING:
    BRA     .CLEAR_AND_REPEAT


; ==============================================================================
; MIDI_CC_1
; ==============================================================================
; LOCATION: 0xEC92
;
; DESCRIPTION:
; Handles a MIDI control code message with a type of '1'.
;
; ==============================================================================

MIDI_CC_1:
    STAA    M_MOD_WHEEL_ANALOG_INPUT


MIDI_UPDATE_PITCH_MOD:
    JSR     MOD_PROCESS_INPUT_SOURCES
    BRA     MIDI_RESET_AND_PROCESS_INCOMING


; ==============================================================================
; MIDI_CC_2
; ==============================================================================
; LOCATION: 0xEC9A
;
; DESCRIPTION:
; Handles a MIDI control code message with a type of '2'.
;
; ==============================================================================

MIDI_CC_2:
    STAA    M_BRTH_CTRL_ANALOG_INPUT
    BRA     MIDI_UPDATE_PITCH_MOD


; ==============================================================================
; MIDI_CC_4
; ==============================================================================
; LOCATION: 0xEC9F
;
; DESCRIPTION:
; Handles a MIDI control code message with a type of '4'.
;
; ==============================================================================

MIDI_CC_4:
    STAA    M_FOOT_CTRL_ANALOG_INPUT
    BRA     MIDI_UPDATE_PITCH_MOD


; ==============================================================================
; MIDI_CC_64
; ==============================================================================
; LOCATION: 0xECA4
;
; DESCRIPTION:
; Handles a MIDI control code message with a type of '64'.
; This is the command to affect the sustain pedal.
;
; ==============================================================================

MIDI_CC_64:
    TSTA
    BEQ     .SIGNAL_OFF
    LDAB    #1

MIDI_SET_PORTA_SUS_PDL_STATUS:
    ORAB    M_PEDAL_INPUT_STATUS

MIDI_STORE_PORTA_SUS_PDL_STATUS:
    STAB    M_PEDAL_INPUT_STATUS
    JSR     MAIN_PROCESS_SUSTAIN_PEDAL
    BRA     MIDI_RESET_AND_PROCESS_INCOMING

.SIGNAL_OFF:
    LDAB    #%10


.SET_PORTA_STATUS:
    ANDB    M_PEDAL_INPUT_STATUS
    BRA     MIDI_STORE_PORTA_SUS_PDL_STATUS


; ==============================================================================
; MIDI_CC_65
; ==============================================================================
; LOCATION: 0xECBB
;
; DESCRIPTION:
; Handles a MIDI control code message with a type of '65'.
; This is the command to affect the portamento pedal.
;
; ==============================================================================

MIDI_CC_65:
    TSTA
    BEQ     .PORTA_OFF
    LDAB    #2
    BRA     MIDI_SET_PORTA_SUS_PDL_STATUS

.PORTA_OFF:
    LDAB    #1
    BRA     .SET_PORTA_STATUS


; ==============================================================================
; MIDI_CC_126
; ==============================================================================
; LOCATION: 0xECC6
;
; DESCRIPTION:
; Handles a MIDI control code message with a type of '126'.
; This is the command to set the synth to monophonic mode.
;
; ==============================================================================

MIDI_CC_126:
    TST     M_MONO_POLY
    BNE     MIDI_CC_RESET
    CMPA    #2
    BNE     MIDI_CC_RESET
    LDAA    #1
    STAA    M_MONO_POLY


.MIDI_CC_127_RESET_VOICES:
    JSR     VOICE_DEACTIVATE_ALL
    JSR     VOICE_RESET

MIDI_CC_RESET:
    BRA     MIDI_RESET_AND_PROCESS_INCOMING


; ==============================================================================
; MIDI_CC_127
; ==============================================================================
; LOCATION: 0xECDC
;
; DESCRIPTION:
; Handles a MIDI Control Code message with a type of '127'.
; This sets the synth to polyphonic mode.
;
; ==============================================================================

MIDI_CC_127:
    TST     M_MONO_POLY
    BEQ     MIDI_CC_123
    CLR     M_MONO_POLY
    BRA     .MIDI_CC_127_RESET_VOICES


; ==============================================================================
; MIDI_CC_5
; ==============================================================================
; LOCATION: 0xECE6
;
; DESCRIPTION:
; Handles a MIDI Control Code message with a type of '127'.
; This sets the synth's portamento time.
;
; ==============================================================================

MIDI_CC_5:
    LDAB    #100
    MUL
    STAA    M_PORTA_TIME
    JSR     PORTA_COMPUTE_RATE_VALUE
    BRA     MIDI_RESET_AND_PROCESS_INCOMING


; ==============================================================================
; MIDI_CC_7
; ==============================================================================
; LOCATION: 0xECF1
;
; DESCRIPTION:
; Handles a MIDI Control Code event of type '7'.
; This subroutine adjusts the synth's volume.
;
; ==============================================================================
; Attributes: thunk

MIDI_CC_7:
    BRA     MIDI_LOAD_VOLUME


; ==============================================================================
; MIDI_CC_6
; ==============================================================================
; LOCATION: 0xECF3
;
; DESCRIPTION:
; Handles a MIDI Control Code event of type '6'.
; If the synth's input mode is set to 'Function', this will update the
; currently selected 'Function parameter'.
;
; ==============================================================================

MIDI_CC_6:
    LDAB    M_INPUT_MODE
    CMPB    #INPUT_MODE_FN
    BNE     MIDI_CC_END
    TST     M_FN_PARAM_CURRENT
    BNE     MIDI_CC_END
    TAB
    JSR     MASTER_TUNE_SET


MIDI_CC_END:
    BRA     MIDI_RESET_AND_PROCESS_INCOMING


; ==============================================================================
; MIDI_CC_96
; ==============================================================================
; LOCATION: 0xED05
;
; DESCRIPTION:
; MIDI CC numbers 96, and 97 are used for parameter increment, and decrement.
;
; ==============================================================================

MIDI_CC_96:
    LDAA    #41
    BRA     .MIDI_INC_DEC

; ==============================================================================
; MIDI_CC_97
; ==============================================================================
; LOCATION: 0xED09
;
; DESCRIPTION:
; Handles a MIDI Control Code event of type '97'.
; MIDI CC numbers 96, and 97 are used for parameter increment, and decrement.
; I'm not sure why the double sequential loading of ACCA occurs.
;
; ==============================================================================

MIDI_CC_97:
    LDAA    M_INPUT_MODE
    LDAA    #40

.MIDI_INC_DEC:
    STAA    M_LAST_PRESSED_BTN
    JSR     BTN_YES_NO
    BRA     MIDI_CC_END

; ==============================================================================
; MIDI_CC_123
; ==============================================================================
; LOCATION: 0xED16
;
; DESCRIPTION:
; Handles a MIDI Control Code event of type '123'.
; This subroutine stops all active notes.
;
; ==============================================================================

MIDI_CC_123:
    LDAA    <TIMER_CTRL_STATUS
    PSHA
    CLR     TIMER_CTRL_STATUS
    JSR     VOICE_DEACTIVATE_ALL
    PULA
    STAA    <TIMER_CTRL_STATUS
    BRA     MIDI_CC_END


; ==============================================================================
; MIDI_LOAD_VOLUME
; ==============================================================================
; LOCATION: 0xED24
;
; DESCRIPTION:
; Parses the volume data received via a MIDI CC message of type '7', and loads
; it to the synth's DAC.
; For more information on the synth's analog DAC volume setting, refer to:
; https://ajxs.me/blog/Yamaha_DX7_Technical_Analysis.html
;
; ==============================================================================

MIDI_LOAD_VOLUME:
    ROLA
    ROLA
    ROLA
    ROLA
    TAB

; Rotate the received MIDI data byte 4 bits to the left, and use it as an
; index into the MIDI Volume Table.
    ANDB    #7
    LDX     #TABLE_MIDI_VOLUME
    ABX
    LDAA    0,x
    STAA    P_DAC
    BRA     MIDI_CC_END


; ==============================================================================
; MIDI DAC Volume Table.
; This table contains the values used to translate between a MIDI volume
; message, and the 3-bit volume setting understood by the DAC's analog
; volume control multiplexer circuit.
; These values are simply 0 through 7 with the bits reversed.
; ==============================================================================
TABLE_MIDI_VOLUME:
    FCB 0, 4, 2, 6, 1, 5, 3
    FCB 7

; Is this byte part of a 'Program Change' message?

.IS_PROG_CHG?:
    CMPB    #MIDI_STATUS_PROG_CHANGE
    BNE     .IS_PITCH_BEND?

; Check whether the DX7 can accept 'Program Change' messages.

.PROG_CHG:
    TST     M_INPUT_MODE

; If the synth is in play mode, fall-through to the subroutine below.
    BNE     MIDI_HANDLE_PROG_CHG_EXIT


; ==============================================================================
; MIDI_PROG_CHG
; ==============================================================================
; LOCATION: 0xED47
;
; DESCRIPTION:
; Changes to patch number in ACCA.
; First checks whether the patch is >= 32, which indicates whether this is
; internal, vs cartridge memory.
; It then performs ACCA % 32 to get the relative patch number, and then
; initiates changing patch.
;
; ARGUMENTS:
; Registers:
; * ACCA: The patch number to change the program to.
;
; ==============================================================================

MIDI_PROG_CHG:
    ANDA    #%111111
    BITA    #%100000
    BEQ     .SELECT_INT_MEMORY                  ; Is patch no >= 32?

.MIDI_PROG_CHG_IS_CRT_INSERTED?:
    LDAB    P_CRT_PEDALS_LCD
    BITB    #CRT_FLAG_INSERTED
    BNE     .SELECT_INT_MEMORY

.SELECT_CRT_MEMORY:
    LDAB    #UI_MODE_CRT_INSERTED
    STAB    M_MEM_SELECT_UI_MODE
    BRA     .SET_PATCH_NUMBER

.SELECT_INT_MEMORY:
    CLR     M_MEM_SELECT_UI_MODE

.SET_PATCH_NUMBER:                              ; ACCA % 32.
    ANDA    #%11111
    STAA    M_LAST_INPUT_EVENT
    STAA    M_LAST_PRESSED_BTN
    JSR     PATCH_READ_WRITE

MIDI_HANDLE_PROG_CHG_EXIT:
    RTS

; Is this part of a 'Pitch Bend' MIDI message?

.IS_PITCH_BEND?:
    CMPB    #MIDI_STATUS_PITCH_BEND
    BNE     .IS_AFTERTOUCH?
; Process a 'Pitch Bend' MIDI message.

.PITCH_BEND:
    TST     M_MIDI_PROCESSED_DATA_COUNT
    BEQ     .INCREMENT_DATA_COUNT
    LDAB    <IO_PORT_2_DATA
    PSHB
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.

.PITCH_BEND_PARSE:
    ASLA
    STAA    M_PITCH_BEND_INPUT
    JSR     PITCH_BEND_PARSE
    JMP     MIDI_CC_END
; Is this part of an 'Aftertouch' MIDI message?

.IS_AFTERTOUCH?:
    CMPB    #MIDI_STATUS_AFTERTOUCH
    BNE     .UNKNOWN_MIDI_STATUS
; Process an 'Aftertouch' MIDI message.

.AFTERTOUCH:
    LDAB    <IO_PORT_2_DATA
    PSHB
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    ASLA
    STAA    M_AFTERTOUCH_ANALOG_INPUT
    JMP     MIDI_UPDATE_PITCH_MOD

; At this point, we can't handle whatever this MIDI message is, so return.

.UNKNOWN_MIDI_STATUS:
    RTS

; Check how many bytes of SYSEX data have been received so far.
; This is used to store the various header data components.

.SYSEX_DATA_COUNT_CHECK:
    TST     M_MIDI_PROCESSED_DATA_COUNT
    BNE     .IS_MSG_COUNT_1

; If we've received a MIDI SYSEX header, and the next byte is not the correct
; identifier for the DX7, exit.

.SYSEX_CHECK_IDENTIFIER:
    CMPA    #MIDI_SYSEX_MANUFACTURER_ID
    BNE     .SYSEX_FORCE_END

; Since this is the start of a valid SYSEX message, clear the SYSEX
; message 'substatus' field.
    CLR     M_MIDI_SUBSTATUS

; Increment the pending data count, and wait for the next data byte.

.INCREMENT_DATA_COUNT:
    INC     M_MIDI_PROCESSED_DATA_COUNT
    RTS

; In the event of some erroneous conditions, such as receiving SYSEX
; intended for another device, this forces the end of parsing the current
; SYSEX message.

.SYSEX_FORCE_END:
    LDAA    #MIDI_STATUS_SYSEX_END
    STAA    <M_MIDI_STATUS_BYTE
    RTS
; Is there one data byte already processed?

.IS_MSG_COUNT_1:
    LDAB    <M_MIDI_PROCESSED_DATA_COUNT
    CMPB    #1
    BNE     .IS_MSG_COUNT_2

.IS_STATUS_CORRECT_RX_CH?:
    PSHA
; Use XOR to determine whether this byte matches the current RX MIDI channel.
; If the result is 0, the channel matches.
    ANDA    #%1111
    EORA    M_MIDI_RX_CH
    BEQ     .CHECK_SUBSTATUS
    PULA
    BRA     .SYSEX_FORCE_END

; Check the substatus byte.

.CHECK_SUBSTATUS:
    PULA
    ANDA    #%11110000
    BEQ     .SET_SUBSTATUS_AND_EXIT

; Check if this is a parameter change SYSEX message.
; Any other type is considered invalid.
    CMPA    #%10000
    BEQ     .SET_SUBSTATUS_AND_EXIT
    BRA     .SYSEX_FORCE_END

; Store the SYSEX 'Substatus', and exit.
; Note that the substatus is incremented.

.SET_SUBSTATUS_AND_EXIT:
    INCA
    STAA    <M_MIDI_SUBSTATUS
    INC     M_MIDI_PROCESSED_DATA_COUNT
    RTS

; Are there two data byte already processed?

.IS_MSG_COUNT_2:
    CMPB    #2
    BNE     .IS_MSG_COUNT_3

; Check the SYSEX 'Substatus' to determine whether this is a parameter
; change message, or a voice data transfer.

.IS_SYSEX_BULK_DATA?:
    LDAB    <M_MIDI_SUBSTATUS
    CMPB    #MIDI_SUBSTATUS_BULK
    BEQ     .SYSEX_BULK_DATA

; Check if the substatus indicates that this is data related to a
; SYSEX parameter change.

.IS_SYSEX_PARAM_DATA?:
    CMPB    #MIDI_SUBSTATUS_PARAM
    BNE     .RESET_AND_EXIT_2

; Parse, and store the SYSEX parameter group data.
; Internally: Voice = 1, Function = 2.

.SYSEX_PARAM_DATA:
    STAA    <M_MIDI_INCOMING_DATA
    LSRA
    LSRA
    BEQ     .IS_SYSEX_PARAM_VOICE?

.IS_SYSEX_PARAM_FUNCTION?:
    CMPA    #2
    BNE     .RESET_AND_EXIT_2

.SYSEX_PARAM_STORE:
    STAA    <M_MIDI_SYSEX_PARAM_GRP
    INC     M_MIDI_PROCESSED_DATA_COUNT
    RTS                                         ; Return, and await next data.

; If we're about to receive SYSEX data disable active sensing testing.
; This is where the SYSEX 'format' flag is stored.

.SYSEX_BULK_DATA:
    CLR     M_MIDI_ACTV_SENS_RX_ENABLE
    TSTA
    BEQ     .SET_SYSEX_FORMAT
    CMPA    #MIDI_SYSEX_FMT_PERF
    BEQ     .SET_SYSEX_FORMAT
    CMPA    #MIDI_SYSEX_FMT_BULK
    BNE     .RESET_AND_EXIT_2

.SET_SYSEX_FORMAT:
    STAA    M_MIDI_SYSEX_FORMAT
    CLR     M_MIDI_SYSEX_PARAM_GRP
    INC     M_MIDI_PROCESSED_DATA_COUNT
    RTS

.RESET_AND_EXIT_2:
    CLR     M_MIDI_SUBSTATUS
    CLR     M_MIDI_PROCESSED_DATA_COUNT
    BRA     .SYSEX_FORCE_END

.IS_SYSEX_PARAM_VOICE?:
    INCA
    BRA     .SYSEX_PARAM_STORE

; Are there three data byte already processed?

.IS_MSG_COUNT_3:
    CMPB    #3
    BNE     .IS_MSG_COUNT_4

; Check whether this is a SYSEX parameter message.

.IS_PARAM_MSG?:
    LDAB    <M_MIDI_SYSEX_PARAM_GRP
    BEQ     .NON_PARAM_MSG
    CMPB    #MIDI_SYSEX_PARAM_GRP_VOICE
    BEQ     .GET_UPPER_SYSEX_PARAM_NUM
    CMPB    #MIDI_SYSEX_PARAM_GRP_FUNCTION
    BEQ     .NON_PARAM_MSG
    BRA     .RESET_AND_EXIT_2

.NON_PARAM_MSG:
    STAA    <M_MIDI_INCOMING_DATA

.INCREMENT_AND_EXIT:
    INC     M_MIDI_PROCESSED_DATA_COUNT
    RTS

; This loads the previous byte containing the parameter group and  upper
; two bits of the parameter number into A.
; This then masks the param group values, and shifts the values into B,
; so that the full 8-bit value can be stored in the incoming data register
; to be read on the next iteration.

.GET_UPPER_SYSEX_PARAM_NUM:
    TAB
    ASLB
    LDAA    <M_MIDI_INCOMING_DATA
    ANDA    #%11
    LSRD
    STAB    <M_MIDI_INCOMING_DATA
    BRA     .INCREMENT_AND_EXIT

; Are there four data byte already processed?

.IS_MSG_COUNT_4:
    CMPB    #4
    BNE     .IS_MSG_COUNT_5

; Check if this is a SYSEX parameter message, or part of a data transfer.

.IS_SYSEX_PARAM?:
    LDAB    <M_MIDI_SYSEX_PARAM_GRP
    BEQ     .IS_SYSEX_FMT_PATCH?
    CMPB    #MIDI_SYSEX_PARAM_GRP_VOICE
    BEQ     .SYSEX_VOICE_DATA
    CMPB    #MIDI_SYSEX_PARAM_GRP_FUNCTION
    BEQ     .IS_SYSEX_DIAG_FUNCTION?
    BRA     .RESET_AND_EXIT

.IS_SYSEX_FMT_PATCH?:
    LDAB    M_MIDI_SYSEX_FORMAT
    BEQ     .IS_INT_MEM_PROTECTED?

.IS_SYSEX_FMT_PERF?:
    CMPB    #MIDI_SYSEX_FMT_PERF
    BEQ     .SYSEX_RX_START

; Check for INT memory protection prior to receiving single/bulk voice dump.

.IS_INT_MEM_PROTECTED?:
    TIM     #MEM_PROTECT_INT, M_MEM_PROTECT_FLAGS
    BNE     .INT_MEM_PROTECTED
    TST     M_MIDI_SYS_INFO_AVAIL
    BEQ     .SYSEX_FORCE_END_PRE
    CLR     TIMER_CTRL_STATUS

.SYSEX_RX_START:
    CLR     IO_PORT_2_DATA
    INC     M_MIDI_PROCESSED_DATA_COUNT
    CLR     M_MIDI_SYSEX_CHECKSUM
    LDD     #0
    STD     <M_MIDI_SYSEX_RX_COUNT
    RTS

; If the function group is set to 2 (Function Parameter), and the parameter
; is less-than or equal to 42, this means that a switch event is being
; transmitted.

.IS_SYSEX_DIAG_FUNCTION?:
    LDAB    <M_MIDI_INCOMING_DATA
    CMPB    #42
    BCS     .IS_PANEL_CTRL_MSG?                 ; If B <= 42, branch.
    BRA     .SYSEX_FUNCTION_DATA

; In the event that the internal memory is protected, this prints the
; appropriate error message, then proceeds to force SYSEX message end.

.INT_MEM_PROTECTED:
    JSR     PRINT_MSG_MEMORY_PROTECTED

.SYSEX_FORCE_END_PRE:
    JMP     .SYSEX_FORCE_END

; Are there five data byte already processed?

.IS_MSG_COUNT_5:
    CMPB    #5
    BNE     .RESET_AND_EXIT

; If there are 5 data bytes already processed, then check whether this is a
; bulk voice data transfer, or a transfer of performance data.
    LDAB    M_MIDI_SYSEX_FORMAT
    CMPB    #MIDI_SYSEX_FMT_PERF
    BNE     .IS_SYSEX_BULK?
    JMP     .SYSEX_PERF_RECEIVE

.RESET_AND_EXIT:
    CLR     M_MIDI_PROCESSED_DATA_COUNT
    CLR     M_MIDI_SUBSTATUS
    RTS

.SYSEX_VOICE_DATA:
    TST     M_MIDI_SYS_INFO_AVAIL
    BEQ     .END_MIDI_PROCESS_RECEIVED_DATA

; If we're currently in 'compare' mode, do nothing.

.MIDI_PROCESS_DATA_IS_IN_COMPARE_MODE?:
    LDAB    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPB    #EDITED_PATCH_IN_COMPARE
    BEQ     .END_MIDI_PROCESS_RECEIVED_DATA
    CLR     IO_PORT_2_DATA
    LDX     #M_PATCH_CURRENT_BUFFER
    LDAB    <M_MIDI_INCOMING_DATA
    ABX
    STAA    0,x
    JSR     PATCH_LOAD_DATA
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    JSR     UI_PRINT_MAIN
    JSR     LED_PRINT_PATCH_NUMBER

.ENABLE_IRQ_AND_EXIT:
    LDAA    #1
    STAA    <IO_PORT_2_DATA                     ; Re-enable IRQ.

.END_MIDI_PROCESS_RECEIVED_DATA:
    CLR     M_MIDI_PROCESSED_DATA_COUNT
    CLR     M_MIDI_SUBSTATUS
    RTS

; Any value under 42 indicates the transfer of a panel control event.
; At this point, ACCA still contains the incoming MIDI byte, 0xE1 contains
; the PREVIOUS byte.
; 0xE1 = Key number.
; ACCA = Key state: 00 for RELEASE, 0x7F for DOWN.

.IS_PANEL_CTRL_MSG?:                            ; Disable IRQ.
    CLR     IO_PORT_2_DATA
    TSTA
    BEQ     .SWITCH_UP

.SWITCH_DOWN:
    LDAA    <M_MIDI_INCOMING_DATA
    JSR     INPUT_BTN_PRESSED
    BRA     .ENABLE_IRQ_AND_EXIT

.SWITCH_UP:
    LDAA    <M_MIDI_INCOMING_DATA
    JSR     INPUT_BTN_RELEASED
    BRA     .ENABLE_IRQ_AND_EXIT

; Parse the SYSEX function data.
; The parameter number is stored in the incoming data byte register.
; Refer to this site for the function parameter number reference:
; https://homepages.abdn.ac.uk/d.j.benson/pages/dx7/sysex-format.txt

.SYSEX_FUNCTION_DATA:
    TST     M_MIDI_SYS_INFO_AVAIL
    BEQ     .SYSEX_ENABLE_IRQ_AND_EXIT
    CLR     IO_PORT_2_DATA                      ; Disable IRQ.
    LDAB    <M_MIDI_INCOMING_DATA
    SUBB    #64
    ASLB
    LDX     #TABLE_SYSEX_FN_DATA_POINTERS
    ABX
    LDX     0,x
    STAA    0,x
    JSR     VOICE_RESET
    JSR     PORTA_COMPUTE_RATE_VALUE
    JSR     MOD_PROCESS_INPUT_SOURCES
    JSR     UI_PRINT_MAIN

.SYSEX_ENABLE_IRQ_AND_EXIT:
    BRA     .ENABLE_IRQ_AND_EXIT

; Check whether this SYSEX message is a bulk voice data transfer.

.IS_SYSEX_BULK?:
    TST     M_MIDI_SYSEX_FORMAT
    BNE     .SYSEX_BULK_RECEIVE

; If this is a transfer of a 155 byte single voice, then check how many
; bytes we've already received.
    LDAB    <M_MIDI_SYSEX_RX_DATA_COUNT
    CMPB    #155
    BEQ     .SYSEX_PATCH_VALIDATE_CHECKSUM
    LDX     #M_PATCH_CURRENT_BUFFER
    ABX
    STAA    0,x                                 ; Store in patch buffer.
    ADDA    <M_MIDI_SYSEX_CHECKSUM
    STAA    <M_MIDI_SYSEX_CHECKSUM              ; Add to checksum.
    INC     M_MIDI_SYSEX_RX_DATA_COUNT
    RTS

; Validate the data transfer.

.SYSEX_PATCH_VALIDATE_CHECKSUM:
    BSR     MIDI_SYSEX_VALIDATE_CHECKSUM
    BEQ     .SYSEX_PATCH_SUCCESS

.SYSEX_PATCH_CHECKSUM_FAILURE:
    BSR     MIDI_PRINT_MSG_CHECKSUM_ERR
    BRA     .SYSEX_EXIT

; Now that all of the patch data has been received, set the synth's 'Patch
; Edited' flag to indicate that the current patch has been modified, and
; proceed to parse the newly loaded data.

.SYSEX_PATCH_SUCCESS:
    CLR     M_INPUT_MODE
    CLR     M_MEM_SELECT_UI_MODE
    LDAA    #EDITED_PATCH_IN_WORKING
    STAA    M_PATCH_CURRENT_MODIFIED_FLAG
    LDAB    <IO_PORT_2_DATA
    PSHB

.SYSEX_PATCH_LOAD_DATA:
    CLR     IO_PORT_2_DATA
    JSR     PATCH_LOAD_DATA
    CLR     M_PATCH_READ_OR_WRITE
    JSR     UI_PRINT_MAIN
    JSR     LED_PRINT_PATCH_NUMBER
    LDAA    #%111111
    STAA    M_PATCH_CURRENT_OPS_ON_OFF

.RESTORE_IRQ_STATUS:
    PULB
    STAB    <IO_PORT_2_DATA

.SYSEX_EXIT:
    LDAB    #%1000
    STAB    <TIMER_CTRL_STATUS                  ; Re-enable timer IRQ.
    BRA     .SYSEX_ENABLE_IRQ_AND_EXIT


MIDI_PRINT_MSG_CHECKSUM_ERR:
    LDX     #aCheckSumError
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

aCheckSumError:      FCC "CHECK SUM ERROR!", 0

; If this is a bulk voice data transfer, check whether we've received all of
; the incoming data.

.SYSEX_BULK_RECEIVE:
    LDX     <M_MIDI_SYSEX_RX_COUNT
    CPX     #$1000

; If all 4096 bytes have been received, branch.
    BEQ     .SYSEX_BULK_VALIDATE_CHECKSUM
    PSHA
    LDD     <M_MIDI_SYSEX_RX_COUNT
    ADDD    #M_EXTERNAL_RAM_START
    XGDX
    PULA

; Store the received byte at 0x1000[0xF4].
    STAA    0,x
    ADDA    <M_MIDI_SYSEX_CHECKSUM
    STAA    <M_MIDI_SYSEX_CHECKSUM              ; Udpate the checksum.
    LDX     <M_MIDI_SYSEX_RX_COUNT
    INX
    STX     <M_MIDI_SYSEX_RX_COUNT              ; Increment received count.
    RTS

; Use the accumulated 'checksum' value to validate the data transfer.

.SYSEX_BULK_VALIDATE_CHECKSUM:
    BSR     MIDI_SYSEX_VALIDATE_CHECKSUM
    BEQ     .SYSEX_BULK_SUCCESS

.SYSEX_BULK_CHECKSUM_FAILURE:
    BSR     MIDI_PRINT_MSG_CHECKSUM_ERR
    BRA     .SYSEX_EXIT

.SYSEX_BULK_SUCCESS:
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    LDX     #aMidiReceived
    JSR     LCD_CLR_WRITE_LINE_2_THEN_PRINT
    BRA     .SYSEX_EXIT


; ==============================================================================
; MIDI_SYSEX_VALIDATE_CHECKSUM
; ==============================================================================
; LOCATION: 0xEF83
;
; DESCRIPTION:
; Validates the checksum created during the receiving of SYSEX data, to
; determine whether the received data is valid.
;
; ARGUMENTS:
; Registers:
; * ACCA: The 'summed' incoming SYSEX data byte to validate against
;         the checksum.
;
; RETURNS:
; * CCR[z]: This flag will be zero in the case that the SYSEX data is valid.
;
; ==============================================================================

MIDI_SYSEX_VALIDATE_CHECKSUM:
    LDAB    <M_MIDI_SYSEX_CHECKSUM
    NEGB
    ANDB    #%1111111
    STAB    <M_MIDI_SYSEX_CHECKSUM
    CMPA    <M_MIDI_SYSEX_CHECKSUM
    RTS


; If the format indicates that this SYSEX message is transferring
; performance data, download the 94 bytes to the synth.
; The synth uses the voice buffer memory location as a temporary storage
; for the performance data dump, as it will not be in use during the
; transfer process.

.SYSEX_PERF_RECEIVE:
    LDAB    <M_MIDI_SYSEX_RX_DATA_COUNT
    CMPB    #94
    BEQ     .SYSEX_PERF_VALIDATE_CHECKSUM
    LDX     #M_MIDI_PERF_DATA_BUFFER
    ABX
    STAA    0,x
    ADDA    <M_MIDI_SYSEX_CHECKSUM
    STAA    <M_MIDI_SYSEX_CHECKSUM
    INC     M_MIDI_SYSEX_RX_DATA_COUNT
    RTS

; Validate the checksum for the received bulk performance data dump.

.SYSEX_PERF_VALIDATE_CHECKSUM:
    BSR     MIDI_SYSEX_VALIDATE_CHECKSUM
    BEQ     .SYSEX_PERF_SUCCESS

.SYSEX_PERF_CHECKSUM_FAILURE:
    BSR     MIDI_PRINT_MSG_CHECKSUM_ERR
    BRA     .SYSEX_PERF_EXIT

.SYSEX_PERF_SUCCESS:
    JSR     MIDI_PROCESS_SYSEX_PERF_BULK_DATA
    JSR     PORTA_COMPUTE_RATE_VALUE
    JSR     MOD_PROCESS_INPUT_SOURCES
    JSR     VOICE_RESET_EVENT_AND_PITCH_BUFFERS

.SYSEX_PERF_EXIT:
    JMP     .ENABLE_IRQ_AND_EXIT


; ==============================================================================
; MIDI_PROCESS_SYSEX_PERF_BULK_DATA
; ==============================================================================
; LOCATION: 0xEFB8
;
; DESCRIPTION:
; Processes the bulk performance data dump received via SYSEX.
; The various performance data fields are parsed and stored.
;
; ==============================================================================

MIDI_PROCESS_SYSEX_PERF_BULK_DATA:
    CLRB
    LDX     #M_MIDI_PERF_DATA_BUFFER

.LOAD_POLYPHONY:
    LDAA    2,x
    BSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_PITCH_BEND_RANGE:
    LDAA    3,x
    BSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_PITCH_BEND_STEP:
    LDAA    4,x
    BSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_PORTA_MODE:
    LDAA    7,x
    BSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_PORTA_GLISS:
    LDAA    6,x
    BSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_PORTA_TIME:
    LDAA    5,x
    BSR     MIDI_STORE_SYSEX_PERF_DATA

.PARSE_MOD_WHEEL_SENS:
    LDAA    9,x
    JSR     MIDI_QUANTISE_PERF_DATA
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_MOD_WHEEL_ASSIGN:
    LDAA    10,x
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.PARSE_FOOT_CTRL_SENS:
    LDAA    11,x
    JSR     MIDI_QUANTISE_PERF_DATA
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_FOOT_CTRL_ASSIGN:
    LDAA    12,x
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.PARSE_BRTH_CTRL_SENS:
    LDAA    15,x
    JSR     MIDI_QUANTISE_PERF_DATA
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_BRTH_CTRL_ASSIGN:
    LDAA    16,x
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.PARSE_AFTERTOUCH_SENS:
    LDAA    13,x
    JSR     MIDI_QUANTISE_PERF_DATA
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.LOAD_AFTERTOUCH_ASSIGN:
    LDAA    14,x
    JSR     MIDI_STORE_SYSEX_PERF_DATA

.PROGRAM_CHANGE:
    LDAA    0,x
    CLR     M_INPUT_MODE
    JSR     MIDI_PROG_CHG
    RTS


; ==============================================================================
; MIDI_STORE_SYSEX_PERF_DATA
; ==============================================================================
; LOCATION: 0xF011
;
; DESCRIPTION:
; Stores parsed SYSEX performance data.
; Loads the 16-bit address in the table of pointers at 0xF028, using ACCB as
; an index, into IX. Then the value in ACCA is stored at this address.
; ACCB is then incremented.
;
; ARGUMENTS:
; Registers:
; * ACCA: The parameter value to store in the performance data table.
; * ACCB: The index to store this parameter at.
;
; ==============================================================================

MIDI_STORE_SYSEX_PERF_DATA:
    PSHX
    LDX     #TABLE_SYSEX_FN_DATA_POINTERS
    ASLB
    ABX
    LDX     0,x
    STAA    0,x
    RORB
    INCB
    PULX
    RTS


; ==============================================================================
; MIDI_QUANTISE_PERF_DATA
; ==============================================================================
; DESCRIPTION:
; Quantises the individual fields received in a SYSEX bulk performance data
; dump to convert them to the device's internal formats.
;
; ARGUMENTS:
; Registers:
; * ACCA: The data to be quantised.
;
; RETURNS:
; * ACCA: The quantised performance data field.
;
; ==============================================================================

MIDI_QUANTISE_PERF_DATA:
    PSHB
    LDAB    #212
    MUL
    LSLD
    LSLD
    LSLD
    PULB
    RTS


; ==============================================================================
; SYSEX Performance Data Parameter Pointer Table.
; This table is used to instuct the software about where to store incoming
; SYSEX performance data.
; ==============================================================================
TABLE_SYSEX_FN_DATA_POINTERS:
    FDB M_MONO_POLY
    FDB M_PITCH_BND_RANGE
    FDB M_PITCH_BND_STEP
    FDB M_PORTA_MODE
    FDB M_PORTA_GLISS_ENABLED
    FDB M_PORTA_TIME
    FDB M_MOD_WHEEL_RANGE
    FDB M_MOD_WHEEL_ASSIGN_FLAGS
    FDB M_FOOT_CTRL_RANGE
    FDB M_FT_CTRL_ASSIGN_FLAGS
    FDB M_BRTH_CTRL_RANGE
    FDB M_BRTH_CTRL_ASSIGN_FLAGS
    FDB M_AFTERTOUCH_RANGE
    FDB M_AFTERTOUCH_ASSIGN_FLAGS
aMidiReceived:       FCC " MIDI RECEIVED", 0


; ==============================================================================
; UI_PRINT
; ==============================================================================
; LOCATION: 0xF05D
;
; DESCRIPTION:
; This subroutine is responsible for printing the synth's main user-interface,
; depending on what 'UI Mode' the synth is currently in.
; This is the main entry point for printing the synth's user-interface to the
; LCD screen output.
;
; ==============================================================================
;

UI_PRINT_MAIN:
    LDX     #TABLE_UI_FUNCTIONS

; This variable contains both the current 'UI Mode', and whether internal,
; or cartridge memory is currently selected.
; This variable controls not only what menu is printed, but how the synth
; responds to various user front-panel inputs.
; This variable is used as an index into the menu function pointer table.
; A function pointer is loaded from this table, and then jumped to.
    LDAB    M_MEM_SELECT_UI_MODE
    ASLB
    ABX
    LDX     0,x
    JMP     0,x


; ==============================================================================
; UI Function Pointer Table.
; Contains pointers to the synth's main UI functions.
; This table is looked up with the synth's 'UI Mode' variable as an index.
; This decides what user interface is presented to the user.
; ==============================================================================
TABLE_UI_FUNCTIONS:
    FDB UI_PRINT_PATCH_INFO
    FDB UI_PRINT_PATCH_INFO
    FDB UI_EDIT_MODE
    FDB UI_EDIT_PATCH_NAME
    FDB UI_PRINT_SAVE_LOAD_MEM_MSG
    FDB UI_FUNCTION_MODE
    FDB UI_MEM_PROTECT_STATE


; ==============================================================================
; LCD_WRITE_STR_TO_BUFFER_LINE_2
; ==============================================================================
; LOCATION: 0xF06D
;
; DESCRIPTION:
; Writes a null-terminated string to the second line of the synth's LCD
; string buffer.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the null-terminated string to write to the buffer.
;
; ==============================================================================

LCD_WRITE_STR_TO_BUFFER_LINE_2:
    PSHX
    LDX     #M_LCD_BUFFER_LN_2
    STX     <M_COPY_DEST_PTR
    PULX
    JSR     LCD_WRITE_STR_TO_BUFFER
    RTS


; ==============================================================================
; UI_PRINT_PATCH_INFO
; ==============================================================================
; LOCATION: 0xF078
;
; DESCRIPTION:
; Prints the main patch info dialog to the synth's LCD screen. e.g:
; 'CARTRIDGE VOICE'
; 'CRT 8 BASS1    '
;
; ==============================================================================

UI_PRINT_PATCH_INFO:
    LDAA    #32
    LDAB    #16

; Fill the first line of string buffer (16 chars) with ASCII spaces.
    LDX     #M_LCD_BUFFER_LN_1

.CLEAR_STR_BUFFER_LOOP:
    STAA    0,x
    INX
    DECB
    BNE     .CLEAR_STR_BUFFER_LOOP

.PRINT_VOICE_SOURCE:
    LDAA    M_MEM_SELECT_UI_MODE
    BNE     .CRT_VOICE

.INT_VOICE:
    LDX     #aInternalVoice
    BRA     .PRINT_LCD_LINE_1

.CRT_VOICE:
    LDX     #aCartridgeVoice

.PRINT_LCD_LINE_1:
    PSHX
    JSR     LCD_CLEAR_STR_BUFFER
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR
    PULX
    JSR     LCD_WRITE_STR_TO_BUFFER

; Depending on whether the patch is in internal, or cartridge memory,
; print either the 'INT', or 'CRT' prefix before the patch number.

.IS_PATCH_IN_INT_OR_CRT?:
    LDAA    M_PATCH_CURRENT_CRT_OR_INT
    BNE     .PRINT_PATCH_NUM_PREFIX_CRT

.PRINT_PATCH_NUM_PREFIX_INT:
    LDX     #aInt
    BRA     .SET_LCD_BUFFER_DEST

.PRINT_PATCH_NUM_PREFIX_CRT:
    LDX     #aCrt

.SET_LCD_BUFFER_DEST:
    PSHX
    LDX     #M_LCD_BUFFER_LN_2
    STX     <M_COPY_DEST_PTR
    PULX
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDX     #$2632                              ; Buffer Line 2 + 3.
    JSR     LCD_PRINT_PATCH_NUMBER
    LDX     #$2635                              ; Buffer Line 2 + 6.
    JSR     LCD_PRINT_PATCH_NAME_TO_BUFFER
    JSR     LCD_PRINT_STR_BUFFER

.HAS_PATCH_BEEN_EDITED?:
    LDAA    M_PATCH_CURRENT_MODIFIED_FLAG
    CMPA    #EDITED_PATCH_IN_WORKING
    BNE     .PATCH_NOT_EDITED
    JMP     SHIFT_LCD_CURSOR_6_RIGHT

.PATCH_NOT_EDITED:
    RTS


; ==============================================================================
; UI_EDIT_MODE
; ==============================================================================
; LOCATION: 0xF0D0
;
; DESCRIPTION:
; This subroutine prints the user interface for menu items related to buttons
; 1-32, while the synth is in 'Edit Mode'.
;
; ==============================================================================

UI_EDIT_MODE:
    CLR     M_PATCH_NAME_EDIT_ACTIVE

; If the last-pressed button was the 'Edit' button, reset the last-pressed
; button to be the previously selected 'Edit Parameter', and call the
; subroutine again.

.IS_LAST_BUTTON_EDIT?:
    LDAA    M_LAST_PRESSED_BTN
    CMPA    #BUTTON_EDIT_CHAR
    BNE     .BTN_NOT_EDIT
    JMP     .RESET_EDIT_PARAM

.BTN_NOT_EDIT:
    JSR     LCD_CLEAR_STR_BUFFER_LINE_2
    LDAA    M_LAST_PRESSED_BTN
    CMPA    #6
    BCC     .BTN_GT_EQ_6
    JMP     .EDIT_BUTTONS_1_TO_6

.BTN_GT_EQ_6:
    CMPA    #46

; @TODO: Under what circumstances does this occur?
; I'm not entirely sure under what circumstances this value will be '46'.
    BNE     .IS_BUTTON_17?

.UI_EDIT_RESET_LAST_PRESSED_BUTTON:
    LDAA    M_EDIT_PARAM_CURRENT
    STAA    M_LAST_PRESSED_BTN

.IS_BUTTON_17?:
    CMPA    #BUTTON_17
    BNE     .IS_BUTTON_OP_SELECT?

.EDIT_OSC_MODE_SYNC:
    LDAA    <M_EDIT_OSC_MODE_SYNC_FLAG
    BNE     .EDIT_OSC_SYNC
    BRA     .EDIT_OSC_MODE

.EDIT_OSC_SYNC:
    LDAA    #29
    BRA     .STORE_EDIT_PARAM_STR_INDEX

.EDIT_OSC_MODE:
    LDAA    #28

.STORE_EDIT_PARAM_STR_INDEX:
    STAA    M_EDIT_PARAM_STR_INDEX
    JMP     .PRINT_EDIT_INFO?

; If the last pressed button was the 'Operator Select' button, send the
; SYSEX message corresponding to enabling/disabling an operator, and reset
; the last-pressed button.

.IS_BUTTON_OP_SELECT?:
    CMPA    #BUTTON_OP_SELECT
    BNE     .IS_BUTTON_7?
    JMP     MIDI_SYSEX_SEND_OP_ON_OFF

.IS_BUTTON_7?:
    CMPA    #BUTTON_7
    BNE     .IS_BUTTON_18?

.PRINT_ALG_SELECT:
    JSR     UI_PRINT_ALG_INFO
    LDX     #aAlgorithmSelec
    JSR     LCD_WRITE_STR_TO_BUFFER_LINE_2
    LDX     #M_PATCH_CURRENT_ALG
    JSR     MIDI_SYSEX_SEND_PARAM_CHG
    JMP     .END_UI_EDIT_MODE

.IS_BUTTON_18?:
    CMPA    #BUTTON_18
    BEQ     .EDIT_FREQUENCY

.IS_BUTTON_19?:
    CMPA    #BUTTON_19
    BEQ     .EDIT_FREQUENCY
    JMP     .IS_BUTTON_20?

.EDIT_FREQUENCY:
    JSR     UI_PRINT_ALG_INFO
    JSR     PATCH_GET_PTR_TO_SELECTED_OP

; Subtract 17 to determine whether the button pressed was 18, or 19.
    LDAA    M_LAST_PRESSED_BTN
    SUBA    #17
    BNE     .PRINT_MSG_FREQ_FINE

.PRINT_MSG_FREQ_COARSE:
    LDAB    #18
    JSR     MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
    LDX     #aFCoarse
    BRA     .PRINT_EDIT_FREQ_MSG

.PRINT_MSG_FREQ_FINE:
    LDAB    #19
    JSR     MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
    LDX     #aFFine

.PRINT_EDIT_FREQ_MSG:
    JSR     LCD_WRITE_STR_TO_BUFFER_LINE_2
    CLR     M_EDIT_PARAM_MAX_VALUE
    JSR     PATCH_GET_PTR_TO_SELECTED_OP

; Check whether this operator uses a fixed, or ratio frequency.

.IS_FIXED_FREQUENCY?:
    TST     17,x
    BNE     .EDIT_FREQUENCY_FIXED

; Load the patch's coarse operator frequency.
; If this value is above 31, set to 1.

.FREQ_MODE_RATIO:
    LDAA    18,x
    BEQ     .COARSE_FREQ_0
    CMPA    #31
    BLS     .COARSE_FREQ_GT_0
    LDAA    #1
    STAA    18,x

.COARSE_FREQ_GT_0:
    LDAB    #100
    MUL
    BRA     .STORE_PRINT_VALUE

.COARSE_FREQ_0:
    LDAB    #50
    CLRA

.STORE_PRINT_VALUE:
    STD     M_EDIT_RATIO_FREQ_PRINT_VALUE
    LDAB    19,x

; Load the 'Operator Fine Freq' value.
; If this value is above 99, set to 0.
    CMPB    #99
    BLS     .PRINT_RATIO_FREQ_COMPUTE_FINE
    CLRB
    STAB    19,x

; Load the 'Operator Coarse Freq' value.
; Increment, and shift right if non-zero.

.PRINT_RATIO_FREQ_COMPUTE_FINE:
    LDAA    18,x
    BNE     .PRINT_RATIO_FREQ_COMPUTE_RATIO
    INCA
    LSRB

; For coarse frequencies above 0, the final operator ratio =
;   (100 * FREQ_COARSE) + (FREQ_COARSE * FREQ_FINE)
; For a coarse frequency of 0, the final operator ratio =
;   50 + ((FREQ_COARSE + 1 ) * (FREQ_FINE >> 1))

.PRINT_RATIO_FREQ_COMPUTE_RATIO:
    MUL
    ADDD    M_EDIT_RATIO_FREQ_PRINT_VALUE
    JSR     CONVERT_INT_TO_STR
    LDX     <M_COPY_DEST_PTR
    LDAA    M_PARSED_INT_THSNDS

; If the final value is below 1000, print a space in this column.
    BEQ     .PRINT_RATIO_FREQ_SPACE
    ADDA    #'0'
    BRA     .PRINT_RATIO_FREQ

.PRINT_RATIO_FREQ_SPACE:
    LDAA    #' '

.PRINT_RATIO_FREQ:
    STAA    0,x
    LDAA    M_PARSED_INT_HNDRDS

; Offset from ASCII '0' to convert each value to an ASCII char.
    ADDA    #'0'
    STAA    1,x
    LDAA    #'.'
    STAA    2,x
    LDAA    M_PARSED_INT_TENS
    ADDA    #'0'
    STAA    3,x
    LDAA    M_PARSED_INT_DIGITS
    ADDA    #'0'
    STAA    4,x
    JMP     .END_UI_EDIT_MODE

.EDIT_FREQUENCY_FIXED:
    LDAB    19,x
    CMPB    #99

; Load the patch's fine operator frequency value.
; If this value is greater than 99, clear it.
    BLS     .LOAD_FIXED_FREQ_VALUES
    CLRB
    STAB    19,x

.LOAD_FIXED_FREQ_VALUES:
    PSHX

; Use the patch's fixed frequency value as an index into this table, and
; load the resulting value into ACCD.
    LDX     #TABLE_FREQ_FIXED_FINE_VALUES
    ASLB
    ABX
    LDD     0,x
    JSR     CONVERT_INT_TO_STR
    PULX

; Load the patch's coarse operator frequency.
; If this value is above 31, set to 1.

.LOAD_OPERATOR_FREQ_COARSE:
    LDAB    18,x
    CMPB    #31
    BLS     .PRINT_FIXED_FREQ
    LDAB    #1
    STAB    18,x

; The 'Operator Coarse Frequency' is clamped at 4, since there are only
; 4 valid values for a fixed frequency.
; This value is used to determine how many digits lie before the decimal
; point when printing the value.
; e.g 1hz = 0, 10hz = 1, 100hz = 2, 1000hz.
; The first entry in the table is 1023. If the coarse freq is 100hz then
; this will print as: 102.3xx

.PRINT_FIXED_FREQ:
    ANDB    #3

; At this point, the copy destination ptr points to the end of the
; LCD buffer, after the final '=' char of the previously printed string.
    LDX     <M_COPY_DEST_PTR
    LDAA    M_PARSED_INT_THSNDS

; Offset the number value with ASCII '0' to convert to an ASCII value.
    ADDA    #'0'
    STAA    0,x
    INX
    DECB

; If value is non-negative after subtracting, branch.
    BPL     .PRINT_FIXED_FREQ_HUNDREDS
    BSR     UI_EDIT_FREQ_PRINT_PERIOD

.PRINT_FIXED_FREQ_HUNDREDS:
    LDAA    M_PARSED_INT_HNDRDS
    BSR     UI_EDIT_FREQ_PRINT_DIGIT
    BMI     .PRINT_FIXED_FREQ_TENS
    DECB
    BPL     .PRINT_FIXED_FREQ_TENS
    BSR     UI_EDIT_FREQ_PRINT_PERIOD

.PRINT_FIXED_FREQ_TENS:
    LDAA    M_PARSED_INT_TENS
    BSR     UI_EDIT_FREQ_PRINT_DIGIT
    BMI     .PRINT_FIXED_FREQ_DIGITS
    DECB
    BPL     .PRINT_FIXED_FREQ_DIGITS
    BSR     UI_EDIT_FREQ_PRINT_PERIOD

.PRINT_FIXED_FREQ_DIGITS:
    LDAA    M_PARSED_INT_DIGITS
    BSR     UI_EDIT_FREQ_PRINT_DIGIT
    BMI     .PRINT_FIXED_FREQ_HZ
    LDAA    #$20                                ; ' '
    STAA    0,x
    INX

.PRINT_FIXED_FREQ_HZ:
    LDD     #'Hz'
    JMP     .PRINT_FINAL_CHARS


; ==============================================================================
; UI_EDIT_FREQ_PRINT_PERIOD
; ==============================================================================
; LOCATION: 0xF210
;
; DESCRIPTION:
; Prints an ASCII period char ('.') to an arbitrary memory location.
; Used in multiple locations when printing a patch's operator frequency values
; to the synth's LCD output.
; The IX pointer is incremented in this function.
;
; ARGUMENTS:
; Registers:
; * IX:   The memory location to print the ASCII '.' character to.
;
; ==============================================================================

UI_EDIT_FREQ_PRINT_PERIOD:
    LDAA    #'.'

; Offset the numeric value with ASCII '0' to convert to an ASCII
; value, then store.
    STAA    0,x
    INX
    RTS


; ==============================================================================
; UI_EDIT_FREQ_PRINT_DIGIT
; ==============================================================================
; LOCATION: 0xF216
;
; DESCRIPTION:
; Prints an ASCII char to an arbitrary memory location.
; Used in multiple locations when printing a patch's operator frequency values
; to the synth's LCD output.
; The IX pointer is incremented in this function.
;
; ARGUMENTS:
; Registers:
; * IX:   The memory location to print the ASCII character to.
;
; ==============================================================================

UI_EDIT_FREQ_PRINT_DIGIT:
    ADDA    #'0'

; Offset the numeric value with ASCII '0' to convert to an ASCII
; value, then store.
    STAA    0,x
    INX
    TSTB
    RTS


; ==============================================================================
; Fine Frequency Values Table.
; ==============================================================================
TABLE_FREQ_FIXED_FINE_VALUES:
    FDB $3E8
    FDB $3FF
    FDB $417
    FDB $430
    FDB $448
    FDB $462
    FDB $47C
    FDB $497
    FDB $4B2
    FDB $4CE
    FDB $4EB
    FDB $508
    FDB $526
    FDB $545
    FDB $564
    FDB $585
    FDB $5A5
    FDB $5C7
    FDB $5EA
    FDB $60D
    FDB $631
    FDB $656
    FDB $67C
    FDB $6A2
    FDB $6CA
    FDB $6F2
    FDB $71C
    FDB $746
    FDB $771
    FDB $79E
    FDB $7CB
    FDB $7FA
    FDB $829
    FDB $85A
    FDB $88C
    FDB $8BF
    FDB $8F3
    FDB $928
    FDB $95F
    FDB $997
    FDB $9D0
    FDB $A0A
    FDB $A46
    FDB $A84
    FDB $A9C
    FDB $B02
    FDB $B44
    FDB $B87
    FDB $BCC
    FDB $C12
    FDB $C5A
    FDB $CA4
    FDB $CEF
    FDB $D3C
    FDB $D8B
    FDB $DDC
    FDB $E2F
    FDB $E83
    FDB $EDA
    FDB $F32
    FDB $F8D
    FDB $FEA
    FDB $1049
    FDB $10AA
    FDB $110D
    FDB $1173
    FDB $11DB
    FDB $1245
    FDB $12B2
    FDB $1322
    FDB $1394
    FDB $1409
    FDB $1480
    FDB $14FA
    FDB $1577
    FDB $15F7
    FDB $167A
    FDB $1700
    FDB $178A
    FDB $1816
    FDB $18A6
    FDB $1939
    FDB $19CF
    FDB $1A69
    FDB $1B06
    FDB $1BA7
    FDB $1C4C
    FDB $1CF5
    FDB $1DA2
    FDB $1E52
    FDB $1F07
    FDB $1FC0
    FDB $207E
    FDB $213F
    FDB $220E
    FDB $22D1
    FDB $23A0
    FDB $2475
    FDB $254E
    FDB $262C

.IS_BUTTON_20?:
    CMPA    #BUTTON_20
    BNE     .IS_BTN_21?

.PRINT_OSC_DETUNE:
    JSR     UI_PRINT_ALG_INFO
    LDX     #aOscDetune
    JSR     LCD_WRITE_STR_TO_BUFFER_LINE_2

.SEND_PARAM_OVER_MIDI:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    LDAB    #20
    JSR     MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
    LDAB    20,x

; Load the operator detune value.
; If this value is over 14, reset it to 7.
    CMPB    #14
    BLS     .PRINT_OSC_DETUNE_VALUE
    LDAB    #7
    STAB    $14,x

; Use the operator detune value as an index into this string.
; Copy it to the LCD buffer, then print.

.PRINT_OSC_DETUNE_VALUE:
    ASLB
    LDX     #a76543210123456
    ABX
    LDD     0,x
    LDX     <M_COPY_DEST_PTR

.PRINT_FINAL_CHARS:
    STAA    0,x
    STAB    1,x
    JMP     .END_UI_EDIT_MODE
a76543210123456:     FCC "-7-6-5-4-3-2-1 0+1+2+3+4+5+6+7"


; ==============================================================================
; MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
; ==============================================================================
; LOCATION: 0xF332
;
; DESCRIPTION:
; Sends a MIDI CC message with a specific operator parameter.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the operator in patch memory to send the parameter of.
; * ACCB: The offset of this specific operator parameter from the start of the
;         operator memory address in IX.
;
; ==============================================================================

MIDI_SYSEX_SEND_OP_PARAM_RELATIVE:
    PSHX
    ABX
    JSR     MIDI_SYSEX_SEND_PARAM_CHG
    PULX
    RTS


; The following branches check the last button pressed to determine which
; EG parameter is being edited.

.IS_BTN_21?:
    CLRB
    CMPA    #BUTTON_21
    BEQ     .ADD_STR_OFFSET_FOR_EG_FUNCTIONS
    INCB
    CMPA    #BUTTON_22
    BEQ     .ADD_STR_OFFSET_FOR_EG_FUNCTIONS
    INCB
    CMPA    #BUTTON_29
    BEQ     .ADD_STR_OFFSET_FOR_EG_FUNCTIONS
    INCB
    CMPA    #BUTTON_30
    BNE     .IS_BTN_25?

.ADD_STR_OFFSET_FOR_EG_FUNCTIONS:
    LDAA    #4
    MUL
    ADDB    <M_EDIT_EG_RATE_LVL_SUB_FN
    ADDB    #30
    STAB    M_EDIT_PARAM_STR_INDEX
    JMP     .PRINT_EDIT_INFO?

.IS_BTN_25?:
    CLRB
    CMPA    #BUTTON_25
    BEQ     .BTN_IS_24_25
    INCB
    CMPA    #BUTTON_24
    BEQ     .BTN_IS_24_25
    STAA    M_EDIT_PARAM_STR_INDEX
    JMP     .IS_BUTTON_31?

; This toggle value is either 0, or 0xFF.
; If bit 0 is set, it is shifted left 1, then added to 46, to create an
; index into the string table of either 46 (OFF), or 48 (ON).

.BTN_IS_24_25:
    LDAA    <M_EDIT_KBD_SCALE_TOGGLE
    ANDA    #1
    ASLB
    ABA
    ADDA    #46
    STAA    M_EDIT_PARAM_STR_INDEX
    JMP     .PRINT_EDIT_INFO?

; If the synth is in 'Edit Mode', and buttons 1 to 6 are pressed, the
; selected operator is enabled or disabled.
; This is done by using the currently pressed button as an index into an
; array of bitmasks, which are XOR'd against the contents of the current
; operator enabled register.

.EDIT_BUTTONS_1_TO_6:
    LDAB    M_LAST_PRESSED_BTN
    LDX     #TABLE_OP_NUMBER_BITMASK
    ABX
    LDAB    0,x
    EORB    M_PATCH_CURRENT_OPS_ON_OFF
    STAB    M_PATCH_CURRENT_OPS_ON_OFF

; Falls-through to print patch info, and return.
    BRA     MIDI_SYSEX_SEND_OP_ON_OFF

; ==============================================================================
; Operator Number Bitmask Table.
; Contains bitmasks corresponding to each of the synth's six operators.
; Used when enabling/disabling individual operators.
; ==============================================================================
TABLE_OP_NUMBER_BITMASK:
    FCB %100000
    FCB %10000
    FCB %1000
    FCB %100
    FCB %10
    FCB 1


MIDI_SYSEX_SEND_OP_ON_OFF:
    LDX     #M_PATCH_CURRENT_OPS_ON_OFF
    JSR     MIDI_SYSEX_SEND_PARAM_CHG


.RESET_EDIT_PARAM:
    JSR     UI_PRINT_ALG_INFO
    LDAA    M_EDIT_PARAM_CURRENT
    STAA    M_LAST_PRESSED_BTN
    JMP     UI_EDIT_MODE

.IS_BUTTON_31?:
    CMPA    #BUTTON_31
    BNE     .PRINT_EDIT_INFO?

.PRINT_KEY_TRANSPOSE:
    JSR     UI_PRINT_ALG_INFO
    LDX     #aMiddleC
    JSR     LCD_WRITE_STR_TO_BUFFER_LINE_2
    LDAB    M_PATCH_CURRENT_TRANSPOSE
    CMPB    #48

; If this value is > 48, set to 24.
; This is because the key transpose is an unsigned value, with a range
; of -24 - 24.
    BLS     .PRINT_KEY_TRANSPOSE_VALUE
    LDAB    #24
    STAB    M_PATCH_CURRENT_TRANSPOSE

.PRINT_KEY_TRANSPOSE_VALUE:
    ADDB    #24
    JSR     PRINT_MUSICAL_NOTES

; Send the current value over SYSEX.
    LDX     #M_PATCH_CURRENT_TRANSPOSE
    JSR     MIDI_SYSEX_SEND_PARAM_CHG
    JMP     .END_UI_EDIT_MODE

.PRINT_EDIT_INFO?:
    JSR     UI_PRINT_ALG_INFO
    LDAB    M_EDIT_PARAM_STR_INDEX

; Check that this variable is less-than, or equal to 49.

.IS_VALID_ENTRY?:
    CMPB    #49
    BLS     .PRINT_EDIT_PARAM_INFO
    RTS

; Subtract 6 from the 'Edit Parameter String Index', and use this variable
; as an index into the 'Edit String Pointers Table.
; We subtract 6, on account of buttons 1-7 being handled elsewhere in this
; function.

.PRINT_EDIT_PARAM_INFO:
    SUBB    #6
    ASLB
    CMPB    #44
    BNE     .LOAD_EDIT_STRING
    JMP     .PRINT_OSC_MODE

; Load the string for the currently selected edit parameter, and print to
; the second line of the LCD screen.

.LOAD_EDIT_STRING:
    PSHB
    LDX     #STR_PTRS_EDIT_PARAM
    ABX
    LDX     0,x
    JSR     LCD_WRITE_STR_TO_BUFFER_LINE_2
    PULB
    CMPB    #48
    BCS     .LOAD_EDIT_PARAM_RANGE              ; If B < 48, branch.
    CMPB    #78
    BHI     .LOAD_EDIT_PARAM_RANGE
    LDAA    <M_EDIT_EG_RATE_LVL_SUB_FN
    LDX     <M_COPY_DEST_PTR
    ADDA    #49
    STAA    0,x

.LOAD_EDIT_PARAM_RANGE:
    LDX     #TABLE_EDIT_PARAM_VALUES
    ABX
    LDD     0,x

; Test ACCB to determine which parameter is currently being edited.
; The number in ACCB corresponds to the offset of this parameter within
; patch memory. e.g. Offset 134 = Algorithm.
; Test if this parameter corresponds to a breakpoint.

.IS_PARAM_BREAKPOINT?:
    CMPB    #8
    BEQ     .TEST_BREAKPOINT_VALUE

.IS_PARAM_LEFT_CURVE?:
    CMPB    #11
    BEQ     .TEST_CURVE_VALUE

.IS_PARAM_RIGHT_CURVE?:
    CMPB    #12
    BEQ     .TEST_CURVE_VALUE

.IS_PARAM_OSC_SYNC?:
    CMPB    #136
    BEQ     .PRINT_OSC_SYNC

.IS_PARAM_LFO_SYNC?:
    CMPB    #141
    BEQ     .PRINT_OSC_SYNC

.IS_PARAM_LFO_WAVEFORM:
    CMPB    #142
    BEQ     .TEST_LFO_WAVEFORM_VALUE

; The following section handles printing all other numeric parameters, as
; well as testing them for invalid values.

.PRINT_NUMERIC_PARAM:
    STD     M_EDIT_PARAM_MAX_AND_OFFSET

; Write '=' to LCD Line 2 Buffer + 13, then increment pointer and save.
    LDAA    #'='
    LDX     #$263C
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Test if the parameter being edited is specific to an operator, or a
; global patch parameter by comparing whether its relative offset is
; above 125.
; If it is an operator parameter, a pointer to the currently
; selected operator will be loaded into IX, otherwise the start of
; the patch 'Edit Buffer' will be loaded into IX.

.IS_OPERATOR_PARAM?:
    CMPB    #125
    BHI     .GLOBAL_PARAM

.OPERATOR_PARAM:
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    BRA     .LOAD_NUMERIC_PARAM

.GLOBAL_PARAM:
    LDX     #M_PATCH_CURRENT_BUFFER

; Load the parameter maximum value, and offset into ACCD.
; The maximum value is in ACCA, the offset in ACCB.

.LOAD_NUMERIC_PARAM:
    LDD     M_EDIT_PARAM_MAX_AND_OFFSET
    ABX

; Save registers, send SYSEX message, and restore registers.
    PSHX
    PSHA
    JSR     MIDI_SYSEX_SEND_PARAM_CHG
    PULA
    PULX

; Load the actual parameter data byte, and store the maximum value for this
; parameter. Then compare this value against the maximum parameter. If it
; is higher, then reset the value to the maximum, and store it.
    LDAB    0,x
    STAA    M_EDIT_PARAM_MAX_VALUE

.TEST_NUMERIC_PARAM:
    CMPB    M_EDIT_PARAM_MAX_VALUE
    BLS     .PRINT_NUMERIC_PARAM_VALUE
    LDAB    M_EDIT_PARAM_MAX_VALUE
    STAB    0,x

.PRINT_NUMERIC_PARAM_VALUE:
    CLRA
    JSR     CONVERT_INT_TO_STR
    LDX     <M_COPY_DEST_PTR
    JSR     LCD_WRITE_NUM_TO_STR_BFR
    BRA     .END_UI_EDIT_MODE

; Check that the breakpoint value is within the range 0-99. If not, the
; value is reset to 0, and stored.

.TEST_BREAKPOINT_VALUE:
    JSR     MIDI_SYSEX_SEND_OP_PARAM
    CMPB    #99
    BLS     .PRINT_BREAKPOINT
    CLRB
    STAB    0,x

.PRINT_BREAKPOINT:
    ADDB    #9
    JSR     PRINT_MUSICAL_NOTES
    BRA     .END_UI_EDIT_MODE

; Check that the curve value is within the range 0-3. If not, the
; value is reset to 0, and stored.

.TEST_CURVE_VALUE:
    JSR     MIDI_SYSEX_SEND_OP_PARAM
    CMPB    #3
    BLS     .PRINT_CURVE
    CLRB
    STAB    0,x

.PRINT_CURVE:
    LDX     #TABLE_STR_PTRS_EG_CURVES
    BRA     .PRINT_PARAMETER_NAME

.TEST_LFO_WAVEFORM_VALUE:
    LDX     #M_PATCH_CURRENT_BUFFER
    PSHB
    JSR     MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
    PULB
    ABX
    LDAB    0,x

; Check that the LFO waveform value is within the range 0-99. If not, the
; value is reset to 0, and stored.
    CMPB    #5
    BLS     .PRINT_LFO_WAVEFORM
    CLRB
    STAB    0,x

.PRINT_LFO_WAVEFORM:
    LDX     #TABLE_STR_PTRS_LFO_WAVES
    BRA     .PRINT_PARAMETER_NAME

.PRINT_OSC_SYNC:
    LDX     #M_PATCH_CURRENT_BUFFER
    PSHB
    JSR     MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
    PULB
    ABX
    LDAB    0,x
    ANDB    #1
    STAB    0,x
    ASLB
    LDX     #TABLE_STR_PTRS_OFF_ON
    ABX
    LDX     0,x
    JSR     LCD_WRITE_STR_TO_BUFFER
    BRA     .END_UI_EDIT_MODE

.PRINT_OSC_MODE:
    LDAB    #17
    JSR     MIDI_SYSEX_SEND_OP_PARAM

; Ensure this value is either 0, or 1.
    ANDB    #1
    STAB    0,x
    LDX     #M_LCD_BUFFER_LN_2
    STX     <M_COPY_DEST_PTR
    LDX     #TABLE_STR_PTRS_FREQ_MODE

.PRINT_PARAMETER_NAME:
    ASLB
    ABX
    LDX     0,x
    JSR     LCD_WRITE_STR_TO_BUFFER

.END_UI_EDIT_MODE:
    JMP     LCD_PRINT_STR_BUFFER


; ==============================================================================
; MIDI_SYSEX_SEND_OP_PARAM
; ==============================================================================
; LOCATION: 0xF4C1
;
; DESCRIPTION:
; Gets the address of a particular operator parameter, relative to the
; currently selected operator, loads the value, and then sends this value
; over MIDI.
;
; ARGUMENTS:
; Registers:
; * ACCB: The offset of this operator parameter from the start of the
;         currently selected operator in patch memory.
;
; RETURNS:
; * ACCB: The specified parameter.
;
; ==============================================================================

MIDI_SYSEX_SEND_OP_PARAM:
    PSHB
    JSR     PATCH_GET_PTR_TO_SELECTED_OP
    PULB
    ABX
    CLRB
    JSR     MIDI_SYSEX_SEND_OP_PARAM_RELATIVE
    LDAB    0,x
    RTS


; ==============================================================================
; PRINT_MUSICAL_NOTES
; ==============================================================================
; LOCATION: 0xF4CE
;
; DESCRIPTION:
; Print the selected musical note name to the specified string buffer.
;
; ARGUMENTS:
; Registers:
; * ACCB: The note number to convert to a musical note.
;
; Memory:
; * 0xFB:   The destination string buffer pointer.
;
; ==============================================================================

PRINT_MUSICAL_NOTES:
    CLRA

.FIND_OCTAVE_LOOP:
    SUBB    #12
    BMI     .WRITE_NOTE_NAME                    ; If B < 0, branch.
    INCA
    BRA     .FIND_OCTAVE_LOOP

; Add 12 back to B to make this a positive number % 12.
; This will now be used as an index into the note name array.

.WRITE_NOTE_NAME:
    ADDB    #12
    DECA
    PSHA

; Load the two note name character bytes into D.

.LOAD_NOTE_NAME:
    LDX     #TABLE_NOTE_NAMES
    ASLB
    ABX
    LDD     0,x

; Write these two bytes to the destination string buffer.

.COPY_NOTE_NAME:
    LDX     <M_COPY_DEST_PTR
    STAA    0,x
    STAB    1,x
    PULA
    TSTA
    BMI     .PRINT_NEGATIVE_OCTAVE

; Add ASCII '0' to the octave number to make it a valid ASCII char.
    ADDA    #'0'
    STAA    2,x
    RTS

; Write '-1' to the destination string buffer.

.PRINT_NEGATIVE_OCTAVE:
    LDAA    #'-'
    LDAB    #'1'
    STAA    2,x
    STAB    3,x
    RTS

; ==============================================================================
; String pointers used in the 'Edit Mode' menu, corresponding to the current
; parameter being edited. This is set from the last button pushed.
; ==============================================================================
STR_PTRS_EDIT_PARAM:
    FDB 0
    FDB aFeedback
    FDB aLfoWave
    FDB aLfoSpeed
    FDB aLfoDelay
    FDB aLfoPmDepth
    FDB aLfoAmDepth
    FDB aLfoKeySync
    FDB aPModSens                               ; Index 8.
    FDB aAModSens
    FDB 0
    FDB 0
    FDB 0
    FDB 0
    FDB 0
    FDB 0
    FDB aBreakPoint                             ; Index 16.
    FDB 0
    FDB 0
    FDB aRateScaling
    FDB aOutputLevel
    FDB aKeyVelocity
    FDB 0
    FDB aOscKeySync
    FDB aEgRate                                 ; Index 24.
    FDB aEgRate
    FDB aEgRate
    FDB aEgRate
    FDB aEgLevel
    FDB aEgLevel
    FDB aEgLevel
    FDB aEgLevel
    FDB aPEgRate                                ; Index 32.
    FDB aPEgRate
    FDB aPEgRate
    FDB aPEgRate
    FDB aPEgLevel
    FDB aPEgLevel
    FDB aPEgLevel
    FDB aPEgLevel
    FDB aLScaleDepth                            ; Index 40.
    FDB aRScaleDepth
    FDB aLKeyScale
    FDB aRKeyScale

; ==============================================================================
; Edit Parameter Table.
; This table is referenced by the 'Edit Parameter UI Function'. It holds the
; maximum numeric value, and relative byte offset of each parameter.
; Each entry is two bytes, consisting of 'Max Value Byte':'Relative Offset'.
; The relative offset is either the relative offset from the start of the
; patch edit buffer, in the case of global parameters, or the offset from the
; start of the current operator, for parameters specific to an operator.
; Length: 44?
; ==============================================================================
TABLE_EDIT_PARAM_VALUES:
    FCB 31                                      ; Algorithm.
    FCB 134
    FCB 7                                       ; Feedback.
    FCB 135
    FCB 5                                       ; Waveform.
    FCB 142
    FCB 99                                      ; LFO Speed.
    FCB 137
    FCB 99                                      ; LFO Delay.
    FCB 138
    FCB 99                                      ; LFO Pitch Mod Depth.
    FCB 139
    FCB 99                                      ; LFO Amp Mod Depth.
    FCB 140
    FCB 1                                       ; LFO Sync.
    FCB 141
    FCB 7
    FCB 143
    FCB 3
    FCB 14
    FDB 0
    FCB $1F
    FCB $12
    FCB $63
    FCB $13
    FCB $E
    FCB $14
    FCB 0
    FCB 0
    FCB 0
    FCB 0
    FCB $63
    FCB 8
    FCB 0
    FCB 0
    FCB 0
    FCB 0
    FCB 7
    FCB $D
    FCB $63
    FCB $10
    FCB 7
    FCB $F
    FCB 1
    FCB $11
    FCB 1
    FCB $88
    FCB $63
    FCB 0
    FCB $63
    FCB 1
    FCB $63
    FCB 2
    FCB $63
    FCB 3
    FCB $63
    FCB 4
    FCB $63
    FCB 5
    FCB $63
    FCB 6
    FCB $63
    FCB 7
    FCB $63
    FCB $7E
    FCB $63
    FCB $7F
    FCB $63
    FCB $80
    FCB $63
    FCB $81
    FCB $63
    FCB $82
    FCB $63
    FCB $83
    FCB $63
    FCB $84
    FCB $63
    FCB $85
    FCB $63
    FCB 9
    FCB $63
    FCB $A
    FCB 3
    FCB $B
    FCB 3
    FCB $C

; ==============================================================================
; Note Name Table.
; ==============================================================================
TABLE_NOTE_NAMES:    FCC "C C#D D#E F F#G G#A A#B "

; ==============================================================================
; EG Curve Name Table.
; ==============================================================================
TABLE_STR_PTRS_EG_CURVES:
    FDB aLin
    FDB aExp
    FDB aExp_0
    FDB aLin_0

; ==============================================================================
; LFO Wave Name Table.
; ==============================================================================
TABLE_STR_PTRS_LFO_WAVES:
    FDB aTriangl
    FDB aSawDwn
    FDB aSawUp
    FDB aSquare
    FDB aSine
    FDB aSHold

; ==============================================================================
; On/Off Name Table.
; ==============================================================================
TABLE_STR_PTRS_OFF_ON:
    FDB aOff
    FDB aOn

; ==============================================================================
; Oscillator Frequency Mode Name Table.
; ==============================================================================
TABLE_STR_PTRS_FREQ_MODE:
    FDB aFrequencyRatio
    FDB aFixedFreqHz


; ==============================================================================
; UI_EDIT_PATCH_NAME
; ==============================================================================
; LOCATION: 0xF5DD
;
; DESCRIPTION:
; This subroutine prints the user-interface to the synth's LCD for editing a
; patch's name.
; It first prints the patch algorithm info to the first line, then the patch's
; name to the second line. This will be continuously updated during the name
; edit process, as this subroutine is called as part of the main UI handler,
; which is called as part of handling user input.
;
; ==============================================================================

UI_EDIT_PATCH_NAME:
    JSR     UI_PRINT_ALG_INFO
    LDX     #aName
    JSR     LCD_WRITE_STR_TO_BUFFER_LINE_2
    LDX     <M_COPY_DEST_PTR
    JSR     LCD_PRINT_PATCH_NAME_TO_BUFFER
    JSR     LCD_PRINT_STR_BUFFER
    LDX     #M_PATCH_CURRENT_NAME
    STX     <M_COPY_SRC_PTR
    LDX     #$2655                              ; LCD Buffer Line 2 + 6.
    STX     <M_COPY_DEST_PTR                    ; Falls-through below.


; The following subroutine shifts the LCD cursor 6 'cells' to the right,
; to align it correctly prior to printing the rest of the patch information.

SHIFT_LCD_CURSOR_6_RIGHT:
    LDAB    #6
    PSHB

; Set the LCD cursor to start of line 2.
    LDAA    #LCD_INSTR_SET_CURSOR_TO_LINE_2
    JSR     LCD_WRITE_INSTRUCTION
    LDAA    #LCD_INSTR_SET_BLINK_ON
    JSR     LCD_WRITE_INSTRUCTION
    PULB

.SHIFT_CURSOR_LOOP:
    LDAA    #LCD_INSTR_SHIFT_CURSOR_RIGHT
    PSHB
    JSR     LCD_WRITE_INSTRUCTION
    PULB
    DECB
    BNE     .SHIFT_CURSOR_LOOP
    RTS


; ==============================================================================
; UI_PRINT_SAVE_LOAD_MEM_MSG
; ==============================================================================
; LOCATION: 0xF611
;
; DESCRIPTION:
; Prints the 'LOAD MEMORY, or 'SAVE MEMORY' messages to the synth's LCD.
; This subroutine is called from the main UI subroutine when the synth is in
; the appropriate 'UI Mode'. This is set by the synth's front-panel input when
; it is in 'Function Mode'.
;
; ==============================================================================

UI_PRINT_SAVE_LOAD_MEM_MSG:
    LDAA    M_LAST_PRESSED_BTN
    SUBA    #14

; Check whether the last button was 15 (Load), or button 16 (Save), then
; print the appropriate message to the LCD buffer, and return.

.IS_LOAD_OR_SAVE?:
    BEQ     .PRINT_SAVE_MEM_MSG

.PRINT_LOAD_MEM_MSG:
    LDAB    #1
    LDX     #aLoadMemoryAllO
    BRA     .END_UI_PRINT_SAVE_LOAD_MEM_MSG

.PRINT_SAVE_MEM_MSG:
    CLRB
    LDX     #aSaveMemoryAllO

.END_UI_PRINT_SAVE_LOAD_MEM_MSG:
    JMP     LCD_WRITE_LINE_1_THEN_PRINT


; ==============================================================================
; UI_FUNCTION_MODE
; ==============================================================================
; LOCATION: 0xF626
;
; DESCRIPTION:
; This subroutine prints the user interface for menu items related to buttons
; 1-32, while the synth is in function mode.
;
; ==============================================================================

UI_FUNCTION_MODE:
    JSR     LCD_CLEAR_STR_BUFFER
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR
    LDX     #aFunctionContro
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDAB    M_FN_PARAM_CURRENT
    STAB    M_LAST_PRESSED_BTN
    CMPB    #BUTTON_2
    BNE     .IS_FN_5?
    JMP     .FN_2_MONO_POLY

.IS_FN_5?:
    CMPB    #BUTTON_5
    BNE     .IS_FN_GT_14?
    JMP     .FN_5_PORTAMENTO

.IS_FN_GT_14?:
    CMPB    #14
    BCS     .IS_FN_11?                          ; Branch if B < 14.
    JMP     .PRINT_MOD_SRC_FN_PARAM

.IS_FN_11?:
    CMPB    #10
    BNE     .IS_FN_8?
    JMP     .FN_11_CRT_FORMAT

.IS_FN_8?:
    CMPB    #7
    BNE     .FN_OTHERS_GET_STR
    JMP     .FN_8

; All other function control menu items are printed from this point.
; Get pointer to the parameter's string representation, and print.

.FN_OTHERS_GET_STR:
    ASLB
    LDX     #TABLE_STR_PTRS_FN_PARAM_NAMES
    ABX
    LDX     0,x

.FN_OTHERS:
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDAB    M_FN_PARAM_CURRENT
    BEQ     .PRINT_FN_1_TO_LCD_AND_EXIT

.IS_FN_9?:
    CMPB    #8
    BEQ     .END_2

.IS_FN_10?:
    CMPB    #9
    BEQ     .END_2
    CMPB    #10
    BEQ     .END_2

; Print ASCII '=' to LCD buffer, and increment buffer pointer.

.PRINT_FN_PARAM:
    LDX     <M_COPY_DEST_PTR
    LDAA    #'='
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Load a pointer to the function parameter table into IX.
; This will be used to load the current function parameter value below.
    LDAB    M_LAST_PRESSED_BTN
    ASLB
    LDX     #TABLE_FN_PARAMS
    ABX

.IS_FN_PARAM_0?:
    TSTB
    BEQ     .LOAD_FN_PARAM_VALUE

; Load the pointer to the function parameter into IX.
; The following section checks whether SYSEX data should be sent according
; to which parameter is currently being edited.
    PSHX
    LDX     0,x

.IS_FN_PARAM_13?:
    LSRB
    CMPB    #13
    BEQ     .RESTORE_PARAM_PTR
    DECB
    CMPB    #6
    BEQ     .RESTORE_PARAM_PTR
    JSR     MIDI_SYSEX_SEND_FN_PARAM

.RESTORE_PARAM_PTR:
    PULX

; Load the pointer to the function parameter into IX, and then load the
; value into ACCB.

.LOAD_FN_PARAM_VALUE:
    LDX     0,x
    LDAB    0,x

.IS_LAST_PRESSED_BUTTON_14?:
    LDAA    M_LAST_PRESSED_BTN
    CMPA    #BUTTON_14
    BNE     .IS_LAST_PRESSED_BUTTON_6?

; Print the synth's battery voltage.
; Multiply the analog value read by the sub-CPU by 50, then effectively
; shift 8 bits to the right to get the quantised voltage value.
; Convert the number to its ASCII value, and print to the synth's LCD.

.FN_14_BATTERY_CHECK:
    LDAA    #50
    MUL
    TAB
    CLRA
    JSR     CONVERT_INT_TO_STR
    LDX     <M_COPY_DEST_PTR
    LDAA    M_PARSED_INT_TENS
    ADDA    #'0'
    STAA    0,x
    LDAA    #'.'
    STAA    1,x
    LDAA    M_PARSED_INT_DIGITS
    ADDA    #'0'
    STAA    2,x

.END_2:
    BRA     .END_1

.PRINT_FN_1_TO_LCD_AND_EXIT:
    JMP     LCD_PRINT_STR_BUFFER

.IS_LAST_PRESSED_BUTTON_6?:
    CMPA    #BUTTON_6
    BEQ     .FN_6_GLISSANDO

; Is the last button 'Pitch Bend Range'?

.IS_LAST_PRESSED_BUTTON_3?:
    CMPA    #BUTTON_3
    BNE     .PRINT_BEND_PARAM

; If the 'Pitch Bend Step' parameter is set to a non-zero value, the
; 'Pitch Bend Range' value is automatically considered to be '12' for all of
; the synth's internal processes.

.FN_3_PITCH_BEND_RANGE:
    TST     M_PITCH_BND_STEP
    BEQ     .PRINT_BEND_PARAM
    LDAB    #12

; Clears A, then converts ACCD to its ASCII numeric value, then prints
; the converted parameter to the LCD screen.

.PRINT_BEND_PARAM:
    CLRA
    JSR     CONVERT_INT_TO_STR
    LDX     <M_COPY_DEST_PTR
    JSR     LCD_WRITE_NUM_TO_STR_BFR

.END_1:
    BRA     .END_UI_FUNCTION_MODE

.FN_6_GLISSANDO:
    TBA
    BRA     .IS_PARAM_ENABLED?

; Perform a bitwise AND operation on the param number, then shift right
; to determine the modulation-source this parameter corresponds to. Use
; this as an index into the table of names, then write to the LCD.

.PRINT_MOD_SRC_FN_PARAM:
    ANDB    #%1100
    LSRB
    LDX     #TABLE_STR_PTRS_MOD_SRC_NAMES
    ABX
    LDX     0,x
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDX     <M_COPY_DEST_PTR
    INX
    STX     <M_COPY_DEST_PTR

; Perform a bitwise AND to determine the particular modulation-source
; parameter type that is being edited, use this value to lookup the name
; in the table, then print to the LCD.
    LDAB    M_LAST_PRESSED_BTN
    ANDB    #%11
    ASLB
    LDX     #TABLE_STR_PTRS_MOD_PARAM_NAMES
    ABX
    LDX     0,x
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDX     <M_COPY_DEST_PTR

; Print the '=' sign to the LCD.
    LDAA    #'='
    STAA    0,x
    INX
    STX     <M_COPY_DEST_PTR

; Lookup, then print the parameter value.
    LDX     #TABLE_FUNC_PARAMS_16_32
    LDAB    M_LAST_PRESSED_BTN
    ANDB    #%1111
    ASLB
    ABX
    LSRB
    PSHX
    PSHB
    LDX     0,x

; Test if the current parameter is one of the modulation-source's 'flags'.
; That being the 'Pitch', 'Amplitude', or 'EG Bias' flags associated with
; a modulation source. If not, it is the 'Range' parameter.

.IS_FLAG_PARAM?:
    ANDB    #%11
    PULB
    PSHB
    BEQ     .MOD_SOURCE_RANGE_PARAM

.MOD_SOURCE_FLAG_PARAM:
    LSRB
    ANDB    #%110
    ADDB    #7
    BRA     .SEND_MOD_SOURCE_PARAM_SYSEX

.MOD_SOURCE_RANGE_PARAM:
    LSRB

; Mask the parameter number, so that the individual flags can be read below.
    ANDB    #%110
    ADDB    #6

.SEND_MOD_SOURCE_PARAM_SYSEX:
    JSR     MIDI_SYSEX_SEND_FN_PARAM
    PULB
    PULX
    ANDB    #%11
    BNE     .PRINT_MOD_SRC_FLAG_PARAM
    JMP     .LOAD_FN_PARAM_VALUE

; The following section shifts the value right until bit 0 holds the
; value of the parameter flag currently being edited.

.PRINT_MOD_SRC_FLAG_PARAM:
    LDX     0,x
    LDAA    0,x
    ASLA

.SHIFT_FLAG_PARAMETER_LOOP:
    LSRA
    DECB
    BNE     .SHIFT_FLAG_PARAMETER_LOOP

; Test bit 0 of the parameter value to determine whether it is enabled,
; or disabled. Lookup the corresponding string accordingly, and print.

.IS_PARAM_ENABLED?:
    BITA    #1
    BEQ     .FN_PARAMETER_DISABLED

.FN_PARAMETER_ENABLED:
    LDX     #aOn
    BRA     .WRITE_LCD_AND_EXIT

.FN_PARAMETER_DISABLED:
    LDX     #aOff

.WRITE_LCD_AND_EXIT:
    JSR     LCD_WRITE_STR_TO_BUFFER

.END_UI_FUNCTION_MODE:
    JMP     LCD_PRINT_STR_BUFFER

.FN_8:
    LDAA    M_EDIT_BTN_8_SUB_FN
    BNE     .IS_FN_8_SUB_2?
    LDX     #aMidiCh
    INC     M_MIDI_RX_CH
    JSR     .FN_OTHERS
    DEC     M_MIDI_RX_CH
    RTS

.IS_FN_8_SUB_2?:
    CMPA    #2
    BEQ     .FN_8_SUB_2

.FN_8_SUB_1:
    TST     M_MIDI_SYS_INFO_AVAIL
    BNE     .SYS_INFO_AVAIL
    LDX     #aSysInfoUnavail

.PRINT_SYS_INFO_STR_AND_EXIT:
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.SYS_INFO_AVAIL:
    LDX     #aSysInfoAvail
    BRA     .PRINT_SYS_INFO_STR_AND_EXIT

.FN_8_SUB_2:
    LDX     #aMidiTransmit
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT
aSysInfoAvail:       FCC "SYS INFO AVAIL", 0
aSysInfoUnavail:     FCC "SYS INFO UNAVAIL", 0
aMidiCh:             FCC "MIDI CH", 0

.FN_2_MONO_POLY:
    CLRB
    LDX     #M_MONO_POLY
    JSR     MIDI_SYSEX_SEND_FN_PARAM
    LDAB    M_MONO_POLY
    LDX     #TABLE_STR_PTRS_POLY_MONO
    BRA     .PRINT_LCD_AND_EXIT

.FN_5_PORTAMENTO:
    LDAB    #3
    LDX     #M_PORTA_MODE
    JSR     MIDI_SYSEX_SEND_FN_PARAM
    LDAB    M_MONO_POLY
    ASLB
    LDAA    M_PORTA_MODE
    ABA
    TAB
    LDX     #TABLE_STR_PTRS_SUSTAIN_MODE

.PRINT_LCD_AND_EXIT:
    ASLB
    ABX

; Use the Mono/Poly value as an index into this string table.
    LDX     0,x
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT

.FN_11_CRT_FORMAT:
    LDX     #aCartridgeForm
    JMP     LCD_CLR_WRITE_LINE_2_THEN_PRINT


; ==============================================================================
; Function Parameter Names Table.
; ==============================================================================
TABLE_STR_PTRS_FN_PARAM_NAMES:
    FDB aMasterTuneAdj
    FDB 0
    FDB aPBendRange
    FDB aPBendStep
    FDB 0
    FDB aGlissando
    FDB aPortaTime
    FDB 0
    FDB aEditRecall
    FDB aVoiceInit
    FDB 0

; ==============================================================================
; MIDI Parameter Names Table.
; ==============================================================================
TABLE_STR_PTRS_MIDI_CH:
    FDB aMidiRecvCh
    FDB aMidiTrnsCh
    FDB aBatteryVolt

; ==============================================================================
; Function Parameter Pointers Table.
; ==============================================================================
TABLE_FN_PARAMS:
    FDB M_MASTER_TUNE_LOW
    FDB M_MONO_POLY
    FDB M_PITCH_BND_RANGE
    FDB M_PITCH_BND_STEP
    FDB M_PORTA_MODE
    FDB M_PORTA_GLISS_ENABLED
    FDB M_PORTA_TIME
    FDB M_MIDI_RX_CH
    FDB 0
    FDB 0
    FDB 0
    FDB M_MIDI_RX_CH
    FDB M_MIDI_TX_CH
    FDB M_BATTERY_VOLTAGE

; ==============================================================================
; Modulation Source Names Table.
; Contains names for each of the synth's modulation-sources. This table is
; used in the 'Function Mode' UI.
; ==============================================================================
TABLE_STR_PTRS_MOD_SRC_NAMES:
    FDB aWheel
    FDB aFoot
    FDB aBreath
    FDB aAfter

; ==============================================================================
; Modulation Parameter Names Table.
; Contains names for each of the synth's EG parameters. This table is
; used in the 'Function Mode' UI.
; ==============================================================================
TABLE_STR_PTRS_MOD_PARAM_NAMES:
    FDB aRange
    FDB aPitch
    FDB aAmp
    FDB aEgB

; ==============================================================================
; Function Parameters 16-32 Pointers Table.
; ==============================================================================
TABLE_FUNC_PARAMS_16_32:
    FDB M_MOD_WHEEL_RANGE
    FDB M_MOD_WHEEL_ASSIGN_FLAGS
    FDB M_MOD_WHEEL_ASSIGN_FLAGS
    FDB M_MOD_WHEEL_ASSIGN_FLAGS
    FDB M_FOOT_CTRL_RANGE
    FDB M_FT_CTRL_ASSIGN_FLAGS
    FDB M_FT_CTRL_ASSIGN_FLAGS
    FDB M_FT_CTRL_ASSIGN_FLAGS
    FDB M_BRTH_CTRL_RANGE                       ; Index 8.
    FDB M_BRTH_CTRL_ASSIGN_FLAGS
    FDB M_BRTH_CTRL_ASSIGN_FLAGS
    FDB M_BRTH_CTRL_ASSIGN_FLAGS
    FDB M_AFTERTOUCH_RANGE
    FDB M_AFTERTOUCH_ASSIGN_FLAGS
    FDB M_AFTERTOUCH_ASSIGN_FLAGS
    FDB M_AFTERTOUCH_ASSIGN_FLAGS               ; Index 15.

; ==============================================================================
; Polyphony Names Table.
; Contains names for each of the synth's polyphony modes. This table is
; used in the 'Function Mode' UI.
; ==============================================================================
TABLE_STR_PTRS_POLY_MONO:
    FDB aPolyMode
    FDB aMonoMode

; ==============================================================================
; Sustain Mode Names Table.
; Contains names for each of the synth's sustain modes. This table is used in
; the 'Function Mode' UI.
; ==============================================================================
TABLE_STR_PTRS_SUSTAIN_MODE:
    FDB aSusKeyPRetain
    FDB aSusKeyPFollow
    FDB aFingeredPorta
    FDB aFullTimePorta

; ==============================================================================
; MIDI Parameter Strings.
; ==============================================================================
aMidiOmniOn:         FCC "Midi Omni : ON", 0
aMidiRecvCh:         FCC "Midi Recv Ch", 0
aMidiTrnsCh:         FCC "Midi Trns Ch", 0
aMidiChInfo:         FCC "Midi Ch Info:", 0
aMidiSyInfo:         FCC "Midi Sy Info:", 0


; ==============================================================================
; UI_MEM_PROTECT_STATE
; ==============================================================================
; LOCATION: 0xF894
;
; DESCRIPTION:
; Prints the user-interface messages related to modifying the internal, and
; cartridge memory protection.
;
; ==============================================================================

UI_MEM_PROTECT_STATE:
    JSR     LCD_CLEAR_STR_BUFFER

; Test whether the last button-press corresponded to the button for
; internal, or cartridge memory protection.
    LDAB    M_LAST_PRESSED_BTN
    SUBB    #33
    PSHB
    BNE     .CRT_SELECTED
    LDX     #aMemoryProtectI
    BRA     .WRITE_PROTECT_STATUS_TO_STR_BUFFER

.CRT_SELECTED:
    LDX     #aMemoryProtectC

.WRITE_PROTECT_STATUS_TO_STR_BUFFER:
    PSHX
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR
    PULX
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDAA    <M_MEM_PROTECT_FLAGS
    PULB
    TSTB
    BNE     .IS_CRT_PROTECTED?

.TEST_INT_PROTECT:
    BITA    #MEM_PROTECT_INT
    BEQ     .PRINT_MSG_OFF

.PRINT_MSG_ON:
    LDX     #aOn
    BRA     .PRINT_STATUS_STRING

.IS_CRT_PROTECTED?:
    BITA    #MEM_PROTECT_CRT
    BEQ     .PRINT_MSG_OFF
    BRA     .PRINT_MSG_ON

.PRINT_MSG_OFF:
    LDX     #aOff

.PRINT_STATUS_STRING:
    PSHX

; Print to the end of the second line of the string buffer.
    LDX     (#M_LCD_BUFFER_LN_2+$D)
    STX     <M_COPY_DEST_PTR
    PULX
    JMP     LCD_WRITE_BFR_AND_PRINT


; ==============================================================================
; UI_PRINT_ALG_INFO
; ==============================================================================
; LOCATION: 0xF8D3
;
; DESCRIPTION:
; Prints the algorithm information to line 1 of the LCD screen.
; This prints the 'ALG 111111 OP4' line seen in edit mode.
; Refer to page 28 of the DX7 manual to see an example of this screen printed.
;
; ==============================================================================

UI_PRINT_ALG_INFO:
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_DEST_PTR
    LDX     #aAlg
    JSR     LCD_WRITE_STR_TO_BUFFER
    LDAB    M_PATCH_CURRENT_ALG
    CMPB    #31
    BLS     .PRINT_INFO
    CLRB
    STAB    M_PATCH_CURRENT_ALG

; Increment ACCB to index by 1.

.PRINT_INFO:
    INCB
    CLRA
    JSR     CONVERT_INT_TO_STR
    LDX     <M_COPY_DEST_PTR
    JSR     LCD_WRITE_NUM_TO_STR_BFR
    LDAA    #' '
    STAA    0,x
    STAA    7,x
    LDAB    #6

; Load the status of the operators (ON/OFF).
; These are a bitmask. Shift twice so that OP6 is in the carry bit.
    LDAA    M_PATCH_CURRENT_OPS_ON_OFF
    STAA    M_OP_CURRENT
    ASL     M_OP_CURRENT
    ASL     M_OP_CURRENT

; Loop six times, checking each operator.
; Shift the 'enabled operator mask' register to the left. If the carry bit
; is set as a result of the operation, it indicates that the operator is
; enabled.
; Copy an ASCII '1' to the LCD buffer for ON, '0' for OFF.

.TEST_OPERATOR_ENABLED_LOOP:
    ASL     M_OP_CURRENT
    BCS     .OPERATOR_ENABLED

.OPERATOR_DISABLED:
    LDAA    #'0'

.WRITE_OPERATOR_STATUS:
    STAA    1,x
    INX
    DECB
    BNE     .TEST_OPERATOR_ENABLED_LOOP
    STX     <M_COPY_DEST_PTR
    LDAB    M_LAST_PRESSED_BTN
    CMPB    #15
    BCS     .FILL_WITH_SPACES                   ; If 15 > ACCB, branch.
    CMPB    #27
    BHI     .FILL_WITH_SPACES                   ; If B > 27, branch.
    CMPB    #16
    BNE     .PRINT_SELECTED_OP                  ; If B != 16, branch.
    LDAA    <M_EDIT_OSC_MODE_SYNC_FLAG
    BNE     .FILL_WITH_SPACES

.PRINT_SELECTED_OP:
    LDX     <M_COPY_DEST_PTR

; Print 'OP' string.
    LDD     #'OP'
    STAA    2,x
    STAB    3,x
    PSHX
    LDAB    M_SELECTED_OPERATOR
    STAB    M_OP_CURRENT

; This computes the current operator NUMBER by comparing the operator
; select register to the operator bitmask.

.CALC_ALG_NUM:
    LDAB    #5
    SUBB    M_SELECTED_OPERATOR
    LDX     #TABLE_OP_NUMBER_BITMASK
    ABX
    LDAA    0,x
    ANDA    M_PATCH_CURRENT_OPS_ON_OFF
    BNE     .PRINT_OP_NUMBER
    DEC     M_SELECTED_OPERATOR

; If this register is now < 0.
    BMI     .RESET
    BRA     .IS_CURRENT_OPERATOR?

; If we've reached 0 without a result, reset.

.RESET:
    LDAB    #5
    STAB    M_SELECTED_OPERATOR

.IS_CURRENT_OPERATOR?:
    LDAB    M_SELECTED_OPERATOR
    CMPB    M_OP_CURRENT
    BEQ     .PRINT_OP_NUMBER
    BRA     .CALC_ALG_NUM
; Print the found operator number.

.PRINT_OP_NUMBER:
    PULX
    LDAB    #5
    SUBB    M_SELECTED_OPERATOR
    ADDB    #'1'                                ; Add ASCII '1'.
    STAB    4,x
    BRA     .END_UI_PRINT_ALG_INFO

.FILL_WITH_SPACES:
    LDX     <M_COPY_DEST_PTR
    LDAA    #' '
    STAA    2,x
    STAA    3,x
    STAA    4,x

.END_UI_PRINT_ALG_INFO:
    RTS

.OPERATOR_ENABLED:
    LDAA    #'1'
    BRA     .WRITE_OPERATOR_STATUS


; ==============================================================================
; LCD_PRINT_PATCH_NUMBER
; ==============================================================================
; LOCATION: 0xF97A
;
; DESCRIPTION:
; Prints the currently selected patch number to the LCD buffer.
;
; ARGUMENTS:
; Registers:
; * IX:   The location in the LCD string buffer to print the current patch
;         number to.
;
; ==============================================================================

LCD_PRINT_PATCH_NUMBER:
    PSHX
    CLRA

; Load the current patch number and increment so it counts up from 1.
    LDAB    M_PATCH_CURRENT_NUMBER
    INCB
    JSR     CONVERT_INT_TO_STR
    PULX
    JSR     LCD_WRITE_NUM_TO_STR_BFR
    RTS


; ==============================================================================
; LCD_PRINT_PATCH_NAME_TO_BUFFER
; ==============================================================================
; LOCATION: 0xF988
;
; DESCRIPTION:
; Prints the name of the patch in the synth's 'Edit Buffer' to a specified
; location in the synth's LCD buffer.
;
; ARGUMENTS:
; Registers:
; * IX:   The address of the memory location in the LCD buffer to write the
;         patch name to.
;
; ==============================================================================

LCD_PRINT_PATCH_NAME_TO_BUFFER:
    STX     <M_COPY_DEST_PTR
    LDX     #M_PATCH_CURRENT_NAME
    STX     <M_COPY_SRC_PTR
    LDAB    #10

.PRINT_NAME_LOOP:
    LDX     <M_COPY_SRC_PTR
    PSHB
    PSHX

; Test whether this param chg is echoed to SYSEX.
; If the synth is in any other input mode than 'Play' each character of
; the name will be sent via SYSEX.
    TST     M_INPUT_MODE
    BEQ     .PRINT_NAME_CHAR

; This function call uses the 'IX' register to determine which
; parameter is sent.
    JSR     MIDI_SYSEX_SEND_PARAM_CHG

.PRINT_NAME_CHAR:
    PULX
    PULB
    LDAA    0,x

.INCREMENT_SRC_PTR:
    INX
    STX     <M_COPY_SRC_PTR

.WRITE_NAME_CHAR:
    LDX     <M_COPY_DEST_PTR
    STAA    0,x

.INCREMENT_DEST_PTR:
    INX
    STX     <M_COPY_DEST_PTR
    DECB
    BNE     .PRINT_NAME_LOOP
    RTS


; ==============================================================================
; LCD_WRITE_NUM_TO_STR_BFR
; ==============================================================================
; LOCATION: 0xF9AF
;
; DESCRIPTION:
; Prints a parsed two digit number to the LCD string buffer.
; Prints the digits stored in the same registers that the 'CONVERT_INT_TO_STR'
; subroutine uses to store its results.
;
; ARGUMENTS:
; Memory:
; * 0x217D: The most-significant digit to print.
; * 0x217C: The least-significant digit to print.
;
; ==============================================================================

LCD_WRITE_NUM_TO_STR_BFR:
    LDAA    M_PARSED_INT_TENS

; If the most significant digit of the number is not 0, branch.
    BNE     .MOST_SIGNIFICANT_DIGIT_NON_ZERO

; Print a space to the buffer to take the place of the zero digit.

.MOST_SIGNIFICANT_DIGIT_ZERO:
    LDAA    #$20                                ; ' '
    STAA    0,x
    INX
    BRA     .PRINT_SECOND_DIGIT

; Start counting from ASCII '0', and store.

.MOST_SIGNIFICANT_DIGIT_NON_ZERO:
    ADDA    #$30                                ; '0'
    STAA    0,x
    INX

.PRINT_SECOND_DIGIT:
    LDAA    M_PARSED_INT_DIGITS

; Index the digit from ASCII '0', and store.
    ADDA    #$30                                ; '0'
    STAA    0,x
    INX
    RTS


; ==============================================================================
; String Table.
; This is the synth's main string table.
; ==============================================================================
aInternalVoice:      FCC "INTERNAL VOICE", 0
aCartridgeVoice:     FCC "CARTRIDGE VOICE", 0
aInt:                FCC "INT", 0
aCrt:                FCC "CRT", 0
aAlg:                FCC "ALG", 0
aFeedback:           FCC "FEEDBACK", 0
aLfoWave:            FCC "LFO WAVE=", 0
aLfoSpeed:           FCC "LFO SPEED", 0
aLfoDelay:           FCC "LFO DELAY", 0
aLfoPmDepth:         FCC "LFO PM DEPTH", 0
aLfoAmDepth:         FCC "LFO AM DEPTH", 0
aPModSens:           FCC "P MOD SENS.", 0
aAModSens:           FCC "A MOD SENS.", 0
aLfoKeySync:         FCC "LFO KEY SYNC=", 0
aFCoarse:            FCC "F COARSE=", 0
aFFine:              FCC "F FINE  =", 0
aOscDetune:          FCC "OSC DETUNE =", 0
aEgRate:             FCC "EG  RATE  ", 0
aEgLevel:            FCC "EG  LEVEL ", 0
aBreakPoint:         FCC "BREAK POINT=", 0
aLKeyScale:          FCC "L KEY SCALE=", 0
aRKeyScale:          FCC "R KEY SCALE=", 0
aLScaleDepth:        FCC "L SCALE DEPTH", 0
aRScaleDepth:        FCC "R SCALE DEPTH", 0
aRateScaling:        FCC "RATE SCALING ", 0
aOutputLevel:        FCC "OUTPUT LEVEL", 0
aKeyVelocity:        FCC "KEY VELOCITY ", 0
aPEgRate:            FCC "P EG RATE  ", 0
aPEgLevel:           FCC "P EG LEVEL ", 0
aMiddleC:            FCC "MIDDLE C = ", 0
aFunctionContro:     FCC "FUNCTION CONTROL", 0
aMasterTuneAdj:      FCC "MASTER TUNE ADJ", 0
aPBendRange:         FCC "P BEND RANGE", 0
aPBendStep:          FCC "P BEND STEP", 0
aPortaTime:          FCC "PORTA TIME", 0
aOscKeySync:         FCC "OSC KEY SYNC=", 0
aBatteryVolt:        FCC "BATTERY VOLT", 0
aLoadMemoryAllO:     FCC " LOAD MEMORY     ALL OF MEMORY ?", 0
aSaveMemoryAllO:     FCC " SAVE MEMORY     ALL OF MEMORY ?", 0
aWheel:              FCC "WHEEL ", 0
aFoot:               FCC "FOOT  ", 0
aBreath:             FCC "BREATH", 0
aAfter:              FCC "AFTER ", 0
aRange:              FCC "RANGE", 0
aPitch:              FCC "PITCH", 0
aAmp:                FCC "AMP  ", 0
aEgB:                FCC "EG B.", 0
aMemoryProtectI:     FCC " MEMORY PROTECT  INTERNAL ", 0
aMemoryProtectC:     FCC " MEMORY PROTECT  CARTRIDGE", 0
aAreYouSure:         FCC " ARE YOU SURE ? ", 0
aMemoryProtecte:     FCC "MEMORY PROTECTED", 0
aOn:                 FCC "ON", 0
aOff:                FCC "OFF", 0
aGlissando:          FCC "GLISSANDO", 0
aAlgorithmSelec:     FCC "ALGORITHM SELECT", 0
aToOp:               FCC " to OP", 0
aName:               FCC "NAME= ", 0
aUnderWriting:       FCC " UNDER WRITING !", 0
aMidiDataError:      FCC "MIDI DATA ERROR!", 0
aMidiBufferFull:     FCC "MIDI BUFFER FULL", 0
aChangeBattery:      FCC "CHANGE BATTERY !", 0
aPolyMode:           FCC "POLY MODE", 0
aMonoMode:           FCC "MONO MODE", 0
aEgCopyFromOp:       FCC " EG COPY         from OP", 0
aLin:                FCC "-LIN", 0
aExp:                FCC "-EXP", 0
aExp_0:              FCC "+EXP", 0
aLin_0:              FCC "+LIN", 0
aTriangl:            FCC "TRIANGL", 0
aSawDwn:             FCC "SAW DWN", 0
aSawUp:              FCC "SAW UP", 0
aSquare:             FCC "SQUARE", 0
aSine:               FCC "SINE", 0
aSHold:              FCC "S/HOLD", 0
aFrequencyRatio:     FCC "FREQUENCY(RATIO)", 0
aFixedFreqHz:        FCC "FIXED FREQ.(Hz)", 0
aSusKeyPRetain:      FCC "SUS-KEY P RETAIN", 0
aSusKeyPFollow:      FCC "SUS-KEY P FOLLOW", 0
aFullTimePorta:      FCC "FULL TIME PORTA", 0
aFingeredPorta:      FCC "FINGERED PORTA", 0
aEditRecall:         FCC "EDIT RECALL ?", 0
aVoiceInit:          FCC "VOICE INIT ?", 0
aNotReadyInsert:     FCC "   NOT READY !  INSERT CARTRIDGE", 0
aCartridgeForm:      FCC "CARTRIDGE FORM ?", 0
aMidiTransmit:       FCC " MIDI TRANSMIT ?", 0


; ==============================================================================
; LCD_INIT
; ==============================================================================
; LOCATION: 0xFDEF
;
; DESCRIPTION:
; Initialises the LCD screen driver, and prints the synth's welcome message.
;
; ==============================================================================

LCD_INIT:
    LDAA    #I8255_CONTROL_WORD_13

; Send 'Control Word 13' to the 8255 to set port A, and C to input, and
; port B to output.
    STAA    P_8255_CTRL
    LDAA    #LCD_CTRL_RW
    STAA    P_LCD_CTRL                          ; Set RW bit of LCD.
    JSR     DELAY_450_CYCLES
    LDAA    #LCD_INSTR_FUNC_SET_8BIT_2_LINE
    JSR     LCD_WRITE_INSTRUCTION
    JSR     DELAY_90_CYCLES
    LDAA    #LCD_INSTR_FUNC_SET_8BIT_2_LINE
    JSR     LCD_WRITE_INSTRUCTION
    JSR     DELAY_7_CYCLES
    LDAA    #LCD_INSTR_FUNC_SET_8BIT_2_LINE
    JSR     LCD_WRITE_INSTRUCTION
    LDAA    #LCD_INSTR_FUNC_SET_8BIT_2_LINE
    JSR     LCD_WRITE_INSTRUCTION
    LDAA    #LCD_INSTR_CLEAR
    JSR     LCD_WRITE_INSTRUCTION
    LDAA    #LCD_INSTR_SET_DIR
    JSR     LCD_WRITE_INSTRUCTION
    LDAA    #LCD_INSTR_SET_BLINK_OFF
    JSR     LCD_WRITE_INSTRUCTION
    JSR     LCD_CLEAR_STR_BUFFER
    JSR     LCD_PRINT_STR_BUFFER
    LDX     #MSG_WELCOME
    JMP     LCD_WRITE_LINE_1_THEN_PRINT

MSG_WELCOME:         FCC "*  YAMAHA DX7  **  SYNTHESIZER *", 0


; ==============================================================================
; LCD_PRINT_STR_BUFFER
; ==============================================================================
; LOCATION: 0xFE52
;
; DESCRIPTION:
; Prints the contents of the device's 'string buffer' to the LCD screen.
; This function incrementally copies the contents of the LCD string buffer
; to the 'LCD current contents' buffer, while simultaneously writing each
; character to the LCD screen memory.
;
; ARGUMENTS:
; Memory:
; * 0x261F: The string buffer that will be printed.
;
; MEMORY USED:
; * 0xF9:   The copy source pointer, pointing to the string buffer.
; * 0xFB:   The copy destination pointer, pointing to the LCD contents buffer.
;
; ==============================================================================

LCD_PRINT_STR_BUFFER:
    LDX     #M_LCD_BUFFER_LN_1
    STX     <M_COPY_SRC_PTR

; Load the address of the LCD's content buffer into 0xFB. This buffer
; is used to check whether the current char needs to be written.
    LDX     #M_LCD_BUFFER_CONTENTS
    STX     <M_COPY_DEST_PTR

; Load instruction to set LCD cursor position into B.
; This is incremented with each putchar operation, so that the position
; the command sets the cursor to stays correct.
    LDAB    #LCD_INSTR_SET_CURSOR_POSITION

.PUT_STRING_LOOP:
    PSHB

; Load ACCA from address pointer in 0xF9.
; Increment the pointer in IX, and store again.
    LDX     <M_COPY_SRC_PTR
    LDAA    0,x
    INX
    STX     <M_COPY_SRC_PTR

; If the next char to be printed matches the one in the same position
; in the LCD's current contents, it can be skipped.
    LDX     <M_COPY_DEST_PTR
    CMPA    0,x
    BEQ     .PUT_STRING_LOOP_INCREMENT
    PSHA
    TBA
    JSR     LCD_WRITE_INSTRUCTION               ; Set the cursor location.
    PULA
    PSHA
    JSR     LCD_WRITE_DATA                      ; Write character data.
    PULA
    STAA    0,x

.PUT_STRING_LOOP_INCREMENT:
    PULB

; Increment the buffer end pointer, and store it back at 0xFB.
    INX
    STX     <M_COPY_DEST_PTR

; Increment cursor position in ACCB, exit if we're at the end of the
; 2nd line (0xD0 = 0xC0 + 16).
    INCB
    CMPB    #$D0
    BEQ     PUTSTRING_EXIT

; If we're on the first line, and not at the end, loop.
; Otherwise, set cursor to the start of the 2nd line.
    CMPB    #$90
    BNE     .PUT_STRING_LOOP

; This instruction sets the LCD cursor to start of the second line.
    LDAB    #LCD_INSTR_SET_CURSOR_TO_LINE_2
    BRA     .PUT_STRING_LOOP

PUTSTRING_EXIT:
    RTS


; ==============================================================================
; LCD_WRITE_STR_TO_BUFFER
; ==============================================================================
; LOCATION: 0xFE8B
;
; DESCRIPTION:
; Writes a null-terminated string to the device's LCD string buffer.
;
; ARGUMENTS:
; Registers:
; * IX:   A pointer to the null-terminated string to write to the buffer.
;
; Memory:
; * 0xFB:   A pointer to the memory address for the string to be written to.
;
; ==============================================================================

LCD_WRITE_STR_TO_BUFFER:
    LDAB    0,x                                 ; Load char into ACCB.

; Exit if the loaded byte is non-ASCII (Outside the 0-127 range).
    BMI     .EXIT_NON_ASCII

; Exit if an unprintable character is encountered.
    CMPB    #$20                                ; ' '

; Branch if *(IX) is above 0x20 (ASCII space).
    BCC     .WRITE_CHAR_TO_BUFFER
    RTS

.WRITE_CHAR_TO_BUFFER:
    BSR     LCD_WRITE_CHAR_TO_BUFFER
    INX
    BRA     LCD_WRITE_STR_TO_BUFFER

.EXIT_NON_ASCII:
    RTS


; ==============================================================================
; LCD_WRITE_CHAR_TO_BUFFER
; ==============================================================================
; LOCATION: 0xFE9A
;
; DESCRIPTION:
; This function writes the char located in ACCB to the address in the string
; buffer pointer stored in 0xFB. The buffer pointer is then incremented.
;
; ARGUMENTS:
; Registers:
; * ACCB: The char to write.
;
; Memory:
; * 0xFB:   A pointer to the destination string buffer.
;
; ==============================================================================

LCD_WRITE_CHAR_TO_BUFFER:
    PSHX
    LDX     <M_COPY_DEST_PTR
    STAB    0,x
    INX                                         ; Increment the buffer pointer.
    STX     <M_COPY_DEST_PTR
    PULX
    RTS


; ==============================================================================
; LCD_WRITE_LINE_1_THEN_PRINT
; ==============================================================================
; LOCATION: 0xFEA4
;
; DESCRIPTION:
; Writes the 1nd line string buffer with the null terminated string in IX, then
; prints the string buffer to the LCD.
;
; ARGUMENTS:
; Registers:
; * IX:   The string to print to the 2nd line of the LCD.
;
; ==============================================================================

LCD_WRITE_LINE_1_THEN_PRINT:
    PSHX
    LDX     #M_LCD_BUFFER_LN_1

; Store string buffer to dest register.
    STX     <M_COPY_DEST_PTR
    PULX                                        ; Continues below.


LCD_WRITE_BFR_AND_PRINT:
    BSR     LCD_WRITE_STR_TO_BUFFER
    JMP     LCD_PRINT_STR_BUFFER


; ==============================================================================
; LCD_WRITE_LINE_2_THEN_PRINT
; ==============================================================================
; LOCATION: 0xFEB0
;
; DESCRIPTION:
; Writes the 2nd line string buffer with the null terminated string in IX, then
; prints the string buffer to the LCD.
;
; ARGUMENTS:
; Registers:
; * IX:   The string to print to the 2nd line of the LCD.
;
; ==============================================================================

LCD_WRITE_LINE_2_THEN_PRINT:
    PSHX
    LDX     #M_LCD_BUFFER_LN_2
    STX     <M_COPY_DEST_PTR
    PULX
    BRA     LCD_WRITE_BFR_AND_PRINT


; ==============================================================================
; LCD_CLEAR_STR_BUFFER
; ==============================================================================
; LOCATION: 0xFEB9
;
; DESCRIPTION:
; This clears both lines of the synth's LCD string buffer.
;
; ==============================================================================

LCD_CLEAR_STR_BUFFER:
    LDX     #M_LCD_BUFFER_LN_1

; Load ASCII Space to ACCA.
    LDAA    #' '
    LDAB    #32

.CLEAR_LCD_BUFFER_LOOP:
    STAA    0,x
    INX
    DECB
    BNE     .CLEAR_LCD_BUFFER_LOOP              ; if b > 0, loop.
    RTS


; ==============================================================================
; LCD_WRITE_INSTRUCTION
; ==============================================================================
; LOCATION: 0xFEC7
;
; DESCRIPTION:
; Writes a specified byte to the LCD controller's instruction register,
; then waits for the busy flag to clear.
;
; ARGUMENTS:
; Registers:
; * ACCA: The byte to be written.
;
; ==============================================================================

LCD_WRITE_INSTRUCTION:
    LDAB    #I8255_CONTROL_WORD_5

; Send 'Control Word 5' to the 8255. This sets Port A, and B to outputs.
; This allows the sending of data to the LCD controller.
    STAB    P_8255_CTRL

; Write the LCD instruction.
; RS=Low, RW=Low := Instruction Write.
    CLR     P_LCD_CTRL
    LDAB    #LCD_CTRL_E
    STAB    P_LCD_CTRL
    STAA    P_LCD_DATA

; Disable write, put in read mode.
    CLR     P_LCD_CTRL
    LDAB    #LCD_CTRL_RW
    STAB    P_LCD_CTRL

; Send 'Control Word 13' to the 8255. This sets Port A, and C to inputs.
; This allows the reading of the LCD controller status.
    LDAB    #I8255_CONTROL_WORD_13
    STAB    P_8255_CTRL
    BRA     LCD_WAIT_FOR_READY
    RTS


; ==============================================================================
; LCD_WRITE_DATA
; ==============================================================================
; LOCATION: 0xFEE7
;
; DESCRIPTION:
; Writes the contents of ACCA to the LCD Data register.
; Configures the 8255 peripheral controller, and LCD controller
; to receive data, then writes the data to the LCD screen.
;
; ARGUMENTS:
; Registers:
; * ACCA: The data to write.
;
; ==============================================================================

LCD_WRITE_DATA:
    LDAB    #I8255_CONTROL_WORD_5

; Send 'Control Word 5' to the 8255. This sets Port A, and B to outputs.
; This allows the sending of data to the LCD controller.
    STAB    P_8255_CTRL
    LDAB    #LCD_CTRL_RS
    STAB    P_LCD_CTRL
    LDAB    #LCD_CTRL_E_RS
    STAB    P_LCD_CTRL

; Write the contents of ACCA to the LCD Data register.
    STAA    P_LCD_DATA
    LDAB    #LCD_CTRL_RS
    STAB    P_LCD_CTRL
    LDAB    #LCD_CTRL_RW_RS
    STAB    P_LCD_CTRL

; Send 'Control Word 13' to the 8255. This sets Port A, and C to inputs.
; This allows the reading of the LCD controller status.
    LDAB    #I8255_CONTROL_WORD_13
    STAB    P_8255_CTRL

; Wait until the LCD Busy flag clears.

LCD_WAIT_FOR_READY:
    LDAB    #LCD_CTRL_E_RW
    STAB    P_LCD_CTRL

; PC7 is multiplexed with PA7, allowing reading of the ready flag.
    LDAA    P_CRT_PEDALS_LCD
    LDAB    #LCD_CTRL_RW
    STAB    P_LCD_CTRL
    ANDA    #LCD_BUSY_FLAG

; If Busy flag bit is set in port C, loop.
    BNE     LCD_WAIT_FOR_READY
    RTS


; ==============================================================================
; HANDLER_TRAP
; ==============================================================================
; LOCATION: 0xFF1A
;
; DESCRIPTION:
; This trap handler clears 142 bytes at 0x232E. This will effectively clear
; all of the synth's non-volatile memory items: performance data, received
; MIDI messages, etc.
;
; ==============================================================================

HANDLER_TRAP:
    LDAB    #142
    LDX     #M_MOD_WHEEL_ASSIGN_FLAGS

.CLEAR_BYTES_LOOP:
    CLR     0,x
    INX
    DECB
    BNE     .CLEAR_BYTES_LOOP                   ; If ACCB > 0, loop.
    LDAB    #150
    STAB    M_BATTERY_VOLTAGE
    JMP     HANDLER_RESET

; Empty data section, not directly cross-referenced anywhere else in the code.
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF, $FF, $FF
    FCB $FF, $FF, $FF

; ==============================================================================
; Hardware Vector Table
; Contains the various interupt vectors used by the HD6303 processor.
; ==============================================================================
VECTOR_TRAP:         FDB HANDLER_TRAP
VECTOR_SCI:          FDB HANDLER_SCI
VECTOR_TMR_TOF:      FDB HANDLER_NMI
VECTOR_TMR_OCF:      FDB HANDLER_OCF
VECTOR_TMR_ICF:      FDB HANDLER_NMI
VECTOR_IRQ:          FDB HANDLER_IRQ
VECTOR_SWI:          FDB HANDLER_NMI
VECTOR_NMI:          FDB HANDLER_NMI
VECTOR_RESET:        FDB HANDLER_RESET
; end of 'ROM'


    END
