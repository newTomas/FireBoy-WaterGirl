unit TCPS;

interface
  uses Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer, IdThread, IdContext, IdUDPBase,
  IdUDPServer;

type
  TCPServer = class
    procedure ServerCreate(IP: String; port: integer);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure SendAllBut(s: string; AContext: TIdContext);
    procedure ServerCommand(Comm:string);
    procedure ServerMessage(Mess: string);
    procedure Close();
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  list: TList;
  SendContext: TIdContext;
  Activation: boolean = false;
  IdTCPServer: TIdTCPServer;
  Server: TCPServer;

implementation

procedure TCPServer.ServerCreate(IP: String; port: integer);
begin
  IdTCPServer.MaxConnections := 5;
  IdTCPServer.Active := false;
  IdTCPServer.Bindings.Clear;
  IdTCPServer.Bindings.Add.SetBinding(IP, port);
  IdTCPServer.Active := true;
  list := IdTCPServer.Contexts.LockList;
  IdTCPServer.Contexts.UnlockList;
  Activation := true;
end;

procedure TCPServer.ServerMessage(Mess: string);
begin
  if (Activation = true) and (list.Count <> 0) then
    //TCPServer.SendAllBut('M Server ' + Mess, SendContext);
end;

procedure TCPServer.ServerCommand(Comm:string);
begin
  if (Activation = true) and (list.Count <> 0) then
    //TCPServer.SendAllBut('C ' + Comm, SendContext);
end;

procedure TCPServer.Close();
begin
  if (Activation = true) and (list.Count <> 0) then
    //TCPServer.SendAllBut('C Disconnect', SendContext);
  IdTCPServer.Active := false;
end;

procedure TCPServer.IdTCPServer1Connect(AContext: TIdContext);
begin
  AContext.Connection.Socket.WriteLn('M Server You connected');
end;

procedure TCPServer.IdTCPServer1Disconnect(AContext: TIdContext);
begin
  //ShowMessage('Ones disconected');
end;

procedure TCPServer.SendAllBut(s: string; AContext: TIdContext);
var
  i: Byte;
Begin
  if (IdTCPServer.Contexts <> nil) then
    for i := 0 to list.Count - 1 do
      if not (list.Items[i] = AContext) then
        TIdContext(list.Items[i]).Connection.Socket.WriteLn(s);
End;

procedure TCPServer.IdTCPServer1Execute(AContext: TIdContext);
var
  s: string;
  n: Byte;
begin
  s := AContext.Connection.Socket.ReadLn;
  SendContext := AContext;
  //ShowMessage(s);
  SendAllBut(s, AContext);
end;

end.
