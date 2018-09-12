unit PSECSecureLevelManager;
{$I PSECinclude.inc}
{ *************************
  Level based SecureManager
  This is a implementation of the SecureManager working with a level based
  security schema. This means, the user have a level defined by a number. The
  security system compare this number with levels. Is the level of the user
  equal or higher, the user have the right to use the component, function or
  event.
  *************************
This is a part of the PSEC (Pascal SECure) framework, it is a
standalone part of PascalSCADA 1.0. A multiplatform SCADA framework for Lazarus.
This code is a entire rewrite of PascalSCADA hosted at
https://sourceforge.net/projects/pascalscada.

Copyright Fabio Luis Girardi (https://github.com/fluisgirardi/pascalsecure)
          Andreas Frieß      (https://github.com/afriess/pascalsecure)

This code is under modified LGPL (see LICENSE.modifiedLGPL.txt).
}

interface

uses
  Classes, SysUtils,
  PSECInterfaces,
  PSECSecureManager;

type
{ TPSECCustomLevelSecureManager }

 TPSECCustomLevelSecureManager = class(TPSECCustomBasicSecureManager)
 protected
   FUserManagement:IPSECBasicUserManagment;
 protected
   function GetUserManagement: IPSECBasicUserManagment;
   procedure SetUserManagement(aUserManagment:IPSECBasicUserManagment);
 public
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
 published
   property UserManagement:IPSECBasicUserManagment read GetUserManagement write SetUserManagement;
 end;

 TPSECLevelSecureManager = class(TPSECCustomLevelSecureManager)
 published
//   property   UserManagement;
 end;



 //protected
 //  function GetControlSecurityManagerExt: TControlSecurityManager;

 //function   Login(Userlogin, Userpassword: String; var UID: Integer):Boolean; overload;
 //function   Login:Boolean;
 //
 //procedure  Logout;
 //procedure  Manage;
 //function   GetCurrentUserlogin:String;
 //function   HasUserLoggedIn:Boolean;
 //procedure  TryAccess(sc:String);
 //procedure RegisterControl(aControl: IPSECControlInterface);
 //procedure UnRegisterControl(aControl: IPSECControlInterface);
 //function   RegisterControlCount:integer;
 //procedure  UpdateControls;
 //// if the SecurityContext is empty, per deault access is allowed
 ////   the Result is only realy checked if a context is given
 //function   CanAccess(sc:String):Boolean;
 //procedure  ValidateSecurityCode(sc:String);
 //procedure  RegisterSecurityCode(sc:String);
 //procedure  UnregisterSecurityCode(sc:String);
 //function   SecurityCodeExists(sc:String):Boolean;
 //function   GetRegisteredAccessCodes:TFPGStringList;
 //function   CheckIfUserIsAllowed(sc:String; RequireUserLogin:Boolean; var userlogin:String):Boolean;

procedure Register;


implementation
{$ifdef debug_secure}
uses
  LazLogger;
{$endif}

ResourceString
  PSECSPalette = 'PascalSecure';

procedure Register;
begin
  RegisterComponents(PSECSPalette,[TPSECLevelSecureManager]);
end;

{ TPSECCustomLevelSecureManager }

//function TPSECCustomLevelSecureManager.GetDummy: TComponent;
//begin
//  Result:= FDummy;
//end;
//
//procedure TPSECCustomLevelSecureManager.SetDummy(AValue: TComponent);
//begin
//  FDummy:= AValue;
//end;

function TPSECCustomLevelSecureManager.GetUserManagement: IPSECBasicUserManagment;
begin
 Result:= FUserManagement;
end;

procedure TPSECCustomLevelSecureManager.SetUserManagement(
 aUserManagment: IPSECBasicUserManagment);
begin
 {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
 if aUserManagment = FUserManagement then
   exit; // ==>>
 FUserManagement:= aUserManagment;
 //  //if (aUserManagment<>nil) and (not (aUserManagment is TBasicUserManagement)) then
 //  //  raise EInvalidUserManagementComponent.Create;
 //  //
 //  //{ TODO -oAndi : why check we this ? }
 //  ////if (um<>nil) and (FUserManagement<>nil) then
 //  ////  raise EUserManagementIsSet.Create;
 //  //
 //  FUserManagement:=aUserManagment;
 //  { TODO -oaf : if it is clear where the manager resides i can work here }
 //  //UpdateControls;
end;

//procedure TPSECCustomLevelSecureManager.SetControlSecurityCode(
// var CurrentSecurityCode: String; const NewSecurityCode: String;
// aControl: IPSECControlInterface);
//begin
//
//end;

constructor TPSECCustomLevelSecureManager.Create(AOwner: TComponent);
begin
 Inherited Create(AOwner);
 pointer(FUserManagement) := nil;  // clear the link without call _Release !!
end;

destructor TPSECCustomLevelSecureManager.Destroy;
begin
  pointer(FUserManagement) := nil;  // clear the link without call _Release !!
  inherited Destroy;
end;


// Usermanagment should be nil, because nobody knows what kind of uermangement we need
//FUserManagement:=nil;
//FSecureControls:=TFPGSecureControlsList.Create;

//if FSecureControls.Count>0 then
//  raise EControlSecurityManagerStillBeingUsed.Create;
//FreeAndNil(FSecureControls);


//procedure TPSECCustomBasicSecureManager.UpdateControls;
//begin
//
//end;
//
//procedure TPSECCustomBasicSecureManager.RegisterControl(aControl: IPSECControlInterface);
//begin
//
//end;

//procedure TPSECCustomBasicSecureManager.UnRegisterControl(aControl: IPSECControlInterface);
//begin
//  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
//end;

//procedure TLevelManager.UpdateControls;
//var
//  c:LongInt;
//  intf: IPSECControlInterface;
//begin
//  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
//  for c:=0 to FSecureControls.Count-1 do begin
//    intf:=IPSECControlInterface(FSecureControls.Items[c]);
//    intf.CanBeAccessed(CanAccess(intf.GetControlSecurityCode));
//  end;
//end;


end.

