:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400


.pc = * "Main"
main:
  
  // TODO: print ntstring at column 10 and row 5 by modifying code before calling jsr
  jsr print_lpstring_sub

  rts

.pc = * "Data"

lpstring:
  .var string = "hello from subroutine2"
  .byte string.size()
  .text string
  .byte 0

.pc = * "Subroutines"
print_lpstring_sub:
  :print_lpstring_at(10, 5, lpstring)
  rts

.macro print_lpstring_at(column, row, lpstring) {
  .var screen_offset = screen_at(column, row)
    ldx lpstring 
    beq end
  loop:
    lda lpstring, X
    sta screen_offset - 1, X
    dex
    bne loop
  end:
} 
.function screen_at(column, row) {
    .return 40*row + column + SCREEN_MEMORY
}