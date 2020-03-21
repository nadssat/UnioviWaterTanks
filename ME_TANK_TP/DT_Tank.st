
TYPE DT_TANK :
STRUCT

Identifier : REAL; (**)
(*Entradas y salidas fisicas del tanque*)

// Temp_TP := REAL; // Temperatura instantanea del bloque
Nivel : REAL; // Nivel instantaneo del bloque

Maximo : BOOL; // Sensor de nivel maximo; Normalmente abierto
Minimo :BOOL; // Sensor de nivel minimo; Normalmente cerradp

V1 : BOOL; // Accionamiento sobre la valvula V1, conecta DS -> TP
V2 : BOOL; // Accionamiento sobre la valvula V2, conecta TP -> DI
V3 : bool; // Accionamiento sobre la valvula V3, conecta TP -> TP // TP -> DS
V5 : BOOL; // Accionamiento sobre la valvula ternaria V3


(*Parametros de funcionamiento*)
Velocity : REAL; (*Velocidad de funcionamiento de la bomba*)
Power : REAL;
(*Parametros de supervisión*)

(*Estados de funcionamiento*)
State : STRING;

END_STRUCT
END_TYPE
