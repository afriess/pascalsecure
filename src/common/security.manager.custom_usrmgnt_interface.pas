unit security.manager.custom_usrmgnt_interface;

{$I security.include.inc}

interface

uses
  Classes, SysUtils,
  security.manager.schema;


type

  ICustomUsrMgntIntf = interface
    ['{87026E86-430F-4C20-9C16-146B81906900}']
     //: Return the user management type.
     function  UsrMgntType:TUsrMgntType;
     //: Return the user management schema (all users, groups and authorizations, if availables).
     function  GetUserSchema:TUsrMgntSchema;
     {: Updates some user detais, like description, user disabled,
     user level access and authorizations.}
     function  UpdateUserDetails(const aUser:TCustomUser):Boolean;
     //: Changes the user Password. Should be used in user administration interfaces.
     function  ChangeUserPassword(const aUser:TCustomUser; const aPasswd:UTF8String):Boolean;
     //: Changes password of current user.
     function  ChangeCurrentUserPassword(const CurrentPass, NewPass:UTF8String):Boolean;
  end;


{$ifdef UseLevelSchema}

  IUsrLevelMgntIntf = interface(ICustomUsrMgntIntf)
    ['{38D383C4-E162-4CF3-98A3-8EF4141AD681}']
    ////: Return the user management type.
    //function  UsrMgntType:TUsrMgntType;
    ////: Return the user management schema (all users, groups and authorizations, if availables).
    //function  GetUserSchema:TUsrMgntSchema;
    //
    //
    //{:
    //Updates some user detais, like description, user disabled,
    //user level access and authorizations.
    //}
    //function  UpdateUserDetails(const aUser:TCustomUser):Boolean;
    //
    ////: Changes the user Password. Should be used in user administration interfaces.
    //function  ChangeUserPassword(const aUser:TCustomUser; const aPasswd:UTF8String):Boolean;
    //
    ////: Changes password of current user.
    //function  ChangeCurrentUserPassword(const CurrentPass, NewPass:UTF8String):Boolean;
  end;
{$endif UseLevelSchema}

{$ifdef UseAuthSchema}

  IUsrAuthMgntIntf = interface(ICustomUsrMgntIntf)
    ['{38D383C4-E162-4CF3-98A3-8EF4141AD681}']
    //: Return the user management type.
    function  UsrMgntType:TUsrMgntType;
    //: Return the user management schema (all users, groups and authorizations, if availables).
    function  GetUserSchema:TUsrMgntSchema;


    {:
    Updates some user detais, like description, user disabled,
    user level access and authorizations.
    }
    function  UpdateUserDetails(const aUser:TCustomUser):Boolean;

    function  AddUserInGroup(const aUser:TCustomUser; const aGroup:TCustomGroup):Boolean;

    //: Changes the user Password. Should be used in user administration interfaces.
    function  ChangeUserPassword(const aUser:TCustomUser; const aPasswd:UTF8String):Boolean;

    //: Changes password of current user.
    function  ChangeCurrentUserPassword(const CurrentPass, NewPass:UTF8String):Boolean;
  end;
{$endif UseAuthSchema}


  { TODO -oAndi : This is not an interface !! }
  TCustomUsrMgntInterface = class(TComponent)
  public
    function  Login(out aLogin, aPass:UTF8String):Boolean; virtual; abstract;
    function  Login:Boolean; virtual; abstract;
    function  CanLogout:Boolean; virtual;
    procedure UserManagement(aSchema:TUsrMgntSchema); virtual; abstract;
    procedure FreezeUserLogin; virtual;
    procedure UnfreezeUserLogin; virtual;
    procedure ProcessMessages; virtual;
    function  LoginVisibleBetweenRetries:Boolean; virtual;
  end;

implementation

{$ifdef debug_secure}
uses
  LazLogger;
{$endif}

function TCustomUsrMgntInterface.CanLogout: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=True;
end;

procedure TCustomUsrMgntInterface.FreezeUserLogin;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}

end;

procedure TCustomUsrMgntInterface.UnfreezeUserLogin;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}

end;

procedure TCustomUsrMgntInterface.ProcessMessages;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}

end;

function TCustomUsrMgntInterface.LoginVisibleBetweenRetries: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=false;
end;

end.

