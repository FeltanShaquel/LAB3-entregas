#include <stdio.h>

int multiplicar(int a, int b)
{
    int resultado = 0;
    int signo = 1;

    // Determinar el signo del resultado
    if (a < 0)
    {
        signo = signo * (-1);
        a = -a;
    }

    if (b < 0)
    {
        signo = signo * (-1);
        b = -b;
    }

    // Multiplicación mediante sumas
    while (b > 0)
    {
        resultado = resultado + a;
        b = b - 1;
    }

    return resultado * signo;
}


int pow_binaria(int x, int y)
{
    int resultado = 1;
    int base = x;
    int exponente = y;

    while (exponente > 0)
    {
        if (exponente % 2 == 1)
        {
            resultado = multiplicar(resultado, base);
        }

        base = multiplicar(base, base);
        exponente = exponente / 2;
    }

    return resultado;
}


int main()
{
    int x, y;
    int resultado;

    printf("Ingrese la base x: ");
    scanf("%d", &x);

    printf("Ingrese el exponente y: ");
    scanf("%d", &y);

    resultado = pow_binaria(x, y);

    printf("%d^%d = %d\n", x, y, resultado);

    return 0;
}