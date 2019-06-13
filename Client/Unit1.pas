unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics,
  Controls, Forms, Dialogs, StdCtrls, IdBaseComponent,
  IdComponent, IdTCPConnection, IdTCPClient, ExtCtrls, IdUDPBase,
  IdUDPClient, TypInfo, TCP, TCPS;

type
  TonMsg = Procedure(s: string);
  TStringSet = (A, M, C, Starts, Disconnect, Server, Player);
  TRights = (Spectator, Owner, Gamer);
  TForm1 = class(TForm)
    Edit1: TEdit;
    Edit2: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Button1: TButton;
    GroupBox1: TGroupBox;
    CheckBox1: TCheckBox;
    Label3: TLabel;
    Label4: TLabel;
    Send: TButton;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit5: TEdit;
    Memo1: TMemo;
    Label5: TLabel;
    Timer1: TTimer;
    Connect: TButton;
    Create: TButton;
    Settings: TButton;
    Exit: TButton;
    Back: TButton;
    StartButton: TButton;
    procedure Button1Click(Sender: TObject);
    procedure SendClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Timer1Timer(Sender: TObject);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure Edit1Click(Sender: TObject);
    procedure Edit2Click(Sender: TObject);
    procedure ConnectClick(Sender: TObject);
    procedure BackClick(Sender: TObject);
    procedure ExitClick(Sender: TObject);
    procedure CreateClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

type
  TPlayer = record
    x, y: integer;
    Way, PClass: string[1];
  end;

var
  Form1: TForm1;
  Me, Friend: TPlayer;
  Game: Boolean = false;
  fullscreen: Boolean = false;
  readiness: Boolean = false;
  Rights: TRights;
  ServerMessage, ServerCommand, ServerAction, ServerSender: TStringSet;
  Client: TCPClient;
  SServer: TCPServer;
  s: TStringList;
  F: integer = 10;
  function StrToStrSet(StringKey: String): TStringSet;

implementation

{$R *.dfm}

procedure Starting();
begin

end;

function StrToStrSet(StringKey: String): TStringSet;
begin
  Result := TStringSet(GetEnumValue(TypeInfo(TStringSet), StringKey));
end;

function StrToRights(StringKey: String): TRights;
begin
  Result := TRights(GetEnumValue(TypeInfo(TRights), StringKey));
end;

procedure onMsg(Mes: string);
Begin
  with Form1 do
  Begin
    s := TStringList.Create;
    s.Delimiter := ' ';
    s.DelimitedText := Mes;
    ServerMessage := StrToStrSet(s[0]);
    case ServerMessage of
    C:
      begin
        ServerCommand := StrToStrSet(s[1]);
        case ServerCommand of
        Disconnect:
          begin
            Form1.Edit1.Text := 'Connection fallen';
            Form1.Edit2.Text := 'ReWrite IP&Port';
            Form1.Button1.Caption := 'Connect';
            Form1.Memo1.Lines.Add('Server droped your connection');
            TCP.Connection := false;
            Client.Disconnect;
          end;
        Starts:  Starting;
        end;
      end;
    M:
      begin
        ServerSender := StrToStrSet(s[1]);
        s.Delete(0);
        case ServerSender of
        Player:
          begin
            s.Delete(0);
            Form1.Memo1.Lines.Add('Friend: ' + s.DelimitedText); // if you want to use s[0] create new string identificator;
          end;
        Server:
          begin
            s.Delete(0);
            Form1.Memo1.Lines.Add('Server: ' + s.DelimitedText);
          end;
        end;

      end;
    A:
      begin
        ServerAction := StrToStrSet(s[1]);
        case ServerAction of
        M:
        end;
      end;
    end;
  end;
end;

