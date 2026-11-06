/*
 * mainv3.c - Laboratorio 3: MCD y MCM en LC-3, formato Q15.0.
 *
 * El programa mantiene dos implementaciones independientes:
 *   1. calcular_solo_c: logica de referencia exclusivamente en C,
 *      usando restas sucesivas para el MCD, division y sumas sucesivas
 *      para el MCM.
 *   2. ejecutar_programa_lc3: simulacion funcional del programa autonomo
 *      LC-3, cargando sus palabras de maquina, entradas y resultados en
 *      memoria y ejecutando hasta HALT.
 */
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MEM_SIZE 65536u
#define ORIGEN 0x3000u
#define LIMITE_INSTRUCCIONES 5000000ULL
#define DIRECCION_DATO_A 0x3030u
#define DIRECCION_DATO_B 0x3031u
#define DIRECCION_RESULTADO_MCD 0x3032u
#define DIRECCION_RESULTADO_MCM 0x3033u
#define DIRECCION_FLAG_OVERFLOW 0x3034u

typedef struct {
    int16_t mcd;
    int16_t mcm;
    int32_t mcm_exacto;
    bool overflow;
    bool entrada_invalida;
    uint32_t iter_mcd;
    uint32_t iter_div;
    uint32_t iter_mul;
} Resultado;

typedef struct {
    uint16_t memoria[MEM_SIZE];
    uint16_t registros[8];
    uint16_t pc;
    uint16_t condicion;
    bool ejecutando;
    uint64_t instrucciones;
    uint64_t por_opcode[16];
} LC3;

enum {
    OP_BR = 0, OP_ADD, OP_LD, OP_ST, OP_JSR, OP_AND, OP_LDR, OP_STR,
    OP_RTI, OP_NOT, OP_LDI, OP_STI, OP_JMP, OP_RES, OP_LEA, OP_TRAP
};

enum { FLAG_POS = 1u, FLAG_ZERO = 2u, FLAG_NEG = 4u };

static const char *NOMBRE_OPCODE[16] = {
    "BR", "ADD", "LD", "ST", "JSR/JSRR", "AND", "LDR", "STR",
    "RTI", "NOT", "LDI", "STI", "JMP/RET", "RES", "LEA", "TRAP"
};

/*
 * Programa autonomo LC-3 equivalente a la logica de mcm_mcd_v3.asm,
 * con entradas/salidas en memoria. Termina con HALT.
 */
static const uint16_t PROGRAMA_AUTONOMO[] = {
    0x202F, 0x0602, 0x903F, 0x1021, 0x222C, 0x0602, 0x927F, 0x1261,
    0x1820, 0x1A60, 0x5DA0, 0x1020, 0x041D, 0x1260, 0x041C, 0x947F,
    0x14A1, 0x1602, 0x0407, 0x0802, 0x10E0, 0x0FF9, 0x943F, 0x14A1,
    0x1242, 0x0FF5, 0x3017, 0x54A0, 0x963F, 0x16E1, 0x14A1, 0x1903,
    0x03FD, 0x56E0, 0x16C5, 0x0601, 0x1DA1, 0x14BF, 0x03FB, 0x360B,
    0x3C0B, 0xF025, 0x1060, 0x3006, 0x5260, 0x3205, 0x3205, 0xF025,
    0x0000, 0x0000, 0x0000, 0x0000, 0x0000
};

static uint16_t extender(uint16_t valor, unsigned bits) {
    if ((valor >> (bits - 1u)) & 1u)
        valor |= (uint16_t)(0xFFFFu << bits);
    return valor;
}

static void actualizar_condicion(LC3 *vm, unsigned registro) {
    if (vm->registros[registro] == 0) vm->condicion = FLAG_ZERO;
    else if (vm->registros[registro] & 0x8000u) vm->condicion = FLAG_NEG;
    else vm->condicion = FLAG_POS;
}

static int32_t absoluto_q15(int16_t valor) {
    return valor < 0 ? -(int32_t)valor : valor;
}

