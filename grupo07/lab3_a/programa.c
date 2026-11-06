#include <stdio.h>
#include <stdint.h>

int main() {
    float num1_f, num2_f;
    printf("Ingrese el primer numero decimal (ej: 3.5): ");
    scanf("%f", &num1_f);
    printf("Ingrese el segundo numero decimal (ej: 1.25): ");
    scanf("%f", &num2_f);

    int16_t q3_12 = (int16_t)(num1_f * 4096.0f);
    int16_t q7_8  = (int16_t)(num2_f * 256.0f);

    int16_t q7_8_aligned = q7_8 << 4; 
    int16_t suma_q3_12 = q3_12 + q7_8_aligned; // Resultado en Q3.12
    int16_t resta_q3_12 = q3_12 - q7_8_aligned; // Resultado en Q3.12

    int32_t mult_intermedia = (int32_t)q3_12 * (int32_t)q7_8; // Formato resultante implícito: Q10.20
    
    int16_t mult_resultado = (int16_t)(mult_intermedia >> 8);

    int32_t div_intermedia = ((int32_t)q3_12 << 8) / (int32_t)q7_8;
    int16_t div_resultado = (int16_t)div_intermedia; // Formato resultante determinado por la diferencia de escalas.

    printf("\n--- RESULTADOS EN PUNTO FIJO ---\n");
    printf("Q3.12 (Num1): %d\n", q3_12);
    printf("Q7.8  (Num2): %d\n", q7_8);
    printf("Suma (Q3.12): %d\n", suma_q3_12);
    printf("Multiplicacion (Q3.12): %d\n", mult_resultado);
    printf("Division: %d\n", div_resultado);

    return 0;
}