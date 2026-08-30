# ============================================================
# Etapa 4: Verificacion de integridad (MIPS)
# Lee alerts.csv, convierte cada alerta en su valor numerico
# segun la tabla del enunciado, y calcula un checksum:
#
#   checksum = checksum + valor
#   checksum = checksum XOR posicion
#
# Valores: TEMP_ALTA=10  LLUVIA_INTENSA=20  VIENTO_FUERTE=30  BATERIA_BAJA=40
# ============================================================

.data
    ruta_entrada:   .asciiz "data/middle/alerts.csv"
    ruta_salida:    .asciiz "data/output/final_result.txt"

    buffer_entrada: .space 2048
    linea_actual:   .space 64
    buffer_salida:  .space 32
    itoa_temp:      .space 20

    str_temp:       .asciiz "TEMP_ALTA"
    str_lluvia:     .asciiz "LLUVIA_INTENSA"
    str_viento:     .asciiz "VIENTO_FUERTE"
    str_bateria:    .asciiz "BATERIA_BAJA"

    msg_error_abrir:  .asciiz "Error: no se pudo abrir alerts.csv\n"
    msg_checksum:     .asciiz "Checksum final: "
    msg_guardado:     .asciiz "\nResultado guardado en final_result.txt\n"
    salto_linea:      .asciiz "\n"

.text
.globl main

main:
    li   $v0, 13
    la   $a0, ruta_entrada
    li   $a1, 0
    li   $a2, 0
    syscall
    move $s0, $v0
    bltz $s0, error_abrir

    li   $v0, 14
    move $a0, $s0
    la   $a1, buffer_entrada
    li   $a2, 2047
    syscall

    li   $v0, 16
    move $a0, $s0
    syscall

    la   $s2, buffer_entrada
    li   $s3, 0
    li   $s4, 0
    li   $s5, 1

siguiente_linea:
    la   $t4, linea_actual
    move $t5, $t4

copiar_caracteres:
    lb   $t6, 0($s2)
    beqz $t6, fin_de_texto
    beq  $t6, 13, saltar_cr
    beq  $t6, 10, fin_de_linea

    sb   $t6, 0($t4)
    addi $t4, $t4, 1
    addi $s2, $s2, 1
    j    copiar_caracteres

saltar_cr:
    addi $s2, $s2, 1
    j    copiar_caracteres

fin_de_linea:
    addi $s2, $s2, 1
    sb   $zero, 0($t4)
    j    procesar_linea

fin_de_texto:
    sb   $zero, 0($t4)
    beq  $t5, $t4, terminar_lectura

procesar_linea:
    beqz $s5, no_es_encabezado
    li   $s5, 0
    j    verificar_fin_archivo

no_es_encabezado:
    lb   $t7, linea_actual
    beqz $t7, verificar_fin_archivo

    addi $s4, $s4, 1

    la   $a0, linea_actual
    la   $a1, str_temp
    jal  strcmp
    beqz $v0, es_temp_alta

    la   $a0, linea_actual
    la   $a1, str_lluvia
    jal  strcmp
    beqz $v0, es_lluvia

    la   $a0, linea_actual
    la   $a1, str_viento
    jal  strcmp
    beqz $v0, es_viento

    la   $a0, linea_actual
    la   $a1, str_bateria
    jal  strcmp
    beqz $v0, es_bateria

    j    verificar_fin_archivo

es_temp_alta:
    li   $t8, 10
    j    acumular
es_lluvia:
    li   $t8, 20
    j    acumular
es_viento:
    li   $t8, 30
    j    acumular
es_bateria:
    li   $t8, 40

acumular:
    add  $s3, $s3, $t8
    xor  $s3, $s3, $s4

verificar_fin_archivo:
    lb   $t9, 0($s2)
    beqz $t9, terminar_lectura
    j    siguiente_linea

terminar_lectura:
    li   $v0, 4
    la   $a0, msg_checksum
    syscall

    li   $v0, 1
    move $a0, $s3
    syscall

    li   $v0, 4
    la   $a0, salto_linea
    syscall

    la   $a0, buffer_salida
    move $a1, $s3
    jal  itoa

    li   $v0, 13
    la   $a0, ruta_salida
    li   $a1, 1
    li   $a2, 0
    syscall
    move $s1, $v0
    bltz $s1, error_escribir

    li   $v0, 15
    move $a0, $s1
    la   $a1, buffer_salida
    li   $a2, 20
    syscall

    li   $v0, 16
    move $a0, $s1
    syscall

    li   $v0, 4
    la   $a0, msg_guardado
    syscall
    j    salir

error_abrir:
    li   $v0, 4
    la   $a0, msg_error_abrir
    syscall
    j    salir

error_escribir:
    li   $v0, 4
    la   $a0, msg_error_abrir
    syscall

salir:
    li   $v0, 10
    syscall


strcmp:
    lb   $t0, 0($a0)
    lb   $t1, 0($a1)
    bne  $t0, $t1, strcmp_diferente
    beqz $t0, strcmp_igual
    addi $a0, $a0, 1
    addi $a1, $a1, 1
    j    strcmp
strcmp_diferente:
    li   $v0, 1
    jr   $ra
strcmp_igual:
    li   $v0, 0
    jr   $ra


itoa:
    la   $t1, itoa_temp
    li   $t0, 10
    li   $t3, 0

    bnez $a1, itoa_extraer
    li   $t2, 48
    sb   $t2, 0($t1)
    addi $t3, $t3, 1
    j    itoa_copiar

itoa_extraer:
    beqz $a1, itoa_copiar
    div  $a1, $t0
    mfhi $t2
    mflo $a1
    addi $t2, $t2, 48
    add  $t4, $t1, $t3
    sb   $t2, 0($t4)
    addi $t3, $t3, 1
    j    itoa_extraer

itoa_copiar:
    addi $t3, $t3, -1
itoa_copiar_loop:
    bltz $t3, itoa_fin
    add  $t4, $t1, $t3
    lb   $t2, 0($t4)
    sb   $t2, 0($a0)
    addi $a0, $a0, 1
    addi $t3, $t3, -1
    j    itoa_copiar_loop
itoa_fin:
    sb   $zero, 0($a0)
    jr   $ra