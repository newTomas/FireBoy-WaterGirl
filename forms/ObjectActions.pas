unit ObjectActions;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    ActionsList: TListView;
    ActionsSelect: TComboBox;
    id: TEdit;
    x: TEdit;
    y: TEdit;
    delete: TButton;
    apply: TButton;
    create: TButton;
    ActionControlGroup: TGroupBox;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form2: TForm2;

implementation

{$R *.dfm}

end.
