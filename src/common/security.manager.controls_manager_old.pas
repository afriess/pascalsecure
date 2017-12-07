unit security.manager.controls_manager_old;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl,
  security.manager.basic_user_management,
  security.manager.SecureControlInterface;

type

  TFPGSecureControlsList = specialize TFPGList<ISecureControlInterface>;

  { TControlSecurityManager }

  TControlSecurityManager = class(TComponent)
  private
    FSecureControls:TFPGSecureControlsList;
  protected
    FUserManagement:TBasicUserManagement;
  protected
    procedure SetUserManagement(um:TBasicUserManagement);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function   Login(Userlogin, Userpassword: String; var UID: Integer):Boolean; overload;
    function   Login:Boolean;

    procedure  Logout;
    procedure  Manage;
    function   GetCurrentUserlogin:String;
    function   HasUserLoggedIn:Boolean;
    procedure  TryAccess(sc:String);
    procedure  RegisterControl(control:ISecureControlInterface);
    procedure  UnRegisterControl(control:ISecureControlInterface);
    function   RegisterControlCount:integer;
    procedure  UpdateControls;
    // if the SecurityContext is empty, per deault access is allowed
    //   the Result is only realy checked if a context is given
    function   CanAccess(sc:String):Boolean;
    procedure  ValidateSecurityCode(sc:String);
    procedure  RegisterSecurityCode(sc:String);
    procedure  UnregisterSecurityCode(sc:String);
    function   SecurityCodeExists(sc:String):Boolean;
    function   GetRegisteredAccessCodes:TFPGStringList;
    function   CheckIfUserIsAllowed(sc:String; RequireUserLogin:Boolean; var userlogin:String):Boolean;
  published
    property   UserManagement:TBasicUserManagement read FUserManagement write SetUserManagement;
  end;

  function GetControlSecurityManager:TControlSecurityManager;
  procedure SetControlSecurityCode(var CurrentSecurityCode:String; const NewSecurityCode:String; ControlSecurityIntf:ISecureControlInterface);

implementation

uses
  {$ifdef debug_secure}
  LazLogger,
  {$endif}
  security.exceptions;

constructor TControlSecurityManager.Create(AOwner: TComponent);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Create(AOwner);
  // Usermanagment should be nil, because nobody knows what kind of uermangement we need
  FUserManagement:=nil;
  FSecureControls:=TFPGSecureControlsList.Create;
end;

destructor TControlSecurityManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FSecureControls.Count>0 then
    raise EControlSecurityManagerStillBeingUsed.Create;
  FreeAndNil(FSecureControls);
  inherited Destroy;
end;

function TControlSecurityManager.Login(Userlogin, Userpassword: String; var UID:Integer): Boolean; overload;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    Result:=TBasicUserManagement(FUserManagement).Login(Userlogin,Userpassword,UID)
  else
    Result:=false;
end;

function   TControlSecurityManager.Login:Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    Result:=TBasicUserManagement(FUserManagement).Login
  else
    Result:=false;
end;

procedure  TControlSecurityManager.Logout;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    TBasicUserManagement(FUserManagement).Logout
end;

procedure  TControlSecurityManager.Manage;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    TBasicUserManagement(FUserManagement).Manage;
end;

function TControlSecurityManager.GetCurrentUserlogin: String;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:='';
  if FUserManagement<>nil then
    Result:=TBasicUserManagement(FUserManagement).CurrentUserLogin;
end;

function TControlSecurityManager.HasUserLoggedIn: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if FUserManagement<>nil then
    Result:=TBasicUserManagement(FUserManagement).UserLogged;
end;

