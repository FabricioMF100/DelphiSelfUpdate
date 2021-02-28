program DemoDelphiAutoUpdate;

uses
  System.StartUpCopy,
  FMX.Forms,
  UPrincipal in 'UPrincipal.pas' {Form1},
  {$IFDEF ANDROID}
  Android.App.JNI.DownloadManager in 'DelphiSelfUpdate\Android.App.JNI.DownloadManager.pas',
  Android.BroadcastReceiver in 'DelphiSelfUpdate\Android.BroadcastReceiver.pas',
  {$ENDIF}
  DelphiSelfUpdate in 'DelphiSelfUpdate\DelphiSelfUpdate.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
