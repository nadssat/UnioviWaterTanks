
(*BLOQUE FUNCIONAL DEL TANQUE: MOVE ALL FLUID*)
(*=================================================================================*)


(*DESCRIPCIÓN: Bloque funcional que a partir de dos tanques se encarga de comprobar
que se cumplen las restricciones locales de funcionamiento, es decir,
que el tanque que cede o GuestTank tenga fluido y que el tanque que recive o
HostTank no este al maximo de su capacidad.
Ademas a partir del conocimiento del esquema de conexiones del sistema
implementamos un codigo encargado de asignar a cada tanque las conexiones
con las valvulas correspondientes para el movimiento de fluido adecuado
Para realizar esto, se ha codificado el tanque con un numero identificador
que podemos encontrar en la estructura llamada DataType. La codi*)
VAR_INPUT
Enable : BOOL; (*Condicion de funcionamiento en el nivel mas exterior del bloque*)
Permiso : BOOL; (*Condicion de funcionamiento local*)
Iniciar : bool; (*Condicion de inicio del proceso*)
Finalizar : bool; (*Condicion de finalizacion del proceso*)
TDone : Real; (*Tiempo de establecimiento de la señal de finalizacion*)
END_VAR

var_IN_OUT
GuestTank : DT_Tank; (*Data Type del tanque que cede fluido,*)
HostTank : DT_Tank; (*Data Type del tanque que recive el fluido*)
END_VAR

VAR_OUTPUT
MSG : STRING; (*Muestra mensajes de informacion relevante para el sistema*)
OUT_Comand_V1 : bool; (*Gobierna la valvula V1 en los estados de ON/OFF*)
OUT_Comand_V2 : bool; (*Gobierna la valvula V2 en los estados de ON/OFF*)
OUT_Comand_V3 : bool; (*Gobierna la valvula V3 en los estados de ON/OFF*)
OUT_Comand_V4 : bool; (*Gobierna la valvula V4 en los estados de ON/OFF*)
OUT_Comand_V5_1 : bool; (*Gobierna la valvula V5.1 en los estados de ON/OFF*)
OUT_Comand_V5_2 : bool; (*Gobierna la valvula V5.2 en los estados de ON/OFF*)
OUT_Power_B2 : Real;(*Fija la potencia aplicada al actuador*)

Done : bool; (*Señal que indica cuando ha finalizado la accion*)
END_VAR

var
EmptyAllTank : FB_TankBasic;
END_VAR

(*CODIGO DE FUNCIONAMIENTO*)
(*=================================================================================*)
EmptyAllTank (Enable := Enable,
              Permiso := GuestTank.Max and not HostTank.Max,
              Iniciar := Iniciar,
              Finalizar := not GuestTank.Min or HostTank.Min,
              TDone := TDone);

(*Independientemente del Deposito que se este llenando, señalamos
el cambio en los estados de los dos depositos*)
GuestTank.State := 'Vaciandose';
HostTank.State := 'Llenandose';


(*GESTION DE CONEXION DE LAS VALVULAS*)
(******************************************************************************)

(*Conexiones del DEPOSITO SUPERIOR*)

IF GuestTank.Identifier := 0 THEN
  CASE HostTank.Identifier OF
    1: (*Conexion Deposito Superior con Tanque Principal*)
      MSG := '(DS -> TP) Fluyendo'
      OUT_Comand_V1 := EmptyAllTank.OUT_Comand;
      OUT_Comand_V2 := FALSE
      OUT_Comand_V3 := FALSE;
      OUT_Comand_V4 := FALSE;
      OUT_Comand_V5_1 := FALSE;
      OUT_Comand_V5_2 := FALSE;
      OUT_Power_B2 := 0.0; // En este caso la Bomba no funciona

    2: (*Conexion Deposito Superior con Deposito Inferior 'pasando por TP'*)
    (*Como pasa por TP podria ser necesario tener en cuenta el nivel del tanque
     pero si lo asimilamos a una tuberia, ya que le llega fluido y sale de el con
     el mismo caudal el nivel del tanque queda invariable y es como si existiese
     una tuberia que conecta los dos depositos*)
      MSG := '(DS -> TP -> DI) Fluyendo'
      OUT_Comand_V1 := EmptyAllTank.OUT_Comand;
      OUT_Comand_V2 := EmptyAllTank.OUT_Comand;
      OUT_Comand_V3 := FALSE;
      OUT_Comand_V4 := FALSE;
      OUT_Comand_V5_1 := FALSE;
      OUT_Comand_V5_2 := FALSE;
      OUT_Power_B2 := 0.0; // En este caso la Bomba no funciona

  END_CASE;
END_IF;

(*Conexiones del TANQUE PRINCIPAL*)

IF GuestTank.Identifier := 1 THEN
  CASE HostTank.Identifier OF
    0: (*Conexion Tanque Principal con Deposito Superior*)
    MSG := '(TP -> DS) Fluyendo'
    OUT_Comand_V1 := FALSE;
    OUT_Comand_V2 := FALSE;
    OUT_Comand_V3 := EmptyAllTank.OUT_Comand;
    OUT_Comand_V4 := FALSE;
    OUT_Comand_V5_1 := FALSE;
    OUT_Comand_V5_2 := EmptyAllTank.OUT_Comand;
    OUT_Power_B2 := HostTank.Power; // Fijamos la potencia de la bomba segun HostTank

    2: (*Conexion Tanque Principal con Deposito Inferior*)
    MSG := '(TP -> DI) Fluyendo'
    OUT_Comand_V1 := FALSE;
    OUT_Comand_V2 := EmptyAllTank.OUT_Comand;
    OUT_Comand_V3 := FALSE;
    OUT_Comand_V4 := FALSE;
    OUT_Comand_V5_1 := FALSE;
    OUT_Comand_V5_2 := FALSE;
    OUT_Power_B2 := 0.0; // En este caso la Bomba no funciona

  END_CASE;
END_IF;

(*Conexiones del DEPOSITO INFERIOR*)

IF GuestTank.Identifier := 2 THEN
  CASE HostTank.Identifier OF
    0: (*Conexion Deposito Inferior con Deposito Superior*)
    MSG := '(DI -> DS) Fluyendo'
    OUT_Comand_V1 := FALSE;
    OUT_Comand_V2 := FALSE;
    OUT_Comand_V3 := FALSE;
    OUT_Comand_V4 := EmptyAllTank.OUT_Comand;
    OUT_Comand_V5_1 := FALSE;
    OUT_Comand_V5_2 := EmptyAllTank.OUT_Comand;
    OUT_Power_B2 := HostTank.Power; // Fijamos la potencia de la bomba segun HostTank

    1: (*Conexion Deposito Inferior con Tanque Principal*)
    MSG := '(DI -> TP) Fluyendo'
    OUT_Comand_V1 := FALSE;
    OUT_Comand_V2 := FALSE;
    OUT_Comand_V3 := FALSE;
    OUT_Comand_V4 := EmptyAllTank.OUT_Comand;
    OUT_Comand_V5_1 := EmptyAllTank.OUT_Comand;
    OUT_Comand_V5_2 := FALSE;
    OUT_Power_B2 := HostTank.Power; // Fijamos la potencia de la bomba segun HostTank

  END_CASE;
END_IF;
