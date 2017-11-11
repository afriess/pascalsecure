unit security.manager.level.mgntdlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ButtonPanel, ActnList, security.manager.mgntdlg, security.exceptions,
  security.manager.schema;

type
  TSecureLvlUsrMgntNotifyEvent   = procedure(Sender:TObject; const aUser:TUserWithLevelAccess) of object;
  TSecureLvlUsrMgntDelUsrEvent   = procedure(Sender:TObject; var   aUser:TUserWithLevelAccess) of object;
  TSecureLvlUsrMgntBlockUsrEvent = procedure(Sender:TObject; var   aUser:TUserWithLevelAccess; const Blocked:Boolean) of object;

  TSecureUsrLvlMgnt = class(TCustomUsrMgnt)
    EnableUser: TAction;
    ChangePass: TAction;
    addUser: TAction;
    delUser: TAction;
    DisableUser: TAction;
    ListView1: TListView;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    procedure addUserExecute(Sender: TObject);
    procedure ChangePassExecute(Sender: TObject);
    procedure delUserExecute(Sender: TObject);
    procedure DisableUserExecute(Sender: TObject);
    procedure EnableUserExecute(Sender: TObject);
    procedure ListView1Editing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    FLevelLength: Integer;
    FOnAddUserClick: TNotifyEvent;
    FOnBlockUserClick: TSecureLvlUsrMgntBlockUsrEvent;
    FOnChangeUserClick: TSecureLvlUsrMgntNotifyEvent;
    FOnChangeUsrPassClick: TSecureLvlUsrMgntNotifyEvent;
    FOnDelUserClick: TSecureLvlUsrMgntDelUsrEvent;
    procedure ValidateSelectedUser(const aUser: TListItem);
    procedure VerifySelected(Data: PtrInt);
  published
    property LevelLength:Integer                               read FLevelLength          write FLevelLength;
    property OnAddUserClick:TNotifyEvent                       read FOnAddUserClick       write FOnAddUserClick;
    property OnDelUserClick:TSecureLvlUsrMgntDelUsrEvent       read FOnDelUserClick       write FOnDelUserClick;
    property OnBlockUserClick:TSecureLvlUsrMgntBlockUsrEvent   read FOnBlockUserClick     write FOnBlockUserClick;
    property OnChangeUserClick:TSecureLvlUsrMgntNotifyEvent    read FOnChangeUserClick    write FOnChangeUserClick;
    property OnChangeUsrPassClick:TSecureLvlUsrMgntNotifyEvent read FOnChangeUsrPassClick write FOnChangeUsrPassClick;

  end;

  ESecurityInvalidUserSelected = class(ESecurityException)
  public
    constructor Create;
  end;

  resourcestring
    SInvalidUserSelected = 'Invalid user selected!';
var
  secureUsrLvlMgnt: TsecureUsrLvlMgnt;

implementation

{$R *.lfm}

constructor ESecurityInvalidUserSelected.Create;
begin
  inherited Create(SInvalidUserSelected);
end;

procedure TSecureUsrLvlMgnt.ValidateSelectedUser(const aUser:TListItem);
begin
  if (aUser=nil) or (aUser.Data=nil) or ((TObject(aUser.Data) is TUserWithLevelAccess)=false) then
    raise ESecurityInvalidUserSelected.Create;
end;

procedure TSecureUsrLvlMgnt.VerifySelected(Data: PtrInt);
var
  res: Boolean;
  Item: TListItem;
begin
  Item:=ListView1.Selected;
  res:=(Item<>nil);
  delUser.Enabled:=res;
  ChangePass.Enabled:=res;
  DisableUser.Enabled:=res;
  EnableUser.Enabled:=false;

  if res and (TObject(Item.Data) is TUserWithLevelAccess) then begin
    if TUserWithLevelAccess(Item.Data).UserBlocked then begin
      EnableUser.Enabled := true;
      DisableUser.Enabled:= false;
      ToolButton5.Action:=EnableUser;
    end else begin
      EnableUser.Enabled := false;
      DisableUser.Enabled:= true;
      ToolButton5.Action := DisableUser;
    end;
  end;
end;

procedure TSecureUsrLvlMgnt.addUserExecute(Sender: TObject);
begin
  if Assigned(FOnAddUserClick) then
    FOnAddUserClick(Sender);
end;

procedure TSecureUsrLvlMgnt.ChangePassExecute(Sender: TObject);
begin
  ValidateSelectedUser(ListView1.Selected);

  if Assigned(FOnChangeUsrPassClick) then
    FOnChangeUsrPassClick(Sender, TUserWithLevelAccess(ListView1.Selected.Data));
end;

procedure TSecureUsrLvlMgnt.delUserExecute(Sender: TObject);
var
  ausr: TUserWithLevelAccess;
begin
  ValidateSelectedUser(ListView1.Selected);

  ausr:=TUserWithLevelAccess(ListView1.Selected.Data);

  if Assigned(FOnDelUserClick) then
    FOnDelUserClick(Sender, ausr);
end;

procedure TSecureUsrLvlMgnt.DisableUserExecute(Sender: TObject);
var
  ausr: TUserWithLevelAccess;
begin
  ValidateSelectedUser(ListView1.Selected);

  ausr:=TUserWithLevelAccess(ListView1.Selected.Data);

  if Assigned(FOnBlockUserClick) then
    FOnBlockUserClick(Sender, ausr, true);
end;

procedure TSecureUsrLvlMgnt.EnableUserExecute(Sender: TObject);
var
  ausr: TUserWithLevelAccess;
begin
  ValidateSelectedUser(ListView1.Selected);

  ausr:=TUserWithLevelAccess(ListView1.Selected.Data);

  if Assigned(FOnBlockUserClick) then
    FOnBlockUserClick(Sender, ausr, false);
end;

procedure TSecureUsrLvlMgnt.ListView1Editing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit:=false;
end;

procedure TSecureUsrLvlMgnt.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
begin
  Application.QueueAsyncCall(@VerifySelected,0);
end;

end.

