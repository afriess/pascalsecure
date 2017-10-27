unit security.manager.graphical_user_management;

{$I security.include.inc}

interface

uses
  ButtonPanel,
  Classes,
  Controls,
  ExtCtrls,
  Forms,
  StdCtrls, ComCtrls,
  sysutils, math, strutils,
  security.manager.schema,
  security.exceptions,
  security.manager.custom_usrmgnt_interface,
  security.manager.basic_user_management,
  security.manager.level.mgntdlg;

type

  TSecureFocusedControl = (fcUserName, fcPassword);

  { TCustomFrmLogin }

  TSecureCustomFrmLogin = Class(TCustomForm)
  private
    FFocusedControl: TSecureFocusedControl;
    FOnCancelClick: TNotifyEvent;
    FOnOKClick: TNotifyEvent;
    function GetUserLogin: String; virtual; abstract;
    function GetUserPassword: String; virtual; abstract;
    procedure SetFocusedControl(AValue: TSecureFocusedControl); virtual; abstract;
    procedure SetUserLogin(AValue: String); virtual; abstract;
    procedure SetUserPassword(AValue: String); virtual; abstract;
  public
    procedure DisableEntry; virtual; abstract;
    procedure EnableEntry; virtual; abstract;
    property FocusedControl:TSecureFocusedControl read FFocusedControl write SetFocusedControl;
    property UserLogin:String read GetUserLogin write SetUserLogin;
    property UserPassword:String read GetUserPassword write SetUserPassword;
    property OnOKClick:TNotifyEvent read FOnOKClick write FOnOKClick;
    property OnCancelClick:TNotifyEvent read FOnCancelClick write FOnCancelClick;
  end;

  TSecureCustomFrmLoginClass = class of TSecureCustomFrmLogin;

  { TFrmLogin }

  TSecureFrmLogin = Class(TSecureCustomFrmLogin)
  private
    lblLogin,
    lblPassword:TLabel;
    edtLogin,
    edtPassword:TEdit;
    btnButtons:TButtonPanel;
    procedure CancelClicked(Sender: TObject);
    function GetUserLogin: String; override;
    function GetUserPassword: String; override;
    procedure OKClicked(Sender: TObject);
    procedure SetUserLogin(AValue: String); override;
    procedure SetUserPassword(AValue: String); override;
    procedure SetFocusedControl(AValue: TSecureFocusedControl); override;
    procedure DoShow; override;
  public
    constructor CreateNew(AOwner: TComponent; Num: Integer=0); override;
    procedure DisableEntry; override;
    procedure EnableEntry; override;
    property FocusedControl:TSecureFocusedControl read FFocusedControl write FFocusedControl;
    property UserLogin:String read GetUserLogin write SetUserLogin;
    property UserPassword:String read GetUserPassword write SetUserPassword;
  end;

  { TGraphicalUsrMgntInterface }

  TGraphicalUsrMgntInterface = class(TCustomUsrMgntInterface)
  private
    procedure LevelAddUserClick(Sender: TObject);
    procedure LevelBlockUserClick(Sender: TObject;
      const aUser: TUserWithLevelAccess);
    procedure LevelChangeUserClick(Sender: TObject;
      const aUser: TUserWithLevelAccess);
    procedure LevelChangeUserPassClick(Sender: TObject;
      const aUser: TUserWithLevelAccess);
    procedure LevelDeleteUser(Sender: TObject; var aUser: TUserWithLevelAccess
      );
    procedure LevelValidateAddUser(Sender: TObject);
    procedure LevelRefreshUserList;
  protected
    frmLogin:TSecureCustomFrmLogin;
    lvlfrm:TsecureUsrLvlMgnt;
    FCanCloseLogin:Boolean;
    FCurrentUserSchema:TUsrMgntSchema;
    procedure CanCloseLogin(Sender: TObject; var CanClose: boolean);
    procedure CancelClick(Sender: TObject);
    procedure OKClick(Sender: TObject);
    function  GetLoginClass:TSecureCustomFrmLoginClass; virtual;
  public
    function  Login(out aLogin, aPass:UTF8String):Boolean; override;
    function  Login:Boolean; override;
    function  CanLogout:Boolean; override;
    procedure UserManagement(aSchema:TUsrMgntSchema); override;
    procedure FreezeUserLogin; override;
    procedure UnfreezeUserLogin; override;
    procedure ProcessMessages; override;
    function  LoginVisibleBetweenRetries:Boolean; override;
  end;

  EInvalidUserDataException = class(ESecurityException)
  public
    constructor Create;
  end;

  EPasswordsDontMatch = class(ESecurityException)
  public
    constructor Create;
  end;

