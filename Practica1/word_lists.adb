--RAUL CANO MONTERO
with Ada.Text_IO;
with Ada.Unchecked_Deallocation;
package body Word_Lists  is
	procedure Free is new Ada.Unchecked_Deallocation(Cell, Word_List_Type);
	P_Ultimo: Word_List_Type;

	procedure Add_Word (List: in out Word_List_Type; Word: in ASU.Unbounded_String) is
		P_Aux, P_Aux2: Word_List_Type;
		Stop : Boolean := False;
	begin -- Add_Word
		if List = null then 					--Si la lista está vacía 
			List := new Cell;					--se crea la primera celda,
			List.Word := Word;					--se almacena la primera palabra en ella
			List.Count := List.Count + 1;		--y se pone el contador a 1 (inicialmente estaba a 0).
			P_Ultimo := List;
		else									--Si la lista tiene ya un primer elemento creado
			P_Aux := List;
			if ASU.To_String(P_Aux.Word) = ASU.To_String(Word) then		--Si la palabra es igual a la primera palabra de la lista
				P_Aux.Count := P_Aux.Count + 1;							--Se aumenta el contador en 1.
			else						--Si la palabra es distinta a la primera palabra almacenada en la lista.
				loop
					if P_Aux.Next = null then		--Si no hay mas celdas en la lista
						P_Aux2 := new Cell;			--se crea una nueva celda,
						P_Aux.Next := P_Aux2;
						P_Aux := P_Aux2;
						P_Aux.Word := Word;			--se almacena la palabra en la nueva celda,
						P_Aux.Count := 1;			--se pone el contador a 1
						P_Ultimo := P_Aux;
						Stop := True;				--y se sale del bucle
					else							--Si hay más celdas en la lista, se
						P_Aux2 := P_Aux.Next;		--recorre la lista hasta encontrar
						P_Aux := P_Aux2;			--una palabra igual a la introducida.
						if ASU.To_String(P_Aux.Word) = ASU.To_String(Word) then
							P_Aux.Count := P_Aux.Count + 1;		--Una vez encontrada se aumenta
							Stop := True;						--el contador en 1 y sale del bucle.
						end if;
					end if;
					exit when Stop = True;
				end loop;
			end if;
		end if;
	end Add_Word;

	procedure Delete_Word (List: in out Word_List_Type; Word: in ASU.Unbounded_String) is
		P_Aux, P_Aux2: Word_List_Type;
		Stop : Boolean := False;
	begin -- Delete_Word
		if List = null then
			raise Word_List_Error;
		end if;
		P_Aux := List;
		if ASU.To_String(P_Aux.Word) = ASU.To_String(Word) then
			P_Aux2 := P_Aux.Next;				--Si la palabra buscada es la primera de
			Free(List);							--la lista se libera el espacio en memoria
			P_Aux := P_Aux2;					--que ocupa y se hace que List apunte a
			List:= P_Aux;						--la siguiente celda de la lista.
			Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) & "| deleted");
		else
			P_Aux2 := P_Aux.Next;		--Si la palabra buscada no es la primera,
			loop						--se pasa a la celda siguiente
				if ASU.To_String(P_Aux2.Word) = ASU.To_String(Word) then
					P_Aux.Next := P_Aux2.Next;	--Si la palabra está en esa celda, se hace
					Free(P_Aux2);				--que la celda anterior apunte a la siguiente
					P_Aux2 := P_Aux;			--se libera la memoria ocupada por esa celda
					Ada.Text_IO.Put_Line("|" & ASU.To_String(Word) & "| deleted");
					Stop := True;				--y se sale del bucle.
				else
					P_Aux := P_Aux2;			--Si la palabra no está en la celda se sigue
					P_Aux2 := P_Aux.Next;		--recorriendo la lista.
					if P_Aux2 = null then		--Si se llega al final de la lista sin haber
						raise Word_List_Error;	--encontrado la palabra, se eleva Word_List_Error
					end if;
				end if;
				exit when Stop = True;
			end loop;
		end if;
		exception
			when Word_List_Error =>
				Ada.Text_IO.Put_Line("No such word");
	end Delete_Word;

	procedure Search_Word (List: in Word_List_Type; Word: in ASU.Unbounded_String; Count: out Natural) is
		P_Aux, P_Aux2 : Word_List_Type;
		Stop : Boolean := False;
	begin --Search_Word
		P_Aux := List;
		if List = null then
			Count := 0;
		elsif ASU.To_String(P_Aux.Word) = ASU.To_String(Word) then		--Si la palabra buscada es la primera
			Count := P_Aux.Count;									--se devuelve el count de esa celda.
		else
			P_Aux2 := P_Aux.Next;				--Si no es la primera, se sigue recorriendo la lista.
			P_Aux := P_Aux2;
			loop
				if ASU.To_String(P_Aux.Word) = ASU.To_String(Word) then		--Cuando se encuentra la palabra
					Count := P_Aux.Count;									--se devuelve su count.
					Stop := True;
				else
					P_Aux2 := P_Aux.Next;		--Si no se encuentra la palabra se
					P_Aux := P_Aux2;			--sigue recorriendo la lista.
					if P_Aux = null then		--Si se llega al final de la lista
						Count := 0;				--sin encontrar la palabra, 
						Stop := True;			--se devuelve un 0.
					end if;
				end if;
				exit when Stop = True;
			end loop;
		end if;
	end Search_Word;

	procedure Max_Word (List: in Word_List_Type; Word: out ASU.Unbounded_String; Count: out Natural) is
		P_Aux, P_Aux2, Maximo : Word_List_Type;
		Stop : Boolean := False;
	begin -- Max_Word
		if List = null then				--Si el primer elemento de la lista apunta
			raise Word_List_Error;		--a null, se eleva Word_List_Error.
		end if;
		Maximo := List;			--Se asigna a maximo la primera celda
		P_Aux := List.Next;		--de la lista y a P_Aux la siguiente.
		while P_Aux /= null loop				--Si hay mas de un elemento en la lista se entra al bucle
			if Maximo.Count >= P_Aux.Count then		--Se compara el count de Maximo con el de la siguiente
				P_Aux2 := P_Aux.Next;				--celda y, si el de Maximo es mayor, se recorre la lista.
				P_Aux := P_Aux2;
			else
				Maximo := P_Aux;				--Si se encuentra un count mayor al de Maximo, se
				P_Aux2 := P_Aux.Next;			--asigna a Maximo la celda donde se encuentra
				P_Aux := P_Aux2;				--este count mayor.
			end if;
			if List = null then			--Si la lista se encuentra vacía
				raise Word_List_Error;	--se eleva Word_List_Error
			end if;
			exit when P_Aux = null;			--Cuando se llega al final de la lista, se sale del bucle.
		end loop;
		Word := Maximo.Word;
		Count := Maximo.Count;
		exception
			when Word_List_Error =>
				Count := 0;
				Ada.Text_IO.Put_Line("No words");
	end Max_Word;

	procedure Print_All (List: in Word_List_Type) is
		P_Aux: Word_List_Type;
		P_Aux2: Word_List_Type;
	begin -- Print_All
		P_Aux := List;
		while P_Aux /= null loop
			Ada.Text_IO.Put_Line("|" & ASU.To_String(P_Aux.Word) & "| -" & Integer'Image(P_Aux.Count));
			P_Aux2 := P_Aux.Next;		--Si la lista no está vacía se imprime el Word de la primera
			P_Aux := P_Aux2;			--celda y se pasa a la siguiente celda, para seguir
		end loop;						--con el bucle hasta llegar al final de la lista.
		if List = null then						--Si la lista está vacía se imprime
			Ada.Text_IO.Put_Line("No words");	--el mensaje "No Words"
		end if;
	end Print_All;

	procedure Delete_List (List: in out Word_List_Type) is		--Extensión 3
		P_Aux: Word_List_Type;
	begin --Delete_List
		while List /= null loop
			P_Aux := List.Next;		--Se asigna P_Aux a la celda siguiente a la que apunta List,
			Free(List);				--se libera la memoria a la que apunta List y se hace que
			List := P_Aux;			--List apunte a la celda apuntada por P_Aux hasta que se
		end loop;					--llegue al final de la lista.
	end Delete_List;

end Word_Lists;


