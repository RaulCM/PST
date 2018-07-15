--RAUL CANO MONTERO
with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Strings.Maps;
with Ada.Command_Line;
with Ada.Exceptions;
with Ada.IO_Exceptions;
with Word_Lists;
with Ada.Characters.Handling;

procedure Words is

	package ASU renames Ada.Strings.Unbounded;
	package ACL renames Ada.Command_Line;
	package ACH renames Ada.Characters.Handling;
	
	type Cell;

	type Word_List_Type is access Cell;

	type Cell is record
		Word: ASU.Unbounded_String;
		Count: Natural := 0;
		Next: Word_List_Type;
	end record;

	Usage_Error: exception;

	File_Name: ASU.Unbounded_String;
	File: Ada.Text_IO.File_Type;

	Finish: Boolean;
	Line: ASU.Unbounded_String;
	P_Lista: Word_Lists.Word_List_Type;
	Palabra_Elegida: ASU.Unbounded_String;
	Frecuencia : Natural := 0;
	

	procedure Trocear (Linea : in out ASU.Unbounded_String) is
	
		Indx: Natural;
		Palabra: ASU.Unbounded_String;
		Long: Natural;
	begin -- Trocear
		
		Indx := 1;
		Long := ASU.Length(Linea);
		while Indx /= 0 and Long /= 0 loop
			Indx := ASU.Index(Linea, Ada.Strings.Maps.To_Set(" ,.-"));
			if Indx = 0 then
				Palabra := Linea;
				Word_Lists.Add_Word(P_Lista, Palabra);
			elsif Indx = 1 then
				Linea := ASU.Tail(Linea, ASU.Length(Linea)-Indx);
			else
				Palabra := ASU.Head (Linea, Indx-1);
				Word_Lists.Add_Word(P_Lista, Palabra);
				Linea := ASU.Tail(Linea, ASU.Length(Linea)-Indx);
			end if;
			Long := ASU.Length(Linea);
		end loop;		
	end Trocear;

	procedure Menu is

		Option : Integer;
		Salir : Boolean := False;
		
	begin -- Menu
		loop
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put_Line("Options");
			Ada.Text_IO.Put_Line("1 Add word");
			Ada.Text_IO.Put_Line("2 Delete word");
			Ada.Text_IO.Put_Line("3 Search word");
			Ada.Text_IO.Put_Line("4 Show all words");
			Ada.Text_IO.Put_Line("5 Quit");
			Ada.Text_IO.New_Line;
			Ada.Text_IO.Put("Your option? ");
			Option := Integer'Value(Ada.Text_IO.Get_Line);
			Ada.Text_IO.New_Line;
			Salir := False;

			case Option is
				when 1 =>
					Ada.Text_IO.Put("Word? ");
					Palabra_Elegida := ASU.To_Unbounded_String(ACH.To_Lower(Ada.Text_IO.Get_Line));
					Word_Lists.Add_Word(P_Lista, Palabra_Elegida);
					Ada.Text_IO.Put_Line("Word |" & ASU.To_String(Palabra_Elegida) & "| added");

				when 2 =>
					Ada.Text_IO.Put("Word? ");
					Palabra_Elegida := ASU.To_Unbounded_String(ACH.To_Lower(Ada.Text_IO.Get_Line));
					Word_Lists.Delete_Word(P_Lista, Palabra_Elegida);
				when 3 =>
					Ada.Text_IO.Put("Word? ");
					Palabra_Elegida := ASU.To_Unbounded_String(ACH.To_Lower(Ada.Text_IO.Get_Line));
					Word_Lists.Search_Word(P_Lista, Palabra_Elegida, Frecuencia);
					if Frecuencia > 0 then
						Ada.Text_IO.Put_Line("|" & ASU.To_String(Palabra_Elegida) & "| - " & Natural'Image(Frecuencia));
					elsif Frecuencia = 0 then
						Ada.Text_IO.Put_Line("No such word");
					end if;
				when 4 =>
					Word_Lists.Print_All(P_Lista);
				when 5 =>
					Word_Lists.Max_Word(P_Lista, Palabra_Elegida, Frecuencia);
					if Frecuencia > 0 then
						Ada.Text_IO.Put_Line("The most frequent word: |" & ASU.To_String(Palabra_Elegida) & "| - " & Natural'Image(Frecuencia));
						Ada.Text_IO.New_Line;
					end if;
					Word_Lists.Delete_List(P_Lista);
					Salir := True;
				when others =>
					Ada.Text_IO.Put_Line("Introduzca una opcion entre 1 y 5");
			end case;
			exit when Salir = True;
		end loop;
	end Menu;

begin -- Words

	if ACL.Argument_Count < 1 or ACL.Argument_Count > 2 then		--Si el numero de argumentos introducidos es menor a 1 o mayor a 2,
	    raise Usage_Error;											--se eleva la excepcion Usage_Error
	end if;
	if ACL.Argument_Count = 1 then									--Si solo se introduce un argumento, este debe ser el nombre de un fichero, por lo que se lee el nombre del fichero.
		File_Name := ASU.To_Unbounded_String(ACL.Argument(1));		--Si el fichero no existe, se eleva la excepcion ADA.IO_EXCEPTIONS.NAME_ERROR.
	elsif ACL.Argument_Count = 2 then								--Si se introducen dos argumentos, el primero debe ser -i y, si no lo es
		if ACL.Argument(1) /= "-i" then								--se eleva la excepcion Usage_Error.
			raise Usage_Error;
		end if;
		File_Name := ASU.To_Unbounded_String(ACL.Argument(2));		--El segundo argumento debe ser el nombre de un fichero.
	else
		raise Usage_Error;
	end if;

	Ada.Text_IO.Open(File, Ada.Text_IO.In_File, ASU.To_String(File_Name));

	Finish := False;
	
	while not Finish loop
		begin
			Line := ASU.To_Unbounded_String(ACH.To_Lower(Ada.Text_IO.Get_Line(File))); --Pasa el fichero a la variable Line
			Trocear(Line); --Pasa Line al procedimiento Trocear, que se encargará de separar el string en palabras.

		exception
			when Ada.IO_Exceptions.End_Error =>
			Finish := True;
		end;
	end loop;

	Ada.Text_IO.Close(File);

	if ACL.Argument_Count = 1 then
		Word_Lists.Max_Word(P_Lista, Palabra_Elegida, Frecuencia);
		Ada.Text_IO.Put_Line("The most frequent word: |" & ASU.To_String(Palabra_Elegida) & "| - " & Natural'Image(Frecuencia));
		Ada.Text_IO.New_Line;
		Ada.Text_IO.New_Line;
	elsif ACL.Argument_Count = 2 then
		if ACL.Argument(1) = "-i" then
			Menu;
			Ada.Text_IO.New_Line;
		end if;
	end if;

	exception

		when Usage_Error =>
			Ada.Text_IO.Put_Line("usage: words [-i] <filename>");
			Ada.Text_IO.New_Line;
		when ADA.IO_EXCEPTIONS.NAME_ERROR =>
			if ACL.Argument_Count = 1 then
				if ACL.Argument(1) = "-i" then
					Ada.Text_IO.Put_Line("usage: words [-i] <filename>");
					Ada.Text_IO.New_Line;
				else
					Ada.Text_IO.Put_Line(ASU.To_String(File_Name) & ": file not found");
					Ada.Text_IO.New_Line;
				end if;
			elsif ACL.Argument_Count = 2 then
				Ada.Text_IO.Put_Line(ASU.To_String(File_Name) & ": file not found");
				Menu;
			end if;
end Words;