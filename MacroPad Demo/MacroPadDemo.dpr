program MacroPadDemo;

uses
  Vcl.Forms,
  untMain in 'untMain.pas' {frmMacroPadDemo},
  untUSB in 'untUSB.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'MacroPad Demo';
  Application.CreateForm(TfrmMacroPadDemo, frmMacroPadDemo);
  Application.Run;
end.