ResourceString
  strFrmLoginCaption     = 'PascalSecure Login';
  strUserLogin           = '&Login';
  strUserPass            = '&Password';
  SSpecialLoginCaption   = 'Enter a user that can access the "%s" token.';
  strYes                 = 'Yes';
  strNo                  = 'No';
  strInvalidDataSupplied = 'Invalid user data';
  strPasswordsDontMatch  = 'Supplied passwords don''t math!';
  strDeleteUser          = 'User removal';
  strConfirmDeleteUser   = 'Confirm the complete removal of user "%s"?';
  strYesDeleteTheUser    = 'Yes, delete user "%s"';
  strNoKeepIt            = 'No, keep it intact!';

implementation

uses
  {$ifdef debug_secure}
  LazLogger,
  {$endif}
  security.manager.controls_manager,
  security.manager.level.addusrdlg,
  Dialogs;

constructor EPasswordsDontMatch.Create;
begin
  inherited Create(strPasswordsDontMatch);
end;

constructor EInvalidUserDataException.Create;
begin
  inherited Create(strInvalidDataSupplied);
end;

{ TFrmLogin }

function TSecureFrmLogin.GetUserLogin: String;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=edtLogin.Text;
end;

procedure TSecureFrmLogin.CancelClicked(Sender: TObject);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FOnCancelClick) then
    FOnCancelClick(Sender)
end;

function TSecureFrmLogin.GetUserPassword: String;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=edtPassword.Text;
end;

procedure TSecureFrmLogin.OKClicked(Sender: TObject);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(FOnOKClick) then
    FOnOKClick(Sender);
end;

