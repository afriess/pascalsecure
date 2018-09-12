{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit PSECCommon;

{$warn 5023 off : no warning about unused units}
interface

uses
  PSECcontrolsManager, PSECExceptions, PSECInterfaces, PSECSecureAuthManager, 
  PSECSecureLevelManager, PSECSecureManager, PSECTexts, PSECUserSchema, 
  PSECBasic_user_management, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('PSECcontrolsManager', @PSECcontrolsManager.Register);
  RegisterUnit('PSECSecureAuthManager', @PSECSecureAuthManager.Register);
  RegisterUnit('PSECSecureLevelManager', @PSECSecureLevelManager.Register);
end;

initialization
  RegisterPackage('PSECCommon', @Register);
end.
