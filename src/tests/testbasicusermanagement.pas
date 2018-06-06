unit TestBasicUserManagement;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry;

type

  { TTestBasic_user_management }

  TTestBasic_user_management= class(TTestCase)
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CR_CustomBasicUserManagment;
  end;

implementation
uses
  security.manager.basic_user_management;

procedure TTestBasic_user_management.SetUp;
begin

end;

procedure TTestBasic_user_management.TearDown;
begin

end;


type
  TDUTCustomBasicUserManagment = class(TCustomBasicUserManagment)
  public
    property UserMgnt;
    property UsrMgntInterface;
  end;

procedure TTestBasic_user_management.CR_CustomBasicUserManagment;
var
  DUT: TDUTCustomBasicUserManagment;
begin
  DUT:= TDUTCustomBasicUserManagment.Create(nil);
  try
    AssertNotNull('Not correct created object',DUT);
    AssertNull('UserMgnt is not Null',DUT.UserMgnt);
    AssertNull('UsrMgntInterface is not Null',DUT.UsrMgntInterface);
  finally
    DUT.Free;
  end;
end;

initialization

  RegisterTest(TTestBasic_user_management);
end.