procedure TSecureFrmLogin.SetUserLogin(AValue: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  edtLogin.Text:=AValue;
end;

procedure TSecureFrmLogin.SetUserPassword(AValue: String);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  edtPassword.Text:=AValue;
end;

procedure TSecureFrmLogin.SetFocusedControl(AValue: TSecureFocusedControl);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if CanFocus then
    case AValue of
      fcUserName: if edtLogin.Enabled and edtLogin.CanFocus then edtLogin.SetFocus;
      fcPassword: if edtPassword.Enabled and  edtPassword.CanFocus then edtPassword.SetFocus;
    end;

  FFocusedControl:=AValue;
end;

procedure TSecureFrmLogin.DoShow;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited DoShow;
  SetFocusedControl(FFocusedControl);
end;

constructor TSecureFrmLogin.CreateNew(AOwner: TComponent; Num: Integer);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited CreateNew(AOwner,Num);
  BorderStyle:=bsDialog;
  SetBounds(0,0,300,150);
  Position:=poScreenCenter;
  FormStyle:=fsSystemStayOnTop;

  lblLogin:=TLabel.Create(Self);
  lblLogin.Caption:=strUserLogin;
  lblLogin.SetBounds(8,8,58,14);
  lblLogin.Parent:=Self;

  edtLogin:=TEdit.Create(Self);
  edtLogin.Name:='PASCALSECURITY_FRMLOGIN_edtLogin';
  edtLogin.Text:='';
  edtLogin.SetBounds(8,24, 290, 86);
  edtLogin.Parent:=Self;

  lblLogin.FocusControl:=edtLogin;

  lblPassword:=TLabel.Create(Self);
  lblPassword.Caption:=strUserPass;
  lblPassword.SetBounds(8,56,54,14);
  lblPassword.Parent:=Self;

  edtPassword:=TEdit.Create(Self);
  edtPassword.Name:='PASCALSECURITY_FRMLOGIN_edtPassword';
  edtPassword.PasswordChar:='*';
  edtPassword.SetBounds(8,72, 290, 86);
  edtPassword.Text:='';
  edtPassword.Parent:=Self;

  lblPassword.FocusControl:=edtPassword;

  btnButtons:=TButtonPanel.Create(Self);
  btnButtons.ShowButtons:=[pbOK, pbCancel];
  btnButtons.OKButton.OnClick:=@OKClicked;
  btnButtons.CancelButton.OnClick:=@CancelClicked;
  btnButtons.Parent:=Self;
end;

procedure TSecureFrmLogin.EnableEntry;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  edtPassword.Enabled:=true;
  edtLogin.Enabled:=true;
  btnButtons.Enabled:=true;
  DoShow;
end;

procedure TSecureFrmLogin.DisableEntry;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  edtPassword.Enabled:=false;
  edtLogin.Enabled:=false;
  btnButtons.Enabled:=false;
end;

{ TGraphicalUsrMgntInterface }

procedure TGraphicalUsrMgntInterface.OKClick(Sender: TObject);
var
  aUID:Integer;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FCanCloseLogin:=false;
  if not Assigned(frmLogin) then exit;
  FCanCloseLogin:=GetControlSecurityManager.Login(frmLogin.GetUserLogin,frmLogin.GetUserPassword, aUID);
  if not FCanCloseLogin then begin
    frmLogin.SetUserPassword('');
    frmLogin.FocusedControl:=fcPassword;
    frmLogin.DoShow;
  end;
end;

function TGraphicalUsrMgntInterface.GetLoginClass: TSecureCustomFrmLoginClass;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=TSecureFrmLogin;
end;

procedure TGraphicalUsrMgntInterface.LevelAddUserClick(Sender: TObject);
var
  frm: TsecureLevelAddUser;
  aUID: Integer;
  aLvlObj, usr: TUserWithLevelAccess;
  a, b, c, d: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  a:=Assigned(FCurrentUserSchema);
  b:=(FCurrentUserSchema is TUsrLevelMgntSchema);
  c:=Supports(TUsrLevelMgntSchema(FCurrentUserSchema).LevelInterface, IUsrLevelMgntInterface);
  d:=Assigned(lvlfrm);

  if (a=false) or (b=false) or (c=false) or (d=false) then
    raise EInvalidUsrMgntSchema.Create;

  frm:=TsecureLevelAddUser.Create(lvlfrm);
  try
    frm.UserBlocked.Checked:=false;
    frm.usrLogin.Text:='';
    frm.usrFullName.Text:='';
    frm.usrPassword.Text:='';
    frm.usrConfirmPassword.Text:='';
    with FCurrentUserSchema as TUsrLevelMgntSchema do begin
      if MinLevel=AdminLevel then
        frm.secureUserLevel.Value:=MaxLevel
      else
        frm.secureUserLevel.Value:=MinLevel;
    end;
    frm.ValidadeAddDialog:=@LevelValidateAddUser;
    if frm.ShowModal=mrOK then begin
      with TUsrLevelMgntSchema(FCurrentUserSchema) do begin
        if LevelInterface.LevelAddUser(frm.usrLogin.Text,
                                    frm.usrFullName.Text,
                                    frm.usrPassword.Text,
                                    frm.secureUserLevel.Value,
                                    frm.UserBlocked.Checked,
                                    aUID,
                                    aLvlObj) then begin
          LevelRefreshUserList;
        end;
      end;
    end;
  finally
    FreeAndNil(frm);
  end;
end;

procedure TGraphicalUsrMgntInterface.LevelBlockUserClick(Sender: TObject;
  const aUser: TUserWithLevelAccess);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}

