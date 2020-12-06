# Text Rendering I - Exercises

#### 1. print_ntstring subroutine

The print_ntstring macro has been used to create a subroutine at the label print_ntstring_sub. Print ntstring by modifying code before calling jsr print_ntstring_sub.

``` asm
:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400


.pc = * "Main"
main:
  
  // TODO: print ntstring by modifying code before calling jsr
  jsr print_nt_string_sub

  rts

.pc = * "Data"

ntstring:
  .text "hello from subroutine"
  .byte 0

.pc = * "Subroutines"
print_nt_string_sub:
  :print_ntstring($ffff)
  rts

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
```

#### 2. print_lpstring subroutine

The print_lpstring macro has been used to create a subroutine at the label print_lpstring_sub. Print lpstring by modifying code before calling jsr print_lpstring_sub.


``` asm
:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400


.pc = * "Main"
main:
  
  // TODO: print lpstring by modifying code before calling jsr
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
  :print_lpstring($ffff)
  rts

.macro print_lpstring(lpstring) {
    ldx #255
  loop:
    inx
    cpx lpstring
    beq end
    lda lpstring + 1, X
    jsr CHROUT
    jmp loop
  end:
} 
```
