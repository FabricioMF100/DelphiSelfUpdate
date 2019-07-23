# DelphiSelfUpdate
Classe Delphi criada pra atualização e instalação de apps

Versão: 1.0.1

**Versões do Android Testadas:**

Android 5.1, 
Android 6.0.1, 
Android 7.1, 
Android 8.1, 
Android 9

**OBSERVAÇÃO IMPORTANTE PARA Delphi 10.3.1 (Somente 10.3.1)**

Exite um bug na unit System.Net.HttpClient.pas original do Delphi 10.3.1 (Release 1) onde há problemas no uso com Thread, para resolver inclua a unit [../DelphiAutoUpdate/HotFix 10.3.1/System.Net.HttpClient.pas](System.Net.HttpClient.pas) corrigida que se encontra na pasta "HotFix 10.3.1" dentro da pasta do seu projeto, isso forçará o Delphi a utilizar a unit corrigida ao invés da problematica.
OBS: O problema não existe nas versões 10.3 e 10.3.2 e por tanto a unit corrigida não deve ser usada.

> Cortesia: Gledston Reis - Obrigado!

# Instruções:
**Permissões Delphi 10.3 (Rio):**

No menu Project > Options  vá até Application > Entitlement List e habilite "Secure File Sharing".
No mesmo menu, va em Application > Uses Permissions e habilite as permissões "Read External Storage" e "Write External Storage"
Abra o arquivo AndroidManifest.template.xml do seu projeto e logo após a linha:
```
<uses-sdk android:minSdkVersion="%minSdkVersion%" android:targetSdkVersion="%targetSdkVersion%" />
```
Adicione a seguinte linha:
```
<uses-permission android:name="android.permission.REQUEST_INSTALL_PACKAGES" />
```

# Como usar:

Copie a unit DelphiSelfUpdate [DelphiAutoUpdate/DelphiSelfUpdate/DelphiSelfUpdate.pas](DelphiSelfUpdate.pas) para a pasta do seu projeto, e no seu "Uses" adicione DelphiSelfUpdate e crie uma variavel do tipo TSelfUpdateDelphi passando no Create o seu form (usado como base para o dialogo de progresso).

```
var
  VUpdate: TSelfUpdateDelphi;
begin
  VUpdate:= TSelfUpdateDelphi.Create(Form1);
```

**Download e instalação simples**

 Chame o methodo Atualizar('Url de download do apk', 'nome do arquivo para salvar');

Exemplo:
```
  VUpdate.Atualizar('http://meusite.com/download/NomeDoApp.apk', 'MeuApp.apk');
```

**Checar versão via URL**

Para a verificação é usado um pequeno arquivo de texto com a mesma sintaxe de um arquivo .ini que pode ser adicionado a qualquer servidor web e acessado via URL.

Exemplo DelphiSelfUpdate.txt:
```
[App]
Versao=1.0.1
[Download]
Link=http://seusite.com/download/DemoDelphiAutoUpdate.apk
```

Existem 2 formas de realizar a verificação de atualização que são elas:

**Verificar se há atualização**

Para apenas verificar se existe uma nova versão e obter o link de download da atualização fornecido no txt use a função VerificarAtualizacao('Link do txt com informação de Versão', 'Versão Atual do app', VariavelQueReceberaOLink): boolean que retornará True caso haja uma nova versão.

> Obs: a função TSelfUpdateDelphi.ObterVersaoAtualApp pode ser utilizada para obter a versão atual instalada.

Exemplo:
```
var
  VTempLinkAtualizacao: string;
begin
 if VUpdate.VerificarAtualizacao('http://seusite.com/atualizacao.txt', TSelfUpdateDelphi.ObterVersaoAtualApp, VTempLinkAtualizacao) then
  begin
   Edit1.Text:= VTempLinkAtualizacao;
   TDialogService.ShowMessage('Há uma nova versão disponível para download.', nil);
  end
  else
  begin
   TDialogService.ShowMessage('Seu app está atualizado.', nil);
  end;
```

**Verificar se há atualização e perguntar se deseja atualizar**

Para verificar se existe uma nova versão e exibir uma mensagem para o usuário perguntando se deseja atualizar use a função VerificarAtualizacaoEPerguntar('Link do txt com informação de Versão', 'Versão Atual do app').

> Obs: a função TSelfUpdateDelphi.ObterVersaoAtualApp pode ser utilizada para obter a versão atual instalada.

Exemplo:
```
VUpdate.VerificarAtualizacaoEPerguntar(EdtLinkInfo.Text, TSelfUpdateDelphi.ObterVersaoAtualApp);
```
