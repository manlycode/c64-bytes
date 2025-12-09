:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400
.const CHROUT = $ffd2   // address of CHROUT kernal call
.const PLOT = $fff0
.const CR=13


.var hello_world = "hello world"
.var hello_world_petscii = "HELLO WORLD"

.pc = * "Main"
main:
  lda #'1'
  jsr CHROUT
  lda #'2'
  jsr CHROUT

  lda #'A'
  jsr CHROUT
  lda #'B'
  jsr CHROUT
  lda #'!'
  jsr CHROUT
  lda #CR
  jsr CHROUT

  :set_cursor_position #10:#3
  print_ntstring(ntstring2)

  :set_cursor_position #11:#5
  print_lpstring(lpstring)

  :set_cursor_position #12:#5
  debug_print("HELLO WORLD DBG")
  rts
.pc = * "Data"

ntstring:
    .text hello_world
    .text " NT"
    .byte 0

ntstring2:
  .text hello_world_petscii
  .text " NT2"
  .byte CR
  .byte 0

lpstring:
    .byte hello_world_petscii.size() + 3
    .text hello_world_petscii
    .text "lp"


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

.macro print_ntstring(ntstring) {
    ldx #0
  loop: 
    lda ntstring, X
    beq end
    
    jsr CHROUT
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

.macro print_lpstring(lpstring) {
    ldx lpstring 
    beq end
  loop:
    lda lpstring, X
    jsr CHROUT
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

  .macro debug_print(string) {
  .if (string.size() > 0) {
      jmp end_text
    text:
       .fill string.size(), string.charAt(string.size()-i-1) // reverse the string in memory

    end_text:

      ldx #string.size() 
    loop:
      lda text - 1, X
      jsr CHROUT
      dex
      bne loop
  }
}

.function screen_at(column, row) {
  .return SCREEN_MEMORY + 40*row + column
}

.pseudocommand set_cursor_position row:col {
  clc
  ldx row
  ldy col
  jsr PLOT
}
