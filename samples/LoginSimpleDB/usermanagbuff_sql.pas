unit userManagBuff_sql;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, db, SdfData, FileUtil, Forms, Controls, Graphics, Dialogs,
  ZDataset, UserManagementBase, ZConnection, prfCommon;


type

  TUserBufferState = (ubUnkwown, ubNotValid, ubServer, ubLocal);

  { TUserManagementSQL }

  TUserManagementSQL = class(TUserManagement)
    Q_Login: TZQuery;
    Q_LoginAktiv: TStringField;
    Q_LoginBerechtigungID: TLongintField;
    Q_LoginNameBerechtigung: TStringField;
    Q_LoginUserID: TSmallintField;
    Q_LoginUsername: TStringField;
    Q_LoginUserpasswort: TStringField;
    BuffData: TSdfDataSet;
    SQLCon1: TZConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    function GetConnected: Boolean;
  protected
    FLastUser : String;
    FLastPass : String;
    FBuffedAge: QWord;
    FBuffedState: TUserBufferState;
    FFilename: String;
    function CheckPrerequisites:boolean;
    procedure SetCon(AValue: TZConnection); override;
  public
    procedure CheckUserPassAccess(user, pass, SecurityCode: String;
      var UserCanDo: Boolean);
    procedure CanAccess(securityCode: String; var CanAccess: Boolean); override;
    procedure CheckUserAndPass(user, pass: String; var aUID: Integer;
      var ValidUser: Boolean; LoginAction: Boolean); override;
    function GetUser: String; override;
    function Connect: Boolean;
    function BufferStateToText: String;
    procedure Disconnect;
    property Connected: Boolean read GetConnected;
    property BufferState: TUserBufferState read FBuffedState;
  end;

function GetUserManagement:TUserManagement;
function GetConnectionUser:TUserManagementSQL;


implementation

uses
  LazLogger
  , utilities
  ;

{$R *.lfm}

var
  UserManagementSQL: TUserManagementSQL;

const
  co_Server = 'WINDEV';

function GetUserManagement: TUserManagement;
begin
  Result := TUserManagement(GetConnectionUser);
end;

function GetConnectionUser: TUserManagementSQL;
begin
  if not Assigned(UserManagementSQL) then begin
    UserManagementSQL := TUserManagementSQL.Create(nil);
    UserManagementSQL.Connection.Database:= 'Hugo_admin';
    UserManagementSQL.Connection.HostName:= co_Server;
    UserManagementSQL.Connection.User:='Admin';
    UserManagementSQL.Connection.Password := 'Secret';
  end ;
  Result := UserManagementSQL;

end;

{ TUserManagementSQL }

procedure TUserManagementSQL.DataModuleCreate(Sender: TObject);
begin
  DebugLn('TUserManagementSQL.DataModuleCreate start');
  FCon := nil;
  FBuffedAge:= 0;
  FBuffedState:= ubUnkwown;
  FFilename:= IncludeTrailingPathDelimiter(ExtractFileDir(ProgramDirectory))+ '1234.csv';
  try
     DebugLn('normal SQL');
     CheckPrerequisites;
    // Nothing to do yet
     SQLCon1.Connected:=false;
     //
     SQLCon1.Protocol := 'FreeTDS_MsSQL>=2005';
     SQLCon1.HostName:= coConnection;
     SQLCon1.User:='admin';
     SQLCon1.Password := 'secret';
     SQLCon1.Database:= coDatabase;
     //
  finally
     //
  end;
  DebugLn('TUserManagementSQL.DataModuleCreate end');
end;

function TUserManagementSQL.GetConnected: Boolean;
begin
  Result:= Connection.Connected;
end;

procedure TUserManagementSQL.SetCon(AValue: TZConnection);
begin
  Inherited SetCon(AValue);
  if Connection = AValue then exit; //-->>
  Q_Login.Connection:= AValue;
end;

function TUserManagementSQL.CheckPrerequisites: boolean;
var
  Drivername: String;
begin
  Result:= False;
  Drivername:= IncludeTrailingPathDelimiter(ExtractFileDir(ProgramDirectory))+ 'sybdb.dll';
  try
    if not FileExists(Drivername) then
      Result:= LoadFromResourceAndMakeFile(HINSTANCE,'SYBDB',Drivername)
    else
      Result := True;
  except
    DebugLn('TUserManagementSQL.CheckPrerequisites cannot create Driverfile sybdb.dll');
    Result:= false;
  end;
