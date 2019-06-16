unit TCP;

interface
  uses Dialogs, Classes, IdTCPClient, IdBaseComponent,
  IdComponent, IdTCPConnection, TypInfo, Controls, SysUtils, TFNW;

type
  //TonMsg = Procedure(s: string);
  TCPClient = class
    private
      function FReadConnected: Boolean;
    public
    property connected: Boolean read FReadConnected;
    function Connect(IP: String; Port: Word; hashes: TMapsList): TPing;
    function Ping(IP: String; Port: Word): TPing;
    procedure Send(Msg: String);
    function Read: string;
    procedure IdTCPClientConnected(Sender: TObject);
    procedure IdTCPClientDisconnected(Sender: TObject);
    procedure Disconnect;
    constructor create{(onMsgProcedure: TonMsg)};
  private
  end;
  {TCPsock = class(TThread)
  private
    //
  protected
    procedure Execute; override;
  end; }

var
  IdTCPClient: TIdTCPClient;
  pinging: boolean;
  //onMsg: TonMsg;
  //cl: TCPsock;
  Client: TCPClient;
  s: String;

implementation

procedure TCPClient.IdTCPClientConnected(Sender: TObject);
begin
  //cl := TCPsock.Create(false);
end;

procedure TCPClient.IdTCPClientDisconnected(Sender: TObject);
begin
  //cl.Free;
end;

function TCPClient.Ping(IP: String; Port: Word): TPing;
var
  s: TStringList;
begin
  IdTCPClient.Disconnect;
  IdTCPClient.Host := IP;
  IdTCPClient.Port := Port;
  try
    pinging := true;
    IdTCPClient.Connect;
    s := TStringList.Create;
    s.StrictDelimiter := true;
    s.Delimiter := '|';
    s.DelimitedText := IdTCPClient.Socket.ReadLn;
    result.name := s[0];
    result.map := s[1];
    result.players := StrToInt(s[2]);
    result.maxplayers := StrToInt(s[3]);
    result.work := true;
    IdTCPClient.Disconnect;
  except
    On e: Exception do
    Begin
      result.work := false;
      ShowMessage(E.Message);
    End;
  end;
  IdTCPClient.Disconnect;
  pinging := false;
end;

procedure TCPClient.Send(Msg: String);
begin
  IdTCPClient.Socket.WriteLn(Msg);
end;

function TCPClient.Read: string;
Begin
  result := IdTCPClient.Socket.ReadLn;
End;

function TCPClient.Connect(IP: string; Port: Word; hashes: TMapsList): TPing;
var
  s: TStringList;
  FS: TFileStream;
  hash: string;
  i: word;
begin
  IdTCPClient.Disconnect;
  IdTCPClient.Host := IP;
  IdTCPClient.Port := Port;
  try
    pinging := true;
    IdTCPClient.Connect;
    s := TStringList.Create;
    s.StrictDelimiter := true;
    s.Delimiter := '|';
    s.DelimitedText := IdTCPClient.Socket.ReadLn;
    result.name := s[0];
    result.map := s[1];
    result.players := StrToInt(s[2]);
    result.maxplayers := StrToInt(s[3]);
    result.work := true;
    hash := IdTCPClient.Socket.ReadLn;
    if length(hashes) > 0 then for I := 0 to High(hashes) do
      if hashes[i].hash = hash then result.hash := hashes[i].hash;
    if result.hash = '' then
    Begin
      IdTCPClient.Socket.WriteLn('download');
      FS := TFileStream.Create('maps/'+result.map+'.dat', fmOpenWrite);
      IdTCPClient.Socket.ReadStream(FS);
      FS.Free;
      FS := TFileStream.Create('maps/'+result.map+'.dat.settings', fmOpenWrite);
      IdTCPClient.Socket.ReadStream(FS);
      FS.Free;
    End else IdTCPClient.Socket.WriteLn('downloaded');

    //Send('Player1');
    //IdTCPClient.Socket.ReadLn;
  except
    on E : Exception do
    Begin
      ShowMessage(E.Message);
      result.work := false;
    End;
  end;
  pinging := false;
end;

{procedure TCPsock.Execute;
begin
  repeat
    if pinging then Continue;
    onMsg(IdTCPClient.Socket.ReadLn);
  until (Terminated);
end;            }

constructor TCPClient.create{(onMsgProcedure: TonMsg)};
begin
  IdTCPClient := TIdTCPClient.Create(Nil);
  IdTCPClient.OnConnected := IdTCPClientConnected;
  IdTCPClient.OnDisconnected := IdTCPClientDisconnected;
  //onMsg := onMsgProcedure;
end;

procedure TCPClient.Disconnect;
begin
  IdTCPClient.Disconnect;
end;

function TCPClient.FReadConnected: Boolean;
begin
  result := IdTCPClient.Connected;
end;

end.
