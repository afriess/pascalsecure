unit security.manager.addusrdlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, ComCtrls, Spin;

type
  TsecureAddUser = class(TForm)
    ButtonPanel1: TButtonPanel;
    UserBlocked: TCheckBox;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    usrPassword: TEdit;
    usrConfirmPassword: TEdit;
    usrLogin: TEdit;
    Label1: TLabel;
    usrFullName: TEdit;
    procedure ButtonPanel1Click(Sender: TObject);
  private
    FValidateAddDialog: TNotifyEvent;
  protected
    FValidadeAddDialog: TNotifyEvent;
    procedure ValidateAdd; virtual;
  published
    property ValidadeAddDialog:TNotifyEvent read FValidateAddDialog write FValidadeAddDialog;
  end;

var
  secureAddUser: TsecureAddUser;

implementation

{$R *.lfm}

procedure TsecureAddUser.ButtonPanel1Click(Sender: TObject);
begin
  ValidateAdd;
end;

procedure TsecureAddUser.ValidateAdd;
begin
  if Assigned(FValidadeAddDialog) then
    FValidadeAddDialog(Self);
end;

end.

