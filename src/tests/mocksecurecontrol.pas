unit MockSecureControl;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Controls,
  security.manager.controls_manager,
  security.manager.SecureControlInterface
  ;

type

  { TMockSecureControl }

  TMockSecureControl = class(TControl, ISecureControlInterface)
  public // For TESTING ONLY
     class var TSTControlSecurityManager: TControlSecurityManager;
  private
    FSecurityCode: String;
    FIsEnabled,
    FIsEnabledBySecurity:Boolean;
     procedure SetSecurityCode(AValue: String); virtual;
     procedure SetEnabled(Value: Boolean); override;
  public
     // ISecureControlInterface
     function GetControlSecurityCode:String; virtual;
     procedure MakeUnsecure; virtual;
     procedure CanBeAccessed(a:Boolean); virtual;
     // Support
     property Enabled read FIsEnabled write SetEnabled default true;
     property SecurityCode:String read FSecurityCode write SetSecurityCode;
  public
     constructor Create(TheOwner: TComponent); override;
     destructor Destroy; override;
     // For testing only -> Set befor Create the Object !!
     Class procedure SetTSTControlSecurityManager(ControlSecurityManager: TControlSecurityManager);
     function TSTIsEnabledInherited:Boolean;
  end;


implementation

constructor TMockSecureControl.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  FIsEnabled:=true;
  FIsEnabledBySecurity:=true;
  FSecurityCode:='';
  TSTControlSecurityManager.RegisterControl(Self as ISecureControlInterface);
end;

destructor TMockSecureControl.Destroy;
begin
  TSTControlSecurityManager.UnRegisterControl(Self as ISecureControlInterface);
  inherited Destroy;
end;

class procedure TMockSecureControl.SetTSTControlSecurityManager(
  ControlSecurityManager: TControlSecurityManager);
begin
  TSTControlSecurityManager:= ControlSecurityManager; // TESTING ONLY
end;

function TMockSecureControl.TSTIsEnabledInherited: Boolean;
begin
  Result:= inherited Enabled;
end;

procedure TMockSecureControl.SetSecurityCode(AValue: String);
begin
  SetControlSecurityCode(FSecurityCode,AValue,(Self as ISecureControlInterface));
end;

function TMockSecureControl.GetControlSecurityCode: String;
begin
  Result:=FSecurityCode;
end;

procedure TMockSecureControl.MakeUnsecure;
begin
  FSecurityCode:='';
  CanBeAccessed(true);
end;

procedure TMockSecureControl.CanBeAccessed(a: Boolean);
begin
  FIsEnabledBySecurity := a;
  SetEnabled(FIsEnabled);
end;

procedure TMockSecureControl.SetEnabled(Value: Boolean);
begin
  FIsEnabled:=Value;
  inherited SetEnabled(FIsEnabled and FIsEnabledBySecurity);
end;

initialization
  TMockSecureControl.SetTSTControlSecurityManager(nil);

end.

