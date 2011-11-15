Rem 
Rem ordplsut.sql
Rem 
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem 
Rem    NAME
Rem      ordplsut.sql - interMedia Code Wizard utility package
Rem 
Rem    DESCRIPTION
Rem      This package provides various utility functions for the interMedia 
Rem      Code Wizard for the PL/SQL Gateway, and for PL/SQL procedures created
Rem      by the Code Wizard.
Rem 
Rem    NOTES
Rem      See the interMedia Code Wizard readme document for installation
Rem      and usage instructions.
Rem 


------------------------------------------------------------------------------
--  Package specification.
------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ORDSYS.OrdPlsGwyUtil AUTHID CURRENT_USER AS

------------------------------------------------------------------------------
--  Procedure declarations
------------------------------------------------------------------------------

--
-- Public functions
-- 
FUNCTION cache_is_valid( last_update_time IN DATE ) RETURN BOOLEAN;
PROCEDURE set_last_modified( last_update_time IN DATE );
PROCEDURE resource_not_found( param_name IN VARCHAR2,
                              param_value IN VARCHAR2 );

--
-- Internal and utility functions used by the OrdPlsGwyCodeWizard package
--
FUNCTION http_to_oracle_date( http_date IN VARCHAR2 ) RETURN DATE;
FUNCTION oracle_to_http_date( ora_date IN DATE ) RETURN VARCHAR2;
PROCEDURE set_timezone( server_timezone IN VARCHAR2 DEFAULT NULL, 
                        server_gmtdiff IN NUMBER DEFAULT NULL );
PROCEDURE get_timezone( server_timezone OUT VARCHAR2, 
                        server_gmtdiff OUT NUMBER );
                       
------------------------------------------------------------------------------
--  Package constant declarations
------------------------------------------------------------------------------

http_status_ok           CONSTANT NUMBER(3) := 200;    -- OK
http_status_moved_perm   CONSTANT NUMBER(3) := 301;    -- Moved permanently
http_status_moved_temp   CONSTANT NUMBER(3) := 302;    -- Moved temporarily
http_status_see_other    CONSTANT NUMBER(3) := 303;    -- See other
http_status_not_modified CONSTANT NUMBER(3) := 304;    -- Not modified
http_status_not_found    CONSTANT NUMBER(3) := 404;    -- Not found

END OrdPlsGwyUtil;
/


------------------------------------------------------------------------------
--  Package body.
------------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY ORDSYS.OrdPlsGwyUtil AS

------------------------------------------------------------------------------
--  Package private constants
------------------------------------------------------------------------------
tz_package_name CONSTANT VARCHAR2( 30 ) := 'ORDSYS.OrdPlsGwyTZ';

LF CONSTANT VARCHAR2( 1 ) := chr( 10 );

------------------------------------------------------------------------------
--  Function name:
--      cache_is_valid
--
--  Description:
--      Return TRUE is resource in browser's cache is still valid.  
------------------------------------------------------------------------------
FUNCTION cache_is_valid( last_update_time IN DATE ) RETURN BOOLEAN
IS
  if_modified_since VARCHAR2( 100 );
BEGIN
  -- 
  -- 
  -- If there is a last-modified date associated with the data and if the 
  -- browser has sent an If-Modified-Since header, then convert the 
  -- if-modified date from GMT to the server's time zone and compare with 
  -- the modification date from the database. If the cache is still valid, 
  -- then return TRUE.
  --
  IF last_update_time IS NOT NULL
  THEN
    if_modified_since := owa_util.get_cgi_env( 'HTTP_IF_MODIFIED_SINCE' );
    IF if_modified_since IS NOT NULL
    THEN
      IF last_update_time <= http_to_oracle_date( if_modified_since )
      THEN
        RETURN TRUE;
      END IF;
    END IF;
  END IF;
    
  --
  -- In all other cases, return FALSE;
  --
  RETURN FALSE;
END cache_is_valid;


------------------------------------------------------------------------------
--  Function name:
--      set_last_modified
--
--  Description:
--      Sets Last-Modified HTTP header  
------------------------------------------------------------------------------
PROCEDURE set_last_modified( last_update_time IN DATE ) IS
BEGIN
  IF last_update_time IS NOT NULL
  THEN
    htp.print( 'Last-Modified: ' || oracle_to_http_date( last_update_time ) );
  END IF;
