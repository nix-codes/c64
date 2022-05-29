;
; Time-based events using raster interrupts
;------------------------------------------
;
; The purpose of this demo is to show how to perform a time-based action sync'ing with the raster.
; General idea and strategy:
; 1. We set up a raster IRQ routine: our routine will execute every time the raster starts on an 
;    arbitrary line that we choose
; 2. A screen is fully redrawn ~60 times per second (on NTSC) or ~50 times per second (on PAL), 
;    which means that our IRQ routine will be execute that amount of times peer second.
; 3. Our routine will keep a counter so that every 50 times (for PAL) it will change the screen
;    border color.
; 4. It will run for the desired amount of time and finally exit cleanly.
;
; Sources:
; https://dustlayer.com/vic-ii/2013/4/25/vic-ii-for-beginners-beyond-the-screen-rasters-cycle
; https://dustlayer.com/c64-coding-tutorials/2013/4/8/episode-2-3-did-i-interrupt-you
; https://codebase64.org/doku.php?id=base:introduction_to_raster_irqs
; https://www.c64-wiki.com/wiki/Raster_interrupt
; https://www.youtube.com/watch?v=LpG9gqPtNLo
;
; Extra notes:
; Code is for "CBM prg Studio"
;




; ==========================
; Parameters
; ==========================
total_seconds  = 10                ;
raster_freq    = 50                ; 50 Hz on PAL or 60 on NTSC



; ==========================
; BASIC loader
; ==========================
; This will create the following single line in the BASIC program:
; 1 SYS4096
; which will load our main program at address $1000 (4096)
; See: https://www.c64-wiki.com/wiki/BASIC_token
;
*=$0801
               byte      $0b,$08     ; pointer to next instruction line: $080b
               byte      1,0         ; 1
               byte      $9e         ; SYS
               byte      "4096",0    ; 4096
               byte      0,0         ; end-of-program marker



; ===========================================
; our pseudo 16-bit registers in the zero page
; ===========================================
r0             = $10
r1             = $12



*=$1000

               lda       #total_seconds
               sta       r1        


;============================================================
; Main
;============================================================

               jsr       raster_routine_init
               jsr       install_raster_irq

check_done                         ; our raster routine indicates that it's done with a 0 on r1
               lda       #0        
               cmp       r1        
               bne       check_done
               jsr       uninstall_raster_irq

                                   ; jump to the default IRQ routine to exit cleanly
               jmp       $ea81     



install_raster_irq
               sei                 ; disable maskable IRQs

               ldy       #$7f      ; disable CIA timers interrupts
               sty       $dc0d     
               sty       $dd0d     

               lda       $dc0d     ; cancel all pending CIA IRQs
               lda       $dd0d     

               lda       #$01      
               sta       $d01a     ; specify interrupt type = "raster"

               lda       #$00      ; specify raster line (0) to interrupt
               sta       $d012     
               lda       $d011     ; bit 0 of #d011 behaves as bit 8 of $d012 (needed for a line > 255)
               and       #$7f      
               sta       $d011     


               lda       #<raster_routine; point IRQ vector to desired irq routine
               ldx       #>raster_routine
               sta       $0314     
               stx       $0315     


               cli                 ; re-enable IRQs

               rts


uninstall_raster_irq

               sei                 ; disable maskable IRQs

               ldy       #$ff      ; re-enable CIA timers
               sty       $dc0d     
               sty       $dd0d     

               lda       #$00      ; disable raster interrupt
               sta       $d01a     

               lda       #$31      ; restore default IRQ vector
               ldx       #$ea      
               sta       $0314     
               stx       $0315     

               cli                 ; re-enable IRQs

               rts


;============================================================
; our custom raster interrupt routine
;============================================================
raster_routine_init
               lda       #raster_freq
               sta       r0        
               rts

raster_routine
               dec       $d019     ; acknowledge IRQ
               dec       r0        
               bne       @exit     
               inc       $d020     
               jsr       raster_routine_init
               dec       r1        
@exit          jmp       $ea81     ; return to kernel interrupt routine to
                                   ; the point where it restores variables from stack and calls RTI

