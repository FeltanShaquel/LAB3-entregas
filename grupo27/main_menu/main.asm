

;
;   Programa principal, para probar el funcionamiento de la subrutina MAIN_MENU.
;   (Se puede usar la subrutina MAIN_MENU desde otro programa que no sea este si es necesario).
;



.EXTERNAL MAIN_MENU-MAIN_MENU
; Por que es el programa main, las direcciones de simbolos externos los pongo despues del programa...

.ORIG x3000

    LD R0 sub_main_menu
    JSRR R0
    HALT

sub_main_menu       .FILL MAIN_MENU-MAIN_MENU


.END