END set_last_modified;


------------------------------------------------------------------------------
--  Function name:
--      resource_not_found
--
--  Description:
--      Output a Not Found error page
------------------------------------------------------------------------------
PROCEDURE resource_not_found( param_name IN VARCHAR2,
                              param_value IN VARCHAR2 ) IS
BEGIN
  owa_util.status_line( 404, 'Not Found', FALSE );
  owa_util.mime_header( 'text/html' );
  htp.htmlOpen;
  htp.headOpen;
  htp.title( '404 Not Found' );
  htp.headClose;
  htp.bodyOpen;
  htp.header( 1, 'Not Found' );
  htp.print( 'The requested media <TT>' || 
             owa_util.get_cgi_env( 'SCRIPT_NAME' ) || 
             owa_util.get_cgi_env( 'PATH_INFO' ) ||  
             '?' || LOWER( param_name ) || '=' || param_value || 
             '</TT> was not found.' );
  htp.bodyClose;
  htp.htmlClose;
END;


------------------------------------------------------------------------------
--  Function name:
--      http_to_oracle_date
--
--  Description:
--      Convert an HTTP GMT-based date to an Oracle date based on the database 
--      server's time zone. HTTP format: Wednesday, 25 Mar 1998 18:21:24 GMT
------------------------------------------------------------------------------
FUNCTION http_to_oracle_date( http_date IN VARCHAR2 ) RETURN DATE
IS
  server_timezone VARCHAR2(3);
  server_gmtdiff NUMBER;
  char_date VARCHAR2( 64 );
  char_pos INTEGER;
  ora_date DATE;
BEGIN
  --
  -- Get timzezone information
  --
  get_timezone( server_timezone, server_gmtdiff );
  
  --
  -- Nothing to do if no input date
  --
  IF http_date IS NULL
  THEN
    --
    -- Return NULL if no input date.
    --
    RETURN NULL;
  ELSE
    -- 
    -- Start off with the original
    --
    char_date := http_date;

    --
    -- First strip off the "; length=NNN".
    --
    char_pos := INSTR( char_date, ';' );
    IF char_pos > 0
    THEN
        char_date := SUBSTR( char_date, 1, char_pos - 1 );
    END IF;

    --
    -- Convert to an Oracle date based on the possible formats:
    --   Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822/RFC 1123
    --   Sunday, 06-Nov-94 08:49:37 GMT ; RFC 850/RFC 1036
    --   Sun Nov  6 08:49:37 1994       ; ANSI C's asctime() format
    -- If it fails, raise an exception based on the standard format.
    --
    -- Note: Use RR date format for RFC 850/RFC 1036 to handle dates
    --       before 2000. See SQL reference manual for more information.
    --
    BEGIN
      ora_date := TO_DATE( char_date, 
                           'Dy, DD Mon YYYY HH24:MI:SS "GMT"',
                           'NLS_DATE_LANGUAGE = American' );
    EXCEPTION 
      WHEN OTHERS THEN 
        BEGIN 
          ora_date := TO_DATE( char_date, 
                               'Day, DD-Mon-RR HH24:MI:SS "GMT"',
                               'NLS_DATE_LANGUAGE = American' );
        EXCEPTION
          WHEN OTHERS THEN
            BEGIN 
              ora_date := TO_DATE( char_date, 
                                   'Dy Mon DD HH24:MI:SS YYYY',
                                   'NLS_DATE_LANGUAGE = American' );
            EXCEPTION
              WHEN OTHERS THEN
                BEGIN
                  ora_date := TO_DATE( char_date, 
                                       'Dy, DD Mon YYYY HH24:MI:SS "GMT"',
                                       'NLS_DATE_LANGUAGE = American' );
                EXCEPTION 
                  WHEN OTHERS THEN 
                    BEGIN
                      RAISE_APPLICATION_ERROR( 
                        -20000,
                        'HTTP date conversion error' || LF ||
                        'ORA-20000: HTTP date: ' || char_date || LF || 
                        SQLERRM );
                    END;
                END; 
            END;
        END;
    END;

    --
    -- Adjust to server's time zone
    --    
    IF server_gmtdiff IS NOT NULL
    THEN
      RETURN ora_date+(server_gmtdiff/24);
    ELSE
      RETURN NEW_TIME(ora_date,'GMT',server_timezone );
    END IF;
  END IF;
