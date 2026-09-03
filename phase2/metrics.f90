program metrics_stage
    implicit none
    integer :: io_status, record_count, i, pos, inicio
    character(len=250) :: line_buffer
    real, allocatable :: temperatura(:), precipitacion(:), viento(:), bateria(:)
    real :: temp_prom, temp_max, temp_min, precip_total, viento_prom, viento_max, bateria_prom

    record_count = 0

    open(unit=10, file='C:/Users/alenc/OneDrive/Escritorio/ParadigmasProyecto1_AAM/data/middle/norm_data.csv', status='old', action='read', form='formatted', iostat=io_status)

    if (io_status /= 0) then
        write(*,*) "Error: No se pudo abrir norm_data.csv"
        stop 1
    end if

    do
        read(10, '(A)', iostat=io_status) line_buffer
        if (io_status /= 0) exit
        if (len_trim(adjustl(line_buffer)) == 0) cycle
        record_count = record_count + 1
    end do

    if (record_count == 0) then
        write(*,*) "Archivo vacio"
        close(10)
        stop 1
    end if

    allocate(temperatura(record_count), precipitacion(record_count), viento(record_count), bateria(record_count))
    rewind(10)
    i = 0

    do while (i < record_count)
        read(10, '(A)', iostat=io_status) line_buffer
        if (io_status /= 0) exit
        if (len_trim(adjustl(line_buffer)) == 0) cycle
        i = i + 1
        block
            character(len=50) :: c(6)
            integer :: j
            inicio = 1
            do j = 1, 5
                pos = index(line_buffer(inicio:), ",")
                c(j) = line_buffer(inicio:inicio+pos-2)
                inicio = inicio + pos
            end do
            c(6) = trim(line_buffer(inicio:))
            read(c(3), *) temperatura(i)
            read(c(4), *) precipitacion(i)
            read(c(5), *) viento(i)
            read(c(6), *) bateria(i)
        end block
    end do
    close(10)

    write(*,*) "Datos leidos:", record_count, "registros"

    temp_prom    = sum(temperatura)  / record_count
    temp_max     = maxval(temperatura)
    temp_min     = minval(temperatura)
    precip_total = sum(precipitacion)
    viento_prom  = sum(viento)       / record_count
    viento_max   = maxval(viento)
    bateria_prom = sum(bateria)      / record_count

    open(unit=20, file='C:/Users/alenc/OneDrive/Escritorio/ParadigmasProyecto1_AAM/data/middle/metrics.csv', status='replace', action='write', iostat=io_status)
    if (io_status /= 0) then
        write(*,*) "Error escribiendo metrics.csv"
        stop 1
    end if

    write(20,'(A)') "Metric,Value"
    write(20,'(A,I0)')   "Total_Processed_Records,", record_count
    write(20,'(A,F0.2)') "Total_Precipitation,",     precip_total
    write(20,'(A,F0.2)') "Average_Temperature,",     temp_prom
    write(20,'(A,F0.2)') "Max_Temperature,",         temp_max
    write(20,'(A,F0.2)') "Min_Temperature,",         temp_min
    write(20,'(A,F0.2)') "Average_Wind_Speed,",      viento_prom
    write(20,'(A,F0.2)') "Max_Wind_Speed,",          viento_max
    write(20,'(A,F0.2)') "Average_Battery_Level,",   bateria_prom
    close(20)

    write(*,*) "metrics.csv generado OK"

end program metrics_stage
