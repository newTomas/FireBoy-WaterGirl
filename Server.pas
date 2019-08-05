unit Server;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, IdCustomTCPServer, IdTCPServer, IdThread,
  IdBaseComponent, IdComponent, StdCtrls, WinSock, IdIPWatch, IdContext, IdGlobal, TFNW;

type
  TForm1 = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    CheckBox1: TCheckBox;
    IdTCPServer1: TIdTCPServer;
    IdIPWatch1: TIdIPWatch;
    CheckBox2: TCheckBox;
    Edit3: TEdit;
    Label3: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  list: TList;
  settings: TPing;
  players: array of record
    nick: string[32];
    choice: Byte;
    ready: boolean;
  end;

implementation

{$R *.dfm}

function IndexOf(Socket: pointer): ShortInt;
var
  i: Byte;
Begin
  if list.Count = 0 then exit;

  for I := 0 to list.Count-1 do if @TIdContext(list.Items[i]).Connection.Socket = Socket then
  Begin
    result := i;
    exit;
  End;
  result := -1;
end;

procedure TForm1.CheckBox1Click(Sender: TObject);
var
  f: file of TSettingsMap;
  stngs: TSettingsMap;
begin
  if not (FileExists('maps/'+Edit3.Text+'.dat') and FileExists('maps/'+Edit3.Text+'.dat.settings')) then CheckBox1.Checked := false;
  if CheckBox1.Checked then
  Begin
    settings.map := Edit3.Text;
    AssignFile(F, 'maps/'+Edit3.Text+'.dat.settings');
    Reset(F);
    Read(F, stngs);
    CloseFile(F);
    settings.maxplayers := stngs.players;
    settings.hash := MD5('maps/'+Edit3.Text+'.dat');
    IdTCPServer1.MaxConnections := settings.maxplayers+1;
    ShowMessage(IntToStr(settings.maxplayers));
    IdTCPServer1.Bindings.Clear;
    if CheckBox2.Checked then IdTCPServer1.Bindings.Add.SetBinding('127.0.0.1', StrToInt(Edit2.Text))
    else IdTCPServer1.Bindings.Add.SetBinding('0.0.0.0', StrToInt(Edit2.Text));
    IdTCPServer1.Active := true;
    list := IdTCPServer1.Contexts.LockList;
    IdTCPServer1.Contexts.UnlockList;
  End else IdTCPServer1.Active := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  //Edit1.Text := IdIPWatch1.LocalIP;
  settings.name := 'Test Server';
  list := IdTCPServer1.Contexts.LockList;
  IdTCPServer1.Contexts.UnlockList;
end;

procedure SendAllBut(AContext: TIdContext; MessageType: TMessageActions; var msg);
var
  i: byte;
Begin
  if list.Count = 0 then exit;
  for i := 0 to list.Count-1 do
    if @TIdContext(list.Items[i]).Connection.Socket <> @AContext.Connection.Socket then
    Begin
      TIdContext(list.Items[i]).Connection.Socket.Write(RawToBytes(MessageType, SizeOf(MessageType)));
      TIdContext(list.Items[i]).Connection.Socket.Write(RawToBytes(msg, SizeOf(msg)));
    End;
End;

procedure SendAll(msg: string);
var
  i: byte;
Begin
  if list.Count = 0 then exit;
  for i := 0 to list.Count-1 do
    TIdContext(list.Items[i]).Connection.Socket.WriteLn(msg);
End;

procedure TForm1.IdTCPServer1Connect(AContext: TIdContext);
var
  Buffer: TIdBytes;
  msg: TMessageActions;
  MsgPlayerConnected: TPlayerConnectedChangeNick;
  MsgPlayerChangeType: TPlayerChangeType;
  MsgPlayerReady: TPlayerReady;
  i: Byte;
