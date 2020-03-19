**************************************************************************
*
* Title:                LED Light Blinking
* 
* Objective:            CSE472 Homework 4
*                       (in-class-room demonstration)
*
* Revision:             V4.5
*
* Date:                 Oct. 2. 2019
*
* Programmer:           Songmeng Wang
* 
* Company:              The Pennsylvania State University
*                       Department of Computer Science and Engineering
*
* Algorithm:            Loops and branches on CSM12C128 board
*
* Resister use:         A accumulator
*                       B acuumulator
*                       X register
*                       Y register
*
* Memory use:           RAM Locations from $3000 for data.
*                                     from $3100 for program.
*
* Input:                
*
* Output:               
*
* Observation:          
*               
* Comments:
*             
*****************************************************************************
*Parameter Declearation Section
*
*Export Symbols
            XDEF      pgstart     ; export 'pgstart' symbol
            ABSENTRY  pgstart     ; for assembly entry point
*                                 ; This is first instruction of the program
*                                 ;     up on the start of simulation

*Symbols and Macros
PORTA       EQU       $0000       ; i/o port addresses(port A not used)
DDRA        EQU       $0002

PORTB       EQU       $0001       ; PORT B is connected with LEDs
DDRB        EQU       $0003
PUCR        EQU       $000C       ; to enable pull-up mode for PORT A,B,E,K

PTP         EQU       $0258       ; PORTP data register, used for Push Switch
PTIP        EQU       $0259       ; PORTP input register <<==================
DDRP        EQU       $025A       ; PORTP data direction register
PERP        EQU       $025C       ; PORTP pull up/down enable
PPSP        EQU       $025D       ; PORTP pull up/down selection

*****************************************************************************
*Data Section
*
            ORG       $3000       ; reserved RAM memory starting address
                                  ;   Memory $3000 to $30FF are for Data
Counter1    DC.W      $0004       ; initial X register count number
Counter2    DC.W      $0001       ; initial Y register count number

StackSpace                        ; remaining memory space for stack data
                                  ; initial stack pointer position set
                                  ; to $3100 (pgstart)
*
*****************************************************************************
* Program Section
*
            ORG       $3100           ; Program start address, in RAM
pgstart     LDS       #pgstart        ; initialize the stack pointer

            LDAA      #%11110000      ; set PORTB bit 7,6,5,4 as output, 3,2,1,0
            STAA      DDRB            ; LED 1,2,3,4 on PORTB bit 4,5,6,7
                                      ; DIP switch 1,2,3,4 on PORTB bit 0,1,2,3
            BSET      PUCR,%00000010  ; enable PORTB pull up/down feature, for the DIP switch 1,2,3,4 on the bits 0,1,2,3.

                                      
            BCLR      DDRP,%00000011  ; Push Button Switch 1 and 2 at PORTP bit 0 and 1    
                                      ; set PORTP bit 0 and 1 as input
            BSET      PERP,%00000011  ; enable the pull up/down feature at PORTP bit 0 and 1
            BCLR      PPSP,%00000011  ; select pull up feature at PORTP bit 0 and 1 for the 
                                      ;   Push Button Switch 1 and 2.
                                      
            LDAA      #%00100000      ; Turn off LED 2 at PORTB bit 4,5
            STAA      PORTB           ; Note:LED numbers and PORTB bit numbers are different
            
mainLoop    
            JSR       rise            ; increase light level
            JSR       fall            ; decrease light level
            BRA       mainLoop        ; loop forever
                
*****************************************************************************
* Subroutine Section
*

;************************************************************
; rising/falling light level subroutines
; These subroutines rises/falls light level of LED4
;
; Input: 'counters' valued $40 and 0 to show the percentage light level
; Output: the light level change
; Register in use: A,B as counters
; Memory location in use: $3050 to store the counter

rise
          PSHB
          PSHA
          
          LDAB      #$00
          LDAA      #$84
rlloop
          BCLR      PORTB,%00010000      ; turn ON LED1 at PORTB 4
          STAB      $3050                ; store counter into memory
          JSR       delaytime            ; run delay10us by counter times
          BSET      PORTB,%00010000      ; turn OFF LED1 at PORTB 4
          STAA      $3050                ; store counter into memory
          JSR       delaytime            ; run delay10us by counter times
          INCB                           ; counterB+1
          DECA                           ; counterA-1
          BNE       rlloop               ; jump back to loop
          
          PULB
          PULA
          RTS
          
fall
          PSHB
          PSHA
          
          LDAB      #$84
          LDAA      #$00
flloop
          BCLR      PORTB,%00010000      ; turn ON LED1 at PORTB 4
          STAB      $3050                ; store counter into memory
          JSR       delaytime            ; run delay10us by counter times
          BSET      PORTB,%00010000      ; turn OFF LED1 at PORTB 4
          STAA      $3050                ; store counter into memory
          JSR       delaytime            ; run delay10us by counter times
          INCA                           ; counterA+1
          DECB                           ; counterB-1
          BNE       flloop               ; jump back to loop
          
          PULB
          PULA
          RTS
          
;************************************************************
; delay by 'counter' times subroutine
; These subroutines runs delay1us by 'counter' times
;
; Input: 'counter' stored in $3050
; Output: Percentage bright level for LED4
; Register in use: Y register, as counter
; Memory locations in use:8 bit input numbers in 'Counter'
          
delaytime
          PSHY
          
          LDY       $3050                ; read the counter from memory
dtloop
          JSR       delay1us             ; B* delay10us
          DEY
          BNE       dtloop
          
          PULY
          RTS
          
          
;************************************************************
; delay1ussubroutine
;
; This subroutine causes 1 us delay
; Input: a 16 bit count number in 'Counter1'
; Output: time delay, cpu cycle waisted
; Register in use: X register, as counter
; Memory locations in use: a 16 bit input number in 'Counter1'
;

delay1us
          PSHA
          
          LDAA      #$1                ; short delay
dly1loop  DECA
          BNE       dly1loop
          
          PULA
          RTS



          
          
                                        