/* Primera funcion principal: solo C, sin instrucciones LC-3. */
static Resultado calcular_solo_c(int16_t a_entrada, int16_t b_entrada) {
    Resultado r = {0};
    if (a_entrada == INT16_MIN || b_entrada == INT16_MIN) {
        r.entrada_invalida = true;
        return r;
    }

    int32_t a = absoluto_q15(a_entrada);
    int32_t b = absoluto_q15(b_entrada);
    if (a == 0 || b == 0) {
        r.mcd = (int16_t)(a == 0 ? b : a);
        return r;
    }

    int32_t original_a = a;
    int32_t original_b = b;
    while (a != b) {
        r.iter_mcd++;
        if (a > b) a -= b;
        else b -= a;
    }
    r.mcd = (int16_t)a;

    int32_t temporal = original_a;
    int32_t cociente = 0;
    while (temporal > 0) {
        r.iter_div++;
        temporal -= a;
        cociente++;
    }

    for (int32_t i = 0; i < cociente; ++i) {
        r.iter_mul++;
        r.mcm_exacto += original_b;
        if (r.mcm_exacto > INT16_MAX) r.overflow = true;
    }
    r.mcm = (int16_t)(uint16_t)r.mcm_exacto;
    return r;
}

static void ejecutar_instruccion(LC3 *vm) {
    uint16_t instruccion = vm->memoria[vm->pc++];
    unsigned opcode = instruccion >> 12;
    vm->instrucciones++;
    vm->por_opcode[opcode]++;

    switch (opcode) {
    case OP_BR:
        if (((instruccion >> 9) & 7u) & vm->condicion)
            vm->pc = (uint16_t)(vm->pc + extender(instruccion & 0x1FFu, 9));
        break;
    case OP_ADD: {
        unsigned dr = (instruccion >> 9) & 7u, sr1 = (instruccion >> 6) & 7u;
        vm->registros[dr] = (uint16_t)(vm->registros[sr1] +
            (((instruccion >> 5) & 1u) ? extender(instruccion & 0x1Fu, 5)
                                        : vm->registros[instruccion & 7u]));
        actualizar_condicion(vm, dr);
        break;
    }
    case OP_LD: {
        unsigned dr = (instruccion >> 9) & 7u;
        vm->registros[dr] = vm->memoria[(uint16_t)(vm->pc + extender(instruccion & 0x1FFu, 9))];
        actualizar_condicion(vm, dr);
        break;
    }
    case OP_ST:
        vm->memoria[(uint16_t)(vm->pc + extender(instruccion & 0x1FFu, 9))] =
            vm->registros[(instruccion >> 9) & 7u];
        break;
    case OP_AND: {
        unsigned dr = (instruccion >> 9) & 7u, sr1 = (instruccion >> 6) & 7u;
        vm->registros[dr] = vm->registros[sr1] &
            (((instruccion >> 5) & 1u) ? extender(instruccion & 0x1Fu, 5)
                                        : vm->registros[instruccion & 7u]);
        actualizar_condicion(vm, dr);
        break;
    }
    case OP_NOT: {
        unsigned dr = (instruccion >> 9) & 7u, sr = (instruccion >> 6) & 7u;
        vm->registros[dr] = (uint16_t)~vm->registros[sr];
        actualizar_condicion(vm, dr);
        break;
    }
    case OP_TRAP:
        if ((instruccion & 0xFFu) == 0x25u) vm->ejecutando = false;
        break;
    default:
        fprintf(stderr, "Opcode no soportado en PC x%04X\n", (unsigned)(vm->pc - 1u));
        vm->ejecutando = false;
        break;
    }
}

