{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit pascalsecure;

interface

uses
  security.exceptions, security.manager.basic_user_management, 
  security.manager.controls_manager_old, 
  security.manager.custom_user_management, 
  security.manager.custom_usrmgnt_interface, security.manager.schema, 
  security.texts, pascalsecure_reg, LazarusPackageIntf;

implementation

procedure Register;
begin
end;

initialization
  RegisterPackage('pascalsecure', @Register);
end.
