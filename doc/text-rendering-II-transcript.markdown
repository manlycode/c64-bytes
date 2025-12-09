# Text Rendering II - KERNAL

In the previous episode, we've learned how to print strings of characters directly to the screen memory at the specified column and row. Today we will learn how to print strings at the current cursor position, just like the print command does it in BASIC.

We could probably do it by hand by storing current cursor position in the memory and update it with each print command, but that sounds boring. Let's make the operating system do it for us.

Both the BASIC interpreter and the KERNAL operating system are nothing more than a set of assembly routines sitting in the ROM. If we know where they are and how to call them, we can use any of those routines in our programs. KERNAL, in particular, was designed to be reused and has a pretty well-defined API with routines for general input and output. The API consists of a jump table near the end of the memory, each entry in the table is an indirect jump into the KERNAL routine. To call one of them we just need to execute a jsr command with the corresponding address of the indirect jump instruction. Some of the routines require passing arguments in some specific way, for example by loading them into registers and either setting or clearing particular flags.

Today we will see how to use two of them:
 - the CHROUT routine for printing characters
 - the PLOT routine for setting and retrieving the cursor position.

Let's begin with printing. The CHROUT jump table entry stays at the hexadecimal address $ffd2 and requires the code of the character to be passed through the accumulator.

``` asm
.const CHROUT = $ffd2
```

So to run it we just need to load a character into the A register and jump into the CHROUT subroutine.
``` asm
  lda #'1'
  jsr CHROUT
  lda #'2'
  jsr CHROUT
  lda #'3'
  jsr CHROUT
  lda #'!'
  jsr CHROUT
```

We can see that it prints the character at the current cursor position and advances the cursor after printing.

Nothing complicated. There is one caveat, though. It requires passed characters to be in so-called PETSCII encoding. The characters we passed earlier work because their indexes in PETSCII are the same as their screencodes. Either by coincidence or by design, screencodes for uppercase letters work for PETSCII letters as well so we'll use them instead.

``` asm
  lda #'A'
  jsr CHROUT
  lda #'B'
  jsr CHROUT
```

This encoding defines few special non-printable characters that control how the text is displayed. One of them is the "caret return" code that advances the cursor to the beginning of the next line.

``` asm
.const CR = 13
```

``` asm
  lda #CR
  jsr CHROUT
  lda #'B'
  jsr CHROUT
```

We will talk more about the PETSCII encoding in the next episode but for now, let's see how to use the CHROUT routine to print strings.

First we'll prepare the hello world string variable in the new encoding.

``` asm
.var hello_world_petscii = "HELLO WORLD"
```

Next, we'll use it to define a null-terminated string. As we want to print each string on a separate line, the last character will be the "caret return".

ntstring2:
  .text hello_world_petscii
  .text " NT2"
  .byte CR
  .byte 0

Now, let's define the print_ntstring macro. As we expect it to print the string at the current cursor position the only argument it needs is an ntstring.

 ``` asm
 .macro print_ntstring(ntstring) {

}
 ```

To make it work, we just need to copy the contents of the print_ntstring_at macro. Remove the unneccessary screen_offset computation, and replace the direct write to the screen memory with the jsr into the CHROUT subroutine.

``` asm
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

When we call it, it just works. 

``` asm
  :print_ntstring(ntstring2)
```
 
In a similar way, we'll call the lpstring version.

``` asm
  :print_lpstring(lpstring2)
```

Let's just copy and modify the existing macro in the same way as we did with the one before.

``` asm
.macro print_lpstring(lpstring) {
    ldx lpstring 
    beq end
  loop:
    lda lpstring, X
    jsr CHROUT
    dex
    bne loop
  end:
} 
```

Finally, let's define an lpstring2 variable. 

``` asm
lpstring2:
  .byte hello_world_petscii.size() + 3 + 1
  .text hello_world_petscii
  .text " LP2"
  .byte CR
```

With many .byte and .text directives, calculating the lenght can get complicated and error-prone, so let's make the compiler calculate it for us.

``` asm
lpstring2:
  .byte lpstring2_end - lpstring2 - 1
  .text hello_world_petscii
  .text " LP2"
  .byte CR
lpstring2_end:
```

When we run it, we can see that the string is on the screen but it's printed in the reverse order.

We can fix it by reversing the order of the loop. We'll start by loading the X register with 0.
 
``` asm
    ldx #0
