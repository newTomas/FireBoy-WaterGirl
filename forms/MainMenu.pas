unit MainMenu;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Buttons;

type
  TForm2 = class(TForm)
    MMPlay: TBitBtn;
    MainMenu: TPanel;
    MMCreateServer: TBitBtn;
    MMMods: TBitBtn;
    MMSettings: TBitBtn;
    MMExit: TBitBtn;
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
