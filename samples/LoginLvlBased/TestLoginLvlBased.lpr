program TestLoginLvlBased;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms,
  {$ifdef debug_secure}
  LazLogger,
  {$endif}
  sysutils, frmmainlvl, security.manager.controls_manager
  { you can add units after this }
  ;

{$R *.res}

// Debugging start with --debug-log=<file> on commandline

{$if declared(UseHeapTrace)}
const
  co_heaptrc = 'heaptrace.trc';
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
  {$ifdef debug_secure}
  DebugLnEnter('****************************************************************');
  DebugLn('Starting...');
  {$endif}
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TFormAuthBased, FormAuthBased);
  Application.Run;
  {$ifdef debug_secure}
  DebugLnExit('...Finishing');
  {$endif}
end.

