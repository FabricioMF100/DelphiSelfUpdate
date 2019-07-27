unit UMD5Principal;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, IdHashMessageDigest, ClipBrd;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Label2: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    OpenDialog1: TOpenDialog;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  ObjMD5: TIdHashMessageDigest5;
  FS: TFileStream;
begin
if OpenDialog1.Execute then
begin
  if FileExists(OpenDialog1.FileName) then
  begin
    try
      Edit1.Text:= OpenDialog1.FileName;
      FS:= TFileStream.Create(OpenDialog1.FileName, fmOpenRead);
      ObjMD5:= TIdHashMessageDigest5.Create;
      Edit2.Text:= ObjMD5.HashStreamAsHex(FS);
    finally
      FS.Free;
      ObjMD5.Free;
    end;
  end;
end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
Clipboard.AsText:= Edit2.Text;
end;

end.
