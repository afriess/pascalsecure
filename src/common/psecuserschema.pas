unit PSECUserSchema;
{$I PSECinclude.inc}

interface

uses
  Classes, SysUtils, fgl;

type

{*****************************************************************************}
{******              common for levelbased and authbased                 *****}
{*****************************************************************************}

  // The typ of the UserMamagment
  TPSECUsrMgntType = (umtUnknown,
                  umtLevel,
                  umtAuthorizationByUser,
                  umtAuthorizationByGroup,
                  umtAuthorizationByUserAndGroup);

  { TPSECCustomUser }
  //: Implements a simple user, with UID, Login, Description and enable/disable option.
  TPSECCustomUser = class(TObject)
  private
    procedure SetUserPassword(AValue: UTF8String);
  protected
    //immutable fields.
    // Unique user ID
    FUID:Integer;
    // Login(name) of the user maybe also a number (as string)
    FUserLogin:UTF8String;
    // Password of the user (NOT CRYPTED ACTUAL!)
    FUserPassword,
    FOldUserPassword: UTF8String;
    // Ashort description or longname of the user
    FUserDescription,
    FOldUserDescription:UTF8String;
    // Is the user blocked/deaktevated
    FBlockedUser,
    FOldUserState:Boolean;
    procedure SetUserDescription(AValue: UTF8String); virtual;
    procedure SetBlockedUser(AValue: Boolean); virtual;
  public
    constructor Create(aUID:Integer; aUserLogin, aUserPassword, aUserDescription:UTF8String;
      aBlockedUser:Boolean);
    constructor Create(aUID:Integer; aUserLogin, aUserDescription:UTF8String;
      aBlockedUser:Boolean);
    function Modified:Boolean; virtual;
    procedure ResetModified; virtual;
  published
    property UID:integer read FUID;
    property Login:UTF8String read FUserLogin;
    property Password:UTF8String read FUserPassword write SetUserPassword;
    property UserDescription:UTF8String read FUserDescription write SetUserDescription;
    property UserBlocked:Boolean read FBlockedUser write SetBlockedUser;
  end;

  //: Implements a list of simple users
  TPSECUserList = specialize TFPGMap<Integer, TPSECCustomUser>;

  TPSECSimpleUser = class(TPSECCustomUser);

  //: Implements the entire user management schema.
  TPSECUsrMgntSchema = class(TObject)
  public
    class function UsrMgntType:TPSECUsrMgntType; virtual;
  end;