end;

procedure TUserManagementSQL.CanAccess(securityCode: String;
  var CanAccess: Boolean);
var
  Code, tmp1, tmp2, tmp3:string;
  tmp4: Boolean;
begin
  CanAccess := false;
  if not Connect then
    exit; // -->>
  if BuffData.Active then
    BuffData.Active:= False;
  BuffData.FileName:=FFilename;
  BuffData.FileMustExist:=True;
  BuffData.FirstLineAsSchema:=True;
  try
    BuffData.Active:=True;
  finally
    //
  end;
  BuffData.First;
  while NOT (BuffData.EOF) do begin
    // if an result is here, the user and password is valid
    tmp1:= UpperCase(BuffData.FieldByName('Q_LoginUsername').AsString);
    tmp2:= BuffData.FieldByName('Q_LoginUserpasswort').AsString;
    tmp3:= UpperCase(BuffData.FieldByName('Q_LoginNameBerechtigung').AsString);
    tmp4:= BuffData.FieldByName('Q_LoginAktiv').AsBoolean;
    if (tmp1 = UpperCase(FLastUser)) AND (tmp2 = FLastPass)
        AND (tmp4) AND (tmp3 = UpperCase(securityCode)) then begin
      CanAccess := true;
      break;
    end;
    BuffData.Next;
  end;
end;

procedure TUserManagementSQL.CheckUserAndPass(user, pass: String;
  var aUID: Integer; var ValidUser: Boolean; LoginAction: Boolean);
var
  Code,tmp1,tmp2:string;
  Rows, Cols: LongInt;
begin
  ValidUser:=false;
  if not Connect then
    exit; // -->>
  aUID := 0;
  FLastUser := '';
  FLastPass := '';
  if BuffData.Active then
    BuffData.Active:= False;
  BuffData.FileName:=FFilename;
  BuffData.FileMustExist:=True;
  BuffData.FirstLineAsSchema:=True;
  try
    BuffData.Active:=True;
  finally
    //
  end;
  BuffData.First;
  while NOT (BuffData.EOF) do begin
    // if an result is here, the user and password is valid
    tmp1:= UpperCase(BuffData.FieldByName('Q_LoginUsername').AsString);
    tmp2:= BuffData.FieldByName('Q_LoginUserpasswort').AsString;
    if (tmp1 = UpperCase(user)) AND (tmp2 = pass) then begin
      ValidUser:=True;
      aUID:= BuffData.FieldByName('Q_LoginUserID').AsInteger;
      FLastUser := UpperCase(user);
      FLastPass := pass;
      break;
    end;
    BuffData.Next;
  end;
end;

procedure TUserManagementSQL.CheckUserPassAccess(user, pass, SecurityCode: String;
  var UserCanDo: Boolean);
var
  tmp1, tmp2, tmp3:string;
  tmp4: Boolean;
begin
  UserCanDo:= false;
  if not Connect then
    exit; // -->>
  if BuffData.Active then
    BuffData.Active:= False;
  BuffData.FileName:=FFilename;
  BuffData.FileMustExist:=True;
  BuffData.FirstLineAsSchema:=True;
  try
    BuffData.Active:=True;
  except
    exit; // -->>
  end;
  BuffData.First;
  while NOT (BuffData.EOF) do begin
    // if an result is here, the user and password is valid
    tmp1:= UpperCase(BuffData.FieldByName('Q_LoginUsername').AsString);
    tmp2:= BuffData.FieldByName('Q_LoginUserpasswort').AsString;
    tmp3:= UpperCase(BuffData.FieldByName('Q_LoginNameBerechtigung').AsString);
    tmp4:= BuffData.FieldByName('Q_LoginAktiv').AsBoolean;
    if (tmp1 = UpperCase(user)) AND (tmp2 = pass)
        AND (tmp4) AND (tmp3 = UpperCase(securityCode)) then begin
      UserCanDo := true;
      break;
    end;
    BuffData.Next;
  end;
end;



function TUserManagementSQL.GetUser: String;
begin
  Result := FLastUser;
end;

function TUserManagementSQL.Connect: Boolean;
const
  co_MaxTime = 1000{ms} * 60{s}; // Dezeit jede Minute wird der Buffer ungültig
