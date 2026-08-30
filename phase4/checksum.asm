# ============================================================
# Etapa 4: Verificacion de integridad (MIPS)
# Lee alerts.csv, convierte cada alerta en su valor numerico
# segun la tabla del enunciado, y calcula un checksum:
#
#   checksum = checksum + valor
#   checksum = checksum XOR posicion
#
# Valores: TEMP_ALTA=10  LLUVIA_INTENSA=20  VIENTO_FUERTE=30  BATERIA_BAJA=40
#
# Entrada:  data/middle/alerts.csv
# Salida:   data/output/final_result.txt (un solo numero: el checksum)
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

# ------------------------------------------------------------
# Rutina: main
# Descripcion: punto de entrada. Abre alerts.csv, lee todo su
#              contenido a memoria, y recorre el buffer linea
#              por linea acumulando el checksum.
# Entrada:  ninguna (usa las rutas fijas en .data)
# Salida:   ninguna directa; escribe el resultado en pantalla
#           y en data/output/final_result.txt
# Registros persistentes usados en todo el flujo principal:
#   $s0 = descriptor de archivo de entrada
#   $s1 = descriptor de archivo de salida
#   $s2 = puntero al caracter actual del buffer de entrada
#   $s3 = checksum acumulado
#   $s4 = posicion (contador de alertas procesadas)
#   $s5 = flag: 1 mientras seguimos en la linea de encabezado
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# Bloque: siguiente_linea / copiar_caracteres
# Descripcion: copia caracter por caracter desde el buffer de
#              entrada hacia linea_actual, hasta encontrar un
#              salto de linea o el final del texto. Ignora '\r'
#              para soportar archivos con saltos de linea estilo
#              Windows (CRLF).
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# Bloque: procesar_linea / no_es_encabezado
# Descripcion: descarta la primera linea (encabezado TIPO_ALERTA)
#              sin procesarla, y para las siguientes, identifica
#              a que tipo de alerta corresponde comparando contra
#              las 4 cadenas conocidas.
# ------------------------------------------------------------
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

# ------------------------------------------------------------
# Bloque: acumular
# Descripcion: aplica la formula del checksum sobre el valor
#              de la alerta identificada y la posicion actual.
# ------------------------------------------------------------
acumular:
    add  $s3, $s3, $t8            # checksum = checksum + valor
    xor  $s3, $s3, $s4            # checksum = checksum XOR posicion

verificar_fin_archivo:
    lb   $t9, 0($s2)
    beqz $t9, terminar_lectura
    j    siguiente_linea

# ------------------------------------------------------------
# Bloque: terminar_lectura
# Descripcion: muestra el checksum final en pantalla, lo
#              convierte a texto, y lo escribe en
#              data/output/final_result.txt.
# ------------------------------------------------------------
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


# ------------------------------------------------------------
# Rutina: strcmp
# Descripcion: compara dos strings terminados en '\0', caracter
#              por caracter, para identificar el tipo de alerta.
# Entrada:  $a0 = direccion del primer string
#           $a1 = direccion del segundo string
# Salida:   $v0 = 0 si son iguales, distinto de 0 si son diferentes
# ------------------------------------------------------------
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


# ------------------------------------------------------------
# Rutina: itoa
# Descripcion: convierte un entero no negativo a su
#              representacion en texto decimal, para poder
#              escribirlo como caracteres en final_result.txt.
# Entrada:  $a0 = direccion de memoria donde escribir el texto
#           $a1 = numero entero a convertir
# Salida:   ninguna en registros; escribe el resultado en la
#           direccion indicada por $a0, terminado en '\0'
# ------------------------------------------------------------
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