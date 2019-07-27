program DSUGeradorMD5;

uses
  Vcl.Forms,
  UMD5Principal in 'UMD5Principal.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Ferramenta de geração de MD5';
  TStyleManager.TrySetStyle('Tablet Light');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
