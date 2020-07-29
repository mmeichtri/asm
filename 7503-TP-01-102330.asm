;Manejo de Matrices (II)
;Se pide desarrollar un programa en assembler Intel 80x86 que cargue desde teclado una cantidad X
;de matrices (con X <= 5) de NxM elementos (con N y M <= 8) y luego permita realizar las siguientes
;operaciones entre ellas:
;● Resta de 2 o más matrices.
;● Igualdad entre 2 matrices.
;● Multiplicar una matriz por un valor escalar leído desde teclado.
;● Modificar o consultar el valor de un elemento (Mij) de una matriz.
;Nota: Los elementos que componen a cada matriz (Mij) son números enteros entre -99 y 99

global main
extern printf
extern sscanf
extern puts
extern gets

section .data
    msjIngDimensiones db "Indique la dimension que desea que tengan las matrices,fila, y columna en un rango de 1 a 8 ",10,0
    msjIngValorMatriz db "Ingrese el valor que quiere ingresar a la matriz, dentro del rango -99, y 99 ", 10, 0
    msjFueraRango db "El valor ingresado, no se encuentra dentro del rango ", 10, 0
    msjValorIngresadoMatriz db "Se guardo correctamente el valor %hhi en la matriz", 10, 0
    menuOpciones db "Opciones: 1- Obtener la resta de ambas matrices, 2- Obtener la igualdad entre matrices, 3- Multiplicar una matriz por un valor escalar, 4- Modificar o consultar el valor de una posicion", 10, 0
    msjColModificar db "Ingrese la columna que quiere modificar", 10, 0
    msjFilModificar db "Ingrese la fila que quiere modificar", 10, 0 
    msjPedirValorEscalar db "Ingrese por el valor que quiere multiplicar", 10, 0
    msjNuevoIngreso db "Indique el valor que quiere guardar en la posicion", 10, 0
    msjMatriz1 db "Va a completar los datos de la matriz 1", 10, 0
    msjMatriz2 db "Va a completar los datos de la matriz 2", 10, 0 
    msjValorModificado db "Se modifico la posicion de la matriz 1, luego de realizar la multiplicacion por el escalar indicado, su valor ahora es de %hhi", 10, 0
    msjPosModificada db "Se modifico correctamente el dato de la columna %hhi fila %hhi, por el valor %hhi", 10, 0
    msjResultadoResta db "El resultado de restar en la posicion columna %hhi, fila %hhi es de %hhi", 10, 0
    msjHayCoincidencia db "Las matrices coinciden", 10, 0
    formatDimensionFilCol dq "%hhi %hhi",0
    formatValor dq "%hhi", 0
    matriz times 320 dq 0
    desplazamiento dq "%hhi", 0
    desplazAuxiliar dq 0
    contador dq 0
    contadorPosMatriz dq 0
    format dq "%hhi", 0
    escalar dq 0
    msjNoHayCoincidencia dq "No existe igualdad entre matrices", 10

section .bss
    plusRsp resq 1
    dimensionFilCol resq 50
    inputValor resq 50
    inputValido resq 1 ;'S' valido, 'N' invalido
    valor resq 1
    dimensionFil resq 1
    dimensionCol resq 1
    desplazamientoMatriz resq 1
    opcionElegidaUsuario resq 1
    opcionElegida resq 1
    valorEscalar resq 1
    filYColModificar resq 1
    modificarFil resq 1
    modificarCol resq 1
    finIngresoMatriz resq 1
    valorNuevo resq 1
    valorNuevoInt resq 1
    inicioMatriz2 resq 1
    tamanioMatriz resq 1
    multiplicarPorValor resq 1
    cantidadElementos resq 1
    ColModificar resq 1
    FilModificar resq 1
    contadorColumnas resq 1
    contadorFilas resq 1
    contarCoincidencias resq 1

section .text
main:
    sub rsp, 8

pedirDimensionMatrices:

    mov rdi,msjIngDimensiones
    call printf

    mov rdi,dimensionFilCol
    call gets

    call validarFyC

    cmp qword[inputValido],"N" ;si es igual a N -> no es valido lo ingresado
    je pedirDimensionMatrices ;por lo tanto, entra de nuevo a pedirle otra dimension

    mov rdi, [dimensionFil]
    mov rsi, [dimensionCol]
    imul rdi, rsi ;contiene el total de elementos de la matriz 
   
    mov qword[cantidadElementos], rdi
    imul rdi, 8

    mov qword[tamanioMatriz], rdi

    mov rdi, qword[cantidadElementos]

    call calcDesplazamientoMatrizyCargar

    call opcionesUsuario

    add rsp,8
    ret

validarFyC:
    mov qword[inputValido],"N"

    mov rdi,dimensionFilCol
    mov rsi,formatDimensionFilCol
    mov rdx,dimensionFil
    mov rcx,dimensionCol
    sub rsp,8
    call sscanf
    add rsp,8

    cmp rax,2
    jl invalido

    cmp qword[dimensionFil],1
    jl invalido
    cmp qword[dimensionFil],8
    jg invalido

    cmp qword[dimensionCol],1
    jl invalido
    cmp qword[dimensionCol],8
    jg invalido

    mov qword[inputValido],"S"

