unit UPrincipal;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Edit, FMX.DialogService,
  DelphiSelfUpdate,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Objects, FMX.Layouts;

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    Layout2: TLayout;
    Layout3: TLayout;
    Text1: TText;
    Button3: TButton;
    EdtLinkApk: TEdit;
    Text3: TText;
    Text2: TText;
    Button1: TButton;
    Button2: TButton;
    EdtLinkInfo: TEdit;
    Text4: TText;
    procedure Button3Click(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  VUpdate: TSelfUpdateDelphi;

implementation

{$R *.fmx}

procedure TForm1.Button1Click(Sender: TObject);
var
  VTempLinkAtualizacao: string;
begin
  //Exemplo apenas verifica se há atualização
  if VUpdate.VerificarAtualizacao(EdtLinkInfo.Text, TSelfUpdateDelphi.ObterVersaoAtualApp, VTempLinkAtualizacao) then
  begin
    EdtLinkApk.Text:= VTempLinkAtualizacao;
    TDialogService.ShowMessage('Há uma nova versão disponível para download.', nil);
  end
  else
  begin
    TDialogService.ShowMessage('Seu app está atualizado.', nil);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  //Exemplo verifica se há atualização e pergunta se deseja atualizar
  VUpdate.VerificarAtualizacaoEPerguntar(EdtLinkInfo.Text, TSelfUpdateDelphi.ObterVersaoAtualApp, True);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  if String.IsNullOrEmpty(EdtLinkApk.Text) then
  begin
    TDialogService.ShowMessage('Preencha o link do Apk ou clique em Verificar atualização.', nil);
  end
  else
  begin
    //Exemplo fazer atualização
    VUpdate.Atualizar(EdtLinkApk.Text, 'teste.apk');
  end;
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  VUpdate:= TSelfUpdateDelphi.Create(Self);
  Text3.Text:= 'Android ' + IntToStr(TOSVersion.Major) + '.' + IntToStr(TOSVersion.Minor) + ' - Versão Apk: ' + TSelfUpdateDelphi.ObterVersaoAtualApp;
end;

end.
