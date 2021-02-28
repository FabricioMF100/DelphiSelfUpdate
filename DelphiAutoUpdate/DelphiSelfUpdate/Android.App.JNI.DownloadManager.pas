//Arquivo gerado em 31/01/2020 10:49:49 by Gledston Reis(gledstonreis@gmail.com)

unit Android.App.JNI.DownloadManager;

interface

uses
  Androidapi.JNIBridge,
  Androidapi.JNI.Analytics,
  Androidapi.JNI.ApkExpansion,
  Androidapi.JNI.App,
  Androidapi.JNI.Dalvik,
  Androidapi.JNI.Embarcadero,
  Androidapi.JNI.GraphicsContentViewText,
  Androidapi.JNI.InputMethodService,
  Androidapi.JNI.JavaTypes,
  Androidapi.JNI.Licensing,
  Androidapi.JNI.Net,
  Androidapi.JNI.OpenGL,
  Androidapi.JNI.Os,
  Androidapi.JNI.PlayServices,
  Androidapi.JNI.Provider,
  Androidapi.JNI.Support,
  Androidapi.JNI.Telephony,
  Androidapi.JNI.Util,
  Androidapi.JNI.VideoView,
  Androidapi.JNI.Webkit,
  Androidapi.JNI.Widget;

type
  JBufferedInputStream = interface; {java/io/BufferedInputStream}
  JDownloadManager = interface; {android/app/DownloadManager}
  JDownloadManager_Query = interface; {android/app/DownloadManager$Query}
  JDownloadManager_Request = interface; {android/app/DownloadManager$Request}
  JEnvironment = interface; {android/os/Environment}
  JSystem = interface; {java/lang/System}

  JBufferedInputStreamClass = interface(JObjectClass {java/io/FilterInputStream})
    ['{A0DBBECD-981D-4FFA-B15F-D5DFF8294DE4}']
    function init(&in: JInputStream): JBufferedInputStream; cdecl; overload;
    function init(&in: JInputStream; size: Integer): JBufferedInputStream; cdecl; overload;
  end;

  [JavaSignature('java/io/BufferedInputStream')]
  JBufferedInputStream = interface(JObject {java/io/FilterInputStream})
    ['{122C21FA-20F6-4CCA-B4D0-2C7FA54561CD}']
    function available: Integer; cdecl;
    procedure close; cdecl;
    procedure mark(readlimit: Integer); cdecl;
    function markSupported: Boolean; cdecl;
    function &read: Integer; cdecl; overload;
    function &read(b: TJavaArray<Byte>; off: Integer; len: Integer): Integer; cdecl; overload;
    procedure reset; cdecl;
    function skip(n: Int64): Int64; cdecl;
  end;

  TJBufferedInputStream = class(TJavaGenericImport<JBufferedInputStreamClass, JBufferedInputStream>)
  end;

  JDownloadManagerClass = interface(JObjectClass)
    ['{72764009-DADA-4B46-B981-F5D41F1BE2F6}']
    function _GetACTION_DOWNLOAD_COMPLETE: JString;
    function _GetACTION_NOTIFICATION_CLICKED: JString;
    function _GetACTION_VIEW_DOWNLOADS: JString;
    function _GetCOLUMN_BYTES_DOWNLOADED_SO_FAR: JString;
    function _GetCOLUMN_DESCRIPTION: JString;
    function _GetCOLUMN_ID: JString;
    function _GetCOLUMN_LAST_MODIFIED_TIMESTAMP: JString;
    function _GetCOLUMN_LOCAL_FILENAME: JString;
    function _GetCOLUMN_LOCAL_URI: JString;
    function _GetCOLUMN_MEDIAPROVIDER_URI: JString;
    function _GetCOLUMN_MEDIA_TYPE: JString;
    function _GetCOLUMN_REASON: JString;
    function _GetCOLUMN_STATUS: JString;
    function _GetCOLUMN_TITLE: JString;
    function _GetCOLUMN_TOTAL_SIZE_BYTES: JString;
    function _GetCOLUMN_URI: JString;
    function _GetERROR_CANNOT_RESUME: Integer;
    function _GetERROR_DEVICE_NOT_FOUND: Integer;
    function _GetERROR_FILE_ALREADY_EXISTS: Integer;
    function _GetERROR_FILE_ERROR: Integer;
    function _GetERROR_HTTP_DATA_ERROR: Integer;
    function _GetERROR_INSUFFICIENT_SPACE: Integer;
    function _GetERROR_TOO_MANY_REDIRECTS: Integer;
    function _GetERROR_UNHANDLED_HTTP_CODE: Integer;
    function _GetERROR_UNKNOWN: Integer;
    function _GetEXTRA_DOWNLOAD_ID: JString;
    function _GetEXTRA_NOTIFICATION_CLICK_DOWNLOAD_IDS: JString;
    function _GetINTENT_EXTRAS_SORT_BY_SIZE: JString;
    function _GetPAUSED_QUEUED_FOR_WIFI: Integer;
    function _GetPAUSED_UNKNOWN: Integer;
    function _GetPAUSED_WAITING_FOR_NETWORK: Integer;
    function _GetPAUSED_WAITING_TO_RETRY: Integer;
    function _GetSTATUS_FAILED: Integer;
    function _GetSTATUS_PAUSED: Integer;
    function _GetSTATUS_PENDING: Integer;
    function _GetSTATUS_RUNNING: Integer;
    function _GetSTATUS_SUCCESSFUL: Integer;
    function getMaxBytesOverMobile(context: JContext): JLong; cdecl;
    function getRecommendedMaxBytesOverMobile(context: JContext): JLong; cdecl;
    property ACTION_DOWNLOAD_COMPLETE: JString read _GetACTION_DOWNLOAD_COMPLETE;
    property ACTION_NOTIFICATION_CLICKED: JString read _GetACTION_NOTIFICATION_CLICKED;
    property ACTION_VIEW_DOWNLOADS: JString read _GetACTION_VIEW_DOWNLOADS;
    property COLUMN_BYTES_DOWNLOADED_SO_FAR: JString read _GetCOLUMN_BYTES_DOWNLOADED_SO_FAR;
    property COLUMN_DESCRIPTION: JString read _GetCOLUMN_DESCRIPTION;
    property COLUMN_ID: JString read _GetCOLUMN_ID;
    property COLUMN_LAST_MODIFIED_TIMESTAMP: JString read _GetCOLUMN_LAST_MODIFIED_TIMESTAMP;
    property COLUMN_LOCAL_FILENAME: JString read _GetCOLUMN_LOCAL_FILENAME;
    property COLUMN_LOCAL_URI: JString read _GetCOLUMN_LOCAL_URI;
    property COLUMN_MEDIAPROVIDER_URI: JString read _GetCOLUMN_MEDIAPROVIDER_URI;
    property COLUMN_MEDIA_TYPE: JString read _GetCOLUMN_MEDIA_TYPE;
    property COLUMN_REASON: JString read _GetCOLUMN_REASON;
    property COLUMN_STATUS: JString read _GetCOLUMN_STATUS;
    property COLUMN_TITLE: JString read _GetCOLUMN_TITLE;
    property COLUMN_TOTAL_SIZE_BYTES: JString read _GetCOLUMN_TOTAL_SIZE_BYTES;
    property COLUMN_URI: JString read _GetCOLUMN_URI;
    property ERROR_CANNOT_RESUME: Integer read _GetERROR_CANNOT_RESUME;
    property ERROR_DEVICE_NOT_FOUND: Integer read _GetERROR_DEVICE_NOT_FOUND;
    property ERROR_FILE_ALREADY_EXISTS: Integer read _GetERROR_FILE_ALREADY_EXISTS;
    property ERROR_FILE_ERROR: Integer read _GetERROR_FILE_ERROR;
    property ERROR_HTTP_DATA_ERROR: Integer read _GetERROR_HTTP_DATA_ERROR;
    property ERROR_INSUFFICIENT_SPACE: Integer read _GetERROR_INSUFFICIENT_SPACE;
    property ERROR_TOO_MANY_REDIRECTS: Integer read _GetERROR_TOO_MANY_REDIRECTS;
    property ERROR_UNHANDLED_HTTP_CODE: Integer read _GetERROR_UNHANDLED_HTTP_CODE;
    property ERROR_UNKNOWN: Integer read _GetERROR_UNKNOWN;
    property EXTRA_DOWNLOAD_ID: JString read _GetEXTRA_DOWNLOAD_ID;
    property EXTRA_NOTIFICATION_CLICK_DOWNLOAD_IDS: JString read _GetEXTRA_NOTIFICATION_CLICK_DOWNLOAD_IDS;
    property INTENT_EXTRAS_SORT_BY_SIZE: JString read _GetINTENT_EXTRAS_SORT_BY_SIZE;
    property PAUSED_QUEUED_FOR_WIFI: Integer read _GetPAUSED_QUEUED_FOR_WIFI;
    property PAUSED_UNKNOWN: Integer read _GetPAUSED_UNKNOWN;
    property PAUSED_WAITING_FOR_NETWORK: Integer read _GetPAUSED_WAITING_FOR_NETWORK;
    property PAUSED_WAITING_TO_RETRY: Integer read _GetPAUSED_WAITING_TO_RETRY;
    property STATUS_FAILED: Integer read _GetSTATUS_FAILED;
    property STATUS_PAUSED: Integer read _GetSTATUS_PAUSED;
    property STATUS_PENDING: Integer read _GetSTATUS_PENDING;
    property STATUS_RUNNING: Integer read _GetSTATUS_RUNNING;
    property STATUS_SUCCESSFUL: Integer read _GetSTATUS_SUCCESSFUL;
  end;

  [JavaSignature('android/app/DownloadManager')]
  JDownloadManager = interface(JObject)
    ['{E027A8B7-8ABD-4BDE-B960-1C0070557D9A}']
    function addCompletedDownload(title: JString; description: JString; isMediaScannerScannable: Boolean; mimeType: JString; path: JString; length: Int64; showNotification: Boolean): Int64; cdecl; overload;
    function addCompletedDownload(title: JString; description: JString; isMediaScannerScannable: Boolean; mimeType: JString; path: JString; length: Int64; showNotification: Boolean; uri: Jnet_Uri; referer: Jnet_Uri): Int64; cdecl; overload;
    function enqueue(request: JDownloadManager_Request): Int64; cdecl;
    function getMimeTypeForDownloadedFile(id: Int64): JString; cdecl;
    function getUriForDownloadedFile(id: Int64): Jnet_Uri; cdecl;
    function openDownloadedFile(id: Int64): JParcelFileDescriptor; cdecl;
    function query(query: JDownloadManager_Query): JCursor; cdecl;
    function remove(ids: TJavaArray<Int64>): Integer; cdecl;
  end;

  TJDownloadManager = class(TJavaGenericImport<JDownloadManagerClass, JDownloadManager>)
  end;

  JDownloadManager_QueryClass = interface(JObjectClass)
    ['{ECAED53C-DBB0-4CBA-9936-CAFA8629D4DF}']
    function init: JDownloadManager_Query; cdecl;
  end;

  [JavaSignature('android/app/DownloadManager$Query')]
  JDownloadManager_Query = interface(JObject)
    ['{13CB2F22-99D0-4396-A802-F639ECBA9954}']
    function setFilterById(ids: TJavaArray<Int64>): JDownloadManager_Query; cdecl;
    function setFilterByStatus(flags: Integer): JDownloadManager_Query; cdecl;
  end;

  TJDownloadManager_Query = class(TJavaGenericImport<JDownloadManager_QueryClass, JDownloadManager_Query>)
  end;

  JDownloadManager_RequestClass = interface(JObjectClass)
    ['{43B5A570-1FE6-41E2-84D1-33FD7D5E7D2A}']
    function _GetNETWORK_MOBILE: Integer;
    function _GetNETWORK_WIFI: Integer;
    function _GetVISIBILITY_HIDDEN: Integer;
    function _GetVISIBILITY_VISIBLE: Integer;
    function _GetVISIBILITY_VISIBLE_NOTIFY_COMPLETED: Integer;
    function _GetVISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION: Integer;
    function init(uri: Jnet_Uri): JDownloadManager_Request; cdecl;
    property NETWORK_MOBILE: Integer read _GetNETWORK_MOBILE;
    property NETWORK_WIFI: Integer read _GetNETWORK_WIFI;
    property VISIBILITY_HIDDEN: Integer read _GetVISIBILITY_HIDDEN;
    property VISIBILITY_VISIBLE: Integer read _GetVISIBILITY_VISIBLE;
    property VISIBILITY_VISIBLE_NOTIFY_COMPLETED: Integer read _GetVISIBILITY_VISIBLE_NOTIFY_COMPLETED;
    property VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION: Integer read _GetVISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION;
  end;

  [JavaSignature('android/app/DownloadManager$Request')]
  JDownloadManager_Request = interface(JObject)
    ['{C3743647-50A6-4A6B-83CC-4CC3DF377CBB}']
    function addRequestHeader(header: JString; value: JString): JDownloadManager_Request; cdecl;
    procedure allowScanningByMediaScanner; cdecl;
    function setAllowedNetworkTypes(flags: Integer): JDownloadManager_Request; cdecl;
    function setAllowedOverMetered(allow: Boolean): JDownloadManager_Request; cdecl;
    function setAllowedOverRoaming(allowed: Boolean): JDownloadManager_Request; cdecl;
    function setDescription(description: JCharSequence): JDownloadManager_Request; cdecl;
    function setDestinationInExternalFilesDir(context: JContext; dirType: JString; subPath: JString): JDownloadManager_Request; cdecl;
    function setDestinationInExternalPublicDir(dirType: JString; subPath: JString): JDownloadManager_Request; cdecl;
    function setDestinationUri(uri: Jnet_Uri): JDownloadManager_Request; cdecl;
    function setMimeType(mimeType: JString): JDownloadManager_Request; cdecl;
    function setNotificationVisibility(visibility: Integer): JDownloadManager_Request; cdecl;
    function setRequiresCharging(requiresCharging: Boolean): JDownloadManager_Request; cdecl;
    function setRequiresDeviceIdle(requiresDeviceIdle: Boolean): JDownloadManager_Request; cdecl;
    function setShowRunningNotification(show: Boolean): JDownloadManager_Request; cdecl; deprecated;
    function setTitle(title: JCharSequence): JDownloadManager_Request; cdecl;
    function setVisibleInDownloadsUi(isVisible: Boolean): JDownloadManager_Request; cdecl;
  end;

  TJDownloadManager_Request = class(TJavaGenericImport<JDownloadManager_RequestClass, JDownloadManager_Request>)
  end;

  JEnvironmentClass = interface(JObjectClass)
    ['{E92D1E85-A1CF-4E8C-A15F-29866739D5FA}']
    function _GetDIRECTORY_ALARMS: JString;
    procedure _SetDIRECTORY_ALARMS(Value: JString);
    function _GetDIRECTORY_DCIM: JString;
    procedure _SetDIRECTORY_DCIM(Value: JString);
    function _GetDIRECTORY_DOCUMENTS: JString;
    procedure _SetDIRECTORY_DOCUMENTS(Value: JString);
    function _GetDIRECTORY_DOWNLOADS: JString;
    procedure _SetDIRECTORY_DOWNLOADS(Value: JString);
    function _GetDIRECTORY_MOVIES: JString;
    procedure _SetDIRECTORY_MOVIES(Value: JString);
    function _GetDIRECTORY_MUSIC: JString;
    procedure _SetDIRECTORY_MUSIC(Value: JString);
    function _GetDIRECTORY_NOTIFICATIONS: JString;
    procedure _SetDIRECTORY_NOTIFICATIONS(Value: JString);
    function _GetDIRECTORY_PICTURES: JString;
    procedure _SetDIRECTORY_PICTURES(Value: JString);
    function _GetDIRECTORY_PODCASTS: JString;
    procedure _SetDIRECTORY_PODCASTS(Value: JString);
    function _GetDIRECTORY_RINGTONES: JString;
    procedure _SetDIRECTORY_RINGTONES(Value: JString);
    function _GetMEDIA_BAD_REMOVAL: JString;
    function _GetMEDIA_CHECKING: JString;
    function _GetMEDIA_EJECTING: JString;
    function _GetMEDIA_MOUNTED: JString;
    function _GetMEDIA_MOUNTED_READ_ONLY: JString;
    function _GetMEDIA_NOFS: JString;
    function _GetMEDIA_REMOVED: JString;
    function _GetMEDIA_SHARED: JString;
    function _GetMEDIA_UNKNOWN: JString;
    function _GetMEDIA_UNMOUNTABLE: JString;
    function _GetMEDIA_UNMOUNTED: JString;
    function init: JEnvironment; cdecl;
    function getDataDirectory: JFile; cdecl;
    function getDownloadCacheDirectory: JFile; cdecl;
    function getExternalStorageDirectory: JFile; cdecl;
    function getExternalStoragePublicDirectory(&type: JString): JFile; cdecl;
    function getExternalStorageState: JString; cdecl; overload;
    function getExternalStorageState(path: JFile): JString; cdecl; overload;
    function getRootDirectory: JFile; cdecl;
    function getStorageState(path: JFile): JString; cdecl; deprecated;
    function isExternalStorageEmulated: Boolean; cdecl; overload;
    function isExternalStorageEmulated(path: JFile): Boolean; cdecl; overload;
    function isExternalStorageRemovable: Boolean; cdecl; overload;
    function isExternalStorageRemovable(path: JFile): Boolean; cdecl; overload;
    property DIRECTORY_ALARMS: JString read _GetDIRECTORY_ALARMS write _SetDIRECTORY_ALARMS;
    property DIRECTORY_DCIM: JString read _GetDIRECTORY_DCIM write _SetDIRECTORY_DCIM;
    property DIRECTORY_DOCUMENTS: JString read _GetDIRECTORY_DOCUMENTS write _SetDIRECTORY_DOCUMENTS;
    property DIRECTORY_DOWNLOADS: JString read _GetDIRECTORY_DOWNLOADS write _SetDIRECTORY_DOWNLOADS;
    property DIRECTORY_MOVIES: JString read _GetDIRECTORY_MOVIES write _SetDIRECTORY_MOVIES;
    property DIRECTORY_MUSIC: JString read _GetDIRECTORY_MUSIC write _SetDIRECTORY_MUSIC;
    property DIRECTORY_NOTIFICATIONS: JString read _GetDIRECTORY_NOTIFICATIONS write _SetDIRECTORY_NOTIFICATIONS;
    property DIRECTORY_PICTURES: JString read _GetDIRECTORY_PICTURES write _SetDIRECTORY_PICTURES;
    property DIRECTORY_PODCASTS: JString read _GetDIRECTORY_PODCASTS write _SetDIRECTORY_PODCASTS;
    property DIRECTORY_RINGTONES: JString read _GetDIRECTORY_RINGTONES write _SetDIRECTORY_RINGTONES;
    property MEDIA_BAD_REMOVAL: JString read _GetMEDIA_BAD_REMOVAL;
    property MEDIA_CHECKING: JString read _GetMEDIA_CHECKING;
    property MEDIA_EJECTING: JString read _GetMEDIA_EJECTING;
    property MEDIA_MOUNTED: JString read _GetMEDIA_MOUNTED;
    property MEDIA_MOUNTED_READ_ONLY: JString read _GetMEDIA_MOUNTED_READ_ONLY;
    property MEDIA_NOFS: JString read _GetMEDIA_NOFS;
    property MEDIA_REMOVED: JString read _GetMEDIA_REMOVED;
    property MEDIA_SHARED: JString read _GetMEDIA_SHARED;
    property MEDIA_UNKNOWN: JString read _GetMEDIA_UNKNOWN;
    property MEDIA_UNMOUNTABLE: JString read _GetMEDIA_UNMOUNTABLE;
    property MEDIA_UNMOUNTED: JString read _GetMEDIA_UNMOUNTED;
  end;

  [JavaSignature('android/os/Environment')]
  JEnvironment = interface(JObject)
    ['{A90B21FB-FF9B-4272-9772-34ED952FE63E}']
  end;

  TJEnvironment = class(TJavaGenericImport<JEnvironmentClass, JEnvironment>)
  end;

  JSystemClass = interface(JObjectClass)
    ['{BE70A2E8-7922-4B08-93A3-986D9D6828DF}']
    function _Geterr: JPrintStream;
    procedure _Seterr(Value: JPrintStream);
    function _Getin: JInputStream;
    procedure _Setin(Value: JInputStream);
    function _Getout: JPrintStream;
    procedure _Setout(Value: JPrintStream);
    procedure arraycopy(param0: JObject; param1: Integer; param2: JObject; param3: Integer; param4: Integer); cdecl;
    function clearProperty(key: JString): JString; cdecl;
    function console: JObject {java/io/Console}; cdecl;
    function currentTimeMillis: Int64; cdecl;
    procedure exit(status: Integer); cdecl;
    procedure gc; cdecl;
    function getenv(name: JString): JString; cdecl; overload;
    function getenv: JMap; cdecl; overload;
    function getProperties: JObject {java/util/Properties}; cdecl;
    function getProperty(key: JString): JString; cdecl; overload;
    function getProperty(key: JString; def: JString): JString; cdecl; overload;
    function getSecurityManager: JObject {java/lang/SecurityManager}; cdecl;
    function identityHashCode(x: JObject): Integer; cdecl;
    function inheritedChannel: JObject {java/nio/channels/Channel}; cdecl;
    function lineSeparator: JString; cdecl;
    procedure load(filename: JString); cdecl;
    procedure loadLibrary(libname: JString); cdecl;
    function mapLibraryName(param0: JString): JString; cdecl;
    function nanoTime: Int64; cdecl;
    procedure runFinalization; cdecl;
    procedure runFinalizersOnExit(value: Boolean); cdecl; deprecated;
    procedure setErr(err: JPrintStream); cdecl;
    procedure setIn(&in: JInputStream); cdecl;
    procedure setOut(&out: JPrintStream); cdecl;
    procedure setProperties(props: JObject {java/util/Properties}); cdecl;
    function setProperty(key: JString; value: JString): JString; cdecl;
    procedure setSecurityManager(s: JObject {java/lang/SecurityManager}); cdecl;
    property err: JPrintStream read _Geterr write _Seterr;
    property &in: JInputStream read _Getin write _Setin;
    property &out: JPrintStream read _Getout write _Setout;
  end;

  [JavaSignature('java/lang/System')]
  JSystem = interface(JObject)
    ['{50848C0A-129E-4618-8B5F-33474B3BFEFA}']
  end;

  TJSystem = class(TJavaGenericImport<JSystemClass, JSystem>)
  end;