invalido:
    ret

calcDesplazamientoMatrizyCargar:
    mov qword[inicioMatriz2], rdi ;guardo el desplazamiento original de la matriz 
    imul rdi, 2 ;multiplico x2 ya que utilice, usar dos matrices, por lo tanto, si tenia que cada matriz, era de 2x3
	;entonces, rdi, va a contener 12. e inicioMatriz va a contener 6
    mov qword[desplazamientoMatriz], rdi ;guardo el desplazamiento total (12) de la matriz en una variable

    mov rdi, msjMatriz1
    call puts

guardarDato:
    call pedirValorPosicion
    call guardarValorMatriz
	
    sub qword[desplazamientoMatriz], 1 ;resta en uno el deplazamiento de la matriz, es decir, que pase a 11, si estaba en la pos 12
    mov rdi, qword[inicioMatriz2] ;me guardo en una varuable inicioMatriz, qye seria 6, para luego realizar la comparacion, y si son iguales, entonces
	;va a pasar a completar los datos de la matriz2
    cmp qword[desplazamientoMatriz], rdi
    je matriz2
    cmp qword[desplazamientoMatriz], 0
    jg guardarDato ;si es mayor a cero, entonces, no llego al ultimo elemento de la matriz, por lo tanto, continua iterando
    mov qword[finIngresoMatriz], 'S'

    jmp fin

matriz2:
    mov rdi, msjMatriz2
    call puts
    jmp guardarDato

fin:
    ret
    
opcionesUsuario:
    mov rdi, menuOpciones
    sub rsp, 8
    call printf
    add rsp, 8  

    mov rdi, opcionElegidaUsuario
    call gets

    mov rdi, opcionElegidaUsuario
    mov rsi, formatValor
    mov rdx, opcionElegida   
    call checkAlign
	sub rsp,[plusRsp]
	call sscanf
	add rsp,[plusRsp]

    call validarEleccion
	cmp qword[inputValido], 'N'
	je opcionesUsuario
	
	cmp qword[opcionElegida], 1
	je restaMatrices
	cmp qword[opcionElegida], 2
	je igualdadMatrices
	cmp qword[opcionElegida], 3
	je multiplicarMatriz
	cmp qword[opcionElegida], 4
	je modificarPosMatriz

    ret

restaMatrices:
    mov qword[contadorColumnas], 0
    mov qword[contadorFilas], 0
    mov qword[desplazamientoMatriz], 0
    mov rbx, qword[tamanioMatriz]

realizarResta:
    mov r9, qword[desplazamientoMatriz]
    mov r8, [matriz + r9] 
    mov rcx, [matriz + rbx + r9]

    sub r8, rcx

    mov rdi, msjResultadoResta
    mov rsi, qword[contadorColumnas]
    mov rdx, qword[contadorFilas]
    mov rcx, r8
    mov rax, 0
    sub rsp, 8
    call printf
    add rsp, 8

    add qword[desplazamientoMatriz], 8
    add qword[contadorFilas], 1
    mov r10, qword[dimensionFil]
    cmp qword[contadorFilas], r10
    jl realizarResta

incrementarColumna:
    mov qword[contadorFilas], 0
    add qword[contadorColumnas], 1
    mov r10, qword[dimensionCol]
    cmp qword[contadorColumnas], r10
    jl realizarResta

finResta:
    ret

igualdadMatrices:
    mov rbx, qword[tamanioMatriz]
    mov qword[desplazamientoMatriz], 0

realizarComparacion:
    mov r9, qword[desplazamientoMatriz]
    mov r8, [matriz + r9]
    mov rcx, [matriz + rbx + r9]

    cmp r8, rcx
    jne matricesDistintas

    add qword[desplazamientoMatriz], 8
    add qword[contadorFilas], 1
    mov r10, qword[dimensionFil]
    cmp qword[contadorFilas], r10
    jne realizarComparacion

incrementarColumnaComparacion:
    mov qword[contadorFilas], 0
    add qword[contadorColumnas], 1
    mov r10, qword[dimensionCol]
    cmp qword[contadorColumnas], r10
    jl realizarComparacion

finVerificarCoincidencias:
    mov rdi, msjHayCoincidencia
    call puts
    ret

matricesDistintas:
    mov rdi, msjNoHayCoincidencia
    call puts
    jmp finCoincidencias

finCoincidencias:
    ret

multiplicarMatriz:
    mov rdi, msjPedirValorEscalar
    call puts
    mov rdi, multiplicarPorValor
    call gets

    mov rdi, multiplicarPorValor
	mov rsi, format
	mov rdx, escalar
	call checkAlign
	sub rsp,[plusRsp]
	call sscanf
	add rsp,[plusRsp]

cantidadIteracion:
    mov r9, 0
    mov rbx, qword[tamanioMatriz]

