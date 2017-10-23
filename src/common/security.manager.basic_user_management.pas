unit security.manager.basic_user_management;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl, dateutils,
  security.manager.schema,
  security.manager.custom_usrmgnt_interface;

type
  TUserChangedEvent = procedure(Sender:TObject; const OldUsername, NewUserName:String) of object;

  TFPGStringList = specialize TFPGList<UTF8String>;

  { TCustomBasicUserManagment }

  TCustomBasicUserManagment =  class(TComponent)
  private
    FUsrMgnt : TUsrMgntSchema;
    FUsrMgntInterface: TCustomUsrMgntInterface;
  protected
    //: Return the user management type.
    function    UsrMgntType:TUsrMgntType; virtual; deprecated 'use UserMgnt.UsrMgntType instead';
    //: Return the user management schema (all users, groups and authorizations, if availables).
    function    GetUserMgnt:TUsrMgntSchema; virtual;
    function    GetUserSchema:TUsrMgntSchema; virtual; deprecated 'use GetUserMgnt instead';
    //: Set the user management schema (all users, groups and authorizations, if availables).
    procedure   SetUserMgnt(AValue: TUsrMgntSchema); virtual;
    //Set the user managment interface
    procedure SetUsrMgntInterface(AValue: TCustomUsrMgntInterface); virtual;
    // Get or set the UserSchema
    property UserMgnt: TUsrMgntSchema read GetUserMgnt write SetUserMgnt;
    //
    property UsrMgntInterface:TCustomUsrMgntInterface read FUsrMgntInterface write SetUsrMgntInterface;
  public
    constructor Create(AOwner:TComponent); override;
    destructor  Destroy; override;
  end;

  TBasicUserManagement = class(TCustomBasicUserManagment)
  protected
    FLoggedUser:Boolean;
    FCurrentUserName,
    FCurrentUserLogin:String;
    FUID:Integer;
    FRetries:Cardinal;
    FLoggedSince:TDateTime;
    FInactiveTimeOut:Cardinal;
    FLoginRetries:Cardinal;
    FFrozenTime:Cardinal;

    FSuccessfulLogin:TNotifyEvent;
    FFailureLogin:TNotifyEvent;
    FUserChanged:TUserChangedEvent;

    FRegisteredSecurityCodes:TFPGStringList;

    function  GetLoginTime:TDateTime;
    procedure SetInactiveTimeOut(AValue: Cardinal); virtual;
    function  GetUID: Integer;
    procedure DoUserChanged; virtual;

    procedure DoSuccessfulLogin; virtual;
    procedure DoFailureLogin; virtual;

    function CheckUserAndPassword(User, Pass:String; var UserID:Integer; LoginAction:Boolean):Boolean; virtual; abstract;

    function GetLoggedUser:Boolean; virtual;
    function GetCurrentUserName:String; virtual;
    function GetCurrentUserLogin:String; virtual;

    function CanAccess(sc:String; aUID:Integer):Boolean; virtual; abstract; overload;
    procedure SetUsrMgntInterface(AValue: TCustomUsrMgntInterface); override;

    procedure Notification(AComponent: TComponent; Operation: TOperation);
      override;

    //read only properties.
    property LoggedSince:TDateTime read GetLoginTime;

    //read-write properties.
    //property VirtualKeyboardType:TVKType read FVirtualKeyboardType write FVirtualKeyboardType;
    property InactiveTimeout:Cardinal read FInactiveTimeOut write SetInactiveTimeOut;
    property LoginRetries:Cardinal read FLoginRetries write FLoginRetries;
    property LoginFrozenTime:Cardinal read  FFrozenTime write FFrozenTime;

    property SuccessfulLogin:TNotifyEvent read FSuccessfulLogin write FSuccessfulLogin;
    property FailureLogin:TNotifyEvent read FFailureLogin write FFailureLogin;
    property UserChanged:TUserChangedEvent read FUserChanged write FUserChanged;
  public
    constructor Create(AOwner:TComponent); override;
    destructor  Destroy; override;
    //: Opens the Login interface of UsrMgntInterface.Login
    function    Login:Boolean; virtual; overload;
    //: Try Login on the system
    function    Login(Userlogin, userpassword: String; var UID: Integer):Boolean; virtual;
    //: Logout
    procedure   Logout; virtual;
    //: Opens the user management defined in UsrMgntInterface.UserManagement.
    procedure   Manage; virtual;

    //Security codes management
    procedure   ValidateSecurityCode(sc:String); virtual; abstract;
    function    SecurityCodeExists(sc:String):Boolean; virtual;
    procedure   RegisterSecurityCode(sc:String); virtual;
    procedure   UnregisterSecurityCode(sc:String); virtual;

    function    CanAccess(sc:String):Boolean; virtual; abstract;
    function    GetRegisteredAccessCodes:TFPGStringList; virtual;

    function    CheckIfUserIsAllowed(sc: String; RequireUserLogin: Boolean; var userlogin: String): Boolean; virtual;

    //read only properties.
    property UID:Integer read GetUID;
    property UserLogged:Boolean read GetLoggedUser;
    property CurrentUserName:String read GetCurrentUserName;
    property CurrentUserLogin:String read GetCurrentUserLogin;
  end;

