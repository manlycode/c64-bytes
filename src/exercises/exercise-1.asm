BasicUpstart2(main)

.const SCREEN_MEMORY = $0400


.pc = * "Main"
main:
  
  // TODO: print ntstring at column 10 and row 5 by modifying code before calling jsr
  jsr print_nt_string_sub

  rts

.pc = * "Data"

ntstring:
  .text "hello from subroutine"
  .byte 0

.pc = * "Subroutines"
print_nt_string_sub:
  print_ntstring_at(10, 5, ntstring)
  rts

.macro print_ntstring_at(column, row, ntstring) {
  .var screen_offset = screen_at(column, row)
    ldx #0
  loop: 
    lda ntstring, X
    beq end
    
    sta screen_offset, X
    inx
    jmp loop
  end:
}

.function screen_at(column, row) {
    .return 40*row + column + SCREEN_MEMORY
}
