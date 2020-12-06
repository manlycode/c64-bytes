:BasicUpstart2(main)

.const SCREEN_MEMORY = $0400

.var hello = "hello"
.var world = "world"
.var space = ' '

.var hello_world = hello + space + world + 2

.printnow hello_world
.print 'x'
.print 53280

.print ""
.print "Integers"
.print toIntString($24)
.print toIntString($d021)
.print toIntString(%10110101)

.print ""
.print "Binary"
.print toBinaryString(220)
.print toBinaryString(35)

.print ""
.print "Hex"
.print toHexString(53280)
.print toHexString(300)

.print ""
.print "Formatting"
.print "Integers"
.print toIntString($24, 6)
.print toIntString($1, 6)
.print "+" + toIntString($12, 5)
.print "------"
.print toIntString($24+$1+$12, 6)

.print ""
.print "Binary"
.print toBinaryString(2,8)
.print toBinaryString(20,8)
.print toBinaryString(220,8)

.print ""
.print "Hex"
.print toHexString(1,4)
.print toHexString(50,4)
.print toHexString(300,4)
.print toHexString(1000,4)


.eval "" + 1 + "X"

.printnow "Program starts at $" + toHexString(main, 4)
.pc = * "Main"
main:

  rts

.pc = * "Data"