{*****************************************************************************}
{******                         levelbased                               *****}
{*****************************************************************************}
{$ifdef UseLevelSchema}
  //forward.
  TPSECUserWithLevelAccess = class;

  IPSECUsrLevelMgntInterface = interface
    ['{E3103A23-FFAE-4286-8565-C41038285EEF}']
    function LevelAddUser(const UserLogin, UserDescription, PlainPassword:UTF8String;
                     const UsrLevel:Integer;
                     const Blocked:Boolean;
                     out   UID:Integer;
                     out   UsrObject:TPSECUserWithLevelAccess):Boolean;

    function LevelDelUser(var UsrObject:TPSECUserWithLevelAccess):Boolean;

    function LevelUpdateUser(var UsrObject:TPSECUserWithLevelAccess;
                        const UserDescription, PlainPassword:UTF8String;
                        const UsrLevel:Integer;
                        const Blocked:Boolean):Boolean;

    function LevelBlockUser(var UsrObject:TPSECUserWithLevelAccess;
                       const Blocked:Boolean):Boolean;

    function LevelChangeUserPass(var UsrObject:TPSECUserWithLevelAccess;
                            const PlainPassword:UTF8String):Boolean;

  end;

  { TPSECUserWithLevelAccess }
  //: Implements a user with access level.
  TPSECUserWithLevelAccess = class(TPSECCustomUser)
  private
  protected
    FUserLevel,
    FOldUserLevel: Integer;
    procedure SetUserLevel(AValue: Integer);
  public
    constructor Create(aUID: Integer; aUserLogin, aUserDescription: UTF8String;
      aBlockedUser: Boolean; aUserLevel: Integer);
    constructor Create(aUID: Integer; aUserLogin, aUserPassword,
      aUserDescription: UTF8String; aBlockedUser: Boolean; aUserLevel: Integer);
    function Modified:Boolean; override;
    procedure ResetModified; override;
  published
    property UserLevel:Integer read FUserLevel write SetUserLevel;
  end;

  //: Implements a list of users with level access.
  TPSECUserLevelList = specialize TFPGMap<Integer, TPSECUserWithLevelAccess>;

  {:
  Implements a user level based schema.

  This schema consists in:
  ** A user list where each user has a access leve.
  ** Level limits (Min and Max).
  ** The level that makes a user admin.

  This schema is similar to the security system used in Elipse SCADA
  and in Wonderware Intouch.
  }
  TPSECUsrLevelMgntSchema = class(TPSECUsrMgntSchema)
  protected
    FMaxLevel: Integer;
    FMinLevel: Integer;
    FAdminLevel: Integer;
    FUserLevelList:TPSECUserLevelList;
    FLevelInterface:IPSECUsrLevelMgntInterface;
    function GetUserByName(aLogin: UTF8String): TPSECCustomUser;
  public
    constructor Create(aMinLevel, aMaxLevel, aAdminLevel:Integer; LvlMgntIntf:IPSECUsrLevelMgntInterface);
    destructor Destroy; override;
    class function UsrMgntType:TPSECUsrMgntType; override;
    property UserByName[UserName:UTF8String]:TPSECCustomUser read GetUserByName;
  published
    function UserList:TPSECUserLevelList;
    function LevelInterface:IPSECUsrLevelMgntInterface;
    property AdminLevel:Integer read FAdminLevel;
    property MinLevel:Integer read FMinLevel;
    property MaxLevel:Integer read FMaxLevel;
  end;

{$endif UseLevelSchema}

{*****************************************************************************}
{******                           authbased                              *****}
{*****************************************************************************}

