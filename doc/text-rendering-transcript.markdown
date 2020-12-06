# Text Rendering

One of the things we need the most in programming is the ability to print a string of characters on the screen. Either to give a user a message or to debug something without the need to jump into the monitor.

In the KickAssembler's scripting language we can assign strings to compilation-time variables by assigning to them string literals defined within double quotes.

``` asm
.var hello = "hello"
.var world = "world"
```

If we don't want a string but a single character we need to use a single-quoted literal.

``` asm
.var space = ' '
```

We can create new strings by concatenating existing ones. We can also add characters or numbers to them, and they will be converted to strings automatically.

``` asm
.var hello_world = hello + space + world + 2
```

Strings, as well as the other values, can be printed at the compilation time using the .print directive.

``` asm
.print hello_world
.print 'x'
.print 53280
```

When it comes to numbers, we can use conversion functions to print them using the most convenient representation.

Like integers,

``` asm
.print ""
.print "Integers"
.print toIntString($24)
.print toIntString($d021)
.print toIntString(%10110101)
```

binary,

``` asm
.print ""
.print "Binary"
.print toBinaryString(220)
.print toBinaryString(35)
```

or hexadecimal numbers.

``` asm
.print ""
.print "Hex"
.print toHexString(53280)
.print toHexString(300)
``` 

Within those functions, we can specify padding as a second argument to put integers in columns prepended by spaces.

``` asm
.print ""
.print "Formatting"
.print "Integers"
.print toIntString($24, 6)
.print toIntString($1, 6)
.print "+" + toIntString($12, 5)
.print "------"
.print toIntString($24+$1+$12, 6)
```

In a similar way, we can prefix either binary 

``` asm
.print ""
.print "Binary"
.print toBinaryString(2,8)
.print toBinaryString(20,8)
.print toBinaryString(220,8)
```

or hexadecimal numbers with zeros.

``` asm
.print ""
.print "Hex"
.print toHexString(1,4)
.print toHexString(50,4)
.print toHexString(300,4)
.print toHexString(1000,4)
```

The print directive can be used to find out the value of a variable or a label. 

``` asm
.print "Program starts at $" + toHexString(main, 4)
```

But one thing to keep in mind is that the printing process happens at the very end of compilation. The KickAssembler is a multi-pass compiler and if the error happens at one of the early stages of the compilation the .print directive won't have a chance to print anything.

``` asm
.eval 1 + "X"
```

In such cases, we can use the .printnow directive. It doesn't wait until the end of the compilation, but it tries to print the string during each pass instead.
  
``` asm
.printnow hello_world
```
It means that depending on what we print, it may fail at early stages if the compiler hasn't had a chance to calculate the value yet.

But what about the runtime?

First, we need to figure out a way to store strings in the memory.
We can either use a .byte directive and list consecutive characters or a .text directive and pass a string to it.

``` asm
ntstring:
  .byte 'h', 'e', 'l', 'l', 'o', ' '
  .text "world"
```

Our printing routine is going to process characters one by one so it needs to know when to stop. And there are two ways to do that, each has its pros and cons. We will explore both of them.

First one marks the end of the string with special null character. Usually, 0 is assumed as it makes the computation easier, but you could choose a different one.

``` asm
  .byte 0
```

The second representation prepends the string with its length. We will assume that 256 characters are enough for everyone so one byte will do.

``` asm
lpstring:
  .byte hello_world.size()
  .text hello_world
```

Let's make two macros. Both will print a string starting at a specific column and a row. But the first macro will deal with null-terminated strings, while length-prepended strings will be handled by the second one.

``` asm
.macro print_ntstring_at(column, row, ntstring) {
  
}

.macro print_lpstring_at(column, row, lpstring) {
  
}
```
First let's create a helper function that will calculate the screen memory offset from a column and a row.

``` asm
.function screen_at(column, row) {
  .return SCREEN_MEMORY + 40*row + column
}
```
We'll need the screen_offset in both macros so let's just put it in both of them.

Let's begin with printing null-terminated strings.

``` asm
  .var screen_offset = screen_at(column, row)
```

We will iterate over each character in a string.

``` asm
    ldx #0
  loop: 
    lda ntstring, X
```

If the character is null, we will end the loop.

``` asm
    beq end

  end:
```

Otherwise, we'll just print the character at the screen_offset, increment the X and jump back to the loop label.

``` asm
    sta screen_offset, X
    inx
    jmp loop
```

Here we can see the reason why zero is usually used as a null character. It allows us to use the beq instruction without unnecessary comparison.

Now, when we call the macro, we can see that it prints the string correctly.

``` asm
  :print_ntstring_at(13, 18, ntstring)
```

The second macro will start with initializing the X register with the length of the string.

``` asm
    ldx lpstring
```

If the string is empty we simply end the routine.

``` asm
  beq end:

end:
```

Otherwise we will iterate backwards over each character.

``` asm
  loop:

    dex
    bne loop
```

The loop goes from the length of the string to 1. And since our strings are prepended by exactly one byte we don't need to modify the base address at all. 

``` asm
    lda lpstring, X
```

The screen_offset however, needs to accommodate.

``` asm
    sta screen_offset - 1, X
```

We can confirm that the macro works by simply printing it on the screen.

``` asm
  :print_lpstring_at(13, 20, lpstring)
```

Both of those macros deal with strings that already exist in the memory. But it would be handy to have debug_print_at macro that will simply print the string in place.

``` asm
  :debug_print_at(13, 22, "hello world3")
```

Let's see how to do that.

``` asm
.macro debug_print_at(column, row, string) {

}
```

First we'll calculate the screen_offset as usual.

``` asm
  .var screen_offset = screen_at(column, row)
```

Then we need to store the string in the memory. Since this is a debug macro, let's just put the string inline with the code. Notice that we know the string's length at the time we call the macro so we neither need to store it along with the string nor use a null character to terminate it.  

``` asm
  text:
    .text string
```

The string is now inserted in the middle of the code, so we need to jump over it.

``` asm
    jmp end_text
  text:
    .text string
  end_text:
```

Now, let's just copy the code for the length-prepended string macro and modify it in two places.

``` asm
    ldx lpstring 
    beq end
  loop:
    lda lpstring, X
    sta screen_offset - 1, X
    dex
    bne loop
  end:
```

The length can be taken directly from the string variable.

``` asm
    ldx #string.size()
```

And we just need to pick the correct character from our text array.

``` asm
    lda text - 1, X
```

In this case we can simplify the code even further. The string is inserted in place so we can skip the whole code generation if the string is empty.

Running the program confirms that it works, and we managed to print each string regardless of internal representation.

Before wrapping up the episode, let's try to insert the at-sign in each of our strings.

If we run the program, we can see that the first string has been truncated.

It happened because all our printing routines use screencodes to encode characters. This is unfortunate for the null-terminated string representation because the screencode of the at-sign is zero. We could eliminate that problem by choosing a different terminator, redefining a character set, or using a different encoding. But whatever we do, we always need to sacrifice one character.


The print_ntstring_at macro is the same size but is slightly less efficient than the lp counterpart.

``` asm
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
```


All of that seems to imply that the length-prepended string representation is simply better. This is most likely to be true in a majority of situations. In the next episode, though, we will try to print our strings in a different way, and we will see if we can find cases more suitable for the null-terminated string representation.

See you soon!
