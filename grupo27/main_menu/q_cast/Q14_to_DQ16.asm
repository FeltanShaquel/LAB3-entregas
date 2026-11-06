


.EXTERNAL CIRCLSH-CIRCLSH
sub_circlsh     .FILL CIRCLSH-CIRCLSH


;   ============================================================================
;   Subrutina: Q14_TO_DQ16
;       Convierte entre distintos formatos Q.
;   
;   -> INPUT  [R0] Q1.14 .
;   <- OUTPUT [R0] Parte entera del Q15.16 . 
;   <- OUTPUT [R1] Parte fraccionaria del Q15.16 .
;   ============================================================================

;   [....Q1_14.....][..............]
;   [.....ext......][....Q1_14.....]    (ext de signo)
;   .....ext.....][....Q1_14.....][.    (<< 2)
;   [.....int......][.....frac....0]    (mascarar exedente)
;   [.....int......][.....frac.....]


Q14_TO_DQ16

    ST R2 q14_to_dq16_r2
    ST R3 q14_to_dq16_r3
    ST R7 q14_to_dq16_r7
    
    ; [R0] q1.14
    ADD R1 R0 #0
    
    AND R0 R0 #0
    ADD R1 R1 #0
    BRzp q14_to_dq16_sk1
    NOT R0 R0

q14_to_dq16_sk1
    LD R2 q14_to_dq16_n
    LD R3 sub_circlsh
    JSRR R3
    
    LD R2 q14_to_dq16_mask
    AND R1 R1 R2

    LD R2 q14_to_dq16_r2
    LD R7 q14_to_dq16_r7
    RET

q14_to_dq16_r2      .FILL #0
q14_to_dq16_r3      .FILL #0
q14_to_dq16_r7      .FILL #0
q14_to_dq16_n       .FILL #2
q14_to_dq16_mask    .FILL xFFFC


.END