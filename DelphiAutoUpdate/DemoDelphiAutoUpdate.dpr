program DemoDelphiAutoUpdate;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'UPrincipal.pas' {Form1},
  DelphiSelfUpdate in 'DelphiSelfUpdate\DelphiSelfUpdate.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
