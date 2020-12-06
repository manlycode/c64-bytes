BasicUpstart2(main)

.const SCREEN_MEMORY=$0400

.pc = * "Main"

main:
    rts
    
.pc = * "Data"