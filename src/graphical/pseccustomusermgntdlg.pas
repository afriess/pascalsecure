unit PSECcustomusermgntdlg;
{$I PSECinclude.inc}
{ *************************
  Base for a UserManager
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
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ButtonPanel,
  ActnList;

type
  TPSECCustomUsrMgnt = class(TForm)
    ActionList1: TActionList;
    ButtonPanel1: TButtonPanel;
    ImageList1: TImageList;
  private

  public

  end;


implementation

{$R *.lfm}

end.

