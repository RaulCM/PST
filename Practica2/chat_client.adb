--RAUL CANO MONTERO
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;

procedure Chat_client is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;

	Server_EP : LLU.End_Point_Type;
	Client_EP : LLU.End_Point_Type;
	Buffer : aliased LLU.Buffer_Type(1024);
	Nombre_Servidor : ASU.Unbounded_String;
	Puerto : Integer;
	Nick : ASU.Unbounded_String;
	IP_Servidor : ASU.Unbounded_String;
	Tipo : CM.Message_Type;
	Comentario : ASU.Unbounded_String;
	Texto : ASU.Unbounded_String;

	Argument_Error: exception;

	use type CM.Message_Type;

begin -- Chat_client
	if ACL.Argument_Count = 3 then
		Nombre_Servidor := ASU.To_Unbounded_String(ACL.Argument(1));
		Puerto := Integer'Value(ACL.Argument(2));
		Nick := ASU.To_Unbounded_String(ACL.Argument(3));
		IP_Servidor := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Nombre_Servidor)));
		Server_EP := LLU.Build(ASU.To_String(IP_Servidor), Puerto);			--Construye el End_Point en el que está atado el servidor.
		LLU.Bind_Any(Client_EP);											--Construye un End_Point libre cualquiera y se ata a él.
		LLU.Reset(Buffer);													--Reinicializa el buffer para empezar a utilizarlo.
		Tipo := CM.Init;
		CM.Message_Type'Output(Buffer'Access, Tipo);						--Introduce el tipo de mensaje en el Buffer.
		LLU.End_Point_Type'Output(Buffer'Access, Client_EP);				--Introduce el End_Point del cliente en el Buffer.
		ASU.Unbounded_String'Output(Buffer'Access, Nick);					--Introduce el Unbounded_String en el Buffer.
		LLU.Send(Server_EP, Buffer'Access);									--Envía el mensaje INIT con el End_Point y el Nick al Servidor.
		LLU.Reset(Buffer);													--Resetea el buffer.
		if ASU.To_String(Nick) = "reader" then
			loop
				LLU.Receive (Client_EP, Buffer'Access);
				Tipo := CM.Message_Type'Input(Buffer'Access);
				Nick := ASU.Unbounded_String'Input(Buffer'Access);
				Texto := ASU.Unbounded_String'Input(Buffer'Access);
				Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Texto));
				LLU.Reset(Buffer);
			end loop;
		else
			while ASU.To_String(Comentario) /= ".quit" loop
				Ada.Text_IO.Put("Message: ");
				Comentario := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
				if ASU.To_String(Comentario) /= ".quit" then
					Tipo := CM.Writer;
					CM.Message_Type'Output(Buffer'Access, Tipo);				--Introduce el tipo de mensaje en el Buffer.
					LLU.End_Point_Type'Output(Buffer'Access, Client_EP);		--Introduce el End_Point del cliente en el Buffer.
					ASU.Unbounded_String'Output(Buffer'Access, Comentario);		--Introduce el Unbounded_String en el Buffer.
					LLU.Send(Server_EP, Buffer'Access);							--Envía el contenido del Buffer.
					LLU.Reset(Buffer);											--Vacía el buffer para recibir en él.
				end if;
			end loop;
			LLU.Finalize;
		end if;
	else
		raise Argument_Error;
	end if;

	exception
		when Argument_Error =>
			Ada.Text_IO.Put_Line("Use: ");
			Ada.Text_IO.Put_Line("       " & ACL.Command_Name & "  Servidor  Puerto  Nick");
			LLU.Finalize;

end Chat_client;