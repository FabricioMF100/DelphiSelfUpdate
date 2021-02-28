unit Android.BroadcastReceiver;

interface

uses
  System.Classes,
  System.Generics.Collections,
  FMX.Platform,
  Androidapi.JNIBridge,
  Androidapi.JNI.App,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.JavaTypes,
  Androidapi.Helpers;

type
  TBroadcastReceiver = class
  public type
    TBroadcastReceiverEvent = procedure(const iAction: JString) of object;
    TBroadcastReceiverListener =
      class(TJavaLocal, JFMXBroadcastReceiverListener)
    private var
      FBroadcastReceiver: TBroadcastReceiver;
    public
      constructor Create(const iBroadcastReceiver: TBroadcastReceiver);
      procedure onReceive(context: JContext; intent: JIntent); cdecl;
    end;
  private var
    FBroadcastReceiverListener: JFMXBroadcastReceiverListener;
    FReceiver: JFMXBroadcastReceiver;
    FActions: TList<String>;
    FOnReceived: TBroadcastReceiverEvent;
  protected
    constructor Create;
    procedure SetReceiver;
    procedure UnsetReceiver;
  public
    destructor Destroy; override;
    procedure AddAction(const iActions: array of JString);
    procedure RemoveAction(const iAction: JString);
    procedure ClearAction;
    property OnReceived: TBroadcastReceiverEvent
      read FOnReceived write FOnReceived;
  end;

function BroadcastReceiver: TBroadcastReceiver;

implementation

uses
  System.UITypes,
  System.SysUtils,
  Androidapi.NativeActivity,
  FMX.Forms,
  FMX.Types;

var
  GBroadcastReceiver: TBroadcastReceiver = nil;

function BroadcastReceiver: TBroadcastReceiver;
begin
  if (GBroadcastReceiver = nil) then
    GBroadcastReceiver := TBroadcastReceiver.Create;

  Result := GBroadcastReceiver;
end;

{ TBroadcastReceiver.TBroadcastReceiverListener }

constructor TBroadcastReceiver.TBroadcastReceiverListener.Create(
  const iBroadcastReceiver: TBroadcastReceiver);
begin
  inherited Create;
  FBroadcastReceiver := iBroadcastReceiver;
end;

procedure TBroadcastReceiver.TBroadcastReceiverListener.onReceive(
  context: JContext;
  intent: JIntent);
var
  JStr: String;
  Str: String;

  procedure CallEvent;
  var
    Action: String;
  begin

    Action := JStr;
    TThread.CreateAnonymousThread(
      procedure
      begin
        TThread.Synchronize(
          TThread.CurrentThread,
          procedure
          begin
            if (Assigned(FBroadcastReceiver.FOnReceived)) then
              FBroadcastReceiver.FOnReceived(StringToJString(Action));
          end
        );
      end
    ).Start;
  end;

begin
  JStr := JStringToString(intent.getAction);

  for Str in FBroadcastReceiver.FActions do
    if (Str = JStr) then
      CallEvent;
end;

{ TReceiverListener }

procedure TBroadcastReceiver.AddAction(const iActions: array of JString);
var
  Str: String;
  JStr: String;
  Action: JString;
  OK: Boolean;
  Changed: Boolean;
begin
  Changed := False;

  for Action in iActions do
  begin
    OK := True;

    JStr := JStringToString(Action);

    for Str in FActions do
      if (Str = JStr) then
      begin
        OK := False;
        Break;
      end;

    if (OK) then begin
      FActions.Add(JStr);
      Changed := True;
    end;
  end;

  if (Changed) then
    SetReceiver;

end;

procedure TBroadcastReceiver.ClearAction;
begin
  FActions.Clear;
  UnsetReceiver;
end;

constructor TBroadcastReceiver.Create;
begin
  inherited;

  FActions := TList<String>.Create;
  SetReceiver;
end;

destructor TBroadcastReceiver.Destroy;
begin
  UnsetReceiver;

  FActions.DisposeOf;

  inherited;
end;

procedure TBroadcastReceiver.RemoveAction(const iAction: JString);
var
  i: Integer;
  JStr: String;
begin
  JStr := JStringToString(iAction);

  for i := 0 to FActions.Count - 1 do
    if (FActions[i] = JStr) then
    begin
      FActions.Delete(i);
      SetReceiver;
      Break;
    end;
end;

procedure TBroadcastReceiver.SetReceiver;
var
  Filter: JIntentFilter;
  Str: String;
begin
  if (FReceiver <> nil) then
    UnsetReceiver;

  Filter := TJIntentFilter.JavaClass.init;

  for Str in FActions do
    Filter.addAction(StringToJString(Str));

  FBroadcastReceiverListener := TBroadcastReceiverListener.Create(Self);
  FReceiver :=
    TJFMXBroadcastReceiver.JavaClass.init(FBroadcastReceiverListener);

  try
    TAndroidHelper.Context.getApplicationContext.registerReceiver(
      FReceiver,
      Filter);
  except
    on E: Exception do
      Log.d('Exception: %s', [E.Message]);
  end;

end;

procedure TBroadcastReceiver.UnsetReceiver;
begin
  try

    if (FReceiver <> nil) and (not (TAndroidHelper.Context as JActivity).isFinishing) then
    begin
         TAndroidHelper.Context.getApplicationContext.unregisterReceiver(FReceiver);
    end;

  except

  end;

  FReceiver := nil;

end;

initialization
finalization
  if (GBroadcastReceiver <> nil) then
    GBroadcastReceiver.DisposeOf;

end.
