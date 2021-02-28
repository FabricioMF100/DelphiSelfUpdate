unit DelphiSelfUpdate;

{
  SelfUpdate para Delphi - Escrito por Fabricio Marques
  Versão: 1.0.3
  
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
  IdHashMessageDigest, System.IniFiles,
  Fmx.Objects, Fmx.StdCtrls, Fmx.Forms, Fmx.Types, System.UiTypes,
  FMX.DialogService, FMX.Dialogs,
  {$IFDEF ANDROID}
  System.Permissions,
  Androidapi.Helpers,
  Androidapi.JNI.GraphicsContentViewText,
  FMX.Platform.Android,
  Androidapi.Jni.JavaTypes,
  Androidapi.JNIBridge,
  Androidapi.Jni.Net,
  //Androidapi.JNI.App,
  Androidapi.JNI.Support,
  Androidapi.JNI.Os,
  Androidapi.IOUtils,
  Android.App.JNI.DownloadManager,
  Android.BroadcastReceiver,
  {$ENDIF}
  System.Threading;

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
    ChecagemMD5: String;
    VUsarDownloadManager: boolean;
    { Private declarations }
    procedure MensagemErro(StrMensagem: String);
    function ChecarMD5(Stream: TStream; MD5: String): boolean;
    procedure ObterPermissoes;
    procedure ChamarInstalacao;
    procedure NetHTTPClientOnReceiveData(const Sender: TObject; AContentLength: Int64; AReadCount: Int64; var Abort: Boolean);
    procedure NetHTTPClientOnRequestError(const Sender: TObject; const AError: string);
    function BaixarAtualizacao:boolean;
    procedure ProcessarAtualizacao;
    procedure DisplayRationale(const APermissions: TArray<string>; const APostRationaleProc: TProc);
    {$IFDEF ANDROID}
    function BaixarAtualizacaoDownloadManager:boolean;//Somente Android
    procedure DownloadManagerOnReceive(const Action: JString);
    procedure ResultadoPermissoes(const APermissions: TArray<string>; const AGrantResults: TArray<TPermissionStatus>);
    {$ENDIF}
  public
    { Public declarations }
    VersaoAtualizacaoDisponivel: String;
    class function ObterVersaoAtualApp:string;
    procedure VerificarAtualizacaoEPerguntar(LinkInfoVersao, VersaoAtual: string; MostrarVersao: boolean);
    function VerificarAtualizacao(LinkInfoVersao, VersaoAtual: string; var VLinkRetorno: string):boolean;
    procedure Atualizar(UrlDownload, NomeDoArquivoSalvar: string);
    constructor Create(AOwner: TForm; UsarDownloadManager: boolean = false);
    property AndroidDownloadManager: boolean read VUsarDownloadManager write VUsarDownloadManager;
  const
    TituloDownloadManager: string = 'Fazendo download da atualização';
  end;

implementation

{ TSelfUpdateDelphi }

procedure TSelfUpdateDelphi.Atualizar(UrlDownload, NomeDoArquivoSalvar: string);
begin
  LinkDownload:= UrlDownload;
  NomeArquivoApk:= NomeDoArquivoSalvar;
{$IFDEF ANDROID}
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
{$ENDIF}
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

        //Checa a integridade caso a sequencia MD5 tenha sido fornecida
        if String.IsNullOrEmpty(ChecagemMD5) = false then
        begin
          TThread.Synchronize(nil, procedure ()
          begin
            DialogoAndamento.PrgBAndamento.Value:= DialogoAndamento.PrgBAndamento.Max;
            DialogoAndamento.TxtFazendoDownload.Text:= 'Download concluído';
            DialogoAndamento.TxtAndamento.Text:= 'Verificando integridade do arquivo...';
          end);
          if ChecarMD5(VStreamArquivo, ChecagemMD5) = False then
          begin
            ErroDownload:= True;
            MensagemErro('Ocorreu um problema no download e o arquivo baixado está corrompido ou inválido.' + sLineBreak + 'Deseja tentar novamente?');
          end;
        end;

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
          Sleep(1500);
          TThread.Synchronize(nil, procedure ()
          begin
            ChamarInstalacao;
          end);
        end;
      end;
end;

{$IFDEF ANDROID}
function TSelfUpdateDelphi.BaixarAtualizacaoDownloadManager: boolean;
var
  VArquivo:Jfile;
  VUriArquivo: Jnet_Uri;
  DMRequest  : JDownloadManager_Request;
  DManager : JDownloadManager;
  URI : Jnet_Uri;
begin
      ErroDownload:= false;
      if FileExists(DiretorioDownload + PathDelim + NomeArquivoApk) then
      begin
        DeleteFile(DiretorioDownload + PathDelim + NomeArquivoApk);
      end;

      BroadcastReceiver.OnReceived := DownloadManagerOnReceive;
      BroadcastReceiver.AddAction(
      [
        TJDownloadManager.JavaClass.ACTION_DOWNLOAD_COMPLETE
      ]
    );

      //Criação do URI do arquivo de destino
      VArquivo:=TJfile.JavaClass.init(StringToJstring(DiretorioDownload),StringToJstring(NomeArquivoApk));
      VUriArquivo:= TJnet_Uri.JavaClass.fromFile(VArquivo);

      //Inicialização do DownloadManager
       URI := TJnet_Uri.JavaClass.parse(StringToJString(LinkDownload));
       DMRequest  := TJDownloadManager_Request.JavaClass.init(URI);

       DMRequest.setAllowedNetworkTypes(TJDownloadManager_Request.JavaClass.NETWORK_WIFI
                  AND TJDownloadManager_Request.JavaClass.NETWORK_MOBILE);

       DMRequest.setAllowedOverRoaming(False);
       DMRequest.setTitle(StrToJCharSequence(TituloDownloadManager));
       DMRequest.setDescription(StrToJCharSequence(VersaoAtualizacaoDisponivel));

       DMRequest.setNotificationVisibility(TJDownloadManager_Request.JavaClass.VISIBILITY_VISIBLE_NOTIFY_COMPLETED);

       //DMRequest.setDestinationInExternalPublicDir(StringToJString(DiretorioDownload), StringToJString(NomeArquivoApk));
       DMRequest.setDestinationUri(VUriArquivo);
       DManager := TJDownloadManager.Wrap((TAndroidHelper.Context.getSystemService(TJContext.JavaClass.DOWNLOAD_SERVICE) as ILocalObject).GetObjectID);

       DManager.enqueue(DMRequest);
      //Fim DownloadManager
end;
{$ENDIF}

procedure TSelfUpdateDelphi.ChamarInstalacao;
{$IFDEF ANDROID}
var
  VArquivo:Jfile;
  Intent:JIntent;
  VUriArquivo: Jnet_Uri;
  VStrFileProvider: string;
{$ENDIF}
begin
{$IFDEF ANDROID}
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
{$ENDIF}
end;

function TSelfUpdateDelphi.ChecarMD5(Stream: TStream; MD5: String): boolean;
var
  IdMD5: TIdHashMessageDigest5;
begin
//Faz a verificação de integridade do arquivo via MD5
  IdMD5 := TIdHashMessageDigest5.Create;
  Result:= False;
  try
    if IdMD5.HashStreamAsHex(Stream) = Md5 then
    begin
      Result := True;
    end;
  finally
    IdMD5.Free;
  end;
end;

constructor TSelfUpdateDelphi.Create(AOwner: TForm; UsarDownloadManager: boolean = false);
begin
  FormBase:= AOwner;
  //Diretório de download
  VUsarDownloadManager:= false;
  {$IFDEF ANDROID}
  VUsarDownloadManager:= UsarDownloadManager;
  DiretorioDownload:= GetSharedDownloadsDir;
  {$ENDIF}
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

{$IFDEF ANDROID}
procedure TSelfUpdateDelphi.DownloadManagerOnReceive(const Action: JString);
var
  VStreamArquivo: TFileStream;
begin
  VStreamArquivo:= TFileStream.Create(DiretorioDownload + PathDelim + NomeArquivoApk, fmOpenRead);

  //Checa a integridade caso a sequencia MD5 tenha sido fornecida
  if String.IsNullOrEmpty(ChecagemMD5) = false then
  begin
//    TThread.Synchronize(nil, procedure ()
//    begin
//      DialogoAndamento.PrgBAndamento.Value:= DialogoAndamento.PrgBAndamento.Max;
//      DialogoAndamento.TxtFazendoDownload.Text:= 'Download concluído';
//      DialogoAndamento.TxtAndamento.Text:= 'Verificando integridade do arquivo...';
//    end);
    if ChecarMD5(VStreamArquivo, ChecagemMD5) = False then
    begin
      ErroDownload:= True;
      MensagemErro('Ocorreu um problema no download e o arquivo baixado está corrompido ou inválido.' + sLineBreak + 'Deseja tentar novamente?');
    end;
  end;

  VStreamArquivo.Free;

  //Ao finalizar executa a instalação
  if ErroDownload = false then
  begin
    Sleep(1500);
    TThread.Synchronize(nil, procedure ()
    begin
      ChamarInstalacao;
    end);
  end;
end;
{$ENDIF}

procedure TSelfUpdateDelphi.MensagemErro(StrMensagem: String);
var
  VMsg: TDialogService;
begin
//Mostra um diálogo perguntando se deseja tentar novamente
ErroDownload:= true;
VMsg:= TDialogService.Create;
VMsg.PreferredMode:= TDialogService.TPreferredMode.Platform;
TThread.Synchronize(nil, procedure ()
  begin
  VMsg.MessageDialog(StrMensagem, TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbYes, 0,
    procedure(const AResult: TModalResult)
    begin
      case AResult of
        mrYes: ProcessarAtualizacao;
      end;
    end);
  end);
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
begin
//Mostra um diálogo perguntando se deseja tentar novamente
MensagemErro('Houve um problema ao tentar concluir o download.' + sLineBreak + 'Deseja tentar novamente?' + sLineBreak + sLineBreak + 'Problema ocorrido: ' + AError);
end;

{$IFDEF ANDROID}
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
{$ENDIF}

function TSelfUpdateDelphi.VerificarAtualizacao(
  LinkInfoVersao, VersaoAtual: string; var VLinkRetorno: string): boolean;
var
  VHttp: TNetHTTPClient;
  VResponse: IHTTPResponse;
  VIniResposta: TMemIniFile;
  //VStrVersao: String;
begin
{$IFDEF ANDROID}
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
          VersaoAtualizacaoDisponivel:= VIniResposta.ReadString('App', 'Versao', '');
          if (String.isNullOrEmpty(VersaoAtualizacaoDisponivel) = false) and (VersaoAtualizacaoDisponivel <> VersaoAtual) then
          begin
            VLinkRetorno:= VIniResposta.ReadString('Download', 'Link', '');
            Result:= True;
            if VIniResposta.ValueExists('Download', 'MD5') then
            begin
              ChecagemMD5:= VIniResposta.ReadString('Download', 'MD5', '');
            end;
            end
            else
            begin
{$ENDIF}
            Result:= False;
{$IFDEF ANDROID}
          end;
          VIniResposta.Free;
        end;
        VHttp.Free;
      except
        VHttp.Free;
        VIniResposta.Free;
        Result:= False;
      end;
{$ENDIF}
end;

procedure TSelfUpdateDelphi.VerificarAtualizacaoEPerguntar(
  LinkInfoVersao, VersaoAtual: string; MostrarVersao: boolean);
var
  VMsg: TDialogService;
  VStrMensagem: String;
  VLinkRetorno: string;
begin
//Mostra um diálogo perguntando se deseja atualizar caso haja atualização
  if VerificarAtualizacao(LinkInfoVersao, VersaoAtual, VLinkRetorno) then
  begin
    VMsg:= TDialogService.Create;
    VMsg.PreferredMode:= TDialogService.TPreferredMode.Sync;

    VStrMensagem:= 'Há uma atualização disponível para o app.' + sLineBreak + 'Deseja atualizar agora?';
    if MostrarVersao then
    begin
      VStrMensagem:= VStrMensagem + sLineBreak + 'Versão instalada: ' + VersaoAtual + sLineBreak + 'Atualização disponível: ' + VersaoAtualizacaoDisponivel;
    end;
    VMsg.MessageDialog(VStrMensagem, TMsgDlgType.mtConfirmation, FMX.Dialogs.mbYesNo, TMsgDlgBtn.mbYes, 0,
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
{$IFDEF ANDROID}
var
  PackageManager: JPackageManager;
  PackageInfo: JPackageInfo;
{$ENDIF}
begin
  //Obtem a versão atual do app
  {$IFDEF ANDROID}
  PackageManager := SharedActivityContext.getPackageManager;
  PackageInfo := PackageManager.getPackageInfo
  (SharedActivityContext.getPackageName, 0);
  result := JStringToString(PackageInfo.versionName);
  {$ENDIF}
end;

procedure TSelfUpdateDelphi.ProcessarAtualizacao;
var
  VTask: ITask;
begin
{$IFDEF ANDROID}
if VUsarDownloadManager then
begin
  BaixarAtualizacaoDownloadManager;
end
else
begin
{$ENDIF}
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
{$IFDEF ANDROID}
end;
{$ENDIF}
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