{$ifdef UseAuthSchema}

  //: Implements a simple authorization code
  TPSECAuthorization = class(TObject)
  protected
    FAuthID: Integer;
    FDescription: UTF8String;
  public
    constructor Create(aAuthID:Integer; aDescription:UTF8String);
  published
    property AuthID:Integer read FAuthID;
    property Description:UTF8String read FDescription;
  end;

  //: Implements a list of authorization codes
  TPSECAuthorizationList = specialize TFPGMap<Integer, TPSECAuthorization>;

  //: Implements a list with all authorization codes
  TPSECAuthorizations = class(TPSECAuthorizationList)
  public
    function AddAuthorization(aAuthID:Integer; aDescription:UTF8String):TPSECAuthorization;
  end;


  //: Implements a user with user allowed authorizations

  { TPSECAuthorizedUser }

  TPSECAuthorizedUser = class(TPSECCustomUser)
  private
    function GetAuthorizationByID(AuthID:Integer):TPSECAuthorization;
    function GetAuthorization(aIndex: Integer): TPSECAuthorization;
    function GetAuthorizationByName(AuthorizationName: UTF8String
      ): TPSECAuthorization;
    function GetAuthorizationCount: Integer;
  protected
    FUserAuthorizations:TPSECAuthorizationList;
  public
    constructor Create(aUID: Integer; aUserLogin, aUserPassword,
      aUserDescription: UTF8String; aBlockedUser: Boolean);
    constructor Create(aUID: Integer; aUserLogin, aUserDescription: UTF8String;
      aBlockedUser: Boolean);
    destructor Destroy; override;
    function AuthorizationList:TPSECAuthorizationList;
    property AuthorizationCount:Integer read GetAuthorizationCount;
    property Authorization[Index:Integer]:TPSECAuthorization read GetAuthorization;
    property AuthorizationByName[AuthorizationName:UTF8String]:TPSECAuthorization read GetAuthorizationByName;
    property AuthorizationByID[AuthID:Integer]:TPSECAuthorization read GetAuthorizationByID;
  end;

  //: Implements a list of users with specific authorizations
  TPSECAuthorizedUserList = specialize TFPGMap<Integer, TPSECAuthorizedUser>;

  //: Implements a simple usergroup with group-authorizations

  { TPSECCustomGroup }

  TPSECCustomGroup = class(TObject)
  private
    function GetUser(aIndex: Integer): TPSECCustomUser;
    function GetUserByUID(aUID: Integer): TPSECCustomUser;
    function GetUserCount: Integer;
  protected
    FGroupID: Integer;
    FGroupName: UTF8String;
    FAuthorizations:TPSECAuthorizationList;
    FUserList:TPSECUserList;
    function AddCustomUser(const aUser:TPSECCustomUser):Boolean; virtual;
    function DelCustomUser(const aUser:TPSECCustomUser):Boolean; virtual;
    function AddCustomAuth(const aAuth:TPSECAuthorization):Boolean; virtual;
    function DelCustomAuth(const aAuth:TPSECAuthorization):Boolean; virtual;
  public
    constructor Create(aGID:Integer; aGroupName:UTF8String); virtual;
    destructor  Destroy; override;
    function    GroupAuthorizations:TPSECAuthorizationList;

    property UserCount:Integer read GetUserCount;
    property User[Index:Integer]:TPSECCustomUser read GetUser;
    property UserByUID[UID:Integer]:TPSECCustomUser read GetUserByUID;
  published
    property GroupID:Integer read FGroupID;
    property GroupName:UTF8String read FGroupName;
  end;

  {:
  Implements a group were users hence the group authorizations, without user
  specific authorizations.
  }

  { TPSECSimpleUserGroup }

  TPSECSimpleUserGroup = class(TPSECCustomGroup)
  public
    function AddUser(const aUser: TPSECSimpleUser): Boolean;
    function DelUser(const aUser: TPSECSimpleUser): Boolean;
    function AddAuth(const aAuth: TPSECAuthorization): Boolean;
    function DelAuth(const aAuth: TPSECAuthorization): Boolean;
  end;

  TPSECSimpleUserGroupList = specialize TFPGMap<Integer, TPSECSimpleUserGroup>;

  {:
  Implements a group where users inherit the group authorizations, adding it
  with user specific authorizations.
  }
  TPSECUsersGroup = class(TPSECCustomGroup)
  public
    function AddUser(const aUser: TPSECAuthorizedUser): Boolean;
  end;

  TPSECUsrGroupList = specialize TFPGMap<Integer, TPSECUsersGroup>;


  {:
  Implements a user management that uses authorizations to allow/deny access.
  This serve as base for TUsrAuthSchema, TGroupAuthSchema and
  TUsrGroupAuthSchema.
  }
  TPSECAuthBasedUsrMgntSchema = class(TPSECUsrMgntSchema)
  protected
    FAuthorizations:TPSECAuthorizations;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Autorizations:TPSECAuthorizations;
  end;

  {:
  Implements a user management that uses authorizations to allow/deny access,
  where each user has a list of allowed authorizations.

  This schema consists in:
  ** A user list where each user has a list of allowed authorizations.
  ** A list with all authorizations available on the security manager.

  This schema is similar to the securty system used in Siemens WinCC.
  }

  { TPSECUsrAuthSchema }

  TPSECUsrAuthSchema = class(TPSECAuthBasedUsrMgntSchema)
  private
    function GetUser(aIndex: Integer): TPSECCustomUser;
    function GetUserByName(aLogin: UTF8String): TPSECCustomUser;
    function GetUserByUID(aUID: Integer): TPSECCustomUser;
    function GetUserCount: Integer;
  protected
    FUserList:TPSECAuthorizedUserList;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function UsrMgntType:TPSECUsrMgntType; override;
    function UserList:TPSECAuthorizedUserList;
    property UserCount:Integer read GetUserCount;
    property User[Index:Integer]:TPSECCustomUser read GetUser;
    property UserByUID[UID:Integer]:TPSECCustomUser read GetUserByUID;
    property UserByName[UserName:UTF8String]:TPSECCustomUser read GetUserByName;
  end;

  {:
  Implements a user management that uses authorizations to allow/deny access,
  where each user has a list of allowed authorizations and inherits the
  authorizations assigned to the group which it belongs.

  This schema consists in:
  ** A list of users, where each user has a list of specific allowed authorizations.
  ** A list of groups, where each group has a list of allowed authorizations,
     where the users of each group will inherit the group authorizations.
  ** A list with all authorizations available on the security manager.

  This schema is similar to the securty system used in Rockwell FactoryTalk.
  }

  { TPSECUsrGroupAuthSchema }

  TPSECUsrGroupAuthSchema = class(TPSECUsrAuthSchema)
  protected
    FGroupList:TPSECUsrGroupList;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function UsrMgntType:TPSECUsrMgntType; override;
    function GroupList:TPSECUsrGroupList;
  end;

  {:
  Implements a user management that uses authorizations to allow/deny access,
  where each user inherits the authorizations assigned to the group which it
  belongs. On this model, users CAN NOT HAVE SPECIFIC PERMISSIONS.

  This schema consists in:
  ** A list of simple users.
  ** A list of groups, where each group has a list of allowed authorizations,
     where the users of each group will inherit the authorizations assigned to
     the group.
  ** A list with all authorizations available on the security manager.
  }

  { TPSECGroupAuthSchema }

  TPSECGroupAuthSchema = class(TPSECAuthBasedUsrMgntSchema)
  protected
    FUserList:TPSECUserList;
    FGroupList:TPSECSimpleUserGroupList;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function UsrMgntType:TPSECUsrMgntType; override;
    function UserList:TPSECUserList;
    function GroupList:TPSECSimpleUserGroupList;
  end;
{$endif UseAuthSchema}

