unit ubuildschemalvl;

{$mode objfpc}{$H+}

{$Define LocalFile}

interface

uses
  Classes, SysUtils, security.manager.schema;

function BuildSchemaLVL:Boolean;

implementation

uses
  LazLogger,
  LazUtils,
  LazFileUtils,
  BufDataSet,
  db,
  security.manager.controls_manager,
  security.manager.custom_user_management
  ;

function BuildSchemaLVL: Boolean;
var
  UserMgmt: TUserLevelUserManagement;
  ASchema: TUsrLevelMgntSchema;
//  AUser: TAuthorizedUser;
begin
  result := false;
  // Clear a possible old managment
  //if (GetControlSecurityManager.UserManagement <> nil) then
  //  GetControlSecurityManager.UserManagement:= nil;
  // *** Usermanagment ***
  UserMgmt:= TUserLevelUserManagement.Create(nil);
  // Create a authentication based Usermanagment
  ASchema:= TUsrLevelMgntSchema.Create(1, 100, 1, UserMgmt);
  { TODO  : Simplify this to avoid potential errors }
  with ASchema do begin
    UserList.Add(0,TUserWithLevelAccess.Create(0,'root','1','Main administrator',false, 1));
    UserList.Add(1,TUserWithLevelAccess.Create(1,'andi','2','A user',            false, 1));
    UserList.Add(2,TUserWithLevelAccess.Create(2,'user','3','Another user',      false, 10));
  end;
  // set the objects
  UserMgmt.UserMgnt:= ASchema;
  GetControlSecurityManager.UserManagement:= UserMgmt;
end;

end.

