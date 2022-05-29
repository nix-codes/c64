# c64
Proof of concepts and other misc. stuff for the Commodore C64
Besides the fun of it, the goal is to learn a bit of the 6502 assembler and try to create programs to use as art in, for example, videos.


## BASIC Loader
I'd rather comment that in this main documentation to avoid having to do it on each file.
In order to run an assembly program, you need to execute an instruction like this: `SYS <address>`. This will start the execution on the given address.
Example: If your program is set up to load at address `$1000` (4096 in dec), then `SYS 4096` will start the execution of your program.

A typical technique used for making assembly programs friendlier to load was to include that BASIC line in the program itself.
```
; ==========================
; BASIC loader
; ==========================
; This will create the following single line in the BASIC program:
; 1 SYS4096
; which will load our main program at address $1000 (4096)
*= $0801                        ; BASIC memory start address

       byte $0b,$08             ; pointer to next instruction line: $080b
       byte 1,0                 ; 1
       byte $9e                 ; SYS
       byte "4096",0            ; 4096
       byte 0,0                 ; end-of-program marker
       
*= $1000
; your main program code goes here
```
