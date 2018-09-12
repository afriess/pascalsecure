unit PSECSecureAuthManager;
{$I PSECinclude.inc}

interface

uses
  Classes, SysUtils,
  PSECSecureManager, PSECUserSchema, PSECInterfaces,PSECAuthUserManager;
type
{ TPSECCustomAuthSecureManager
 Implements a user management Manager that uses authorizations to allow/deny access,
 where each user inherits the authorizations assigned to the group which it
 belongs. On this model, users CAN NOT HAVE SPECIFIC PERMISSIONS.

 This schema consists in:
 ** A list of simple users.
 ** A list of groups, where each group has a list of allowed authorizations,
    where the users of each group will inherit the authorizations assigned to
    the group.
 ** A list with all authorizations available on the security manager.
 }
 TPSECCustomAuthSecureManager = class(TPSECCustomBasicSecureManager,IPSECBasicSecurity{, IPSECManager})
 private
   FLogedinUser : integer;
   FUserIsLogedin : boolean;
   function GetUserAuthSchema: TPSECAuthUserManager;
   procedure SetUserAuthSchema(AValue: TPSECAuthUserManager);
 protected
   FUserAuthSchema:TPSECAuthUserManager;
   //FUserManagement:IUsrAuthMgntInterface;
 protected
   //function GetUserManagement: IUsrAuthMgntInterface;
   //procedure SetUserManagement(aUserManagment:IUsrAuthMgntInterface);
   //property UserManagement:IUsrAuthMgntInterface read GetUserManagement write SetUserManagement;
   property UserAuthSchema:TPSECAuthUserManager read GetUserAuthSchema write SetUserAuthSchema;

 public
   constructor Create(AOwner: TComponent); override;
   destructor Destroy; override;
   // Basic Security functions
   function GetCurrentUserlogin: String;
   function IsUserLoggedIn: Boolean;
   function Login(Userlogin, Userpassword: String; var UID: Integer): Boolean;
   procedure Logout;
 end;

 TPSECAuthSecureManager = class(TPSECCustomAuthSecureManager)
 public
   property UserAuthSchema;
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
  RegisterComponents(PSECSPalette,[TPSECAuthSecureManager]);
end;

{ TPSECCustomAuthSecureManager }

function TPSECCustomAuthSecureManager.GetUserAuthSchema: TPSECAuthUserManager;
begin
  Result := FUserAuthSchema;
end;

procedure TPSECCustomAuthSecureManager.SetUserAuthSchema(
  AValue: TPSECAuthUserManager);
begin
  if FUserAuthSchema=AValue then Exit;
  FUserAuthSchema:=AValue;
end;

//function TPSECCustomAuthSecureManager.GetUserManagement: IUsrAuthMgntInterface;
//begin
// Result:= FUserManagement;
//end;
//
//procedure TPSECCustomAuthSecureManager.SetUserManagement(
//  aUserManagment: IUsrAuthMgntInterface);
//begin
// {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
// if aUserManagment = FUserManagement then
//   exit; // ==>>
// if (aUserManagment = nil) then
//   pointer(FUserManagement) := nil  // clear the link without call _Release !!
// else
//   FUserManagement:= aUserManagment;
//end;



constructor TPSECCustomAuthSecureManager.Create(AOwner: TComponent);
begin
 {$ifdef debug_secure}
   Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});
   if assigned(AOwner) then
     Debugln('  owner:'+AOwner.Name);
 {$endif}
 Inherited Create(AOwner);
 FUserAuthSchema := TPSECAuthUserManager.Create;
end;

destructor TPSECCustomAuthSecureManager.Destroy;
begin
 {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
 //if FUserAuthSchema <> nil then
 //  FUserAuthSchema.Free;
 //pointer(FUserManagement) := nil;  // clear the link without call _Release !!
 inherited Destroy;
end;

function TPSECCustomAuthSecureManager.GetCurrentUserlogin: String;
begin
 Result := FUserAuthSchema.GetUserName(FLogedinUser);
end;

function TPSECCustomAuthSecureManager.IsUserLoggedIn: Boolean;
begin
  Result := FUserIsLogedin;
end;

function TPSECCustomAuthSecureManager.Login(Userlogin, Userpassword: String;
  var UID: Integer): Boolean;
begin
  UID:=-1;
  Result := false;
  if FUserAuthSchema.CanUserLogin(Userlogin,Userpassword, UID) then begin
    FLogedinUser := UID ;
    FUserIsLogedin := true;
    Result := true;
    { TODO -oAndi : Send message to components }
  end;
end;

procedure TPSECCustomAuthSecureManager.Logout;
begin
  FLogedinUser := -1 ;
  FUserIsLogedin := false;
  { TODO -oAndi : Send message to components }
end;


end.

