unit PSECSecureManager;
{$I PSECinclude.inc}
{ *************************
  (Basic)SecureManager
  This is the absolute basic and common implementation of the SecureManager. The
  specialied functionallity must be written in the children, like level based or
  authentication based security.
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
  Classes, SysUtils,
  PSECInterfaces;

type
  { TPSECCustomBasicSecureManager }

  TPSECCustomBasicSecureManager = class(TComponent)
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

  { TPSECBasicSecureManager }
  TPSECBasicSecureManager = class(TPSECCustomBasicSecureManager)
  end;


implementation

{$ifdef debug_secure}
uses
  LazLogger;
{$endif}

constructor TPSECCustomBasicSecureManager.Create(AOwner: TComponent);
begin
  {$ifdef debug_secure}
    Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});
    if assigned(AOwner) then
      Debugln('  owner:'+AOwner.Name);
  {$endif}
  inherited Create(AOwner);
end;

destructor TPSECCustomBasicSecureManager.Destroy;
begin
  {$ifdef debug_secure}Debugln({$I %FILE%} + '->' +{$I %CURRENTROUTINE%} + ' ' +{$I %LINE%});{$endif}
  inherited Destroy;
end;


end.

