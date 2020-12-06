BasicUpstart2(main)

.const SCREEN_MEMORY=$0400

.var hello = "hello"
.var world = "world"
.var space = ' '

.var hello_world = hello + space + world + '@' + 2


.pc = * "Main"

main:
    debug_print_at(13,18,"helloworld@3")
    print_lpstring_at(13,19,lpstring)
    rts
    
.pc = * "Data"

ntstring: // null terminated string
    .byte 'h', 'e', 'l', 'l', 'o', ' '
    .text "world1"
    .byte 0

lpstring: //prepend string w/ length
    .byte hello_world.size()
    .text hello_world

.macro print_ntstring_at(column, row, nstring) {
    .var screen_offset = screen_at(column, row)

    ldx #0
loop:
    lda ntstring,x
    beq end
    sta screen_offset,x
    inx
    jmp loop
end:
}

.macro print_lpstring_at(column, row, lpstring) {
    .var screen_offset = screen_at(column, row)
    ldx lpstring
loop:
    lda lpstring,x
    sta screen_offset-1,x
    dex
    bne loop
}

.macro debug_print_at(column, row, string) {
    .var screen_offset = screen_at(column, row)

    jmp end_text
text:
    .text string
end_text:
    ldx #string.size()
    beq end
loop:
    lda text-1,x
    sta screen_offset-1,x
    dex
    bne loop
end:
}

.function screen_at(column, row) {
    .return 40*row + column + SCREEN_MEMORY
}