/* Segunda funcion principal: simula el programa autonomo LC-3 hasta HALT. */
static Resultado ejecutar_programa_lc3(int16_t a, int16_t b, uint64_t *cantidad,
                                      uint64_t por_opcode[16], bool *termino) {
    LC3 vm = {0};
    size_t palabras = sizeof(PROGRAMA_AUTONOMO) / sizeof(PROGRAMA_AUTONOMO[0]);
    memcpy(&vm.memoria[ORIGEN], PROGRAMA_AUTONOMO, sizeof(PROGRAMA_AUTONOMO));
    vm.memoria[DIRECCION_DATO_A] = (uint16_t)a;
    vm.memoria[DIRECCION_DATO_B] = (uint16_t)b;
    vm.pc = ORIGEN;
    vm.condicion = FLAG_ZERO;
    vm.ejecutando = true;

    while (vm.ejecutando && vm.instrucciones < LIMITE_INSTRUCCIONES)
        ejecutar_instruccion(&vm);

    Resultado r = {0};
    r.mcd = (int16_t)vm.memoria[DIRECCION_RESULTADO_MCD];
    r.mcm = (int16_t)vm.memoria[DIRECCION_RESULTADO_MCM];
    r.overflow = vm.memoria[DIRECCION_FLAG_OVERFLOW] != 0;
    *cantidad = vm.instrucciones;
    *termino = !vm.ejecutando;
    memcpy(por_opcode, vm.por_opcode, sizeof(vm.por_opcode));
    (void)palabras;
    return r;
}

static void imprimir_resultado(const char *titulo, Resultado r) {
    printf("%s\n", titulo);
    if (r.entrada_invalida) {
        printf("  Entrada invalida: -32768 esta fuera de Q15.0.\n");
        return;
    }
    printf("  MCD = %d | MCM = %d", r.mcd, r.mcm);
    if (r.overflow) printf(" | OVERFLOW (exacto: %d)", r.mcm_exacto);
    putchar('\n');
    printf("  Iteraciones MCD/DIV/MUL = %u/%u/%u\n",
           r.iter_mcd, r.iter_div, r.iter_mul);
}

static void imprimir_opcodes(const uint64_t por_opcode[16]) {
    for (unsigned i = 0; i < 16; ++i)
        if (por_opcode[i]) printf("  %-9s: %llu\n", NOMBRE_OPCODE[i],
                                  (unsigned long long)por_opcode[i]);
}

static bool iguales(Resultado a, Resultado b) {
    return a.entrada_invalida == b.entrada_invalida &&
           a.mcd == b.mcd && a.mcm == b.mcm &&
           a.overflow == b.overflow;
}

static int ejecutar_pruebas(void) {
    unsigned total = 0, fallas = 0;
    for (int a = -32767; a <= 32767; a += 257) {
        for (int b = -32767; b <= 32767; b += 263) {
            uint64_t inst, opcodes[16];
            bool termino;
            Resultado c = calcular_solo_c((int16_t)a, (int16_t)b);
            Resultado lc3 = ejecutar_programa_lc3((int16_t)a, (int16_t)b,
                                                   &inst, opcodes, &termino);
            total++;
            if (!termino || !iguales(c, lc3)) fallas++;
        }
    }
    printf("Pruebas: %u | fallas: %u\n", total, fallas);
    return fallas == 0 ? EXIT_SUCCESS : EXIT_FAILURE;
}

int main(int argc, char **argv) {
    if (argc > 1 && strcmp(argv[1], "--test") == 0)
        return ejecutar_pruebas();

    int a, b;
    printf("Ingrese dos enteros A y B: ");
    if (scanf("%d %d", &a, &b) != 2 ||
        a < INT16_MIN || a > INT16_MAX || b < INT16_MIN || b > INT16_MAX) {
        fprintf(stderr, "Entrada invalida: use enteros de 16 bits.\n");
        return EXIT_FAILURE;
    }

    Resultado solo_c = calcular_solo_c((int16_t)a, (int16_t)b);
    uint64_t instrucciones, opcodes[16];
    bool termino;
    Resultado lc3 = ejecutar_programa_lc3((int16_t)a, (int16_t)b,
                                          &instrucciones, opcodes, &termino);

    imprimir_resultado("\n=== 1. LOGICA EN C ===", solo_c);
    imprimir_resultado("\n=== 2. LC-3 SIMULADO ===", lc3);
    printf("  Terminacion: %s\n", termino ? "HALT" : "limite de instrucciones");
    printf("  Instrucciones ejecutadas: %llu\n",
           (unsigned long long)instrucciones);
    printf("  Comparacion C vs LC-3: %s\n",
           (termino && iguales(solo_c, lc3)) ? "EXACTA" : "DISCREPANCIA");
    imprimir_opcodes(opcodes);
    return (termino && iguales(solo_c, lc3)) ? EXIT_SUCCESS : EXIT_FAILURE;
}