unit security.manager.addusrdlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  ButtonPanel, ComCtrls, Spin, ExtCtrls, Buttons;

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
  private
    FValidateAddDialog: TNotifyEvent;
  protected
    FValidadeAddDialog: TNotifyEvent;
    function ValidAdd:Boolean; virtual;
    function CloseQuery: boolean; override;
  published
    property ValidadeAddDialog:TNotifyEvent read FValidateAddDialog write FValidadeAddDialog;
  end;

var
  secureAddUser: TsecureAddUser;

implementation

{$R *.lfm}

function TsecureAddUser.ValidAdd: Boolean;
begin
  Result:=false;
  try
    if Assigned(FValidadeAddDialog) then
      FValidadeAddDialog(Self);
    Result:=true;
  except
    on e:Exception do begin
      Result:=false;
      Application.ShowException(e);
    end;
  end;
end;

function TsecureAddUser.CloseQuery: boolean;
begin
  Result:=ValidAdd and inherited CloseQuery;
end;

end.

