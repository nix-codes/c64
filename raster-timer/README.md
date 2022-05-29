Time-based events using raster interrupts
------------------------------------------

The purpose of this demo is to show how to perform a time-based action sync'ing with the raster.

General idea and strategy:
1. We set up a raster IRQ routine: our routine will execute every time the raster starts on an 
   arbitrary line that we choose
2. A screen is fully redrawn ~60 times per second (on NTSC) or ~50 times per second (on PAL), 
   which means that our IRQ routine will be execute that amount of times peer second.
3. Our routine will keep a counter so that every 50 times (for PAL) it will change the screen
   border color.
4. It will run for the desired amount of time and finally exit cleanly.

Sources:
https://dustlayer.com/vic-ii/2013/4/25/vic-ii-for-beginners-beyond-the-screen-rasters-cycle
https://dustlayer.com/c64-coding-tutorials/2013/4/8/episode-2-3-did-i-interrupt-you
https://codebase64.org/doku.php?id=base:introduction_to_raster_irqs
https://www.c64-wiki.com/wiki/Raster_interrupt
https://www.youtube.com/watch?v=LpG9gqPtNLo

Extra notes:
Assembly code is for "CBM prg Studio" assembler.

