unit PSECcontrolsManager;
{$I PSECinclude.inc}
{ *************************
  ControlsManager
  Manages and hold the list of the Secure Controls.
  Holds also the actual SecureManager
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
  Classes, SysUtils, fgl,
  PSECInterfaces,
  PSECSecuremanager;

Type

  TPSECControlsList = specialize TFPGList<IPSECControlInterface>;

  { TPSECControlManager } // Is a singleton, because we can only have one

//  TPSECControlManager  = class(TInterfacedObject, IPSECManager)
  TPSECControlManager  = class(TComponent, IPSECManager)
  private
    function GetSecureManager: TPSECCustomBasicSecureManager;
    procedure SetSecureManager(AValue: TPSECCustomBasicSecureManager);
  protected
    FSecureControls:TPSECControlsList;
    FSecureManager: TPSECCustomBasicSecureManager;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure  RegisterControl(aControl: IPSECControlInterface);
    procedure  UnRegisterControl(aControl: IPSECControlInterface);
    procedure  UpdateControls;
    function   Count: Integer;
    // Implementation of the IPSECManager
    procedure  SetControlSecurityCode(
                    var CurrentSecurityCode: String;
                    const NewSecurityCode: String;
                    aControl: IPSECControlInterface); virtual;
  published
    // Refernce to the SecureManager
    property   SecureManager: TPSECCustomBasicSecureManager read GetSecureManager write SetSecureManager;
  end;


function  GetPSECControlManager: TPSECControlManager;

procedure Register;


implementation
{$R PSECCommon.res}

{$ifdef debug_secure}
uses
  LazLogger;
{$endif}

ResourceString
  PSECSPalette = 'PascalSecure';


procedure Register;
begin
  RegisterComponents(PSECSPalette,[TPSECControlManager]);
end;


var
 ControlManager: TPSECControlManager;

function GetPSECControlManager: TPSECControlManager;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  // Simple singleton
  if ControlManager = nil then
    ControlManager:= TPSECControlManager.Create(nil);
  // Return the Manager for the Controls
  Result:= ControlManager;
end;

procedure SetControlSecurityCode(var CurrentSecurityCode: String;
  const NewSecurityCode: String; ControlSecurityIntf: IPSECControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  GetPSECControlManager.SetControlSecurityCode(CurrentSecurityCode, NewSecurityCode, ControlSecurityIntf);
end;

{ TPSECControlManager }

function TPSECControlManager.GetSecureManager: TPSECCustomBasicSecureManager;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= FSecureManager;
end;

procedure TPSECControlManager.SetSecureManager(AValue: TPSECCustomBasicSecureManager);
begin
  {$ifdef debug_secure}
    Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});
    Debugln('  Value:' +AValue.Name);
  {$endif}
  if FSecureManager = AValue then
    exit; // ==>>
  // Check if we have not an active Securemanager
  //// this should be avoided, to inhibt the user to drop two Securemanagers into the project
  //if (FSecureManager <> nil)
  //   and (AValue<>nil)
  //   and not(FSecureManager is TPSECBasicSecureManager) then
  //  raise Exception.Create('Only one SecureManager allowed (One is actual running and a new one is created)');
  // Clear the old manager an set the new one
  if FSecureManager <> nil then
    FreeAndNil(FSecureManager);
  FSecureManager:= AValue;
  // if the manger should be nil (=removed) we create the standardmanager
  if FSecureManager  = nil then
    FSecureManager:= TPSECBasicSecureManager.Create(nil);
  // Set the state of the controls according the new manager
  UpdateControls;
end;

constructor TPSECControlManager.Create(AOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited create(AOwner);
  FSecureManager := nil;
  FSecureControls:= TPSECControlsList.Create;
  FSecureManager:= nil; { TODO -oaf : No Securemanager } //TPSECBasicSecureManager.Create(nil);
end;

destructor TPSECControlManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FSecureControls);
  if FSecureManager <> nil then
    FreeAndNil(FSecureManager);
  inherited Destroy;
end;

procedure TPSECControlManager.RegisterControl(
  aControl: IPSECControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FSecureControls.IndexOf(aControl)=-1 then begin;
    FSecureControls.Add(aControl);
    { TODO -oaf : I set the default behavior to false - you can later change to the correct value if a usermanager is installed }
    aControl.CanBeAccessed(false);
    //aControl.CanBeAccessed(CanAccess(aControl.GetControlSecurityCode));
  end;
end;

procedure TPSECControlManager.UnRegisterControl(
  aControl: IPSECControlInterface);
var
  idx: LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  idx:= FSecureControls.IndexOf(aControl);
  if idx<>-1 then
    FSecureControls.Delete(idx);
end;

procedure TPSECControlManager.SetControlSecurityCode(
  var CurrentSecurityCode: String; const NewSecurityCode: String;
  aControl: IPSECControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if CurrentSecurityCode=NewSecurityCode then Exit;

  if Trim(NewSecurityCode)='' then
    aControl.MakeUnsecure // no securitycode mean -> make unsecure
  else
    begin
      If FSecureManager is IPSECManager then
        with FSecureManager as IPSECManager do begin
          { TODO -oaf : if it is clear where the manager resides i can work here }
          //ValidateSecurityCode(NewSecurityCode);
          //if not SecurityCodeExists(NewSecurityCode) then
          //  RegisterSecurityCode(NewSecurityCode);
          //
          //aControl.CanBeAccessed(CanAccess(NewSecurityCode));
        end;
    end;
  CurrentSecurityCode:= NewSecurityCode;

end;

procedure TPSECControlManager.UpdateControls;
var
  c:LongInt;
  aControl: IPSECControlInterface;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  for c:=0 to FSecureControls.Count-1 do begin
    aControl:=IPSECControlInterface(FSecureControls.Items[c]);
    { TODO -oaf : if it is clear where the manager resides i can work here }
//    aControl.CanBeAccessed(CanAccess(intf.GetControlSecurityCode));
  end;
end;

function TPSECControlManager.Count: Integer;
begin
  Result:= FSecureControls.Count;
end;

{ TPSECCustomBasicSecureManager }

//function TPSECCustomBasicSecureManager.GetControlSecurityManagerExt: TPSECControlManager;
//begin
//  Result:= GetPSECControlManager;
//end;
//
//function TPSECCustomBasicSecureManager.GetUserManagement: TBasicUserManagement;
//begin
//  Result:= FUserManagement;
//end;
//
//procedure TPSECCustomBasicSecureManager.SetUserManagement(aUserManagment: TBasicUserManagement);
//begin
//  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
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
//end;


initialization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  ControlManager:= nil;

finalization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if (ControlManager <> nil) then
    FreeAndNil(ControlManager);

end.

