with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Handlers;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;

procedure Chat_Server_2 is
	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;

	Argument_Error: exception;

	Puerto: Integer;
	Max_Clientes: Integer;
	Nombre_Servidor : ASU.Unbounded_String;
	IP_Servidor : ASU.Unbounded_String;
	Server_EP : LLU.End_Point_Type;
	Comando: Character;

	function Time_Image (T: Ada.Calendar.Time) return String is
		begin
			return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");
	end Time_Image;

	procedure Datos_EP (EP: in LLU.End_Point_Type; IP: out ASU.Unbounded_String; Puerto: out ASU.Unbounded_String) is
		String_EP: ASU.Unbounded_String;
		Indx: Natural;
	begin -- Datos_EP
		String_EP := ASU.To_Unbounded_String(LLU.Image(EP));
		String_EP := ASU.Tail(String_EP, 23);
		Indx := ASU.Index(String_EP, ",");
		IP := ASU.Head(String_EP, Indx-1);
		String_EP := ASU.Tail(String_EP, ASU.Length(String_EP)-Indx);
		Puerto := ASU.Tail(String_EP, 5);
	end Datos_EP;

	procedure Mostrar_Activos (M : Handlers.Active_Lists.Map) is
		C: Handlers.Active_Lists.Cursor := Handlers.Active_Lists.First(M);
		IP, Puerto: ASU.Unbounded_String;
	begin -- Mostrar_Activos
		while Handlers.Active_Lists.Has_Element(C) loop
				Datos_EP(Handlers.Active_Lists.Element(C).Value.End_Point, IP, Puerto);
				Ada.Text_IO.Put_Line (	ASU.To_String(Handlers.Active_Lists.Element(C).Key) & " (" & ASU.To_String(IP) & ":" 
										& ASU.To_String(Puerto) & "): " & Time_Image(Handlers.Active_Lists.Element(C).Value.Time));
				Handlers.Active_Lists.Next(C);
		end loop;
	end Mostrar_Activos;

	procedure Mostrar_Antiguos (M : Handlers.Old_Lists.Map) is
		C: Handlers.Old_Lists.Cursor := Handlers.Old_Lists.First(M);
		IP, Puerto: ASU.Unbounded_String;
	begin -- Mostrar_Antiguos
		while Handlers.Old_Lists.Has_Element(C) loop
			Ada.Text_IO.Put_Line (	ASU.To_String(Handlers.Old_Lists.Element(C).Key) & ": " &
									Time_Image(Handlers.Old_Lists.Element(C).Value));
			Handlers.Old_Lists.Next(C);
		end loop;
	end Mostrar_Antiguos;

begin -- Chat_Server_2
	
	if (ACL.Argument_Count = 2) then
		if (Integer'Value(ACL.Argument(2))>1) and (Integer'Value(ACL.Argument(2))<51) then
			Puerto := Integer'Value(ACL.Argument(1));
			Max_Clientes := Integer'Value(ACL.Argument(2));
			Nombre_Servidor := ASU.To_Unbounded_String(LLU.Get_Host_Name);
			IP_Servidor := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Nombre_Servidor)));
			Server_EP := LLU.Build (ASU.To_String(IP_Servidor), Puerto);
			LLU.Bind (Server_EP, Handlers.Server_Handler'Access);
			loop
				Ada.Text_IO.Get_Immediate(Comando);
				if Comando = 'l' or Comando = 'L' then
					Ada.Text_IO.Put_Line("ACTIVE CLIENTS");
					Ada.Text_IO.Put_Line("==============");
					Mostrar_Activos(Handlers.Activos);
					Ada.Text_IO.New_Line;
				elsif Comando = 'o' or Comando = 'O' then
					Ada.Text_IO.Put_Line("OLD CLIENTS");
					Ada.Text_IO.Put_Line("===========");
					Mostrar_Antiguos(Handlers.Antiguos);
					Ada.Text_IO.New_Line;
				end if;
			end loop;
		else
			raise Argument_Error;
		end if;
	else
		raise Argument_Error;
	end if;
	exception 
		when Argument_Error =>
			Ada.Text_IO.Put_Line("Use: ");
			Ada.Text_IO.Put_Line("       " & ACL.Command_Name & "  Puerto  Numero_de_clientes_(entre_2_y_50)");
			LLU.Finalize;
end Chat_Server_2;