implementation

uses
  {$ifdef debug_secure}
  LazLogger,
  {$endif}
  PSECExceptions;

{*****************************************************************************}
{******              common for levelbased and authbased                 *****}
{*****************************************************************************}

{ TPSECCustomUser }

procedure TPSECCustomUser.SetBlockedUser(AValue: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FBlockedUser=AValue then Exit;
  FOldUserState:=FBlockedUser;
  FBlockedUser:=AValue;
end;

procedure TPSECCustomUser.SetUserPassword(AValue: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserPassword=AValue then Exit;
  FOldUserPassword:= FUserPassword;
  FUserPassword:=AValue;
end;

procedure TPSECCustomUser.SetUserDescription(AValue: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserDescription=AValue then Exit;
  FOldUserDescription:=FUserDescription;
  FUserDescription:=AValue;
end;

constructor TPSECCustomUser.Create(aUID: Integer; aUserLogin, aUserPassword,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUID:=aUID;
  FUserLogin:=aUserLogin;

  FUserDescription    := aUserDescription;
  FOldUserDescription := aUserDescription;

  FUserPassword   := aUserPassword;
  FOldUserPassword:= aUserPassword;

  FBlockedUser  := aBlockedUser;
  FOldUserState := aBlockedUser;
end;

constructor TPSECCustomUser.Create(aUID: Integer; aUserLogin,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Create(aUID, aUserLogin, '', aUserDescription, aBlockedUser);
end;

function TPSECCustomUser.Modified: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result := (FUserDescription<>FOldUserDescription) or (FBlockedUser<>FOldUserState)
            or (FUserPassword <> FOldUserPassword);
end;

procedure TPSECCustomUser.ResetModified;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FOldUserDescription:=FUserDescription;
  FOldUserPassword:= FUserPassword;
  FOldUserState:=FBlockedUser;
end;

{ TPSECUsrMgntSchema }

class function TPSECUsrMgntSchema.UsrMgntType: TPSECUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= umtUnknown;
end;

{*****************************************************************************}
{******                         levelbased                               *****}
{*****************************************************************************}
{$ifdef UseLevelSchema}

{ TPSECUserWithLevelAccess }
procedure TPSECUserWithLevelAccess.SetUserLevel(AValue: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserLevel=AValue then Exit;
  FUserLevel:=AValue;
end;

constructor TPSECUserWithLevelAccess.Create(aUID: Integer; aUserLogin,
  aUserDescription: UTF8String; aBlockedUser: Boolean; aUserLevel: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Create(aUID, aUserLogin, '', aUserDescription, aBlockedUser, aUserLevel);
end;

constructor TPSECUserWithLevelAccess.Create(aUID: Integer; aUserLogin, aUserPassword,
  aUserDescription: UTF8String; aBlockedUser: Boolean; aUserLevel: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(aUID, aUserLogin, aUserPassword, aUserDescription, aBlockedUser);
  FUserLevel:=aUserLevel;
  FOldUserLevel:=aUserLevel;
end;

function TPSECUserWithLevelAccess.Modified: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  result := inherited Modified or (FUserLevel<>FOldUserLevel)
end;

procedure TPSECUserWithLevelAccess.ResetModified;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited;
  FOldUserLevel := FUserLevel;
end;

{TPSECUsrLevelMgntSchema}

function TPSECUsrLevelMgntSchema.GetUserByName(aLogin: UTF8String): TPSECCustomUser;
var
  i: Integer;
  AuxResult: TPSECUserWithLevelAccess;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserLevelList) then
    for i:= 0 to FUserLevelList.Count-1 do begin
       AuxResult:= FUserLevelList.Data[i];
       if SameStr(aLogin,AuxResult.Login) then begin
         Result:=AuxResult;
         break;
       end;
    end; // for
end;

constructor TPSECUsrLevelMgntSchema.Create(aMinLevel, aMaxLevel,
  aAdminLevel: Integer; LvlMgntIntf: IPSECUsrLevelMgntInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FAdminLevel:=aAdminLevel;
  FUserLevelList:=TPSECUserLevelList.Create;
  if aMinLevel>=aMaxLevel then
    raise EInvalidLevelRanges.Create(aMinLevel,aMaxLevel);
  FMinLevel:=aMinLevel;
  FMaxLevel:=aMaxLevel;
  FLevelInterface:=LvlMgntIntf;
end;

destructor TPSECUsrLevelMgntSchema.Destroy;
var
  i: LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  for i:=FUserLevelList.Count-1 downto 0 do begin
    FUserLevelList.KeyData[FUserLevelList.Keys[i]].Destroy;
    FUserLevelList.Delete(i);
  end;

  inherited Destroy;
end;

class function TPSECUsrLevelMgntSchema.UsrMgntType: TPSECUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TPSECUsrMgntType.umtLevel;
end;

function TPSECUsrLevelMgntSchema.UserList: TPSECUserLevelList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserLevelList;
end;

function TPSECUsrLevelMgntSchema.LevelInterface: IPSECUsrLevelMgntInterface;
begin
  Result:=FLevelInterface;
end;

{$endif UseLevelSchema}

{*****************************************************************************}
{******                           authbased                              *****}
{*****************************************************************************}

{$ifdef UseAuthSchema}

{TPSECUsersGroup}

function TPSECUsersGroup.AddUser(const aUser: TPSECAuthorizedUser): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=AddCustomUser(aUser);
end;

function TPSECSimpleUserGroup.AddUser(const aUser: TPSECSimpleUser): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=AddCustomUser(aUser);
end;

function TPSECSimpleUserGroup.DelUser(const aUser: TPSECSimpleUser): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=DelCustomUser(aUser);
end;

function TPSECSimpleUserGroup.AddAuth(const aAuth: TPSECAuthorization): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=AddCustomAuth(aAuth);
end;

function TPSECSimpleUserGroup.DelAuth(const aAuth: TPSECAuthorization): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=DelCustomAuth(aAuth);
end;

{TPSECGroupAuthSchema}

constructor TPSECGroupAuthSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUserList:=TPSECUserList.Create;
  FGroupList:=TPSECSimpleUserGroupList.Create;
end;

destructor TPSECGroupAuthSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FGroupList);
  FreeAndNil(FUserList);
  inherited Destroy;
end;

class function TPSECGroupAuthSchema.UsrMgntType: TPSECUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TPSECUsrMgntType.umtAuthorizationByGroup;
end;

function TPSECGroupAuthSchema.UserList: TPSECUserList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList;
end;

function TPSECGroupAuthSchema.GroupList: TPSECSimpleUserGroupList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FGroupList;
end;


{TPSECUsrGroupAuthSchema}

constructor TPSECUsrGroupAuthSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FGroupList:=TPSECUsrGroupList.Create;
end;

destructor TPSECUsrGroupAuthSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FGroupList);
  inherited Destroy;
end;

class function TPSECUsrGroupAuthSchema.UsrMgntType: TPSECUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TPSECUsrMgntType.umtAuthorizationByUserAndGroup;
end;

function TPSECUsrGroupAuthSchema.GroupList: TPSECUsrGroupList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FGroupList;
end;

{TPSECUsrAuthSchema}

function TPSECUsrAuthSchema.GetUser(aIndex: Integer): TPSECCustomUser;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and (aIndex<FUserList.Count) then
    result := FUserList.KeyData[FUserList.Keys[aIndex]];
end;

function TPSECUsrAuthSchema.GetUserByName(aLogin: UTF8String): TPSECCustomUser;
var
  i: Integer;
  AuxResult: TPSECAuthorizedUser;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) then
    for i:= 0 to FUserList.Count-1 do begin
       AuxResult:= FUserList.Data[i];
       if SameStr(aLogin,AuxResult.Login) then begin
         Result:=AuxResult;
         break;
       end;
    end; // for
end;

function TPSECUsrAuthSchema.GetUserByUID(aUID: Integer): TPSECCustomUser;
var
  aKeyIdx: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and FUserList.Find(aUID, aKeyIdx) then
    Result := FUserList.KeyData[FUserList.Keys[aKeyIdx]];
end;

function TPSECUsrAuthSchema.GetUserCount: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList.Count;
end;

constructor TPSECUsrAuthSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUserList:=TPSECAuthorizedUserList.Create;
  FUserList.Sorted:=true;
end;

destructor TPSECUsrAuthSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FUserList);
  inherited Destroy;
end;

class function TPSECUsrAuthSchema.UsrMgntType: TPSECUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TPSECUsrMgntType.umtAuthorizationByUser;
end;

function TPSECUsrAuthSchema.UserList: TPSECAuthorizedUserList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList;
end;

{TPSECAuthBasedUsrMgntSchema}

constructor TPSECAuthBasedUsrMgntSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FAuthorizations:=TPSECAuthorizations.Create;
end;

destructor TPSECAuthBasedUsrMgntSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FAuthorizations);
  inherited Destroy;
end;

function TPSECAuthBasedUsrMgntSchema.Autorizations: TPSECAuthorizations;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FAuthorizations;
end;

{TPSECCustomGroup}

function TPSECCustomGroup.GetUser(aIndex: Integer): TPSECCustomUser;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and (aIndex<FUserList.Count) then
    result := FUserList.KeyData[FUserList.Keys[aIndex]];
end;

function TPSECCustomGroup.GetUserByUID(aUID: Integer): TPSECCustomUser;
var
  aKeyIdx: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and FUserList.Find(aUID, aKeyIdx) then
    Result := FUserList.Data[aKeyIdx];
  //Result := FUserList.KeyData[FUserList.Keys[aUID]];
end;

function TPSECCustomGroup.GetUserCount: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList.Count;
end;

function TPSECCustomGroup.AddCustomUser(const aUser: TPSECCustomUser): Boolean;
var
  InsertAtIdx, i: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FUserList) and Assigned(aUser) then begin
    InsertAtIdx:=-1;
    for i:=0 to FUserList.Count-1 do
      if FUserList.Keys[i]<aUser.UID then begin
        InsertAtIdx:=i;
        break;
      end;
    if InsertAtIdx=-1 then begin
      FUserList.Add(aUser.UID, aUser);
      Result:=true;
    end else begin
      FUserList.InsertKeyData(InsertAtIdx, aUser.UID, aUser);
      Result:=true;
    end;
  end;
end;

function TPSECCustomGroup.DelCustomUser(const aUser: TPSECCustomUser): Boolean;
var
  i: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FUserList) and Assigned(aUser) then begin
    for i:=0 to FUserList.Count-1 do
      if FUserList.Keys[i] = aUser.UID then begin
        FUserList.Delete(i);
        Result:=true;
        break;
      end;
  end;
end;

function TPSECCustomGroup.AddCustomAuth(const aAuth: TPSECAuthorization
  ): Boolean;
var
  InsertAtIdx, i: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FAuthorizations) and Assigned(aAuth) then begin
    InsertAtIdx:=-1;
    for i:=0 to FAuthorizations.Count-1 do
      if FAuthorizations.Keys[i]<aAuth.AuthID then begin
        InsertAtIdx:=i;
        break;
      end;
    if InsertAtIdx=-1 then begin
      FAuthorizations.Add(aAuth.AuthID, aAuth);
      Result:=true;
    end else begin
      FAuthorizations.InsertKeyData(InsertAtIdx, aAuth.AuthID, aAuth);
      Result:=true;
    end;
  end;
