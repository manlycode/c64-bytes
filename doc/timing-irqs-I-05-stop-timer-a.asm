:BasicUpstart2(main)

.label screen_memory = $0400

.label border_color = $d020
.label background_color = $d021

.label irq_handler_vector = $0314
.label irq_handler_address = $ea31

.const VIC2 = $d000
.const SPRITE_BITMAPS = LoadBinary("ready.bin")
.const SPRITE_BITMAPS_COUNT = SPRITE_BITMAPS.getSize() / 64
.const FIRST_SPRITE_BITMAP_ID = 256 - SPRITE_BITMAPS_COUNT
.namespace sprites {
  .label positions = VIC2
  .label position_x_high_bits = VIC2 + 16
  .label enable_bits = VIC2 + 21
  .label colors = VIC2 + 39
  .label pointers = screen_memory + 1024 - 8
}

.label cia1_base = $dc00

.namespace cia1 {
  .label timer_a = cia1_base + 4
  .label timer_b = cia1_base + 6
  .label interrupt_control_and_status = cia1_base + 13
  .label interrupt_timer_a_control = cia1_base + 14
  .label interrupt_timer_b_control = cia1_base + 15
}

.namespace basic {
  .label print_word = $bdcd
}

.namespace kernal {
  .label chrout = $ffd2
}

main:
  :mov #DARK_GRAY: border_color
  :mov #BLACK: background_color

  :mov #%01111111: sprites.enable_bits
  .for (var i = 0; i < 7; i++) {
    :mov #FIRST_SPRITE_BITMAP_ID + i: sprites.pointers + i
  }
  .const start_x = 140
  .const start_y = 170
  .for (var i = 0; i < 6; i++) {
    :set_sprite_position(i, start_x + 16 * i, start_y)
  }
  :set_sprite_position(6, start_x, start_y + 16)

  sei
  :mov16 #animate_sprites: irq_handler_vector
  cli 

  :print_string("TIMER A STATE ")
  :print_bits cia1.interrupt_timer_a_control

  :mov #%00000000: cia1.interrupt_timer_a_control

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_string("TIMER A STATE ")
  :print_bits cia1.interrupt_timer_a_control


  rts

animate_sprites:
  lda sprites.enable_bits
  eor #01000000
  sta sprites.enable_bits
  jmp irq_handler_address

.pc = 64*FIRST_SPRITE_BITMAP_ID "Sprite bitmaps"
.fill SPRITE_BITMAPS.getSize(), SPRITE_BITMAPS.get(i)

.pseudocommand mov16 source: destination {
  :_mov bits_to_bytes(16): source: destination
}

.pseudocommand mov source: destination {
  :_mov bits_to_bytes(8): source: destination
}

.pseudocommand _mov bytes_count: source: destination {
  .for (var i = 0; i < bytes_count.getValue(); i++) {
    lda extract_byte_argument(source, i) 
    sta extract_byte_argument(destination, i) 
  } 
}

.macro set_sprite_position(index, position_x, position_y) {
  lda #position_x
  sta sprites.positions + index*2 + 0
  lda #position_y
  sta sprites.positions + index*2 + 1
  lda sprites.position_x_high_bits
  .if (position_x > 255) {
    ora #1 << index
  } else {
    and #255 - 1 << index
  }
  sta sprites.position_x_high_bits
}

.pseudocommand print_char char {
  lda char
  jsr kernal.chrout
}

.pseudocommand print_bits byte {
  .for (var i = 7; i >= 0; i--) {
    .var current_bit = 1 << i
    lda byte
    and #current_bit
    beq zero
  one:
    :print_char #'1'
    jmp end
  zero:
      :print_char #'0'
  end:
  }
}
.pseudocommand print_int16 value {
  ldx extract_byte_argument(value, 0)
  lda extract_byte_argument(value, 1)
  jsr basic.print_word
}

.macro print_string(string) {
  .if (string.size() > 0) {
      jmp end_text
    text:
      .fill string.size(), string.charAt(string.size() - 1 - i)
    end_text:

      ldx #string.size() 
    loop:
      lda text - 1, X
      jsr kernal.chrout
      dex
      bne loop
  }
}

.function extract_byte_argument(arg, byte_id) {
  .if (arg.getType()==AT_IMMEDIATE) {
    .return CmdArgument(arg.getType(), extract_byte(arg.getValue(), byte_id))
  } else {
    .return CmdArgument(arg.getType(), arg.getValue() + byte_id)
  }
}

.function extract_byte(value, byte_id) {
  .var bits = _bytes_to_bits(byte_id)
  .eval value = value >> bits
  .return value & $ff
}

.function _bytes_to_bits(bytes) {
  .return bytes * 8
}

.function bits_to_bytes(bits) {
  .return bits / 8
}


