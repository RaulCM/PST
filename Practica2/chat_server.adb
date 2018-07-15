--RAUL CANO MONTERO
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Collections;

procedure Chat_Server is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;
	package CC renames Client_Collections;

	Server_EP : LLU.End_Point_Type;
	Client_EP : LLU.End_Point_Type;
	Admin_EP : LLU.End_Point_Type;
	Buffer : aliased LLU.Buffer_Type(1024);
	Nombre_Servidor : ASU.Unbounded_String;
	Puerto : Integer;
	Nick : ASU.Unbounded_String;
	Aux : ASU.Unbounded_String;
	IP_Servidor : ASU.Unbounded_String;
	Tipo : CM.Message_Type;
	Comentario : ASU.Unbounded_String;
	Texto : ASU.Unbounded_String;
	Escritores : CC.Collection_Type;
	Lectores : CC.Collection_Type;
	Unique: Boolean;
	Password : ASU.Unbounded_String;
	Password_Admin : ASU.Unbounded_String;
	Data : ASU.Unbounded_String;
	Stop : Boolean := False;

	Argument_Error: exception;

	use type CM.Message_Type;

begin -- Chat_Server
	if ACL.Argument_Count = 2 then
		Puerto := Integer'Value(ACL.Argument(1));
		Password := ASU.To_Unbounded_String(ACL.Argument(2));
		Nombre_Servidor := ASU.To_Unbounded_String(LLU.Get_Host_Name);
		IP_Servidor := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Nombre_Servidor)));
		Server_EP := LLU.Build (ASU.To_String(IP_Servidor), Puerto);			--Construye un End_Point en una dirección y puerto concretos.
		LLU.Bind (Server_EP);													--Se ata al End_Point para poder recibir en él.
		loop
			LLU.Reset(Buffer);													--Vacía el buffer para ahora recibir en él.
			LLU.Receive (Server_EP, Buffer'Access);								--Espera a recibir algo dirigido al Server_EP.
			Tipo := CM.Message_Type'Input (Buffer'Access);						--Se lee el tipo de mensaje que se recibe.
			if Tipo = CM.Init then												--Si el mensaje es del tipo INIT se entra.
				Client_EP := LLU.End_Point_Type'Input(Buffer'Access);			--Saca el End Point del buffer.
				Nick := ASU.Unbounded_String'Input(Buffer'Access);				--Saca el Nick del buffer.
				
				if ASU.To_String(Nick) = "reader" then										--Si entra un lector.
					Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick));		--Mostramos que se ha recibido un INIT de un lector.
					Unique := False;
					CC.Add_Client(Lectores, Client_EP, Nick, Unique);						--Añadimos el lector a la lista "Lectores".
				else															--Si es un escritor.
					Unique := True;
					begin
					CC.Add_Client(Escritores, Client_EP, Nick, Unique);						--Se añade el escritor a la lista "Escritores".
					Ada.Text_IO.Put_Line("INIT received from " & ASU.To_String(Nick));		--Si no se eleva la excepción, se muestra la recepcion del INIT.
					Tipo := CM.Server;
					Texto := ASU.To_Unbounded_String(ASU.To_String(Nick) & " joins the chat");
					Nick := ASU.To_Unbounded_String("servidor");
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access, Tipo);
					ASU.Unbounded_String'Output(Buffer'Access, Nick);
					ASU.Unbounded_String'Output(Buffer'Access, Texto);
					CC.Send_To_All(Lectores, Buffer'Access);				--Se envía a los lectores un mensaje server indicando la entrada de un escritor.
					exception
						when CC.Client_Collection_Error =>
							Ada.Text_IO.Put_Line ("INIT received from " & ASU.To_String(Nick) & ". IGNORED, nick already used");
					end;
				end if;
			elsif Tipo = CM.Writer then											--Si el mensaje es del tipo WRITER se entra.
				Client_EP := LLU.End_Point_Type'Input(Buffer'Access);			--Se saca el EP del emisario del mensaje.
				Comentario := ASU.Unbounded_String'Input(Buffer'Access);		--Se saca el comentario.
				begin
				Nick := CC.Search_Client(Escritores, Client_EP);				--Se llama a la función Search para que devuelva el nick correspondiente al Client_EP.
				Ada.Text_IO.Put_Line("WRITER received from " & ASU.To_String(Nick) & ": " & ASU.To_String(Comentario));
				Tipo := CM.Server;
				Texto := Comentario;
				LLU.Reset(Buffer);
				CM.Message_Type'Output(Buffer'Access, Tipo);
				ASU.Unbounded_String'Output(Buffer'Access, Nick);
				ASU.Unbounded_String'Output(Buffer'Access, Texto);
				CC.Send_To_All(Lectores, Buffer'Access);
				exception
					when CC.Client_Collection_Error =>
						Ada.Text_IO.Put_Line ("WRITER received from unknown client. IGNORED");
				end;
			elsif Tipo = CM.Collection_Request then
				Admin_EP := LLU.End_Point_Type'Input(Buffer'Access);
				Password_Admin := ASU.Unbounded_String'Input(Buffer'Access);
				if ASU.To_String(Password) = ASU.To_String(Password_Admin) then
					Ada.Text_IO.Put_Line("COLLECTION_REQUEST received");
					Tipo := CM.Collection_Data;
					Data := ASU.To_Unbounded_String(CC.Collection_Image(Escritores));
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access, Tipo);
					ASU.Unbounded_String'Output(Buffer'Access, Data);
					LLU.Send(Admin_EP, Buffer'Access);
					LLU.Reset(Buffer);
				else
					Ada.Text_IO.Put_Line("COLLECTION_REQUEST received. IGNORED, incorrect password");
				end if;
			elsif Tipo = CM.Ban then
				Password_Admin := ASU.Unbounded_String'Input(Buffer'Access);
				Nick := ASU.Unbounded_String'Input(Buffer'Access);
				if ASU.To_String(Password) = ASU.To_String(Password_Admin) then
					begin
						CC.Delete_Client(Escritores, Nick);
						Ada.Text_IO.Put_Line("BAN received for " & ASU.To_String(Nick));
						exception
							when CC.Client_Collection_Error =>
								Ada.Text_IO.Put_Line("BAN received for " & ASU.To_String(Nick) & ". IGNORED, nick not found");
					end;
				else
					Ada.Text_IO.Put_Line("BAN received for " & ASU.To_String(Nick) & ". IGNORED, incorrect password");
				end if;
			elsif Tipo = CM.Shutdown then
				Password_Admin := ASU.Unbounded_String'Input(Buffer'Access);
				if ASU.To_String(Password) = ASU.To_String(Password_Admin) then
					Stop := True;
					Ada.Text_IO.Put_Line("SHUTDOWN received");
				else
					Ada.Text_IO.Put_Line("SHUTDOWN received. IGNORED, incorrect password");
				end if;
			end if;
			LLU.Reset(Buffer);
			exit when Stop = True;
		end loop;
	else
		raise Argument_Error;
	end if;
	LLU.Finalize;

	exception
		when Argument_Error =>
			Ada.Text_IO.Put_Line("Use: ");
			Ada.Text_IO.Put_Line("       " & ACL.Command_Name & "  Puerto  Password");
			LLU.Finalize;
end Chat_Server;