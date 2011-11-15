Rem
Rem ordplsui.sql
Rem
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem
Rem    NAME
Rem      ordplsui.sql - interMedia Code Wizard utility package installation.
Rem
Rem    DESCRIPTION
Rem      Installs the utility package for the interMedia Code Wizard for 
Rem      the PL/SQL Gateway.
Rem
Rem    NOTES
Rem      You must connect as ORDSYS prior to running this script.
Rem

-- Create utility package
@@ordplsut.sql

-- Grant execute permission and create public synonym
GRANT EXECUTE ON ORDSYS.OrdPlsGwyUtil TO PUBLIC;
CREATE PUBLIC SYNONYM OrdPlsGwyUtil FOR ORDSYS.OrdPlsGwyUtil;