procedure TForm1.BackClick(Sender: TObject);
begin
  Connect.Visible := True;
  Create.Visible := True;
  Settings.Visible := True;
  Exit.Visible := True;
  Connect.Enabled := True;
  Create.Enabled := True;
  Settings.Enabled := True;
  Exit.Enabled := True;
  Edit1.Visible := false;
  Edit2.Visible := false;
  Label1.Visible := false;
  Label2.Visible := false;
  Button1.Visible := false;
  Back.Visible := false;
  Edit1.Enabled := false;
  Edit2.Enabled := false;
  Label1.Enabled := false;
  Label2.Enabled := false;
  Button1.Enabled := false;
  Back.Enabled := false;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if Button1.Caption = 'Connect' then
  begin

    Connect.Visible := True;
    Create.Visible := True;
    Settings.Visible := True;
    Exit.Visible := True;
    Connect.Enabled := True;
    Create.Enabled := True;
    Settings.Enabled := True;
    Exit.Enabled := True;
    Edit1.Visible := false;
    Edit2.Visible := false;
    Label1.Visible := false;
    Label2.Visible := false;
    Button1.Visible := false;
    Back.Visible := false;
    Edit1.Enabled := false;
    Edit2.Enabled := false;
    Label1.Enabled := false;
    Label2.Enabled := false;
    Button1.Enabled := false;
    Back.Enabled := false;
    Edit5.Visible := true;
    Edit5.Enabled := true;
    Label5.Visible := true;
    Label5.Enabled := true;
    Memo1.Visible := true;
    Memo1.Enabled := true;
    Send.Visible := true;
    Send.Enabled := true;
    if (TCP.Connection = false) and (Connect.Caption = 'Присоединиться к серверу') then
    begin
      Client := TCPClient.create(onMsg);
      Client.Disconnect;
      Client.Connect(Edit1.Text, StrToInt(Edit2.Text));
      if TCP.Connection = True then
      begin
        Connect.Caption := 'Отключиться от сервера';
      end;
      StartButton.Visible := true;
      StartButton.Enabled := true;
    end;
  end
  else if Button1.Caption = 'Create' then
  begin
    SServer := TCPServer.create();
    SServer.ServerCreate(Edit1.Text, StrToInt(Edit2.Text));
    if (TCP.Connection = false) and (Connect.Caption = 'Присоединиться к серверу') then
    begin
      Client := TCPClient.create(onMsg);
      Client.Disconnect;
      Client.Connect(Edit1.Text, StrToInt(Edit2.Text));
      if TCP.Connection = True then
      begin
        Connect.Caption := 'Отключиться от сервера';
        Rights := StrToRights('Owner');
      end;
    end;
    ShowMessage('Server created successfuly');
    Connect.Visible := True;
    Create.Visible := True;
    Settings.Visible := True;
    Exit.Visible := True;
    Connect.Enabled := True;
    Create.Enabled := True;
    Settings.Enabled := True;
    Exit.Enabled := True;
    Edit1.Visible := false;
    Edit2.Visible := false;
    Label1.Visible := false;
    Label2.Visible := false;
    Button1.Visible := false;
    Back.Visible := false;
    Edit1.Enabled := false;
    Edit2.Enabled := false;
    Label1.Enabled := false;
    Label2.Enabled := false;
    Button1.Enabled := false;
    Back.Enabled := false;
    Edit5.Visible := true;
    Edit5.Enabled := true;
    Label5.Visible := true;
    Label5.Enabled := true;
    Memo1.Visible := true;
    Memo1.Enabled := true;
    Send.Visible := true;
    Send.Enabled := true;
    StartButton.Visible := true;
    StartButton.Enabled := true;
  end;
end;

procedure TForm1.ConnectClick(Sender: TObject);
begin
  if Connect.Caption = 'Присоединиться к серверу' then
  begin
    Connect.Visible := false;
    Create.Visible := false;
    Settings.Visible := false;
    Exit.Visible := false;
    Connect.Enabled := false;
    Create.Enabled := false;
    Settings.Enabled := false;
    Exit.Enabled := false;
    Edit1.Visible := true;
    Edit2.Visible := true;
    Label1.Visible := true;
    Label2.Visible := true;
    Button1.Visible := true;
    Back.Visible := true;
    Edit1.Enabled := true;
    Edit2.Enabled := true;
    Label1.Enabled := true;
    Label2.Enabled := true;
    Button1.Enabled := true;
    Back.Enabled := true;
    Button1.Caption := 'Connect';
  end
  else
  begin
    Client.Disconnect;
    Connect.Caption := 'Присоединиться к серверу';
    Edit5.Visible := false;
    Edit5.Enabled := false;
    Label5.Visible := false;
    Label5.Enabled := false;
    Memo1.Visible := false;
    Memo1.Enabled := false;
    Send.Visible := false;
    Send.Enabled := false;
    StartButton.Visible := false;
    StartButton.Enabled := false;
  end;
end;

procedure TForm1.CreateClick(Sender: TObject);
begin
  Connect.Visible := false;
  Create.Visible := false;
  Settings.Visible := false;
  Exit.Visible := false;
  Connect.Enabled := false;
  Create.Enabled := false;
  Settings.Enabled := false;
  Exit.Enabled := false;
  Edit1.Visible := true;
  Edit2.Visible := true;
  Label1.Visible := true;
  Label2.Visible := true;
  Button1.Visible := true;
  Back.Visible := true;
  Edit1.Enabled := true;
  Edit2.Enabled := true;
  Label1.Enabled := true;
  Label2.Enabled := true;
  Button1.Enabled := true;
  Back.Enabled := true;
  Button1.Caption := 'Create';
