

.EXTERNAL GETVAL_BUFFER-BUFFER
.EXTERNAL GETVAL_BUFFER-BUFFER_END
ext_buffer      .FILL GETVAL_BUFFER-BUFFER
ext_buffer_end  .FILL GETVAL_BUFFER-BUFFER_END

.EXTERNAL GETLINE-GETLINE
.EXTERNAL FROMDEC-FROMDEC
.EXTERNAL TODEC-TODEC
sub_getline     .FILL GETLINE-GETLINE
sub_fromdec     .FILL FROMDEC-FROMDEC
sub_todec       .FILL TODEC-TODEC

.EXTERNAL DQ16_TO_Q12-DQ16_TO_Q12
.EXTERNAL Q12_TO_DQ16-Q12_TO_DQ16
sub_to_q12      .FILL DQ16_TO_Q12-DQ16_TO_Q12
sub_from_q12    .FILL Q12_TO_DQ16-Q12_TO_DQ16


;
;   Subrutina para obtener un valor por teclato en cierto formato, mostrando un prompt y el valor obtenido.
;


GETVAL_Q12

    ; [R0] prompt   ("a > ")
    ; [R1] name     ("a:  ")

    ST R1 getval_q12_name               ;
    ST R2 getval_q12_r2                 ;
    ST R3 getval_q12_r3                 ;
    ST R4 getval_q12_r4                 ;
    ST R5 getval_q12_r5                 ;
    ST R7 getval_q12_r7                 ;

    PUTS                                ;   print(prompt)

    LD R0 ext_buffer                    ;
    LD R1 ext_buffer_end                ;
    LD R2 sub_getline                   ;
    JSRR R2                             ;   [R0] buffer = getline()

    LD R2 sub_fromdec                   ;
    JSRR R2                             ;   [R0, R1, R5] = [entero, decimal, errores]

    LD R2 sub_to_q12                    ;
    JSRR R2                             ;
    ST R0 getval_q12_value              ;
    LD R2 sub_from_q12                  ;   
    JSRR R2                             ;

    LD R2 ext_buffer                    ;
    AND R3 R3 #0                        ;   # (R3 = formato)
    LD R4 sub_todec                     ;
    JSRR R4                             ;   [R2] = buffer   # (con valor actualizado)

    LD R0 getval_q12_name               ;
    PUTS                                ;
    ADD R0 R2 #0                        ;
    PUTS                                ;
    AND R0 R0 #0                        ;
    ADD R0 R0 #10                       ;
    OUT                                 ;   print(name + buffer + '\n')

    LD R0 getval_q12_value              ;
    LD R1 getval_q12_name               ;
    LD R2 getval_q12_r2                 ;
    LD R3 getval_q12_r3                 ;
    LD R4 getval_q12_r4                 ;
    LD R5 getval_q12_r5                 ;
    LD R7 getval_q12_r7                 ;
    RET                                 ;

getval_q12_value   .FILL #0
getval_q12_name    .FILL #0
getval_q12_r2      .FILL #0
getval_q12_r3      .FILL #0
getval_q12_r4      .FILL #0
getval_q12_r5      .FILL #0
getval_q12_r7      .FILL #0


.END