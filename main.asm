BasicUpstart2(main)

.const SCREEN_MEMORY=$0400


.pc = * "Main"

main:
    // enable the sprite
    lda #%00001111
    sta sprites.enable_bits

    // left
    lda #24
    sta sprites.positions + 2*1+ 0     // x values are at even locations

    // top
    lda #50
    sta sprites.positions + 1    // y values are odd locations

    lda #4
    sta sprites.colors + 1

    // right
    lda #64
    sta sprites.positions + 2*1+ 0     // x values are at even locations
    lda sprites.x_msb
    ora #%00000010
    sta sprites.x_msb

    lda #50
    sta sprites.positions + 2*1 + 1    // y values are odd locations

    lda #5
    sta sprites.colors + 2


    // left
    lda #24
    sta sprites.positions + 2*2 + 0     // x values are at even locations

    // bottom
    lda #60 + 21 * 8
    sta sprites.positions + 2*2 + 1    // y values are odd locations

    lda #6
    sta sprites.colors + 3

    // right
    lda #64
    sta sprites.positions + 2*3+ 0     // x values are at even locations
    lda sprites.x_msb
    ora #%00000010
    sta sprites.x_msb

    // bottom
    lda #60 + 21 * 8
    sta sprites.positions + 2*3 + 1    // y values are odd locations

    lda #7
    sta sprites.colors + 4



    // .for (var i = 0; i < 8; i++) {
            
    //     .var x = 25 + 24*i
    //     .var y = 51 + 21*i
    //     .var color = 2*i +1

    //     lda #x
    //     sta sprites.positions + 2*i + 0
    //     lda #y
    //     sta sprites.positions + 2*i + 1
    //     lda #color
    //     sta sprites.colors + i
    // }

    rts
    
.pc = * "Data"

.const VIC2 = $d000
.namespace sprites {
    .label WIDTH_std =  24
    .label WIDTH_mc  = 12
    .label HEIGHT = 21

    .label positions = VIC2
    .label enable_bits = VIC2 + 21
    .label colors = VIC2 + 39

    .label x_msb = $d010
}

.define spriteTable {
    .var spriteTable = Hashtable()

    .for(var i=0;i<8;i++) {
        .var currentTable = Hashtable()
        .eval currentTable.put("x", vic.start+2*i)
        .eval currentTable.put("y", vic.start+2*i+1)
        .eval currentTable.put("color", sprites.colors+i)
        .eval spriteTable.put(i, currentTable)
    }        
}

.var keys = spriteTable.keys()
.for (var i=0; i<keys.size(); i++) {
    .var key = keys.get(i)
    .print  key + ":"
    .var innerTable = spriteTable.get(key)
    .var innerKeys = innerTable.keys()
    .for (var j=0; j<innerKeys.size(); j++) {
        .var curKey = innerKeys.get(j)
        .var curValue = innerTable.get(curKey)
    .print "  " + curKey + ": 0x" + toHexString(curValue)
    }
}


.namespace vic {
    .label start = $d000
}

