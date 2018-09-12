unit TestPSECAuthUserschema;
{$I PSECinclude.inc}
{ *************************
  Tests for changing and managment of the UserSchema
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
  Classes, SysUtils, fpcunit, testutils, testregistry, PSECUserSchema;

type
// Prefix of the tests
// C = Create
// R = Read
// U = Update/Change
// D = Delete/Remove

  { TTestAuthUserSchema }

  TTestAuthUserSchema= class(TTestCase)
  private
  protected
    DUT: TPSECGroupAuthSchema;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure C_GroupAuthSchema;
    procedure CD_InsertUser;
    procedure CD_InsertGoup;
  end;

implementation

procedure TTestAuthUserSchema.C_GroupAuthSchema;
begin
  AssertNotNull('Not correct created object',DUT);
  AssertEquals('Wrong Type of AuthSchema',(DUT is TPSECGroupAuthSchema), True);
  AssertEquals('Wrong Type of Schema',(DUT.UsrMgntType = TPSECUsrMgntType.umtAuthorizationByGroup), True);
end;

procedure TTestAuthUserSchema.CD_InsertUser;
var
  User : TPSECSimpleUser;
  uUid: Integer;
begin
  AssertEquals('User Count not empty',0,DUT.UserList.Count);
  for uUid := 1 to 100 do begin
    User := TPSECSimpleUser.Create(uUid,'tester'+IntToStr(uUid),'secret','First Tester',false);
    DUT.UserList.Add(uUid,User);
    AssertEquals('User Count not ' + IntToStr(uUid),uUid,DUT.UserList.Count);
  end;
  DUT.UserList.Clear;
  AssertEquals('User Count not empty',0,DUT.UserList.Count);
end;

procedure TTestAuthUserSchema.CD_InsertGoup;
var
  Grp : TPSECSimpleUserGroup;
  uGrpid: Integer;
begin
  AssertEquals('Group Count not empty',0,DUT.GroupList.Count);
  for uGrpid := 1 to 100 do begin
    Grp := TPSECSimpleUserGroup.Create(uGrpid,'grp'+IntToStr(uGrpid));
    DUT.GroupList.Add(uGrpid,Grp);
    AssertEquals('Group Count not ' + IntToStr(uGrpid),uGrpid,DUT.GroupList.Count);
  end;
  DUT.GroupList.Clear;
  AssertEquals('User Count not empty',0,DUT.GroupList.Count);
end;


procedure TTestAuthUserSchema.SetUp;
begin
  DUT := TPSECGroupAuthSchema.Create;
end;

procedure TTestAuthUserSchema.TearDown;
begin
  FreeAndNil(DUT);
end;

initialization

  RegisterTest(TTestAuthUserSchema);
end.

