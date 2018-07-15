--RAUL CANO MONTERO
with Ada.Strings.Unbounded;
with Lower_Layer_UDP;

package Chat_Messages is

	type Message_Type is (Init, Writer, Server, Collection_Request, Collection_Data, Ban, Shutdown);

end Chat_Messages;