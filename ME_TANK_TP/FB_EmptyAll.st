
(*BLOQUE FUNCIONAL DEL TANQUE: EMPTY ALL*)
(*=================================================================================*)


(*DESCRIPCIÓN: Bloque funcional que vacia el tanque principal, *)
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
OUT_Power : real; (*Fija la potencia aplicada al actuador*)
OUT_Comand : Bool; (*Gobierna el actuador en los estados de ON/OFF*)
Done : bool; (*Señal que indica cuando ha finalizado la accion*)
END_VAR

var
EmptyAllTank : FB_TankBasic;
END_VAR

(*CODIGO DE FUNCIONAMIENTO*)

EmptyAllTank (Enable := Enable,
              Permiso := GuestTank.Max and not HostTank.Max,
              )
