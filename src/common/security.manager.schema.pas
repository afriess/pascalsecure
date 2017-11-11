unit security.manager.schema;

{$I security.include.inc}

interface

uses
  Classes, SysUtils, fgl;

type

{*****************************************************************************}
{******              common for levelbased and authbased                 *****}
{*****************************************************************************}

  // The typ of the UserMamagment
  TUsrMgntType = (umtUnknown,
                  umtLevel,
                  umtAuthorizationByUser,
                  umtAuthorizationByGroup,
                  umtAuthorizationByUserAndGroup);

  { TCustomUser }
  //: Implements a simple user, with UID, Login, Description and enable/disable option.
  TCustomUser = class(TObject)
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
  TUserList = specialize TFPGMap<Integer, TCustomUser>;

  TSimpleUser = class(TCustomUser);

  //: Implements the entire user management schema.
  TUsrMgntSchema = class(TObject)
  public
    class function UsrMgntType:TUsrMgntType; virtual;
  end;



{*****************************************************************************}
{******                         levelbased                               *****}
{*****************************************************************************}
{$ifdef UseLevelSchema}
  //forward.
  TUserWithLevelAccess = class;

  IUsrLevelMgntInterface = interface
    ['{E3103A23-FFAE-4286-8565-C41038285EEF}']
    function LevelAddUser(const UserLogin, UserDescription, PlainPassword:UTF8String;
                     const UsrLevel:Integer;
                     const Blocked:Boolean;
                     out   UID:Integer;
                     out   UsrObject:TUserWithLevelAccess):Boolean;

    function LevelDelUser(var UsrObject:TUserWithLevelAccess):Boolean;

    function LevelUpdateUser(var UsrObject:TUserWithLevelAccess;
                        const UserDescription, PlainPassword:UTF8String;
                        const UsrLevel:Integer;
                        const Blocked:Boolean):Boolean;

    function LevelBlockUser(var UsrObject:TUserWithLevelAccess;
                       const Blocked:Boolean):Boolean;

    function LevelChangeUserPass(var UsrObject:TUserWithLevelAccess;
                            const PlainPassword:UTF8String):Boolean;

  end;

  { TUserWithLevelAccess }
  //: Implements a user with access level.
  TUserWithLevelAccess = class(TCustomUser)
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
  TUserLevelList = specialize TFPGMap<Integer, TUserWithLevelAccess>;

  {:
  Implements a user level based schema.

  This schema consists in:
  ** A user list where each user has a access leve.
  ** Level limits (Min and Max).
  ** The level that makes a user admin.

  This schema is similar to the security system used in Elipse SCADA
  and in Wonderware Intouch.
  }
  TUsrLevelMgntSchema = class(TUsrMgntSchema)
  protected
    FMaxLevel: Integer;
    FMinLevel: Integer;
    FAdminLevel: Integer;
    FUserLevelList:TUserLevelList;
    FLevelInterface:IUsrLevelMgntInterface;
    function GetUserByName(aLogin: UTF8String): TCustomUser;
  public
    constructor Create(aMinLevel, aMaxLevel, aAdminLevel:Integer; LvlMgntIntf:IUsrLevelMgntInterface);
    destructor Destroy; override;
    class function UsrMgntType:TUsrMgntType; override;
    property UserByName[UserName:UTF8String]:TCustomUser read GetUserByName;
  published
    function UserList:TUserLevelList;
    function LevelInterface:IUsrLevelMgntInterface;
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
  TAuthorization = class(TObject)
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
  TAuthorizationList = specialize TFPGMap<Integer, TAuthorization>;

  //: Implements a list with all authorization codes
  TAuthorizations = class(TAuthorizationList)
  public
    function AddAuthorization(aAuthID:Integer; aDescription:UTF8String):TAuthorization;
  end;


  //: Implements a user with user allowed authorizations

  { TAuthorizedUser }

  TAuthorizedUser = class(TCustomUser)
  private
    function GetAuthorizationByID(AuthID:Integer):TAuthorization;
    function GetAuthorization(aIndex: Integer): TAuthorization;
    function GetAuthorizationByName(AuthorizationName: UTF8String
      ): TAuthorization;
    function GetAuthorizationCount: Integer;
  protected
    FUserAuthorizations:TAuthorizationList;
  public
    constructor Create(aUID: Integer; aUserLogin, aUserPassword,
      aUserDescription: UTF8String; aBlockedUser: Boolean);
    constructor Create(aUID: Integer; aUserLogin, aUserDescription: UTF8String;
      aBlockedUser: Boolean);
    destructor Destroy; override;
    function AuthorizationList:TAuthorizationList;
    property AuthorizationCount:Integer read GetAuthorizationCount;
    property Authorization[Index:Integer]:TAuthorization read GetAuthorization;
    property AuthorizationByName[AuthorizationName:UTF8String]:TAuthorization read GetAuthorizationByName;
    property AuthorizationByID[AuthID:Integer]:TAuthorization read GetAuthorizationByID;
  end;

  //: Implements a list of users with specific authorizations
  TAuthorizedUserList = specialize TFPGMap<Integer, TAuthorizedUser>;

  //: Implements a simple usergroup with group-authorizations
  TCustomGroup = class(TObject)
  private
    function GetUser(aIndex: Integer): TCustomUser;
    function GetUserByUID(aUID: Integer): TCustomUser;
    function GetUserCount: Integer;
  protected
    FGroupID: Integer;
    FGroupName: UTF8String;
    FAuthorizations:TAuthorizationList;
    FUserList:TUserList;
    function AddCustomUser(const aUser:TCustomUser):Boolean; virtual;
  public
    constructor Create(aGID:Integer; aGroupName:UTF8String); virtual;
    destructor  Destroy; override;
    function    GroupAuthorizations:TAuthorizationList;

    property UserCount:Integer read GetUserCount;
    property User[Index:Integer]:TCustomUser read GetUser;
    property UserByUID[UID:Integer]:TCustomUser read GetUserByUID;
  published
    property GroupID:Integer read FGroupID;
    property GroupName:UTF8String read FGroupName;
  end;

  {:
  Implements a group were users hence the group authorizations, without user
  specific authorizations.
  }
  TSimpleUserGroup = class(TCustomGroup)
  public
    function AddUser(const aUser: TSimpleUser): Boolean;
  end;

  TSimpleUserGroupList = specialize TFPGMap<Integer, TSimpleUserGroup>;

  {:
  Implements a group where users inherit the group authorizations, adding it
  with user specific authorizations.
  }
  TUsersGroup = class(TCustomGroup)
  public
    function AddUser(const aUser: TAuthorizedUser): Boolean;
  end;

  TUsrGroupList = specialize TFPGMap<Integer, TUsersGroup>;


  {:
  Implements a user management that uses authorizations to allow/deny access.
  This serve as base for TUsrAuthSchema, TGroupAuthSchema and
  TUsrGroupAuthSchema.
  }
  TAuthBasedUsrMgntSchema = class(TUsrMgntSchema)
  protected
    FAuthorizations:TAuthorizations;
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Autorizations:TAuthorizations;
  end;

  {:
  Implements a user management that uses authorizations to allow/deny access,
  where each user has a list of allowed authorizations.

  This schema consists in:
  ** A user list where each user has a list of allowed authorizations.
  ** A list with all authorizations available on the security manager.

  This schema is similar to the securty system used in Siemens WinCC.
  }

  { TUsrAuthSchema }

  TUsrAuthSchema = class(TAuthBasedUsrMgntSchema)
  private
    function GetUser(aIndex: Integer): TCustomUser;
    function GetUserByName(aLogin: UTF8String): TCustomUser;
    function GetUserByUID(aUID: Integer): TCustomUser;
    function GetUserCount: Integer;
  protected
    FUserList:TAuthorizedUserList;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function UsrMgntType:TUsrMgntType; override;
    function UserList:TAuthorizedUserList;
    property UserCount:Integer read GetUserCount;
    property User[Index:Integer]:TCustomUser read GetUser;
    property UserByUID[UID:Integer]:TCustomUser read GetUserByUID;
    property UserByName[UserName:UTF8String]:TCustomUser read GetUserByName;
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

  { TUsrGroupAuthSchema }

  TUsrGroupAuthSchema = class(TUsrAuthSchema)
  protected
    FGroupList:TUsrGroupList;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function UsrMgntType:TUsrMgntType; override;
    function GroupList:TUsrGroupList;
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

  { TGroupAuthSchema }

  TGroupAuthSchema = class(TAuthBasedUsrMgntSchema)
  protected
    FUserList:TUserList;
    FGroupList:TSimpleUserGroupList;
  public
    constructor Create; override;
    destructor Destroy; override;
    class function UsrMgntType:TUsrMgntType; override;
    function UserList:TUserList;
    function GroupList:TSimpleUserGroupList;
  end;
{$endif UseAuthSchema}

