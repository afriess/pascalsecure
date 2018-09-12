unit PSECExceptions;

{$I PSECinclude.inc}

interface

uses
  Classes, SysUtils,
  PSECTexts;

type
  PSECException = class(Exception);

  { PSECSystemAccessDenied }

  PSECSystemAccessDenied = class(PSECException)
  public
    constructor Create(Token:UTF8String);
  end;

  { PSECMangerAlreadySet }

  PSECMangerAlreadySet = class(PSECException)
  public
    constructor Create;
  end;

  { PSECManagerStillBeingUsed }

  EControlSecurityManagerStillBeingUsed = class(PSECException)
  public
    constructor Create;
  end;

  { EInvalidUserManagementComponent }

  EInvalidUserManagementComponent = class(PSECException)
  public
    constructor Create;
  end;

  { EUserManagementIsSet }

  EUserManagementIsSet = class(PSECException)
  public
    constructor Create;
  end;

  { PSECCodeIsInUseYet }

  PSECCodeIsInUseYet = class(PSECException)
  public
    constructor Create;
  end;

  EInvalidLevelRanges = class(PSECException)
  public
    constructor Create(aMinLevel, aMaxLevel:Integer);
  end;

  EUnassignedUsrMgntIntf = class(PSECException)
  public
    constructor Create;
  end;

  ENilUserSchema = class(PSECException)
  public
    constructor Create;
  end;

  EUnknownUserMgntSchema = class(PSECException)
  public
    constructor Create;
  end;

  EInvalidUsrMgntSchema = class(PSECException)
    constructor Create;
  end;

implementation


{ EInvalidUsrMgntSchema }

constructor EInvalidUsrMgntSchema.Create;
begin
  inherited Create(SInvalidUserMgntSchema);
end;

{ EUnknownUserMgntSchema }

constructor EUnknownUserMgntSchema.Create;
begin
  inherited Create(SUnknownUserMgntSchema);
end;

{ ENilUserSchema }

constructor ENilUserSchema.Create;
begin
  inherited Create(SUnassignedUserSchema);
end;

{ EUnassignedUsrMgntIntf }

constructor EUnassignedUsrMgntIntf.Create;
begin
  inherited Create(SUnassignedUsrMgntIntf);
end;

{ EInvalidLevelRanges }

constructor EInvalidLevelRanges.Create(aMinLevel, aMaxLevel: Integer);
begin
  inherited Create(Format(SInvalidUserSchemaLevels,[aMinLevel,aMaxLevel]));
end;

{ PSECCodeIsInUseYet }

constructor PSECCodeIsInUseYet.Create;
begin
  inherited Create(SSecurityCodeIsInUseYet);
end;

{ EUserManagementIsSet }

constructor EUserManagementIsSet.Create;
begin
  inherited Create(SUserManagementIsSet);
end;

{ EInvalidUserManagementComponent }

constructor EInvalidUserManagementComponent.Create;
begin
  inherited Create(SInvalidUserManagementComponent);
end;

{ PSECManagerStillBeingUsed }

constructor EControlSecurityManagerStillBeingUsed.Create;
begin
  inherited Create(SControlSecurityManagerStillBeingUsed);
end;

{ PSECMangerAlreadySet }

constructor PSECMangerAlreadySet.Create;
begin
  inherited Create(SUserManagementIsSet);
end;

{ PSECSystemAccessDenied }

constructor PSECSystemAccessDenied.Create(Token: UTF8String);
begin
  { TODO -oaf : if it is clear where the manager resides i can work here }
  //if GetControlSecurityManager.HasUserLoggedIn then
  //  inherited Create(Format(SUserHasNotAllowedToAccessObject,[GetControlSecurityManager.GetCurrentUserlogin, Token]))
  //else
    inherited Create(Format(SNoUserLoggedInToAccessObject,[Token]));
end;

end.