end;

function TPSECCustomGroup.DelCustomAuth(const aAuth: TPSECAuthorization
  ): Boolean;
var
  i: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if Assigned(FAuthorizations) and Assigned(aAuth) then begin
    for i:=0 to FAuthorizations.Count-1 do
      if FAuthorizations.Keys[i] = aAuth.AuthID then begin
        FAuthorizations.Delete(i);
        Result:=true;
        break;
      end;
  end;
end;

constructor TPSECCustomGroup.Create(aGID: Integer; aGroupName: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUserList:=TPSECUserList.Create;
  FUserList.Sorted:=true;
  FAuthorizations:=TPSECAuthorizationList.Create;
  FGroupID:=aGID;
  FGroupName:=aGroupName;
end;

destructor TPSECCustomGroup.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FUserList);
  FreeAndNil(FAuthorizations);
  inherited Destroy;
end;

function TPSECCustomGroup.GroupAuthorizations: TPSECAuthorizationList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FAuthorizations;
end;

{ TPSECAuthorizedUser }

function TPSECAuthorizedUser.GetAuthorizationByID(AuthID: Integer): TPSECAuthorization;
var
  aux: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserAuthorizations) and FUserAuthorizations.Find(AuthID, aux) then
    result := FUserAuthorizations.KeyData[FUserAuthorizations.Keys[aux]];
