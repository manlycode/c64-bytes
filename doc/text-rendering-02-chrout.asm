:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400

.const CHROUT = $ffd2

.const CR = 13

.var hello_world = "hello world"

.pc = * "Main"
main:
  :print_ntstring_at(12, 18, ntstring)
  :print_lpstring_at(12, 20, lpstring)
  :debug_print_at(12, 22, "hello world debug")

  lda #'1'
  jsr CHROUT
  lda #'2'
  jsr CHROUT
  lda #'3'
  jsr CHROUT
  lda #'!'
  jsr CHROUT
  lda #'A'
  jsr CHROUT
  lda #CR
  jsr CHROUT
  lda #'B'
  jsr CHROUT

  rts

.pc = * "Data"

ntstring:
  .text hello_world
  .text " nt"
  .byte 0

lpstring:
  .byte hello_world.size() + 3
  .text hello_world
  .text " lp"

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

.macro debug_print_at(column, row, string) {
  .var screen_offset = screen_at(column, row)
  .if (string.size() > 0) {
      jmp end_text
    text:
      .text string
    end_text:

      ldx #string.size() 
    loop:
      lda text - 1, X
      sta screen_offset - 1, X
      dex
      bne loop
  }
}

.function screen_at(column, row) {
  .return SCREEN_MEMORY + 40*row + column
}

