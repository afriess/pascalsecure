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
  //level events
  TLevelAddUser              = procedure(const UserLogin, UserDescription, PlainPassword:UTF8String;
                                         const aUsrLevel:Integer;
                                         const aBlocked:Boolean;
                                         out   aUID:Integer;
                                         out   Result:Boolean) of object;
  TLevelDelUser              = procedure(Const aUsrObject:TUserWithLevelAccess;
                                         out   Result:Boolean) of object;
  TLevelUpdateUser           = procedure(const aUsrObject:TUserWithLevelAccess;
                                         const aUserDescription, aPlainPassword:UTF8String;
                                         const aUsrLevel:Integer;
                                         const aBlocked:Boolean;
                                         out   Result:Boolean) of object;
  TLevelBlockUser            = procedure(const aUsrObject:TUserWithLevelAccess;
                                         const aBlocked:Boolean;
                                         out   Result:Boolean) of object;
  TLevelChangeUserPass       = procedure(const aUsrObject:TUserWithLevelAccess;
                                         const aPlainPassword:UTF8String;
                                         out   Result:Boolean) of object;

  { TUserCustomizedUserManagement }

  TUserCustomizedUserManagement = class(TBasicUserManagement, IUsrLevelMgntInterface)
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

    //level events...
    FLevelAddUser             :TLevelAddUser;
    FLevelBlockUser           :TLevelBlockUser;
    FLevelChangeUserPass      :TLevelChangeUserPass;
    FLevelDelUser             :TLevelDelUser;
    FLevelUpdateUser          :TLevelUpdateUser;
  protected
    function  CheckUserAndPassword(User, Pass:String; var UserID:Integer; LoginAction:Boolean):Boolean; override;

    function  GetCurrentUserName:String; override;
    function  GetCurrentUserLogin:String; override;
    function  CanAccess(sc: String; aUID: Integer): Boolean; override; overload;

    function UsrMgntType: TUsrMgntType; override;
    function GetUserSchema: TUsrMgntSchema; override;
  protected
    //level interface.
    function LevelAddUser(const UserLogin, UserDescription, PlainPassword:UTF8String;
                          const aUsrLevel:Integer;
                          const aBlocked:Boolean;
                          out   aUID:Integer;
                          out   aUsrObject:TUserWithLevelAccess):Boolean;

    function LevelDelUser(Const aUsrObject:TUserWithLevelAccess):Boolean;

    function LevelUpdateUser(const aUsrObject:TUserWithLevelAccess;
                             const aUserDescription, aPlainPassword:UTF8String;
                             const aUsrLevel:Integer;
                             const aBlocked:Boolean):Boolean;

    function LevelBlockUser(const aUsrObject:TUserWithLevelAccess;
                            const aBlocked:Boolean):Boolean;

    function LevelChangeUserPass(const aUsrObject:TUserWithLevelAccess;
                                 const aPlainPassword:UTF8String):Boolean;
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

    property OnLevelAddUser        :TLevelAddUser              read FLevelAddUser              write FLevelAddUser;
    property OnLevelDelUser        :TLevelDelUser              read FLevelDelUser              write FLevelDelUser;
    property OnLevelUpdateUser     :TLevelUpdateUser           read FLevelUpdateUser           write FLevelUpdateUser;
    property OnLevelBlockUser      :TLevelBlockUser            read FLevelBlockUser            write FLevelBlockUser;
    property OnLevelChangeUserPass :TLevelChangeUserPass       read FLevelChangeUserPass       write FLevelChangeUserPass;
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

function TUserCustomizedUserManagement.LevelAddUser(const UserLogin,
  UserDescription, PlainPassword: UTF8String; const aUsrLevel: Integer;
  const aBlocked: Boolean; out aUID: Integer; out
  aUsrObject: TUserWithLevelAccess): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FLevelAddUser) then begin
    FLevelAddUser(UserLogin, UserDescription, PlainPassword, aUsrLevel, aBlocked, aUID, Result);
  end;

  if Result then begin
    aUsrObject:=TUserWithLevelAccess.Create(aUID,UserLogin,PlainPassword,UserDescription,aBlocked, aUsrLevel);
  end;
end;

function TUserCustomizedUserManagement.LevelDelUser(
  const aUsrObject: TUserWithLevelAccess): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
end;

function TUserCustomizedUserManagement.LevelUpdateUser(
  const aUsrObject: TUserWithLevelAccess; const aUserDescription,
  aPlainPassword: UTF8String; const aUsrLevel: Integer; const aBlocked: Boolean
  ): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
end;

function TUserCustomizedUserManagement.LevelBlockUser(
  const aUsrObject: TUserWithLevelAccess; const aBlocked: Boolean): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
end;

function TUserCustomizedUserManagement.LevelChangeUserPass(
  const aUsrObject: TUserWithLevelAccess; const aPlainPassword: UTF8String
  ): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
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

