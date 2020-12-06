:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400

.var hello = "hello"
.var world = "world"
.var space = ' '

.var hello_world = hello + space + world + 2

.pc = * "Main"
main:
  
  :print_ntstring_at(13, 18, ntstring)
  :print_lpstring_at(13, 20, lpstring)
  :debug_print_at(13, 22, "hello world3")
  rts

.pc = * "Data"

ntstring:
  .byte 'h', 'e', 'l', 'l', 'o', ' '
  .text "world1"
  .byte 0

lpstring:
  .byte hello_world.size()
  .text hello_world

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
