--RAUL CANO MONTERO
with Ada.Unchecked_Deallocation;
with Chat_Messages;
with Ada.Text_IO;

package body Client_Collections is

	procedure Free is new Ada.Unchecked_Deallocation(Cell, Cell_A);
	package CM renames Chat_Messages;

	procedure Add_Client (Collection: in out Collection_Type; EP: in LLU.End_Point_Type; Nick: in ASU.Unbounded_String; Unique: in Boolean) is
		P_Aux: Cell_A;
		Stop : Boolean := False;
	begin -- Add_Client
		if Collection.P_First = null then 			--La lista está vacía
			Collection.P_First := new Cell;			--Se crea la primera celda.
			P_Aux := Collection.P_First;			--P_Aux apunta a la primera celda.
			P_Aux.Client_EP := EP;					--Se asigna la dirección IP al Client_EP de la primera celda.
			P_Aux.Nick := Nick;						--Se asigna el nick al Nick de la primera celda.
			Collection.Total := 1;
		else										--Si ya hay elementos en la lista.
			P_Aux := Collection.P_First;			--Se apunta al primer elemento de la lista.
			loop
				if ASU.To_String(P_Aux.Nick) = ASU.To_String(Nick) and Unique = True then	--Si se encuentra el elemento y Unique es True.
					raise Client_Collection_Error;											--Se eleva la excepción.
				else
					if P_Aux.Next = null then		--Si no hay más elementos en la lista.
						P_Aux := new Cell;			--Se crea un nuevo elemento.
						P_Aux.Client_EP := EP;		--Se introducen los datos en la nueva celda.
						P_Aux.Nick := Nick;
						P_Aux.Next := Collection.P_First;		--Se hace que el elemento nuevo apunte al primero.
						Collection.P_First := P_Aux;
						Collection.Total := Collection.Total + 1;
						Stop := True;				--Se sale del bucle.
					else
						P_Aux := P_Aux.Next;		--Se pasa al siguiente elemento de la lista para buscar si el nick esta en alguna celda.
					end if;
				end if;
				exit when Stop = True;
			end loop;
		end if;
	end Add_Client;

	procedure Delete_Client (Collection: in out Collection_Type; Nick: in ASU.Unbounded_String) is
		P_Aux, P_Aux2: Cell_A;
		Stop : Boolean := False;
	begin -- Delete_Client
		P_Aux := Collection.P_First;
		if P_Aux = null then												--Si la lista está vacía, se eleva la excepción.
			raise Client_Collection_Error;
		elsif ASU.To_String(P_Aux.Nick) = ASU.To_String(Nick) then			--Si el nick está en el primer elemento de la lista.
			P_Aux2 := P_Aux.Next;
			Free(P_Aux);													--Se libera la memoria ocupada por ese elemento.
			Collection.Total := Collection.Total - 1;						--Se reduce en 1 el numero de usuarios.
			Collection.P_First := P_Aux2;									--Se hace que Collection apunte al 2º elemento de la lista.
		else																--Si el nick buscado no está el primero.
			P_Aux2 := P_Aux.Next;											--Se pasa al siguiente elemento de la lista.
			loop
				if ASU.To_String(P_Aux2.Nick) = ASU.To_String(Nick) then	--Si se encuentra el nick.
					P_Aux.Next := P_Aux2.Next;								--Se hace que la celda anterior apunte a la siguiente.
					Free(P_Aux2);											--Se libera la memoria ocupada por la celda.
					Collection.Total := Collection.Total - 1;				--Se reduce en 1 el numero de usuarios.
					Stop := True;											--Se sale del bucle.
				else														--Si no se encuentra el nick.
					P_Aux := P_Aux2;										--Se recorre la lista hasta llegar al final.
					P_Aux2 := P_Aux.Next;
					if P_Aux2 = null then									--Si se llega al final de la lista.
	    				raise Client_Collection_Error;						--Se eleva Client_Collection_Error.
	    			end if;
				end if;
				exit when Stop = True;
			end loop;
		end if;
	end Delete_Client;

	use Lower_Layer_UDP;

	function Search_Client (Collection: in Collection_Type; EP: in LLU.End_Point_Type) return ASU.Unbounded_String is
		P_Aux: Cell_A;
	begin -- Search_Client
		P_Aux := Collection.P_First;
		loop
			if P_Aux.Client_EP = EP then			--Si coincide la IP se devuelve el nick.
				return P_Aux.Nick;
			else
				P_Aux := P_Aux.Next;				--Se sigue recorriendo la lista.
				if P_Aux = null then				--Si se llega al final de la lista sin haber encontrado el EP
					raise Client_Collection_Error;	--Se eleva la excepción.
				end if;
			end if;
		end loop;
	end Search_Client;

	procedure Send_To_All (Collection: in Collection_Type; P_Buffer: access LLU.Buffer_Type) is
		P_Aux: Cell_A;
	begin -- Send_To_All
		P_Aux := Collection.P_First;
		while P_Aux /= null loop
			LLU.Send(P_Aux.Client_EP, P_Buffer);
			P_Aux := P_Aux.Next;
		end loop;
	end Send_To_All;

	procedure Datos_EP (EP: in End_Point_Type; IP: out ASU.Unbounded_String; Puerto: out ASU.Unbounded_String) is
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



	function Collection_Image (Collection: in Collection_Type) return String is
		P_Aux: Cell_A;
		Datos_Clientes: ASU.Unbounded_String;
		IP, Puerto: ASU.Unbounded_String;
	begin -- Collection_Image
		P_Aux := Collection.P_First;
		while P_Aux /= null loop
			Datos_EP(P_Aux.Client_EP, IP, Puerto);
			Datos_Clientes := ASU.To_Unbounded_String(ASU.To_String(Datos_Clientes) & ASCII.LF & ASU.To_String(IP) & ":" & ASU.To_String(Puerto) & " " & ASU.To_String(P_Aux.Nick));
			P_Aux := P_Aux.Next;
		end loop;
		return ASU.To_String(Datos_Clientes);
	end Collection_Image;



end Client_Collections;