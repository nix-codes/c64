; ==========================
; Definitions
; ==========================

; -----------------------------------------------
; Kernal routines used
; -----------------------------------------------
k_chrout       = $ffd2             ; Kernal routine to output a single character (typically to the screen)


; -----------------------------------------------
; our virtual 16-bit registers in the zero page
; -----------------------------------------------
r0             = $fb
r1             = $fd


; -----------------------------------------------
; BASIC loader:
; 10 SYS (4096)
; -----------------------------------------------
*=$0801

               byte      $0E, $08, $0A, $00, $9E, $20, $28
               byte      $34, $30, $39, $36, $29, $00, $00, $00



*= $1000

; ==========================
; Main
; ==========================

               jsr       print_nl
               lda       #<message 
               sta       r0 + 0
               lda       #>message 
               sta       r0 + 1
               jsr       print     
               rts


; -----------------------------------------------------------------
; print_nl
;
; Prints a new line in the current cursor position.
; 
; destroys: .A
; -----------------------------------------------------------------
print_nl       lda       #$0d
               jsr       k_chrout
               rts

; -----------------------------------------------------------------
; print
;
; Prints a null-terminated string in the current cursor position.
;
; receives: (R0): address of the string
; returns :    Y: length of the string
; destroys:    A
; -----------------------------------------------------------------
print          ldy       #0
@read_char     lda       (r0),y
               beq       @end      
               jsr       k_chrout  
               iny
               jmp       @read_char
@end           rts



; ==========================
; Data
; ==========================
message
               text      "hello, world!",0


