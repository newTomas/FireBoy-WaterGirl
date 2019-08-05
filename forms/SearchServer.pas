unit SearchServer;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls,
  Vcl.ComCtrls;

type
  TForm2 = class(TForm)
    SearchServer: TPanel;
    SSAddress: TEdit;
    SSReturn: TBitBtn;
    SSGetInfo: TBitBtn;
    SSConnect: TBitBtn;
    SSServerInfo: TListView;
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
