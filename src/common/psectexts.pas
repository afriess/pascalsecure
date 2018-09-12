unit PSECTexts;

{$I PSECinclude.inc}

interface

uses
  Classes, SysUtils;

resourcestring
  SAccessDenied                         = 'Access denied!';
  SUserHasNotAllowedToAccessObject      = 'Access denied!'+LineEnding+'User "%s" isn''t allowed to access object protected by security code "%s"';
  SNoUserLoggedInToAccessObject         = 'Access denied!'+LineEnding+'No user logged in to access object protected by security code "%s". Did you forget to do Login?';

  SSecurityCodeIsInUseYet               = 'Security code still being used!';
  SInvalidUserManagementComponent       = 'Invalid user manager component';
  SUserManagementIsSet                  = 'User management component already set!';
  SControlSecurityManagerStillBeingUsed = 'Control security manager still being used. Maybe some control forget the unregister on their destructor?';

  SInvalidUserSchemaLevels              = 'Invalid user management range. Maximum value should be greater than minimum value.'+LineEnding+'Minimum=%d'+LineEnding+'Maximum=%d';
  SUnassignedUsrMgntIntf                = 'Unassigned user management interface!'+LineEnding+'Impossible to display login or user management dialogs.';

  SUnassignedUserSchema                 =  'Unassigned user schema (user schema object=nil)!';
  SUnknownUserMgntSchema                =  'Unknown user management schema class!';

  SInvalidUserMgntSchema                = 'Invalid user management!';

implementation

end.

