unit Server;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, IdCustomTCPServer, IdTCPServer, IdThread,
  IdBaseComponent, IdComponent, StdCtrls, WinSock, IdIPWatch, IdContext, TFNW;

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
  settings: record
    map, name, hash: string;
    maxplayers: byte;
  end;
  players: array of record
    nick: string;
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
    IdTCPServer1.Bindings.Add.SetBinding(Edit1.Text, StrToInt(Edit2.Text));
    if CheckBox2.Checked then IdTCPServer1.Bindings.Add.SetBinding('127.0.0.1', StrToInt(Edit2.Text));
    IdTCPServer1.Active := true;
    list := IdTCPServer1.Contexts.LockList;
    IdTCPServer1.Contexts.UnlockList;
  End else IdTCPServer1.Active := false;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Edit1.Text := IdIPWatch1.LocalIP;
  settings.name := 'Test Server';
  list := IdTCPServer1.Contexts.LockList;
  IdTCPServer1.Contexts.UnlockList;
end;

procedure SendAllBut(AContext: TIdContext; msg: string);
var
  i: byte;
Begin
  if list.Count = 0 then exit;
  for i := 0 to list.Count-1 do
    if list.Items[i] <> @AContext then TIdContext(list.Items[i]).Connection.Socket.WriteLn(msg);
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
begin
  AContext.Connection.Socket.WriteLn(settings.name+'|'+settings.map+'|'+IntToStr(Length(players))+'|'+IntToStr(settings.maxplayers));
  AContext.Connection.Socket.WriteLn(settings.hash);
  if AContext.Connection.Socket.ReadLn = 'download' then
  Begin
    AContext.Connection.Socket.WriteFile('maps/'+settings.map+'.dat');
    AContext.Connection.Socket.WriteFile('maps/'+settings.map+'.dat.settings');
  end;
  SetLength(players, Length(players)+1);
  //players[High(players)].nick := AContext.Connection.Socket.ReadLn;
  players[High(players)].ready := false;
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
  s1: TStringList;
  s: string;
  i: Byte;
  readys: Byte;
begin
  s := AContext.Connection.Socket.ReadLn;
  ShowMessage(s);
  if s = 'Ready' then
  Begin      
    readys := 0;
    if IndexOf(@AContext.Connection.Socket) = -1 then exit;
    players[IndexOf(@AContext.Connection.Socket)].ready := true;
    for i := 0 to High(players) do if players[i].ready then inc(readys);
    if readys = settings.maxplayers then SendAll('start');
    exit;
  End;
  if s = 'NotReady' then
  Begin
    readys := 0;
    if IndexOf(@AContext.Connection.Socket) = -1 then exit;
    players[IndexOf(@AContext.Connection.Socket)].ready := false;
  End;
  s1 := TStringList.Create;
  s1.Delimiter := '|';
  s1.StrictDelimiter := true;
  s1.DelimitedText := s;
end;

end.
