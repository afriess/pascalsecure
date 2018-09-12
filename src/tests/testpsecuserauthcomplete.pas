unit TestPSECUserAuthComplete;
{$I PSECinclude.inc}
{ *************************
  Tests - are the parts working togehther
  *************************
This is a part of the Testsuite of PSEC (Pascal SECure) framework, it is a
standalone part of PascalSCADA 1.0. A multiplatform SCADA framework for Lazarus.
This code is a entire rewrite of PascalSCADA hosted at
https://sourceforge.net/projects/pascalscada.

Copyright Andreas Frieß      (https://github.com/afriess/pascalsecure)
          Fabio Luis Girardi (https://github.com/fluisgirardi/pascalsecure)

This code is under modified LGPL (see LICENSE.modifiedLGPL.txt).
}
interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  PSECcontrolsManager,PSECSecureAuthManager,PSECUserSchema;

type
  // Prefix of the tests
  // C = Create
  // R = Read
  // U = Update/Change
  // D = Delete/Remove


  { TTestUserAuthComplete }

  TTestUserAuthComplete= class(TTestCase)
  protected
    DUT_CM: TPSECControlManager;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CD_OneUserLoginLogout;
    procedure CD_OneUserLoginBad;
    procedure CD_OneGroup;
    procedure C_OneUserInGroup;
    procedure CD_GroupAuth;
    procedure CR_GroupAuth;
  end;

implementation

procedure TTestUserAuthComplete.CD_OneUserLoginLogout;
var
  uUid,testID: Integer;
  uName : string;
begin
  AssertEquals('User Count not empty',0,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.UserList.Count);
  AssertEquals('Group Count not empty',0,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.GroupList.Count);
  //
  uUid:=123;
  uName := 'tester'+IntToStr(uUid);
  TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddUser(uUid,uName,'First Tester','secret','',false);
  AssertEquals('User Count not 1',1,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.UserList.Count);
  // Login
  AssertTrue('Login not working',TPSECAuthSecureManager(DUT_CM.SecureManager).Login(uName,'secret',testID));
  AssertEquals('Userid not the same, should '+IntToStr(uUid)+' is ' + IntToStr(testID),uUid,testID);
  AssertTrue('Check Login not working',TPSECAuthSecureManager(DUT_CM.SecureManager).IsUserLoggedIn);
  AssertEquals('User not the same, should '+uName+' is ' + TPSECAuthSecureManager(DUT_CM.SecureManager).GetCurrentUserlogin,uName,TPSECAuthSecureManager(DUT_CM.SecureManager).GetCurrentUserlogin);
  // logout
  TPSECAuthSecureManager(DUT_CM.SecureManager).Logout;
  AssertFalse('Check Logout not working',TPSECAuthSecureManager(DUT_CM.SecureManager).IsUserLoggedIn);
  AssertEquals('Current Userlogin should empty','',TPSECAuthSecureManager(DUT_CM.SecureManager).GetCurrentUserlogin);
end;

procedure TTestUserAuthComplete.CD_OneUserLoginBad;
var
  uUid, testID: Integer;
  uName : string;
begin
  uUid:=124;
  testid := -1;
  uName := 'tester'+IntToStr(uUid);
  TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddUser(uUid,uName,'First Tester','bad','',false);
  AssertEquals('User Count not 1',1,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.UserList.Count);
  // Test the login - must be bad
  AssertFalse('Login should not working',TPSECAuthSecureManager(DUT_CM.SecureManager).Login(uName,'secret',testID));
  AssertFalse('Check Login not working',TPSECAuthSecureManager(DUT_CM.SecureManager).IsUserLoggedIn);
  AssertEquals('Current Userlogin should empty','',TPSECAuthSecureManager(DUT_CM.SecureManager).GetCurrentUserlogin);
  // Logout should not change anything
  TPSECAuthSecureManager(DUT_CM.SecureManager).Logout;
  AssertFalse('Check Logout is false',TPSECAuthSecureManager(DUT_CM.SecureManager).IsUserLoggedIn);
  AssertTrue('Delete said false',TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.DelUser(uUid));
  AssertEquals('User Count not 0',0,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.UserList.Count);
end;

procedure TTestUserAuthComplete.CD_OneGroup;
var
  uGrpid : integer;
  uName : string;
begin
  uGrpid:= 567;
  uName:= 'grp'+IntToStr(uGrpid);
  AssertTrue('Add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddGroup(uGrpid,UName));
  AssertEquals('Group Count not 1',1,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.GroupList.Count);
  //
  AssertTrue('Delete said false',TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.DelGroup(uGrpid));
  AssertEquals('Group Count not 0',0,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.GroupList.Count);
end;

procedure TTestUserAuthComplete.C_OneUserInGroup;
var
  uUid, uGrpid: Integer;
  uName, uGrp : string;
begin
  uUid:= 123;
  uGrpid:= 567;
  uName:= 'user'+IntToStr(uUid);
  uGrp:= 'grp'+IntToStr(uGrpid);
  // Prepare user and group
  AssertTrue('Useradd say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddUser(uUid,uName,'First Tester','good','',false));
  AssertEquals('User Count not 1',1,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.UserList.Count);
  AssertTrue('Groupadd say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddGroup(uGrpid,uGrp));
  AssertEquals('Group Count not 1',1,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.GroupList.Count);
  // Add user to the group
  AssertFalse('User should not in Group', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.IsUserInGroup(uGrpid,uUid));
  AssertTrue('User in Group add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddUserToGroup(uGrpid,uUid));
  // Check if user is in group
  AssertTrue('User is not in group', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.IsUserInGroup(uGrpid,uUid));
  // Check if user is in one of the groups
  AssertTrue('User is not used in group', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.IsUserUsedInGroups(uUid));
  // ----
  // Remove user from group
  AssertTrue('User in Group delete say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.DelUserFromGroup(uGrpid,uUid));
  // Check if user is not in group
  AssertFalse('User is not in group', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.IsUserInGroup(uGrpid,uUid));
  // Check if user is not in one of the groups
  AssertFalse('User is not used in group', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.IsUserUsedInGroups(uUid));
end;

procedure TTestUserAuthComplete.CD_GroupAuth;
var
  uAuthid, uGrpid: Integer;
  uAuth, uGrp : string;
begin
  uAuthid:= 1212;
  uGrpid:= 678;
  uAuth:= 'auth'+IntToStr(uAuthid);
  uGrp:= 'grp'+IntToStr(uGrpid);
  // Create group
  AssertTrue('Group add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddGroup(uGrpid,uGrp));
  AssertEquals('Group Count not 1',1,TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.GroupList.Count);
  //
  AssertTrue('Auth add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddAuthToGroup(uGrpid,uAuthid,uAuth));

  AssertTrue('Auth del say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.DelAuthFromGroup(uGrpid,uAuthid));
end;

procedure TTestUserAuthComplete.CR_GroupAuth;
var
  uAuthid, uGrpid, uUid: Integer;
  uAuth, uGrp, uName : string;
begin
  uAuthid:= 1212;
  uUid:= 123;
  uName:= 'user'+IntToStr(uUid);
  uGrpid:= 678;
  uAuth:= 'auth'+IntToStr(uAuthid);
  uGrp:= 'grp'+IntToStr(uGrpid);
  AssertTrue('Useradd say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddUser(uUid,uName,'First Tester','good','',false));
  AssertTrue('Group add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddGroup(uGrpid,uGrp));
  AssertTrue('User in Group add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddUserToGroup(uGrpid,uUid));
  // Check if the user have not or have Auth
  AssertFalse('User has Auth', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.HasUserAuth(uUid,uAuth));
  AssertTrue('Auth add say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.AddAuthToGroup(uGrpid,uAuthid,uAuth));
  AssertTrue('User has not Auth', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.HasUserAuth(uUid,uAuth));
  // Remove Auth and check
  AssertTrue('Auth del say false', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.DelAuthFromGroup(uGrpid,uAuthid));
  AssertFalse('User has Auth', TPSECAuthSecureManager(DUT_CM.SecureManager).UserAuthSchema.HasUserAuth(uUid,uAuth));
end;

procedure TTestUserAuthComplete.SetUp;
begin
  DUT_CM:= TPSECControlManager.Create(nil);
  DUT_CM.SecureManager := TPSECAuthSecureManager.Create(nil);
end;

procedure TTestUserAuthComplete.TearDown;
begin
  if DUT_CM.SecureManager <> nil then begin
    DUT_CM.SecureManager := nil;
  end;
  FreeAndNil(DUT_CM);
end;

initialization

  RegisterTest(TTestUserAuthComplete);
end.

