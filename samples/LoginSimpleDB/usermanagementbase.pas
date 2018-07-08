unit usermanagementbase;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, ZConnection;

type
  IUserManagementAccess = interface
    ['{50ED3CB6-97F0-49D1-BB7B-4294FDD20A00}']
    procedure CanAccess(securityCode: String; var CanAccess: Boolean);
    procedure CheckUserAndPass(user, pass: String;
        var aUID: Integer; var ValidUser: Boolean; LoginAction: Boolean);
    function GetUser:String;
  end;

  { TUserManagement }

  TUserManagement = class(TDataModule,IUserManagementAccess)
  private
    function GetCon: TZConnection;
  protected
    FCon: TZConnection;
    procedure SetCon(AValue: TZConnection); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    procedure CanAccess(securityCode: String; var CanAccess: Boolean); virtual abstract;
    procedure CheckUserAndPass(user, pass: String; var aUID: Integer;
      var ValidUser: Boolean; LoginAction: Boolean); virtual abstract;
    function GetUser: String; virtual abstract;
  published
    property Connection: TZConnection read GetCon write SetCon;
  end;


implementation

{$R *.lfm}

{ TUserManagement }

function TUserManagement.GetCon: TZConnection;
begin
  Result := FCon;
end;

procedure TUserManagement.SetCon(AValue: TZConnection);
begin
  if FCon=AValue then Exit;
  FCon:=AValue;
end;

constructor TUserManagement.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCon := nil;
end;

end.