realizarMultiplicacion:
    mov rdx, [matriz + r9] 
    imul rdx, [escalar]

    call mostrarModificacionMultiplicacion

    add r9, 8
    cmp r9, rbx
    jl realizarMultiplicacion

    ret

mostrarModificacionMultiplicacion:
    mov rdi, msjValorModificado
    mov rsi, rdx
    push r9
    sub rsp, 8
    call printf
    add rsp, 8
    pop r9
    ret

modificarPosMatriz:
    mov rdi, msjColModificar
    sub rsp, 8
    call printf
    add rsp, 8

    mov rdi, ColModificar
    call gets

    mov rdi,ColModificar
    mov rsi,format
    mov rdx, modificarCol
    call checkAlign
    sub rsp,[plusRsp]
    call sscanf
    add rsp,[plusRsp]

    mov rdi, msjFilModificar
    sub rsp, 8
    call printf
    add rsp, 8

    mov rdi, FilModificar
    call gets

    mov rdi, FilModificar
    mov rsi, format
    mov rdx, modificarFil
    call checkAlign
    sub rsp, [plusRsp]
    call sscanf
    add rsp, [plusRsp]

    cmp qword[modificarFil], 1
    jl modificarPosMatriz
    cmp qword[modificarFil], 8
    jg modificarPosMatriz

    cmp qword[modificarCol], 1
    jl modificarPosMatriz
    cmp qword[modificarCol], 8
    jg modificarPosMatriz

pedirNuevoIngresoPosicion:
    mov rdi, msjNuevoIngreso
    sub rsp, 8
    call printf
    add rsp, 8

    mov rdi, valorNuevo
    call gets
    
    mov rdi, valorNuevo
    mov rsi, format
    mov rdx, valorNuevoInt
    call checkAlign
	sub rsp,[plusRsp]
	call sscanf
	add rsp,[plusRsp]

    cmp qword[valorNuevoInt], -99
    jl pedirNuevoIngresoPosicion
    cmp qword[valorNuevoInt], 99
    jg pedirNuevoIngresoPosicion

    mov rdx, qword[modificarFil]
    sub rdx, 1
    imul rdx, qword[dimensionCol]
    imul rdx, 8

    mov rbx, rdx

    mov rdx, [modificarCol]
    sub rdx, 1
    imul rdx, 8

    add rbx, rdx

    mov r9, [valorNuevoInt]
    mov [matriz + rbx], r9

    mov rdi, msjPosModificada
    mov rsi, qword[modificarCol]
    mov rdx, qword[modificarFil]
    mov rcx, qword[valorNuevoInt]
    sub rsp, 8
    call printf
    add rsp, 8

    ret

validarEleccion:
	mov qword[inputValido], 'S'

	cmp qword[opcionElegida], 1
	jl eleccionInvalida
	cmp qword[opcionElegida], 4
	jg eleccionInvalida
	
	jmp finValidacion
	
eleccionInvalida:
	mov qword[inputValido], 'N'
	mov rdi, msjFueraRango
	call puts

finValidacion:
    ret

pedirValorPosicion:     
    mov rdi,msjIngValorMatriz
    call printf

    mov rdi,inputValor
    call gets

    mov rdi, inputValor
    mov rsi, formatValor
    mov rdx, valor    
    call checkAlign
	sub rsp,[plusRsp]
	call sscanf
	add rsp,[plusRsp]   

    call VALINGRESO

    cmp qword[inputValido],"N"
    je pedirValorPosicion


VALINGRESO:
    mov qword[inputValido], 'S'
    cmp qword[valor], -99 ;valido si esta en el rango,ya que cada elemento puede estar entre -99, y 99
    jl valorFueraRango
    cmp qword[valor],99
    jg valorFueraRango

    jmp finValidacionIngreso

valorFueraRango:
    mov qword[inputValido], 'N'
    mov rdi, msjFueraRango
    call puts

finValidacionIngreso:
    ret

guardarValorMatriz:
    mov rdx, qword[valor]

    mov rbx, qword[desplazAuxiliar] ;inicialmente contiene 8, por lo tanto va a estar en la primer pos d ela matriz
    mov [matriz + rbx], rdx

    mov rdi, msjValorIngresadoMatriz
    mov rsi, [matriz + rbx]
    call printf 

    add qword[desplazAuxiliar], 8 ;sumo 8, para que pase al siguiente elemento de la matriz 


checkAlign:
	push rax
	push rbx
	push rdx
	push rdi
	mov qword[plusRsp], 0
	mov rdx, 0
	mov rax, rsp
	add rax, 8 ; para sumar lo que resto la call
	add rax, 32 ; para sumar lo que restaron las push
	mov rbx, 16
	idiv rbx ; rdx: rax / 16 resto queda en rdx
	cmp rdx, 0 ; resto = 0?
	je finCheckAlign
	mov qword[plusRsp], 8

finCheckAlign:
	pop rdi
	pop rdx
	pop rbx
	pop rax
	ret