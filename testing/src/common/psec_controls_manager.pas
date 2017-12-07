unit PSEC_controls_manager;

{$I PSECinclude.inc}

interface

uses
  Classes, SysUtils, fgl,
  PSECInterfaces;
  {security.manager.basic_user_management,}
  //security.manager.SecureControlInterface;

type

  TPSECControlsList = specialize TFPGList<ISecureControlInterface>;

  // forward
  TPSECCustomBasicSecureManager = class;
  TPSECBasicSecureManager = class;


  { TPSECControlSecurityManager } // Is a singleton, because we can only have one

  TPSECControlSecurityManager  = class(TObject)
  private
    function GetSecureManager: TPSECBasicSecureManager;
    procedure SetSecureManager(AValue: TPSECBasicSecureManager);
  protected
    FSecureControls:TPSECControlsList;
    FSecureManager: TPSECBasicSecureManager;
  public
    constructor Create;
    destructor Destroy; override;
    procedure  RegisterControl(aControl: ISecureControlInterface);
    procedure  UnRegisterControl(aControl: ISecureControlInterface);
    procedure  UpdateControls;
    function   Count: Integer;
    procedure  SetControlSecurityCode(
                    var CurrentSecurityCode: String;
                    const NewSecurityCode: String;
                    aControl: ISecureControlInterface); virtual;
    property   SecureManager: TPSECBasicSecureManager read GetSecureManager write SetSecureManager;
  end;

  { TPSECCustomBasicSecureManager }

  TPSECCustomBasicSecureManager = class(TComponent)
  public
    CSM : TPSECControlSecurityManager;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TPSECBasicSecureManager }
  TPSECBasicSecureManager = class(TPSECCustomBasicSecureManager)
  end;

  { TPSECCustomUserSecureManager }

  TPSECCustomUserSecureManager = class(TPSECBasicSecureManager, ISecureManager)
  protected
    FUserManagement:TBasicUserManagement;
  protected
    function GetUserManagement: TBasicUserManagement;
    procedure SetUserManagement(aUserManagment:TBasicUserManagement);
    procedure  SetControlSecurityCode(
                    var CurrentSecurityCode: String;
                    const NewSecurityCode: String;
                    aControl: ISecureControlInterface);
    property UserManagement:TBasicUserManagement read GetUserManagement write SetUserManagement;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
  end;

  TUserSecureManager = class(TPSECCustomUserSecureManager)
  published
    property   UserManagement;
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



function  GetPSECManager: TPSECControlSecurityManager;
{ TODO -oAndi : Should be replaced by GetControlSecuritymanager.SetControlSecurityCode in the components}
//procedure SetControlSecurityCode(var CurrentSecurityCode:String; const NewSecurityCode:String; ControlSecurityIntf:ISecureControlInterface);

implementation
{$ifdef debug_secure}
uses
  LazLogger;
{$endif}


var
 CSM: TPSECControlSecurityManager;

function GetPSECManager: TPSECControlSecurityManager;
begin
  Result:= CSM;
end;

procedure SetControlSecurityCode(var CurrentSecurityCode: String;
  const NewSecurityCode: String; ControlSecurityIntf: ISecureControlInterface);
begin
  GetPSECManager.SetControlSecurityCode(CurrentSecurityCode, NewSecurityCode, ControlSecurityIntf);
end;

{ TPSECCustomUserSecureManager }

function TPSECCustomUserSecureManager.GetUserManagement: TBasicUserManagement;
begin
  Result:= FUserManagement;
end;

procedure TPSECCustomUserSecureManager.SetUserManagement(
  aUserManagment: TBasicUserManagement);
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

procedure TPSECCustomUserSecureManager.SetControlSecurityCode(
  var CurrentSecurityCode: String; const NewSecurityCode: String;
  aControl: ISecureControlInterface);
begin

end;

constructor TPSECCustomUserSecureManager.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
end;

destructor TPSECCustomUserSecureManager.Destroy;
begin
  inherited Destroy;
end;

{ TPSECControlSecurityManager }

function TPSECControlSecurityManager.GetSecureManager: TPSECBasicSecureManager;
begin
  Result:= FSecureManager;
end;

procedure TPSECControlSecurityManager.SetSecureManager(AValue: TPSECBasicSecureManager);
begin
  if FSecureManager = AValue then
    exit; // ==>>
  // Clear the old manager an set the new one
  if FSecureManager <> nil then
    FreeAndNil(FSecureManager);
  FSecureManager:= AValue;
  // Set the state of the controls according the new manager
  UpdateControls;
end;

constructor TPSECControlSecurityManager.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited create;
  FSecureControls:= TFPGSecureControlsList.Create;
  FSecureManager:= TPSECBasicSecureManager.Create(nil);
  FSecureManager.CSM:= self;
end;

destructor TPSECControlSecurityManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FSecureControls);
  if FSecureManager <> nil then
    FreeAndNil(FSecureManager);
  inherited Destroy;
end;

procedure TPSECControlSecurityManager.RegisterControl(
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

procedure TPSECControlSecurityManager.UnRegisterControl(
  aControl: ISecureControlInterface);
var
  idx: LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  idx:= FSecureControls.IndexOf(aControl);
  if idx<>-1 then
    FSecureControls.Delete(idx);
end;

procedure TPSECControlSecurityManager.SetControlSecurityCode(
  var CurrentSecurityCode: String; const NewSecurityCode: String;
  aControl: ISecureControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if CurrentSecurityCode=NewSecurityCode then Exit;

  if Trim(NewSecurityCode)='' then
    aControl.MakeUnsecure // no securitycode mean -> make unsecure
  else
    begin
      If FSecureManager is ISecureManager then
        with FSecureManager as ISecureManager do begin
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

procedure TPSECControlSecurityManager.UpdateControls;
var
  c:LongInt;
  aControl: ISecureControlInterface;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  for c:=0 to FSecureControls.Count-1 do begin
    aControl:=ISecureControlInterface(FSecureControls.Items[c]);
    { TODO -oaf : if it is clear where the manager resides i can work here }
//    aControl.CanBeAccessed(CanAccess(intf.GetControlSecurityCode));
  end;
end;

function TPSECControlSecurityManager.Count: Integer;
begin
  Result:= FSecureControls.Count;
end;

{ TPSECCustomBasicSecureManager }

//function TPSECCustomBasicSecureManager.GetControlSecurityManagerExt: TPSECControlSecurityManager;
//begin
//  Result:= GetPSECManager;
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

constructor TPSECCustomBasicSecureManager.Create(AOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(AOwner);
end;

destructor TPSECCustomBasicSecureManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
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
//procedure TPSECCustomBasicSecureManager.RegisterControl(aControl: ISecureControlInterface);
//begin
//
//end;

//procedure TPSECCustomBasicSecureManager.UnRegisterControl(aControl: ISecureControlInterface);
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
  CSM:= TPSECControlSecurityManager.create;

finalization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if (CSM <> nil) then
    FreeAndNil(CSM);

end.

