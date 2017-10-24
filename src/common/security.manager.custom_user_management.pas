unit security.manager.custom_user_management;

{$mode objfpc}{$H+}

interface

uses
  Classes,
  sysutils,
  security.manager.basic_user_management,
  security.manager.schema;

type

  TCheckUserAndPasswordEvent = procedure(user, pass:String; var aUID:Integer; var ValidUser:Boolean; LoginAction:Boolean) of object;
  TUserStillLoggedEvent      = procedure(var StillLogged:Boolean) of object;
  TGetUserNameAndLogin       = procedure(var UserInfo:String) of object;
  TManageUsersAndGroupsEvent = TNotifyEvent;
  TValidadeSecurityCode      = procedure(const securityCode:String) of object;
  TRegisterSecurityCode      = procedure(const securityCode:String) of object;
  TLogoutEvent               = TNotifyEvent;
  TCanAccessEvent            = procedure(securityCode:String; var CanAccess:Boolean) of object;
  TUIDCanAccessEvent         = procedure(aUID:Integer; securityCode:String; var CanAccess:Boolean) of object;
  TGetUserSchemaType         = procedure(var SchemaType:TUsrMgntType) of object;
  TGetUserSchema             = procedure(var Schema:TUsrMgntSchema) of object;

  { TUserCustomizedUserManagement }

  TUserCustomizedUserManagement = class(TBasicUserManagement)
  private
    FCheckUserAndPasswordEvent:TCheckUserAndPasswordEvent;
    FGetUserName              :TGetUserNameAndLogin;
    FGetUserLogin             :TGetUserNameAndLogin;
    FGetUserSchema            :TGetUserSchema;
    FGetUserSchemaType        :TGetUserSchemaType;
    FManageUsersAndGroupsEvent:TManageUsersAndGroupsEvent;
    FRegisterSecurityCode     :TRegisterSecurityCode;
    FUIDCanAccessEvent        :TUIDCanAccessEvent;
    FValidadeSecurityCode     :TValidadeSecurityCode;
    FCanAccessEvent           :TCanAccessEvent;
    FLogoutEvent              :TLogoutEvent;
  protected
    function  CheckUserAndPassword(User, Pass:String; var UserID:Integer; LoginAction:Boolean):Boolean; override;

    function  GetCurrentUserName:String; override;
    function  GetCurrentUserLogin:String; override;
    function  CanAccess(sc: String; aUID: Integer): Boolean; override; overload;

    function UsrMgntType: TUsrMgntType; override;
    function GetUserSchema: TUsrMgntSchema; override;
  public
    procedure Logout; override;
    procedure Manage; override;

    //Security codes management
    procedure ValidateSecurityCode(sc:String); override;
    procedure RegisterSecurityCode(sc: String); override;

    function  CanAccess(sc:String):Boolean; override;
  published
    property UID;
    property CurrentUserName;
    property CurrentUserLogin;
    property LoggedSince;

    property LoginRetries;
    property LoginFrozenTime;

    property SuccessfulLogin;
    property FailureLogin;
    property UserMgnt;
    property UsrMgntInterface;
   published
    property OnCheckUserAndPass    :TCheckUserAndPasswordEvent read FCheckUserAndPasswordEvent write FCheckUserAndPasswordEvent;
    property OnGetUserName         :TGetUserNameAndLogin       read FGetUserName               write FGetUserName;
    property OnGetUserLogin        :TGetUserNameAndLogin       read FGetUserLogin              write FGetUserLogin;
    property OnManageUsersAndGroups:TManageUsersAndGroupsEvent read FManageUsersAndGroupsEvent write FManageUsersAndGroupsEvent;
    property OnValidadeSecurityCode:TValidadeSecurityCode      read FValidadeSecurityCode      write FValidadeSecurityCode;
    property OnRegisterSecurityCode:TRegisterSecurityCode      read FRegisterSecurityCode      write FRegisterSecurityCode;
    property OnCanAccess           :TCanAccessEvent            read FCanAccessEvent            write FCanAccessEvent;
    property OnUIDCanAccess        :TUIDCanAccessEvent         read FUIDCanAccessEvent         write FUIDCanAccessEvent;
    property OnLogout              :TLogoutEvent               read FLogoutEvent               write FLogoutEvent;
    property OnGetSchemaType       :TGetUserSchemaType         read FGetUserSchemaType         write FGetUserSchemaType;
    property OnGetUserSchema       :TGetUserSchema             read FGetUserSchema             write FGetUserSchema;
  end;

implementation

  {$ifdef debug_secure}
uses
  LazLogger;
  {$endif}


{ TUserCustomizedUserManagement }

function TUserCustomizedUserManagement.CheckUserAndPassword(User,
  Pass: String; var UserID: Integer; LoginAction: Boolean): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  try
    if Assigned(FCheckUserAndPasswordEvent) then
      FCheckUserAndPasswordEvent(user,Pass,UserID,Result,LoginAction);
  except
    Result:=false;
  end;
end;

function TUserCustomizedUserManagement.GetCurrentUserName: String;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:='';
  if FLoggedUser then
    try
      if Assigned(FGetUserName) then
        FGetUserName(Result);
    except
      Result:='';
    end;
end;

function TUserCustomizedUserManagement.GetCurrentUserLogin: String;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:='';
  if FLoggedUser then
    try
      if Assigned(FGetUserLogin) then
        FGetUserLogin(Result);
    except
      Result:='';
    end;
end;

function TUserCustomizedUserManagement.CanAccess(sc: String; aUID: Integer
  ): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=(Trim(sc)='');
  if aUID>=0 then
    try
      if Assigned(FUIDCanAccessEvent) then
        FUIDCanAccessEvent(aUID,sc,Result);
    except
      Result:=(Trim(sc)='');
    end;
end;

function TUserCustomizedUserManagement.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=umtUnknown;
  if Assigned(FGetUserSchemaType) then
    FGetUserSchemaType(Result);
end;

function TUserCustomizedUserManagement.GetUserSchema: TUsrMgntSchema;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if Assigned(FGetUserSchema) then
    FGetUserSchema(Result);
end;

procedure TUserCustomizedUserManagement.Logout;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Logout;
  if Assigned(FLogoutEvent) then
    try
      FLogoutEvent(self);
    except
    end;
end;

procedure TUserCustomizedUserManagement.Manage;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FManageUsersAndGroupsEvent) then
    FManageUsersAndGroupsEvent(Self)
  else
    inherited Manage;
end;

procedure TUserCustomizedUserManagement.ValidateSecurityCode(sc: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FValidadeSecurityCode) then
    FValidadeSecurityCode(sc);
end;

procedure TUserCustomizedUserManagement.RegisterSecurityCode(sc: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FRegisterSecurityCode) then
    FRegisterSecurityCode(sc);
end;

function TUserCustomizedUserManagement.CanAccess(sc: String): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=(Trim(sc)='');
  if FLoggedUser then
    try
      if Assigned(FCanAccessEvent) then
        FCanAccessEvent(sc,Result);
    except
      Result:=(Trim(sc)='');
    end;
end;

end.

