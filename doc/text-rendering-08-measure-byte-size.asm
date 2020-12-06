:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400

.var hello = "hello"
.var world = "world@"
.var space = ' '

.var hello_world = hello + space + world + 2

.pc = * "Main"
main:
  
s1:
  :print_ntstring_at(13, 18, ntstring)
e1:
.var nt_size = e1 - s1
.print "print_ntstring_at size in bytes: " + nt_size

s2:
  :print_lpstring_at(13, 20, lpstring)
e2:
.var lp_size = e2 - s2
.print "print_lpstring_at size in bytes: " + lp_size

:debug_print_at(13, 22, "hello world@3")

  rts

.pc = * "Data"

ntstring:
  .byte 'h', 'e', 'l', 'l', 'o', ' '
  .text "world@1"
  .byte 0

lpstring:
  .byte hello_world.size()
  .text hello_world

.macro print_ntstring_at(column, row, ntstring) {         //  bytes | cycles (assuming no page boundaries crossed)
  .var screen_offset = screen_at(column, row)             // -----------------
    ldx #0                                                //      2 |      2
  loop:                                                   //        |          
    lda ntstring, X                                       //      3 |      4
    beq end                                               //      2 |      2 (3 on branch taken)
    
    sta screen_offset, X                                  //      3 |      5
    inx                                                   //      1 |      2
    jmp loop                                              //      3 |      3
  end:                                                    // -----------------                            
}                                                         //     14 | 9 + 16*n      n is the length of a string

.macro print_lpstring_at(column, row, lpstring) {          //  bytes | cycles (assuming no page boundaries crossed)
  .var screen_offset = screen_at(column, row)              // -----------------
    ldx lpstring                                           //      3 |      4
    beq end                                                //      2 |      2 (3 on branch taken)
  loop:                                                    // 
    lda lpstring, X                                        //      3 |      4
    sta screen_offset - 1, X                               //      3 |      5                    
    dex                                                    //      1 |      2
    bne loop                                               //      2 |      2 (3 on branch taken)
  end:                                                     //        |       
}                                                          // -----------------                       
                                                           //     14 |  5           when empty string           
                                                           //           3 + 14*n    n is the length of a string           

                                                           // no. chars       - 0,  1,  2,  3,  4, ...,  255
                                                           // ntstring cycles - 9, 25, 41, 57, 73, ..., 4089
                                                           // lpstring cycles - 5, 17, 31, 45, 59, ..., 3573                 

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

.function screen_at(column, row) {
  .return SCREEN_MEMORY + 40*row + column
}
