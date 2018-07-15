--RAUL CANO MONTERO
with Lower_Layer_UDP;
with Ada.Strings.Unbounded;
with Ada.Text_IO;
with Ada.Exceptions;
with Ada.Command_Line;
with Chat_Messages;
with Client_Collections;
with Ada.IO_Exceptions;

procedure Chat_Admin is
	package LLU renames Lower_Layer_UDP;
	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package CM renames Chat_Messages;

	Nombre_Servidor : ASU.Unbounded_String;
	Puerto : Integer;
	Password : ASU.Unbounded_String;
	Option : Integer := 0;
	IP_Servidor : ASU.Unbounded_String;
	Server_EP : LLU.End_Point_Type;
	Admin_EP : LLU.End_Point_Type;
	Buffer : aliased LLU.Buffer_Type(1024);
	Tipo : CM.Message_Type;
	Expired : Boolean;
	Data : ASU.Unbounded_String;
	Nick : ASU.Unbounded_String;

	Argument_Error: exception;

begin -- Chat_Admin
	if ACL.Argument_Count = 3 then
		Nombre_Servidor := ASU.To_Unbounded_String(ACL.Argument(1));
		Puerto := Integer'Value(ACL.Argument(2));
		Password := ASU.To_Unbounded_String(ACL.Argument(3));
		IP_Servidor := ASU.To_Unbounded_String(LLU.To_IP(ASU.To_String(Nombre_Servidor)));
		Server_EP := LLU.Build(ASU.To_String(IP_Servidor), Puerto);
		LLU.Bind_Any(Admin_EP);
		while Option /= 4 loop
			Ada.Text_IO.Put_Line("Options");
			Ada.Text_IO.Put_Line("1 Show writers collection");
			Ada.Text_IO.Put_Line("2 Ban writer");
			Ada.Text_IO.Put_Line("3 Shutdown server");
			Ada.Text_IO.Put_Line("4 Quit");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put("Your Option? ");
			Option := Integer'Value(Ada.Text_IO.Get_Line);
			case Option is
				when 1 =>
					Tipo := CM.Collection_Request;
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access, Tipo);
					LLU.End_Point_Type'Output(Buffer'Access, Admin_EP);
					ASU.Unbounded_String'Output(Buffer'Access, Password);
					LLU.Send(Server_EP, Buffer'Access);
					LLU.Reset(Buffer);
					LLU.Receive (Admin_EP, Buffer'Access, 5.0, Expired);
					if Expired = True then
						LLU.Finalize;
					end if;
					Tipo := CM.Message_Type'Input (Buffer'Access);
					Data := ASU.Unbounded_String'Input(Buffer'Access);
					LLU.Reset(Buffer);
					Ada.Text_IO.Put_Line(ASU.To_String(Data));
					Ada.Text_IO.New_Line;
				when 2 =>
					Ada.Text_IO.Put("Nick to ban? ");
					Nick := ASU.To_Unbounded_String(Ada.Text_IO.Get_Line);
					Tipo := CM.Ban;
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access, Tipo);
					ASU.Unbounded_String'Output(Buffer'Access, Password);
					ASU.Unbounded_String'Output(Buffer'Access, Nick);
					LLU.Send(Server_EP, Buffer'Access);
					LLU.Reset(Buffer);
					Ada.Text_IO.New_Line;
				when 3 =>
					Tipo := CM.Shutdown;
					LLU.Reset(Buffer);
					CM.Message_Type'Output(Buffer'Access, Tipo);
					ASU.Unbounded_String'Output(Buffer'Access, Password);
					LLU.Send(Server_EP, Buffer'Access);
					LLU.Reset(Buffer);
					Ada.Text_IO.Put_Line("Server shutdown sent");
					Ada.Text_IO.New_Line;
				when others =>
					null;
			end case;
		end loop;
	else
		raise Argument_Error;
	end if;
	LLU.Finalize;
	exception
		when Argument_Error =>
			Ada.Text_IO.Put_Line("Use: ");
			Ada.Text_IO.Put_Line("       " & ACL.Command_Name & "  Servidor  Puerto  Password");
			LLU.Finalize;
		when ADA.IO_EXCEPTIONS.END_ERROR =>
			null;
end Chat_Admin;