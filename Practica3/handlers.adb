with Ada.Text_IO;

package body Handlers is

	procedure Server_Handler (From : in LLU.End_Point_Type; To : in LLU.End_Point_Type; P_Buffer : access LLU.Buffer_Type) is
		Tipo: CM.Message_Type;
		Client_EP_Receive: LLU.End_Point_Type;
		Client_EP_Handler: LLU.End_Point_Type;
		Nick: ASU.Unbounded_String;
		Comentario: ASU.Unbounded_String;
		Datos: Value_Type;
		Datos_Encontrado: Value_Type;
		Max_Clients: Natural := Integer'Value(Ada.Command_Line.Argument(2));
		Success: Boolean;
		Aceptado: Boolean;
--		C: Active_Lists.Cursor := Active_Lists.First(Activos);
		Tiempo: Ada.Calendar.Time;
		Elegido: ASU.Unbounded_String;

		use type CM.Message_Type;
		use type Ada.Calendar.Time;
		use type LLU.End_Point_Type;

		procedure Enviar (M : Active_Lists.Map) is
			C: Active_Lists.Cursor := Active_Lists.First(M);
		begin
			while Active_Lists.Has_Element(C) loop
				begin
					if ASU.To_String(Active_Lists.Element(C).Key) /= ASU.To_String(Nick) then
						LLU.Send(Active_Lists.Element(C).Value.End_Point, P_Buffer);	
					end if;
					Active_Lists.Next(C);
				exception
					when Active_Lists.No_Element =>
						Active_Lists.Next(C);
				end;
			end loop;
		end Enviar;

	begin -- Server_Handler
		Tipo := CM.Message_Type'Input(P_Buffer);
		if Tipo = CM.Init then
			Client_EP_Receive := LLU.End_Point_Type'Input(P_Buffer);
			Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Datos.End_Point := Client_EP_Handler;
			Datos.Time := Ada.Calendar.Clock;
			Active_Lists.Get(Activos, Nick, Datos_Encontrado, Success);
			if Success then
				Ada.Text_IO.Put_Line ("INIT recieved from " & ASU.To_String(Nick) & ". IGNORED, nick already used");
				Tipo := CM.Welcome;
				Aceptado := False;
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Tipo);
				Boolean'Output(P_Buffer, Aceptado);
				LLU.Send(Client_EP_Receive, P_Buffer);
			else
				Ada.Text_IO.Put_Line ("INIT recieved from " & ASU.To_String(Nick));
				begin
					Active_Lists.Put(Activos, Nick, Datos);
					exception
						when Active_Lists.Full_Map => 
							declare
								C: Active_Lists.Cursor := Active_Lists.First(Activos);
							begin
								Tiempo := Active_Lists.Element(C).Value.Time;
								while Active_Lists.Has_Element(C)loop
									if Tiempo >= Active_Lists.Element(C).Value.Time then
										Tiempo:= Active_Lists.Element(C).Value.Time;
										Elegido:= Active_Lists.Element(C).Key;
										Active_Lists.Next(C);						
									else	
										Active_Lists.Next(C);
									end if;
								end loop;
								Tipo := CM.Server;
								Comentario := ASU.To_Unbounded_String(ASU.To_String(Elegido) & " banned for being idle too long");
								LLU.Reset(P_Buffer.all);
								CM.Message_Type'Output(P_Buffer, Tipo);
								ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
								ASU.Unbounded_String'Output(P_Buffer, Comentario);
								Active_Lists.Get(Activos, Elegido, Datos_Encontrado, Success);
								LLU.Send(Datos_Encontrado.End_Point, P_Buffer);
								Active_Lists.Delete(Activos, Elegido, Success);
								Old_Lists.Put(Antiguos, Elegido, Datos.Time);
								LLU.Reset(P_Buffer.all);
								CM.Message_Type'Output(P_Buffer, Tipo);
								ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
								ASU.Unbounded_String'Output(P_Buffer, Comentario);
								Enviar(Activos);
								Active_Lists.Put(Activos, Nick, Datos);
							end;
				end;
				Tipo := CM.Welcome;
				Aceptado := True;
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Tipo);
				Boolean'Output(P_Buffer, Aceptado);
				LLU.Send(Client_EP_Receive, P_Buffer);
				Tipo := CM.Server;
				Comentario := ASU.To_Unbounded_String(ASU.To_String(Nick) & " joins the chat");
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Tipo);
				ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
				ASU.Unbounded_String'Output(P_Buffer, Comentario);
				Enviar(Activos);
			end if;
		elsif Tipo = CM.Writer then
			Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Comentario := ASU.Unbounded_String'Input(P_Buffer);
			Datos.End_Point := Client_EP_Handler;
			Datos.Time := Ada.Calendar.Clock;
			Active_Lists.Get(Activos, Nick, Datos_Encontrado, Success);
			if Success and Datos_Encontrado.End_Point = Datos.End_Point then
				Ada.Text_IO.Put_Line("WRITER received from " & ASU.To_String(Nick) & ": " & ASU.To_String(Comentario));
				Tipo := CM.Server;
				LLU.Reset(P_Buffer.all);
				CM.Message_Type'Output(P_Buffer, Tipo);
				ASU.Unbounded_String'Output(P_Buffer, Nick);
				ASU.Unbounded_String'Output(P_Buffer, Comentario);
				Enviar(Activos);
			else
				Ada.Text_IO.Put_Line("WRITER received from unknown client. IGNORED");
			end if;
		elsif Tipo = CM.Logout then
			Client_EP_Handler := LLU.End_Point_Type'Input(P_Buffer);
			Nick := ASU.Unbounded_String'Input(P_Buffer);
			Datos.End_Point := Client_EP_Handler;
			Datos.Time := Ada.Calendar.Clock;
			Active_Lists.Get(Activos, Nick, Datos_Encontrado, Success);
			if Success and Datos_Encontrado.End_Point = Datos.End_Point then
				Active_Lists.Delete(Activos, Nick, Success);
				if Success then
					Old_Lists.Put(Antiguos, Nick, Datos.Time);
					Tipo := CM.Server;
					Ada.Text_IO.Put_Line("LOGOUT received from " & ASU.To_String(Nick));
					Comentario := ASU.To_Unbounded_String(ASU.To_String(Nick) & " leaves the chat");
					LLU.Reset(P_Buffer.all);
					CM.Message_Type'Output(P_Buffer, Tipo);
					ASU.Unbounded_String'Output(P_Buffer, ASU.To_Unbounded_String("server"));
					ASU.Unbounded_String'Output(P_Buffer, Comentario);
					Enviar(Activos);
				end if;
			else
				Ada.Text_IO.Put_Line("LOGOUT received from unknown client. IGNORED");
			end if;
		end if;
	end Server_Handler;

	procedure Client_Handler (From : in LLU.End_Point_Type; To : in LLU.End_Point_Type; P_Buffer : access LLU.Buffer_Type) is
		Tipo : CM.Message_Type;
		Nick : ASU.Unbounded_String;
		Comentario : ASU.Unbounded_String;
	begin -- Client_Handler
		Tipo := CM.Message_Type'Input(P_Buffer);
		Nick := ASU.Unbounded_String'Input(P_Buffer);
		Comentario := ASU.Unbounded_String'Input(P_Buffer);
		Ada.Text_IO.New_Line;
		Ada.Text_IO.Put_Line(ASU.To_String(Nick) & ": " & ASU.To_String(Comentario));
		Ada.Text_IO.Put(">> ");
	end Client_Handler;

end Handlers;