end;

function TPSECAuthorizedUser.GetAuthorization(aIndex: Integer): TPSECAuthorization;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserAuthorizations) and (aIndex<FUserAuthorizations.Count) then
    result := FUserAuthorizations.KeyData[FUserAuthorizations.Keys[aIndex]];
end;

function TPSECAuthorizedUser.GetAuthorizationByName(AuthorizationName: UTF8String
  ): TPSECAuthorization;
var
  i: Integer;
  AuxResult: TPSECAuthorization;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserAuthorizations) then
    for i:= 0 to FUserAuthorizations.Count-1 do begin
       AuxResult:= FUserAuthorizations.Data[i];
       if SameStr(AuthorizationName,AuxResult.Description) then begin
         Result:=AuxResult;
         break;
       end;
    end; // for
end;

function TPSECAuthorizedUser.GetAuthorizationCount: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserAuthorizations.Count;
end;

constructor TPSECAuthorizedUser.Create(aUID: Integer; aUserLogin, aUserPassword,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(aUID,aUserLogin,aUserPassword,aUserDescription,aBlockedUser);
  FUserAuthorizations:=TPSECAuthorizationList.Create;
  FUserAuthorizations.Sorted:=true;
end;

constructor TPSECAuthorizedUser.Create(aUID: Integer; aUserLogin,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Create(aUID,aUserLogin, '',aUserDescription,aBlockedUser);
end;


destructor TPSECAuthorizedUser.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FUserAuthorizations);
  inherited Destroy;
end;

function TPSECAuthorizedUser.AuthorizationList: TPSECAuthorizationList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserAuthorizations;
end;

{ TPSECAuthorization }

function TPSECAuthorizations.AddAuthorization(aAuthID: Integer;
  aDescription: UTF8String): TPSECAuthorization;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=TPSECAuthorization.Create(aAuthID, aDescription);
  Add(aAuthID, Result);
end;

constructor TPSECAuthorization.Create(aAuthID: Integer; aDescription: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FAuthID:=aAuthID;
  FDescription:=aDescription;
end;

{$endif UseAuthSchema}


end.

