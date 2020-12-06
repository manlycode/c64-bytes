:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400

.const CHROUT = $ffd2

.const CR = 13

.var hello_world = "hello world"
.var hello_world_petscii = "HELLO WORLD"

.pc = * "Main"
main:
  :print_ntstring_at(12, 18, ntstring)
  :print_lpstring_at(12, 20, lpstring)
  :debug_print_at(12, 22, "hello world debug")

  :print_ntstring(ntstring2)
  :print_lpstring(lpstring2)
  :debug_print("HELLO WORLD DEBUG2")
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

ntstring2:
  .text hello_world_petscii
  .text " NT2"
  .byte CR
  .byte 0

lpstring2:
  .byte lpstring2_end - lpstring2 - 1
  .text hello_world_petscii
  .text " LP2"
  .byte CR
lpstring2_end:

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
    ldx #-1
  loop:
    inx
    cpx lpstring
    beq end
    lda lpstring + 1, X
    jsr CHROUT
    jmp loop
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
      .text string
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

