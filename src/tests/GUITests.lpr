program GUITests;

{$mode objfpc}{$H+}

uses
  Interfaces, Forms, GuiTestRunner, sysutils, testpseccontrolsmanager, psecsecuremanager,
  TestPSECSecureManager, psecsecurelevelmanager, psecsecureauthmanager,
  psecuserschema, TestPSECAuthSecureManager, testpsecauthuserschema,
  MockSecureControl, TestPSECUserAuthComplete, PSECAuthUserManager;

{$R *.res}

{$if declared(UseHeapTrace)}
const
  co_heaptrc = 'heaptrace.txt';
{$endif}

begin
  // If you want to show heaptrc report dialog only if there were leaks
  //   in your application, then put this command somewhere
  //   in your main project source file:
  {$if declared(UseHeapTrace)}
    GlobalSkipIfNoLeaks := true; // supported as of debugger version 3.1.1
    if FileExists(co_heaptrc) then
        DeleteFile(co_heaptrc);
    SetHeapTraceOutput(co_heaptrc); // supported as of debugger version 3.1.1
    //   HaltOnError := false;             // dont halt a the end of the programm
  {$endif}
  Application.Initialize;
  Application.CreateForm(TGuiTestRunner, TestRunner);
  Application.Run;
end.

