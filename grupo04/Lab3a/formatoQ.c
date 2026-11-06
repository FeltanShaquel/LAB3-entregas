// Laboratorio 3-a - Formato Q

#include <stdio.h>
#include <stdint.h>
#include <inttypes.h>

void formato(float num1_float, float num2_float)
{
    /*
     * 2) Conversión a formatos Q
     *
     * Se utilizan dos formatos diferentes:
     *
     * num1 -> Q4.11
     * num2 -> Q7.8
     *
     * En un formato Q con n bits fraccionarios,
     * el valor entero almacenado se obtiene multiplicando
     * el número real por 2^n.
     */

    const int32_t escala_q11 = 1 << 11;   // 2^11 = 2048
    const int32_t escala_q8  = 1 << 8;    // 2^8  = 256

    int16_t num1_q11;
    int16_t num2_q8;

    /*
     * Conversión de punto flotante a punto fijo.
     * El casting convierte el resultado a un entero de 16 bits.
     */
    num1_q11 = (int16_t)(num1_float * escala_q11);
    num2_q8  = (int16_t)(num2_float * escala_q8);

    printf("\n--- Conversion a formato Q ---\n");
    printf("num1 en Q4.11: %" PRId16 "\n", num1_q11);
    printf("num2 en Q7.8 : %" PRId16 "\n", num2_q8);


    /*
     * 3) Compatibilizacion para suma y resta
     *
     * Para poder sumar o restar los numeros, ambos deben
     * tener la misma cantidad de bits fraccionarios.
     *
     * num1 esta en Q4.11
     * num2 esta en Q7.8
     *
     * Pasamos num2 de Q7.8 a una representacion con
     * 11 bits fraccionarios:
     *
     *     11 - 8 = 3
     *
     * Por lo tanto multiplicamos por 2^3 = 8.
     *
     * Un desplazamiento a la izquierda de 3 posiciones
     * equivale a multiplicar por 8.
     */

    int32_t num2_q11 = (int32_t)num2_q8 << 3;

    printf("\n--- Compatibilizacion de formatos ---\n");
    printf("num2 convertido a Q?.11: %" PRId32 "\n", num2_q11);


    /*
     * Ambos valores estan ahora expresados con 11 bits
     * fraccionarios, por lo que pueden sumarse y restarse.
     */

    int32_t suma_q11 =
        (int32_t)num1_q11 + num2_q11;

    int32_t resta_q11 =
        (int32_t)num1_q11 - num2_q11;

    printf("\n--- Suma y resta ---\n");
    printf("Suma en Q?.11 : %" PRId32 "\n", suma_q11);
    printf("Resta en Q?.11: %" PRId32 "\n", resta_q11);

    /*
     * Para visualizar los resultados en decimal:
     *
     * valor real = valor entero / 2^11
     */
    printf("Suma en decimal : %.8f\n",
           (float)suma_q11 / escala_q11);

    printf("Resta en decimal: %.8f\n",
           (float)resta_q11 / escala_q11);


    /*
     * 4) Multiplicacion
     *
     * num1 esta en Q4.11
     * num2 esta en Q7.8
     *
     * Al multiplicar:
     *
     *     11 + 8 = 19
     *
     * Por lo tanto el resultado posee 19 bits fraccionarios:
     *
     *     Q?.19
     *
     * Se utiliza int32_t para disponer de suficiente espacio
     * para almacenar el producto.
     */

    int32_t mult_q19 =
        (int32_t)num1_q11 * (int32_t)num2_q8;

    printf("\n--- Multiplicacion ---\n");
    printf("Producto en Q?.19: %" PRId32 "\n", mult_q19);

    /*
     * Para expresar nuevamente el resultado en Q?.8,
     * debemos pasar de 19 bits fraccionarios a 8:
     *
     *     19 - 8 = 11
     *
     * Por lo tanto dividimos por 2^11.
     *
     * El desplazamiento a la derecha de 11 posiciones
     * realiza esta division por 2^11.
     */

    int32_t mult_res_q8 =
        mult_q19 >> 11;

    printf("Producto convertido a Q?.8: %" PRId32 "\n",
           mult_res_q8);

    /*
     * Como el resultado esta expresado en Q?.8,
     * para obtener el valor real se divide por 2^8.
     */
    printf("Producto en decimal: %.8f\n",
           (float)mult_res_q8 / escala_q8);


    /*
     * 5) Division conservando la mayor resolucion posible
     *
     * Si dividieramos directamente:
     *
     *     Q?.11 / Q?.8
     *
     * el resultado tendria:
     *
     *     11 - 8 = 3 bits fraccionarios.
     *
     * Esto produciria una resolucion muy baja.
     *
     * Para conservar mayor precision, primero aumentamos
     * la escala del dividendo en 8 bits:
     *
     *     Q?.11 -> Q?.19
     *
     * multiplicando por 2^8.
     *
     * Luego:
     *
     *     Q?.19 / Q?.8 = Q?.11
     *
     * De esta forma obtenemos un resultado con 11 bits
     * fraccionarios.
     */

    if (num2_q8 == 0)
    {
        printf("\nNo se puede realizar la division: "
               "el segundo numero es cero.\n");
        return;
    }

    int32_t dividendo_q19 =
        (int32_t)num1_q11 << 8;

    printf("\n--- Division ---\n");
    printf("Dividendo convertido a Q?.19: %" PRId32 "\n",
           dividendo_q19);

    /*
     * Q?.19 / Q?.8 = Q?.11
     */
    int32_t div_res_q11 =
        dividendo_q19 / (int32_t)num2_q8;

    printf("Resultado de la division en Q?.11: %" PRId32 "\n",
           div_res_q11);

    /*
     * Como el resultado esta en Q?.11,
     * se divide por 2^11 para obtener el valor real.
     */
    printf("Division en decimal: %.8f\n",
           (float)div_res_q11 / escala_q11);
}


int main(void)
{
    /*
     * 1) Declaracion de variables de punto flotante.
     *
     * Se pueden colocar breakpoints aqui y observar
     * num1_float y num2_float durante la depuracion.
     */

    float num1_float;
    float num2_float;

    printf("Ingrese el primer numero: ");

    if (scanf("%f", &num1_float) != 1)
    {
        printf("Entrada invalida.\n");
        return 1;
    }

    printf("Ingrese el segundo numero: ");

    if (scanf("%f", &num2_float) != 1)
    {
        printf("Entrada invalida.\n");
        return 1;
    }

    /*
     * Breakpoint sugerido:
     * inspeccionar num1_float y num2_float antes
     * de realizar la conversion a formato Q.
     */

    formato(num1_float, num2_float);

    return 0;
}