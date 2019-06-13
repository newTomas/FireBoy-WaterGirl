unit TCP;

interface
  uses Dialogs, Classes, IdTCPClient, IdBaseComponent,
  IdComponent, IdTCPConnection, TypInfo, Controls;

type
  TonMsg = Procedure(s: string);
  TCPClient = class
    procedure Connect(IP: String; Port: Word);
    procedure Send(LType, Line: String);
    procedure IdTCPClientConnected(Sender: TObject);
    procedure IdTCPClientDisconnected(Sender: TObject);
    procedure Disconnect;
    constructor create(onMsgProcedure: TonMsg);
  private
  end;
  TCPsock = class(TThread)
  private
    { Private declarations }
  protected
    procedure Execute; override;
  end;

var
  IdTCPClient: TIdTCPClient;
  onMsg: TonMsg;
  Connection: Boolean;
  cl: TCPsock;
  Client: TCPClient;
  s: String;

implementation

procedure TCPClient.IdTCPClientConnected(Sender: TObject);
begin
  Connection := True;
  cl := TCPsock.Create(false);
end;

procedure TCPClient.IdTCPClientDisconnected(Sender: TObject);
begin
  cl.Free;
  Connection := false;
end;

procedure TCPClient.Send(LType, Line: String);
begin
  IdTCPClient.Socket.WriteLn(LType + ' ' + Line);
end;

procedure TCPClient.Connect(IP: string; Port: Word);
begin
  IdTCPClient.Disconnect;
  IdTCPClient.Host := IP;
  IdTCPClient.Port := Port;
  IdTCPClient.Connect;
end;

procedure TCPsock.Execute;
begin
  repeat
    onMsg(IdTCPClient.Socket.ReadLn);
  until (Terminated);
end;

constructor TCPClient.create(onMsgProcedure: TonMsg);
begin
  IdTCPClient := TIdTCPClient.Create(Nil);
  IdTCPClient.OnConnected := IdTCPClientConnected;
  IdTCPClient.OnDisconnected := IdTCPClientDisconnected;
  onMsg := onMsgProcedure;
end;

procedure TCPClient.Disconnect;
begin
  IdTCPClient.Disconnect;
  Connection := false;
end;

end.
