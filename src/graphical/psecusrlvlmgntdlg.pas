unit PSECusrlvlmgntdlg;
{$I PSECinclude.inc}
{ *************************
  Level based UserManager
  This is a implementation of the UserManager working with a level based
  security schema. This means, the user have a level defined by a number. The
  security system compare this number with levels. Is the level of the user
  equal or higher, the user have the right to use the component, function or
  event.
  *************************
This is a part of the PSEC (Pascal SECure) framework, it is a
standalone part of PascalSCADA 1.0. A multiplatform SCADA framework for Lazarus.
This code is a entire rewrite of PascalSCADA hosted at
https://sourceforge.net/projects/pascalscada.

Copyright Fabio Luis Girardi (https://github.com/fluisgirardi/pascalsecure)
          Andreas Frieß      (https://github.com/afriess/pascalsecure)

This code is under modified LGPL (see LICENSE.modifiedLGPL.txt).
}
interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ComCtrls,
  ButtonPanel, ActnList, PSECcustomusermgntdlg, PSECUserSchema, PSECExceptions;

type
  TSecureLvlUsrMgntNotifyEvent = procedure(Sender:TObject; const aUser:TPSECUserWithLevelAccess) of object;

  TPSECUsrLvlMgnt = class(TPSECCustomUsrMgnt)
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
    procedure ListView1Editing(Sender: TObject; Item: TListItem;
      var AllowEdit: Boolean);
    procedure ListView1SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
  private
    FOnAddUserClick: TNotifyEvent;
    FOnBlockUserClick: TSecureLvlUsrMgntNotifyEvent;
    FOnChangeUserClick: TSecureLvlUsrMgntNotifyEvent;
    FOnChangeUsrPassClick: TSecureLvlUsrMgntNotifyEvent;
    FOnDelUserClick: TSecureLvlUsrMgntNotifyEvent;
    procedure ValidateSelectedUser(const aUser: TListItem);
  published
    property OnAddUserClick:TNotifyEvent                       read FOnAddUserClick       write FOnAddUserClick;
    property OnDelUserClick:TSecureLvlUsrMgntNotifyEvent       read FOnDelUserClick       write FOnDelUserClick;
    property OnBlockUserClick:TSecureLvlUsrMgntNotifyEvent     read FOnBlockUserClick     write FOnBlockUserClick;
    property OnChangeUserClick:TSecureLvlUsrMgntNotifyEvent    read FOnChangeUserClick    write FOnChangeUserClick;
    property OnChangeUsrPassClick:TSecureLvlUsrMgntNotifyEvent read FOnChangeUsrPassClick write FOnChangeUsrPassClick;
  end;

  ESecurityInvalidUserSelected = class(PSECException)
  public
    constructor Create;
  end;

  resourcestring
    SInvalidUserSelected = 'Invalid user selected!';

implementation

{$R *.lfm}

constructor ESecurityInvalidUserSelected.Create;
begin
  inherited Create(SInvalidUserSelected);
end;

procedure TPSECUsrLvlMgnt.ValidateSelectedUser(const aUser:TListItem);
begin
  if (aUser=nil) or (aUser.Data=nil) or ((TObject(aUser.Data) is TPSECUserWithLevelAccess)=false) then
    raise ESecurityInvalidUserSelected.Create;
end;

procedure TPSECUsrLvlMgnt.addUserExecute(Sender: TObject);
begin
  if Assigned(FOnAddUserClick) then
    FOnAddUserClick(Sender);
end;

procedure TPSECUsrLvlMgnt.ChangePassExecute(Sender: TObject);
begin
  ValidateSelectedUser(ListView1.Selected);

  if Assigned(FOnChangeUsrPassClick) then
    FOnChangeUsrPassClick(Sender, TPSECUserWithLevelAccess(ListView1.Selected.Data));
end;

procedure TPSECUsrLvlMgnt.delUserExecute(Sender: TObject);
begin
  ValidateSelectedUser(ListView1.Selected);

  if Assigned(FOnDelUserClick) then
    FOnDelUserClick(Sender, TPSECUserWithLevelAccess(ListView1.Selected.Data));
end;

procedure TPSECUsrLvlMgnt.DisableUserExecute(Sender: TObject);
begin
  ValidateSelectedUser(ListView1.Selected);

  if Assigned(FOnBlockUserClick) then
    FOnBlockUserClick(Sender, TPSECUserWithLevelAccess(ListView1.Selected.Data));
end;

procedure TPSECUsrLvlMgnt.ListView1Editing(Sender: TObject; Item: TListItem;
  var AllowEdit: Boolean);
begin
  AllowEdit:=false;
end;

procedure TPSECUsrLvlMgnt.ListView1SelectItem(Sender: TObject;
  Item: TListItem; Selected: Boolean);
var
  res: Boolean;
begin
  res:=(Item<>nil);
  delUser.Enabled:=res;
  ChangePass.Enabled:=res;
  DisableUser.Enabled:=res;
end;

end.

