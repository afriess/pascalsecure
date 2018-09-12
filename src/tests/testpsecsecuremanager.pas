unit TestPSECSecureManager;
{$I PSECinclude.inc}
{ *************************
  Tests for changing and managment of the ControlManager
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

  { TTestSecureManager }

  TTestSecureManager= class(TTestCase)
  protected
    DUT_CM: TPSECControlManager;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CR_SecureManager;
    procedure CU_SecureLVLManager;
    procedure CU_SecureAuthManager;
    procedure CU_TwoSecureManagerA;
    procedure CU_TwoSecureManagerB;
  end;

implementation
uses
  PSECSecureLevelManager,
  PSECSecureAuthManager;

procedure TTestSecureManager.SetUp;
begin
  DUT_CM:= TPSECControlManager.Create(nil);
  DUT_CM.SecureManager := TPSECBasicSecureManager.Create(nil);
end;

procedure TTestSecureManager.TearDown;
begin
  //if DUT_CM.SecureManager <> nil then begin
  //  DUT_CM.SecureManager.free; // := nil;
  //  DUT_CM := nil;
  //end;
  FreeAndNil(DUT_CM);
end;

procedure TTestSecureManager.CR_SecureManager;
begin
  AssertNotNull('Not correct created object',DUT_CM);
  // Check if the SecureManager is well initialized
  AssertNotNull('SecureManager not initialized',DUT_CM.SecureManager);
  AssertEquals('Wrong Type of SecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), True);
  AssertEquals('Wrong Type of SecureManager, should be TPSECBasicSecureManager',(DUT_CM.SecureManager is TPSECLevelSecureManager), False);
  AssertEquals('Wrong Type of SecureManager, should be TPSECBasicSecureManager',(DUT_CM.SecureManager is TPSECAuthSecureManager), False);
end;

procedure TTestSecureManager.CU_SecureLVLManager;
var
  NewLevelManager : TPSECLevelSecureManager;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TPSECLevelSecureManager.Create(nil);
  DUT_CM.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT_CM.SecureManager is TPSECLevelSecureManager), True);
  AssertEquals('Wrong Type of SecureManager, not TPSECBasicSecureManager should be TLevelSecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), False);
  AssertEquals('Wrong Type of SecureManager, not TAuthSecureManager should be TLevelSecureManager',(DUT_CM.SecureManager is TPSECAuthSecureManager), False);
end;

procedure TTestSecureManager.CU_SecureAuthManager;
var
  NewLevelManager : TPSECAuthSecureManager;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TPSECAuthSecureManager.Create(nil);
  DUT_CM.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TAuthSecureManager',(DUT_CM.SecureManager is TPSECAuthSecureManager), True);
  AssertEquals('Wrong Type of SecureManager, not TPSECBasicSecureManager should be TLevelSecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), False);
  AssertEquals('Wrong Type of SecureManager, not TLevelSecureManager should be TAuthSecureManager',(DUT_CM.SecureManager is TPSECLevelSecureManager), False);
end;

procedure TTestSecureManager.CU_TwoSecureManagerA;
var
  NewLevelManager : TPSECLevelSecureManager;
  NewAuthManager : TPSECAuthSecureManager;
  IsExceptionRaised: boolean;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TPSECLevelSecureManager.Create(nil);
  DUT_CM.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT_CM.SecureManager is TPSECLevelSecureManager), True);
  NewAuthManager := nil;
  IsExceptionRaised := false;
  try
    DUT_CM.SecureManager := NewAuthManager;
  except
    IsExceptionRaised:=true;
  end;
  { TODO -oaf : Changed, no exception should be raised anymore }
  AssertFalse('Exception is raised', IsExceptionRaised);
  // because nothing should be changed, so the old Manager is still available
  AssertEquals('Wrong Type of SecureManager, should be TPSECCustomBasicSecureManager',(DUT_CM.SecureManager is TPSECCustomBasicSecureManager), True);
end;

procedure TTestSecureManager.CU_TwoSecureManagerB;
var
  NewLevelManager : TPSECLevelSecureManager;
  NewAuthManager : TPSECAuthSecureManager;
  IsExceptionRaised: boolean;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT_CM.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TPSECLevelSecureManager.Create(nil);
  DUT_CM.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT_CM.SecureManager is TPSECLevelSecureManager), True);
  IsExceptionRaised := false;
  try
    DUT_CM.SecureManager := nil;
  except
    IsExceptionRaised:=true;
  end;
  AssertFalse('Exception is raised, something wrong with SecureManager', IsExceptionRaised);
  NewAuthManager := TPSECAuthSecureManager.Create(nil);
  IsExceptionRaised := false;
  try
    DUT_CM.SecureManager := NewAuthManager;
  except
    IsExceptionRaised:=true;
  end;
  AssertFalse('Exception is raised', IsExceptionRaised);
  AssertEquals('Wrong Type of SecureManager, should be TAuthSecureManager',(DUT_CM.SecureManager is TPSECAuthSecureManager), True);
end;


initialization

  RegisterTest(TTestSecureManager);
end.

