unit TCPS;

interface
  uses Windows, Messages, SysUtils, Variants,
  Classes, Graphics,
  Controls, Dialogs, StdCtrls, IdBaseComponent,
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
    constructor create();
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  list: TList;
  SendContext: TIdContext;
  IdTCPServer: TIdTCPServer;
  Activation: boolean = false;
  Server: TCPServer;
  settings: record
    map, name: string;
    maxplayers: byte;
  end;
  players: byte;

implementation

procedure TCPServer.ServerCreate(IP: String; port: integer);
begin
  IdTCPServer.MaxConnections := 5;
  IdTCPServer.Active := false;
  IdTCPServer.Bindings.Clear;
  IdTCPServer.Bindings.Add.SetBinding(IP, port);
  IdTCPServer.OnExecute := IdTCPServer1Execute;
  //IdTCPServer.OnDisconnect := IdTCPServer1Disconnect;
  IdTCPServer.OnConnect := IdTCPServer1Connect;
  IdTCPServer.Active := true;
  list := IdTCPServer.Contexts.LockList;
  IdTCPServer.Contexts.UnlockList;
  Activation := true;
end;

procedure TCPServer.ServerMessage(Mess: string);
begin
  if (Activation = true) and (list.Count <> 0) then
    SendAllBut('M Server ' + Mess, SendContext);
end;

procedure TCPServer.ServerCommand(Comm:string);
begin
  if (Activation = true) and (list.Count <> 0) then
    SendAllBut('C ' + Comm, SendContext);
end;

procedure TCPServer.Close();
begin
  if (Activation = true) and (list.Count <> 0) then
    SendAllBut('C Disconnect', SendContext);
  IdTCPServer.Active := false;  
end;

procedure TCPServer.IdTCPServer1Connect(AContext: TIdContext);
begin
  AContext.Connection.Socket.WriteLn('M Server You connected');
  if list.Count = 2 then
    AContext.Connection.Socket.WriteLn('C Roodes Gamer');
  if list.Count > 2 then
    AContext.Connection.Socket.WriteLn('C Roodes Spectator');
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
  if s = 'ping ' then
  Begin
    AContext.Connection.Socket.WriteLn(settings.name+'|'+settings.map+'|'+IntToStr(players)+'|'+IntToStr(settings.maxplayers));
    exit;
  End;
  SendContext := AContext;
  SendAllBut(s, AContext);
end;

constructor TCPServer.create();
begin
  settings.name := 'Test Server 1337';
  settings.map := 'Test Map';
  settings.maxplayers := 32;
  players := 1;
  IdTCPServer := TIdTCPServer.Create(Nil);
end;

end.
