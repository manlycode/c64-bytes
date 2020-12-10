# Timing IRQs I - Exercises

#### 1. Delayed events on demand.

a) Stop timer A
b) Set it to a "one off" mode.
c) Set the timer value to a largest possible 16-bit number.
d) Insert an IRQ routine that will simply increment the border color.
e) Add a joystick handling routine that will enable timer whenever the button is pressed.

#### 2. Print Int 8

Take a look at the ```:print_int16``` pseudocommand in the source code of the episode.

It calls a BASIC subroutine that does the actual printing.

Use the same BASIC subroutine to implement ```:print_int8``` pseudocommand that will print decimal value of any 8-bit number passed to it.

Bonus challenge: use the [64spec library](http://64bites/64spec/) to write tests to confirm that it works.