procedure  TControlSecurityManager.TryAccess(sc:String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    if not TBasicUserManagement(FUserManagement).CanAccess(sc) then
      raise ESecuritySystemAccessDenied.Create(sc);
end;

procedure TControlSecurityManager.SetUserManagement(um: TBasicUserManagement);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if (um<>nil) and (not (um is TBasicUserManagement)) then
    raise EInvalidUserManagementComponent.Create;

  { TODO -oAndi : why check we this ? }
  //if (um<>nil) and (FUserManagement<>nil) then
  //  raise EUserManagementIsSet.Create;

  FUserManagement:=um;
  UpdateControls;
end;

procedure  TControlSecurityManager.RegisterControl(control:ISecureControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FSecureControls.IndexOf(control)=-1 then begin;
    FSecureControls.Add(control);
    control.CanBeAccessed(CanAccess(control.GetControlSecurityCode));
  end;
end;

procedure  TControlSecurityManager.UnRegisterControl(control:ISecureControlInterface);
var
  idx:LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  idx:=FSecureControls.IndexOf(control);
  if idx<>-1 then
    FSecureControls.Delete(idx);
end;

function TControlSecurityManager.RegisterControlCount: integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:= FSecureControls.Count;
end;

procedure  TControlSecurityManager.UpdateControls;
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

function   TControlSecurityManager.CanAccess(sc:String):Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  { TODO -oFabio : what is the expected behavior ?}
  Result:=false;
  if sc='' then begin
    Result:=true;
    exit;
  end;
  if (FUserManagement<>nil) and (FUserManagement is TBasicUserManagement) then
    Result:=TBasicUserManagement(FUserManagement).CanAccess(sc);
end;

procedure  TControlSecurityManager.ValidateSecurityCode(sc:String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    TBasicUserManagement(FUserManagement).ValidateSecurityCode(sc);
end;

procedure  TControlSecurityManager.RegisterSecurityCode(sc:String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement<>nil then
    TBasicUserManagement(FUserManagement).RegisterSecurityCode(sc);
end;

procedure  TControlSecurityManager.UnregisterSecurityCode(sc:String);
var
  being_used:Boolean;
  c:LongInt;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  being_used:=false;
  for c:=0 to FSecureControls.Count-1 do
    being_used:=being_used or (ISecureControlInterface(FSecureControls.Items[c]).GetControlSecurityCode=sc);

  if being_used then
    raise ESecurityCodeIsInUseYet.Create;

  if FUserManagement<>nil then
    TBasicUserManagement(FUserManagement).UnregisterSecurityCode(sc);
end;

function   TControlSecurityManager.SecurityCodeExists(sc:String):Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if FUserManagement<>nil then
    Result:=TBasicUserManagement(FUserManagement).SecurityCodeExists(sc);
end;

function TControlSecurityManager.GetRegisteredAccessCodes: TFPGStringList;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if FUserManagement=nil then begin
    Result:=TFPGStringList.Create
  end else
    Result:=TBasicUserManagement(FUserManagement).GetRegisteredAccessCodes;
end;

function TControlSecurityManager.CheckIfUserIsAllowed(sc: String;
  RequireUserLogin: Boolean; var userlogin: String): Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
  if FUserManagement<>nil then
    Result:=TBasicUserManagement(FUserManagement).CheckIfUserIsAllowed(sc, RequireUserLogin, userlogin);
end;

var
  QControlSecurityManager:TControlSecurityManager;

function GetControlSecurityManager: TControlSecurityManager;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=QControlSecurityManager;
end;

procedure SetControlSecurityCode(var CurrentSecurityCode: String;
  const NewSecurityCode: String; ControlSecurityIntf: ISecureControlInterface);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if CurrentSecurityCode=NewSecurityCode then Exit;

  if Trim(NewSecurityCode)='' then
    ControlSecurityIntf.CanBeAccessed(true)
  else
    with GetControlSecurityManager do begin
      ValidateSecurityCode(NewSecurityCode);
      if not SecurityCodeExists(NewSecurityCode) then
        RegisterSecurityCode(NewSecurityCode);

      ControlSecurityIntf.CanBeAccessed(CanAccess(NewSecurityCode));
    end;

  CurrentSecurityCode:=NewSecurityCode;
end;

initialization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  QControlSecurityManager:=TControlSecurityManager.Create(nil);
finalization
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FreeAndNil(QControlSecurityManager);

end.