implementation

uses security.exceptions,
     security.manager.controls_manager;

{ TCustomBasicUserManagment }

procedure TCustomBasicUserManagment.SetUserMgnt(AValue: TUsrMgntSchema);
begin
  if (AValue = FUsrMgnt) then exit; //-->>
  // exist a schema, then remove it
  if Assigned(FUsrMgnt) then begin
    FreeAndNil(FUsrMgnt);
  end;
  FUsrMgnt:= AValue;
end;

procedure TCustomBasicUserManagment.SetUsrMgntInterface(
  AValue: TCustomUsrMgntInterface);
begin

end;

constructor TCustomBasicUserManagment.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUsrMgnt := nil;
end;

destructor TCustomBasicUserManagment.Destroy;
begin
  if Assigned(FUsrMgnt) then
    FreeAndNil(FUsrMgnt);
  inherited Destroy;
end;

function TCustomBasicUserManagment.UsrMgntType: TUsrMgntType;
begin
  if Assigned(FUsrMgnt) then
    Result := FUsrMgnt.UsrMgntType
  else
    Result:= TUsrMgntType.umtUnknown;
end;

function TCustomBasicUserManagment.GetUserMgnt: TUsrMgntSchema;
begin
  Result:= FUsrMgnt;
end;

function TCustomBasicUserManagment.GetUserSchema: TUsrMgntSchema;
begin
  Result:= GetUserMgnt;
end;

constructor TBasicUserManagement.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);

  if GetControlSecurityManager.UserManagement=nil then
    GetControlSecurityManager.UserManagement:=Self
  else
    raise EUserManagementIsSet.Create;

  FLoggedUser:=false;
  FCurrentUserName:='';
  FCurrentUserLogin:='';
  FUID:=-1;
  FLoggedSince:=Now;

  FRegisteredSecurityCodes:=TFPGStringList.Create;
end;

destructor  TBasicUserManagement.Destroy;
begin
  if GetControlSecurityManager.UserManagement=Self then
    GetControlSecurityManager.UserManagement:=nil;

  if FRegisteredSecurityCodes<>nil then
    FRegisteredSecurityCodes.Destroy;
  inherited Destroy;
end;

function TBasicUserManagement.Login: Boolean;
begin
  Result:=false;
  if Assigned(FUsrMgntInterface) then
    Result:=FUsrMgntInterface.Login
  else
    raise EUnassignedUsrMgntIntf.Create;
end;

function TBasicUserManagement.Login(Userlogin, userpassword: String; var UID:Integer):Boolean; overload;
var
  AFreezeStarted: TDateTime;
begin
  Result:=CheckUserAndPassword(Userlogin, userpassword, UID, true);
  if Result then begin
    FLoggedUser:=true;
    FUID:=UID;
    FCurrentUserLogin:=Userlogin;
    FLoggedSince:=Now;
    Result:=true;
    FRetries:=0;
    GetControlSecurityManager.UpdateControls;
    DoSuccessfulLogin;
  end else begin
    FRetries:=FRetries+1;
    if (FRetries>=FLoginRetries) and (FLoginRetries>0) and (FFrozenTime>0) and Assigned(FUsrMgntInterface) then begin

      if FUsrMgntInterface.LoginVisibleBetweenRetries then
        FUsrMgntInterface.FreezeUserLogin;

      AFreezeStarted:=Now;
      repeat
        CheckSynchronize(1);
        FUsrMgntInterface.ProcessMessages;
      until MilliSecondsBetween(Now,AFreezeStarted)>=FFrozenTime;

      if FUsrMgntInterface.LoginVisibleBetweenRetries then
        FUsrMgntInterface.UnfreezeUserLogin;

      FRetries:=0;
    end;
  end;
end;

