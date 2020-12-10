# Timing IRQs I

We already know that the cursor blinking on Commodore 64 is done within a default interrupt handling routine.
When we turn the computer on the maskable interrupt signal or IRQ is being sent around sixty times per second by one of an internal timers.

Today we will learn how this process actually works.

Let's start with a program that displays seven sprites.

``` asm
  :mov #%01111111; sprites.enable_bits
```

And set's their pointers to bitmaps, loaded from a file.

``` asm
  .for (var i = 0; i < 7; i++) {
    :mov #FIRST_SPRITE_BITMAP_ID + i; sprites.pointers + i
  }
```

``` asm
.const SPRITE_BITMAPS = LoadBinary("ready.bin")
```

``` asm
.pc = 64*FIRST_SPRITE_BITMAP_ID "Sprite bitmaps"
.fill SPRITE_BITMAPS.getSize(), SPRITE_BITMAPS.get(i)
```

First six of those sprites are displayed in a row.

``` asm
  .const start_x = 140
  .const start_y = 170
  .for (var i = 0; i < 6; i++) {
    :set_sprite_position(i, start_x + 16 * i, start_y)
  }
```

While the last one is pushed 16 pixels below.

``` asm
  :set_sprite_position(6, start_x, start_y + 16)
```

We also have an interrupt driven animation.

``` asm
  sei
  :mov16 #animate_sprites; irq_handler_vector
  cli 
```

It simply toggles that sprite on and off on each frame.

``` asm
animate_sprites:
  lda sprites.enable_bits
  eor #01000000
  sta sprites.enable_bits
  jmp irq_handler_address
```

When we run the program we can see that it displays the word "READY." and a blinking cursor underneath.

We already know how to make the animation slower using a counter that will skip a specific number of frames.

``` asm
animate_sprites:
  lda counter
  bne end
  :mov #30; counter
  lda sprites.enable_bits
  eor #01000000
  sta sprites.enable_bits
end:
  dec counter
  jmp irq_handler_address

counter: .byte 0
```
But this technique cannot ever be used to speed up the animation.

If we need more control over how frequently the interrupt is signalled, we need to understand timers.

The one that is causing the IRQ by default is called timer A.

It sits in the first of two Complex Interface Adapter chips or CIAs.

We can check it's status using the timer_a control register.

``` asm
  :print_string("TIMER A STATE ")
  :print_bits cia1.interrupt_timer_a_control
  :print_char #13
```

As we can see, only the first bit is set, which means that the timer is running.

We can print the actual 16 bit timer value at any time to see that it actually changes.

``` asm
  :print_char #13
  :print_int16 cia1.timer_a  

  // 8 more times

  :print_char #13
  :print_int16 cia1.timer_a

  :print_char #13
  :print_string("TIMER A STATE ")
  :print_bits cia1.interrupt_timer_a_control
```

If we clear the first bit of the control register. The timer will stop.

``` asm
  :mov #%00000000; cia1.interrupt_timer_a_control
```

This will also make the computer unusable since no interrupts will be generated from now on.

To see the initial value of the timer we can reset it by setting its fifth bit.

``` asm
  :mov #%00010000; cia1.interrupt_timer_a_control
```

If you are running this program on a Commodore 64 designed to work with a PAL system you will see a number 16421. While on the NTSC system the timer will be initialized with a number 17045.

This is because timer a is counting CPU cycles by default. Commodores working on different systems have different CPU frequencies.

And those numbers are simply number of cycles required to generate the IRQ signal roughly 60 times per second.

``` asm
C64 PAL - 985248 cycles/sec
Timer A - 16421 cycles/IRQ
~59,999269228 - IRQs/sec

C64 NTSC - 1022727 cycles/sec
Timer A - 17045 cycles/IRQ
~60,001584042 - IRQs/sec
```

Knowing that we can make the interrupt happen twice as fast if we divide this number by two, and use it to initialize the timer.

``` asm
  :mov16 #round(16421/2); cia1.timer_a
```

We can theoretically set the timer to 1 to try and execute the interrupt on every cycle. But this makes little sense in practice since the exuction of the interrupt handling routine will take many more cycles and signals generated at that time will be ignored. It will also give no chance for a normal program to execute. Since a new interrupt will be generated as soon as the previous one is handled.

We can also make the frequency slower. For example by multiplying the initial timer value by 2 we can make it twice as slow.

``` asm
  :mov16 #round(16421*2); cia1.timer_a
```

Unfortunately we can't slow it down to an arbitrary frequency this way.

The largest possible 16-bit number is only around 3.9 times bigger than the initial value of the timer.

``` asm
  :mov16 #round(16421*3.9); cia1.timer_a
```

By looking at the printed numbers, we can see that the timer counts down. As soon as it passes zero, it generates an interrupt signal and is being automatically reset to the initial value. And then it starts counting down immediately.

The reset happens because the timer a is set to the continuous mode by default.

This mode is on when the fourth bit of the control register is cleared.

If we set this bit, the timer will still generate the interrupt on underflow and reset to the initial value. But it will also stop and it will automatically clear the first bit of the control register.

``` asm
  :mov #%00001001; cia1.interrupt_timer_a_control
```

You can use this mode to schedule singular events that need to happen at some specific time in the future.

In that case it is usually a good idea to reset the timer when setting the one-off mode.

This way we can make sure that the timer will run for the whole requested period.

``` asm
  :mov #%00011001; cia1.interrupt_timer_a_control
```
And that's it for today.

In the next episode we will see how can we use the second timer to gain more control over the interrupt frequency.

See you soon!
