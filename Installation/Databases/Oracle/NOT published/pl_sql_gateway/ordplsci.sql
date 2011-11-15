Rem
Rem ordplsci.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      ordplsci.sql - interMedia Code Wizard installation script.
Rem
Rem    DESCRIPTION
Rem      Installs the interMedia Code Wizard for the PL/SQL Gateway.
Rem
Rem    NOTES
Rem      You must connect as ORDSYS prior to running this script.
Rem

-- Install utility package
@@ordplsui.sql

-- Create code wizard package
@@ordplscw.sql

-- Grant execute permission and create public synonym
GRANT EXECUTE ON ORDSYS.OrdPlsGwyCodeWizard TO PUBLIC;
CREATE PUBLIC SYNONYM OrdPlsGwyCodeWizard FOR ORDSYS.OrdPlsGwyCodeWizard;
CREATE PUBLIC SYNONYM OrdCWPkg FOR ORDSYS.OrdPlsGwyCodeWizard;