procedure   TBasicUserManagement.Logout;
begin
  if (not Assigned(FUsrMgntInterface)) or (FUsrMgntInterface.CanLogout) then begin
    FLoggedUser:=false;
    FCurrentUserName:='';
    FCurrentUserLogin:='';
    FUID:=-1;
    FLoggedSince:=Now;
    GetControlSecurityManager.UpdateControls;
  end;
end;

procedure TBasicUserManagement.Manage;
var
  schema: TUsrMgntSchema;
begin
  if Assigned(FUsrMgntInterface) then begin
    schema:=GetUserSchema;
    try
      FUsrMgntInterface.UserManagement(schema)
    finally
      FreeAndNil(schema);
    end;
  end else
    raise EUnassignedUsrMgntIntf.Create;
end;

function    TBasicUserManagement.SecurityCodeExists(sc:String):Boolean;
begin
  Result:=FRegisteredSecurityCodes.IndexOf(sc)>=0;
end;

procedure   TBasicUserManagement.RegisterSecurityCode(sc:String);
begin
  if Not SecurityCodeExists(sc) then
    FRegisteredSecurityCodes.Add(sc);
end;

procedure   TBasicUserManagement.UnregisterSecurityCode(sc:String);
begin
  if SecurityCodeExists(sc) then
    FRegisteredSecurityCodes.Delete(FRegisteredSecurityCodes.IndexOf(sc));
end;

function TBasicUserManagement.GetRegisteredAccessCodes: TFPGStringList;
begin
  Result:=TFPGStringList.Create;
  Result.Assign(FRegisteredSecurityCodes);
end;

function TBasicUserManagement.CheckIfUserIsAllowed(sc: String;
  RequireUserLogin: Boolean; var userlogin: String): Boolean;
var
  aLogin, aPass:UTF8String;
  aUserID: Integer;
begin
  //if current user has the authorization, avoid open the dialog that will
  //asks by other user allowed
  if UserLogged and CanAccess(sc) and (RequireUserLogin=false) then begin
    userlogin:=GetCurrentUserLogin;
    Result:=true;
    exit;
  end;

  Result:=false;
  if Assigned(FUsrMgntInterface) then begin
    if FUsrMgntInterface.Login(aLogin, aPass) then begin
      if CheckUserAndPassword(aLogin, aPass, {%H-}aUserID, false) then begin
        if CanAccess(sc, aUserID) then begin
          Result:=true;
          userlogin:=aLogin;
        end else
          Result:=false;
      end;
    end
  end else
    raise EUnassignedUsrMgntIntf.Create;
end;

function TBasicUserManagement.GetUID: Integer;
begin
  Result:=FUID;
end;

procedure TBasicUserManagement.SetUsrMgntInterface(
  AValue: TCustomUsrMgntInterface);
begin
  if UsrMgntInterface=AValue then Exit; // -->>
  // clear notifications
  if Assigned(UsrMgntInterface) then UsrMgntInterface.RemoveFreeNotification(Self);
  if Assigned(AValue) then AValue.FreeNotification(Self);
  // set the new value
  inherited SetUsrMgntInterface(AValue);
  UsrMgntInterface:=AValue;
end;

procedure TBasicUserManagement.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  if (Operation=opRemove) and (AComponent=UsrMgntInterface) then
    UsrMgntInterface:=nil; { TODO -oAndi : Check if only nil or we must use free }
end;

function    TBasicUserManagement.GetLoginTime:TDateTime;
begin
  if FLoggedUser then
    Result:=FLoggedSince
  else
    Result:=Now;
end;

procedure TBasicUserManagement.SetInactiveTimeOut(AValue: Cardinal);
begin
  FInactiveTimeOut:=AValue;
end;

function TBasicUserManagement.GetLoggedUser:Boolean;
begin
  Result:=FLoggedUser;
end;

function TBasicUserManagement.GetCurrentUserName:String;
begin
  Result:=FCurrentUserName;
end;

function TBasicUserManagement.GetCurrentUserLogin:String;
begin
  Result:=FCurrentUserLogin;
end;

procedure TBasicUserManagement.DoSuccessfulLogin;
begin
  if Assigned(FSuccessfulLogin) then
    FSuccessfulLogin(Self);
end;

procedure TBasicUserManagement.DoFailureLogin;
begin
  if Assigned(FFailureLogin) then
    FFailureLogin(Self);
end;

procedure TBasicUserManagement.DoUserChanged;
begin
  if Assigned(FUserChanged) then
    try
      FUserChanged(Self, FCurrentUserLogin, GetCurrentUserLogin);
    finally
    end;
end;

end.