implementation

uses
  {$ifdef debug_secure}
  LazLogger,
  {$endif}
  security.exceptions;

{*****************************************************************************}
{******              common for levelbased and authbased                 *****}
{*****************************************************************************}

{ TCustomUser }

procedure TCustomUser.SetBlockedUser(AValue: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FBlockedUser=AValue then Exit;
  FOldUserState:=FBlockedUser;
  FBlockedUser:=AValue;
end;

procedure TCustomUser.SetUserPassword(AValue: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserPassword=AValue then Exit;
  FOldUserPassword:= FUserPassword;
  FUserPassword:=AValue;
end;

procedure TCustomUser.SetUserDescription(AValue: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserDescription=AValue then Exit;
  FOldUserDescription:=FUserDescription;
  FUserDescription:=AValue;
end;

constructor TCustomUser.Create(aUID: Integer; aUserLogin, aUserPassword,
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

constructor TCustomUser.Create(aUID: Integer; aUserLogin,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Create(aUID, aUserLogin, '', aUserDescription, aBlockedUser);
end;

function TCustomUser.Modified: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result := (FUserDescription<>FOldUserDescription) or (FBlockedUser<>FOldUserState)
            or (FUserPassword <> FOldUserPassword);
end;

procedure TCustomUser.ResetModified;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FOldUserDescription:=FUserDescription;
  FOldUserPassword:= FUserPassword;
  FOldUserState:=FBlockedUser;
end;

{ TUsrMgntSchema }

class function TUsrMgntSchema.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= umtUnknown;
end;

{*****************************************************************************}
{******                         levelbased                               *****}
{*****************************************************************************}
{$ifdef UseLevelSchema}

{ TUserWithLevelAccess }
procedure TUserWithLevelAccess.SetUserLevel(AValue: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserLevel=AValue then Exit;
  FUserLevel:=AValue;
end;

constructor TUserWithLevelAccess.Create(aUID: Integer; aUserLogin,
  aUserDescription: UTF8String; aBlockedUser: Boolean; aUserLevel: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Create(aUID, aUserLogin, '', aUserDescription, aBlockedUser, aUserLevel);
end;

constructor TUserWithLevelAccess.Create(aUID: Integer; aUserLogin, aUserPassword,
  aUserDescription: UTF8String; aBlockedUser: Boolean; aUserLevel: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(aUID, aUserLogin, aUserPassword, aUserDescription, aBlockedUser);
  FUserLevel:=aUserLevel;
  FOldUserLevel:=aUserLevel;
end;

function TUserWithLevelAccess.Modified: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  result := inherited Modified or (FUserLevel<>FOldUserLevel)
end;

procedure TUserWithLevelAccess.ResetModified;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited;
  FOldUserLevel := FUserLevel;
end;

{TUsrLevelMgntSchema}

function TUsrLevelMgntSchema.GetUserByName(aLogin: UTF8String): TCustomUser;
var
  i: Integer;
  AuxResult: TUserWithLevelAccess;
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

constructor TUsrLevelMgntSchema.Create(aMinLevel, aMaxLevel,
  aAdminLevel: Integer; LvlMgntIntf: IUsrLevelMgntInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FAdminLevel:=aAdminLevel;
  FUserLevelList:=TUserLevelList.Create;
  if aMinLevel>=aMaxLevel then
    raise EInvalidLevelRanges.Create(aMinLevel,aMaxLevel);
  FMinLevel:=aMinLevel;
  FMaxLevel:=aMaxLevel;
  FLevelInterface:=LvlMgntIntf;
end;

destructor TUsrLevelMgntSchema.Destroy;
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

class function TUsrLevelMgntSchema.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TUsrMgntType.umtLevel;
end;

function TUsrLevelMgntSchema.UserList: TUserLevelList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserLevelList;
end;

function TUsrLevelMgntSchema.LevelInterface: IUsrLevelMgntInterface;
begin
  Result:=FLevelInterface;
end;

{$endif UseLevelSchema}

{*****************************************************************************}
{******                           authbased                              *****}
{*****************************************************************************}

{$ifdef UseAuthSchema}

{TUsersGroup}

function TUsersGroup.AddUser(const aUser: TAuthorizedUser): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=AddCustomUser(aUser);
end;

function TSimpleUserGroup.AddUser(const aUser: TSimpleUser): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=AddCustomUser(aUser);
end;

{TGroupAuthSchema}

constructor TGroupAuthSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUserList:=TUserList.Create;
  FGroupList:=TSimpleUserGroupList.Create;
end;

destructor TGroupAuthSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FGroupList);
  FreeAndNil(FUserList);
  inherited Destroy;
end;

class function TGroupAuthSchema.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TUsrMgntType.umtAuthorizationByGroup;
end;

function TGroupAuthSchema.UserList: TUserList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList;
end;

function TGroupAuthSchema.GroupList: TSimpleUserGroupList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FGroupList;
end;


{TUsrGroupAuthSchema}

constructor TUsrGroupAuthSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FGroupList:=TUsrGroupList.Create;
end;

destructor TUsrGroupAuthSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FGroupList);
  inherited Destroy;
end;

class function TUsrGroupAuthSchema.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TUsrMgntType.umtAuthorizationByUserAndGroup;
end;

function TUsrGroupAuthSchema.GroupList: TUsrGroupList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FGroupList;
end;

{TUsrAuthSchema}

function TUsrAuthSchema.GetUser(aIndex: Integer): TCustomUser;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and (aIndex<FUserList.Count) then
    result := FUserList.KeyData[FUserList.Keys[aIndex]];
end;

function TUsrAuthSchema.GetUserByName(aLogin: UTF8String): TCustomUser;
var
  i: Integer;
  AuxResult: TAuthorizedUser;
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

function TUsrAuthSchema.GetUserByUID(aUID: Integer): TCustomUser;
var
  aKeyIdx: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and FUserList.Find(aUID, aKeyIdx) then
    Result := FUserList.KeyData[FUserList.Keys[aKeyIdx]];
end;

function TUsrAuthSchema.GetUserCount: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList.Count;
end;

constructor TUsrAuthSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUserList:=TAuthorizedUserList.Create;
  FUserList.Sorted:=true;
end;

destructor TUsrAuthSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FUserList);
  inherited Destroy;
end;

class function TUsrAuthSchema.UsrMgntType: TUsrMgntType;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= TUsrMgntType.umtAuthorizationByUser;
end;

function TUsrAuthSchema.UserList: TAuthorizedUserList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList;
end;

{TAuthBasedUsrMgntSchema}

constructor TAuthBasedUsrMgntSchema.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FAuthorizations:=TAuthorizations.Create;
end;

destructor TAuthBasedUsrMgntSchema.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FAuthorizations);
  inherited Destroy;
end;

function TAuthBasedUsrMgntSchema.Autorizations: TAuthorizations;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FAuthorizations;
end;

{TCustomGroup}

function TCustomGroup.GetUser(aIndex: Integer): TCustomUser;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and (aIndex<FUserList.Count) then
    result := FUserList.KeyData[FUserList.Keys[aIndex]];
end;

function TCustomGroup.GetUserByUID(aUID: Integer): TCustomUser;
var
  aKeyIdx: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserList) and FUserList.Find(aUID, aKeyIdx) then
    Result := FUserList.KeyData[FUserList.Keys[aUID]];
end;

function TCustomGroup.GetUserCount: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserList.Count;
end;

function TCustomGroup.AddCustomUser(const aUser: TCustomUser): Boolean;
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

constructor TCustomGroup.Create(aGID: Integer; aGroupName: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FUserList:=TUserList.Create;
  FAuthorizations:=TAuthorizationList.Create;
  FGroupID:=aGID;
  FGroupName:=aGroupName;
end;

destructor TCustomGroup.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FUserList);
  FreeAndNil(FAuthorizations);
  inherited Destroy;
end;

function TCustomGroup.GroupAuthorizations: TAuthorizationList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FAuthorizations;
end;

{ TAuthorizedUser }

function TAuthorizedUser.GetAuthorizationByID(AuthID: Integer): TAuthorization;
var
  aux: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserAuthorizations) and FUserAuthorizations.Find(AuthID, aux) then
    result := FUserAuthorizations.KeyData[FUserAuthorizations.Keys[aux]];
end;

function TAuthorizedUser.GetAuthorization(aIndex: Integer): TAuthorization;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=nil;
  if assigned(FUserAuthorizations) and (aIndex<FUserAuthorizations.Count) then
    result := FUserAuthorizations.KeyData[FUserAuthorizations.Keys[aIndex]];
end;

function TAuthorizedUser.GetAuthorizationByName(AuthorizationName: UTF8String
  ): TAuthorization;
var
  i: Integer;
  AuxResult: TAuthorization;
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

function TAuthorizedUser.GetAuthorizationCount: Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserAuthorizations.Count;
end;

constructor TAuthorizedUser.Create(aUID: Integer; aUserLogin, aUserPassword,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(aUID,aUserLogin,aUserPassword,aUserDescription,aBlockedUser);
  FUserAuthorizations:=TAuthorizationList.Create;
  FUserAuthorizations.Sorted:=true;
end;

constructor TAuthorizedUser.Create(aUID: Integer; aUserLogin,
  aUserDescription: UTF8String; aBlockedUser: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Create(aUID,aUserLogin, '',aUserDescription,aBlockedUser);
end;


destructor TAuthorizedUser.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FUserAuthorizations);
  inherited Destroy;
end;

function TAuthorizedUser.AuthorizationList: TAuthorizationList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FUserAuthorizations;
end;

{ TAuthorization }

function TAuthorizations.AddAuthorization(aAuthID: Integer;
  aDescription: UTF8String): TAuthorization;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=TAuthorization.Create(aAuthID, aDescription);
  Add(aAuthID, Result);
end;

constructor TAuthorization.Create(aAuthID: Integer; aDescription: UTF8String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create;
  FAuthID:=aAuthID;
  FDescription:=aDescription;
end;

{$endif UseAuthSchema}


end.

