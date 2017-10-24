unit security.manager.SecureControlInterface;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, fgl,
  security.manager.basic_user_management;

type

  //: @name defines a interface between the security manager and secure controls.
  ISecureControlInterface = interface
    ['{A950009B-A2E7-4ED8-BDB3-B6E191D184FB}']
    //: Gets the access code of the control.
    function GetControlSecurityCode:String;
    //: Clear the security of the control, making it unsecure.
    procedure MakeUnsecure;
    //: Enables/disables the control. @seealso(Enabled)
    procedure CanBeAccessed(a:Boolean);
  end;

implementation

end.

