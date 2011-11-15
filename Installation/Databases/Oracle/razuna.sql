--------------------------------------------------------------------------------
-- Script for creating default database setup for Razuna
--
-- You need to execute this script as sys user and sysdba
--
--
--------------------------------------------------------------------------------

SET TAB OFF;
SET ECHO OFF;
SET FEEDBACK OFF;
SET SHOWMODE OFF;

spool razuna

-- We can use this if we call this script like @scriptname <thevalue>
-- define theuser = &1

--------------------------------------------------------------------------------
-- CREATE THE SCHEMA (USER)
--------------------------------------------------------------------------------

prompt ===========================
prompt Setting up the Razuna Schema ...
prompt

-- We can also let the user enter a name
accept theuser char format a30 prompt "Enter the schema name (enter razuna or your custom schema): "

-- Let user enter password
accept thepass char format a30 prompt "Enter the password for the above schema: "

drop user &theuser cascade;

create user &theuser identified by &thepass;

grant connect, resource, ctxapp, create any directory, drop any directory, create trigger, create procedure to &theuser;
grant execute on ctx_ddl to &theuser;

prompt Razuna Schema done
prompt ===========================
prompt

--------------------------------------------------------------------------------
-- CREATE THE STORED PROCEDURES
--------------------------------------------------------------------------------

prompt ===========================
prompt Stored Procedures setup ...

@@insert_procedures.sql &theuser

prompt Stored Procedures setup done
prompt ===========================
prompt

commit;

--------------------------------------------------------------------------------
-- CREATE OUR OWN LEXER IN THE SCHEMA
-- connect as user
--------------------------------------------------------------------------------

prompt Connecting to the schema
prompt ===========================
prompt

connect &theuser/&thepass;

EXEC CTX_DDL.CREATE_PREFERENCE ('razuna_lexer', 'BASIC_LEXER');
EXEC CTX_DDL.SET_ATTRIBUTE ('razuna_lexer', 'MIXED_CASE', 'NO');

commit;

prompt ===========================
prompt Database fully setup for Razuna!
prompt Please point your browser now to your Razuna installation
prompt Example: http://www.mydomain.com/razuna/admin/
prompt You can now exit the sqlplus app.
prompt ===========================

spool off;

-- Exit the sqlplus app
-- exit;
