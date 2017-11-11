unit security.manager.controls_manager;

{$I security.include.inc}

interface

uses
  Classes, SysUtils, fgl,
  security.manager.basic_user_management,
  security.manager.SecureControlInterface;

type

  TFPGSecureControlsList = specialize TFPGList<ISecureControlInterface>;

  { TControlSecurityManager } // Is a singleton, because we can only have one

  TControlSecurityManager  = class(TComponent)
  protected
    FSecureControls:TFPGSecureControlsList;
  public
    constructor create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure  RegisterControl(aControl: ISecureControlInterface);
    procedure  UnRegisterControl(aControl: ISecureControlInterface);
    procedure  SetControlSecurityCode(
                    var CurrentSecurityCode: String;
                    const NewSecurityCode: String;
                    ControlSecurityIntf:ISecureControlInterface);
    procedure  UpdateControls;
    function   Count: Integer;
  end;

  { TSecureManager }

  TSecureManager = class(TComponent)
  protected
    FUserManagement:TBasicUserManagement;
  protected
    function GetControlSecurityManagerExt: TControlSecurityManager;
    function GetUserManagement: TBasicUserManagement;
    procedure SetUserManagement(aUserManagment:TBasicUserManagement);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    //function   Login(Userlogin, Userpassword: String; var UID: Integer):Boolean; overload;
    //function   Login:Boolean;
    //
    //procedure  Logout;
    //procedure  Manage;
    //function   GetCurrentUserlogin:String;
    //function   HasUserLoggedIn:Boolean;
    //procedure  TryAccess(sc:String);
    //procedure RegisterControl(aControl: ISecureControlInterface);
    //procedure UnRegisterControl(aControl: ISecureControlInterface);
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
  published
    property   UserManagement:TBasicUserManagement read GetUserManagement write SetUserManagement;
    property   ControlSecurityManager: TControlSecurityManager read GetControlSecurityManagerExt;
  end;


function  GetControlSecurityManager: TControlSecurityManager;
{ TODO -oAndi : Should be replaced by GetControlSecuritymanager.SetControlSecurityCode in the components}
procedure SetControlSecurityCode(var CurrentSecurityCode:String; const NewSecurityCode:String; ControlSecurityIntf:ISecureControlInterface);

implementation
{$ifdef debug_secure}
uses
  LazLogger;
{$endif}


var
 CSM: TControlSecurityManager;

function GetControlSecurityManager: TControlSecurityManager;
begin
  Result:= CSM;
end;

procedure SetControlSecurityCode(var CurrentSecurityCode: String;
  const NewSecurityCode: String; ControlSecurityIntf: ISecureControlInterface);
begin
  GetControlSecurityManager.SetControlSecurityCode(CurrentSecurityCode, NewSecurityCode, ControlSecurityIntf);
end;

{ TControlSecurityManager }

constructor TControlSecurityManager.create(AOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited create(AOwner);
  FSecureControls:=TFPGSecureControlsList.Create;
end;

destructor TControlSecurityManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FSecureControls);
  inherited Destroy;
end;

procedure TControlSecurityManager.RegisterControl(
  aControl: ISecureControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FSecureControls.IndexOf(aControl)=-1 then begin;
    FSecureControls.Add(aControl);
    { TODO -oaf : I set the default behavior to false - you can later change to the correct value if a usermanager is installed }
    aControl.CanBeAccessed(false);
    //aControl.CanBeAccessed(CanAccess(aControl.GetControlSecurityCode));
  end;
end;

procedure TControlSecurityManager.UnRegisterControl(
  aControl: ISecureControlInterface);
var
  idx: LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  idx:= FSecureControls.IndexOf(aControl);
  if idx<>-1 then
    FSecureControls.Delete(idx);
end;

procedure TControlSecurityManager.SetControlSecurityCode(
  var CurrentSecurityCode: String; const NewSecurityCode: String;
  ControlSecurityIntf: ISecureControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if CurrentSecurityCode=NewSecurityCode then Exit;

  if Trim(NewSecurityCode)='' then
    ControlSecurityIntf.MakeUnsecure; // no securitycode mean -> make unsecure
  else
    with GetControlSecurityManager do begin
      ValidateSecurityCode(NewSecurityCode);
      if not SecurityCodeExists(NewSecurityCode) then
        RegisterSecurityCode(NewSecurityCode);

      ControlSecurityIntf.CanBeAccessed(CanAccess(NewSecurityCode));
    end;

  CurrentSecurityCode:=NewSecurityCode;

end;

procedure TControlSecurityManager.UpdateControls;
var
  c:LongInt;
  intf: ISecureControlInterface;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  for c:=0 to FSecureControls.Count-1 do begin
    intf:=ISecureControlInterface(FSecureControls.Items[c]);
    intf.CanBeAccessed(CanAccess(intf.GetControlSecurityCode));
  end;
end;

function TControlSecurityManager.Count: Integer;
begin
  Result:= FSecureControls.Count;
end;

{ TSecureManager }

function TSecureManager.GetControlSecurityManagerExt: TControlSecurityManager;
begin
  Result:= GetControlSecurityManager;
end;

function TSecureManager.GetUserManagement: TBasicUserManagement;
begin
  Result:= FUserManagement;
end;

procedure TSecureManager.SetUserManagement(aUserManagment: TBasicUserManagement);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  //if (aUserManagment<>nil) and (not (aUserManagment is TBasicUserManagement)) then
  //  raise EInvalidUserManagementComponent.Create;
  //
  //{ TODO -oAndi : why check we this ? }
  ////if (um<>nil) and (FUserManagement<>nil) then
  ////  raise EUserManagementIsSet.Create;
  //
  FUserManagement:=aUserManagment;
  UpdateControls;
end;

constructor TSecureManager.Create(AOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(AOwner);
  // Usermanagment should be nil, because nobody knows what kind of uermangement we need
  FUserManagement:=nil;
  //FSecureControls:=TFPGSecureControlsList.Create;
end;

destructor TSecureManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  //if FSecureControls.Count>0 then
  //  raise EControlSecurityManagerStillBeingUsed.Create;
  //FreeAndNil(FSecureControls);
  inherited Destroy;
end;

procedure TSecureManager.UpdateControls;
begin

end;

//procedure TSecureManager.RegisterControl(aControl: ISecureControlInterface);
//begin
//
//end;

//procedure TSecureManager.UnRegisterControl(aControl: ISecureControlInterface);
//begin
//  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
//end;

//procedure TLevelManager.UpdateControls;
//var
//  c:LongInt;
//  intf: ISecureControlInterface;
//begin
//  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
//  for c:=0 to FSecureControls.Count-1 do begin
//    intf:=ISecureControlInterface(FSecureControls.Items[c]);
//    intf.CanBeAccessed(CanAccess(intf.GetControlSecurityCode));
//  end;
//end;

initialization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  CSM:= TControlSecurityManager.create(nil);

finalization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if (CSM <> nil) then
    FreeAndNil(CSM);

end.

