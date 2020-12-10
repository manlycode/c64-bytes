# Sprites I - Properties

If you want to create a dynamic game like a shooter or a platformer, you will need to display multiple moving images representing entities like the player, monsters, bullets or even explosions.

It is possible, although quite hard to draw all of those using characters. We will take a look at this method in future episodes. But today we will explore a feature built into the hardware that was designed specifically to use in dynamic games.

VIC-II the graphical chip of Commodore 64 can display eight movable bitmaps, also known as sprites. All of them can be controlled by the set of registers that are mapped directly onto the memory starting at the hexadecimal address $d000.

``` asm
.const VIC2 = $d000
```

We will keep addresses of sprite registers in a namespace called sprites.

``` asm
.namespace sprites {
}
```

The first two addresses that we need are  the start of the positions registers address and a bitfield for enabling sprites.

``` asm
  .label positions = VIC2
  .label enable_bits = VIC2 + 21
```

With those defined we can display our first sprite. To do that we need to ensure two things. 

First we need to enable the sprite so that the VIC-II will draw it. 

This can be accomplished by setting the bit at the position 0 in the sprites.enabled bitfield. 

``` asm
  lda #%00000001
  sta sprites.enable_bits
```

Now, let's define two variables that will define the horizontal and vertical positions  of the sprite so that we can actually see it on the screen. X equal to 25 and Y equal to 51 will make sure that the sprite is placed in the top left corner one pixel away from the border.

``` asm
  .var x = 25
  .var y = 51
```

Now we just need to assign the x variable to the sprite.positions + 0 address, and y to the sprite.positions + 1.

``` asm
  lda #x
  sta sprites.positions + 0
  lda #y
  sta sprites.positions + 1
```

Once we run the program, we can see that there is a white rectangle displayed at the top left corner of the screen. And this is our sprite.

By default, sprite bitmaps are defined with all bits set in them. We will change that in the next episode. For now let's just display the remaining ones.

It is convenient to start numbering them from 0 to 7. This way we can directly assign a bit position to each sprite. This time, we will enable all of them,

``` asm
  lda #%11111111
  sta sprites.enable_bits
```

and initialize their positions in a for loop.

``` asm
  .for (var i = 0; i < 8; i++) {

  }
```

Each sprite is a 24 by 21 pixels bitmap. If we offset each position by those numbers, we can expect to see them arranged diagonally.

``` asm
    .var x = 25 + 24*i
    .var y = 51 + 21*i
```

Sprite positions are laid in the memory in pairs so that the Xs are on even offsets, and Ys are offset by odd numbers.

``` asm
    lda #x
    sta sprites.positions + 2*i + 0
    lda #y
    sta sprites.positions + 2*i + 1
```

The default sprite colors make the sprite number 5 seemingly invisible. Let's change that.

The color registers start at the 39th byte counting from the VIC-II base address.

``` asm
  .label colors = VIC2 + 39
```

Let's define a color variable in the for loop and assign an odd color to it.

``` asm
    .var color = 2*i + 1
```

Colors for each sprite are placed next to each other so we can easily assign them by adding the index to the sprites.colors address.

``` asm
    lda #color
    sta sprites.colors + i
```

Now all af our sprites are fully visible.

We already know that the top left corner of the visible area of the screen starts at the 24 pixels horizontally and 50 pixels vertically.

``` asm
  // left
  lda #24

  // top
  lda #50

```
And we already have the first sprite there pushed just one pixel away from the border.

``` asm
  // left
  lda #24 + 1
  sta sprites.positions + 2*0 + 0

  // top
  lda #50 + 1
  sta sprites.positions + 2*0 + 1
```

The visible area of the screen is 200 pixels tall, so if we add the height of the top border, we get 250. And that's the vertical position of the first pixel covered by the bottom border.

``` asm
  // bottom
  lda #250
```

If we want the second sprite to be placed one pixel away from there, we need to offset its vertical position by minus 22.

``` asm 
  // left
  lda #24 + 1
  sta sprites.positions + 2*0 + 0
  sta sprites.positions + 2*1 + 0

  // bottom
  lda #250 - 22
  sta sprites.positions + 2*1 + 1
```

The first pixel covered by the right border has its horizontal position set to 344. That is the width of 320 pixels of the visible area plus the 24-pixel width of the border.

``` asm
  // right
  lda #344
```

To place the third sprite one pixel away from the bottom right corner, we need to offset its horizontal position by minus 25.

``` asm
  // right
  lda #344 - 25
  sta sprites.positions + 2*2 + 0

  // bottom
  lda #250 - 22
  sta sprites.positions + 2*1 + 1
  sta sprites.positions + 2*2 + 1
```

With all positions defined we can place the final sprite at the top right corner.

``` asm
  // right
  lda #344 - 25
  sta sprites.positions + 2*2 + 0
  sta sprites.positions + 2*3 + 0

  // top
  lda #50 + 1
  sta sprites.positions + 2*0 + 1
  sta sprites.positions + 2*3 + 1
```

But, it doesn't work.

The problem with the right position is that it doesn't fit in a byte, and it overflows. So effectively we got the same effect as subtracting 256 from the rightmost position.

``` asm
  lda #344 - 25 - 256
```

To store this number, we would need at least 9 bits. So we need a way to set the 9th bit of the horizontal position for each sprite.

To save the memory, all of those bits are cleverly packed in another bitfield that is placed in the memory right after all sprite position registers.

``` asm
  .label position_x_high_bits = VIC2 + 16
```

If we set the bits for the second and third sprite, 256 will be effectively added to their horizontal positions, and they will be finally placed in rightmost corners.

``` asm
  // right
  lda #%00001100
  sta sprites.position_x_high_bits
  lda #344 - 25 - 256
```

To finish this episode let's also learn two additional bit fields that can be used to stretch sprites in both directions.

Twenty-three bytes away from the VIC-II base address is the vertical_stretch bitfield. While the horizontal one is placed six bytes further.

``` asm
  .label vertical_stretch_bits = VIC2 + 23
  .label horizontal_stretch_bits = VIC2 + 29
```

The 8th sprite will be stretched in both directions. The 5th one only vertically. And we will apply only the horizontal stretch to the 6th one.

``` asm
  lda #%10010000
  sta sprites.vertical_stretch_bits

  lda #%10100000
  sta sprites.horizontal_stretch_bits
```

It is important to realise that while the size of the sprite changes during expansion, the number of pixels in the bitmap defining the sprite does not. Well it is not immediately obvious at the moment as we display just plain rectangles. 
But it will be visible in the next episode in which we'll learn how to redefine sprite bitmaps.

See you soon!




