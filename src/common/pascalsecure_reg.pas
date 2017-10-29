unit pascalsecure_reg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils
  , security.manager.custom_user_management
  ;

ResourceString
  SPascalSecurePalette = 'PascalSecure';

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents(SPascalSecurePalette,[TUserLevelUserManagement]);
end;

end.

