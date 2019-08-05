unit Lobby;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TForm2 = class(TForm)
    Lobby: TPanel;
    LPlayers: TListBox;
    LReady: TCheckBox;
    LPlayerType: TRadioGroup;
    LChat: TMemo;
    LMessage: TEdit;
    LSend: TBitBtn;
    LLeave: TBitBtn;
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
