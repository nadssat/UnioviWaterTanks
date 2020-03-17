

BLOCK_FUNCTION FB_BASIC
// VARIABLES DE ENTRADA DEL BLOQUE FUNCIONAL
VAR_INPUT
  Enable: Bool; // Permite la funcionalidad del bloque
END_VAR
// VARIABLE BIDIRECCIONAL DE ENTRADA
var_IN_OUT
  Actuador: Bool;
  (*Es la señal de activacion en control manual, puede activarse
  desde dentro y fuera del bloque, es decir, es bidireccional*)
END_VAR

VAR_INPUT
  Permiso: Bool;
  (*Variable para el bloqueo o activacion interna del
  bloque. Ademas de las condiciones fisicas del sistema
  podemos permitir el funcionamiento segun nuestros intereses*)

  SP_Power: REAL;
  Iniciar: BOOL;
  (*Condicion o condiciones fisicas para la activacion del
  bloque funcional*)
  Finalizar: BOOL;
  (*Condicion o condiciones fisicas para la finalizacion del bloque
  funcional*)
  TDone: INT;
  (*Tiempo de permanencia de la señal de finalizacion*)
END_VAR

// VARIABLES DE SALIDA DEL BLOQUE FUNCIONAL
VAR_OUTPUT
  MSG: STRING := '  ';
  (*Variable tipo texto que permite dar indicaciones al
  usuario sobre el estado del sistema*)
  Done: Bool;
  (*Variable de control sobre el actuador, da un 1 cuando deberia
  funcionar y un 0 cuando no*)
  OUT_Power: REAL;
  (*Variable de salida que indica la potencia aplicada sobre el
  actuador, en caso de no ser un actuador de control binario*)
END_VAR

// VARIABLES INTERNAS DEL BLOQUE FUNCIONAL
var
  RS_Act: RS; // Bloque RS, con entradas SET, RESET y salidas RS_Act.Q
  FT_Act: F_TRIG; (*Falling Edge Detection, variables de entrada CLK,
  variables de salida FT_Act.Q; Detecta flancos de bajada en CLK (el
  bloque opuesto es el R_TRIG o Rising Edge Detection)*)
  TP_Done_Act: TP; (*PULSE TIMER, Genera un pulso durante el tiempo especificado
    Como entradas recive IN(activacion) y PT(duracion del pulso) como salidas Q
    y ET(Elapsed time of the pulse o tiempo de duracion del pulso)*)
END_VAR

// CODIGO DEL BLOQUE funcional

  IF Enable THEN // Activacion general del bloque

    MSG := '    '; (*Mensaje*)
    RS_Act (SET1:= Iniciar AND Permiso, RESET1 := Finalizar);
    (*Creamos un bloque RS con activacion mediante la acctivacion sincronizada
    de Iniciar y Permiso. El bloque se resetea mediante finalizar*)

    Actuador := RS_Act.Q1 AND Permiso;
    (*Si la salida del bloque anterior es 1 y Permiso es 1, ejecutamos
    las instrucciones de codigo.IMPORTANTE, si RS_Act.Q1 se hace 0, implica
    que Actuador va a valer cero y esto se vera reflejado en el Data Type*)

    IF Actuador THEN
      MSG:= 'Actuador activado'; // Indicamos que el bloque funciona
      OUT_Power := SP_Power ; // Fijamos la potencia de salida
    ELSE
      OUT_Power := 0.0; // Si Actuador= 0 -> Power = 0
    END_IF

    FT_Act (CLK := Actuador)
    (*Si Actuador = 0 -> NO hay FLANCO; Si Actuador = 1 -> hay FLANCO*)

    TP_Done_Act (IN:= FT_Act.Q ,PT := TO_TIME(T_Done))
    (*Con el flanco generado anteriormente activamos un temporizador
    que tiene por salida 1 hasta que se cumpla el tiempo T_Done*)

    Done:= TP_Done_Act.Q
    (*Done va a valer 1 durante T_Done, hasta que se acabe
    el temporizador*)

    IF Done THEN
      MSG := 'Finalizado';
    END_IF

END_IF;
