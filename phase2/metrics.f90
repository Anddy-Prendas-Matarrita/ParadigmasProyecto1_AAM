program metrics_stage
    implicit none

    ! Variables para lectura del archivo
    integer :: io_status, record_count
    character(len=250) :: line_buffer

    ! Arreglos de tamaño estático
    integer, parameter :: MAX_RECORDS = 5000
    real, dimension(MAX_RECORDS) :: temp_data, precip_data, wind_data, battery_data

    ! Variables para lectura por columnas
    character(len=50) :: col1, col2, col3, col4, col5, col6

    ! Variables de salida
    real :: total_precip
    real :: avg_temp, max_temp, min_temp
    real :: avg_wind, max_wind
    real :: avg_battery

    record_count = 0

    ! 1. Intentar abrir el archivo de datos normalizados
    open(unit=10, file='../data/middle/norm_data.csv', status='old', action='read', iostat=io_status)
    if (io_status /= 0) then
        open(unit=10, file='data/middle/norm_data.csv', status='old', action='read', iostat=io_status)
    end if

    if (io_status /= 0) then
        print *, "Error: No se pudo abrir norm_data.csv"
        stop
    end if

    ! 2. Lectura directa (SE REMOVIÓ EL READ DEL ENCABEZADO)
    do
        read(10, '(A)', iostat=io_status) line_buffer
        if (io_status /= 0) exit 

        ! Ignorar líneas vacías
        if (len_trim(line_buffer) == 0) cycle

        record_count = record_count + 1
        if (record_count > MAX_RECORDS) exit

        ! Extraer las 6 columnas usando subcadenas delimitadas por comas limpias
        call parse_csv_line(line_buffer, col1, col2, col3, col4, col5, col6)

        ! Convertir cadenas a reales de forma explícita
        read(col3, *) temp_data(record_count)    ! Temp
        read(col4, *) precip_data(record_count)  ! Precip
        read(col5, *) wind_data(record_count)    ! Wind
        read(col6, *) battery_data(record_count) ! Battery
    end do
    close(10)

    ! 3. Cálculos e impresión
    if (record_count > 0) then
        total_precip = accumulated_precipitation(precip_data(1:record_count), record_count)
        avg_temp     = Temperature_Average(temp_data(1:record_count))
        max_temp     = Temperature_Max(temp_data(1:record_count))
        min_temp     = Temperature_Min(temp_data(1:record_count))
        avg_wind     = Temperature_Average(wind_data(1:record_count))
        max_wind     = Temperature_Max(wind_data(1:record_count))
        avg_battery  = Temperature_Average(battery_data(1:record_count))

        print *, "=== INFORMACION PROCESADA EN FORTRAN ==="
        print *, "Total de registros procesados: ", record_count
        print *, "-----------------------------------------------------"
        print *, "Precipitacion acumulada:        ", total_precip
        print *, "Temperatura promedio:          ", avg_temp
        print *, "Temperatura maxima:            ", max_temp
        print *, "Temperatura minima:            ", min_temp
        print *, "Viento promedio:               ", avg_wind
        print *, "Viento maximo:                 ", max_wind
        print *, "Bateria promedio:              ", avg_battery
        print *, "-----------------------------------------------------"

        ! Guardar en CSV
        open(unit=20, file='../data/middle/metrics.csv', status='replace', action='write', iostat=io_status)
        if (io_status /= 0) then
            open(unit=20, file='data/middle/metrics.csv', status='replace', action='write', iostat=io_status)
        end if

        if (io_status == 0) then
            write(20, '(A)') "Metric,Value"
            write(20, '(A,I0)') "Total_Processed_Records,", record_count
            write(20, '(A,F8.2)') "Total_Precipitation,", total_precip
            write(20, '(A,F8.2)') "Average_Temperature,", avg_temp
            write(20, '(A,F8.2)') "Max_Temperature,", max_temp
            write(20, '(A,F8.2)') "Min_Temperature,", min_temp
            write(20, '(A,F8.2)') "Average_Wind_Speed,", avg_wind
            write(20, '(A,F8.2)') "Max_Wind_Speed,", max_wind
            write(20, '(A,F8.2)') "Average_Battery_Level,", avg_battery
            close(20)
            print *, "Resultados guardados en metrics.csv"
        end if
    else
        print *, "Advertencia: El archivo esta vacio o no contiene datos validos."
    end if

contains

    subroutine parse_csv_line(line, c1, c2, c3, c4, c5, c6)
        character(len=*), intent(in) :: line
        character(len=*), intent(out) :: c1, c2, c3, c4, c5, c6
        integer :: p1, p2, p3, p4, p5

        ! Corrección de la búsqueda acumulativa de posiciones relativas
        p1 = index(line, ',')
        p2 = p1 + index(line(p1+1:), ',')
        p3 = p2 + index(line(p2+1:), ',')
        p4 = p3 + index(line(p3+1:), ',')
        p5 = p4 + index(line(p4+1:), ',')

        c1 = line(1:p1-1)
        c2 = line(p1+1:p2-1)
        c3 = line(p2+1:p3-1)
        c4 = line(p3+1:p4-1)
        c5 = line(p4+1:p5-1)
        c6 = line(p5+1:)
    end subroutine parse_csv_line

    function accumulated_precipitation(values, n) result(total)
        implicit none
        integer, intent(in) :: n
        real, dimension(n), intent(in) :: values
        real :: total
        integer :: idx

        total = 0.0
        do idx = 1, n
            total = total + values(idx)
        end do
    end function accumulated_precipitation

    real function Temperature_Average(temperatures)
        implicit none
        real, intent(in) :: temperatures(:)

        if (size(temperatures) == 0) then
            Temperature_Average = 0.0
        else
            Temperature_Average = sum(temperatures) / real(size(temperatures))
        end if
    end function Temperature_Average

    real function Temperature_Max(temperatures)
        implicit none
        real, intent(in) :: temperatures(:)

        if (size(temperatures) == 0) then
            Temperature_Max = -huge(1.0)
        else
            Temperature_Max = maxval(temperatures)
        end if
    end function Temperature_Max

    real function Temperature_Min(temperatures)
        implicit none
        real, intent(in) :: temperatures(:)

        if (size(temperatures) == 0) then
            Temperature_Min = huge(1.0)
        else
            Temperature_Min = minval(temperatures)
        end if
    end function Temperature_Min

end program metrics_stage