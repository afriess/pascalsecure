unit TestPSECAuthSecureManager;
{$I PSECinclude.inc}
{ *************************
  Tests for changing and managment of the AuthControlManager
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
  PSECInterfaces, PSECcontrolsManager, PSECSecureManager;

// Prefix of the tests
// C = Create
// R = Read
// U = Update/Change
// D = Delete/Remove

type

  { TTestAuthSecureManager }

  TTestAuthSecureManager= class(TTestCase)
  protected
    DUT_CM: TPSECControlManager;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CR_AuthSecureManager;

  end;

implementation
uses
  PSECSecureLevelManager,
  PSECSecureAuthManager;

procedure TTestAuthSecureManager.SetUp;
begin
  DUT_CM:= TPSECControlManager.Create(nil);
  DUT_CM.SecureManager := TPSECAuthSecureManager.Create(nil);
end;

procedure TTestAuthSecureManager.TearDown;
begin
  if DUT_CM.SecureManager <> nil then begin
    DUT_CM.SecureManager := nil;
  end;
  FreeAndNil(DUT_CM);
end;

procedure TTestAuthSecureManager.CR_AuthSecureManager;
begin
  AssertNotNull('Not correct created object',DUT_CM);
  // Check if the SecureManager is well initialized
  AssertNotNull('SecureManager not initialized',DUT_CM.SecureManager);
  AssertEquals('Wrong Type of SecureManager',(DUT_CM.SecureManager is TPSECAuthSecureManager), True);
  AssertEquals('Wrong Type of SecureManager, should be TPSECBasicSecureManager',(DUT_CM.SecureManager is TPSECLevelSecureManager), False);
end;




initialization

  RegisterTest(TTestAuthSecureManager);
end.

