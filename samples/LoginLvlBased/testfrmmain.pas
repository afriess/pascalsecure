unit testfrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList,
  // security
  security.securemanager,
  security.actions.login, security.controls.SecureButton,
  security.manager.graphical_user_management, security.actions.manage,
  security.manager.custom_user_management, security.manager.schema,;

type

  { TFormAuthBased }

  TFormAuthBased = class(TForm)
    ActionList1: TActionList;
    BuLogout: TButton;
    BuGraphLogin: TButton;
    BuManage: TButton;
    GraphicalUsrMgntInterface1: TGraphicalUsrMgntInterface;
    LoginAction1: TLoginAction;
    ManageUsersAndGroupsAction1: TManageUsersAndGroupsAction;
    Memo1: TMemo;
    SecureButton1: TSecureButton;
    SecureButton2: TSecureButton;
    procedure BuLogoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CustomizedUserManagement1CanAccess(securityCode: String;
      var CanAccess: Boolean);
    procedure CustomizedUserManagement1CheckUserAndPass(user,
      pass: String; var aUID: Integer; var ValidUser: Boolean;
      LoginAction: Boolean);
    procedure CustomizedUserManagement1GetUserLogin(var UserInfo: String);
    procedure FormDestroy(Sender: TObject);
    procedure ManageUsersAndGroupsAction1Execute(Sender: TObject);
    procedure SecureButton1Click(Sender: TObject);
    procedure UserLevelUserManagement1GetSchemaType(
      var SchemaType: TUsrMgntType);
    procedure UserLevelUserManagement1GetUserName(var UserInfo: String);
    procedure UserLevelUserManagement1GetUserSchema(
      var Schema: TUsrMgntSchema);
    procedure UserLevelUserManagement1Logout(Sender: TObject);
    procedure UserCustomizedUserManagement1ManageUsersAndGroups(Sender: TObject
      );
  private
    LastValidUser:String;
  protected
    SCM : TSecureManager;
  public
    constructor Create(TheOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  FormAuthBased: TFormAuthBased;

implementation

uses
  security.manager.controls_manager, ubuildschemalvl, strutils;

{$R *.lfm}


{ TFormAuthBased }

procedure TFormAuthBased.CustomizedUserManagement1CheckUserAndPass(user,
  pass: String; var aUID: Integer; var ValidUser: Boolean; LoginAction: Boolean);
var
  aUser: TCustomUser;

begin
  //check the user login and password
  Memo1.Append('CustomizedUserManagement1CheckUserAndPass'+' ' + user + ' '+pass);
  ValidUser:= False;
  LastValidUser:= '';
  { TODO -oAndi : This should be easier to handle}
  if TUserLevelUserManagement(GetControlSecurityManager.UserManagement).UserMgnt is TUsrLevelMgntSchema then begin
     aUser := TUsrLevelMgntSchema(TUserLevelUserManagement(GetControlSecurityManager.UserManagement).UserMgnt).UserByName[user];
     if aUser <> nil then
        ValidUser:= SameStr(aUser.Password,pass);
  end;
  if ValidUser then
    LastValidUser:=user;
end;

procedure TFormAuthBased.CustomizedUserManagement1GetUserLogin(
  var UserInfo: String);
begin
  //
  Memo1.Append('CustomizedUserManagement1GetUserLogin' + ' ' +UserInfo);
end;


procedure TFormAuthBased.FormDestroy(Sender: TObject);
begin
  //if Assigned(MySchema) then
  //  FreeAndNil(MySchema);
end;

procedure TFormAuthBased.ManageUsersAndGroupsAction1Execute(Sender: TObject);
begin

end;

procedure TFormAuthBased.SecureButton1Click(Sender: TObject);
begin
  Memo1.Append('SecureButton Clicked');
end;

procedure TFormAuthBased.UserLevelUserManagement1GetSchemaType(
  var SchemaType: TUsrMgntType);
begin
  Memo1.Append('UserCustomizedUserManagement1GetSchemaType');
end;

procedure TFormAuthBased.UserLevelUserManagement1GetUserName(
  var UserInfo: String);
begin
  Memo1.Append('UserCustomizedUserManagement1GetUserName');
end;

procedure TFormAuthBased.UserLevelUserManagement1GetUserSchema(
  var Schema: TUsrMgntSchema);
begin
  // Only used if OnManageUsersANdGroups not set !!
  Memo1.Append('UserCustomizedUserManagement1GetUserSchema');
  //Schema:= MySchema;
end;

procedure TFormAuthBased.UserLevelUserManagement1Logout(Sender: TObject);
begin
  Memo1.Append('CustomizedUserManagement1Logout');
  LastValidUser:='';
end;

procedure TFormAuthBased.UserCustomizedUserManagement1ManageUsersAndGroups(
  Sender: TObject);
begin
  Memo1.Append('UserCustomizedUserManagement1ManageUsersAndGroups');
  TUserLevelUserManagement(SCM.UserManagement).UsrMgntInterface.UserManagement(TUserLevelUserManagement(GetControlSecurityManager.UserManagement).UserMgnt);
end;

constructor TFormAuthBased.Create(TheOwner: TComponent);
begin
  inherited Create(TheOwner);
  // We create the manager
  SCM:= TCustomBasicSecureManager.Create(self);
end;

destructor TFormAuthBased.Destroy;
begin
  inherited Destroy;
end;

procedure TFormAuthBased.CustomizedUserManagement1CanAccess(securityCode: String;
  var CanAccess: Boolean);
//var
//  aUser: TAuthorizedUser;
begin
  CanAccess:= False;
  { TODO -oAndi : This should be easier to handle}
  //check if the current user can access the securityCode
  //if TUserLevelUserManagement(GetControlSecurityManager.UserManagement).UserMgnt is TUsrLevelMgntSchema then begin
  //   aUser := TAuthorizedUser(TUsrLevelMgntSchema(TUserLevelUserManagement(GetControlSecurityManager.UserManagement).UserMgnt).UserByName[LastValidUser]);
  //   if aUser <> nil then
  //     CanAccess:= (aUser.AuthorizationByName[securityCode] <> nil);
  //end;
  Memo1.Append('CustomizedUserManagement1CanAccess'+' '+securityCode+' = '+ifthen(CanAccess,'TRUE', 'FALSE'));
end;

procedure TFormAuthBased.BuLogoutClick(Sender: TObject);
begin
  Memo1.Append('BuLogoutClick');
  GetControlSecurityManager.Logout;
end;

procedure TFormAuthBased.FormCreate(Sender: TObject);
var
  UserMgmt: TUserLevelUserManagement;
  ASchema: TUsrLevelMgntSchema;
//  AUser: TAuthorizedUser;
begin
  Memo1.Clear;
  Memo1.Append('Create and build Schema');
  // *** Usermanagment ***
  SCM.UserManagement:= TUserLevelUserManagement.Create(nil);
  TUserLevelUserManagement(SCM.UserManagement).UsrMgntInterface:= TGraphicalUsrMgntInterface.Create(nil);
  // Create a authentication based Usermanagment
  SCM.UserManagement.UserMgnt:= TUsrLevelMgntSchema.Create(1, 100, 1, TUserLevelUserManagement(SCM.UserManagement).UsrMgntInterface);
  { TODO  : Simplify this to avoid potential errors }
  with TUsrLevelMgntSchema(SCM.UserManagement.UserMgnt) do begin
    UserList.Add(0,TUserWithLevelAccess.Create(0,'root','1','Main administrator',false, 1));
    UserList.Add(1,TUserWithLevelAccess.Create(1,'andi','2','A user',            false, 1));
    UserList.Add(2,TUserWithLevelAccess.Create(2,'user','3','Another user',      false, 10));
  end;
  Memo1.Append('-------------------------');
  Memo1.Append('Login as Username/Password');
  Memo1.Append('   root     1');
  Memo1.Append('   user     2');
  Memo1.Append('   andi     3');
  Memo1.Append('-------------------------');
end;

end.

