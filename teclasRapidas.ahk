#Requires AutoHotkey v2.0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Variables;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(VAR) - TeamViewer - Ruta al ejecutable de TeamViewer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TeamViewer := "C:\Program Files\TeamViewer\TeamViewer.exe"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(VAR) - ImagenFirma - Path a la imagen a usar como firma (puede ser solo el nombre si esta en el mismo directorio) La imagen debe estar en el directorio del script en este caso
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ImagenFirma := "Firma.png"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Funciones;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - SetImageToClipboard(path) - Función que coloca imagen en el portapapeles usado para la firma
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
SetImageToClipboard(path) {
    ; Comando PowerShell en una sola línea
    ps := "powershell.exe -NoProfile -Command Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; [System.Windows.Forms.Clipboard]::SetImage([System.Drawing.Image]::FromFile('" . path . "'))"
    RunWait(ps, ,"Hide")
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - MsgYCopiarImagen(msg) - Función que limpia la respuesta por defecto y coloca el mensaje y el la imagen de firma seleccionada
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MsgYCopiarImagen(msg) {
    BorrarTodoMenosTik()
    Sleep 100
    SendInput msg
    Sleep 1000
    IF FileExist(ImagenFirma) {
        SetImageToClipboard(ImagenFirma)
        Send "^v"
        Sleep 800
        SendInput "{up}{up}"
        Sleep 1700
        SendInput "{left}{up}{up}{up}{up}{up}"
    } ELSE {
        MsgBox "No se encontró: " ImagenFirma
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - Buscar(texto, ruta, extension, incluirSub, guiRef) - Función que busca el texto indicado en la carpeta seleccionada teniendo en cuenta o no las subcarpetas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Buscar(texto, ruta, extension, incluirSub, guiRef) {
    IF (texto = "" || ruta = "") {
        MsgBox("Debes ingresar el texto y la ruta.", "Error", 48)
        return
    }
 
    ; Escapar comillas simples
    texto := StrReplace(texto, "'", "''")
    ruta := StrReplace(ruta, "'", "''")
    
    psCommand := (
        'Get-ChildItem -Path ' . "'" . ruta . "'" . ' -Filter ' . "'" . extension . "'" . (incluirSub ? ' -Recurse ' : ' ') .
        '| SELECT-String -Pattern ' . "'" . texto . "'" . ' | ' .
        'Format-Table Filename, LineNumber, Line -AutoSize'
    )
 
    comando := 'powershell -NoExit -Command "' . psCommand . '"'
    ;SendInput "comando"
    WinActivate("TeamViewer")
    Sleep 200
    Abrir(comando)
    guiRef.Destroy()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - Abrir(comando) - Función para Abrir un comando desde ejecutar
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Abrir(comando){
    SendEvent "{lwin down}r{lwin up}"
    Sleep 600
    Intercambio(comando)
    SendEvent "{enter}"
    return
}
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Para abrir como administrador de windows funciona pero es tedioso hasta para las carpetas lo pide SendEvent "{ctrl down}{shIFt down}{enter}{ctrl up}{shIFt up}"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - Intercambio(clipInter) - Función para enviar con el clipboard un determinado texto para mejorar los tiempos de envío y evitar errores por la velocidad de uso. La misma resguarda el clipboard actual y luego de utilizarlo vuelve a colocar el original para su uso normal
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Intercambio(clipInter) {
    clipOrig := A_Clipboard
    A_Clipboard := clipInter
    while A_Clipboard!=clipInter{
        Sleep 50
    }
    Sleep 50
    SendInput "{control down}{v}{control up}"
    Sleep 50
    A_Clipboard := clipOrig
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - BorrarTodoMenosTik() - Función que limpia la respuesta por defecto dejando solo la linea que indica la URL al TIK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
BorrarTodoMenosTik(){
    SendInput "{control down}{home}{control up}{down}{down}{shIFt down}{down}{shIFt up}"
    SendInput "^c"
    SendInput "{control down}{a}{control up}"
    SendInput "{control down}{shIFt down}{v}{shIFt up}{control up}"
    ;SendInput "{control down}{home}{control up}{shIFt down}{down}{down}{shIFt up}{DELETE}"
    ;SendInput "{down}{control down}{shIFt down}{end}{shIFt up}{control up}{DELETE}"
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - Llamada() - Función que obtiene y formatea el horario para colocar en un archivo de texto un nuevo espacio para anotar datos sobre una Llamada recibida (Guardia)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Llamada(){
    TimeString := FormatTime("R","yyyy-MM-dd HH:mm")
    SendInput "`n" TimeString "`n`n`n------------------------------------------`n"
    SendInput "{up}{up}{up}"
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(FUNC) - Plantilla(momento) - Función que formatea la respuesta a un incidente según un momento recibido (" día", "as tardes", "as noches", Etc)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Plantilla(momento){
    return "`n`nBuen" momento "{!}`n`nQuedo a disposición.`n`nAtentamente`n`n"
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Atajos;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + q - Abrir ID TV seleccionado con Pass1 como contraseña por defecto
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!q:: {
    A_Clipboard := ""
    Send "^c"
    ClipWait
    IF FileExist(TeamViewer){
        Run TeamViewer ' -i "' A_Clipboard '" -P Pass1'
    } ELSE {
        MsgBox "La ruta al ejecutable de TeamViewer no es correcta."
    }
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + w - Administracion de equipos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!w:: Abrir("compmgmt.msc")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + e - Resupuesta Según horario (Hasta las 13 'Buen día', Hasta las 20 'Buenas tardes', Desde las 20 'Buenas noches')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!e:: {
    TimeString := FormatTime("T1","HH")
    IF (TimeString<13) {
        Momento := " día"
    }ELSE{
        IF (TimeString<=19) {
            Momento := "as tardes"
        } ELSE {
            Momento := "as noches"
        }
    }
    MsgYCopiarImagen(Plantilla(Momento))
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + i - Abre un cmd con ipconfig /all
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!i:: Abrir("cmd /K ipconfig /all")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + o - Instalar características de Windows
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!o:: Abrir("OptionalFeatures")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + d - Administrador de dispositivos
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!d:: Abrir("devmgmt.msc")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + r - Adaptadores de Red
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!r:: Abrir("ncpa.cpl")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + s - Servicios de windows ('services.msc')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!s:: Abrir("services.msc")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + p - Dispositivos e Impresoras (incluye W11)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!p:: Abrir("control /name Microsoft.AddHardware")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + u - Cuentas de usuario de windows ('control userpasswords2')
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!u:: Abrir("control userpasswords2")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + a - Aplicaciones y características
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!a:: Abrir("appwiz.cpl")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + b - Pass1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!b:: SendInput "Pass1"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + n - Pass2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!n:: SendInput "Pass2"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + 1 - 'SELECT * FROM '
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!1:: Intercambio ('SELECT * FROM ')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + 2 - UPDATE  set /**/, LastUpdated=GETDATE() WHERE id
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!2:: {
    Intercambio ('UPDATE  set /**/, LastUpdated=GETDATE() WHERE id')
    Send "{ctrl down}{left}{left}{left}{left}{left}{left}{left}{left}{left}{left}{ctrl up}{left}"
    return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + 3 - DELETE  WHERE id
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!3:: {
    Intercambio ('DELETE  WHERE id')
    Send "{ctrl down}{left}{left}{ctrl up}{left}"
    return
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + 5 - EXEC sp_fkeys
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!5:: Send ('EXEC sp_fkeys ')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + 6 - EXEC sp_HelpText
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!6:: Send ('EXEC sp_HelpText ')

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + < - Para generar espacio en el txt donde se anotan las Llamadas
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!<:: {
    Llamada
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Ctrl + Alt + r - Recargar Script (para cambios o errores)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^!r::Reload

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Ctrl + ShIFt + f - Buscar texto en logs de TeamViewer
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^+f:: {
    SendInput "{ctrl down}{c}{ctrl up}"
    Sleep 400
    Path:=A_Clipboard
    SeleccionarCarpeta(*) {
        rutaBox.value := DirSELECT("C:\", 0 , "Seleccionar carpeta")
    }
 
    myGui := Gui()
    myGui.Title := "Buscar en archivos"
 
    myGui.Add("Text", , "Texto a buscar:")
    textoBox := myGui.Add("Edit", "w300")
 
    myGui.Add("Text", "y+10" , "Ruta de carpeta:")
    rutaBox := myGui.Add("Edit", "w260")
    rutaBox.value:=Path
    
    seleccionarBtn := myGui.Add("Button", "x+5 w35", "...")
    seleccionarBtn.OnEvent("Click", SeleccionarCarpeta)
    
    incluirSub := myGui.Add("CheckBox", "x20 y+10" , "Incluir subcarpetas")
    incluirSub.Value := false  ; Por defecto activado

    myGui.Add("Text", "x20 y+15" , "Tipo de archivo:")
    extensionBox := myGui.Add("DropDownList", "Choose4" , ["*.txt", "*.log", "*.csv", "*.*"])
 
    btnBuscar := myGui.Add("Button", "Default x10 y+15 w70", "Buscar").OnEvent("Click", (*) => Buscar(textoBox.Value, rutaBox.Value, extensionBox.Text, incluirSub.Value, myGui))

    cancelarBtn := myGui.Add("Button", "x+10 w70" , "Cancelar")
    cancelarBtn.OnEvent("Click", (*) => myGui.Destroy())

    myGui.OnEvent("Escape", (*) => myGui.Destroy())

    myGui.Show()
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Ctrl + Shift + a - Mostrar lista de atajos en pantalla
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
^+a::{
    rutaScript := A_ScriptFullPath
    if !FileExist(rutaScript) {
        MsgBox("No se pudo leer el script actual.")
        return
    }

    ancho := 1165
    contenido := FileRead(rutaScript, "UTF-8")
    lineas := StrSplit(contenido, "`n")
    atajos := []

    Loop lineas.Length - 2 {
        i := A_Index
        linea := Trim(lineas[i])
        lineaIntermedia := Trim(lineas[i + 1])
        lineaAtajo := Trim(lineas[i + 2])

        if linea ~= "^\s*;\(ATAJO\)\s*-" && lineaAtajo ~= "^[^\s]+::" {
            descripcionCompleta := RegExReplace(linea, "^\s*;\(ATAJO\)\s*-\s*", "")
            tecla := RegExReplace(lineaAtajo, "\s*::.*", "")
            atajos.Push({tecla: tecla, texto: descripcionCompleta})
        }
    }

    ; Crear GUI de 3 columnas
    ventana := Gui("AlwaysOnTop Resize", "Listado de Atajos")
    ventana.SetFont("s14 w700", "Segoe UI")
    ventana.AddText("x0 w" ancho " Center", "Atajos definidos (Ctrl + Shift + a para abrir esta lista):")
    ventana.SetFont("s8 w0", "Segoe UI")

    columnas := 4
    espacioX := 290
    fila := 50
    columnaActual := 0

    for i, item in atajos {
        x := 10 + (columnaActual * espacioX)
        atajo := SubStr(item.texto,1,InStr(item.texto,"-")-2)
        descripcion := SubStr(item.texto,InStr(item.texto,"-")+2)
        if (InStr(descripcion,"-")=1){
            descripcion := SubStr(descripcion,3)
            atajo := atajo " -"
        }
        ventana.SetFont("s10 w700", "Segoe UI")
        ventana.AddText("x" x " y" fila " w280", atajo)
        ventana.SetFont("s8 w0", "Segoe UI")
        ventana.AddText("x" x " y" fila+18 " r2 w280", descripcion)
        columnaActual := Mod(columnaActual + 1, columnas)
        if columnaActual = 0
            fila += 45
    }

    ventana.SetFont("s10 w700", "Segoe UI")
    ventana.AddText("x10 y" fila+55, "Presione Escape para salir")

    ventana.OnEvent("Escape", (*) => ventana.Destroy())
    ventana.Show("w" ancho " h" . (fila + 80))
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;Pruebas;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;(ATAJO) - Alt + g - (Prueba) Envío de whatsapp seleccionando el número de teléfono, tomando el numero del incidente
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
!g:: {
    A_Clipboard:=""
    SendInput "{ctrl down}{c}{ctrl up}"
    ClipWait
    cadena := RegExReplace(A_Clipboard, "\D")
    cadena := RegExReplace(cadena, "^0*")
    ;MsgBox(cadena)
    incidente := RegExReplace(WinGetTitle("A"), "\D")
    abrir("https://wa.me/" cadena "?text=Buen%20día!%20Como%20estás?%20Te%20escribo%20por%20el%20incidente%20" incidente "!%20")
}