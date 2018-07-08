unit testpseccontrolsmanager;
{$I PSECinclude.inc}
{ *************************
  Tests for the ControlManager
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
  { TTestControls_manager }

  TTestControls_manager= class(TTestCase)
  protected
    DUT: TPSECControlManager;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CR_ControlManager;
    procedure CRD_MockControl;
    procedure CRD_MultiMockControl;
  end;

implementation
uses
  MockSecureControl;

procedure TTestControls_manager.SetUp;
begin
  DUT:= TPSECControlManager.Create(nil);
end;

procedure TTestControls_manager.TearDown;
begin
  FreeAndNil(DUT);
end;

procedure TTestControls_manager.CR_ControlManager;
begin
  AssertNotNull('Not correct created object',DUT);
  // Check if the SecureManager is well initialized
  AssertNotNull('SecureManager not initialized',DUT.SecureManager);
  AssertEquals('Wrong Type of SecureManager',(DUT.SecureManager is TPSECBasicSecureManager), True);
end;

procedure TTestControls_manager.CRD_MockControl;
var
  CntrlA : TMockSecureControl;
begin
  AssertNotNull('Not correct created object',DUT);
  CntrlA:= nil;
  TMockSecureControl.TSTControlManager:= DUT;
  AssertEquals('DUT RegisterControlCount',DUT.Count,0);
  CntrlA:= TMockSecureControl.Create(nil);
  AssertNotNull('Not correct created object',CntrlA);
  AssertSame('DUT in Cntrl',DUT,CntrlA.TSTControlManager);
  AssertEquals('DUT RegisterControlCount after controladd',DUT.Count,1);
  AssertEquals('GetControlSecurityCode wrong result',CntrlA.GetControlSecurityCode,'');
  CntrlA.SecurityCode:='xAxA';
  AssertEquals('GetControlSecurityCode wrong result',CntrlA.GetControlSecurityCode,'xAxA');
  CntrlA.MakeUnsecure;
  AssertEquals('GetControlSecurityCode wrong result after MakeUnsecure',CntrlA.GetControlSecurityCode,'');
  CntrlA.Enabled:=False;
  CntrlA.CanBeAccessed(False);
  AssertEquals('inherited Enabled wrong result False/False',CntrlA.TSTIsEnabledInherited,False);
  CntrlA.Enabled:=True;
  CntrlA.CanBeAccessed(False);
  AssertEquals('inherited Enabled wrong result True/False',CntrlA.TSTIsEnabledInherited,False);
  CntrlA.Enabled:=False;
  CntrlA.CanBeAccessed(True);
  AssertEquals('inherited Enabled wrong result False/True',CntrlA.TSTIsEnabledInherited,False);
  CntrlA.Enabled:=True;
  CntrlA.CanBeAccessed(True);
  AssertEquals('inherited Enabled wrong result True/True',CntrlA.TSTIsEnabledInherited,True);
  CntrlA.Free;
  AssertEquals('DUT RegisterControlCount after control free',DUT.Count,0);
  TMockSecureControl.TSTControlManager:= nil;
end;

procedure TTestControls_manager.CRD_MultiMockControl;
type
  TArrCntrls = Array[0..99] of TMockSecureControl;
var
  Cntrls : TArrCntrls;
  i: Integer;
begin
  AssertNotNull('Not correct created object',DUT);
  TMockSecureControl.TSTControlManager:= DUT;
  AssertEquals('DUT RegisterControlCount',DUT.Count,0);
  for i := Low(Cntrls) to High(Cntrls) do begin
    Cntrls[i]:= TMockSecureControl.Create(nil);
    AssertNotNull('Not correct created object',Cntrls[i]);
    AssertSame('DUT in Cntrl',DUT,Cntrls[i].TSTControlManager);
    AssertEquals('DUT RegisterControlCount after controladd',DUT.Count,i+1);
  end;
  for i := Low(Cntrls) to High(Cntrls) do begin
    FreeAndNil(Cntrls[i]);
    AssertEquals('DUT UnRegisterControlCount after free',DUT.Count,High(Cntrls)-i);
  end;
  AssertEquals('DUT UnRegisterControlCount',DUT.Count,0);
end;

initialization

  RegisterTest(TTestControls_manager);
end.

