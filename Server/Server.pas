unit Server;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdBaseComponent,
  IdComponent, IdCustomTCPServer, IdTCPServer, IdThread, IdContext, IdUDPBase,
  IdUDPServer;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    Edit5: TEdit;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Button2: TButton;
    Edit2: TEdit;
    Edit3: TEdit;
    Edit4: TEdit;
    Edit6: TEdit;
    Memo1: TMemo;
    IdTCPServer1: TIdTCPServer;
    Button3: TButton;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure IdTCPServer1Disconnect(AContext: TIdContext);
    procedure IdTCPServer1Execute(AContext: TIdContext);
    procedure IdTCPServer1Connect(AContext: TIdContext);
    procedure SendAllBut(s: string; AContext: TIdContext);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CleareClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  list: TList;
  SendContext: TIdContext;
  Activation: boolean = false;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  port: Integer;
begin
  IdTCPServer1.MaxConnections := 5;
  IdTCPServer1.Active := false;
  port := StrToInt(Edit1.Text);
  IdTCPServer1.Bindings.Clear;
  IdTCPServer1.Bindings.Add.SetBinding('127.0.0.1', port);
  IdTCPServer1.Active := true;
  Edit4.Text := 'Listening...';
  list := IdTCPServer1.Contexts.LockList;
  IdTCPServer1.Contexts.UnlockList;
  Activation := true;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if (Activation = true) and (list.Count <> 0) then
  begin
    SendAllBut('M Server ' + Edit6.Text, SendContext);
    Form1.Memo1.Lines.Add('Server Message ' + Edit6.Text);
  end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if (Activation = true) and (list.Count <> 0) then
    SendAllBut('C ' + Edit6.Text, SendContext);
end;

procedure TForm1.CleareClick(Sender: TObject);
begin
  Edit6.Text := '';
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if (Activation = true) and (list.Count <> 0) then
    SendAllBut('C Disconnect', SendContext);
  IdTCPServer1.Active := false;
end;

procedure TForm1.IdTCPServer1Connect(AContext: TIdContext);
begin
  AContext.Connection.Socket.WriteLn('M Server You connected');
end;

procedure TForm1.IdTCPServer1Disconnect(AContext: TIdContext);
begin
  //ShowMessage('Ones disconected');
end;

procedure TForm1.SendAllBut(s: string; AContext: TIdContext);
var
  i: Byte;
Begin
  if (IdTCPServer1.Contexts <> nil) then
    for i := 0 to list.Count - 1 do
      if not (list.Items[i] = AContext) then
        TIdContext(list.Items[i]).Connection.Socket.WriteLn(s);
End;

procedure TForm1.IdTCPServer1Execute(AContext: TIdContext);
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
