


.EXTERNAL CIRCLSH-CIRCLSH
sub_circlsh     .FILL CIRCLSH-CIRCLSH


;   ============================================================================
;   Subrutina: Q8_TO_DQ16
;       Convierte entre distintos formatos Q.
;   
;   -> INPUT  [R0] Q7.8 .
;   <- OUTPUT [R0] Parte entera del Q15.16 . 
;   <- OUTPUT [R1] Parte fraccionaria del Q15.16 .
;   ============================================================================

;   [....Q7_8......][..............]
;   [.....ext......][....Q7_8......]    (ext de signo)
;   ..ext..][....Q7_8......][.......    (<< 8)
;   [.....int......][.frac..0000000]    (mascarar exedente)
;   [.....int......][.....frac.....]


Q8_TO_DQ16

    ST R2 q8_to_dq16_r2
    ST R3 q8_to_dq16_r3
    ST R7 q8_to_dq16_r7
    
    ; [R0] q7.8
    ADD R1 R0 #0
    
    AND R0 R0 #0
    ADD R1 R1 #0
    BRzp q8_to_dq16_sk1
    NOT R0 R0

q8_to_dq16_sk1
    LD R2 q8_to_dq16_n
    LD R3 sub_circlsh
    JSRR R3
    
    LD R2 q8_to_dq16_mask
    AND R1 R1 R2

    LD R2 q8_to_dq16_r2
    LD R3 q8_to_dq16_r3
    LD R7 q8_to_dq16_r7
    RET

q8_to_dq16_r2       .FILL #0
q8_to_dq16_r3       .FILL #0
q8_to_dq16_r7       .FILL #0
q8_to_dq16_n        .FILL #8
q8_to_dq16_mask     .FILL xFF00

.END