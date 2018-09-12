unit PSECAuthUserManager;

{$mode objfpc}{$H+}
{$WARN 6058 off : Call to subroutine "$1" marked as inline is not inlined}
interface

uses
  Classes, SysUtils,PSECInterfaces, PSECUserSchema;

type

  {TPSECCustomAuthUserManager
   Implements a user management where each user inherits the authorizations
   assigned to the group which it belongs.
   }
  TPSECCustomAuthUserManager = class(TPSECGroupAuthSchema)
  private

  public
    constructor Create; override;
    destructor Destroy; override;
    // Interface User
    function AddUser(UID: Integer; const UserLogin, UserDescription, PlainPassword: String;
      const {%H-}UsrAuth: String; const Blocked: Boolean): Boolean;
    function BlockUser(const UID: Integer; const Blocked: Boolean): Boolean;
    function ChangeUserPass(const UID: Integer; const PlainPassword: String): Boolean;
    function DelUser(const UID: Integer): Boolean;
    function UpdateUser(const UID: Integer;
      const UserDescription, PlainPassword: String; const UsrAuth: String;
      const Blocked: Boolean): Boolean;
    // Interface Group
    function AddGroup(GrpID: integer; GrpName: string):Boolean;
    function DelGroup(const GrpID: Integer): Boolean;
    function AddUserToGroup(GrpID, UserID : integer):boolean;
    function DelUserFromGroup(GrpID, UserID : integer):boolean;
    function AddAuthToGroup(GrpID, AuthID : integer; AuthName: string):boolean;
    function DelAuthFromGroup(GrpID, AuthID : integer):boolean;
    // Managment user
    function CanUserLogin(const UserLogin, PlainPassword: String; out UID: integer):boolean;
    function GetUserName(UID: integer):string;
    // Managment group
    function GetGroupName(GrpID: integer):string;
    function IsUserInGroup(GrpID, UserID : integer):boolean;
    function IsUserUsedInGroups(UserID : integer):boolean;
    // Managment auth
    function HasUserAuth(UserID: integer; AuthName: string):boolean;
  end;

  TPSECAuthUserManager = class(TPSECCustomAuthUserManager)

  end;

implementation

{ TPSECCustomAuthUserManager }

function TPSECCustomAuthUserManager.AddUser(UID: Integer; const UserLogin,
  UserDescription, PlainPassword: String; const UsrAuth: String;
  const Blocked: Boolean): Boolean;
var
  User: TPSECSimpleUser;
  UserIdx : integer;
begin
  Result := false;
  UserIdx := UserList.IndexOf(UID);
  if UserIdx < 0 then begin
    User := TPSECSimpleUser.Create(UID,UserLogin,PlainPassword,UserDescription,Blocked);
    UserList.Add(UID,User);
    Result := true;
  end;
end;

function TPSECCustomAuthUserManager.BlockUser(const UID: Integer;
  const Blocked: Boolean): Boolean;
begin
  { TODO -oAndi : Write code here }
  Result := false;
end;

function TPSECCustomAuthUserManager.ChangeUserPass(const UID: Integer;
  const PlainPassword: String): Boolean;
begin
  { TODO -oAndi : Write code here }
  Result := false;
end;

constructor TPSECCustomAuthUserManager.Create;
begin
  inherited Create;

end;

function TPSECCustomAuthUserManager.DelUser(const UID: Integer): Boolean;
var
  UserIdx: Integer;
begin
  Result := false;
  { TODO -oandi : check if user is used !!}
  UserIdx := UserList.IndexOf(UID);
  if UserIdx >= 0 then begin
    TPSECSimpleUser(UserList.Data[UserIdx]).Free;
    UserList.Delete(UserIdx);
    Result := (UserList.IndexOf(UID) < 0);
  end;
end;

destructor TPSECCustomAuthUserManager.Destroy;
begin
  inherited Destroy;
end;

function TPSECCustomAuthUserManager.UpdateUser(const UID: Integer;
  const UserDescription, PlainPassword: String; const UsrAuth: String;
  const Blocked: Boolean): Boolean;
begin
  { TODO -oAndi : Write code here }
  Result := false;
end;

function TPSECCustomAuthUserManager.AddGroup(GrpID: integer; GrpName: string
  ): Boolean;
var
  Grp: TPSECSimpleUserGroup;
  GrpIdx : integer;
begin
  Result := false;
  GrpIdx := GroupList.IndexOf(GrpID);
  if GrpIdx < 0 then begin
    Grp := TPSECSimpleUserGroup.Create(GrpID,GrpName);
    GroupList.Add(GrpID,Grp);
    Result := true;
  end;
end;

function TPSECCustomAuthUserManager.DelGroup(const GrpID: Integer): Boolean;
var
  GrpIdx: Integer;
begin
  Result := false;
  { TODO -oandi : check if group is used !!}
  GrpIdx := GroupList.IndexOf(GrpID);
  if GrpIdx >= 0 then begin
    TPSECSimpleUserGroup(GroupList.Data[GrpIdx]).Free;
    GroupList.Delete(GrpIdx);
    Result := (GroupList.IndexOf(GrpID) < 0);
  end;
end;

function TPSECCustomAuthUserManager.AddUserToGroup(GrpID, UserID: integer
  ): boolean;
var
  Grp: TPSECSimpleUserGroup;
  GrpIdx, UserIdx : integer;
  User: TPSECSimpleUser;
