SET TAB OFF
SET ECHO OFF
SET SHOWMODE OFF

prompt ===========================
prompt Setting up the eContentPark Schema ...
prompt ===========================
prompt

SELECT TO_CHAR(systimestamp, 'YYYY.MM.DD HH:MI:SS')  FROM dual returning systimestamp into t;

prompt Please provide below the absolute path to the INCOMING folder of the Administration
prompt (This is the folder at econtentpark/admin/incoming)
prompt
accept diradminin char format a90 prompt "Absolute path to the ADMIN INCOMING directory (C:\Inetpub\wwwroot\econtentpark\admin\incoming): "

prompt ===========================
prompt Database fully setup for econtentPark!
prompt Please point your browser now to your eContentPark installation
prompt Example: http://127.0.0.1/econtentpark/admin/
prompt ===========================
