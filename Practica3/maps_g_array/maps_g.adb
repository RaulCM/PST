with Ada.Text_IO;
with Ada.Unchecked_Deallocation;

package body Maps_G is

--   procedure Free is new Ada.Unchecked_Deallocation (Cell, Cell_Array_A);


   procedure Get (M       : Map;
                  Key     : in  Key_Type;
                  Value   : out Value_Type;
                  Success : out Boolean) is
      P_Aux : Cell_Array_A;
      N : Integer := 1;
   begin
      P_Aux := M.P_Array;
      Success := False;
      while not Success and N <= M.Length Loop
         if P_Aux(N).Key = Key then
            Value := P_Aux(N).Value;
            Success := True;
         end if;
         N := N + 1;
      end loop;
   end Get;


   procedure Put (M     : in out Map;
                  Key   : Key_Type;
                  Value : Value_Type) is
      P_Aux : Cell_Array_A;
      N : Integer := 1;
   begin
      if M.Length = Max then
         raise Full_Map;
      end if;
      P_Aux := M.P_Array;
      if M.Length = 0 then
         M.P_Array := new Cell_Array;
         M.P_Array(1).Key := Key;
         M.P_Array(1).Value := Value;
         M.P_Array(1).Full := True;
         M.Length := M.Length + 1;
      else
         while M.P_Array(N).Full = True loop
            N := N + 1;
         end loop;
         M.P_Array(N).Key := Key;
         M.P_Array(N).Value := Value;
         M.P_Array(N).Full := True;
         M.Length := M.Length + 1;
      end if;
   end Put;


   procedure Delete (M      : in out Map;
                     Key     : in  Key_Type;
                     Success : out Boolean) is
      P_Aux : Cell_Array_A;
      N : Integer := 1;
   begin
      Success := False;
      P_Aux  := M.P_Array;
      while not Success loop
         if P_Aux(N).Key = Key then
            M.Length := M.Length - 1;
            P_Aux(N).Full := False;
--            Free (P_Current);
            Success := True;
         end if;
         N := N + 1;      
      end loop;
   end Delete;


   function Map_Length (M : Map) return Natural is
   begin
      return M.Length;
   end Map_Length;


   function First (M: Map) return Cursor is
   begin
      return (M => M, Element_A => M.P_Array(1), N => 1);
   end First;


   procedure Next (C: in out Cursor) is
   begin
      C.N := C.N + 1;
      C.Element_A := C.M.P_Array(C.N);
   end Next;


   function Element (C: Cursor) return Element_Type is
   begin
      if C.Element_A.Full = True then
         return (Key   => C.Element_A.Key,
                 Value => C.Element_A.Value);
      else
         raise No_Element;
      end if;
   end Element;


   function Has_Element (C: Cursor) return Boolean is
   begin
      if C.M.Length <= 1 or C.N = 150 then
         return False;
      else
         return True;
      end if;
   end Has_Element;


end Maps_G;
