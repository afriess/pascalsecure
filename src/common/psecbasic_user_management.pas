unit PSECBasic_user_management;
{$I PSECinclude.inc}
{ *************************
  (Basic)User Magement
  This is the absolute basic and common implementation of the User Management. The
  specialied functionallity must be written in the children, like level based or
  authentication based security.
  *************************
This is a part of the PSEC (Pascal SECure) framework, it is a
standalone part of PascalSCADA 1.0. A multiplatform SCADA framework for Lazarus.
This code is a entire rewrite of PascalSCADA hosted at
https://sourceforge.net/projects/pascalscada.

Copyright Fabio Luis Girardi (https://github.com/fluisgirardi/pascalsecure)
          Andreas Frieß      (https://github.com/afriess/pascalsecure)

This code is under modified LGPL (see LICENSE.modifiedLGPL.txt).
}

interface

uses
  Classes, SysUtils, fgl, dateutils,
  PSECUserSchema,
  PSECInterfaces;

type
  TPSECUserChangedEvent = procedure(Sender:TObject; const OldUsername, NewUserName:String) of object;

  TPSECStringList = specialize TFPGList<UTF8String>;

  { TPSECBasicUserManagement }

  TPSECBasicUserManagement = class(TComponent)
  protected
    //: Return the user management type.
    function    UsrMgntType:TPSECUsrMgntType; virtual;
    //: Return the user management schema (all users, groups and authorizations, if availables).
    function    GetUserSchema:TPSECUsrMgntSchema; virtual;
  protected
    FUsrMgntInterface: IUsrLevelMgntInterface;
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
    FUserChanged:TPSECUserChangedEvent;

    FRegisteredSecurityCodes:TPSECStringList;

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
    procedure SetUsrMgntInterface(AValue: IUsrLevelMgntInterface);

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
    property UserChanged:TPSECUserChangedEvent read FUserChanged write FUserChanged;
    property UsrMgntInterface:IUsrLevelMgntInterface read FUsrMgntInterface write SetUsrMgntInterface;
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
    function    GetRegisteredAccessCodes:TPSECStringList; virtual;

    function    CheckIfUserIsAllowed(sc: String; RequireUserLogin: Boolean; var userlogin: String): Boolean; virtual;

    //read only properties.
    property UID:Integer read GetUID;
    property UserLogged:Boolean read GetLoggedUser;
    property CurrentUserName:String read GetCurrentUserName;
    property CurrentUserLogin:String read GetCurrentUserLogin;
  end;

implementation

uses PSECExceptions,
     PSECcontrolsManager;

constructor TPSECBasicUserManagement.Create(AOwner:TComponent);
begin
  inherited Create(AOwner);
  { TODO -oANdi : Who is responsible }
  //if GetControlSecurityManager.UserManagement=nil then
  //  GetControlSecurityManager.UserManagement:=Self
  //else
  //  raise EUserManagementIsSet.Create;

  FLoggedUser:=false;
  FCurrentUserName:='';
  FCurrentUserLogin:='';
  FUID:=-1;
  FLoggedSince:=Now;

  FRegisteredSecurityCodes:=TPSECStringList.Create;
end;

destructor  TPSECBasicUserManagement.Destroy;
begin
  { TODO -oANdi : Who is responsible }
  //if GetControlSecurityManager.UserManagement=Self then
  //  GetControlSecurityManager.UserManagement:=nil;

  if FRegisteredSecurityCodes<>nil then
    FRegisteredSecurityCodes.Destroy;
  inherited Destroy;
end;

function TPSECBasicUserManagement.Login: Boolean;
begin
  Result:=false;
  { TODO -oANdi : Who is responsible }
  //if Assigned(FUsrMgntInterface) then
  //  Result:=FUsrMgntInterface.Login
  //else
  //  raise EUnassignedUsrMgntIntf.Create;
end;

function TPSECBasicUserManagement.Login(Userlogin, userpassword: String; var UID:Integer):Boolean; overload;
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
    { TODO -oANdi : Who is responsible }
    //GetControlSecurityManager.UpdateControls;
    DoSuccessfulLogin;
  end else begin
    FRetries:=FRetries+1;
    if (FRetries>=FLoginRetries) and (FLoginRetries>0) and (FFrozenTime>0) and Assigned(FUsrMgntInterface) then begin

      { TODO -oANdi : Who is responsible }
      //if FUsrMgntInterface.LoginVisibleBetweenRetries then
      //  FUsrMgntInterface.FreezeUserLogin;
      //
      //AFreezeStarted:=Now;
      //repeat
      //  CheckSynchronize(1);
      //  FUsrMgntInterface.ProcessMessages;
      //until MilliSecondsBetween(Now,AFreezeStarted)>=FFrozenTime;
      //
      //if FUsrMgntInterface.LoginVisibleBetweenRetries then
      //  FUsrMgntInterface.UnfreezeUserLogin;
      //
      FRetries:=0;
    end;
  end;
end;

procedure   TPSECBasicUserManagement.Logout;
begin
  { TODO -oANdi : Who is responsible }
  //if (not Assigned(FUsrMgntInterface)) or (FUsrMgntInterface.CanLogout) then begin
  //  FLoggedUser:=false;
  //  FCurrentUserName:='';
  //  FCurrentUserLogin:='';
  //  FUID:=-1;
  //  FLoggedSince:=Now;
  //  GetControlSecurityManager.UpdateControls;
  //end;
end;

procedure TPSECBasicUserManagement.Manage;
{ TODO -oANdi : Who is responsible }
//var
//  schema: TUsrMgntSchema;
begin
  { TODO -oANdi : Who is responsible }
  //if Assigned(FUsrMgntInterface) then begin
  //  schema:=GetUserSchema;
  //  try
  //    FUsrMgntInterface.UserManagement(schema)
  //  finally
  //    FreeAndNil(schema);
  //  end;
  //end else
  //  raise EUnassignedUsrMgntIntf.Create;
end;

function TPSECBasicUserManagement.UsrMgntType: TPSECUsrMgntType;
begin
  Result:=umtUnknown;
end;

function TPSECBasicUserManagement.GetUserSchema: TPSECUsrMgntSchema;
begin
  Result:=nil;
end;

function    TPSECBasicUserManagement.SecurityCodeExists(sc:String):Boolean;
begin
  Result:=FRegisteredSecurityCodes.IndexOf(sc)>=0;
end;

procedure   TPSECBasicUserManagement.RegisterSecurityCode(sc:String);
begin
  if Not SecurityCodeExists(sc) then
    FRegisteredSecurityCodes.Add(sc);
end;

procedure   TPSECBasicUserManagement.UnregisterSecurityCode(sc:String);
begin
  if SecurityCodeExists(sc) then
    FRegisteredSecurityCodes.Delete(FRegisteredSecurityCodes.IndexOf(sc));
end;

function TPSECBasicUserManagement.GetRegisteredAccessCodes: TPSECStringList;
begin
  Result:=TPSECStringList.Create;
  Result.Assign(FRegisteredSecurityCodes);
end;

function TPSECBasicUserManagement.CheckIfUserIsAllowed(sc: String;
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
  { TODO -oANdi : Who is responsible }
  //if Assigned(FUsrMgntInterface) then begin
  //  if FUsrMgntInterface.Login(aLogin, aPass) then begin
  //    if CheckUserAndPassword(aLogin, aPass, {%H-}aUserID, false) then begin
  //      if CanAccess(sc, aUserID) then begin
  //        Result:=true;
  //        userlogin:=aLogin;
  //      end else
  //        Result:=false;
  //    end;
  //  end
  //end else
  //  raise EUnassignedUsrMgntIntf.Create;
end;

function TPSECBasicUserManagement.GetUID: Integer;
begin
  Result:=FUID;
end;

procedure TPSECBasicUserManagement.SetUsrMgntInterface(
  AValue: IUsrLevelMgntInterface);
begin

  if FUsrMgntInterface=AValue then Exit;
  { TODO -oANdi : Who is responsible }
  //if Assigned(FUsrMgntInterface) Then FUsrMgntInterface.RemoveFreeNotification(Self);
  //if Assigned(AValue) then AValue.FreeNotification(Self);
  FUsrMgntInterface:=AValue;
end;

procedure TPSECBasicUserManagement.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited Notification(AComponent, Operation);
  { TODO -oANdi : Who is responsible }
  //if (Operation=opRemove) and (AComponent=FUsrMgntInterface) then
  //  FUsrMgntInterface:=nil;
end;

function    TPSECBasicUserManagement.GetLoginTime:TDateTime;
begin
  if FLoggedUser then
    Result:=FLoggedSince
  else
    Result:=Now;
end;

procedure TPSECBasicUserManagement.SetInactiveTimeOut(AValue: Cardinal);
begin
  FInactiveTimeOut:=AValue;
end;

function TPSECBasicUserManagement.GetLoggedUser:Boolean;
begin
  Result:=FLoggedUser;
end;

function TPSECBasicUserManagement.GetCurrentUserName:String;
begin
  Result:=FCurrentUserName;
end;

function TPSECBasicUserManagement.GetCurrentUserLogin:String;
begin
  Result:=FCurrentUserLogin;
end;

procedure TPSECBasicUserManagement.DoSuccessfulLogin;
begin
  if Assigned(FSuccessfulLogin) then
    FSuccessfulLogin(Self);
end;

procedure TPSECBasicUserManagement.DoFailureLogin;
begin
  if Assigned(FFailureLogin) then
    FFailureLogin(Self);
end;

procedure TPSECBasicUserManagement.DoUserChanged;
begin
  if Assigned(FUserChanged) then
    try
      FUserChanged(Self, FCurrentUserLogin, GetCurrentUserLogin);
    finally
    end;
end;

end.