end;

procedure TGraphicalUsrMgntInterface.LevelChangeUserClick(Sender: TObject;
  const aUser: TUserWithLevelAccess);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}

end;

procedure TGraphicalUsrMgntInterface.LevelChangeUserPassClick(Sender: TObject;
  const aUser: TUserWithLevelAccess);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}

end;

procedure TGraphicalUsrMgntInterface.LevelDeleteUser(Sender: TObject;
  var aUser: TUserWithLevelAccess);
var
  a, b, c, d, e: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  a:=Assigned(FCurrentUserSchema);
  b:=(FCurrentUserSchema is TUsrLevelMgntSchema);
  c:=Supports(TUsrLevelMgntSchema(FCurrentUserSchema).LevelInterface, IUsrLevelMgntInterface);
  d:=Assigned(aUser);
  e:=Assigned(lvlfrm);

  if (a=false) or (b=false) or (c=false) or (d=false) or (e=false) then
    raise EInvalidUsrMgntSchema.Create;

  if QuestionDlg(strDeleteUser,
                 Format(strConfirmDeleteUser,[aUser.Login]),
                 mtConfirmation,
                 [mrYes, Format(strYesDeleteTheUser,[aUser.Login]), mrNo, strNoKeepIt, 'IsDefault'],
                 0)=mrYes
  then begin
    if TUsrLevelMgntSchema(FCurrentUserSchema).LevelInterface.LevelDelUser(aUser) then begin
      LevelRefreshUserList;
    end;
  end;
end;

procedure TGraphicalUsrMgntInterface.LevelValidateAddUser(Sender: TObject);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Sender is TsecureLevelAddUser then
    with Sender as TsecureLevelAddUser do begin
      if SameText(Trim(usrLogin.Text), '') or SameText(usrPassword.Text, '') or SameText(usrConfirmPassword.Text, '') then
        raise EInvalidUserDataException.Create;
      if (not SameText(usrPassword.Text, usrConfirmPassword.Text)) then
        raise EPasswordsDontMatch.Create;
    end;
end;

procedure TGraphicalUsrMgntInterface.LevelRefreshUserList;
var
  item: TListItem;
  u, lvlLength: Integer;
  aLvlSchema: TUsrLevelMgntSchema;
  usr: TUserWithLevelAccess;
  a, b, c, d: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  a:=Assigned(FCurrentUserSchema);
  b:=(FCurrentUserSchema is TUsrLevelMgntSchema);
  c:=Supports(TUsrLevelMgntSchema(FCurrentUserSchema).LevelInterface, IUsrLevelMgntInterface);
  d:=Assigned(lvlfrm);

  if a and b and c and d then begin
    lvlfrm.ListView1.Clear;
    aLvlSchema:=TUsrLevelMgntSchema(FCurrentUserSchema);
    lvlLength:=lvlfrm.LevelLength;
    for u:=0 to TUsrLevelMgntSchema(FCurrentUserSchema).UserList.Count-1 do begin
      usr:=aLvlSchema.UserList.KeyData[aLvlSchema.UserList.Keys[u]];
      item:=lvlfrm.ListView1.Items.add;
      item.Caption:=usr.Login;
      item.SubItems.Add(usr.UserDescription);
      item.SubItems.Add(RightStr(StringOfChar('0',lvlLength)+inttostr(usr.UserLevel),lvlLength));
      item.SubItems.Add(ifthen(usr.UserBlocked, strYes, strNo));
      item.Data:=usr;
    end;
  end;
end;

procedure TGraphicalUsrMgntInterface.CanCloseLogin(Sender: TObject;
  var CanClose: boolean);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  CanClose:=FCanCloseLogin;
end;

procedure TGraphicalUsrMgntInterface.CancelClick(Sender: TObject);
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  FCanCloseLogin:=true;
end;

