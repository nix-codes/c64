; ============================================================
; Parameters
; ============================================================
total_seconds  = 10                ; total running time for this demo
raster_freq    = 50                ; 50 Hz on PAL or 60 on NTSC


; ============================================================
; Definitions
; ============================================================

; -----------------------------------------------
; our virtual 16-bit registers in the zero page
; -----------------------------------------------
r0             = $fb
r1             = $fd

; ============================================================
; BASIC loader:
; 10 SYS (4096)
; ============================================================
*=$0801

               byte      $0E, $08, $0A, $00, $9E, $20, $28
               byte      $34, $30, $39, $36, $29, $00, $00, $00



; ============================================================
; Main
; ============================================================
*=$1000

               lda       #total_seconds
               sta       r1        
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


; -----------------------------------
; our custom raster interrupt routine
; -----------------------------------
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

