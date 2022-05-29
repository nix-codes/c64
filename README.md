# c64
Proof of concepts and other misc. stuff for the Commodore C64
Besides the fun of it, the goal is to learn a bit of the 6502 assembler and try to create programs to use as art in, for example, videos.


## Patterns
I will use some patterns across the code samples.

### Pattern: BASIC Loader
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
For info on the BASIC instruction tokens, see: https://www.c64-wiki.com/wiki/BASIC_token
<br>
<br>
### Pattern: Virtual 16-bit registers
The 6502 is very limited in registers. We only have 3 8-bit registers (A, X, Y) to do everything, and they are quite inconvenient for using as 16-bit parameters, typically for addresses.
For this reason, I'll define an area in the Zero-Page (ZP) to store our virtual registers:
```
; -----------------------------------------------
; our virtual 16-bit registers in the zero page
; -----------------------------------------------
r0             = $fb
r1             = $fd
```
I picked `$00fb` and `$00fd` because that area of 4 bytes is unused. However, it seems that it's a valid practice to override other areas, as long as your code doesn't need any of the functionalitites stored in the area that you are overriding.
<br>
<br>
### Pattern: Implicit `CMP`s
In many cases we may want to do a comparison by using `CMP` or any of its variants. In the end, what we end up checking is for the `Z` flag. Keep in mind that different operations apart from `CMP` modify this flag so, for example, you don't need to do a `CMP` after you do `LDA`, because the latter will always turn on the Z flag if the value loaded onto `A` is zero.
