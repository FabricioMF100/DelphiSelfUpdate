unit DelphiSelfUpdate;

{
  SelfUpdate para Delphi - Escrito por Fabricio Marques
  Versão: 1.0.1
  
  https://github.com/FabricioMF100/DelphiSelfUpdate

  !!!!!!! OBSERVAÇÃO IMPORTANTE PARA Delphi 10.3.1 (Somente 10.3.1) !!!!!!
    Exite um bug na unit System.Net.HttpClient.pas original do Delphi 10.3.1 (Release 1)
    onde há problemas no uso com Thread, para resolver inclua a unit corrigida
    que se encontra na pasta "HotFix 10.3.1" dentro da pasta do seu projeto,
    isso forçará o Delphi a utilizar a unit corrigida ao invés da problematica.
      OBS: O problema não existe nas versões 10.3 e 10.3.2 e por tanto a unit corrigida
      não deve ser usada.

    Cortesia: Gledston Reis - Obrigado!
  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  Instruções:
    Permissões Delphi 10.3 (Rio):
      No menu Project > Options  vá até Application > Entitlement List e
      habilite "Secure File Sharing".
      No mesmo menu, va em Application > Uses Permissions e habilite as
      permissões "Read External Storage" e "Write External Storage"

      Abra o arquivo AndroidManifest.template.xml do seu projeto e logo após
      a linha
        <uses-sdk android:minSdkVersion="%minSdkVersion%" android:targetSdkVersion="%targetSdkVersion%" />
      Adicione a seguinte linha
        <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

  Como usar:
    copie essa unit para a pasta do seu projeto, e no seu "Uses" adicione DelphiSelfUpdate
    crie uma variavel do tipo TSelfUpdateDelphi passando no Create o seu form (usado como
    base para o dialogo de progresso)
    chame o methodo Atualizar('Url de download do apk', 'nome do arquivo para salvar');
    Exemplo:

    var
      VUpdate: TSelfUpdateDelphi;
    begin
      VUpdate:= TSelfUpdateDelphi.Create(Form1);
      VUpdate.Atualizar('http://meusite.com/download/NomeDoApp.apk', 'MeuApp.apk');
}

interface

uses
  System.SysUtils, System.Types, System.Classes, System.IOUtils,
  System.Net.HttpClient, System.Net.HttpClientComponent,
  System.Permissions, System.Threading, System.IniFiles,
  Fmx.Objects, Fmx.StdCtrls, Fmx.Forms, Fmx.Types, System.UiTypes,
  FMX.DialogService, FMX.Dialogs,
  Androidapi.Helpers,
  Androidapi.JNI.GraphicsContentViewText,
  FMX.Platform.Android,
  Androidapi.Jni.JavaTypes,
  //Androidapi.JNIBridge,
  Androidapi.Jni.Net,
  //Androidapi.JNI.App,
  Androidapi.JNI.Support,
  Androidapi.JNI.Os,
  Androidapi.IOUtils;

type
  TSelfUpdateDelphiDownloading = class
    public
      RctFundoEscuro: TRectangle;
      RctFundoMenor: TRectangle;
      TxtFazendoDownload: TText;
      TxtAndamento: TText;
      PrgBAndamento: TProgressBar;
      constructor Create(AOwner: TForm);
    const
      TextoIniciando: string = 'Iniciando...';
      TextoFazendoDownload: string = 'Fazendo download da atualização, por favor aguarde.';
  end;

