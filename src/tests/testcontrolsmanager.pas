unit TestControlsManager;

{$I PSECinclude.inc}

interface

uses
  Classes, SysUtils, fpcunit, testutils, testregistry,
  security.manager.controls_manager
  ;

type

  { TTestControls_manager }

  TTestControls_manager= class(TTestCase)
  protected
    DUT: TControlSecurityManager;
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure CR_ControlSecurityManager;
    procedure TST_CSM_Control;
  end;

implementation
uses
  MockSecureControl;

procedure TTestControls_manager.SetUp;
begin
  DUT:= TControlSecurityManager.Create(nil);
end;

procedure TTestControls_manager.TearDown;
begin
  DUT.Free;
end;

procedure TTestControls_manager.CR_ControlSecurityManager;
var
  DummyInt: Integer;
begin
  AssertNotNull('Not correct created object',DUT);
  // Usermanagment should be null, because nobody knows what kind of uermangement we need
  AssertNull('UserManagement is not Null',DUT.UserManagement);
  AssertFalse('Login wrong result',DUT.Login);
  AssertFalse('Login(..) wrong result',DUT.Login('','',DummyInt));
  AssertEquals('GetCurrentUserlogin wrong result','',DUT.GetCurrentUserlogin);
  AssertEquals('HasUserLoggedIn wrong result',False,DUT.HasUserLoggedIn);
  { TODO -oFabio : Is this default correct ? }
  // if no sc (SecurityContext) is given Result is true by default
  AssertEquals('CanAccess default wrong result',True,DUT.CanAccess(''));
  // with a real sc, the sc is checked !!
  AssertEquals('CanAccess wrong result',False,DUT.CanAccess('dummy'));
  AssertEquals('SecurityCodeExists wrong result',False,DUT.SecurityCodeExists(''));
end;

procedure TTestControls_manager.TST_CSM_Control;
var
  CntrlA : TMockSecureControl;
  dummystr: String;
begin
  AssertNotNull('Not correct created object',DUT);
  CntrlA:= nil;
  TMockSecureControl.TSTControlManager:= DUT;
  AssertEquals('DUT RegisterControlCount',DUT.RegisterControlCount,0);
  CntrlA:= TMockSecureControl.Create(nil);
  AssertNotNull('Not correct created object',CntrlA);
  AssertSame('DUT in Cntrl',DUT,CntrlA.TSTControlManager);
  AssertEquals('DUT RegisterControlCount after controladd',DUT.RegisterControlCount,1);
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
  TMockSecureControl.TSTControlManager:= nil;
end;

initialization

  RegisterTest(TTestControls_manager);
end.