END http_to_oracle_date;


------------------------------------------------------------------------------
--  Function name:
--      oracle_to_http_date
--
--  Description:
--      Convert an Oracle date based on the database server's time zone to an
--      HTTP GMT-based date. Foe example:
--        Sun, 06 Nov 1994 08:49:37 GMT  ; RFC 822/RFC 1123

------------------------------------------------------------------------------
FUNCTION oracle_to_http_date( ora_date IN DATE ) RETURN VARCHAR2
IS
  server_timezone VARCHAR2(3);
  server_gmtdiff NUMBER;
  gmt_date DATE;
BEGIN
  --
  -- Get timzezone information
  --
  get_timezone( server_timezone, server_gmtdiff );

  --
  -- Nothing to do if no input date
  --  
  IF ora_date IS NULL
  THEN
    --
    -- Return NULL if no input date.
    --
    RETURN NULL;
  ELSE
    --
    -- Convert time to GMT, then format as per HTTP standard.
    --
    IF server_gmtdiff IS NOT NULL
    THEN
        gmt_date := ora_date-(server_gmtdiff/24);
    ELSE
        gmt_date := NEW_TIME( ora_date, server_timezone, 'GMT' );
    END IF;
    RETURN TO_CHAR( gmt_date, 
                    'Dy, DD Mon YYYY HH24:MI:SS "GMT"',
                    'NLS_DATE_LANGUAGE = American' );
  END IF;
END oracle_to_http_date;


------------------------------------------------------------------------------
--  Procedure name:
--      set_timezone
--
--  Description:
--       Sets the time zone information in the ORDPLSGWYTZ package by
--       creating or replacing the package.
------------------------------------------------------------------------------
PROCEDURE set_timezone( server_timezone IN VARCHAR2 DEFAULT NULL, 
                        server_gmtdiff IN NUMBER DEFAULT NULL )
IS
  pkg VARCHAR2( 1000 );
BEGIN
  --
  -- First create the package source
  --
  pkg := 'CREATE OR REPLACE PACKAGE ' || tz_package_name || ' AS' || LF ||
         '--' || LF ||
         '-- interMedia time zone information' || LF ||
         '--' || LF;
  IF server_timezone IS NOT NULL
  THEN
     pkg := pkg || 
       'server_timezone CONSTANT VARCHAR2(3) := ''' || server_timezone || ''';' || LF ||
       'server_gmtdiff CONSTANT NUMBER := NULL;' || LF;
  ELSIF server_gmtdiff IS NOT NULL
  THEN 
     pkg := pkg || 
       'server_timezone CONSTANT VARCHAR2(3) := NULL;' || LF || 
       'server_gmtdiff CONSTANT NUMBER := ' || server_gmtdiff || ';' || LF;
  ELSE
    raise_application_error( -20002, 'No timezone information specified' );
  END IF;
  pkg := pkg || 'END;' || LF;

  --
  -- Now create or replace the package in the database.
  --
  EXECUTE IMMEDIATE pkg;
  
  --
  -- Now grant access to public
  --
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || tz_package_name || ' TO PUBLIC';

END set_timezone;


------------------------------------------------------------------------------
--  Procedure name:
--      get_timezone
--
--  Description:
--       Gets the time zone information from the ORDPLSGWYTZ package.
------------------------------------------------------------------------------
PROCEDURE get_timezone( server_timezone OUT VARCHAR2, 
                        server_gmtdiff OUT NUMBER )
IS
BEGIN
  EXECUTE IMMEDIATE 'BEGIN ' ||
                    '  :tz := ' || tz_package_name || '.server_timezone; ' ||
                    '  :gmtdiff := ' || tz_package_name || '.server_gmtdiff; ' ||
                    'END;'
    USING OUT server_timezone, OUT server_gmtdiff;
EXCEPTION
  WHEN OTHERS THEN
    BEGIN
      RAISE_APPLICATION_ERROR( 
        -20001, 
        'interMedia time zone information not set' || LF ||
        'ORA-20001: see interMedia Code Wizard README for more information' || LF ||
        SQLERRM ); 
    END;
END get_timezone;


END OrdPlsGwyUtil;
/

