:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400

.var hello = "hello"
.var world = "world"
.var space = ' '

.var hello_world = hello + space + world + 2

.pc = * "Main"
main:

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
  
}

.macro print_lpstring_at(column, row, lpstring) {
  
}


