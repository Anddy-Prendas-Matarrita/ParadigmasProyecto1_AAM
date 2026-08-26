program metrics_stage
    implicit none

    integer :: io_status
    integer :: record_count
    character(len=250) :: line_buffer, header

    record_count = 0

    ! 1. Intentar abrir desde la subcarpeta phase2
    open(unit=10, file='../data/middle/norm_data.csv', status='old', action='read', iostat=io_status)

    ! Si falla, intentar abrir desde la raiz del proyecto
    if (io_status /= 0) then
        open(unit=10, file='data/middle/norm_data.csv', status='old', action='read', iostat=io_status)
    end if

    if (io_status /= 0) then
        print *, "Error: No se pudo abrir norm_data.csv. Revisa si BASIC-256 genero el archivo."
        stop
    end if

    ! Leer y descartar la linea de encabezado
    read(10, '(A)', iostat=io_status) header

    ! 2. Leer registros linea por linea
    do
        read(10, '(A)', iostat=io_status) line_buffer
        if (io_status /= 0) exit ! Fin del archivo

        record_count = record_count + 1
    end do
    close(10)

    ! 3. Confirmacion de lectura
    if (record_count > 0) then
        print *, "Informacion de BASIC-256 leida correctamente."
        print *, "Total de registros recibidos: ", record_count
        print *, "Listo para empezar con los calculos."
    else
        print *, "Advertencia: El archivo esta vacio o no contiene datos validos."
    end if

end program metrics_stage