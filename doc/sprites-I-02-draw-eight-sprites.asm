:BasicUpstart2(main)

.const VIC2 = $d000

.namespace sprites {
  .label positions = VIC2
  .label enable_bits = VIC2 + 21
}
main:
  lda #%11111111
  sta sprites.enable_bits
  .for (var i = 0; i < 8; i++) {
    .var x = 25 + 24*i
    .var y = 51 + 21*i
    lda #x
    sta sprites.positions + 2*i + 0
    lda #y
    sta sprites.positions + 2*i + 1
  }
  rts
