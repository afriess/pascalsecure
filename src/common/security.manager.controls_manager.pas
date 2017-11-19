unit security.manager.controls_manager;

{$I security.include.inc}

interface

uses
  Classes, SysUtils, fgl,
  {security.manager.basic_user_management,}
  security.manager.SecureControlInterface;

type

  TFPGSecureControlsList = specialize TFPGList<ISecureControlInterface>;

  // forward
  TCustomBasicSecureManager = class;
  TBasicSecureManager = class;


  { TControlSecurityManager } // Is a singleton, because we can only have one

  TControlSecurityManager  = class(TObject)
  private
    function GetSecureManager: TBasicSecureManager;
    procedure SetSecureManager(AValue: TBasicSecureManager);
  protected
    FSecureControls:TFPGSecureControlsList;
    FSecureManager: TBasicSecureManager;
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
    property   SecureManager: TBasicSecureManager read GetSecureManager write SetSecureManager;
  end;

  { TCustomBasicSecureManager }

  TCustomBasicSecureManager = class(TComponent)
  public
    CSM : TControlSecurityManager;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TBasicSecureManager }
  TBasicSecureManager = class(TCustomBasicSecureManager)
  end;

  { TCustomUserSecureManager }

  TCustomUserSecureManager = class(TBasicSecureManager, ISecureManager)
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

  TUserSecureManager = class(TCustomUserSecureManager)
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



function  GetControlSecurityManager: TControlSecurityManager;
{ TODO -oAndi : Should be replaced by GetControlSecuritymanager.SetControlSecurityCode in the components}
//procedure SetControlSecurityCode(var CurrentSecurityCode:String; const NewSecurityCode:String; ControlSecurityIntf:ISecureControlInterface);

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

{ TCustomUserSecureManager }

function TCustomUserSecureManager.GetUserManagement: TBasicUserManagement;
begin
  Result:= FUserManagement;
end;

procedure TCustomUserSecureManager.SetUserManagement(
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

procedure TCustomUserSecureManager.SetControlSecurityCode(
  var CurrentSecurityCode: String; const NewSecurityCode: String;
  aControl: ISecureControlInterface);
begin

end;

constructor TCustomUserSecureManager.Create(AOwner: TComponent);
begin
  Inherited Create(AOwner);
end;

destructor TCustomUserSecureManager.Destroy;
begin
  inherited Destroy;
end;

{ TControlSecurityManager }

function TControlSecurityManager.GetSecureManager: TBasicSecureManager;
begin
  Result:= FSecureManager;
end;

procedure TControlSecurityManager.SetSecureManager(AValue: TBasicSecureManager);
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

constructor TControlSecurityManager.Create;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited create;
  FSecureControls:= TFPGSecureControlsList.Create;
  FSecureManager:= TBasicSecureManager.Create(nil);
  FSecureManager.CSM:= self;
end;

destructor TControlSecurityManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(FSecureControls);
  if FSecureManager <> nil then
    FreeAndNil(FSecureManager);
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

procedure TControlSecurityManager.UpdateControls;
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

function TControlSecurityManager.Count: Integer;
begin
  Result:= FSecureControls.Count;
end;

{ TCustomBasicSecureManager }

//function TCustomBasicSecureManager.GetControlSecurityManagerExt: TControlSecurityManager;
//begin
//  Result:= GetControlSecurityManager;
//end;
//
//function TCustomBasicSecureManager.GetUserManagement: TBasicUserManagement;
//begin
//  Result:= FUserManagement;
//end;
//
//procedure TCustomBasicSecureManager.SetUserManagement(aUserManagment: TBasicUserManagement);
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

constructor TCustomBasicSecureManager.Create(AOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(AOwner);
end;

destructor TCustomBasicSecureManager.Destroy;
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


//procedure TCustomBasicSecureManager.UpdateControls;
//begin
//
//end;
//
//procedure TCustomBasicSecureManager.RegisterControl(aControl: ISecureControlInterface);
//begin
//
//end;

//procedure TCustomBasicSecureManager.UnRegisterControl(aControl: ISecureControlInterface);
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
  CSM:= TControlSecurityManager.create;

finalization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if (CSM <> nil) then
    FreeAndNil(CSM);

end.