const
  TJDownloadManager_ACTION_DOWNLOAD_COMPLETE = 'android.intent.action.DOWNLOAD_COMPLETE';
  TJDownloadManager_ACTION_NOTIFICATION_CLICKED = 'android.intent.action.DOWNLOAD_NOTIFICATION_CLICKED';
  TJDownloadManager_ACTION_VIEW_DOWNLOADS = 'android.intent.action.VIEW_DOWNLOADS';
  TJDownloadManager_COLUMN_BYTES_DOWNLOADED_SO_FAR = 'bytes_so_far';
  TJDownloadManager_COLUMN_DESCRIPTION = 'description';
  TJDownloadManager_COLUMN_ID = '_id';
  TJDownloadManager_COLUMN_LAST_MODIFIED_TIMESTAMP = 'last_modified_timestamp';
  TJDownloadManager_COLUMN_LOCAL_FILENAME = 'local_filename';
  TJDownloadManager_COLUMN_LOCAL_URI = 'local_uri';
  TJDownloadManager_COLUMN_MEDIAPROVIDER_URI = 'mediaprovider_uri';
  TJDownloadManager_COLUMN_MEDIA_TYPE = 'media_type';
  TJDownloadManager_COLUMN_REASON = 'reason';
  TJDownloadManager_COLUMN_STATUS = 'status';
  TJDownloadManager_COLUMN_TITLE = 'title';
  TJDownloadManager_COLUMN_TOTAL_SIZE_BYTES = 'total_size';
  TJDownloadManager_COLUMN_URI = 'uri';
  TJDownloadManager_ERROR_CANNOT_RESUME = 1008;
  TJDownloadManager_ERROR_DEVICE_NOT_FOUND = 1007;
  TJDownloadManager_ERROR_FILE_ALREADY_EXISTS = 1009;
  TJDownloadManager_ERROR_FILE_ERROR = 1001;
  TJDownloadManager_ERROR_HTTP_DATA_ERROR = 1004;
  TJDownloadManager_ERROR_INSUFFICIENT_SPACE = 1006;
  TJDownloadManager_ERROR_TOO_MANY_REDIRECTS = 1005;
  TJDownloadManager_ERROR_UNHANDLED_HTTP_CODE = 1002;
  TJDownloadManager_ERROR_UNKNOWN = 1000;
  TJDownloadManager_EXTRA_DOWNLOAD_ID = 'extra_download_id';
  TJDownloadManager_EXTRA_NOTIFICATION_CLICK_DOWNLOAD_IDS = 'extra_click_download_ids';
  TJDownloadManager_INTENT_EXTRAS_SORT_BY_SIZE = 'android.app.DownloadManager.extra_sortBySize';
  TJDownloadManager_PAUSED_QUEUED_FOR_WIFI = 3;
  TJDownloadManager_PAUSED_UNKNOWN = 4;
  TJDownloadManager_PAUSED_WAITING_FOR_NETWORK = 2;
  TJDownloadManager_PAUSED_WAITING_TO_RETRY = 1;
  TJDownloadManager_STATUS_FAILED = 16;
  TJDownloadManager_STATUS_PAUSED = 4;
  TJDownloadManager_STATUS_PENDING = 1;
  TJDownloadManager_STATUS_RUNNING = 2;
  TJDownloadManager_STATUS_SUCCESSFUL = 8;

  TJDownloadManager_Request_NETWORK_MOBILE = 1;
  TJDownloadManager_Request_NETWORK_WIFI = 2;
  TJDownloadManager_Request_VISIBILITY_HIDDEN = 2;
  TJDownloadManager_Request_VISIBILITY_VISIBLE = 0;
  TJDownloadManager_Request_VISIBILITY_VISIBLE_NOTIFY_COMPLETED = 1;
  TJDownloadManager_Request_VISIBILITY_VISIBLE_NOTIFY_ONLY_COMPLETION = 3;

  TJEnvironment_MEDIA_BAD_REMOVAL = 'bad_removal';
  TJEnvironment_MEDIA_CHECKING = 'checking';
  TJEnvironment_MEDIA_EJECTING = 'ejecting';
  TJEnvironment_MEDIA_MOUNTED = 'mounted';
  TJEnvironment_MEDIA_MOUNTED_READ_ONLY = 'mounted_ro';
  TJEnvironment_MEDIA_NOFS = 'nofs';
  TJEnvironment_MEDIA_REMOVED = 'removed';
  TJEnvironment_MEDIA_SHARED = 'shared';
  TJEnvironment_MEDIA_UNKNOWN = 'unknown';
  TJEnvironment_MEDIA_UNMOUNTABLE = 'unmountable';
  TJEnvironment_MEDIA_UNMOUNTED = 'unmounted';

implementation

procedure RegisterTypes;
begin
  TRegTypes.RegisterType('Android.App.JNI.DownloadManager.JBufferedInputStream', TypeInfo(Android.App.JNI.DownloadManager.JBufferedInputStream));
  TRegTypes.RegisterType('Android.App.JNI.DownloadManager.JDownloadManager', TypeInfo(Android.App.JNI.DownloadManager.JDownloadManager));
  TRegTypes.RegisterType('Android.App.JNI.DownloadManager.JDownloadManager_Query', TypeInfo(Android.App.JNI.DownloadManager.JDownloadManager_Query));
  TRegTypes.RegisterType('Android.App.JNI.DownloadManager.JDownloadManager_Request', TypeInfo(Android.App.JNI.DownloadManager.JDownloadManager_Request));
  TRegTypes.RegisterType('Android.App.JNI.DownloadManager.JEnvironment', TypeInfo(Android.App.JNI.DownloadManager.JEnvironment));
  TRegTypes.RegisterType('Android.App.JNI.DownloadManager.JSystem', TypeInfo(Android.App.JNI.DownloadManager.JSystem));
end;

initialization
  RegisterTypes;
end.