type
  TSelfUpdateDelphi = class
    LinkDownload: string;
    LinkVerificaVersao: string;
    NomeArquivoApk: string;
    DiretorioDownload: string;
    DialogoAndamento: TSelfUpdateDelphiDownloading;
  private
    FormBase: TForm;
    ErroDownload: boolean;
    { Private declarations }
    procedure ObterPermissoes;
    procedure ChamarInstalacao;
    procedure NetHTTPClientOnReceiveData(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var Abort: Boolean);
    procedure NetHTTPClientOnRequestError(const Sender: TObject; const AError: string);
    function BaixarAtualizacao:boolean;
    procedure ProcessarAtualizacao;
    procedure DisplayRationale(const APermissions: TArray<string>; const APostRationaleProc: TProc);
    procedure ResultadoPermissoes(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
  public
    { Public declarations }
    class function ObterVersaoAtualApp:string;
    procedure VerificarAtualizacaoEPerguntar(LinkInfoVersao, VersaoAtual: string);
    function VerificarAtualizacao(LinkInfoVersao, VersaoAtual: string; var VLinkRetorno: string):boolean;
    procedure Atualizar(UrlDownload, NomeDoArquivoSalvar: string);
    constructor Create(AOwner: TForm);
  end;

implementation

{ TSelfUpdateDelphi }

procedure TSelfUpdateDelphi.Atualizar(UrlDownload, NomeDoArquivoSalvar: string);
begin
  LinkDownload:= UrlDownload;
  NomeArquivoApk:= NomeDoArquivoSalvar;

  //Caso seja Android 6 ou superior solicita permissão
  if TOSVersion.Major < 6 then
  begin
    ProcessarAtualizacao;
  end
  else
  begin
    //Caso seja Android 5 ou inferior a permissão já é concedida
    ObterPermissoes;
  end;
end;

function TSelfUpdateDelphi.BaixarAtualizacao: boolean;
var
  VHttp: TNetHTTPClient;
  VStreamArquivo: TFileStream;
begin
      ErroDownload:= false;
      if FileExists(DiretorioDownload + PathDelim + NomeArquivoApk) then
      begin
        DeleteFile(DiretorioDownload + PathDelim + NomeArquivoApk);
      end;

      VStreamArquivo:= TFileStream.Create(DiretorioDownload + PathDelim + NomeArquivoApk, fmCreate);
      VHttp:= TNetHTTPClient.Create(nil);
      try
        VHttp.OnReceiveData:= NetHTTPClientOnReceiveData;
        VHttp.OnRequestError:= NetHTTPClientOnRequestError;
        VHttp.HandleRedirects:= True;
        VHttp.UserAgent:= 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36';
        //VHttp.ConnectionTimeout:= 4000;
        //VHttp.ResponseTimeout:= 10000;
        VHttp.Get(LinkDownload, VStreamArquivo);
      finally
        VHttp.Free;
        VStreamArquivo.Free;

        //Ao finalizar executa a instalação
        if ErroDownload = false then
        begin
        TThread.Synchronize(nil, procedure ()
          begin
            DialogoAndamento.PrgBAndamento.Value:= DialogoAndamento.PrgBAndamento.Max;
            DialogoAndamento.TxtFazendoDownload.Text:= 'Download concluído';
            DialogoAndamento.TxtAndamento.Text:= 'A instalação será iniciada...';
          end);
          Sleep(1000);
          TThread.Synchronize(nil, procedure ()
          begin
            ChamarInstalacao;
          end);
        end;
      end;
end;

procedure TSelfUpdateDelphi.ChamarInstalacao;
var
  VArquivo:Jfile;
  Intent:JIntent;
  VUriArquivo: Jnet_Uri;
  VStrFileProvider: string;
begin
  VArquivo:=TJfile.JavaClass.init(StringToJstring(DiretorioDownload),StringToJstring(NomeArquivoApk));

  if TOSVersion.Major < 7 then
  begin
    //
    //  Para API inferor a 25 envia o caminho absoluto
    //  Cortesia: Igor Bastos - Obrigado!
    //
    VUriArquivo:= TJnet_Uri.JavaClass.fromFile(VArquivo);
  end
  else
  begin
    VStrFileProvider:= JStringToString(TAndroidHelper.Context.getApplicationContext.getPackageName) + '.fileprovider';

    VUriArquivo := TJFileProvider.JavaClass.getUriForFile(TAndroidHelper.Context, StringToJString(VStrFileProvider), VArquivo);
  end;
  Intent := TJIntent.Create ;
  Intent.setAction(TJIntent.JavaClass.ACTION_VIEW);
  Intent.addFlags(TJIntent.JavaClass.FLAG_ACTIVITY_NEW_TASK);
  if TOSVersion.Major > 5 then
  begin
    Intent.addFlags(TJIntent.JavaClass.FLAG_GRANT_READ_URI_PERMISSION);
  end;
  Intent.setDataAndType(VUriArquivo,StringToJstring('application/vnd.android.package-archive'));
  SharedActivityContext.startActivity(Intent);

end;

constructor TSelfUpdateDelphi.Create(AOwner: TForm);
begin
  FormBase:= AOwner;
  //Diretório de download
  DiretorioDownload:= GetSharedDownloadsDir;
end;

procedure TSelfUpdateDelphi.DisplayRationale(const APermissions: TArray<string>; const APostRationaleProc: TProc);
begin
  // Mostra uma mensagem sobre as permissões
  TDialogService.ShowMessage('Para continuar com a atualização, precisamos de sua permissão para fazer o download.',
    procedure(const AResult: TModalResult)
    begin
      APostRationaleProc;
    end)
end;

procedure TSelfUpdateDelphi.NetHTTPClientOnReceiveData(const Sender: TObject;
  AContentLength, AReadCount: Int64; var Abort: Boolean);
begin
//Atualização da porcentagem do download
 TThread.Synchronize(nil, procedure ()
  begin
    DialogoAndamento.PrgBAndamento.Max:= AContentLength;
    DialogoAndamento.PrgBAndamento.Value:= AReadCount;
    DialogoAndamento.TxtAndamento.Text:= FloatToStr(Round((AReadCount / AContentLength) * 100)) + '% concluído';
  end);
end;

procedure TSelfUpdateDelphi.NetHTTPClientOnRequestError(const Sender: TObject;
  const AError: string);
var
  VMsg: TDialogService;
begin
//Mostra um diálogo perguntando se deseja tentar novamente
ErroDownload:= true;
VMsg:= TDialogService.Create;
VMsg.PreferredMode:= TDialogService.TPreferredMode.Platform;
TThread.Synchronize(nil, procedure ()
  begin
  VMsg.MessageDialog('Houve um problema ao tentar concluir o download.' + sLineBreak + 'Deseja tentar novamente?' + sLineBreak + sLineBreak + 'Problema ocorrido: ' + AError, TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes: ProcessarAtualizacao;
      end;
    end);
  end);
end;

procedure TSelfUpdateDelphi.ResultadoPermissoes(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
begin
//Caso seja permitido executa a atualização
    if (Length(AGrantResults) > 0) then
    begin
        if (AGrantResults[0] = TPermissionStatus.Granted) then
        begin
          ProcessarAtualizacao;
        end;
    end;
end;

function TSelfUpdateDelphi.VerificarAtualizacao(
  LinkInfoVersao, VersaoAtual: string; var VLinkRetorno: string): boolean;
var
  VHttp: TNetHTTPClient;
  VResponse: IHTTPResponse;
  VIniResposta: TMemIniFile;
  VStrVersao: String;
begin
// Acessa o link e verifica as informações de versão
      VHttp:= TNetHTTPClient.Create(nil);
      try
        VHttp.HandleRedirects:= True;
        VHttp.UserAgent:= 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/65.0.3325.181 Safari/537.36';
        //VHttp.ConnectionTimeout:= 4000;
        //VHttp.ResponseTimeout:= 10000;
        VHttp.Accept:= 'application/json,text/plain,text/html';
        VResponse:= VHttp.Get(LinkInfoVersao);
        if VResponse.ContentAsString.Length > 0 then
        begin
          //Carrega as informações e checa se a versão é diferente
          VIniResposta:= TMemIniFile.Create(VResponse.ContentStream);
          VStrVersao:= VIniResposta.ReadString('App', 'Versao', '');
          if (String.isNullOrEmpty(VStrVersao) = false) and (VStrVersao <> VersaoAtual) then
          begin
            VLinkRetorno:= VIniResposta.ReadString('Download', 'Link', '');
            Result:= True;
            end
            else
            begin
            Result:= False;
          end;
          VIniResposta.Free;
        end;
        VHttp.Free;
      except
        VHttp.Free;
        VIniResposta.Free;
        Result:= False;
      end;

end;

procedure TSelfUpdateDelphi.VerificarAtualizacaoEPerguntar(
  LinkInfoVersao, VersaoAtual: string);
var
  VMsg: TDialogService;
  VLinkRetorno: string;
begin
//Mostra um diálogo perguntando se deseja atualizar caso haja atualização
  if VerificarAtualizacao(LinkInfoVersao, VersaoAtual, VLinkRetorno) then
  begin
    VMsg:= TDialogService.Create;
    VMsg.PreferredMode:= TDialogService.TPreferredMode.Sync;
    VMsg.MessageDialog('Há uma atualização disponível para o app.' + sLineBreak + 'Deseja atualizar agora?', TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbYes, 0,
      procedure(const AResult: TModalResult)
      begin
        case AResult of
        mrYes: Atualizar(VLinkRetorno, 'TempAppUpdate.apk');
        end;
      end);
  end;
end;

procedure TSelfUpdateDelphi.ObterPermissoes;
begin
{$IFDEF ANDROID}
  PermissionsService.RequestPermissions([JStringToString(TJManifest_permission.JavaClass.WRITE_EXTERNAL_STORAGE),
                                        JStringToString(TJManifest_permission.JavaClass.READ_EXTERNAL_STORAGE),
                                        JStringToString(TJManifest_permission.JavaClass.INSTALL_PACKAGES)],
  Self.ResultadoPermissoes, DisplayRationale);
{$ENDIF}
end;

class function TSelfUpdateDelphi.ObterVersaoAtualApp: string;
var
  PackageManager: JPackageManager;
  PackageInfo: JPackageInfo;
begin
  //Obtem a versão atual do app
  PackageManager := SharedActivityContext.getPackageManager;
  PackageInfo := PackageManager.getPackageInfo
  (SharedActivityContext.getPackageName, 0);
  result := JStringToString(PackageInfo.versionName);
end;

procedure TSelfUpdateDelphi.ProcessarAtualizacao;
var
  VTask: ITask;
begin
//Cria a Task(Thread) para download da atualização
  if DialogoAndamento = nil then
  begin
    DialogoAndamento:= TSelfUpdateDelphiDownloading.Create(FormBase);
  end;
  DialogoAndamento.RctFundoEscuro.BringToFront;
  DialogoAndamento.PrgBAndamento.Value:= 0;

    VTask:= TTask.Create(procedure ()
      begin
        BaixarAtualizacao;
      end);
    VTask.Start;
end;

{ TSelfUpdateDelphiDownloading }

constructor TSelfUpdateDelphiDownloading.Create(AOwner: TForm);
begin
//Criação do diálogo visual do download
  RctFundoEscuro:= TRectangle.Create(AOwner);
  RctFundoEscuro.BeginUpdate;
  RctFundoEscuro.Parent:= AOwner;
  RctFundoEscuro.Width:= AOwner.Width;
  RctFundoEscuro.Height:= AOwner.Height;
  RctFundoEscuro.Position.X:= 0;
  RctFundoEscuro.Position.Y:= 0;
  RctFundoEscuro.Fill.Color:= $C8000000;

  RctFundoMenor:= TRectangle.Create(RctFundoEscuro);
  RctFundoMenor.BeginUpdate;
  RctFundoMenor.Parent:= RctFundoEscuro;
  RctFundoMenor.Padding.Top:= 5;
  RctFundoMenor.Padding.Bottom:= 5;
  RctFundoMenor.Padding.Left:= 5;
  RctFundoMenor.Padding.Right:= 5;
  RctFundoMenor.XRadius:= 5;
  RctFundoMenor.YRadius:= 5;
  RctFundoMenor.Width:= RctFundoEscuro.Width - 40;
  RctFundoMenor.Height:= 140;
  RctFundoMenor.Align:= TAlignLayout.Center;
  RctFundoMenor.Fill.Color:= TAlphaColorRec.White;

  TxtFazendoDownload:= TText.Create(RctFundoMenor);
  TxtFazendoDownload.BeginUpdate;
  TxtFazendoDownload.Parent:= RctFundoMenor;
  TxtFazendoDownload.Align:= TAlignLayout.Top;
  TxtFazendoDownload.Text:= TextoFazendoDownload;
  TxtFazendoDownload.TextSettings.Font.Style:= [TFontStyle.fsBold];

  TxtAndamento:= TText.Create(RctFundoMenor);
  TxtAndamento.BeginUpdate;
  TxtAndamento.Parent:= RctFundoMenor;
  TxtAndamento.Align:= TAlignLayout.Bottom;
  TxtAndamento.Text:= TextoIniciando;
  TxtAndamento.TextSettings.Font.Style:= [TFontStyle.fsBold];

  PrgBAndamento:= TProgressBar.Create(RctFundoMenor);
  PrgBAndamento.BeginUpdate;
  PrgBAndamento.Parent:= RctFundoMenor;
  PrgBAndamento.Margins.Top:= 5;
  PrgBAndamento.Margins.Bottom:= 5;
  PrgBAndamento.Margins.Left:= 5;
  PrgBAndamento.Margins.Right:= 5;
  PrgBAndamento.Align:= TAlignLayout.Client;

  RctFundoEscuro.BringToFront;

  PrgBAndamento.EndUpdate;
  TxtAndamento.EndUpdate;
  TxtFazendoDownload.EndUpdate;
  RctFundoMenor.EndUpdate;
  RctFundoEscuro.EndUpdate;
end;

end.
