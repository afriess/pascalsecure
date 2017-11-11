unit frmMain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ActnList, Spin, security.actions.login, security.controls.SecureButton,
  security.manager.graphical_user_management, security.actions.manage,
  security.manager.custom_user_management, security.manager.schema;

type

  { TForm1 }

  TForm1 = class(TForm)
    ActionList1: TActionList;
    BuLoginAndi: TButton;
    BuLogout: TButton;
    BuLoginB: TButton;
    Button1: TButton;
    Button2: TButton;
    GraphicalUsrMgntInterface1: TGraphicalUsrMgntInterface;
    LoginAction1: TLoginAction;
    ManageUsersAndGroupsAction1: TManageUsersAndGroupsAction;
    Memo1: TMemo;
    SecureButton1: TSecureButton;
    SecureButton2: TSecureButton;
    UserCustomizedUserManagement1: TUserCustomizedUserManagement;
    procedure BuLoginAndiClick(Sender: TObject);
    procedure BuLoginBClick(Sender: TObject);
    procedure BuLogoutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure CustomizedUserManagement1CanAccess(securityCode: String;
      var CanAccess: Boolean);
    procedure CustomizedUserManagement1CheckUserAndPass(user,
      pass: String; var aUID: Integer; var ValidUser: Boolean;
      LoginAction: Boolean);
    procedure CustomizedUserManagement1GetUserLogin(var UserInfo: String);
    procedure FormDestroy(Sender: TObject);
    procedure SecureButton1Click(Sender: TObject);
    procedure UserCustomizedUserManagement1GetSchemaType(
      var SchemaType: TUsrMgntType);
    procedure UserCustomizedUserManagement1GetUserSchema(
      var Schema: TUsrMgntSchema);
    procedure UserCustomizedUserManagement1LevelAddUser(const UserLogin,
      UserDescription, PlainPassword: UTF8String; const aUsrLevel: Integer;
      const aBlocked: Boolean; out aUID: Integer; out Result: Boolean);
    procedure UserCustomizedUserManagement1LevelBlockUser(
      var aUsrObject: TUserWithLevelAccess; const aBlocked: Boolean; out
      Result: Boolean);
    procedure UserCustomizedUserManagement1LevelDelUser(
      const aUsrObject: TUserWithLevelAccess; out Result: Boolean);
    procedure UserCustomizedUserManagement1Logout(Sender: TObject);
  private
    LastValidUser:String;
    NextUID:Integer;
  public

  end;

var
  Form1: TForm1;

implementation

uses
  security.manager.controls_manager, strutils;

{$R *.lfm}

{ TForm1 }

procedure TForm1.CustomizedUserManagement1CheckUserAndPass(user,
  pass: String; var aUID: Integer; var ValidUser: Boolean; LoginAction: Boolean
  );
begin
  //
  //check the user login and password
  Memo1.Append('CustomizedUserManagement1CheckUserAndPass'+' ' + user + ' '+pass);
  ValidUser:=(((user='andi')  and (pass='1')) or
              ((user='user')  and (pass='2')) or
              ((user='root')  and (pass='3')) or
              ((user='fabio') and (pass='7')));

  if ValidUser then
    LastValidUser:=user;
end;

procedure TForm1.CustomizedUserManagement1GetUserLogin(
  var UserInfo: String);
begin
  //
  Memo1.Append('CustomizedUserManagement1GetUserLogin' + ' ' +UserInfo);
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
  //
end;

procedure TForm1.SecureButton1Click(Sender: TObject);
begin
  Memo1.Append('SecureButton Clicked');
end;

procedure TForm1.UserCustomizedUserManagement1GetSchemaType(
  var SchemaType: TUsrMgntType);
begin
  SchemaType:=umtLevel;
end;

procedure TForm1.UserCustomizedUserManagement1GetUserSchema(
  var Schema: TUsrMgntSchema);
var
  aLvlMgntIntf:IUsrLevelMgntInterface;
begin
  if Supports(UserCustomizedUserManagement1, IUsrLevelMgntInterface, aLvlMgntIntf) then begin
    Schema:=TUsrLevelMgntSchema.Create(1, 100, 1, aLvlMgntIntf);
    with Schema as TUsrLevelMgntSchema do begin
      UserList.Add(0,TUserWithLevelAccess.Create(0,'root','Main administrator',false, 1));
      UserList.Add(1,TUserWithLevelAccess.Create(1,'andi','A user',            false, 1));
      UserList.Add(2,TUserWithLevelAccess.Create(2,'user','Another user',      true,  10));
    end;
  end;
end;

procedure TForm1.UserCustomizedUserManagement1LevelAddUser(const UserLogin,
  UserDescription, PlainPassword: UTF8String; const aUsrLevel: Integer;
  const aBlocked: Boolean; out aUID: Integer; out Result: Boolean);
begin
  Memo1.Append('UserCustomizedUserManagement1LevelAddUser');
  aUID:=NextUID;
  Inc(NextUID);
  Result:=true;
  ShowMessage('User Application event binding: Add the new user in your database, file or something else...');
end;

procedure TForm1.UserCustomizedUserManagement1LevelBlockUser(
  var aUsrObject: TUserWithLevelAccess; const aBlocked: Boolean; out
  Result: Boolean);
begin
  ShowMessage(format('User Application event binding: The user "%s" will be %s',[aUsrObject.Login, IfThen(aBlocked,'blocked/disabled','unblocked/enabled')]));
  aUsrObject.UserBlocked:=aBlocked;
  //update the enabled/disabled user in your database,file or anything else here
  Result:=true;
end;

procedure TForm1.UserCustomizedUserManagement1LevelDelUser(
  const aUsrObject: TUserWithLevelAccess; out Result: Boolean);
begin
  ShowMessage(format('User Application event binding: The user "%s" was deleted!',[aUsrObject.Login]));
  Result:=true; //confirm all delete commands...
  //delete the user in your database,file or anything else here
end;

procedure TForm1.UserCustomizedUserManagement1Logout(Sender: TObject);
begin
  Memo1.Append('CustomizedUserManagement1Logout');
  LastValidUser:='';
end;

procedure TForm1.CustomizedUserManagement1CanAccess(securityCode: String;
  var CanAccess: Boolean);
begin
  Memo1.Append('CustomizedUserManagement1CanAccess'+' '+securityCode);
  //check if the current user can access the securityCode
  CanAccess :=((LastValidUser='andi') and (securityCode='autorizacao1')) or
              ((LastValidUser='user') and (securityCode='autorizacao2')) or
              ((LastValidUser='root') and ((securityCode='autorizacao1') or (securityCode='autorizacao2')));

end;

procedure TForm1.BuLoginAndiClick(Sender: TObject);
var
  dummy : Integer;
begin
  Memo1.Append('BuLoginAndiClick');
  GetControlSecurityManager.Logout;
  GetControlSecurityManager.Login('andi','1',dummy);
end;

procedure TForm1.BuLoginBClick(Sender: TObject);
var
  dummy : Integer;
begin
  Memo1.Append('BuLoginBClick');
  GetControlSecurityManager.Logout;
  GetControlSecurityManager.Login('xxx','1',dummy);
end;

procedure TForm1.BuLogoutClick(Sender: TObject);
begin
  Memo1.Append('BuLogoutClick');
  GetControlSecurityManager.Logout;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  Memo1.Clear;
  Memo1.Append('Create');
  NextUID:=1000;
end;

end.

