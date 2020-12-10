:BasicUpstart2(main)

.const VIC2 = $d000

.namespace sprites {
  .label positions = VIC2
  .label enable_bits = VIC2 + 21
}

main:
  lda #%00000001
  sta sprites.enable_bits
  .var x = 25
  .var y = 51
  lda #x
  sta sprites.positions + 0
  lda #y
  sta sprites.positions + 1
  rts