begin
  Result := false;
  GrpIdx := GroupList.IndexOf(GrpID);
  UserIdx:= UserList.IndexOf(UserID);
  if (GrpIdx >= 0) and (UserIdx >= 0) then begin
    User:= TPSECSimpleUser(UserList.Data[UserIdx]);
    GroupList.Data[GrpIdx].AddUser(User);
    Result := true;
  end;
end;

function TPSECCustomAuthUserManager.DelUserFromGroup(GrpID, UserID: integer
  ): boolean;
var
  Grp: TPSECSimpleUserGroup;
  User: TPSECSimpleUser;
  GrpIdx, UserIdx : integer;
begin
  Result := false;
  GrpIdx := GroupList.IndexOf(GrpID);
  if (GrpIdx >= 0) then begin
    UserIdx:= UserList.IndexOf(UserID);
    User:= TPSECSimpleUser(UserList.Data[UserIdx]);
    GroupList.Data[GrpIdx].DelUser(User);
    Result := true;
  end;
end;

function TPSECCustomAuthUserManager.AddAuthToGroup(GrpID, AuthID: integer;
  AuthName: string): boolean;
var
  GrpIdx: integer;
  aAuth : TPSECAuthorization;
begin
  Result := false;
  GrpIdx := GroupList.IndexOf(GrpID);
  if (GrpIdx >= 0) then begin
    aAuth := TPSECAuthorization.Create(AuthID,AuthName);
    Result := GroupList.Data[GrpIdx].AddAuth(aAuth);
  end;
end;

function TPSECCustomAuthUserManager.DelAuthFromGroup(GrpID, AuthID: integer
  ): boolean;
var
  Grp: TPSECSimpleUserGroup;
  aAuth : TPSECAuthorization;
  GrpIdx, AuthIdx : integer;
begin
  Result := false;
  GrpIdx := GroupList.IndexOf(GrpID);
  if (GrpIdx >= 0) then begin
    AuthIdx:= GroupList.Data[GrpIdx].GroupAuthorizations.IndexOf(AuthID);
    if (AuthIdx >= 0) then begin
    aAuth:= TPSECAuthorization(GroupList.Data[GrpIdx].GroupAuthorizations.Data[AuthIdx]);
    Result := GroupList.Data[GrpIdx].DelAuth(aAuth);
    end;
  end;
end;

function TPSECCustomAuthUserManager.CanUserLogin(const UserLogin,
  PlainPassword: String; out UID: integer): boolean;
var
  User: TPSECSimpleUser;
  i: Integer;
begin
  Result := false;
  UID := -1;
  for i:= 0 to UserList.Count-1 do begin
    User := TPSECSimpleUser(UserList.Data[i]);
    if (User <> nil) and SameStr(User.Login,UserLogin)
       and SameStr(User.Password,PlainPassword) and (not User.UserBlocked) then begin
      UID := User.UID;
      Result := true;
      exit;
    end;
  end;
end;

function TPSECCustomAuthUserManager.GetUserName(UID: integer): string;
var
  UserIdx : integer;
begin
  Result := '';
  UserIdx := UserList.IndexOf(UID);
  if UserIdx >= 0 then begin
    Result := TPSECSimpleUser(UserList.Data[UserIdx]).Login;
  end;
end;

function TPSECCustomAuthUserManager.GetGroupName(GrpID: integer): string;
var
  GrpIdx : integer;
begin
  Result := '';
  GrpIdx := GroupList.IndexOf(GrpID);
  if GrpIdx >= 0 then begin
    Result := TPSECSimpleUserGroup(GroupList.Data[GrpIdx]).GroupName;
  end;
end;

function TPSECCustomAuthUserManager.IsUserInGroup(GrpID, UserID: integer
  ): boolean;
var
  Grp: TPSECSimpleUserGroup;
  User: TPSECSimpleUser;
  GrpIdx, UserIdx : integer;
begin
  Result := false;
  GrpIdx := GroupList.IndexOf(GrpID);
  if (GrpIdx >= 0) then begin
    GroupList.Data[GrpIdx].UserByUID[UserID];
    Result := (GroupList.Data[GrpIdx].UserByUID[UserID] <> nil);
  end;
end;

function TPSECCustomAuthUserManager.IsUserUsedInGroups(UserID: integer): boolean;
var
  Grp: TPSECSimpleUserGroup;
  User: TPSECSimpleUser;
  GrpIdx, UserIdx : integer;
begin
  Result := false;
  for GrpIdx:= 0 to GroupList.Count-1 do begin
    GroupList.Data[GrpIdx].UserByUID[UserID];
    if (GroupList.Data[GrpIdx].UserByUID[UserID] <> nil) then begin
      Result := true;
      break;
    end;
  end;
end;

function TPSECCustomAuthUserManager.HasUserAuth(UserID: integer;
  AuthName: string): boolean;
var
  Grp: TPSECSimpleUserGroup;
  Auth: TPSECSimpleUser;
  GrpIdx, UserIdx , i: integer;
begin
  Result := false;
  for GrpIdx:= 0 to GroupList.Count-1 do begin
    GroupList.Data[GrpIdx].UserByUID[UserID];
    if (GroupList.Data[GrpIdx].UserByUID[UserID] <> nil) then begin
      // user is in group
      for i:= 0 to GroupList.Data[GrpIdx].GroupAuthorizations.Count-1 do begin
        if SameText(AuthName,GroupList.Data[GrpIdx].GroupAuthorizations.Data[i].Description) then begin
          Result := true;
          break;
        end;
      end;
    end;
  end;
end;

end.

