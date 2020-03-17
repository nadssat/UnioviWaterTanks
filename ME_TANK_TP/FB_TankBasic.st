

(**)

(*BLOQUE FUNCIONAL PARA EL DESARROLLO DE ACCIONES DEL MODULO DE EQUIPAMIENTO TANQUE*)
(*=================================================================================*)

(*DEFINICIÓN DE LAS VARIABLES*)
VAR_INPUT
Enable : BOOL; (*Condicion de funcionamiento en el nivel mas exterior del bloque*)
Permiso : BOOL; (*Condicion de funcionamiento local*)
Iniciar : bool; (*Condicion de inicio del proceso*)
Finalizar : bool; (*Condicion de finalizacion del proceso*)
TDone : Real; (*Tiempo de establecimiento de la señal de finalizacion)
//DI_DS := Bool; (*Seleccion del deposito de Origen/Destino*)
END_VAR

//var_IN_OUT
//Estado := int; (*Indica el estado anterior del modulo de equipamiento*)
//END_VAR

VAR_OUTPUT
MSG : STRING; (*Muestra mensajes de informacion relevante para el sistema*)
OUT_Power : real; (*Fija la potencia aplicada al actuador*)
OUT_Comand : Bool; (*Gobierna el actuador en los estados de ON/OFF*)
Done : bool; (*Señal que indica cuando ha finalizado la accion*)
END_VAR

var
RS_ON_OFF : RS; (*Bloque RS*)
F_EdgeDetection : F_TRIG; (*Falling Edge Detection*)
Fin : TP (*Pulse Timer, donde IN es la activacion y PT la duracion del pulso*)
END_VAR


(*CODIGO DE FUNCIONAMIENTO*)

  IF Enable THEN

    MSG := '    '; (*Mensaje*)
    RS_ON_OFF (SET := Iniciar AND Permiso, RESET := Finalizar)

    Actuador := RS_Act.Q1 AND Permiso;

    if Actuador THEN

      MSG:= 'Actuador activado'; // Indicamos que el bloque funciona
      OUT_Comand := True; (*Encendemos el actuador*)
      OUT_Power := SP_Power ; // Fijamos la potencia de salida

    else
        OUT_Comand := False; (*Actuador apagado*)
        OUT_Power := 0.0; (*Potencia de salida = 0*)

    END_IF

    F_EdgeDetection (CLK:=Actuador);
    (*Generamos un flanco cuando Actuador pasa de 0->1 que nos sirve para
    activar un temporizador de tiempo 'TDone'*)


    Fin (IN:= F_EdgeDetection.Q,PT:=TO_TIME(TDone));
    (*El flanco activa el temporizador 'Fin'*)

    Done := Fin.Q; (*Durante TDone señalaremos con la señal Done que la
      accion ha terminado*)

    if Done THEN
      MSG := 'Finalizado';
    END_IF


    END_IF


  END_IF
