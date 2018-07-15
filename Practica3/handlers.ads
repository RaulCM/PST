with Chat_Messages;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Maps_G;
with Ada.Calendar;
with Ada.Command_Line;

package Handlers is
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;

	type Value_Type is record
		End_Point: LLU.End_Point_Type;
		Time: Ada.Calendar.Time;
	end record;

	Max_Client: Natural:= Natural'Value(Ada.Command_Line.Argument(2));
	Max_Old: Natural := 150;

	package Active_Lists is new Maps_G (ASU.Unbounded_String, 
										Value_Type, 
										Max_Client,
										"=" => ASU."=");

	package Old_Lists is new Maps_G (	ASU.Unbounded_String, 
										Ada.Calendar.Time,
										Max_Old,
										"=" => ASU."=");

	Activos: Active_Lists.Map;
	Antiguos: Old_Lists.Map;



	-- Handler para utilizar como parámetro en LLU.Bind en el servidor
	-- Muestra en pantalla la cadena de texto recibida y responde enviando
	--   la cadena "¡Bienvenido!"
	-- Este procedimiento NO debe llamarse explícitamente
	procedure Server_Handler (	From	: in		LLU.End_Point_Type;
								To 		: in		LLU.End_Point_Type;
								P_Buffer: access	LLU.Buffer_Type);


   -- Handler para utilizar como parámetro en LLU.Bind en el cliente
   -- Muestra en pantalla la cadena de texto recibida
   -- Este procedimiento NO debe llamarse explícitamente
	procedure Client_Handler (	From	: in		LLU.End_Point_Type;
								To 		: in		LLU.End_Point_Type;
								P_Buffer: access	LLU.Buffer_Type);
end Handlers;