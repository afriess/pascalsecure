unit MockSecureControl;
{$I PSECinclude.inc}
{ *************************
  Mock for the diffent secure controls used by PSEC
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
  Classes, SysUtils, Controls,
  security.manager.controls_manager,
  security.manager.SecureControlInterface;

type

  { TMockSecureControl }

  TMockSecureControl = class(TControl, ISecureControlInterface)
  { ***** FOR TESTING ONLY START ***** }
  public
    // Has the Object a mocked or normal ControlManager
    FTST_IsMockControlManager: Boolean;
    // If TSTControlManager is nil, normal operation is used
    class var TSTControlManager: TControlSecurityManager;
    // Set befor Create the Object !! To use the Mock, nil if normal operation
    Class procedure TSTSetControlManager(ControlManager: TControlSecurityManager);
    // Check the inherited Enabled Flag
    function TSTIsEnabledInherited:Boolean;
  { ***** FOR TESTING ONLY END ***** }
  private
    FSecurityCode: String;
    FIsEnabled,
    FIsEnabledBySecurity:Boolean;
    procedure SetSecurityCode(AValue: String); virtual;
  protected
    procedure SetEnabled(Value: Boolean); override;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
    // Implementation of the IPSECControlInterface
    function GetControlSecurityCode:String; virtual;
    procedure MakeUnsecure; virtual;
    procedure CanBeAccessed(a:Boolean); virtual;
    // Support
    property Enabled read FIsEnabled write SetEnabled default true;
    property SecurityCode:String read FSecurityCode write SetSecurityCode;
  end;


implementation


{ ***** FOR TESTING ONLY START ***** }
class procedure TMockSecureControl.TSTSetControlManager(
  ControlManager: TControlSecurityManager);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  TSTControlManager:= ControlManager; // TESTING ONLY
end;

function TMockSecureControl.TSTIsEnabledInherited: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= inherited Enabled;
end;

{ ***** FOR TESTING ONLY END ***** }


constructor TMockSecureControl.Create(TheOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(TheOwner);
  FIsEnabled:=true;
  FIsEnabledBySecurity:=true;
  FSecurityCode:='';
  if TSTControlManager = nil then begin
    // Normal Operation
   {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ':use normal Manager' +{$I %LINE%});{$endif}
   GetControlSecurityManager.RegisterControl(Self as ISecureControlInterface);
   FTST_IsMockControlManager:= False; // No Mock
  end
  else begin
    // Work with injected Manager
    {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ':use mocked Manager ' +{$I %LINE%});{$endif}
    TSTControlManager.RegisterControl(Self as ISecureControlInterface);
    FTST_IsMockControlManager:= True; // Is Mock
  end;
end;

destructor TMockSecureControl.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  TSTControlManager.UnRegisterControl(Self as ISecureControlInterface);
  inherited Destroy;
end;

procedure TMockSecureControl.SetSecurityCode(AValue: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FSecurityCode=AValue then
    Exit; // ==>>
  if Trim(AValue)='' then
    CanBeAccessed(true)
  else
    {TSTControlManager.}SetControlSecurityCode(FSecurityCode,AValue,(Self as ISecureControlInterface));
  FSecurityCode:=AValue;
end;

function TMockSecureControl.GetControlSecurityCode: String;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=FSecurityCode;
end;

procedure TMockSecureControl.MakeUnsecure;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FSecurityCode:='';
  CanBeAccessed(true);
end;

procedure TMockSecureControl.CanBeAccessed(a: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FIsEnabledBySecurity := a;
  SetEnabled(FIsEnabled);
end;

procedure TMockSecureControl.SetEnabled(Value: Boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FIsEnabled:=Value;
  inherited SetEnabled(FIsEnabled and FIsEnabledBySecurity);
end;

initialization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  TMockSecureControl.TSTSetControlManager(nil);

end.

