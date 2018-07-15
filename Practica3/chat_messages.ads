with Ada.Strings.Unbounded;
with Lower_Layer_UDP;

package Chat_Messages is

	type Message_Type is (Init, Welcome, Writer, Server, Logout);

end Chat_Messages;