end;

procedure TForm1.Edit1Click(Sender: TObject);
begin
  Edit1.Text := '';
  Edit2.Text := '';
end;

procedure TForm1.Edit2Click(Sender: TObject);
begin
  Edit2.Text := '';
  Edit1.Text := '';
end;

procedure TForm1.ExitClick(Sender: TObject);
begin
  Form1.Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if TCP.Connection = true then
    Client.Disconnect;
  SServer.Close;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  {fullscreen := true;
  Form1.WindowState := wsMaximized;
  Form1.BorderStyle := bsNone;
  Form1.Width := Screen.Width;
  Form1.height := Screen.Height;
  FormStyle := fsStayOnTop;
  Form1.Left := 0;
  Form1.Top := 0;
  {Form1.Edit1.Text := '127.0.0.1';
  Form1.Edit2.Text := '8080';
  Client := TCPClient.create(onMsg);
  Client.Connect('127.0.0.1', 8080);
  if TCP.Connection = True then
    Button1.Caption := 'Enter to Game'; }
end;

procedure TForm1.SendClick(Sender: TObject);
begin
  if (Edit5.Text <> '') and (TCP.Connection = true) then
  begin
    Client.Send('M Player', Edit5.Text);
    Form1.Memo1.Lines.Add('Me: ' + Edit5.Text);
    Edit5.Text := '';
  end;
end;

procedure TForm1.StartButtonClick(Sender: TObject);
begin
  if Rights = StrToRights('Owner') then
  begin
    SServer.ServerMessage('Sturting...');
    SServer.ServerCommand('Starts');
  end;
  //if (Rights = Spectator) and (Game = true) then // что-то что ещё не добавленно (и скорее всего будет потом)
  if (Rights = Gamer) and (readiness = false) then
    readiness := true;
  if (Rights = Gamer) and (readiness = true) then
    readiness := false;
end;

procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case ord(Key) of
    VK_F11, VK_ESCAPE:
      if fullscreen = true then
      begin
        fullscreen := false;
        Form1.WindowState := wsNormal;
        Form1.BorderStyle := bsSizeable;
        Form1.Width := Screen.Width div 3 * 2;
        Form1.height := Screen.Height div 3 * 2;
        FormStyle := fsNormal;
        Form1.Left := (Screen.Width - Form1.Width) div 2;
        Form1.Top := (Screen.Height - Form1.Height) div 2;
        F := 55;
      end else
      begin
        fullscreen := true;
        Form1.WindowState := wsMaximized;
        Form1.BorderStyle := bsNone;
        Form1.Width := Screen.Width;
        Form1.height := Screen.Height;
        FormStyle := fsStayOnTop;
        Form1.Left := 0;
        Form1.Top := 0;
        F := 10
      end;
    VK_RETURN: SendClick(Sender);{if Edit5.Text <> '' then
      begin
        Client.Send('M', Edit5.Text);
        Form1.Memo1.Lines.Add('Me: ' + Edit5.Text);
        Edit5.Text := '';
      end;          }
  end;
end;


procedure TForm1.Timer1Timer(Sender: TObject);
begin
  with Form1 do
  begin
    Label1.Left := (Width - Edit1.Width) div 2;
    Label2.Left := (Width - Edit1.Width) div 2;
    Edit1.Left := (Width - Edit1.Width) div 2;
    Edit2.Left := (Width - Edit1.Width) div 2;
    Button1.Left := (Width - Edit1.Width) div 2;
    Back.Left := (Width - Edit1.Width) div 2;
    Connect.Left := (Width - Connect.Width) div 2;
    Create.Left := (Width - Create.Width) div 2;
    Settings.Left := (Width - Settings.Width) div 2;
    Settings.Left := (Width - Settings.Width) div 2;
    Exit.Left := (Width - Exit.Width) div 2;
    Memo1.Top := Height - Memo1.Height - F;
    Send.Top := Memo1.Top - 35;
    Edit5.Top := Send.Top;
    Label5.Top := Edit5.Top - 27;
    StartButton.Left := Connect.Left + Connect.Width + 6;
    if Rights = StrToRights('Owner') then
      StartButton.Caption := 'Начать игру';
    if (Rights = Gamer) and (readiness = false) then
      StartButton.Caption := 'Включить готовность';
    if (Rights = Gamer) and (readiness = true) then
      StartButton.Caption := 'Отключить готовность';
    if (Rights = Spectator) and (Game = false) then
      StartButton.Caption := 'Ожидайте игры';
    if (Rights = Spectator) and (Game = true) then
      StartButton.Caption := 'Смотреть игру';
  end;
end;

end.
