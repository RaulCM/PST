with Ada.Text_IO;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;
with Chat_Messages;
with Handlers;

procedure Chat_client_2 is
	package ACL renames Ada.Command_Line;
	package ASU renames Ada.Strings.Unbounded;
	package LLU renames Lower_Layer_UDP;
	package CM renames Chat_Messages;

	Argument_Error: exception;

	Nombre_Servidor: ASU.Unbounded_String;
	Nick: ASU.Unbounded_String;
	IP_Servidor: ASU.Unbounded_String;
	Comentario: ASU.Unbounded_String;
	Puerto: Integer;
	Server_EP: LLU.End_Point_Type;
	Client_EP_Receive: LLU.End_Point_Type;
	Client_EP_Handler: LLU.End_Point_Type;
	Buffer: aliased LLU.Buffer_Type(1024);
	Expired: Boolean := False;
	Aceptado: Boolean;
	Stop: Boolean := False;
	Tipo: CM.Message_Type;

	use type CM.Message_Type;
begin -- Chat_client_2
	if ACL.Argument_Count = 3 then
		Nombre_Servidor := ASU.To_Unbounded_String(ACL.Argument(1));		--Se saca el nombre del servidor de la linea de argumentos.
		Puerto := Integer'Value(ACL.Argument(2));							--Se saca el puerto de la linea de argumentos.
		Nick := ASU.To_Unbounded_String(ACL.Argument(3));					--Se saca el nick de la linea de argumentos.
		IP_Servidor := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Nombre_Servidor)));
		
		Server_EP := LLU.Build(ASU.To_String(IP_Servidor), Puerto);

		LLU.Bind_Any(Client_EP_Receive);									--Construye un End_Point libre cualquiera y se ata a él.
		LLU.Bind_Any(Client_EP_Handler, Handlers.Client_Handler'Access);
	-- Envio del mensaje INIT.
		LLU.Reset(Buffer);
		CM.Message_Type'Output(Buffer'Access, CM.Init);
		LLU.End_Point_type'Output(Buffer'Access, Client_EP_Receive);
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
		ASU.Unbounded_String'Output(Buffer'Access, Nick); 
		LLU.Send(Server_EP, Buffer'Access);
	-- Recepcion del mensaje WELCOME.
		LLU.Reset(Buffer);
		LLU.Receive(Client_EP_Receive, Buffer'Access, 10.0, Expired);
		if Expired then
			Ada.Text_IO.Put_Line("Server unreachable");
			LLU.Finalize;
		else
			Tipo := CM.Message_Type'Input(Buffer'Access);
			if Tipo = CM.Welcome then
				Aceptado := Boolean'Input(Buffer'Access);
				if Aceptado then
					Ada.Text_IO.Put_Line("Mini-Chat v2.0: Welcome " & ASU.To_String(Nick));
					loop
						Ada.Text_IO.Put(">> ");
						Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
						if ASU.To_String(Comentario) /= ".quit" then
						-- Envio del mensaje WRITER
							Tipo := CM.Writer;
							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access, Tipo);
							LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
							ASU.Unbounded_String'Output(Buffer'Access, Nick);
							ASU.Unbounded_String'Output(Buffer'Access, Comentario);
							LLU.Send(Server_EP, Buffer'Access);
							LLU.Reset(Buffer);
						else
						-- Envio del mensaje LOGOUT
							Tipo := CM.Logout;
							LLU.Reset(Buffer);
							CM.Message_Type'Output(Buffer'Access, Tipo);
							LLU.End_Point_Type'Output(Buffer'Access, Client_EP_Handler);
							ASU.Unbounded_String'Output(Buffer'Access, Nick);
							LLU.Send(Server_EP, Buffer'Access);
							Stop := True;
						end if;
						exit when Stop = True;
					end loop;
				else
					Ada.Text_IO.Put_Line("Mini-Chat v2.0: IGNORED new user " & ASU.To_String(Nick) & ", nick already used");
				end if;
			end if;
		end if;
	else
		raise Argument_Error;
	end if;
	LLU.Finalize;
	exception 
		when Argument_Error =>
			Ada.Text_IO.Put_Line("Use: ");
			Ada.Text_IO.Put_Line("       " & ACL.Command_Name & "  Servidor  Puerto  Nick");
			LLU.Finalize;
end Chat_client_2;