begin
  inc(settings.players);
  AContext.Connection.Socket.Write(RawToBytes(Settings, SizeOf(Settings)));

  if Length(players) > 0 then
  Begin
    for i := 0 to High(players) do
    Begin
      msg := PlayerConnected;
      MsgPlayerConnected.id := i+1;
      MsgPlayerConnected.nick := players[i].nick;
      AContext.Connection.Socket.Write(RawToBytes(msg, SizeOf(msg)));
      AContext.Connection.Socket.Write(RawToBytes(MsgPlayerConnected, SizeOf(MsgPlayerConnected)));

      if players[i].choice >= 0 then
      Begin
        msg := PlayerConnected;
        MsgPlayerChangeType.id := i+1;
        MsgPlayerChangeType.PlayerType := players[i].choice;
        AContext.Connection.Socket.Write(RawToBytes(msg, SizeOf(msg)));
        AContext.Connection.Socket.Write(RawToBytes(MsgPlayerChangeType, SizeOf(MsgPlayerChangeType)));
      End;

      if players[i].ready then
      Begin
        msg := PlayerReady;
        MsgPlayerReady.id := i+1;
        MsgPlayerReady.ready := true;
        AContext.Connection.Socket.Write(RawToBytes(msg, SizeOf(msg)));
        AContext.Connection.Socket.Write(RawToBytes(MsgPlayerReady, SizeOf(MsgPlayerReady)));
      End;
    End;
  End;
  AContext.Connection.Socket.ReadBytes(Buffer, SizeOf(MsgPlayerConnected));
  BytesToRaw(Buffer, MsgPlayerConnected, sizeof(MsgPlayerConnected));
  SendAllBut(AContext, PlayerConnected, MsgPlayerConnected);
  SetLength(players, Length(players)+1);
  players[High(players)].ready := false;
  players[High(players)].nick := MsgPlayerConnected.nick;
end;

procedure TForm1.IdTCPServer1Disconnect(AContext: TIdContext);
var
  i: byte;
begin
  if IndexOf(@AContext.Connection.Socket) = -1 then exit;
  if High(players) <> IndexOf(@AContext.Connection.Socket) then
    for I := IndexOf(@AContext.Connection.Socket) to High(players)-1 do players[i] := players[i+1];
  SetLength(players, length(players)-1);
end;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
var
  i: Byte;
  FS: TFileStream;
  Buffer: TIdBytes;
  msg: TMessageActions;
  PlayerChangeType: TPlayerChangeType;
  MsgPlayerReady: TPlayerReady;
  TxtMessage: TMessage;
  MsgChangeNick: TPlayerConnectedChangeNick;
begin
  AContext.Connection.Socket.ReadBytes(Buffer, SizeOf(msg));
  BytesToRaw(Buffer, msg, sizeof(msg));

  case msg of
    Ping: AContext.Connection.Socket.Write(RawToBytes(Settings, SizeOf(Settings)));
    NeedsDownload: Begin
      FS := TFileStream.Create('maps/'+settings.map+'.dat', fmOpenRead);
      AContext.Connection.Socket.Write(FS,FS.Size,true);
      FS.Free;
      FS := TFileStream.Create('maps/'+settings.map+'.dat.settings', fmOpenRead);
      AContext.Connection.Socket.Write(FS,FS.Size,true);
      FS.Free;
    end;
    PlayerMove: ;
    ObjectMove: ;
    ChangePlayerType: Begin
      AContext.Connection.Socket.ReadBytes(Buffer, SizeOf(PlayerChangeType));
      BytesToRaw(Buffer, PlayerChangeType, sizeof(PlayerChangeType));
      players[IndexOf(@AContext.Connection.Socket)].choice := PlayerChangeType.PlayerType;
      SendAllBut(AContext, msg, PlayerChangeType);
    end;
    TextMessage: Begin
      AContext.Connection.Socket.ReadBytes(Buffer, SizeOf(TxtMessage));
      BytesToRaw(Buffer, TxtMessage, sizeof(TxtMessage));
      SendAllBut(AContext, msg, TxtMessage);
    end;
    ChangeNick: Begin
      AContext.Connection.Socket.ReadBytes(Buffer, SizeOf(MsgChangeNick));
      BytesToRaw(Buffer, MsgChangeNick, sizeof(MsgChangeNick));
      players[IndexOf(@AContext.Connection.Socket)].nick := MsgChangeNick.nick;
      SendAllBut(AContext, msg, MsgChangeNick);
    end;
    PlayerReady: Begin
      AContext.Connection.Socket.ReadBytes(Buffer, SizeOf(MsgPlayerReady));
      BytesToRaw(Buffer, MsgPlayerReady, sizeof(MsgPlayerReady));
      players[IndexOf(@AContext.Connection.Socket)].ready := MsgPlayerReady.ready;
      SendAllBut(AContext, msg, MsgPlayerReady);
    end;
  end;
end;

end.
