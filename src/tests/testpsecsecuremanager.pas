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
    DUT: TPSECControlManager;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CR_SecureManager;
    procedure CU_SecureManager;
    procedure CU_TwoSecureManagerA;
    procedure CU_TwoSecureManagerB;
  end;

implementation
uses
  PSECSecureLevelManager,
  PSECSecureAuthManager;

procedure TTestSecureManager.SetUp;
begin
  DUT:= TPSECControlManager.Create(nil);
end;

procedure TTestSecureManager.TearDown;
begin
  FreeAndNil(DUT);
end;

procedure TTestSecureManager.CR_SecureManager;
begin
  AssertNotNull('Not correct created object',DUT);
  // Check if the SecureManager is well initialized
  AssertNotNull('SecureManager not initialized',DUT.SecureManager);
  AssertEquals('Wrong Type of SecureManager',(DUT.SecureManager is TPSECBasicSecureManager), True);
  AssertEquals('Wrong Type of SecureManager, should be TPSECBasicSecureManager',(DUT.SecureManager is TLevelSecureManager), False);
  AssertEquals('Wrong Type of SecureManager, should be TPSECBasicSecureManager',(DUT.SecureManager is TAuthSecureManager), False);
end;

procedure TTestSecureManager.CU_SecureManager;
var
  NewLevelManager : TLevelSecureManager;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TLevelSecureManager.Create(nil);
  DUT.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT.SecureManager is TLevelSecureManager), True);
  AssertEquals('Wrong Type of SecureManager, not TPSECBasicSecureManager should be TLevelSecureManager',(DUT.SecureManager is TPSECBasicSecureManager), False);
  AssertEquals('Wrong Type of SecureManager, not TAuthSecureManager should be TLevelSecureManager',(DUT.SecureManager is TAuthSecureManager), False);
end;

procedure TTestSecureManager.CU_TwoSecureManagerA;
var
  NewLevelManager : TLevelSecureManager;
  NewAuthManager : TAuthSecureManager;
  IsExceptionRaised: boolean;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TLevelSecureManager.Create(nil);
  DUT.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT.SecureManager is TLevelSecureManager), True);
  NewAuthManager := TAuthSecureManager.Create(nil);
  IsExceptionRaised := false;
  try
    DUT.SecureManager := NewAuthManager;
  except
    IsExceptionRaised:=true;
  end;
  AssertTrue('Exception is not raised', IsExceptionRaised);
  // because nothing should be changed, so the old Manager is still available
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT.SecureManager is TLevelSecureManager), True);
end;

procedure TTestSecureManager.CU_TwoSecureManagerB;
var
  NewLevelManager : TLevelSecureManager;
  NewAuthManager : TAuthSecureManager;
  IsExceptionRaised: boolean;
begin
  AssertEquals('Wrong Type of SecureManager',(DUT.SecureManager is TPSECBasicSecureManager), True);
  NewLevelManager := TLevelSecureManager.Create(nil);
  DUT.SecureManager := NewLevelManager;
  AssertEquals('Wrong Type of SecureManager, should be TLevelSecureManager',(DUT.SecureManager is TLevelSecureManager), True);
  IsExceptionRaised := false;
  try
    DUT.SecureManager := nil;
  except
    IsExceptionRaised:=true;
  end;
  AssertFalse('Exception is raised, something wrong with SecureManager', IsExceptionRaised);
  NewAuthManager := TAuthSecureManager.Create(nil);
  IsExceptionRaised := false;
  try
    DUT.SecureManager := NewAuthManager;
  except
    IsExceptionRaised:=true;
  end;
  AssertFalse('Exception is raised', IsExceptionRaised);
  AssertEquals('Wrong Type of SecureManager, should be TAuthSecureManager',(DUT.SecureManager is TAuthSecureManager), True);
end;


initialization

  RegisterTest(TTestSecureManager);
end.