var
  Rows, Cols, i: LongInt;
  ConState: TConnectionState;
begin
  Result := False;
  // Prüfen des Masterzustandes
  // Wenn der Allgemeinzustand nicht Server ist, so kann der lokale Zustand nur Lokal sein/werden
  if not IsConnectionState(csServer) then begin
    // Connection zum Server trennen fals vorhanden
    Connection.Disconnect;
    FBuffedState:= ubLocal;
  end;
  // Prüfen ob der Buffer erneuert werdenm soll/kann
  //  if FBuffedState = ubServer {AND ((FBuffedAge + co_MaxTime) < GetTickCount64)} then begin
  if (FBuffedState = ubLocal) and FileExists(FFilename) then begin
    // Buffer ist vorhanden, aber keine Verbindung zum Server = Lokal
    Result:= True;
    exit;
  end;
  //if (FBuffedState = ubServer) and ((FBuffedAge + co_MaxTime) < GetTickCount64) then begin
  //  // Buffer ist vorhanden und nicht zu alt
  //  Result:= True;
  //  exit;
  //end;
  // Buffer ist zu alt, nicht vorhanden oder unbekannt
  if (not Connection.Connected) then
    try
      // Achtung, wenn Server nichterreichbar, verursacht das ein TimeOut
      // Kann theoretisch nicht sein, da über Masterzustand geprüft
      Connection.Connect;
    except
      on E: Exception do begin
        DebugLn('TUserManagementSQL: Connection raised error ->'+E.Message);
      end;
    end;
  if (not Connection.Connected) and FileExists(FFilename) then begin
    // Buffer ist vorhanden, aber keine Verbindung zum Server = Lokal, Login möglich
    FBuffedState:= ubLocal;
    Result:= True;
    exit;
  end;
  if (not Connection.Connected) then begin
    // Buffer ist nicht vorhanden und keine Verbindung zum Server = kein Login möglich
    FBuffedState:= ubNotValid;
    exit;
  end;
  // Alles da, wir können den Server nach lokal spiegeln
  try
    Q_Login.Connection:= Connection;
    Q_Login.Active:= True;
    BuffData.Active:= False;
    // Read the buffer
    if FileExists(FFilename) then
      DeleteFile(FFilename);
    BuffData.FileName:=FFilename;
    BuffData.FileMustExist:= False;
    BuffData.Schema.Clear;
    for i:= 0 to Q_Login.FieldCount-1 do begin
      BuffData.Schema.Add(Q_Login.Fields[i].Name);
    end;
    BuffData.FirstLineAsSchema:=True;
    try
      BuffData.Active:=True;
    except
      // Buffer ist nicht ansprechbar und keine Verbindung zum Server = kein Login möglich
      Connection.Disconnect;
      FBuffedState:= ubNotValid;
      exit;
    end;
    Rows:= BuffData.RecordCount;
    Cols:= BuffData.FieldCount;
    BuffData.First;
    if Q_Login.FieldCount = BuffData.FieldCount then begin
      Q_Login.First;
      while not Q_Login.EOF do begin
        BuffData.Append;
        for i:= 0 to BuffData.FieldCount-1 do begin
          BuffData.Fields[i].AsString:= Q_Login.Fields[i].AsString;
        end;
        BuffData.Post;
        Q_Login.Next;
      end;
    end;
    BuffData.Active:=False;
    Connection.Disconnect;
    FBuffedAge:= GetTickCount64;
    FBuffedState:= ubServer;
    Result := True;
  except
    on E: Exception do begin
      DebugLn('TUserManagementSQL: Read data raised error ->'+E.Message);
    end;
  end;
end;

function TUserManagementSQL.BufferStateToText: String;
begin
  case FBuffedState of
    ubUnkwown: Result:= 'unbekannt';
    ubServer: Result:= 'server';
    ubLocal: Result:= 'lokal';
  else
    Result:= 'ungültig';
  end;
end;

procedure TUserManagementSQL.Disconnect;
begin
  Connection.Disconnect;
  FBuffedState:= ubUnkwown;
end;

initialization
  UserManagementSQL := TUserManagementSQL.Create(nil);

finalization
  if Assigned(UserManagementSQL) then
    FreeAndNil(UserManagementSQL);

end.

