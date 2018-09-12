unit PSECInterfaces;
{$I PSECinclude.inc}
{ *************************
  Interfaces
  for the PSEC-Project
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
  Classes, SysUtils;

type

  //: @name defines a interface between the security manager and secure controls.
  IPSECControlInterface = interface
    ['{7AD939E4-4EEA-4A47-AA15-885EE83B9041}']
    //: Gets the access code of the control.
    function GetControlSecurityCode:String;
    //: Clear the security of the control, making it unsecure.
    procedure MakeUnsecure;
    //: Enables/disables the control. @seealso(Enabled)
    procedure CanBeAccessed(a:Boolean);
  end;

  //: @name defines a interface between the security manager and secure controls.
  IPSECManager = interface
    ['{9CDED8DB-CF1C-4853-805B-B3687DD49847}']
    // Set the Securiytcode of the control
    procedure  SetControlSecurityCode(
                    var CurrentSecurityCode: String;
                    const NewSecurityCode: String;
                    aControl: IPSECControlInterface);
  end;

  //: @name defines a basically interface for the usermanagment.
  IPSECBasicUserManagment =  interface
    ['{80E18713-7638-4C58-B5EC-36F84D193423}']
    function OnlyDummy: integer;
    //: Return the user management schema (all users, groups and authorizations, if availables).
  //  function   GetUserMgnt:TUsrMgntSchema;
  //  //: Set the user management schema (all users, groups and authorizations, if availables).
  //  procedure  SetUserMgnt(AValue: TUsrMgntSchema);
  //  //Set the user managment interface
  //  function   GetUsrMgntInterface: TCustomUsrMgntInterface;
  //  //Set the user managment interface
  //  procedure  SetUsrMgntInterface(AValue: TCustomUsrMgntInterface);
  //  // Get or set the UserSchema
  //  property UserMgnt: TUsrMgntSchema read GetUserMgnt write SetUserMgnt;
  //  // Get or set the UserManagement Interface
  //  property UsrMgntInterface:TCustomUsrMgntInterface read GetUsrMgntInterface write SetUsrMgntInterface;
  end;

  IPSECUserLevelAccess = interface
    ['{C8D147D6-B7EB-416A-B516-CCF2CE9CCD38}']
    function GetUserLevel: Integer;
    procedure SetUserLevel(AValue: Integer);
    function Modified:Boolean;
    procedure ResetModified;
    property UserLevel:Integer read GetUserLevel write SetUserLevel;
  end;

  IUsrLevelMgntInterface = interface
    ['{F9FDD85F-54AB-4EC2-BD60-8567CA69AF40}']
    function AddUser(const UserLogin, UserDescription, PlainPassword:String;
                     const UsrLevel:Integer;
                     const Blocked:Boolean;
                     out   UID:Integer;
                     out   UsrObject:IPSECUserLevelAccess):Boolean;

    function DelUser(var UsrObject:IPSECUserLevelAccess):Boolean;

    function UpdateUser(var UsrObject:IPSECUserLevelAccess;
                        const UserDescription, PlainPassword:String;
                        const UsrLevel:Integer;
                        const Blocked:Boolean):Boolean;

    function BlockUser(var UsrObject:IPSECUserLevelAccess;
                       const Blocked:Boolean):Boolean;

    function ChangeUserPass(var UsrObject:IPSECUserLevelAccess;
                            const PlainPassword:String):Boolean;
  end;

  IPSECUserAuthAccess = interface
    ['{9EA04118-99D2-4A6E-A8FB-0CF507336198}']
    function GetUserAuth: String;
    procedure SetUserAuth(AValue: String);
    function Modified:Boolean;
    procedure ResetModified;
    property UserAuth:String read GetUserAuth write SetUserAuth;
  end;

  //IUsrAuthMgntInterface = interface
  //  ['{1892AB07-11D6-4F13-8FD2-C29C47B865DF}']
  //  function AddUser(const UserLogin, UserDescription, PlainPassword:String;
  //                   const UsrAuth:String;
  //                   const Blocked:Boolean;
  //                   out   UID:Integer;
  //                   out   UsrObject:IPSECUserAuthAccess):Boolean;
  //
  //  function DelUser(var UsrObject:IPSECUserAuthAccess):Boolean;
  //
  //  function UpdateUser(var UsrObject:IPSECUserAuthAccess;
  //                      const UserDescription, PlainPassword:String;
  //                      const UsrAuth:String;
  //                      const Blocked:Boolean):Boolean;
  //
  //  function BlockUser(var UsrObject:IPSECUserAuthAccess;
  //                     const Blocked:Boolean):Boolean;
  //
  //  function ChangeUserPass(var UsrObject:IPSECUserAuthAccess;
  //                          const PlainPassword:String):Boolean;
  //end;

  {Interface Basic Security functions
    eg. Login, Logout}
  IPSECBasicSecurity = interface
    ['{BF8B1906-65D5-40FF-BBA0-82B65015B9B7}']
    function   Login(Userlogin, Userpassword: String; var UID: Integer):Boolean;
    procedure  Logout;
    function   GetCurrentUserlogin:String;
    function   IsUserLoggedIn:Boolean;
  end;

implementation

end.

