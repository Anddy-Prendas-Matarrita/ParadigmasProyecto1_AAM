program metrics_stage
    implicit none

    integer :: io_status
    integer :: record_count, i, pos, inicio
    character(len=250) :: line_buffer
    real, allocatable :: temperatura(:), precipitacion(:), viento(:), bateria(:)
    real :: temp_prom, temp_max, temp_min
    real :: precip_total
    real :: viento_prom, viento_max
    real :: bateria_prom

    record_count = 0

    open(unit=10, file='../data/middle/norm_data.csv', status='old', action='read', iostat=io_status)

    if (io_status /= 0) then
        open(unit=10, file='data/middle/norm_data.csv', status='old', action='read', iostat=io_status)
    end if

    if (io_status /= 0) then
        print *, "Error: No se pudo abrir norm_data.csv. Revisa si BASIC-256 genero el archivo."
        stop
    end if

    ! norm_data.csv NO tiene encabezado (ver contracts.md) - no se descarta ninguna linea

    ! --- contar registros validos (ignorando lineas en blanco) ---
    do
        read(10, '(A)', iostat=io_status) line_buffer
        if (io_status /= 0) exit
        if (len_trim(line_buffer) == 0) cycle
        record_count = record_count + 1
    end do

    if (record_count == 0) then
        print *, "Advertencia: El archivo esta vacio o no contiene datos validos."
        close(10)
        stop
    end if

    ! --- reservar espacio para guardar los 4 valores numericos por fila ---
    allocate(temperatura(record_count))
    allocate(precipitacion(record_count))
    allocate(viento(record_count))
    allocate(bateria(record_count))

    ! --- volver al inicio y leer los valores reales ---
    rewind(10)

    i = 0
    do while (i < record_count)
        read(10, '(A)', iostat=io_status) line_buffer
        if (io_status /= 0) exit
        if (len_trim(line_buffer) == 0) cycle

        i = i + 1

        ! separar la linea en 6 campos: ID,ESTACION,TEMP,PRECIP,VIENTO,BATERIA
        inicio = 1
        block
            character(len=50) :: campos(6)
            integer :: j
            do j = 1, 5
                pos = index(line_buffer(inicio:), ",")
                campos(j) = line_buffer(inicio:inicio+pos-2)
                inicio = inicio + pos
            end do
            campos(6) = line_buffer(inicio:)

            read(campos(3), *) temperatura(i)
            read(campos(4), *) precipitacion(i)
            read(campos(5), *) viento(i)
            read(campos(6), *) bateria(i)
        end block
    end do

    close(10)

    print *, "Informacion de BASIC-256 leida correctamente."
    print *, "Total de registros recibidos: ", record_count

    ! --- calculos ---
    temp_prom = promedio(temperatura, record_count)
    temp_max  = valor_maximo(temperatura, record_count)
    temp_min  = valor_minimo(temperatura, record_count)

    precip_total = total(precipitacion, record_count)

    viento_prom = promedio(viento, record_count)
    viento_max  = valor_maximo(viento, record_count)

    bateria_prom = promedio(bateria, record_count)

    ! --- escribir metrics.csv en formato clave-valor (ver contracts.md) ---
    open(unit=20, file='data/middle/metrics.csv', status='replace', action='write')
    write(20, '(A)') "Metric,Value"
    write(20, '(A,I0)')    "Total_Processed_Records,", record_count
    write(20, '(A,F0.2)')  "Total_Precipitation,", precip_total
    write(20, '(A,F0.2)')  "Average_Temperature,", temp_prom
    write(20, '(A,F0.2)')  "Max_Temperature,", temp_max
    write(20, '(A,F0.2)')  "Min_Temperature,", temp_min
    write(20, '(A,F0.2)')  "Average_Wind_Speed,", viento_prom
    write(20, '(A,F0.2)')  "Max_Wind_Speed,", viento_max
    write(20, '(A,F0.2)')  "Average_Battery_Level,", bateria_prom
    close(20)

    print *, "Resultados guardados en metrics.csv"

contains

    !Calcula el promedio de un arreglo de valores
    function promedio(datos, n) result(prom)
        real, intent(in) :: datos(:)
        integer, intent(in) :: n
        real :: prom
        real :: suma
        integer :: k

        suma = 0.0
        do k = 1, n
            suma = suma + datos(k)
        end do
        prom = suma / n
    end function promedio

    !Calcula la suma total de un arreglo de valores (acumulado)
    function total(datos, n) result(suma_total)
        real, intent(in) :: datos(:)
        integer, intent(in) :: n
        real :: suma_total
        integer :: k

        suma_total = 0.0
        do k = 1, n
            suma_total = suma_total + datos(k)
        end do
    end function total

    !Encuentra el valor mas alto dentro de un arreglo
    function valor_maximo(datos, n) result(vmax)
        real, intent(in) :: datos(:)
        integer, intent(in) :: n
        real :: vmax
        integer :: k

        vmax = datos(1)
        do k = 2, n
            if (datos(k) > vmax) then
                vmax = datos(k)
            end if
        end do
    end function valor_maximo

    !Encuentra el valor mas bajo dentro de un arreglo
    function valor_minimo(datos, n) result(vmin)
        real, intent(in) :: datos(:)
        integer, intent(in) :: n
        real :: vmin
        integer :: k

        vmin = datos(1)
        do k = 2, n
            if (datos(k) < vmin) then
                vmin = datos(k)
            end if
        end do
    end function valor_minimo

end program metrics_stage