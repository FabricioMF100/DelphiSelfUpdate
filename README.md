# DelphiSelfUpdate
Classe Delphi criada pra atualização e instalação de apps

Versão: 1.0.1

**OBSERVAÇÃO IMPORTANTE PARA Delphi 10.3.1 (Somente 10.3.1)**
Exite um bug na unit System.Net.HttpClient.pas original do Delphi 10.3.1 (Release 1) onde há problemas no uso com Thread, para resolver inclua a unit corrigida que se encontra na pasta "HotFix 10.3.1" dentro da pasta do seu projeto, isso forçará o Delphi a utilizar a unit corrigida ao invés da problematica.
OBS: O problema não existe nas versões 10.3 e 10.3.2 e por tanto a unit corrigida não deve ser usada.

> Cortesia: Gledston Reis - Obrigado!

# Instruções:
**Permissões Delphi 10.3 (Rio):**

No menu Project > Options  vá até Application > Entitlement List e habilite "Secure File Sharing".
No mesmo menu, va em Application > Uses Permissions e habilite as permissões "Read External Storage" e "Write External Storage"
Abra o arquivo AndroidManifest.template.xml do seu projeto e logo após a linha
> <uses-sdk android:minSdkVersion="%minSdkVersion%" android:targetSdkVersion="%targetSdkVersion%" />
Adicione a seguinte linha
> <uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />

# Como usar:
Copie essa unit para a pasta do seu projeto, e no seu "Uses" adicione DelphiSelfUpdate crie uma variavel do tipo TSelfUpdateDelphi passando no Create o seu form (usado como base para o dialogo de progresso) chame o methodo Atualizar('Url de download do apk', 'nome do arquivo para salvar');

Exemplo:
`
var
  VUpdate: TSelfUpdateDelphi;
begin
  VUpdate:= TSelfUpdateDelphi.Create(Form1);
  VUpdate.Atualizar('http://meusite.com/download/NomeDoApp.apk', 'MeuApp.apk');
`
