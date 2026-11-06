


.EXTERNAL CIRCLSH-CIRCLSH
sub_circlsh     .FILL CIRCLSH-CIRCLSH


;   ============================================================================
;   Subrutina: Q12_TO_DQ16
;       Convierte entre distintos formatos Q.
;   
;   -> INPUT  [R0] Q3.12 .
;   <- OUTPUT [R0] Parte entera del Q15.16 . 
;   <- OUTPUT [R1] Parte fraccionaria del Q15.16 .
;   ============================================================================

;   [....Q3_12.....][..............]
;   [.....ext......][....Q3_12.....]    (ext de signo)
;   ...ext.....][....Q3_12.....][...    (<< 4)
;   [.....int......][.....frac..000]    (mascarar exedente)
;   [.....int......][.....frac.....]


Q12_TO_DQ16

    ST R2 q12_to_dq16_r2
    ST R3 q12_to_dq16_r3
    ST R7 q12_to_dq16_r7
    
    ; [R0] q3.12
    ADD R1 R0 #0
    
    AND R0 R0 #0
    ADD R1 R1 #0
    BRzp q12_to_dq16_sk1
    NOT R0 R0

q12_to_dq16_sk1
    LD R2 q12_to_dq16_n
    LD R3 sub_circlsh
    JSRR R3
    
    LD R2 q12_to_dq16_mask
    AND R1 R1 R2

    LD R2 q12_to_dq16_r2
    LD R3 q12_to_dq16_r3
    LD R7 q12_to_dq16_r7
    RET

q12_to_dq16_r2      .FILL #0
q12_to_dq16_r3      .FILL #0
q12_to_dq16_r7      .FILL #0
q12_to_dq16_n       .FILL #4
q12_to_dq16_mask    .FILL xFFF0


.END