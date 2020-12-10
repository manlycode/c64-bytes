:BasicUpstart2(main)

.const VIC2 = $d000

.namespace sprites {
  .label positions = VIC2
  .label position_x_high_bits = VIC2 + 16
  .label enable_bits = VIC2 + 21
  .label colors = VIC2 + 39
}
main:
  lda #%11111111
  sta sprites.enable_bits
  .for (var i = 0; i < 8; i++) {
    .var x = 25 + 24*i
    .var y = 51 + 21*i
    .var color = 2*i + 1
    lda #x
    sta sprites.positions + 2*i + 0
    lda #y
    sta sprites.positions + 2*i + 1
    lda #color
    sta sprites.colors + i
  }
  // left
  lda #25
  sta sprites.positions + 2*0 + 0
  sta sprites.positions + 2*1 + 0

  // right
  lda #%00001100
  sta sprites.position_x_high_bits
  lda #344 - 25 - 256
  sta sprites.positions + 2*2 + 0
  sta sprites.positions + 2*3 + 0

  // top
  lda #51
  sta sprites.positions + 2*0 + 1
  sta sprites.positions + 2*3 + 1
   
  // left
  lda #228
  sta sprites.positions + 2*1 + 1
  sta sprites.positions + 2*2 + 1

  rts