function TGraphicalUsrMgntInterface.Login(out aLogin, aPass: UTF8String
  ): Boolean;
var
  afrmLogin: TSecureCustomFrmLogin;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  afrmLogin:=GetLoginClass.CreateNew(Application);
  try
    Result:=afrmLogin.ShowModal=mrOK;
    if Result then begin
      aLogin:=frmLogin.UserLogin;
      aPass :=frmLogin.UserPassword;
    end;
  finally
    FreeAndNil(afrmLogin);
  end;
end;

function TGraphicalUsrMgntInterface.Login: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(frmLogin) then begin
    Result:=false;
    frmLogin.ShowOnTop;
    exit;
  end;

  FCanCloseLogin:=false;

  frmLogin:=GetLoginClass.CreateNew(nil);
  try
    frmLogin.Caption:=strFrmLoginCaption;
    frmLogin.OnCloseQuery:=@CanCloseLogin;
    frmLogin.OnOKClick:=@OKClick;
    frmLogin.OnCancelClick:=@CancelClick;
    frmLogin.UserLogin:='';
    frmLogin.FocusedControl:=fcUserName;
    Result:=frmLogin.ShowModal=mrOK;
  finally
    FreeAndNil(frmLogin);
  end;
end;

function TGraphicalUsrMgntInterface.CanLogout: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=true;
end;

procedure TGraphicalUsrMgntInterface.UserManagement(aSchema: TUsrMgntSchema);
var
  lvlSchema: TUsrLevelMgntSchema;
  i: Integer;
  usr: TUserWithLevelAccess;
  item: TListItem;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  //allows one user management...
  if (not Assigned(FCurrentUserSchema)) and Assigned(aSchema) then begin
    FCurrentUserSchema:=aSchema;
    try
      {$ifdef UseLevelSchema}
      if aSchema is TUsrLevelMgntSchema then begin
        lvlSchema:=TUsrLevelMgntSchema(aSchema);
        lvlfrm:=TsecureUsrLvlMgnt.Create(Self);
        try
          lvlfrm.OnAddUserClick:=@LevelAddUserClick;
          lvlfrm.OnBlockUserClick:=@LevelBlockUserClick;
          lvlfrm.OnChangeUserClick:=@LevelChangeUserClick;
          lvlfrm.OnChangeUsrPassClick:=@LevelChangeUserPassClick;
          lvlfrm.OnDelUserClick:=@LevelDeleteUser;
          lvlfrm.LevelLength := Max(Length(IntToStr(lvlSchema.MinLevel)), Length(IntToStr(lvlSchema.MaxLevel)));

          LevelRefreshUserList;
          lvlfrm.ShowModal;
        finally
          FreeAndNil(lvlfrm);
        end;
        exit;
      end;
      {$endif UseLevelSchema}
      {$IfDef UseAuthSchema}
      if aSchema is TUsrAuthSchema then begin

        exit;
      end;

      if aSchema is TUsrGroupAuthSchema then begin

        exit;
      end;

      if aSchema is TGroupAuthSchema then begin

        exit;
      end;
      {$endif UseAuthSchema}

      //unknown schema class...
      raise EUnknownUserMgntSchema.Create;
    finally
      FCurrentUserSchema:=nil;
    end;
  end else begin
    if not Assigned(aSchema) then
      raise ENilUserSchema.Create;

    //TODO: Second user management session exception...
  end;

end;

procedure TGraphicalUsrMgntInterface.FreezeUserLogin;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(frmLogin) then frmLogin.DisableEntry;
end;

procedure TGraphicalUsrMgntInterface.UnfreezeUserLogin;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  if Assigned(frmLogin) then frmLogin.EnableEntry;
end;

procedure TGraphicalUsrMgntInterface.ProcessMessages;
begin
  Application.ProcessMessages;
  CheckSynchronize(1);
  Sleep(1);
end;

function TGraphicalUsrMgntInterface.LoginVisibleBetweenRetries: Boolean;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  Result:=true;
end;

end.

