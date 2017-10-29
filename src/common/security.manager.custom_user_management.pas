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

  { TUserLevelUserManagement }

  TUserLevelUserManagement = class(TBasicUserManagement, IUsrLevelMgntInterface)
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
    FCurrentUserSchema:TUsrMgntSchema;
    function  CheckUserAndPassword(User, Pass:String; var UserID:Integer; LoginAction:Boolean):Boolean; override;

    function  GetCurrentUserName:String; override;
    function  GetCurrentUserLogin:String; override;
    function  CanAccess(sc: String; aUID: Integer): Boolean; override; overload;

    function UsrMgntType: TUsrMgntType; override;
    function GetUserMgnt: TUsrMgntSchema; override;
  protected
    //level interface.
    function LevelAddUser(const UserLogin, UserDescription, PlainPassword:UTF8String;
                          const aUsrLevel:Integer;
                          const aBlocked:Boolean;
                          out   aUID:Integer;
                          out   aUsrObject:TUserWithLevelAccess):Boolean;

    function LevelDelUser(var  aUsrObject:TUserWithLevelAccess):Boolean;

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


{ TUserLevelUserManagement }

function TUserLevelUserManagement.CheckUserAndPassword(User,
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

function TUserLevelUserManagement.GetCurrentUserName: String;
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

function TUserLevelUserManagement.GetCurrentUserLogin: String;
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

function TUserLevelUserManagement.CanAccess(sc: String; aUID: Integer
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

function TUserLevelUserManagement.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=umtUnknown;
  if Assigned(FGetUserSchemaType) then
    FGetUserSchemaType(Result);
end;

function TUserLevelUserManagement.GetUserMgnt: TUsrMgntSchema;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if Assigned(FGetUserSchema) then
    FGetUserSchema(Result);

  FCurrentUserSchema:=Result
end;

function TUserLevelUserManagement.LevelAddUser(const UserLogin,
  UserDescription, PlainPassword: UTF8String; const aUsrLevel: Integer;
  const aBlocked: Boolean; out aUID: Integer; out
  aUsrObject: TUserWithLevelAccess): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FLevelAddUser) then begin
    FLevelAddUser(UserLogin, UserDescription, PlainPassword, aUsrLevel, aBlocked, aUID, Result);
  end;

  if Result and Assigned(FCurrentUserSchema) and (FCurrentUserSchema is TUsrLevelMgntSchema) then begin
    aUsrObject:=TUserWithLevelAccess.Create(aUID,UserLogin,PlainPassword,UserDescription,aBlocked, aUsrLevel);
    TUsrLevelMgntSchema(FCurrentUserSchema).UserList.Add(aUsrObject.UID, aUsrObject);
  end;
end;

function TUserLevelUserManagement.LevelDelUser(
  var aUsrObject: TUserWithLevelAccess): Boolean;
var
  idx: LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FLevelDelUser) then begin
    FLevelDelUser(aUsrObject, Result);
  end;

  if Result and Assigned(FCurrentUserSchema) and (FCurrentUserSchema is TUsrLevelMgntSchema) then begin
    idx:=TUsrLevelMgntSchema(FCurrentUserSchema).UserList.IndexOf(aUsrObject.UID);
    if idx<>-1 then begin
      if TUsrLevelMgntSchema(FCurrentUserSchema).UserList.KeyData[aUsrObject.UID]<>aUsrObject then begin
        TUsrLevelMgntSchema(FCurrentUserSchema).UserList.KeyData[aUsrObject.UID].Destroy;
        FreeAndNil(aUsrObject);
      end else
        FreeAndNil(aUsrObject);

      TUsrLevelMgntSchema(FCurrentUserSchema).UserList.Delete(idx);
    end;
  end;
end;

function TUserLevelUserManagement.LevelUpdateUser(
  const aUsrObject: TUserWithLevelAccess; const aUserDescription,
  aPlainPassword: UTF8String; const aUsrLevel: Integer; const aBlocked: Boolean
  ): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
end;

function TUserLevelUserManagement.LevelBlockUser(
  const aUsrObject: TUserWithLevelAccess; const aBlocked: Boolean): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FLevelBlockUser) then
    FLevelBlockUser(aUsrObject, aBlocked, Result);
end;

function TUserLevelUserManagement.LevelChangeUserPass(
  const aUsrObject: TUserWithLevelAccess; const aPlainPassword: UTF8String
  ): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
end;

procedure TUserLevelUserManagement.Logout;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Logout;
  if Assigned(FLogoutEvent) then
    try
      FLogoutEvent(self);
    except
    end;
end;

procedure TUserLevelUserManagement.Manage;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FManageUsersAndGroupsEvent) then
    FManageUsersAndGroupsEvent(Self)
  else
    inherited Manage;
end;

procedure TUserLevelUserManagement.ValidateSecurityCode(sc: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FValidadeSecurityCode) then
    FValidadeSecurityCode(sc);
end;

procedure TUserLevelUserManagement.RegisterSecurityCode(sc: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FRegisterSecurityCode) then
    FRegisterSecurityCode(sc);
end;

function TUserLevelUserManagement.CanAccess(sc: String): Boolean;
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

