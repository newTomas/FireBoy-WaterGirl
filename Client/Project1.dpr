program Project1;

uses
  Forms,
  Unit1 in '..\Client2\Unit1.pas' {Form1},
  TCP in 'TCP.pas',
  TCPS in 'TCPS.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
