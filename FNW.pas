unit FNW;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, StdCtrls, DLLManager, TFNW;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Button2: TButton;
    Button3: TButton;
    ListBox1: TListBox;
    Button4: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  Manager: TDLLManager;
  Symma: function (a,b:integer):Integer;stdcall;
  DllMessage: procedure;
  LibHandle: THandle;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
begin
  Manager.Load(Edit1.Text,ListBox1);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if ListBox1.ItemIndex <> -1 then Manager.UnLoad(ListBox1.Items[ListBox1.ItemIndex],ListBox1);

end;

procedure TForm1.Button4Click(Sender: TObject);
begin
  Manager.LoadALL('F:\game\MapEditor\mods',ListBox1);
end;

end.
