# Text Rendering I - Exercises

#### 1. print_ntstring_at subroutine

The print_ntstring_at macro has been used to create a subroutine at the label print_ntstring_sub. Print ntstring at column 10 and row 5 by modifying code before calling jsr print_ntstring_sub.

``` asm
:BasicUpstart2(main)

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
  :print_ntstring_at(0, 0, $ffff)
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
```

#### 2. print_lpstring_at subroutine

The print_lpstring_at macro has been used to create a subroutine at the label print_lpstring_sub. Print ntstring at column 10 and row 5 by modifying code before calling jsr print_lpstring_sub.


``` asm
:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400


.pc = * "Main"
main:
  
  // TODO: print ntstring at column 10 and row 5 by modifying code before calling jsr
  jsr print_lpstring_sub

  rts

.pc = * "Data"

lpstring:
  .var string = "hello from subroutine"
  .byte string.size()
  .text string
  .byte 0

.pc = * "Subroutines"
print_lpstring_sub:
  :print_lpstring_at(0, 0, $ffff)
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
```