```

Then we'll increment the X at the end of the loop and compare it with the string length.

``` asm
    inx
    cpx lpstring
```

Finally, we need to add 1 to the lpstring variable to get the proper start of the string.

``` asm
    lda lpstring + 1, X
```

It works, but we can make it shorter and faster.

Let's see what happens when we load the x with -1 at the start. 

``` asm
    ldx #-1
```

To keep the old behavior, we need to increment the x register at the beginning of each loop.

``` asm
    inx
```

Let's compare it here as well but reverse the branching condition, so we can exit the loop as soon as the lenght of the string is reached.

``` asm
    cpx lpstring
    beq end
```

Finally, at the end of each iteration we need the unconditional jump to the loop label.

``` asm
  jmp loop
```

With those changes in place, the check for an empty string at the beginning is not neccessary anymore. The early exit from the loop will work even if the length of the string is 0.

The last, and possibly the most useful macro to create is the debug_print one.

``` asm
.macro debug_print(string) {

}
```

Again, we can easily adapt the code from the debug_print_at macro.

``` asm
  .if (string.size() > 0) {
      jmp end_text
    text:
      .text string
    end_text:

      ldx #string.size() 
    loop:
      lda text - 1, X
      jsr CHROUT
      dex
      bne loop
  }

```

Similarly to the initial version of the print_lpstring macro, this one will print the string in the reverse order.

But in this case, instead of changing the code, we can simply reverse the string in the memory at the compilation time.

``` asm
  .fill string.size(), string.charAt(string.size() - 1 - i)
```

We can now write strings on the screen at the current cursor position. But, what if we want to change it.

We can use another KERNAL routine to do it for us. It is called PLOT, and it's entry in the jump table starts at the hexadecimal address $fff0.

``` asm
.const PLOT = $fff0
```

It is a bit more complicated to set up than the CHROUT routine so let's wrap it in an easy to use pseudo command.

We'll call it set_cursor_position and it will require two arguments - a column and a row.

``` asm
.pseudocommand set_cursor_position column; row {

  jsr PLOT
}
```

Before jumping into the PLOT subroutine, we need to clear the carry flag to signify that we want to change the cursor position.

``` asm
  clc
```

We also need to load the row index into the x, and the column index into the y register.

``` asm
  ldx row
  ldy column
```

If we call the pseudocommand before calling each of our print macros, they will be printed at the specified cursor position.

``` asm
  :set_cursor_position #12; #19 
  :print_ntstring(ntstring2)
  :set_cursor_position #12; #21 
  :print_lpstring(lpstring2)
  :set_cursor_position #12; #23 
  :debug_print("HELLO WORLD DEBUG2")
```

But we can see that when the program ends the cursor position stays modified by our last print command. It would be cool to restore it to a state at the beginning of our program.

To do that we need to create a get_cursor_position pseudo command.

``` asm
.pseudocommand get_cursor_position column; row  {
}
```

It will also jump to the PLOT subroutine.

``` asm
  jsr PLOT
```

But we need to set the carry flag before the jump to signify that we want to retrieve the cursor position.

``` asm
  sec
```

With that in place the PLOT subroutine will leave the row and the column index in the X and the Y register. At that point we just need to store them.

``` asm
  stx row
  sty column
```

Let's also add two variables to our program to store the column and the row.

``` asm
column:
  .byte 0
row:
  .byte 0
```

Finally, if we call the get_cursor_position with these variables at the beggining of our program, we can restore the cursor position at the end of it.

As we can see, calling KERNAL routines is pretty easy, and it can save us a lot of programming effort. However, printing characters with the CHROUT routine is slower than writing them directly into the screen memory. The real advantage lies in using the PETSCII encoding. We can use it to change easily the color, character set, or cursor position with printing one of the special characters. 

``` asm
ntstring2:
  .byte 14
  .byte 28
  .text hello_world_petscii
  .byte 30
  .text " NT2"
  .byte CR
  .byte 0

lpstring2:
  .byte hello_world_petscii.size() + 4 + 5
  .byte 5
  .text hello_world_petscii
  .byte 144
  .byte 145
  .text " LP2"
  .byte 158
  .byte CR
```

But that is something we'll explore in the next episode.

See you soon!
