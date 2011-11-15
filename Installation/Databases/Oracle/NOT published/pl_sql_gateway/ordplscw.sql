Rem 
Rem ordplscw.sql
Rem 
Rem  Copyright (c) Oracle Corporation 2001. All Rights Reserved.
Rem 
Rem    NAME
Rem      ordplscw.sql - interMedia Code Wizard
Rem 
Rem    DESCRIPTION
Rem      The interMedia Code Wizard for the PL/SQL Gateway lets you create 
Rem      PL/SQL procedures for the PL/SQL Gateway to upload and retrieve 
Rem      media data stored in a database using the interMedia object types.  
Rem 
Rem    NOTES
Rem      See the interMedia Code Wizard readme document for installation
Rem      and usage instructions.
Rem 


---------------------------------------------------------------------------
--  Package specification.
---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE ORDSYS.Ordplsgwycodewizard AUTHID CURRENT_USER AS

---------------------------------------------------------------------------
--  Type declarations
---------------------------------------------------------------------------
TYPE vc2_array IS TABLE OF VARCHAR2(128) INDEX BY BINARY_INTEGER;
TYPE dad_array IS TABLE OF VARCHAR2(64);
TYPE user_array IS TABLE OF VARCHAR2(30);

---------------------------------------------------------------------------
--  External procedure declarations
---------------------------------------------------------------------------
PROCEDURE menu;
PROCEDURE dispatch_main_menu( selection IN VARCHAR2 DEFAULT NULL,
                              selected_dad IN VARCHAR2 DEFAULT NULL,
                              form_action IN VARCHAR2 );

PROCEDURE set_dads( delete_dads IN vc2_array,
                    add_dad_name IN VARCHAR2 DEFAULT NULL,
                    add_user_name IN VARCHAR2 DEFAULT NULL,
                    form_action IN VARCHAR2 ); 

PROCEDURE set_timezone( timezone_selector IN VARCHAR2 DEFAULT NULL,
                        server_timezone IN VARCHAR2 DEFAULT NULL,
                        server_gmtdiff IN VARCHAR2 DEFAULT NULL,
                        form_action IN VARCHAR2 );

PROCEDURE code_wizard_dispatch( upload_download IN VARCHAR2,
                                table_name IN VARCHAR2 DEFAULT NULL,
                                procedure_type IN VARCHAR2 DEFAULT NULL,
                                form_action IN VARCHAR2 );

PROCEDURE validate_download_columns( procedure_type IN VARCHAR2,
                                     table_name IN VARCHAR2,
                                     selected_column IN VARCHAR2,
                                     selected_keycol IN VARCHAR2,
                                     form_action IN VARCHAR2 );
PROCEDURE validate_download_names( procedure_type IN VARCHAR2,
                                   table_name IN VARCHAR2,
                                   selected_column IN VARCHAR2,
                                   selected_keycol IN VARCHAR2,
                                   procedure_name IN VARCHAR2,
                                   parameter_name IN VARCHAR2,
                                   selected_function IN VARCHAR2,
                                   form_action IN VARCHAR2 );
PROCEDURE generate_download_procedure( procedure_type IN VARCHAR2,
                                       table_name IN VARCHAR2,
                                       selected_column IN VARCHAR2,
                                       selected_keycol IN VARCHAR2,
                                       procedure_name IN VARCHAR2,
                                       parameter_name IN VARCHAR2,
                                       selected_function IN VARCHAR2,
                                       form_action IN VARCHAR2 );
PROCEDURE generate_download_done( procedure_type IN VARCHAR2,
                                  table_name IN VARCHAR2,
                                  selected_column IN VARCHAR2,
                                  selected_keycol IN VARCHAR2,
                                  procedure_name IN VARCHAR2,
                                  parameter_name IN VARCHAR2,
                                  selected_function IN VARCHAR2,
                                  form_action IN VARCHAR2 );
PROCEDURE view_download_source( procedure_type IN VARCHAR2,
                                table_name IN VARCHAR2,
                                selected_column IN VARCHAR2,
                                selected_keycol IN VARCHAR2,
                                procedure_name IN VARCHAR2,
                                parameter_name IN VARCHAR2 );

PROCEDURE validate_document_table( procedure_type IN VARCHAR2,
                                   table_name IN VARCHAR2,
                                   doctable_action IN VARCHAR2,
                                   doctable_name IN VARCHAR2 DEFAULT NULL,
                                   newdoctable_name IN VARCHAR2 DEFAULT NULL,
                                   form_action IN VARCHAR2 );
PROCEDURE validate_upload_columns( procedure_type IN VARCHAR2,
                                   table_name IN VARCHAR2,
                                   doctable_name IN VARCHAR2,
                                   selected_columns IN vc2_array,
                                   selected_keycol IN VARCHAR2,
                                   table_access IN VARCHAR2,
                                   form_action IN VARCHAR2 );
PROCEDURE validate_upload_proc_name( procedure_type IN VARCHAR2,
                                     table_name IN VARCHAR2,
                                     doctable_name IN VARCHAR2,
                                     selected_columns IN vc2_array,
                                     selected_keycol IN VARCHAR2,
                                     table_access IN VARCHAR2,
                                     additional_columns IN vc2_array,
                                     procedure_name IN VARCHAR2,
                                     selected_function IN VARCHAR2,
                                     form_action IN VARCHAR2 );
PROCEDURE generate_upload_procedure( procedure_type IN VARCHAR2,
                                     table_name IN VARCHAR2,
                                     doctable_name IN VARCHAR2,
                                     selected_columns IN vc2_array,
                                     selected_keycol IN VARCHAR2,
                                     additional_columns IN vc2_array,
                                     table_access IN VARCHAR2,
                                     procedure_name IN VARCHAR2,
                                     selected_function IN VARCHAR2,
                                     form_action IN VARCHAR2 );
PROCEDURE generate_upload_done( procedure_type IN VARCHAR2,
                                table_name IN VARCHAR2,
                                doctable_name IN VARCHAR2,
                                selected_columns IN vc2_array,
                                selected_keycol IN VARCHAR2,
                                additional_columns IN vc2_array,
                                table_access IN VARCHAR2,
                                procedure_name IN VARCHAR2,
                                selected_function IN VARCHAR2,
                                form_action IN VARCHAR2 );
PROCEDURE view_upload_source( procedure_type IN VARCHAR2,
                              table_name IN VARCHAR2,
                              doctable_name IN VARCHAR2,
                              selected_columns IN vc2_array,
                              selected_keycol IN VARCHAR2,
                              additional_columns IN vc2_array,
                              table_access IN VARCHAR2,
                              procedure_name IN VARCHAR2 );
PROCEDURE view_upload_form( procedure_type IN VARCHAR2,
                            table_name IN VARCHAR2,
                            doctable_name IN VARCHAR2,
                            selected_columns IN vc2_array,
                            selected_keycol IN VARCHAR2,
                            additional_columns IN vc2_array,
                            table_access IN VARCHAR2,
                            procedure_name IN VARCHAR2,
                            test_dad_name IN VARCHAR2 );

PROCEDURE view_compiled_source( procedure_name IN VARCHAR2 );

END Ordplsgwycodewizard;
/


---------------------------------------------------------------------------
--  Package body.
---------------------------------------------------------------------------
CREATE OR REPLACE PACKAGE BODY ORDSYS.Ordplsgwycodewizard AS

---------------------------------------------------------------------------
--  Package private variables needed for procedure argument defaulting
---------------------------------------------------------------------------
empty_array vc2_array;

---------------------------------------------------------------------------
--  Local functions and procedures
---------------------------------------------------------------------------
PROCEDURE select_dads( add_dad_name IN VARCHAR2 DEFAULT NULL,
                       add_user_name IN VARCHAR2 DEFAULT NULL,
                       error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE get_authed_dads( out_dad_list OUT vc2_array,
                           out_user_list OUT vc2_array );
PROCEDURE set_authed_dads( dad_list IN vc2_array,
                           user_list IN vc2_array );

FUNCTION check_dad RETURN BOOLEAN;
FUNCTION check_user( user_name IN VARCHAR2,
                     error_message IN VARCHAR2 ) RETURN BOOLEAN;

PROCEDURE select_timezone( timezone_selector IN VARCHAR2 DEFAULT NULL,
                           server_timezone IN VARCHAR2 DEFAULT NULL,
                           server_gmtdiff IN VARCHAR2 DEFAULT NULL,
                           error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE show_tz_button( standard_timezone IN VARCHAR2,
                          daylight_timezone IN VARCHAR2,
                          timezone_description IN VARCHAR2,
                          server_timezone IN VARCHAR2,
                          timezone_checked IN OUT VARCHAR2 );

PROCEDURE code_wizard( upload_download IN VARCHAR2 DEFAULT NULL,
                       table_name IN VARCHAR2 DEFAULT NULL,
                       procedure_type IN VARCHAR2 DEFAULT NULL,
                       error_message IN VARCHAR2 DEFAULT NULL );

PROCEDURE select_download_columns( procedure_type IN VARCHAR2 DEFAULT NULL,
                                   table_name IN VARCHAR2 DEFAULT NULL,
                                   selected_column IN VARCHAR2 DEFAULT NULL,
                                   selected_keycol IN VARCHAR2 DEFAULT NULL,
                                   error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE select_download_names( procedure_type IN VARCHAR2 DEFAULT NULL,
                                 table_name IN VARCHAR2 DEFAULT NULL,
                                 selected_column IN VARCHAR2 DEFAULT NULL,
                                 selected_keycol IN VARCHAR2 DEFAULT NULL,
                                 procedure_name IN VARCHAR2 DEFAULT NULL,
                                 parameter_name IN VARCHAR2 DEFAULT NULL,
                                 selected_function IN VARCHAR2 DEFAULT NULL,
                                 error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE display_download_summary( procedure_type IN VARCHAR2,
                                    table_name IN VARCHAR2,
                                    selected_column IN VARCHAR2,
                                    selected_keycol IN VARCHAR2,
                                    procedure_name IN VARCHAR2,
                                    parameter_name IN VARCHAR2,
                                    selected_function IN VARCHAR2 );
PROCEDURE generate_download_proc_source( procedure_type IN VARCHAR2,
                                         table_name IN VARCHAR2,
                                         selected_column IN VARCHAR2,
                                         selected_keycol IN VARCHAR2,
                                         procedure_name IN VARCHAR2,
                                         parameter_name IN VARCHAR2 );

PROCEDURE select_document_table( procedure_type IN VARCHAR2 DEFAULT NULL,
                                 table_name IN VARCHAR2 DEFAULT NULL,
                                 doctable_action IN VARCHAR2 DEFAULT NULL,
                                 doctable_name IN VARCHAR2 DEFAULT NULL,
                                 newdoctable_name IN VARCHAR2 DEFAULT NULL,
                                 error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE select_upload_columns( procedure_type IN VARCHAR2 DEFAULT NULL,
                                 table_name IN VARCHAR2 DEFAULT NULL,
                                 doctable_name IN VARCHAR2 DEFAULT NULL,
                                 selected_columns IN vc2_array,
                                 selected_keycol IN VARCHAR2 DEFAULT NULL,
                                 table_access IN VARCHAR2 DEFAULT NULL,
                                 error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE select_upload_proc_name( procedure_type IN VARCHAR2 DEFAULT NULL,
                                   table_name IN VARCHAR2 DEFAULT NULL,
                                   doctable_name IN VARCHAR2 DEFAULT NULL,
                                   selected_columns IN vc2_array,
                                   selected_keycol IN VARCHAR2 DEFAULT NULL,
                                   table_access IN VARCHAR2 DEFAULT NULL,
                                   additional_columns IN vc2_array,
                                   procedure_name IN VARCHAR2 DEFAULT NULL,
                                   selected_function IN VARCHAR2 DEFAULT NULL,
                                   error_message IN VARCHAR2 DEFAULT NULL );
PROCEDURE display_upload_summary( procedure_type IN VARCHAR2 ,
                                  table_name IN VARCHAR2,
                                  doctable_name IN VARCHAR2,
                                  selected_columns IN vc2_array,
                                  selected_keycol IN VARCHAR2,
                                  additional_columns IN vc2_array,
                                  table_access IN VARCHAR2,
                                  procedure_name IN VARCHAR2,
                                  selected_function IN VARCHAR2 );
PROCEDURE generate_upload_proc_source( procedure_type IN VARCHAR2,
                                       table_name IN VARCHAR2,
                                       doctable_name IN VARCHAR2,
                                       selected_columns IN vc2_array,
                                       selected_keycol IN VARCHAR2,
                                       additional_columns IN vc2_array,
                                       table_access IN VARCHAR2,
                                       procedure_name IN VARCHAR2 );
PROCEDURE generate_upload_proc_sig( procedure_type IN VARCHAR2,
                                    selected_columns IN vc2_array,
                                    selected_keycol IN VARCHAR2,
                                    additional_columns IN vc2_array,
                                    procedure_name IN VARCHAR2,
                                    package_spec IN BOOLEAN DEFAULT FALSE );
PROCEDURE wrtsrc( sql_string IN VARCHAR2 );
PROCEDURE wrtsrcln( sql_string IN VARCHAR2 DEFAULT '' );
                                   
PROCEDURE print_download_context( procedure_type IN VARCHAR2 DEFAULT NULL,
                                  table_name IN VARCHAR2 DEFAULT NULL,
                                  selected_column IN VARCHAR2 DEFAULT NULL,
                                  selected_keycol IN VARCHAR2 DEFAULT NULL,
                                  procedure_name IN VARCHAR2 DEFAULT NULL,
                                  parameter_name IN VARCHAR2 DEFAULT NULL,
                                  selected_function IN VARCHAR2 DEFAULT NULL );
PROCEDURE print_upload_context( procedure_type IN VARCHAR2 DEFAULT NULL,
                                table_name IN VARCHAR2 DEFAULT NULL,
                                doctable_name IN VARCHAR2 DEFAULT NULL,
                                selected_columns IN vc2_array DEFAULT empty_array,
                                selected_keycol IN VARCHAR2 DEFAULT NULL,
                                additional_columns IN vc2_array DEFAULT empty_array,
                                table_access IN VARCHAR2 DEFAULT NULL,
                                procedure_name IN VARCHAR2 DEFAULT NULL,
                                selected_function IN VARCHAR2 DEFAULT NULL );
PROCEDURE print_context_data( field_name IN VARCHAR2,
                              field_value IN VARCHAR2 );
PROCEDURE print_context_data_array( field_name IN VARCHAR2,
                                    field_value_array IN vc2_array );

PROCEDURE show_compilation_errors( procedure_name IN VARCHAR2 );

PROCEDURE print_compiled_source_button( procedure_name IN VARCHAR2 );

PROCEDURE print_page_header;
PROCEDURE print_page_trailer;
PROCEDURE print_message( message IN VARCHAR2,
                         ruler IN BOOLEAN DEFAULT FALSE,
                         end_paragraph IN BOOLEAN DEFAULT FALSE );
PROCEDURE print_error_message( message IN VARCHAR2 );
PROCEDURE html_p_open;
PROCEDURE html_p_close;
PROCEDURE html_hr;
PROCEDURE html_br( num_breaks IN NUMBER DEFAULT 1 );
PROCEDURE html_table_open( cborder IN VARCHAR2 DEFAULT '0',
                           ccellspacing IN VARCHAR2 DEFAULT '0',
                           csummary IN VARCHAR2 DEFAULT NULL,
                           blayout IN BOOLEAN DEFAULT FALSE,
                           cscope IN VARCHAR2 DEFAULT NULL,
                           cattributes IN VARCHAR2 DEFAULT NULL );
PROCEDURE html_table_close;
FUNCTION htmlf_label( cname IN VARCHAR2, 
                      ctext IN VARCHAR2 ) RETURN VARCHAR2;
PROCEDURE htmlp_label( cname IN VARCHAR2, 
                       ctext IN VARCHAR2 );
FUNCTION htmlf_attr( cname IN VARCHAR2, 
                     cvalue IN VARCHAR2 ) RETURN VARCHAR2;
FUNCTION htmlf_id( cname IN VARCHAR2 ) RETURN VARCHAR2;
FUNCTION htmlf_for( cname IN VARCHAR2 ) RETURN VARCHAR2;
FUNCTION htmlf_tt( cdata IN VARCHAR2 ) RETURN VARCHAR2;
FUNCTION htmlf_text( cvalue IN VARCHAR2,
                     csize IN VARCHAR2 DEFAULT NULL,
                     ccolor IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
PROCEDURE htmlp_text( cvalue IN VARCHAR2,
                      csize IN VARCHAR2 DEFAULT NULL,
                      ccolor IN VARCHAR2 DEFAULT NULL );
FUNCTION htmlf_form_text_field( cname IN VARCHAR2,
                                clabel IN VARCHAR2 DEFAULT NULL,
                                csize IN VARCHAR2 DEFAULT NULL,
                                cmaxlength IN VARCHAR2 DEFAULT NULL,
                                cvalue IN VARCHAR2 DEFAULT NULL )
  RETURN VARCHAR2;
PROCEDURE htmlp_form_text_field( cname IN VARCHAR2,
                                 clabel IN VARCHAR2 DEFAULT NULL,
                                 csize IN VARCHAR2 DEFAULT NULL,
                                 cmaxlength IN VARCHAR2 DEFAULT NULL,
                                 cvalue IN VARCHAR2 DEFAULT NULL );
FUNCTION htmlf_form_radio( cname IN VARCHAR2,
                           cvalue IN VARCHAR2,
                           clabel IN VARCHAR2,
                           cchecked IN OUT VARCHAR2,
                           cdefault IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
PROCEDURE htmlp_form_radio( cname IN VARCHAR2,
                            cvalue IN VARCHAR2,
                            clabel IN VARCHAR2,
                            cchecked IN OUT VARCHAR2,
                            cdefault IN VARCHAR2 DEFAULT NULL );
FUNCTION htmlf_form_checkbox( cname IN VARCHAR2,
                              cvalue IN VARCHAR2,
                              clabel IN VARCHAR2,
                              cchecked IN OUT VARCHAR2,
                              cdefaults IN vc2_array DEFAULT empty_array ) 
  RETURN VARCHAR2;
PROCEDURE htmlp_form_checkbox( cname IN VARCHAR2,
                               cvalue IN VARCHAR2,
                               clabel IN VARCHAR2,
                               cchecked IN OUT VARCHAR2,
                               cdefaults IN vc2_array DEFAULT empty_array );
PROCEDURE htmlp_form_select_open( cname IN VARCHAR2, 
                                  clabel IN VARCHAR2 );
PROCEDURE htmlp_form_select_option( cvalue IN VARCHAR2,
                                    cselected IN VARCHAR2 );
PROCEDURE htmlp_form_select_close; 

PROCEDURE form_open( proc_name IN VARCHAR2,
                     request_method IN VARCHAR2 DEFAULT 'POST', 
                     target IN VARCHAR2 DEFAULT NULL );
PROCEDURE form_close( menu_bar IN BOOLEAN DEFAULT TRUE,
                      done_button IN BOOLEAN DEFAULT FALSE,
                      cancel_button IN BOOLEAN DEFAULT FALSE,
                      logout_button IN BOOLEAN DEFAULT FALSE,
                      back_button IN BOOLEAN DEFAULT FALSE,
                      next_button IN BOOLEAN DEFAULT FALSE,
                      finish_button IN BOOLEAN DEFAULT FALSE,
                      apply_button IN BOOLEAN DEFAULT FALSE,
                      step_num IN INTEGER DEFAULT 0,
                      num_steps IN INTEGER DEFAULT 0 );

FUNCTION get_checked( checked_flag IN OUT VARCHAR2,
                      form_value IN VARCHAR2 DEFAULT NULL,
                      default_value IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;
FUNCTION get_checked_array( checked_flag IN OUT VARCHAR2,
                            form_value IN VARCHAR2 DEFAULT NULL,
                            default_values IN vc2_array DEFAULT empty_array )
    RETURN VARCHAR2;

FUNCTION package_url( proc_name IN VARCHAR2 ) RETURN VARCHAR2;
PROCEDURE extract_column_name_and_info( column_name_info IN VARCHAR2,
                                        column_name OUT VARCHAR2,
                                        column_info OUT VARCHAR2 );
FUNCTION sql_ident( prefix IN VARCHAR2 DEFAULT '',
                    sql_name IN VARCHAR2,
                    postfix IN VARCHAR2 DEFAULT '' ) RETURN VARCHAR2;

---------------------------------------------------------------------------
--  Package private constants
---------------------------------------------------------------------------
wizard_title CONSTANT VARCHAR2( 64 ) := 'interMedia Code Wizard for the PL/SQL Gateway';
wizard_name CONSTANT VARCHAR2( 64 ) := '<I>inter</I>Media Code Wizard for the PL/SQL Gateway';
package_name CONSTANT VARCHAR2( 40 ) := 'ORDSYS.OrdPlsGwyCodeWizard';
package_synonym CONSTANT VARCHAR2( 40 ) := 'OrdCWPkg';
dad_pkg_name CONSTANT VARCHAR2( 40 ) := 'ORDSYS.OrdPlsGwyAuthedDADs';
admin_dad_name CONSTANT VARCHAR2( 10 ) := 'ORDCWADMIN'; 
admin_user_name CONSTANT VARCHAR2( 10 ) := 'ORDSYS'; 

num_download_steps CONSTANT INTEGER := 4;
num_upload_steps CONSTANT INTEGER := 5;

color_white CONSTANT VARCHAR2( 10 ) := '#ffffff';
color_blue CONSTANT VARCHAR2( 10 ) := '#336699';
color_cream CONSTANT VARCHAR2( 10 ) := '#f7f7e7';
color_brown CONSTANT VARCHAR2( 10 ) := '#663300';

AMPERSAND CONSTANT VARCHAR2( 1 ) := CHR( 38 );
NBSP CONSTANT VARCHAR2( 6 ) := AMPERSAND || 'nbsp;';
AMPLT CONSTANT VARCHAR2( 6 ) := AMPERSAND || 'lt;';
AMPGT CONSTANT VARCHAR2( 6 ) := AMPERSAND || 'gt;';
LF CONSTANT VARCHAR2( 1 ) := CHR( 10 );
IN_ CONSTANT VARCHAR2( 10 ) := 'in_';
LOCAL_  CONSTANT VARCHAR2( 10 ) := 'local_';
CTX_ CONSTANT VARCHAR2( 10 ) := '_ctx';

---------------------------------------------------------------------------
--  Package private variables
---------------------------------------------------------------------------
source_buf VARCHAR2( 32000 );

---------------------------------------------------------------------------
--  Cursors
---------------------------------------------------------------------------
CURSOR key_cursor( table_name_arg VARCHAR2 ) IS
    SELECT ucc.column_name, DECODE( ac.constraint_type, 'P', 'Primary key',
                                                        'U', 'Unique' ) info
      FROM user_cons_columns ucc, all_constraints ac
      WHERE ucc.constraint_name = ac.constraint_name AND
            ac.owner = USER AND
            ac.table_name = table_name_arg AND
            ( ac.constraint_type = 'P' OR ac.constraint_type = 'U' );

CURSOR nonkey_cursor( table_name_arg VARCHAR2 ) IS
    SELECT utc.column_name, utc.column_id
    FROM user_tab_columns utc
    WHERE utc.table_name = table_name_arg AND
          utc.data_type IN ( 'CHAR', 'VARCHAR', 'VARCHAR2',
                             'NCHAR', 'NVARCHAR', 'NVARCHAR2',
                             'NUMBER', 'DATE' ) AND
          utc.column_name NOT IN
          ( SELECT ucc.column_name
              FROM user_cons_columns ucc, all_constraints ac
              WHERE ucc.constraint_name = ac.constraint_name AND
                    ac.owner = USER AND ac.table_name = table_name_arg AND
                    ( ac.constraint_type = 'P' OR ac.constraint_type = 'U' ) )
    ORDER BY utc.column_id;

CURSOR mediacol_cursor( table_name_arg VARCHAR2 ) IS
    SELECT column_name, data_type, column_id FROM user_tab_columns utc
      WHERE table_name = table_name_arg AND
            data_type_owner = 'ORDSYS' AND
            data_type IN ( 'ORDIMAGE', 'ORDAUDIO', 'ORDVIDEO', 'ORDDOC' )
      ORDER BY column_id;

---------------------------------------------------------------------------
--  PL/SQL procedure templates and other SQL templates
---------------------------------------------------------------------------

download_sa_proc_template CONSTANT VARCHAR2( 500 ) :=
  'CREATE OR REPLACE PROCEDURE %procedure-name%' ||
  ' ( %keycol-param% IN VARCHAR2 )' || LF ||
  'AS' || LF;

download_pkg_proc_template CONSTANT VARCHAR2( 500 ) :=
  '-- add to package: ' || LF ||
  LF ||
  'PROCEDURE %procedure-name%' ||
  ' ( %keycol-param% IN VARCHAR2 );' || LF ||
  LF ||
  '-- add to package body:' || LF ||
  LF ||
  'PROCEDURE %procedure-name%' ||
  ' ( %keycol-param% IN VARCHAR2 )' || LF ||
  'IS' || LF;

download_proc_body_template CONSTANT VARCHAR2( 3000 ) :=
  '  localObject ORDSYS.%column-type%;' || LF ||
  '  localBlob  BLOB;' || LF ||
  '  localBfile BFILE;' || LF ||
  '  httpStatus NUMBER;' || LF ||
  '  lastModDate VARCHAR2(256);' || LF ||
  LF ||
  'BEGIN' || LF ||
  '  --' || LF ||
  '  -- Retrieve the object from the database into a local object.' || LF ||
  '  --' || LF ||
  '  BEGIN' || LF ||
  '    SELECT mtbl.%column-name% INTO localObject FROM %table-name% mtbl ' || LF ||
  '      WHERE mtbl.%keycol-name% = %keycol-param%;' || LF ||
  '  EXCEPTION' || LF ||
  '    WHEN NO_DATA_FOUND THEN' || LF ||
  '      ordplsgwyutil.resource_not_found( ''%keycol-param%'', %keycol-param% );' || LF ||
  '      RETURN;' || LF ||
  '  END;' || LF ||
  LF ||
  '  --' || LF ||
  '  -- Check update time if browser sent If-Modified-Since header' || LF ||
  '  --' || LF ||
  '  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )' || LF ||
  '  THEN' || LF ||
  '    owa_util.status_line( ordplsgwyutil.http_status_not_modified );' || LF ||
  '    RETURN;' || LF ||
  '  END IF;' || LF ||
  LF ||
  '  --' || LF ||
  '  -- Figure out where the image is.' || LF ||
  '  --' || LF ||
  '  IF localObject.isLocal() THEN' || LF ||
  '    --' || LF ||
  '    -- Data is stored locally in the localData BLOB attribute' || LF ||
  '    --' || LF ||
  '    localBlob := localObject.getContent();' || LF ||
  '    owa_util.mime_header( localObject.getMimeType(), FALSE );' || LF ||
  '    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );' || LF ||
  '    owa_util.http_header_close();' || LF ||
  '    IF owa_util.get_cgi_env( ''REQUEST_METHOD'' ) <> ''HEAD'' THEN' || LF ||
  '      wpg_docload.download_file( localBlob );' || LF ||
  '    END IF;' || LF ||
  LF ||
  '  ELSIF UPPER( localObject.getSourceType() ) = ''FILE'' THEN' || LF ||
  '    --' || LF ||
  '    -- Data is stored as a file from which ORDSource creates ' || LF ||
  '    -- a BFILE.' || LF ||
  '    --' || LF ||
  '    localBfile  := localObject.getBFILE();' || LF ||
  '    owa_util.mime_header( localObject.getMimeType(), FALSE );' || LF ||
  '    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );' || LF ||
  '    owa_util.http_header_close();' || LF ||
  '    IF owa_util.get_cgi_env( ''REQUEST_METHOD'' ) <> ''HEAD'' THEN' || LF ||
  '      wpg_docload.download_file( localBfile );' || LF ||
  '    END IF;' || LF ||
  LF ||
  '  ELSIF UPPER( localObject.getSourceType() ) = ''HTTP'' THEN' || LF ||
  '    --' || LF ||
  '    -- The image is referenced as an HTTP entity, so we have to ' || LF ||
  '    -- redirect the client to the URL which ORDSource provides.' || LF ||
  '    --' || LF ||
  '    owa_util.redirect_url( localObject.getSource() );' || LF ||
  LF ||
  '  ELSE' || LF ||
  '    --' || LF ||
  '    -- The image is stored in an application-specific data' || LF ||
  '    -- source type for which no default action is available.' || LF ||
  '    --' || LF ||
  '    NULL;' || LF ||
  '  END IF;' || LF ||
  'END %procedure-name%;';

upload_table_template CONSTANT VARCHAR2( 1000 ) :=
  'CREATE TABLE %document-table-name%' || LF ||
  '  ( name           VARCHAR2(256) UNIQUE NOT NULL,' || LF ||
  '    mime_type      VARCHAR2(128),' || LF ||
  '    doc_size       NUMBER,' || LF ||
  '    dad_charset    VARCHAR2(128),' || LF ||
  '    last_updated   DATE,' || LF ||
  '    content_type   VARCHAR2(128),' || LF ||
  '    blob_content   BLOB )';

store_media_template CONSTANT VARCHAR2( 1000 ) :=
  '  --' || LF ||
  '  -- Store media data for column %media-col-arg-name%' || LF ||
  '  --' || LF ||
  '  IF %media-col-arg-name% IS NOT NULL' || LF ||
  '  THEN' || LF ||
  '    SELECT dtbl.doc_size, dtbl.mime_type, dtbl.blob_content INTO' || LF ||
  '           upload_size, upload_mimetype, upload_blob' || LF ||
  '      FROM %doctable-name% dtbl WHERE dtbl.name = %media-col-arg-name%;' || LF ||
  '    IF upload_size > 0' || LF ||
  '    THEN' || LF ||
  '      dbms_lob.copy( %media-col-local-name%.source.localData, ' || LF ||
  '                     upload_blob, ' || LF ||
  '                     upload_size );' || LF ||
  '      %media-col-local-name%.setLocal();' || LF ||
  '      BEGIN' || LF ||
  '        %media-col-local-name%.setProperties(%set-props-args%);' || LF ||
  '      EXCEPTION' || LF ||
  '        WHEN OTHERS THEN' || LF ||
  '%set-content-length%' ||
  '          %media-col-local-name%.mimeType := upload_mimetype;' || LF ||
  '      END;' || LF ||
  '    END IF;' || LF ||
  '    DELETE FROM %doctable-name% dtbl WHERE dtbl.name = %media-col-arg-name%;' || LF ||
  '  END IF;' || LF ||
  LF;

upload_done_message CONSTANT VARCHAR2( 1000 ) :=
  '  --' || LF ||
  '  -- Display template completion message' || LF ||
  '  --' || LF ||
  '  htp.print( ''<html>'' );' || LF ||
  '  htp.print( ''<title>interMedia Code Wizard: Template Upload Procedure</title>'' );' || LF ||
  '  htp.print( ''<body>'' );' || LF ||
  '  htp.print( ''<h2><i>inter</i>Media Code Wizard: Template Upload Procedure</h2>'' );' || LF ||
  '  htp.print( ''Media uploaded successfully.'' );' || LF ||
  '  htp.print( ''</body>'' );' || LF ||
  '  htp.print( ''</html>'' );' || LF;

in_varchar2 CONSTANT VARCHAR2( 20 )      := ' IN VARCHAR2';
in_varchar2_null CONSTANT VARCHAR2( 30 ) := ' IN VARCHAR2 DEFAULT NULL';


---------------------------------------------------------------------------
--  Name:
--      menu
--
--  Description:
--      Main entry procedure to the code wizard.
---------------------------------------------------------------------------
PROCEDURE menu
IS
  dad_list vc2_array;
  user_list vc2_array;
  this_dad VARCHAR2( 128 );
  default_dad VARCHAR2( 64 );
  checked VARCHAR2( 10 );
  num_br INTEGER;
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Output common page header
  --
  print_page_header;
  
  --
  -- Tell them what we're doing
  --
  print_message( 'Main menu', ruler=>TRUE );

  --
  -- Display current DAD and schema names
  --
  this_dad := UPPER( owa_util.get_cgi_env( 'DAD_NAME' ) ); 
  get_authed_dads( dad_list, user_list );
  html_p_open;
  html_table_open( blayout=>TRUE, cscope=>'row' );
  htp.tableRowOpen;
  htp.tableData( cvalue=>htmlf_text( cvalue=>'Current DAD: ',
                                     csize=>'+1', ccolor=>color_blue ), 
                 cattributes=>'SCOPE="row"' );
  htp.tableData( cvalue=>this_dad, 
                 cattributes=>'SCOPE="row"' );
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData( cvalue=>htmlf_text( cvalue=>'Current schema: ',
                                     csize=>'+1', ccolor=>color_blue ), 
                 cattributes=>'SCOPE="row"' );
  htp.tableData( cvalue=>USER, 
                 cattributes=>'SCOPE="row"' );
  htp.tableRowClose;
  html_table_close;
  html_p_close;

  --
  -- Present tool options
  --
  html_p_open;
  form_open( 'dispatch_main_menu', request_method=>'GET' );
  htp.print( 'Select the required function, then click the <B>Next</B> button.' );
  htp.ulistOpen;
  checked := 'checked';
  htmlp_form_radio( cname=>'selection',
                    cvalue=>'download_code_wizard',
                    clabel=>'Create media retrieval procedure',
                    cchecked=>checked );
  htp.br;
  htmlp_form_radio( cname=>'selection',
                    cvalue=>'upload_code_wizard',
                    clabel=>'Create media upload procedure',
                    cchecked=>checked );
  
  --
  -- Present DAD options, if there's more than one DAD.
  --
  num_br := 2;
  IF dad_list.COUNT > 1
  THEN
    htp.br;
    htp.br;
    htmlp_form_radio( cname=>'selection',
                      cvalue=>'change_dad',
                      clabel=>'Change DAD',
                      cchecked=>checked );
    htp.ulistOpen;
    
    --
    -- Choose the DAD selected by default.
    --
    FOR i IN 1..dad_list.COUNT
    LOOP
      IF dad_list( i ) <> this_dad
      THEN
        default_dad := dad_list( i );
        EXIT;
      END IF; 
    END LOOP;
    
    --
    -- Display options
    --
    checked := NULL;
    FOR i IN 1..dad_list.COUNT
    LOOP
      IF i > 1
      THEN
        htp.br;
      END IF;
      htmlp_form_radio( cname=>'selected_dad',
                        cvalue=>dad_list( i ),
                        clabel=>'Change to ' || dad_list( i ),
                        cchecked=>checked,
                        cdefault=>default_dad );
    END LOOP;
    htp.ulistClose;
    num_br := 1;
  END IF;
  
  --
  -- Present admin user options
  --
  IF USER = admin_user_name
  THEN
    html_br( num_br );
    num_br := 2;
    htmlp_form_radio( cname=>'selection',
                      cvalue=>'dad_authorization',
                      clabel=>'DAD authorization',
                      cchecked=>checked );
    htp.br;
    htmlp_form_radio( cname=>'selection',
                      cvalue=>'timezone_management',
                      clabel=>'Time zone management',
                      cchecked=>checked );
  END IF;
  
  --
  -- Present logout option 
  --
  html_br( num_br );
  htmlp_form_radio( cname=>'selection',
                    cvalue=>'logout',
                    clabel=>'Logout',
                    cchecked=>checked );
  htp.ulistClose;
  html_p_close;

  --
  -- End of form
  --
  form_close( next_button=>TRUE );

  --
  -- Output common page trailer
  --
  print_page_trailer;
END menu;


---------------------------------------------------------------------------
--  Name:
--      dispatch_main_menu
--
--  Description:
--      Dispatch to selected tool
---------------------------------------------------------------------------
PROCEDURE dispatch_main_menu( selection IN VARCHAR2 DEFAULT NULL,
                              selected_dad IN VARCHAR2 DEFAULT NULL,
                              form_action IN VARCHAR2 )
IS
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Go straight to main menu if form action is Cancel.
  --
  IF form_action = 'Cancel'
  THEN
    menu;
    RETURN;
  END IF;
  
  --
  -- Dispatch based on selection.
  --
  IF selection = 'download_code_wizard'
  THEN
    code_wizard( 'download' );
    RETURN;
  ELSIF selection = 'upload_code_wizard'
  THEN
    code_wizard( 'upload' );
    RETURN;
  ELSIF selection = 'change_dad'
  THEN
    owa_util.redirect_url( owa_util.get_cgi_env( 'SCRIPT_PREFIX' ) || '/' || 
                           LOWER( selected_dad ) || '/' || 
                           package_synonym || '.menu' ); 
    RETURN;
  ELSIF selection = 'timezone_management'
  THEN
    select_timezone;
    RETURN;
  ELSIF selection = 'dad_authorization'
  THEN
    select_dads;
    RETURN;
  ELSIF selection = 'logout'
  THEN
    owa_util.redirect_url( owa_util.get_cgi_env( 'SCRIPT_NAME' ) || 
                           '/logmeoff' ); 
    RETURN;
  END IF;

  --
  -- Invalid selection or no selection specified
  --
  print_page_header;
  print_error_message( 'Invalid selection or no selection specified' );
  print_page_trailer;
END dispatch_main_menu;


---------------------------------------------------------------------------
--  Name:
--      select_dads
--
--  Description:
--      Select DADs for use with code wizard - add new or delete existing.
---------------------------------------------------------------------------
PROCEDURE select_dads( add_dad_name IN VARCHAR2 DEFAULT NULL,
                       add_user_name IN VARCHAR2 DEFAULT NULL,
                       error_message IN VARCHAR2 DEFAULT NULL )
IS
  dad_list vc2_array;
  user_list vc2_array;
  checked VARCHAR2( 10 ) := NULL;
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Authorize DADs for use with the ' || wizard_name, ruler=>TRUE );
  
  --
  -- Must be logged in as admin user to do this.
  --
  IF NOT check_user( admin_user_name, 
                     'Please log in as ' || admin_user_name || ' to authorize DADs' )
  THEN
    RETURN;
  END IF;

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Start form
  --
  form_open( 'set_dads' );
  
  --
  -- Get current list of authorized DADs
  --
  get_authed_dads( dad_list, user_list );

  --
  -- Display current DADs, with delete option for all but ORDCWADMIN
  --
  html_p_open;
  htp.print( 'The following table list the DADs and users currently authorized' );
  htp.print( 'to use the ' || wizard_name || '. To delete a DAD, check the' );
  htp.print( 'corresponding checkbox. Note that the code wizard administration' );
  htp.print( 'DAD, ' || htmlf_tt( admin_dad_name ) || ', cannot be deleted.' );
  html_p_close;
  htp.ulistOpen;
  htp.formHidden( cname=>'delete_dads', cvalue=>'dummy' );
  html_table_open( csummary=>'Table containing list of authorized DADs',
                   ccellspacing=>'5' );
  htp.tableRowOpen;
  htp.tableHeader( 'DAD name', cattributes=>'SCOPE="col" ALIGN="left"' );
  htp.tableHeader( 'User name', cattributes=>'SCOPE="col" ALIGN="left"' );
  htp.tableHeader( 'Delete', cattributes=>'SCOPE="col" ALIGN="left"' );
  htp.tableRowClose;
  FOR i IN 1..dad_list.COUNT
  LOOP
    htp.tableRowOpen;
    htp.tableData( htmlf_tt( dad_list( i ) ), cattributes=>'SCOPE="col"' );
    htp.tableData( htmlf_tt( user_list( i ) ), cattributes=>'SCOPE="col"' );
    IF LOWER( dad_list( i ) ) = LOWER( admin_dad_name )
    THEN
      htp.tableData( '<BR>' );
    ELSE
      htp.tableData( htmlf_form_checkbox( cname=>'delete_dads',
                                          cvalue=>dad_list( i ),
                                          clabel=>'Check to delete',
                                          cchecked=>checked ),
                     cattributes=>'SCOPE="col"' );
    END IF;
    htp.tableRowClose;
  END LOOP;
  html_table_close;
  htp.ulistClose;

  --
  -- Allow addition of new DAD
  --
  htp.print( 'Enter a DAD name and user name below to authorize a DAD for use' );
  htp.print( ' with the ' || wizard_name || '.' );
  htp.ulistOpen;
  html_table_open( blayout=>TRUE, cscope=>'row' );
  htp.tableRowOpen;
  htp.tableData( cvalue=>htmlf_label( 'add_dad_name', 'DAD name: ' ), 
                 cattributes=>'SCOPE="row"' );
  htp.tableData( htmlf_form_text_field( cname=>'add_dad_name',
                                        cvalue=>add_dad_name,
                                        csize=>'20',
                                        cmaxlength=>'64' ) );
  htp.tableRowClose;
  htp.tableRowOpen;
  htp.tableData( cvalue=>htmlf_label( 'add_user_name', 'User name: ' ), 
                 cattributes=>'SCOPE="row"' );
  htp.tableData( htmlf_form_text_field( cname=>'add_user_name',
                                        cvalue=>add_user_name,
                                        csize=>'20',
                                        cmaxlength=>'30' ) );
  htp.tableRowClose;
  html_table_close;
  htp.ulistClose;

  --
  -- Just Cancel and Apply Buttons.
  --
  form_close( cancel_button=>TRUE, apply_button=>TRUE );
  
  --
  -- Output common page trailer
  --
  print_page_trailer;
END select_dads;


---------------------------------------------------------------------------
--  Name:
--      set_dads
--
--  Description:
--      Set DADs: either create new or delete existing.
---------------------------------------------------------------------------
PROCEDURE set_dads( delete_dads IN vc2_array,
                    add_dad_name IN VARCHAR2 DEFAULT NULL,
                    add_user_name IN VARCHAR2 DEFAULT NULL,
                    form_action IN VARCHAR2 )
IS
  dad_list vc2_array;
  user_list vc2_array;
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Must be logged in as admin user to do this.
  --
  IF NOT check_user( admin_user_name,
                     'Please log in as ' || admin_user_name || ' to authorize DADs' )
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel' OR form_action = 'Done'  
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_dads;
    RETURN;
  END IF;
  
  --
  -- Get current DAD list.
  --
  get_authed_dads( dad_list, user_list );
  
  --
  -- Delete specified DADs.
  --
  FOR i IN 2..delete_dads.COUNT
  LOOP
    FOR j IN 1..dad_list.COUNT
    LOOP
      IF delete_dads( i ) = dad_list( j )
      THEN
        dad_list( j ) := NULL;
        user_list( j ) := NULL;
        EXIT;
      END IF;
    END LOOP;
  END LOOP;
    
  --
  -- Add new DAD.
  --
  IF add_dad_name IS NOT NULL OR add_user_name IS NOT NULL
  THEN
    IF add_dad_name IS NULL OR add_user_name IS NULL
    THEN
      select_dads( add_dad_name=>add_dad_name, 
                   add_user_name=>add_user_name, 
                   error_message=>'Missing DAD or user name; please enter both' );
      RETURN; 
    END IF;
    FOR i IN 1..dad_list.COUNT
    LOOP
      IF UPPER( add_dad_name ) = dad_list( i )
      THEN
        select_dads( add_dad_name=>add_dad_name, 
                     add_user_name=>add_user_name, 
                     error_message=>'Duplicate DAD name not allowed' );
        RETURN;
      END IF;
    END LOOP;
    dad_list( dad_list.COUNT + 1 ) := UPPER( add_dad_name ); 
    user_list( user_list.COUNT + 1 ) := UPPER( add_user_name ); 
  END IF;
  
  --
  -- Create/replace auth'ed DADs package
  --
  set_authed_dads( dad_list, user_list );
  get_authed_dads( dad_list, user_list );
  
  --
  -- Display completion screen, using this procedure to handle form
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'List of authorized DADs updated', ruler=>TRUE );

  --
  -- Display current DADs
  --
  html_p_open;
  htp.print( 'The following DADs are now authorized to use the ' );
  htp.print( wizard_name || '.' );
  html_p_close;
  htp.ulistOpen;
  html_table_open( csummary=>'Table containing list of authorized DADs',
                   ccellspacing=>'2' );
  htp.tableRowOpen;
  htp.tableHeader( 'DAD name', cattributes=>'SCOPE="col"' );
  htp.tableHeader( 'User name', cattributes=>'SCOPE="col"' );
  htp.tableRowClose;
  FOR i IN 1..dad_list.COUNT
  LOOP
    htp.tableRowOpen;
    IF dad_list( i ) IS NOT NULL
    THEN
      htp.tableData( htmlf_tt( dad_list( i ) ), cattributes=>'SCOPE="col"' );
      htp.tableData( htmlf_tt( user_list( i ) ), cattributes=>'SCOPE="col"' );
    END IF;
    htp.tableRowClose;
  END LOOP;
  html_table_close;
  htp.ulistClose;

  --
  -- Just Done and Back Buttons.
  --    
  form_open( 'set_dads' );
  htp.formHidden( cname=>'delete_dads', cvalue=>'dummy' );
  form_close( done_button=>TRUE, back_button=>TRUE );

  --
  -- Output common page trailer
  --
  print_page_trailer;
  
END set_dads;


---------------------------------------------------------------------------
--  Name:
--      get_authed_dads
--
--  Description:
--      Read list of authorized DADs from OrdPlsGwyDADList package.
---------------------------------------------------------------------------
PROCEDURE get_authed_dads( out_dad_list OUT vc2_array,
                           out_user_list OUT vc2_array )
IS
  num_dads NUMBER;
  dad_list vc2_array;
  user_list vc2_array;
BEGIN
  BEGIN
    EXECUTE IMMEDIATE 
        'BEGIN ' ||
        '  :num_dads := ' || dad_pkg_name || '.authed_dads.COUNT; ' ||
        'END;'
      USING OUT num_dads;
    FOR i IN 1..num_dads
    LOOP
      EXECUTE IMMEDIATE 
          'BEGIN ' ||
          '  :dad_name := ' || dad_pkg_name || '.authed_dads( :dad_num ); ' ||
          '  :user_name := ' || dad_pkg_name || '.authed_users( :dad_num ); ' ||
          'END;'
        USING OUT dad_list( i ), IN i, OUT user_list( i );
    END LOOP;
  EXCEPTION
    WHEN OTHERS THEN
      BEGIN
        dad_list( 1 ) := admin_dad_name;
        user_list( 1 ) := admin_user_name;
      END;
  END;
  out_dad_list := dad_list;
  out_user_list := user_list;
END get_authed_dads;


---------------------------------------------------------------------------
--  Name:
--      set_authed_dads
--
--  Description:
--      Create OrdPlsGwyDADList package with list of authorized DADs.
---------------------------------------------------------------------------
PROCEDURE set_authed_dads( dad_list IN vc2_array,
                           user_list IN vc2_array )
IS
  pkg VARCHAR2( 4000 );
  sep VARCHAR2( 2 ); 
BEGIN
  --
  -- First create the package source
  --
  pkg := 'CREATE OR REPLACE PACKAGE ' || dad_pkg_name || ' AS' || LF ||
         '--' || LF ||
         '-- DADs authorized for use with interMedia Code Wizard' || LF ||
         '--' || LF ||
         'authed_dads ' || package_name || '.dad_array' || ' := ' || 
                                           package_name || '.dad_array' || '(';
  sep := ' ';
  FOR i IN 1..dad_list.COUNT
  LOOP
    IF dad_list( i ) IS NOT NULL
    THEN
      pkg := pkg || sep || '''' || UPPER( dad_list( i ) ) || '''';
      sep := ', ';
    END IF;
  END LOOP;
  pkg := pkg || ' ); ' || LF;
  pkg := pkg || 'authed_users ' || package_name || '.user_array' || ' := ' || 
                                        package_name || '.user_array' || '(';
  sep := ' ';
  FOR i IN 1..user_list.COUNT
  LOOP
    IF user_list( i ) IS NOT NULL
    THEN
      pkg := pkg || sep || '''' || UPPER( user_list( i ) ) || '''';
      sep := ', ';
    END IF;
  END LOOP;
  pkg := pkg || ' ); ' || LF;
  pkg := pkg || 'END;' || LF;

  --
  -- Now create or replace the package in the database.
  --
  EXECUTE IMMEDIATE pkg;
  
  --
  -- Now grant access to public
  --
  EXECUTE IMMEDIATE 'GRANT EXECUTE ON ' || dad_pkg_name || ' TO PUBLIC';

END set_authed_dads;


---------------------------------------------------------------------------
--  Name:
--      check_dad
--
--  Description:
--      Verify that the current DAD is authorized for use
---------------------------------------------------------------------------
FUNCTION check_dad RETURN BOOLEAN
IS
  dad_list vc2_array;
  user_list vc2_array;
  this_dad VARCHAR2( 128 );
  dad_found BOOLEAN;
BEGIN
  --
  -- Get list of authorized DADs, then see if this DAD is authorized.
  --
  get_authed_dads( dad_list, user_list );
  this_dad := UPPER( owa_util.get_cgi_env( 'DAD_NAME' ) );
  dad_found := FALSE;
  FOR i IN 1..dad_list.COUNT
  LOOP
    IF dad_list( i ) = this_dad  
    THEN
      dad_found := TRUE;
      IF user_list( i ) = USER
      THEN
        RETURN TRUE;
      ELSE
        EXIT;
      END IF;
    END IF;
  END LOOP;
    
  --
  -- DAD not authorized.
  --
  print_page_header;
  html_p_open;
  IF dad_found
  THEN
    htp.print( 'The ' || htmlf_tt( this_dad ) || ' DAD is not authorized for' );
    htp.print( 'use with the ' || wizard_name || ' using the' ); 
    htp.print( htmlf_tt( USER ) || ' user.' );
  ELSE    
    htp.print( 'The ' || htmlf_tt( this_dad ) || ' DAD is not authorized for' );
    htp.print( 'use with the ' || wizard_name || '.' );
  END IF;    
  html_p_close;
  html_p_open;
  htp.print( 'See the ' || wizard_name || ' README document' );
  htp.print( 'for more information on authorizing DADs and' );
  htp.print( 'users for use with the ' || wizard_name || '.' );    
  html_p_close;
  html_p_open;
  htp.print( 'Click the <B>Logout</B> button to log off (clear HTTP' );
  htp.print( 'authentication information).' );
  html_p_close;

  --
  -- Display form with a logout option
  --
  htp.formOpen( curl=>owa_util.get_owa_service_path || 'logmeoff',
                cmethod=>'GET' );
  form_close( logout_button=>TRUE );

  --
  -- Output common page trailer
  --
  print_page_trailer;
  


  RETURN FALSE;

END check_dad;


---------------------------------------------------------------------------
--  Name:
--      check_user
--
--  Description:
--      Check for a required user name
---------------------------------------------------------------------------
FUNCTION check_user( user_name IN VARCHAR2,
                     error_message IN VARCHAR2 ) RETURN BOOLEAN
IS
BEGIN
  IF USER = user_name
  THEN
    RETURN TRUE;
  ELSE
    print_error_message( error_message );
    form_open( 'dispatch_main_menu' );
    form_close( cancel_button=>TRUE );
    print_page_trailer;
    RETURN FALSE;
  END IF;
END check_user;


---------------------------------------------------------------------------
--  Name:
--      select_timezone
--
--  Description:
--      Select the server's time zone, either an actual server-supported
--      time zone or an offset from GMT.
---------------------------------------------------------------------------
PROCEDURE select_timezone( timezone_selector IN VARCHAR2 DEFAULT NULL,
                           server_timezone IN VARCHAR2 DEFAULT NULL,
                           server_gmtdiff IN VARCHAR2 DEFAULT NULL,
                           error_message IN VARCHAR2 DEFAULT NULL )
IS
  local_selector VARCHAR2( 10 );
  local_timezone VARCHAR2( 5 );
  local_gmtdiff VARCHAR2( 10 );
  selector_checked VARCHAR2( 10 );
  timezone_checked VARCHAR2( 10 );
  display_current_setting BOOLEAN := FALSE;
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Set server time zone information', ruler=>TRUE );
  
  --
  -- Must be logged in as admin user to do this.
  --
  IF NOT check_user( admin_user_name,
                     'Please log in as ' || admin_user_name || 
                     ' to set time zone information' )
  THEN
    RETURN;
  END IF;

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Get default values. Always use a default value of GMT for timezone 
  -- radio buttons.
  --
  IF timezone_selector IS NULL
  THEN
    BEGIN
      Ordplsgwyutil.get_timezone( local_timezone, local_gmtdiff );
      display_current_setting := TRUE;
      IF local_timezone IS NOT NULL
      THEN
        local_selector := 'timezone';
      ELSE
        local_selector := 'gmtdiff';
        local_timezone := 'GMT';
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        local_selector := 'timezone';
        local_timezone := 'GMT';
        local_gmtdiff := NULL;
    END;
  ELSE
    display_current_setting := TRUE;
    local_selector := timezone_selector;
    local_timezone := server_timezone;
    local_gmtdiff := server_gmtdiff;
  END IF;

  --
  -- Start form
  --
  form_open( 'set_timezone' );
  
  html_p_open;
  htp.print( 'The database server''s time zone must be specified for media' );
  htp.print( 'retrieval procedures to handle HTTP date headers correctly.' );
  html_p_close;
  html_p_open;
  htp.print( '<B>Note:</B>' || NBSP || NBSP || NBSP );
  htp.print( 'For a database that resides in a time zone that adjusts for' );
  htp.print( 'daylight savings time, the recommended approach is to' );
  htp.print( 'specify the timezone identifier or offset from GMT for the' );
  htp.print( 'time zone''s daylight savings time. Using this approach,' );
  htp.print( 'there is no need to make semi-annual time zone changes.' );
  htp.print( 'Otherwise, for a database that resides in a time zone that' );
  htp.print( 'never adjusts for daylight savings time, simply specify the' );
  htp.print( 'time zone''s offset from GMT.' );
  htp.print( 'See the ' || wizard_name || ' README document' );
  htp.print( 'for more information on specifying the time zone.' );
  html_p_close;

  --
  -- Display current setting
  --
  IF display_current_setting
  THEN
    html_p_open;
    htp.prn( 'The time zone is currently set to: ' );
    IF local_selector = 'timezone'
    THEN
      htp.print( htmlf_tt( local_timezone ) );
    ELSE
      IF local_gmtdiff >= 0
      THEN
        htp.print( htmlf_tt( 'GMT+' || local_gmtdiff ) );
      ELSE
        htp.print( htmlf_tt( 'GMT' || local_gmtdiff ) );
      END IF; 
    END IF;
    html_p_close;
  END IF;

  --
  -- Display some instructions.
  --
  html_p_open;
  htp.print( 'Choose either to use a time zone identifier supported by the' );
  htp.print( 'database server or to specify the offset in hours from GMT.' );
  html_p_close;

  --
  -- Supported time zone identifiers 
  --
  htp.uListOpen;
  selector_checked := 'checked';
  htmlp_form_radio( cname=>'timezone_selector',
                    cvalue=>'timezone',
                    clabel=>'Use time zone identifier',
                    cchecked=>selector_checked,
                    cdefault=>local_selector );
  htp.uListOpen;
  htp.br;
  htp.print( 'Select a time zone identifier from one of the following' );
  htp.print( 'time zones.' );
  htp.br;
  htp.br;
  html_table_open( blayout=>TRUE, ccellspacing=>'3' );
  htp.tableRowOpen;
  htp.tableHeader( 'Standard<BR>Time',
                   cattributes=>'VALIGN="top" ALIGN="center" SCOPE="col"' );  
  htp.tableHeader( 'Daylight<BR>Time',
                   cattributes=>'VALIGN="top" ALIGN="center" SCOPE="col"'  );  
  htp.tableHeader( 'Description',
                   cattributes=>'VALIGN="top" ALIGN="left" SCOPE="col"'  );  
  htp.tableRowClose;  
  show_tz_button( 'AST', 'ADT', 'Atlantic Standard or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'BST', 'BDT', 'Bering Standard or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'CST', 'CDT', 'Central Standard or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'EST', 'EDT', 'Eastern Standard or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'GMT',  NULL, 'Greenwich Mean Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'HST', 'HDT', 'Alaska-Hawaii Standard Time or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'MST', 'MDT', 'Mountain Standard or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'NST',  NULL, 'Newfoundland Standard Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'PST', 'PDT', 'Pacific Standard or Daylight Time',
                  local_timezone, timezone_checked );
  show_tz_button( 'YST', 'YDT', 'Yukon Standard or Daylight Time',
                  local_timezone, timezone_checked );
  htp.tableClose;
  htp.uListClose;

  --
  -- Offset from GMT
  --  
  htp.br;
  htmlp_form_radio( cname=>'timezone_selector',
                    cvalue=>'gmtdiff',
                    clabel=>'Specify offset from GMT',
                    cchecked=>selector_checked,
                    cdefault=>local_selector );
  htp.uListOpen;
  htp.br;
  htp.print( 'Specify the offset in hours from GMT. Use a positive offset' );
  htp.print( 'if the time zone is ahead of GMT. Use a negative offset if' );
  htp.print( 'the timezone is behind GMT.' );
  htp.br;
  htp.br;
  htmlp_form_text_field( cname=>'server_gmtdiff',
                         clabel=>'Time zone offset: ', 
                         cvalue=>local_gmtdiff, 
                         csize=>'10' );
  htp.uListClose;
  htp.uListClose;

  --
  -- Just Cancel and Apply Buttons.
  --
  form_close( cancel_button=>TRUE, apply_button=>TRUE );
  
  --
  -- Output common page trailer
  --
  print_page_trailer;
END select_timezone;


---------------------------------------------------------------------------
--  Name:
--      show_tz_button
--
--  Description:
--      Display timezone selection buttons.
---------------------------------------------------------------------------
PROCEDURE show_tz_button( standard_timezone IN VARCHAR2,
                          daylight_timezone IN VARCHAR2,
                          timezone_description IN VARCHAR2,
                          server_timezone IN VARCHAR2,
                          timezone_checked IN OUT VARCHAR2 )
IS
BEGIN
  htp.tableRowOpen;
  htp.tableData( htmlf_form_radio( cname=>'server_timezone',
                                   cvalue=>standard_timezone,
                                   clabel=>standard_timezone,
                                   cchecked=>timezone_checked,
                                   cdefault=>server_timezone ),
                 cattributes=>'SCOPE="col"' );
  IF daylight_timezone IS NOT NULL
  THEN
    htp.tableData( htmlf_form_radio( cname=>'server_timezone',
                                     cvalue=>daylight_timezone,
                                     clabel=>daylight_timezone,
                                     cchecked=>timezone_checked,
                                     cdefault=>server_timezone ),
                   cattributes=>'SCOPE="col"' );
  ELSE
    htp.tableData( htf.br,
                   cattributes=>'SCOPE="col"' );
  END IF;
  htp.tableData( timezone_description,
                 cattributes=>'SCOPE="col"' );
  htp.tableRowClose;
END show_tz_button;


---------------------------------------------------------------------------
--  Name:
--      set_timezone
--
--  Description:
--      Call the OrdPlsGwyUtil package to set the time zone information.
---------------------------------------------------------------------------
PROCEDURE set_timezone( timezone_selector IN VARCHAR2,
                        server_timezone IN VARCHAR2,
                        server_gmtdiff IN VARCHAR2,
                        form_action IN VARCHAR2 )
IS
  gmtdiff NUMBER;
  error_message VARCHAR2( 128 ) := NULL;
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Must be logged in as admin user to do this.
  --
  IF NOT check_user( admin_user_name,
                     'Please log in as ' || admin_user_name || 
                     ' to set time zone information' )
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel' OR form_action = 'Done'  
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_timezone( timezone_selector=>timezone_selector,
                     server_timezone=>server_timezone, 
                     server_gmtdiff=>server_gmtdiff );
    RETURN;
  END IF;
  
  --
  -- Validate input
  --
  IF timezone_selector = 'timezone'
  THEN
    Ordplsgwyutil.set_timezone( server_timezone=>server_timezone );
  ELSE
    IF server_gmtdiff IS NOT NULL
    THEN
      BEGIN
        gmtdiff := TO_NUMBER( server_gmtdiff );
        Ordplsgwyutil.set_timezone( server_gmtdiff=>gmtdiff );
      EXCEPTION
        WHEN INVALID_NUMBER OR VALUE_ERROR THEN
          error_message := 'Invalid time zone offset';
      END; 
    ELSE
      error_message := 'Please supply a time zone offset';
    END IF; 
  END IF;
  IF error_message IS NOT NULL
  THEN
    select_timezone( timezone_selector=>timezone_selector,
                     server_timezone=>server_timezone, 
                     server_gmtdiff=>NULL,
                     error_message=>error_message );
    RETURN;
  END IF;
  
  --
  -- Display completion screen, using this procedure to handle form
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Server time zone information was set', ruler=>TRUE );

  --
  -- Display setting
  --
  html_p_open;
  htp.prn( 'Time zone set to: ' );
  IF timezone_selector = 'timezone'
  THEN
    htp.print( htmlf_tt( server_timezone ) );
  ELSE
    IF gmtdiff >= 0
    THEN
      htp.print( htmlf_tt( 'GMT+' || gmtdiff ) );
    ELSE
      htp.print( htmlf_tt( 'GMT' || gmtdiff ) );
    END IF; 
  END IF;
  html_p_close;

  --
  -- Display deployment instructions.
  --   
  html_p_open;
  htp.print( '<B>Note:</B>' || NBSP || NBSP || NBSP || 'If you deploy' );
  htp.print( 'media retrieval procedures to other databases, you must install' );
  htp.print( 'the OrdPlsGwyUtil package in the ORDSYS schema of each database.' );
  htp.print( 'In addition, you must also specify the time zone for each' );
  htp.print( 'database. If the interMedia Code Wizard is not installed, use' );
  htp.print( 'SQL*Plus to specify the time zone information as follows,' );
  htp.print( 'substituting a time zone identifier or the offset in hours from' );
  htp.print( 'GMT as appropriate.' );
  htp.uListOpen;
  htp.preOpen;
  htp.print( 'SQL> CONNECT ORDSYS/' || AMPLT || '<I>ordsys-password</I>' || AMPGT );
  IF timezone_selector = 'timezone'
  THEN
    htp.print( 'SQL> EXEC ORDPLSGWYUTIL.SET_TIMEZONE( server_timezone=>''' ||
               server_timezone || ''' );' );
  ELSE
    htp.print( 'SQL> EXEC ORDPLSGWYUTIL.SET_TIMEZONE( server_gmtdiff=>' || 
               server_gmtdiff || ' );' );
  END IF;
  htp.preClose;
  htp.uListClose;
  htp.print( 'If a deployment database is in a different time zone, specify' );
  htp.print( 'the time zone information as follows, substituting a time zone' );
  htp.print( 'identifier or the offset in hours from GMT as appropriate.' );
  htp.print( 'For example:' );
  htp.uListOpen;
  htp.preOpen;
  htp.print( 'SQL> CONNECT ORDSYS/' || AMPLT || '<I>ordsys-password</I>' || AMPGT );
  htp.print( 'SQL> EXEC ORDPLSGWYUTIL.SET_TIMEZONE( server_timezone=>''EDT'' );' );
  htp.print( '                      --or--' );
  htp.print( 'SQL> EXEC ORDPLSGWYUTIL.SET_TIMEZONE( server_gmtdiff=>-4 );' );
  htp.preClose;
  htp.uListClose;
  html_p_close;

  --
  -- Start form, sending current settings
  --
  form_open( 'set_timezone' );
  htp.formHidden( cname=>'timezone_selector', cvalue=>timezone_selector ); 
  htp.formHidden( cname=>'server_timezone', cvalue=>server_timezone ); 
  htp.formHidden( cname=>'server_gmtdiff', cvalue=>server_gmtdiff ); 

  --
  -- Just Done and Back Buttons.
  --    
  form_close( done_button=>TRUE, back_button=>TRUE );

  --
  -- Output common page trailer
  --
  print_page_trailer;
  
END set_timezone;


---------------------------------------------------------------------------
--  Name:
--      code_wizard
--
--  Description:
--      Code wizard step 1: Select the table and procedure type
---------------------------------------------------------------------------
PROCEDURE code_wizard( upload_download IN VARCHAR2 DEFAULT NULL,
                       table_name IN VARCHAR2 DEFAULT NULL,
                       procedure_type IN VARCHAR2 DEFAULT NULL,
                       error_message IN VARCHAR2 DEFAULT NULL )
IS
  CURSOR tab_count_cursor IS
    SELECT COUNT( UNIQUE table_name ) table_count FROM user_tab_columns
      WHERE data_type_owner = 'ORDSYS' AND 
            data_type IN ( 'ORDIMAGE', 'ORDAUDIO', 'ORDVIDEO', 'ORDDOC' );

  CURSOR tab_cursor IS
    SELECT UNIQUE table_name FROM user_tab_columns
      WHERE data_type_owner = 'ORDSYS' AND 
            data_type IN ( 'ORDIMAGE', 'ORDAUDIO', 'ORDVIDEO', 'ORDDOC' );

  table_count INTEGER := 0;
  checked VARCHAR2( 10 );
  local_timezone VARCHAR2( 10 );
  local_gmtdiff VARCHAR2( 10 );
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 1: Select database table and procedure type', ruler=>TRUE );

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Start form
  --
  form_open( 'code_wizard_dispatch' );
  htp.formHidden( cname=>'upload_download', cvalue=>upload_download );

  --
  -- Ensure the timezone has been set if creating a media retrieval procedure.
  --
  IF upload_download = 'download'
  THEN
    BEGIN
      Ordplsgwyutil.get_timezone( local_timezone, local_gmtdiff );
    EXCEPTION
      WHEN OTHERS THEN
        print_error_message( 
          'Time zone information must be set to create a media retrieval procedure' );
      html_p_open;
      htp.print( 'To set the time zone information, return to the main menu,' );
      htp.print( 'then select the "Time zone management" function using the' );
      htp.print( wizard_name || ' ' || admin_dad_name || ' administration DAD.' );
      html_p_close;
      form_close( cancel_button=>TRUE );
      print_page_trailer;
      RETURN;
    END;
  END IF;

  --
  -- Figure out how many tables
  --
  FOR tab_count IN tab_count_cursor LOOP
    table_count := tab_count.table_count;
    EXIT;
  END LOOP;

  --
  -- No need to bother with anything else if there are no media tables.
  --
  IF table_count > 0
  THEN
    --
    -- Display available multimedia tables
    --
    htp.print( 'Select a table from the following list of tables found to' );
    htp.print( 'contain one or more media columns.' );
    htp.ulistOpen;
    checked := 'checked';
    IF table_count > 5
    THEN
      htmlp_form_select_open( cname=>'table_name', clabel=>'Select table: ' );
    END IF;
    FOR tab IN tab_cursor LOOP
      IF table_count > 5
      THEN
        htmlp_form_select_option( cvalue=>tab.table_name,
                                  cselected=>get_checked( checked,
                                                          tab.table_name,
                                                          table_name ) );
      ELSE
        htmlp_form_radio( cname=>'table_name',
                          cvalue=>tab.table_name,
                          clabel=>tab.table_name,
                          cchecked=>checked,
                          cdefault=>table_name );
        htp.br;
      END IF;
    END LOOP;
    IF table_count > 5
    THEN
      htmlp_form_select_close;
    END IF;
    htp.ulistClose;

    --
    -- Select standalone or package procedure
    --
    htp.print( 'Choose either to create a standalone PL/SQL procedure or' );
    htp.print( 'to generate the source of a PL/SQL procedure for inclusion' );
    htp.print( 'into a PL/SQL package.' );
    htp.ulistOpen;
    checked := 'checked';
    htmlp_form_radio( cname=>'procedure_type',
                      cvalue=>'Standalone',
                      clabel=>'Standalone procedure',
                      cchecked=>checked,
                      cdefault=>procedure_type );
    htp.br;
    htmlp_form_radio( cname=>'procedure_type',
                      cvalue=>'Package',
                      clabel=>'Package procedure',
                      cchecked=>checked,
                      cdefault=>procedure_type );
    htp.ulistClose;
  ELSE
    --
    -- Couldn't find any multimedia tables
    --
    print_error_message( 'No media tables found in user ' ||
                         USER || '''s schema' );
  END IF;

  --
  -- End of form
  --
  IF table_count > 0
  THEN
    IF upload_download = 'download'
    THEN
      form_close( cancel_button=>TRUE, next_button=>TRUE,
                step_num=>1, num_steps=>num_download_steps );
    ELSE
      form_close( cancel_button=>TRUE, next_button=>TRUE,
                step_num=>1, num_steps=>num_upload_steps );
    END IF;
  ELSE
    form_close( cancel_button=>TRUE );
  END IF;

  --
  -- Output common page trailer
  --
  print_page_trailer;
END code_wizard;


---------------------------------------------------------------------------
--  Name:
--      code_wizard_dispatch
--
--  Description:
--      Code wizard step 1: Dispatch based on upload/download
---------------------------------------------------------------------------
PROCEDURE code_wizard_dispatch( upload_download IN VARCHAR2,
                                table_name IN VARCHAR2 DEFAULT NULL,
                                procedure_type IN VARCHAR2 DEFAULT NULL,
                                form_action IN VARCHAR2 )
IS
  error_message VARCHAR2( 128 ) := NULL;
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  END IF;

  --
  -- Make sure all data was entered.
  --
  IF table_name IS NULL
  THEN
    error_message := 'Please select a table';
  END IF;
  IF procedure_type IS NULL
  THEN
    error_message := 'Please select the type of procedure to create';
  END IF;
  IF error_message IS NOT NULL
  THEN
    code_wizard( upload_download=>upload_download,
                 table_name=>table_name,
                 procedure_type=>procedure_type,
                 error_message=>error_message );
    RETURN;
  END IF;

  --
  -- Dispatch based on upload/download
  --
  IF upload_download = 'download'
  THEN
    select_download_columns( procedure_type=>procedure_type,
                             table_name=>table_name  );
    RETURN;
  END IF;
  IF upload_download = 'upload'
  THEN
    select_document_table( procedure_type=>procedure_type,
                           table_name=>table_name  );
    RETURN;
  END IF;
END code_wizard_dispatch;


---------------------------------------------------------------------------
--  Name:
--      select_download_columns
--
--  Description:
--      Download step 2: Select the media column and key column
---------------------------------------------------------------------------
PROCEDURE select_download_columns( procedure_type IN VARCHAR2 DEFAULT NULL,
                                   table_name IN VARCHAR2 DEFAULT NULL,
                                   selected_column IN VARCHAR2 DEFAULT NULL,
                                   selected_keycol IN VARCHAR2 DEFAULT NULL,
                                   error_message IN VARCHAR2 DEFAULT NULL )
IS
  column_info VARCHAR2( 128 );
  checked VARCHAR2( 10 );
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 2: Select media column and key column', ruler=>TRUE );

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Start form, passing table name to next procedure
  --
  form_open( 'validate_download_columns' );
  print_download_context( procedure_type=>procedure_type,
                          table_name=>table_name );

  --
  -- Display available multimedia columns in selected table
  --
  htp.print( 'Select the column from which to retrieve the media data' );
  htp.print( 'from the following list of media columns found in the' );
  htp.print( htmlf_tt( table_name ) || ' table.' );
  htp.ulistOpen;
  checked := ' checked';
  FOR col IN mediacol_cursor( table_name ) LOOP
    column_info := col.column_name || ' (' || col.data_type || ')';
    htmlp_form_radio( cname=>'selected_column',
                      cvalue=>column_info,
                      clabel=>column_info,
                      cchecked=>checked,
                      cdefault=>selected_column );
    htp.br;
  END LOOP;
  htp.ulistClose;

  --
  -- Display available key columns
  --
  htp.print( 'Select the column to be used to locate the media data from' );
  htp.print( 'the following list of columns found in the ' );
  htp.print( htmlf_tt( table_name ) || ' table.' );
  htp.ulistOpen;
  checked := ' checked';
  FOR keycol IN key_cursor( table_name ) LOOP
    htmlp_form_radio( cname=>'selected_keycol',
                      cvalue=>keycol.column_name,
                      clabel=>keycol.column_name || ' (' || keycol.info || ')',
                      cchecked=>checked,
                      cdefault=>selected_keycol );
    htp.br;
  END LOOP;
    htmlp_form_radio( cname=>'selected_keycol',
                      cvalue=>'rowid',
                      clabel=>'ROWID (Unique)',
                      cchecked=>checked,
                      cdefault=>selected_keycol );
  htp.br;
  FOR nonkeycol IN nonkey_cursor( table_name ) LOOP
    htmlp_form_radio( cname=>'selected_keycol',
                      cvalue=>nonkeycol.column_name,
                      clabel=>nonkeycol.column_name,
                      cchecked=>checked,
                      cdefault=>selected_keycol );
    htp.br;
  END LOOP;
  htp.ulistClose;

  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, next_button=>TRUE,
            step_num=>2, num_steps=>num_download_steps );

  --
  -- Output common page trailer
  --
  print_page_trailer;
END select_download_columns;


---------------------------------------------------------------------------
--  Name:
--      validate_download_columns
--
--  Description:
--      Download step 2: Validate the selected columns
---------------------------------------------------------------------------
PROCEDURE validate_download_columns( procedure_type IN VARCHAR2,
                                     table_name IN VARCHAR2,
                                     selected_column IN VARCHAR2,
                                     selected_keycol IN VARCHAR2,
                                     form_action IN VARCHAR2 )
IS
  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
  keycol_name VARCHAR2( 128 );
  error_message VARCHAR2( 128 );
  dummy VARCHAR2( 128 );
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    code_wizard( upload_download=>'download',
                 table_name=>table_name,
                 procedure_type=>procedure_type );
    RETURN;
  END IF;

  --
  -- Make sure all data was entered.
  --
  IF selected_column IS NULL
  THEN
    error_message := 'Please select a media column';
  ELSIF selected_keycol IS NULL
  THEN
    error_message := 'Please select a key column';
  END IF;
  IF error_message IS NOT NULL
  THEN
    select_download_columns( table_name=>table_name,
                             selected_column=>selected_column,
                             selected_keycol=>selected_keycol,
                             error_message=>'Please select a key column' );
    RETURN;
  END IF;

  --
  -- Extract column name and column type from selected column
  --
  extract_column_name_and_info( selected_column, column_name, column_type );
  IF column_type IS NULL
  THEN
    error_message := 'INTERNAL ERROR:- NO MEDIA TYPE';
  END IF;
  IF error_message IS NOT NULL
  THEN
    select_download_columns( table_name=>table_name,
                             selected_column=>selected_column,
                             selected_keycol=>selected_keycol,
                             error_message=>'Please select a key column' );
    RETURN;
  END IF;

  --
  -- Select procedure and parameter names
  --
  select_download_names( procedure_type=>procedure_type,
                         table_name=>table_name,
                         selected_column=>selected_column,
                         selected_keycol=>selected_keycol );
END validate_download_columns;


---------------------------------------------------------------------------
--  Name:
--      select_download_names
--
--  Description:
--      Download step 3: Select procedure name and parameter name
---------------------------------------------------------------------------
PROCEDURE select_download_names( procedure_type IN VARCHAR2 DEFAULT NULL,
                                 table_name IN VARCHAR2 DEFAULT NULL,
                                 selected_column IN VARCHAR2 DEFAULT NULL,
                                 selected_keycol IN VARCHAR2 DEFAULT NULL,
                                 procedure_name IN VARCHAR2 DEFAULT NULL,
                                 parameter_name IN VARCHAR2 DEFAULT NULL,
                                 selected_function IN VARCHAR2 DEFAULT NULL,
                                 error_message IN VARCHAR2 DEFAULT NULL )
IS
  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
  default_proc_name VARCHAR2( 128 );
  default_param_name VARCHAR2( 128 );
  checked VARCHAR2( 10 ) := ' checked';
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 3: Select procedure name and parameter name', ruler=>TRUE );

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Start form, passing table name and column names to next procedure
  --
  form_open( 'validate_download_names' );
  print_download_context( procedure_type=>procedure_type,
                          table_name=>table_name,
                          selected_column=>selected_column,
                          selected_keycol=>selected_keycol );

  --
  -- Select procedure name
  --
  IF procedure_name IS NULL
  THEN
    extract_column_name_and_info( selected_column, column_name, column_type );
    default_proc_name := 'GET_' || table_name || '_' || column_name;
  ELSE
    default_proc_name := procedure_name;
  END IF;
  default_proc_name := SUBSTR( default_proc_name, 1, 30 );
  htp.print( 'Choose a name for the media retrieval procedure. You can' );
  htp.print( 'accept the default provided or supply a different name.' );
  htp.uListOpen;
  htmlp_form_text_field( cname=>'procedure_name',
                         clabel=>'Procedure name: ',
                         csize=>'30',
                         cmaxlength=>'30',
                         cvalue=>default_proc_name );
  htp.uListClose;

  --
  -- Select parameter name
  --
  IF parameter_name IS NULL
  THEN
    default_param_name := 'MEDIA_' || selected_keycol;
  ELSE
    default_param_name := parameter_name;
  END IF;
  default_param_name := SUBSTR( default_param_name, 1, 30 );
  htp.print( 'Choose a name for the parameter used to supply the' );
  htp.print( 'key value. You can accept the default provided or supply a' );
  htp.print( 'different name. The parameter name is used in a media' );
  htp.print( 'retrieval URL as follows: ' );
  htp.print( '<TT>http://host/pls/DAD/proc-name?param-name=key-value</TT>' );
  htp.uListOpen;
  htmlp_form_text_field( cname=>'parameter_name',
                         clabel=>'Parameter name: ',
                         csize=>'30',
                         cmaxlength=>'30',
                         cvalue=>default_param_name );
  htp.uListClose;

  --
  -- Select function
  --
  IF procedure_type = 'Standalone'
  THEN
    html_p_open;
    htp.print( 'Choose either to create the procedure in the database or' );
    htp.print( 'to generate the procedure source code only. In either case' );
    htp.print( 'you will subsequently have the opportunity to view the' );
    htp.print( 'generated source code.' );
    htp.uListOpen;
    checked := 'checked';
    htmlp_form_radio( cname=>'selected_function',
                      cvalue=>'create',
                      clabel=>'Create procedure in the database',
                      cchecked=>checked,
                      cdefault=>selected_function );
    htp.br;
    htmlp_form_radio( cname=>'selected_function',
                      cvalue=>'view',
                      clabel=>'Generate procedure source only',
                      cchecked=>checked,
                      cdefault=>selected_function );
    htp.uListClose;
    html_p_close;
  ELSE
    htp.formHidden( cname=>'selected_function', cvalue=>'view' );
  END IF;

  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, next_button=>TRUE,
            step_num=>3, num_steps=>num_download_steps );

  --
  -- Output common page trailer
  --
  print_page_trailer;

END select_download_names;


---------------------------------------------------------------------------
--  Name:
--      validate_download_names
--
--  Description:
--      Download step 3: Validate procedure name and parameter name
---------------------------------------------------------------------------
PROCEDURE validate_download_names( procedure_type IN VARCHAR2,
                                   table_name IN VARCHAR2,
                                   selected_column IN VARCHAR2,
                                   selected_keycol IN VARCHAR2,
                                   procedure_name IN VARCHAR2,
                                   parameter_name IN VARCHAR2,
                                   selected_function IN VARCHAR2,
                                   form_action IN VARCHAR2 )
IS
  error_message VARCHAR2( 128 );
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_download_columns( procedure_type=>procedure_type,
                             table_name=>table_name,
                             selected_column=>selected_column,
                             selected_keycol=>selected_keycol );
    RETURN;
  END IF;

  --
  -- Make sure all data was entered.
  --
  IF procedure_name IS NULL
  THEN
    error_message := 'Please enter a procedure name';
  ELSIF parameter_name IS NULL
  THEN
    error_message := 'Please enter a parameter name';
  ELSIF selected_function IS NULL
  THEN
    error_message := 'Please select a function';
  END IF;
  IF error_message IS NOT NULL
  THEN
    select_download_names( procedure_type=>procedure_type,
                           table_name=>table_name,
                           selected_column=>selected_column,
                           selected_keycol=>selected_keycol,
                           procedure_name=>procedure_name,
                           parameter_name=>parameter_name,
                           selected_function=>selected_function,
                           error_message=>error_message );
    RETURN;
  END IF;

  --
  -- Generate download procedure
  --
  display_download_summary( procedure_type=>procedure_type,
                            table_name=>table_name,
                            selected_column=>selected_column,
                            selected_keycol=>selected_keycol,
                            procedure_name=>UPPER( procedure_name ),
                            parameter_name=>UPPER( parameter_name ),
                            selected_function=>selected_function );
END validate_download_names;


---------------------------------------------------------------------------
--  Name:
--      display_download_summary
--
--  Description:
--      Download step 4: Review summary
---------------------------------------------------------------------------
PROCEDURE display_download_summary( procedure_type IN VARCHAR2,
                                    table_name IN VARCHAR2,
                                    selected_column IN VARCHAR2,
                                    selected_keycol IN VARCHAR2,
                                    procedure_name IN VARCHAR2,
                                    parameter_name IN VARCHAR2,
                                    selected_function IN VARCHAR2 )
IS
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 4: Review selected options', ruler=>TRUE );

  --
  -- Display summary table
  --
  htp.print( 'Click the <B>Finish</B> button if the following options are' );
  htp.print( 'correct.' );
  htp.uListOpen;
  html_table_open( blayout=>TRUE, cscope=>'row' );

  --
  -- Display selected options
  --
  htp.tableRowOpen;
  htp.tableData( cvalue=>'Procedure type:', cattributes=>'SCOPE="row"' );
  htp.tableData( cvalue=>procedure_type, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Table name:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>table_name, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Media column:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>selected_column, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Key column:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>selected_keycol, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Procedure name:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>procedure_name, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Parameter name:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>parameter_name, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Function:', cattributes=>'SCOPE="row"'  );
  IF selected_function = 'create' 
  THEN
    htp.tableData( cvalue=>'Create procedure in the database',
                   cattributes=>'SCOPE="row"' );
  ELSE
    htp.tableData( cvalue=>'Generate procedure source only',
                   cattributes=>'SCOPE="row"' );
  END IF;
  htp.tableRowClose;

  --
  -- End of summary table
  --
  htp.tableClose;
  htp.uListClose;

  --
  -- Start form, passing all data to next procedure
  --
  form_open( 'generate_download_procedure' );
  print_download_context( procedure_type=>procedure_type,
                          table_name=>table_name,
                          selected_column=>selected_column,
                          selected_keycol=>selected_keycol,
                          procedure_name=>procedure_name,
                          parameter_name=>parameter_name,
                          selected_function=>selected_function );

  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, finish_button=>TRUE,
            step_num=>4, num_steps=>num_download_steps );

END display_download_summary;


---------------------------------------------------------------------------
--  Name:
--      generate_download_procedure
--
--  Description:
--      Download final step: Generate download procedure
---------------------------------------------------------------------------
PROCEDURE generate_download_procedure( procedure_type IN VARCHAR2,
                                       table_name IN VARCHAR2,
                                       selected_column IN VARCHAR2,
                                       selected_keycol IN VARCHAR2,
                                       procedure_name IN VARCHAR2,
                                       parameter_name IN VARCHAR2,
                                       selected_function IN VARCHAR2,
                                       form_action IN VARCHAR2 )
IS
  compiled_successfully BOOLEAN := FALSE;
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_download_names( procedure_type=>procedure_type,
                           table_name=>table_name,
                           selected_column=>selected_column,
                           selected_keycol=>selected_keycol,
                           procedure_name=>procedure_name,
                           parameter_name=>parameter_name,
                           selected_function=>selected_function );
    RETURN;
  END IF;

  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Create or display generated procedure
  --
  IF selected_function = 'create'
  THEN
    BEGIN
      print_message( 'Compile procedure and review generated source',
                     ruler=>TRUE );
      generate_download_proc_source( procedure_type=>procedure_type,
                                     table_name=>table_name,
                                     selected_column=>selected_column,
                                     selected_keycol=>selected_keycol,
                                     procedure_name=>procedure_name,
                                     parameter_name=>parameter_name );
      EXECUTE IMMEDIATE source_buf;
      print_message( 'Procedure created successfully: ' );
      htp.print( htmlf_tt( procedure_name ) );
      compiled_successfully := TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -24344
        THEN
          print_error_message( 'The following errors were encountered compiling: ' ||
                               htmlf_tt( procedure_name ) );
          show_compilation_errors( procedure_name );
        ELSE
          print_message( 'Error creating procedure: ' );
          htp.print( htmlf_tt( procedure_name ) );
          print_error_message( htmlf_tt( SQLERRM ) );
        END IF;
    END;
  ELSE
    print_message( 'Review generated source', ruler=>TRUE );
  END IF;

  --
  -- If compiled successfully, show compiled source button, otherwise, show
  -- generated source button.
  --
  IF compiled_successfully
  THEN
    print_compiled_source_button( procedure_name );
  ELSE
    html_p_open;
    htp.print( 'Click the <B>View</B> button to display the generated PL/SQL' );
    htp.print( 'source code in a pop-up window.' );
    htp.print( 'To save the source in a file for editing, select' );
    htp.print( '<B>Save As...</B> from your browser''s <B>File</B>' );
    htp.print( 'pull-down menu.' );
    htp.ulistOpen;
    form_open( proc_name=>'view_download_source', target=>'_blank' );
    print_download_context( procedure_type=>procedure_type,
                            table_name=>table_name,
                            selected_column=>selected_column,
                            selected_keycol=>selected_keycol,
                            procedure_name=>procedure_name,
                            parameter_name=>parameter_name );
    htp.prn( 'Click to display generated source: ' );
    htp.formSubmit( cvalue=>'View' );
    form_close( menu_bar=>FALSE );
    htp.ulistClose;
    html_p_close;
  END IF;

  --
  -- Always display URL format.
  --
  html_p_open;
  htp.print( 'Use the following URL format to retrieve media data from the' );
  htp.print( 'database using the ' || htmlf_tt( procedure_name ) );
  htp.print( 'procedure.' );
  htp.ulistOpen;
  htp.print( htmlf_tt( 'http://host:port/pls/<I>DAD-name</I>/' || 
                       LOWER( procedure_name ) ||  
                       '?' || LOWER( parameter_name ) || '=<I>key-value</I>' ) );
  htp.ulistClose;
  html_p_close;

  --
  -- Test the created procedure, if possible, ie, if we tried to create it.
  --
  IF selected_function = 'create'
  THEN
    html_p_open;
    htp.print( 'Enter a key value, then click the <B>Test</B> button to test' );
    htp.print( 'the generated PL/SQL procedure. The media or media player' );
    htp.print( 'will be displayed in a pop-up window.' );
    htp.ulistOpen;
    htp.formOpen( curl=>owa_util.get_owa_service_path || LOWER( procedure_name ),
                  cmethod=>'GET',
                  ctarget=>'_blank' );
    htmlp_form_text_field( cname=>parameter_name,
                           clabel=>'Key parameter (' || parameter_name || '): ',
                           csize=>'20',
                           cmaxlength=>'100' );
    htp.formSubmit( cvalue=>'Test' );
    htp.formClose;
    htp.ulistClose;
    html_p_close;
  END IF;

  --
  -- Display standard action bar
  --
  form_open( 'generate_download_done' );
  print_download_context( procedure_type=>procedure_type,
                          table_name=>table_name,
                          selected_column=>selected_column,
                          selected_keycol=>selected_keycol,
                          procedure_name=>procedure_name,
                          parameter_name=>parameter_name,
                          selected_function=>selected_function );
  form_close( done_button=>TRUE, back_button=>TRUE );

  --
  -- Output common page trailer
  --
  print_page_trailer;
END generate_download_procedure;


---------------------------------------------------------------------------
--  Name:
--      generate_download_done
--
--  Description:
--      Completion for for download procedure
---------------------------------------------------------------------------
PROCEDURE generate_download_done( procedure_type IN VARCHAR2,
                                  table_name IN VARCHAR2,
                                  selected_column IN VARCHAR2,
                                  selected_keycol IN VARCHAR2,
                                  procedure_name IN VARCHAR2,
                                  parameter_name IN VARCHAR2,
                                  selected_function IN VARCHAR2,
                                  form_action IN VARCHAR2 )
IS
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Done'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    display_download_summary( procedure_type=>procedure_type,
                              table_name=>table_name,
                              selected_column=>selected_column,
                              selected_keycol=>selected_keycol,
                              procedure_name=>procedure_name,
                              parameter_name=>parameter_name,
                              selected_function=>selected_function );
    RETURN;
  END IF;
  menu();
END generate_download_done;


---------------------------------------------------------------------------
--  Name:
--      view_download_source
--
--  Description:
--      View generated source, either a package procedure or a template
--      HTML form.
--
---------------------------------------------------------------------------
PROCEDURE view_download_source( procedure_type IN VARCHAR2,
                                table_name IN VARCHAR2,
                                selected_column IN VARCHAR2,
                                selected_keycol IN VARCHAR2,
                                procedure_name IN VARCHAR2,
                                parameter_name IN VARCHAR2 )
IS
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Generate and display source
  --
  generate_download_proc_source( procedure_type=>procedure_type,
                                 table_name=>table_name,
                                 selected_column=>selected_column,
                                 selected_keycol=>selected_keycol,
                                 procedure_name=>procedure_name,
                                 parameter_name=>parameter_name );
  owa_util.mime_header( 'text/plain', TRUE );
  htp.prn( source_buf );
END view_download_source;


---------------------------------------------------------------------------
--  Name:
--      generate_download_proc_source
--
--  Description:
--      Generates download procedure source.
--
---------------------------------------------------------------------------
PROCEDURE generate_download_proc_source( procedure_type IN VARCHAR2,
                                         table_name IN VARCHAR2,
                                         selected_column IN VARCHAR2,
                                         selected_keycol IN VARCHAR2,
                                         procedure_name IN VARCHAR2,
                                         parameter_name IN VARCHAR2 )
IS
  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
BEGIN
  --
  -- Create template based on procedure style
  --
  IF procedure_type = 'Standalone'
  THEN
    source_buf := download_sa_proc_template || download_proc_body_template;
  ELSE
    source_buf := download_pkg_proc_template || download_proc_body_template;
  END IF;

  --
  -- Extract column name and type.
  --
  extract_column_name_and_info( selected_column, column_name, column_type );

  --
  -- Substitute procedure, table and variable names with actual values.
  --
  source_buf := REPLACE( source_buf, '%procedure-name%', procedure_name );
  source_buf := REPLACE( source_buf, '%table-name%', table_name );
  source_buf := REPLACE( source_buf, '%column-name%', column_name );
  source_buf := REPLACE( source_buf, '%column-type%', column_type );
  source_buf := REPLACE( source_buf, '%keycol-name%', selected_keycol );
  source_buf := REPLACE( source_buf, '%keycol-param%', parameter_name );
END;


---------------------------------------------------------------------------
--  Name:
--      select_document_table
--
--  Description:
--      Upload step 2: Select the PL/SQL Gateway document upload table
---------------------------------------------------------------------------
PROCEDURE select_document_table( procedure_type IN VARCHAR2 DEFAULT NULL,
                                 table_name IN VARCHAR2 DEFAULT NULL,
                                 doctable_action IN VARCHAR2 DEFAULT NULL,
                                 doctable_name IN VARCHAR2 DEFAULT NULL,
                                 newdoctable_name IN VARCHAR2 DEFAULT NULL,
                                 error_message IN VARCHAR2 DEFAULT NULL )
IS
  CURSOR upltab_cursor IS
    SELECT DISTINCT table_name FROM user_tab_columns
      WHERE column_name = 'DAD_CHARSET';

  CURSOR upltabcol_cursor( table_name_arg VARCHAR2 ) IS
    SELECT COUNT(*) upltabcol_count FROM user_tab_columns
      WHERE table_name = table_name_arg AND
            column_name IN ( 'NAME', 'MIME_TYPE', 'DOC_SIZE', 'DAD_CHARSET',
                             'LAST_UPDATED', 'CONTENT_TYPE', 'BLOB_CONTENT' );

  doctable_names vc2_array;
  default_doctable_name VARCHAR2( 30 );
  default_doctable_exists BOOLEAN;
  dad_doctable_name VARCHAR2( 30 );
  dad_doctable_exists BOOLEAN;
  dad_doctable_message VARCHAR2( 128 );
  doctable_checked VARCHAR2( 10 );
  action_checked VARCHAR2( 10 );
  action_default VARCHAR2( 15 );
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 2: Select PL/SQL Gateway document upload table', 
                 ruler=>TRUE );

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Detailed explanation of PL/SQL document tables.
  --
  html_p_open;
  htp.print( 'All files uploaded using the PL/SQL Gateway are uploaded into' );
  htp.print( 'a document table. The media upload procedure created by this' );
  htp.print( 'code wizard moves uploaded media from the specified document' );
  htp.print( 'table to the application''s table. To avoid transient files' );
  htp.print( 'appearing temporarily in a document table used by another' );
  htp.print( 'application component, choose a document table that is not' );
  htp.print( 'being used to store documents permanently.' );
  html_p_close;
  html_p_open;
  htp.print( '<B>Note:</B>' || NBSP || NBSP || NBSP || 'Be sure to specify' );
  htp.print( 'the selected document table in the application''s Database' );
  htp.print( 'Access Descriptor (DAD). If the DAD already specifies a' );
  htp.print( 'different document table, create a new DAD for media uploads.' );
  html_p_close;

  --
  -- Find available document tables
  --
  dad_doctable_name := UPPER( owa_util.get_cgi_env( 'DOCUMENT_TABLE' ) );
  default_doctable_exists := FALSE;
  default_doctable_name := newdoctable_name;
  IF default_doctable_name IS NULL
  THEN
    default_doctable_name := doctable_name;
  END IF;
  IF default_doctable_name IS NULL
  THEN
    default_doctable_name := dad_doctable_name;
  END IF;
  FOR tab IN upltab_cursor
  LOOP
    FOR tabcol IN upltabcol_cursor( tab.table_name ) 
    LOOP
      IF tabcol.upltabcol_count >= 7
      THEN
        doctable_names( doctable_names.COUNT + 1 ) := tab.table_name;
        IF default_doctable_name = tab.table_name 
        THEN
          default_doctable_exists := TRUE;
        END IF;
        IF dad_doctable_name = tab.table_name 
        THEN
          dad_doctable_exists := TRUE;
        END IF;
      END IF;
      EXIT;
    END LOOP;
  END LOOP;

  --
  -- If a document table was specified for the DAD, then construct a 
  -- message to display it.
  --
  IF dad_doctable_name IS NULL
  THEN
    dad_doctable_message := 
      'No document table is currently specified for the ' ||
      htmlf_tt( UPPER( owa_util.get_cgi_env( 'DAD_NAME' ) ) ) || ' DAD.';
  ELSE
    dad_doctable_message := 
      'The document table currently specified for the ' ||
      htmlf_tt( UPPER( owa_util.get_cgi_env( 'DAD_NAME' ) ) ) || ' DAD is: ' ||  
      htmlf_tt( dad_doctable_name );
  END IF;

  --
  -- Start form, passing table name to next procedure
  --
  form_open( 'validate_document_table' );
  print_upload_context( procedure_type=>procedure_type,
                        table_name=>table_name );

  --
  -- Always provide the option of creating a new table, making it the only
  -- option if there no existing tables. 
  --
  IF doctable_names.COUNT > 0
  THEN
    doctable_checked := 'checked';
    action_checked := 'checked';
    action_default := doctable_action;
    IF action_default IS NULL
    THEN
      IF default_doctable_exists OR dad_doctable_name IS NULL
      THEN
        action_default := 'use_existing';
      ELSE
        action_default := 'create_new';
      END IF;
    END IF;
    IF NOT default_doctable_exists
    THEN
      default_doctable_name := NULL;
    END IF;
    html_p_open;
    htp.print( dad_doctable_message ); 
    html_p_close;
    html_p_open;
    htp.print( 'Choose either to select an existing document table or' );
    htp.print( 'to create a new document table.' );
    htp.ulistOpen;
    htmlp_form_radio( cname=>'doctable_action',
                      cvalue=>'use_existing',
                      clabel=>'Use existing document table',
                      cchecked=>action_checked,
                      cdefault=>action_default );
    htp.ulistOpen;
    htp.br;
    htp.print( 'Select an existing PL/SQL Gateway' );
    htp.print( 'document table from the following list.' ); 
    htp.br;
    FOR i IN 1..doctable_names.COUNT
    LOOP
      htp.br;
      htmlp_form_radio( cname=>'doctable_name',
                        cvalue=>doctable_names( i ),
                        clabel=>doctable_names( i ),
                        cchecked=>doctable_checked,
                        cdefault=>default_doctable_name );
    END LOOP;
    htp.ulistClose;
    htp.br;
    htmlp_form_radio( cname=>'doctable_action',
                      cvalue=>'create_new',
                      clabel=>'Create new document table',
                      cchecked=>action_checked,
                      cdefault=>action_default );
    IF action_default = 'use_existing'
    THEN
      IF dad_doctable_exists
      THEN
        default_doctable_name := NULL;
      ELSE
        default_doctable_name := dad_doctable_name;
      END IF;
    ELSE
      IF newdoctable_name IS NULL
      THEN
        default_doctable_name := dad_doctable_name;
      ELSE
        default_doctable_name := newdoctable_name;
      END IF;
    END IF;
    htp.ulistOpen;
    html_p_open;
    htp.print( 'Enter a table name below to create a new document table.' );
    IF default_doctable_name IS NOT NULL
    THEN
      htp.print( 'You can accept the default provided or supply a different name.' );
    END IF;
    html_p_close;
    htmlp_form_text_field( cname=>'newdoctable_name',
                           cvalue=>default_doctable_name,
                           clabel=>'Table name: ',
                           csize=>'30',
                           cmaxlength=>'30' );
    htp.ulistClose;
    htp.ulistClose;
    html_p_close;
  ELSE
    print_message( 'No suitable PL/SQL Gateway document tables were found in this schema',
                   end_paragraph=>TRUE );
    htp.formHidden( cname=>'doctable_action', cvalue=>'create_new' );
    html_p_open;
    htp.print( dad_doctable_message ); 
    html_p_close;
    html_p_open;
    htp.print( 'Enter a table name below to create a new document table.' );
    htp.ulistOpen;
    htmlp_form_text_field( cname=>'newdoctable_name',
                           cvalue=>default_doctable_name,
                           clabel=>'Table name: ',
                           csize=>'30',
                           cmaxlength=>'30' );
    htp.ulistClose;
    html_p_close;
  END IF;
  
  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, next_button=>TRUE,
            step_num=>2, num_steps=>num_upload_steps );

  --
  -- Output common page trailer
  --
  print_page_trailer;
END select_document_table;


---------------------------------------------------------------------------
--  Name:
--      validate_document_table
--
--  Description:
--      Upload step 2: Validate the PL/SQL Gateway document upload table
---------------------------------------------------------------------------
PROCEDURE validate_document_table( procedure_type IN VARCHAR2,
                                   table_name IN VARCHAR2,
                                   doctable_action IN VARCHAR2,
                                   doctable_name IN VARCHAR2 DEFAULT NULL,
                                   newdoctable_name IN VARCHAR2 DEFAULT NULL,
                                   form_action IN VARCHAR2 )
IS
  create_table_sql VARCHAR2( 4000 );
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    code_wizard( upload_download=>'upload',
                 table_name=>table_name,
                 procedure_type=>procedure_type );
    RETURN;
  END IF;

  --
  -- Validation and processing is based on whether or not we're creating a
  -- new document table.
  --
  IF doctable_action = 'use_existing'
  THEN
    --
    -- Make sure all data was entered.
    --
    IF doctable_name IS NULL
    THEN
      select_document_table( procedure_type=>procedure_type,
                             table_name=>table_name,
                             doctable_action=>doctable_action,
                             doctable_name=>doctable_name,
                             newdoctable_name=>newdoctable_name,
                             error_message=>'Please select a document table' );
      RETURN;
    END IF;

    --
    -- Select media columns and key column
    --
    select_upload_columns( procedure_type=>procedure_type,
                           table_name=>table_name,
                           doctable_name=>doctable_name,
                           selected_columns=>empty_array );
  ELSE
    --
    -- Make sure all data was entered.
    --
    IF newdoctable_name IS NULL 
    THEN
      select_document_table( procedure_type=>procedure_type,
                             table_name=>table_name,
                             doctable_action=>doctable_action,
                             doctable_name=>doctable_name,
                             newdoctable_name=>newdoctable_name,
                             error_message=>'Please enter a new document table name' );
      RETURN;
    END IF;

    --
    -- Create new document table.
    --
    create_table_sql := REPLACE( upload_table_template,
                                 '%document-table-name%',
                                 newdoctable_name );
    BEGIN
      EXECUTE IMMEDIATE create_table_sql;
    EXCEPTION
      WHEN OTHERS THEN
        select_document_table(
            procedure_type=>procedure_type,
            table_name=>table_name,
            doctable_action=>doctable_action,
            doctable_name=>doctable_name,
            newdoctable_name=>newdoctable_name,
            error_message=>'"' || SQLERRM || '" creating document table' );
        RETURN;
    END;

    --
    -- Select media columns and key column
    --
    select_upload_columns( procedure_type=>procedure_type,
                           table_name=>table_name,
                           doctable_name=>newdoctable_name,
                           selected_columns=>empty_array );
  END IF;

END validate_document_table;

---------------------------------------------------------------------------
--  Name:
--      select_upload_columns
--
--  Description:
--      Upload step 3: Select the media column(s) and key column
---------------------------------------------------------------------------
PROCEDURE select_upload_columns( procedure_type IN VARCHAR2 DEFAULT NULL,
                                 table_name IN VARCHAR2 DEFAULT NULL,
                                 doctable_name IN VARCHAR2 DEFAULT NULL,
                                 selected_columns IN vc2_array,
                                 selected_keycol IN VARCHAR2 DEFAULT NULL,
                                 table_access IN VARCHAR2 DEFAULT NULL,
                                 error_message IN VARCHAR2 DEFAULT NULL )
IS
  column_info VARCHAR2( 128 );
  checked VARCHAR2( 10 );
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 3: Select data access and media column(s)', ruler=>TRUE );

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Start form, passing table name to next procedure
  --
  form_open( 'validate_upload_columns' );
  print_upload_context( procedure_type=>procedure_type,
                        table_name=>table_name,
                        doctable_name=>doctable_name );

  --
  -- Display available multimedia columns in selected table
  -- Use dummy first entry in case no selections are made
  --
  htp.print( 'Select the column or columns to which media data is to' );
  htp.print( 'be uploaded from the following list of media columns found in' );
  htp.print( 'the ' || htmlf_tt( table_name ) || ' table. If the table' );
  htp.print( 'contains multiple media columns, you may select multiple' );
  htp.print( 'columns to allow more than one media item to be uploaded from' );
  htp.print( 'a single HTML form.' );
  htp.ulistOpen;
  htp.formHidden( cname=>'selected_columns', cvalue=>'dummy' );
  checked := ' checked';
  FOR col IN mediacol_cursor( table_name ) LOOP
    column_info := col.column_name || ' (' || col.data_type || ')';
    htmlp_form_checkbox( cname=>'selected_columns',
                         cvalue=>column_info,
                         clabel=>column_info,
                         cchecked=>checked,
                         cdefaults=>selected_columns );
    htp.br;
  END LOOP;
  htp.ulistClose;

  --
  -- Display available key columns
  --
  htp.print( 'Select the column to be used to locate the media data from' );
  htp.print( 'the following list of columns found in the ' );
  htp.print( htmlf_tt( table_name ) || ' table.' );
  htp.ulistOpen;
  checked := ' checked';
  FOR keycol IN key_cursor( table_name ) LOOP
    htmlp_form_radio( cname=>'selected_keycol',
                      cvalue=>keycol.column_name,
                      clabel=>keycol.column_name || ' (' || keycol.info || ')',
                      cchecked=>checked,
                      cdefault=>selected_keycol );
    htp.br;
  END LOOP;
  FOR nonkeycol IN nonkey_cursor( table_name ) LOOP
    htmlp_form_radio( cname=>'selected_keycol',
                      cvalue=>nonkeycol.column_name,
                      clabel=>nonkeycol.column_name,
                      cchecked=>checked,
                      cdefault=>selected_keycol );
    htp.br;
  END LOOP;
  htp.ulistClose;

  --
  -- Select data access mode
  --
  htp.print( 'Choose how the generated procedure will access the table to' );
  htp.print( 'store uploaded media data. You may choose to insert a new row' );
  htp.print( 'into the table, to update an existing row in the table, or to' );
  htp.print( 'conditionally insert a new row if an existing row does not' );
  htp.print( 'exist.' );
  htp.ulistOpen;
  checked := 'checked';
  htmlp_form_radio( cname=>'table_access',
                    cvalue=>'insert',
                    clabel=>'Insert new row',
                    cchecked=>checked,
                    cdefault=>table_access );
  htp.br;
  htmlp_form_radio( cname=>'table_access',
                    cvalue=>'update',
                    clabel=>'Update existing row',
                    cchecked=>checked,
                    cdefault=>table_access );
  htp.br;
  htmlp_form_radio( cname=>'table_access',
                    cvalue=>'update_insert',
                    clabel=>'Conditional insert or update',
                    cchecked=>checked,
                    cdefault=>table_access );
  htp.ulistClose;

  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, next_button=>TRUE,
            step_num=>3, num_steps=>num_upload_steps );

  --
  -- Output common page trailer
  --
  print_page_trailer;
END select_upload_columns;


---------------------------------------------------------------------------
--  Name:
--      validate_upload_columns
--
--  Description:
--      Upload step 3: Validate the selected media columns
---------------------------------------------------------------------------
PROCEDURE validate_upload_columns( procedure_type IN VARCHAR2,
                                   table_name IN VARCHAR2,
                                   doctable_name IN VARCHAR2,
                                   selected_columns IN vc2_array,
                                   selected_keycol IN VARCHAR2,
                                   table_access IN VARCHAR2,
                                   form_action IN VARCHAR2 )
IS
  error_message VARCHAR2( 128 ) := NULL;
  column_name VARCHAR2( 128 );
  keycol_name VARCHAR2( 128 );
  dummy VARCHAR2( 128 );
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_document_table( procedure_type=>procedure_type,
                           table_name=>table_name,
                           doctable_name=>doctable_name );
    RETURN;
  END IF;

  --
  -- Make sure all data was entered.
  --
  IF selected_columns IS NULL
  THEN
    error_message := 'Please select one or more media columns';
  ELSIF selected_columns.COUNT < 2
  THEN
    error_message := 'Please select one or more media columns';
  ELSIF selected_keycol IS NULL
  THEN
    error_message := 'Please select a key column';
  END IF;
  IF error_message IS NOT NULL
  THEN
    select_upload_columns( procedure_type=>procedure_type,
                           table_name=>table_name,
                           doctable_name=>doctable_name,
                           selected_columns=>selected_columns,
                           selected_keycol=>selected_keycol,
                           table_access=>table_access,
                           error_message=>error_message );
    RETURN;
  END IF;

  --
  -- Select procedure name
  --
  select_upload_proc_name( procedure_type=>procedure_type,
                           table_name=>table_name,
                           doctable_name=>doctable_name,
                           selected_columns=>selected_columns,
                           selected_keycol=>selected_keycol,
                           table_access=>table_access,
                           additional_columns=>empty_array );

END validate_upload_columns;


---------------------------------------------------------------------------
--  Name:
--      select_upload_proc_name
--
--  Description:
--      Upload step 4: Select additional columns and procedure name.
---------------------------------------------------------------------------
PROCEDURE select_upload_proc_name( procedure_type IN VARCHAR2 DEFAULT NULL,
                                   table_name IN VARCHAR2 DEFAULT NULL,
                                   doctable_name IN VARCHAR2 DEFAULT NULL,
                                   selected_columns IN vc2_array,
                                   selected_keycol IN VARCHAR2 DEFAULT NULL,
                                   table_access IN VARCHAR2 DEFAULT NULL,
                                   additional_columns IN vc2_array,
                                   procedure_name IN VARCHAR2 DEFAULT NULL,
                                   selected_function IN VARCHAR2 DEFAULT NULL,
                                   error_message IN VARCHAR2 DEFAULT NULL )
IS
  CURSOR other_cols_cursor( table_name_arg VARCHAR2, keycol_arg VARCHAR2) IS
    SELECT utc.column_name, utc.column_id
    FROM user_tab_columns utc
    WHERE utc.table_name = table_name_arg AND
          utc.data_type IN ( 'CHAR', 'VARCHAR', 'VARCHAR2',
                             'NCHAR', 'NVARCHAR', 'NVARCHAR2',
                             'NUMBER', 'DATE' ) AND
          utc.column_name <> keycol_arg
    ORDER BY utc.column_id;

  CURSOR cons_cursor( table_name_arg VARCHAR2, column_name_arg VARCHAR2 ) IS
      SELECT COUNT(*) cons_count
        FROM user_cons_columns ucc, all_constraints ac
        WHERE ucc.column_name = column_name_arg AND
              ucc.constraint_name = ac.constraint_name AND
              ac.owner = USER AND
              ac.table_name = table_name_arg AND
              ( ac.constraint_type = 'P' OR 
                ac.constraint_type = 'U' OR
                ac.constraint_type = 'C' );

  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
  default_proc_name VARCHAR2( 128 );
  checked VARCHAR2( 10 );
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 4: Select additional columns and procedure name',
                 ruler=>TRUE );

  --
  -- Display any error from previous form submission.
  --
  IF error_message IS NOT NULL
  THEN
    print_error_message( error_message );
  END IF;

  --
  -- Start form, passing table name, etc, to next procedure
  --
  form_open( 'validate_upload_proc_name' );
  print_upload_context( procedure_type=>procedure_type,
                        table_name=>table_name,
                        doctable_name=>doctable_name,
                        selected_columns=>selected_columns,
                        selected_keycol=>selected_keycol,
                        table_access=>table_access );

  --
  -- Display available non-multimedia columns in selected table
  -- Use dummy first entry in case no selections are made. Don't
  -- duplicate the key column. If first time through, then check all
  -- columns with either primrary key, unique, or not-null constraint.
  --
  htp.print( 'Optionally select any additional columns to be stored in the' );
  htp.print( 'table along with the media data. The primary key and any' );
  htp.print( 'columns with a unique or not-null constraint are selected' );
  htp.print( 'automatically. If updating an existing row, simply clear any' );
  htp.print( 'columns you do not wish to be stored. Note that the key column' );
  htp.print( 'selected in the previous step is always included.' ); 
  htp.ulistOpen;
  checked := 'checked';
  htp.formHidden( cname=>'additional_columns', cvalue=>'dummy' );
  FOR col IN other_cols_cursor( table_name, selected_keycol ) LOOP
    IF col.column_name <> selected_keycol
    THEN
      IF additional_columns.COUNT > 1
      THEN
        htmlp_form_checkbox( cname=>'additional_columns',
                             cvalue=>col.column_name,
                             clabel=>col.column_name,
                             cchecked=>checked,
                             cdefaults=>additional_columns );
      ELSE
        checked := NULL;
        FOR cons IN cons_cursor( table_name, col.column_name )
        LOOP
          IF cons.cons_count > 0
          THEN
            checked := 'checked';
          END IF;
          EXIT;
        END LOOP;
        htmlp_form_checkbox( cname=>'additional_columns',
                             cvalue=>col.column_name,
                             clabel=>col.column_name,
                             cchecked=>checked );
      END IF;
      htp.br;
    END IF;
  END LOOP;
  htp.ulistClose;

  --
  -- Select procedure name
  --
  IF procedure_name IS NULL
  THEN
    extract_column_name_and_info( selected_columns(2), column_name, column_type );
    default_proc_name := 'UPLOAD_' || table_name || '_' || column_name;
    default_proc_name := SUBSTR( default_proc_name, 1, 30 );
  ELSE
    default_proc_name := procedure_name;
  END IF;
  htp.print( 'Choose a name for the media upload procedure. You can accept' );
  htp.print( 'the default provided or supply a different name.' );
  htp.ulistOpen;
  htmlp_form_text_field( cname=>'procedure_name',
                         clabel=>'Procedure name: ',
                         csize=>'30',
                         cmaxlength=>'30',
                         cvalue=>default_proc_name );
  htp.ulistClose;

  --
  -- Select function if standalone procedure - only option is to view package
  -- procedure source.
  --
  IF procedure_type = 'Standalone'
  THEN
    htp.print( 'Choose either to create the procedure in the database or' );
    htp.print( 'to generate the procedure source code only. In either case' );
    htp.print( 'you will subsequently have the opportunity to view the' );
    htp.print( 'generated source code.' );
    htp.ulistOpen;
    checked := 'checked';
    htmlp_form_radio( cname=>'selected_function',
                      cvalue=>'create',
                      clabel=>'Create procedure in the database',
                      cchecked=>checked,
                      cdefault=>selected_function );
    htp.br;
    htmlp_form_radio( cname=>'selected_function',
                      cvalue=>'view',
                      clabel=>'Generate procedure source only',
                      cchecked=>checked,
                      cdefault=>selected_function );
    htp.ulistClose;
  ELSE
    htp.formHidden( cname=>'selected_function', cvalue=>'view' );
  END IF;

  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, next_button=>TRUE,
            step_num=>4, num_steps=>num_upload_steps );

  --
  -- Output common page trailer
  --
  print_page_trailer;

END select_upload_proc_name;


---------------------------------------------------------------------------
--  Name:
--      validate_upload_proc_name
--
--  Description:
--      Upload step 4: Validate the selected non-media columns
---------------------------------------------------------------------------
PROCEDURE validate_upload_proc_name( procedure_type IN VARCHAR2,
                                     table_name IN VARCHAR2,
                                     doctable_name IN VARCHAR2,
                                     selected_columns IN vc2_array,
                                     selected_keycol IN VARCHAR2,
                                     table_access IN VARCHAR2,
                                     additional_columns IN vc2_array,
                                     procedure_name IN VARCHAR2,
                                     selected_function IN VARCHAR2,
                                     form_action IN VARCHAR2 )
IS
  i INTEGER;
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_upload_columns( procedure_type=>procedure_type,
                           table_name=>table_name,
                           doctable_name=>doctable_name,
                           selected_columns=>selected_columns,
                           selected_keycol=>selected_keycol,
                           table_access=>table_access );
    RETURN;
  END IF;

  --
  -- Validate input
  --
  IF procedure_name IS NULL
  THEN
    select_upload_proc_name( procedure_type=>procedure_type,
                             table_name=>table_name,
                             doctable_name=>doctable_name,
                             selected_columns=>selected_columns,
                             selected_keycol=>selected_keycol,
                             additional_columns=>additional_columns,
                             table_access=>table_access,
                             procedure_name=>procedure_name,
                             selected_function=>selected_function,
                             error_message=>'Please select a procedure name' );
    RETURN;
  END IF;

  --
  -- Display summary
  --
  display_upload_summary( procedure_type=>procedure_type,
                          table_name=>table_name,
                          doctable_name=>doctable_name,
                          selected_columns=>selected_columns,
                          selected_keycol=>selected_keycol,
                          additional_columns=>additional_columns,
                          table_access=>table_access,
                          procedure_name=>procedure_name,
                          selected_function=>selected_function );

END validate_upload_proc_name;


---------------------------------------------------------------------------
--  Name:
--      display_upload_summary
--
--  Description:
--      Upload step 5: Review summary
---------------------------------------------------------------------------
PROCEDURE display_upload_summary( procedure_type IN VARCHAR2,
                                  table_name IN VARCHAR2,
                                  doctable_name IN VARCHAR2,
                                  selected_columns IN vc2_array,
                                  selected_keycol IN VARCHAR2,
                                  additional_columns IN vc2_array,
                                  table_access IN VARCHAR2,
                                  procedure_name IN VARCHAR2,
                                  selected_function IN VARCHAR2 )

IS
  table_data VARCHAR2( 2000 );
BEGIN
  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Tell them what we're doing
  --
  print_message( 'Step 5: Review selected options', ruler=>TRUE );

  --
  -- Display summary table
  --
  htp.print( 'Click the <B>Finish</B> button if the following options are' );
  htp.print( 'correct.' );
  htp.uListOpen;
  html_table_open( blayout=>TRUE, cscope=>'row' );

  --
  -- Display selected options
  --
  htp.tableRowOpen;
  htp.tableData( cvalue=>'Procedure type:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>procedure_type, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Table name:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>table_name, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Media column(s):', 
                 cattributes=>'VALIGN="top" SCOPE="row"' );
  table_data := selected_columns( 2 );
  FOR i IN 3..selected_columns.COUNT LOOP
    table_data := table_data || '<BR>' || selected_columns( i );
  END LOOP;
  htp.tableData( cvalue=>table_data, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Key column:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>selected_keycol, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Additional column(s):', 
                 cattributes=>'VALIGN="top" SCOPE="row"' );
  IF additional_columns.COUNT > 1
  THEN
    table_data := additional_columns( 2 );
    FOR i IN 3..additional_columns.COUNT LOOP
      table_data := table_data || '<BR>' || additional_columns( i );
    END LOOP;
  ELSE
    table_data := '--none--';
  END IF;
  htp.tableData( cvalue=>table_data, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Table access mode:', cattributes=>'SCOPE="row"'  );
  IF table_access = 'insert' 
  THEN
    table_data := 'Insert';
  ELSIF table_access = 'update' 
  THEN
    table_data := 'Update';
  ELSE
    table_data := 'Conditional update or insert';
  END IF;
  htp.tableData( cvalue=>table_data, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Procedure name:', cattributes=>'SCOPE="row"'  );
  htp.tableData( cvalue=>procedure_name, cattributes=>'SCOPE="row"'  );
  htp.tableRowClose;

  htp.tableRowOpen;
  htp.tableData( cvalue=>'Function:', cattributes=>'SCOPE="row"'  );
  IF selected_function = 'create' 
  THEN
    htp.tableData( cvalue=>'Create procedure in the database',
                   cattributes=>'SCOPE="row"' );
  ELSE
    htp.tableData( cvalue=>'Generate procedure source only',
                   cattributes=>'SCOPE="row"' );
  END IF;
  htp.tableRowClose;

  --
  -- End of summary table
  --
  htp.tableClose;
  htp.uListClose;

  --
  -- Start form, passing all data to next procedure
  --
  form_open( 'generate_upload_procedure' );
  print_upload_context( procedure_type=>procedure_type,
                        table_name=>table_name,
                        doctable_name=>doctable_name,
                        selected_columns=>selected_columns,
                        selected_keycol=>selected_keycol,
                        additional_columns=>additional_columns,
                        table_access=>table_access,
                        procedure_name=>procedure_name,
                        selected_function=>selected_function );

  --
  -- End of form
  --
  form_close( cancel_button=>TRUE, back_button=>TRUE, finish_button=>TRUE,
            step_num=>5, num_steps=>num_upload_steps );

END display_upload_summary;


---------------------------------------------------------------------------
--  Name:
--      generate_upload_procedure
--
--  Description:
--      Generate upload procedure.
---------------------------------------------------------------------------
PROCEDURE generate_upload_procedure( procedure_type IN VARCHAR2,
                                     table_name IN VARCHAR2,
                                     doctable_name IN VARCHAR2,
                                     selected_columns IN vc2_array,
                                     selected_keycol IN VARCHAR2,
                                     additional_columns IN vc2_array,
                                     table_access IN VARCHAR2,
                                     procedure_name IN VARCHAR2,
                                     selected_function IN VARCHAR2,
                                     form_action IN VARCHAR2 )
IS
  compiled_successfully BOOLEAN := FALSE;
  button_name VARCHAR2( 10 );
  dad_name VARCHAR2( 64 );
  dad_doctable_name VARCHAR2( 30 );
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Cancel'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    select_upload_proc_name( procedure_type=>procedure_type,
                             table_name=>table_name,
                             doctable_name=>doctable_name,
                             selected_columns=>selected_columns,
                             selected_keycol=>selected_keycol,
                             additional_columns=>additional_columns,
                             table_access=>table_access,
                             procedure_name=>procedure_name,
                             selected_function=>selected_function );
    RETURN;
  END IF;

  --
  -- Output common page header
  --
  print_page_header;

  --
  -- Create and compile generated procedure if so directed.
  --
  IF selected_function = 'create'
  THEN
    BEGIN
      print_message( 'Compile procedure and review generated source',
                     ruler=>TRUE );
      generate_upload_proc_source( procedure_type=>procedure_type,
                                   table_name=>table_name,
                                   doctable_name=>doctable_name,
                                   selected_columns=>selected_columns,
                                   selected_keycol=>selected_keycol,
                                   additional_columns=>additional_columns,
                                   table_access=>table_access,
                                   procedure_name=>procedure_name );
      EXECUTE IMMEDIATE source_buf;
      print_message( 'Procedure created successfully: ' );
      htp.print( htmlf_tt( procedure_name ) );
      compiled_successfully := TRUE;
    EXCEPTION
      WHEN OTHERS THEN
        IF SQLCODE = -24344
        THEN
          print_error_message( 'The following errors were encountered compiling' ||
                               htmlf_tt( procedure_name ) );
          show_compilation_errors( procedure_name );
        ELSE
          print_message( 'Error creating procedure: ' );
          htp.print( htmlf_tt( procedure_name ) );
          print_error_message( htmlf_tt( SQLERRM ) );
        END IF;
    END;
  ELSE
    print_message( 'Review generated source', ruler=>TRUE );
  END IF;

  --
  -- If compiled successfully, show compiled source button, otherwise, show
  -- generated source button.
  --
  IF compiled_successfully
  THEN
    print_compiled_source_button( procedure_name );
  ELSE
    html_p_open;
    htp.print( 'Click the <B>View</B> button to display the generated PL/SQL' );
    htp.print( 'source code in a pop-up window.' );
    htp.print( 'To save the source in a file for editing, select' );
    htp.print( '<B>Save As...</B> from your browser''s <B>File</B>' );
    htp.print( 'pull-down menu.' );
    htp.ulistOpen;
    form_open( proc_name=>'view_upload_source', target=>'_blank' );
    print_upload_context( procedure_type=>procedure_type,
                          table_name=>table_name,
                          doctable_name=>doctable_name,
                          selected_columns=>selected_columns,
                          selected_keycol=>selected_keycol,
                          additional_columns=>additional_columns,
                          table_access=>table_access,
                          procedure_name=>procedure_name );
    htp.prn( 'Click to display generated source: ' );
    htp.formSubmit( cvalue=>'View' );
    form_close( menu_bar=>FALSE );
    htp.ulistClose;
    html_p_close;
  END IF;

  --
  -- Test the created procedure, if possible, ie, if we tried to create it.
  --
  dad_name := LOWER( owa_util.get_cgi_env( 'DAD_NAME' ) );
  dad_doctable_name := UPPER( owa_util.get_cgi_env( 'DOCUMENT_TABLE' ) );
  html_p_open;
  IF selected_function = 'create'
  THEN
    htp.print( 'Enter a DAD name,' );
    IF doctable_name = dad_doctable_name
    THEN
      htp.print( 'or accept the default provided,' );
    ELSE
      dad_name := NULL;
    END IF;
    htp.print( 'then click the <B>Test</B> button to' );
    htp.print( 'display an HTML form in a pop-up window to upload media' );
    htp.print( 'to the database to test the generated PL/SQL procedure.' );
    button_name := 'Test';
  ELSE
    htp.print( 'Enter a DAD name, then click the <B>View</B> button to' );
    htp.print( 'display a template HTML form in a pop-up window which you' );
    htp.print( 'can edit and then use to upload media to the database' );
    htp.print( 'using the generated PL/SQL procedure.' );
    button_name := 'View';
  END IF;
  htp.print( 'To save the source in a file for editing, select' );
  htp.print( '<B>Save As...</B> from your browser''s <B>File</B>' );
  htp.print( 'pull-down menu.' );
  htp.ulistClose;
  IF doctable_name <> dad_doctable_name
  THEN
    html_p_open;
    htp.print( '<B>Note:</B>' || NBSP || NBSP || NBSP || 'You must configure' );
    htp.print( 'the DAD, specifying the document table name as' );
    htp.print( htmlf_tt( doctable_name ) || ', before you can' );
    htp.print( 'test the generated procedure.' );
    html_p_close;
  END IF;
  htp.ulistOpen;
  form_open( proc_name=>'view_upload_form', target=>'_blank' );
  print_upload_context( procedure_type=>procedure_type,
                        table_name=>table_name,
                        doctable_name=>doctable_name,
                        selected_columns=>selected_columns,
                        selected_keycol=>selected_keycol,
                        additional_columns=>additional_columns,
                        table_access=>table_access,
                        procedure_name=>procedure_name );
  htmlp_form_text_field( cname=>'test_dad_name',
                         cvalue=>dad_name,
                         clabel=>'DAD: ',
                         csize=>'20', 
                         cmaxlength=>'100' );
  htp.formSubmit( cvalue=>button_name );
  form_close( menu_bar=>FALSE );
  htp.ulistClose;

  --
  -- Display standard action bar
  --
  form_open( 'generate_upload_done' );
  print_upload_context( procedure_type=>procedure_type,
                        table_name=>table_name,
                        doctable_name=>doctable_name,
                        selected_columns=>selected_columns,
                        selected_keycol=>selected_keycol,
                        additional_columns=>additional_columns,
                        table_access=>table_access,
                        procedure_name=>procedure_name,
                        selected_function=>selected_function );
  form_close( done_button=>TRUE, back_button=>TRUE );

  --
  -- Output common page trailer
  --
  print_page_trailer;

END generate_upload_procedure;


---------------------------------------------------------------------------
--  Name:
--      generate_upload_done
--
--  Description:
--      Completion for upload procedure
---------------------------------------------------------------------------
PROCEDURE generate_upload_done( procedure_type IN VARCHAR2,
                                table_name IN VARCHAR2,
                                doctable_name IN VARCHAR2,
                                selected_columns IN vc2_array,
                                selected_keycol IN VARCHAR2,
                                additional_columns IN vc2_array,
                                table_access IN VARCHAR2,
                                procedure_name IN VARCHAR2,
                                selected_function IN VARCHAR2,
                                form_action IN VARCHAR2 )
IS
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Handle cancel/back/next action
  --
  IF form_action = 'Done'
  THEN
    menu();
    RETURN;
  ELSIF form_action = 'Back'
  THEN
    display_upload_summary( procedure_type=>procedure_type,
                            table_name=>table_name,
                            doctable_name=>doctable_name,
                            selected_columns=>selected_columns,
                            selected_keycol=>selected_keycol,
                            additional_columns=>additional_columns,
                            table_access=>table_access,
                            procedure_name=>procedure_name,
                            selected_function=>selected_function );
    RETURN;
  END IF;
  menu();
END generate_upload_done;


---------------------------------------------------------------------------
--  Name:
--      view_upload_source
--
--  Description:
--      View generated procedure source.
--
---------------------------------------------------------------------------
PROCEDURE view_upload_source( procedure_type IN VARCHAR2,
                              table_name IN VARCHAR2,
                              doctable_name IN VARCHAR2,
                              selected_columns IN vc2_array,
                              selected_keycol IN VARCHAR2,
                              additional_columns IN vc2_array,
                              table_access IN VARCHAR2,
                              procedure_name IN VARCHAR2 )
IS
BEGIN
  --
  -- Check DAD is authorized.
  --
  IF NOT check_dad  
  THEN
    RETURN;
  END IF;

  --
  -- Generate and display source
  --
  generate_upload_proc_source( procedure_type=>procedure_type,
                               table_name=>table_name,
                               doctable_name=>doctable_name,
                               selected_columns=>selected_columns,
                               selected_keycol=>selected_keycol,
                               additional_columns=>additional_columns,
                               table_access=>table_access,
                               procedure_name=>procedure_name );
  owa_util.mime_header( 'text/plain', TRUE );
  htp.prn( source_buf );
END view_upload_source;


---------------------------------------------------------------------------
--  Name:
--      generate_upload_proc_source
--
--  Description:
--      Generates upload procedure source.
--
---------------------------------------------------------------------------
PROCEDURE generate_upload_proc_source( procedure_type IN VARCHAR2,
                                       table_name IN VARCHAR2,
                                       doctable_name IN VARCHAR2,
                                       selected_columns IN vc2_array,
                                       selected_keycol IN VARCHAR2,
                                       additional_columns IN vc2_array,
                                       table_access IN VARCHAR2,
                                       procedure_name IN VARCHAR2 )
IS
  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
  sep VARCHAR2( 20 );
  ins_indent VARCHAR2( 4 ) := '  ';
  store_media_sql VARCHAR2( 4000 );
  set_content_len_sql VARCHAR2( 128 );
BEGIN
  --
  -- Note that, unlike retrieval procedures, large chunks of upload
  -- procedures have to be created 'on the fly', rather than using
  -- simple string substitution, although that is used where possible.
  -- Start by reseting SQL buffer.
  --
  source_buf := '';

  --
  -- Write procedure signature:
  --
  --  CREATE OR REPLACE PROCEDURE %procedure-name%
  --    ( in_%keycol_name% IN VARCHAR2,
  --      in_%media-col-name% IN VARCHAR2 DEFAULT NULL [, ...]
  --     [in_%other-col-name% IN VARCHAR2 DEFAULT NULL [, ...]] )
  --  AS
  --
  -- Or:
  --
  --  -- add to package: 
  --  
  --  PROCEDURE %procedure-name%
  --    ( in_%keycol_name% IN VARCHAR2,
  --      in_%media-col-name% IN VARCHAR2 DEFAULT NULL [, ...]
  --     [in_%other-col-name% IN VARCHAR2 DEFAULT NULL [, ...]] );
  --  
  --  -- add to package body:
  --  
  --  PROCEDURE %procedure-name%
  --    ( in_%keycol_name% IN VARCHAR2,
  --      in_%media-col-name% IN VARCHAR2 DEFAULT NULL [, ...]
  --     [in_%other-col-name% IN VARCHAR2 DEFAULT NULL [, ...]] )
  --  IS
  --
  IF procedure_type = 'Standalone'
  THEN
    generate_upload_proc_sig( procedure_type=>procedure_type,
                              selected_columns=>selected_columns,
                              selected_keycol=>selected_keycol,
                              additional_columns=>additional_columns,
                              procedure_name=>procedure_name );
  ELSE
    generate_upload_proc_sig( procedure_type=>procedure_type,
                              selected_columns=>selected_columns,
                              selected_keycol=>selected_keycol,
                              additional_columns=>additional_columns,
                              procedure_name=>procedure_name,
                              package_spec=>TRUE );
    generate_upload_proc_sig( procedure_type=>procedure_type,
                              selected_columns=>selected_columns,
                              selected_keycol=>selected_keycol,
                              additional_columns=>additional_columns,
                              procedure_name=>procedure_name,
                              package_spec=>FALSE );
  END IF;

  --
  -- Declare local variables:
  --
  --    local_%media-col-name% ORDSYS.%media-col-type% :=
  --                                        ORDSYS.%media-col-type%.init();
  --   [local_%media-col-name%_ctx RAW( 64 );]
  --   [...]
  --   [local_%keycol_name% %table-name%.%keycol-name%.TYPE;]
  --    upload_size     INTEGER;
  --    upload_mimetype VARCHAR2( 128 );
  --    upload_blob     BLOB;
  --  BEGIN
  --
  FOR i IN 2 .. selected_columns.COUNT LOOP
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    wrtsrcln( '  local_' || column_name ||
               ' ORDSYS.' || column_type || ' :=' ||
               ' ORDSYS.' || column_type || '.init();');
    IF column_type <> 'ORDIMAGE'
    THEN
      wrtsrcln( '  ' || sql_ident( LOCAL_, column_name, CTX_ ) || ' RAW( 64 );' );
    END IF;
  END LOOP;
  IF table_access = 'update_insert'
  THEN
    wrtsrcln( '  ' || sql_ident( LOCAL_, selected_keycol ) || ' ' ||
                      table_name || '.' || selected_keycol || '%TYPE := NULL;' );
  END IF;
  wrtsrcln( '  upload_size     INTEGER;' );
  wrtsrcln( '  upload_mimetype VARCHAR2( 128 );' );
  wrtsrcln( '  upload_blob     BLOB;' );
  wrtsrcln( 'BEGIN' );

  --
  -- Update row if table_access parameter is update or update_isert
  --
  IF table_access = 'update' OR table_access = 'update_insert'
  THEN
    --
    -- Create update statement:
    --
    --   --
    --   -- Update table with initialized interMedia object(s).
    --   --
    --   UPDATE %table-name% mtbl
    --     SET mtbl.%media-col-name% = local_%media-col-name% [,...]
    --        [mtbl.%other-col-name% = in_%other-col-name% [,...]]
    --     WHERE mtbl.%keycol_name% = in_%keycol_name%
    --    [RETURN mtbl.%keycol_name% INTO local_%keycol-name%];
    --
    wrtsrcln( '  --' );
    wrtsrcln( '  -- Update existing row' );
    wrtsrcln( '  --' );
    wrtsrcln( '  UPDATE ' || table_name || ' mtbl' );
    sep := '    SET ';
    FOR i IN 2 .. selected_columns.COUNT LOOP
      extract_column_name_and_info( selected_columns( i ),
                                    column_name,
                                    column_type );
      wrtsrc( sep || 'mtbl.' || column_name || ' = local_' || column_name );
      sep := ',' || LF || '        ';
    END LOOP;
    FOR i IN 2 .. additional_columns.COUNT LOOP
      wrtsrc( sep || 'mtbl.' || additional_columns( i ) ||
               ' = ' || sql_ident( IN_, additional_columns( i ) ) );
    END LOOP;
    wrtsrcln;
    wrtsrc( '    WHERE mtbl.' || selected_keycol || ' = ' || 
            sql_ident( IN_, selected_keycol ) );
    IF table_access = 'update_insert'
    THEN
      wrtsrcln;
      wrtsrc( '    RETURN mtbl.' || selected_keycol || 
                 ' INTO ' || sql_ident( LOCAL_, selected_keycol ) );
    END IF;
    wrtsrcln( ';' );
  END IF;

  --
  -- Conditionally insert row if table_access parameter is update_isert
  --
  --   --
  --   -- Conditionally insert new row into table
  --   --
  --   IF local_%keycol-name% IS NULL
  --   THEN
  --
  IF table_access = 'update_insert'
  THEN
    wrtsrcln;
    wrtsrcln( '  --' );
    wrtsrcln( '  -- Conditionally insert new row if no existing row updated' );
    wrtsrcln( '  --' );
    wrtsrcln( '  IF ' || sql_ident( LOCAL_, selected_keycol ) || ' IS NULL' );
    wrtsrcln( '  THEN' );
    ins_indent := '    ';
  END IF;

  --
  -- Insert row if table_access parameter is insert or update_isert
  --
  IF table_access = 'insert' OR table_access = 'update_insert'
  THEN
    --
    -- Create insert statement:
    --
    --   --
    --   -- Insert new row into table
    --   --
    --   INSERT INTO %table-name% ( %keycol-name%, %media-col-name% [, ...]
    --                              [, %other-col-name% [, ...]] )
    --     VALUES ( in_%keycol-name%, local_%media-col-name% [, ...]
    --              [, in_%other-col-name% [, ...]] );
    --
    wrtsrcln( ins_indent || '--' );
    wrtsrcln( ins_indent || '-- Insert new row into table' );
    wrtsrcln( ins_indent || '--' );
    wrtsrc( ins_indent || 'INSERT INTO ' || table_name || ' ( ' );
    wrtsrc( selected_keycol );
    sep := ', ';
    FOR i IN 2 .. selected_columns.COUNT LOOP
      extract_column_name_and_info( selected_columns( i ),
                                    column_name,
                                    column_type );
      wrtsrc( sep || column_name );
    END LOOP;
    FOR i IN 2 .. additional_columns.COUNT LOOP
      wrtsrc( sep || additional_columns( i ) );
    END LOOP;
    wrtsrcln( ' )' );
    wrtsrc( ins_indent || '  VALUES ( ' );
    wrtsrc( sql_ident( IN_, selected_keycol ) );
    FOR i IN 2 .. selected_columns.COUNT LOOP
      extract_column_name_and_info( selected_columns( i ),
                                    column_name,
                                    column_type );
      wrtsrc( sep || 'local_' || column_name );
    END LOOP;
    FOR i IN 2 .. additional_columns.COUNT LOOP
      wrtsrc( sep || sql_ident( IN_, additional_columns( i ) ) );
    END LOOP;
    wrtsrcln( ' );' );
  END IF;

  --
  -- End conditional insert:
  --
  --  END IF;
  --
  IF table_access = 'update_insert'
  THEN
    wrtsrcln( '  END IF;' );
  END IF;

  --
  -- Create select statement to select media objects for update:
  --
  --   --
  --   -- Select interMedia object(s) for update.
  --   --
  --   SELECT mtbl.%media-col-name% [,...] INTO local_%media-col_name% [, ...]
  --     FROM %table-name% mtbl WHERE mtbl.%keycol-name% = in_%keycol-name% FOR UPDATE;
  --
  wrtsrcln;
  wrtsrcln( '  --' );
  wrtsrcln( '  -- Select interMedia object(s) for update' );
  wrtsrcln( '  --' );
  wrtsrc(   '  SELECT' );
  sep := ' ';
  FOR i IN 2 .. selected_columns.COUNT LOOP
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    wrtsrc( sep || 'mtbl.' || column_name );
    sep := ', ';
  END LOOP;
  wrtsrc( ' INTO' );
  sep := ' ';
  FOR i IN 2 .. selected_columns.COUNT LOOP
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    wrtsrc( sep || 'local_' || column_name );
    sep := ', ';
  END LOOP;
  wrtsrcln;
  wrtsrcln( '    FROM ' || table_name || ' mtbl' ||
            ' WHERE mtbl.' || selected_keycol || ' = ' || 
                    sql_ident( IN_, selected_keycol ) || ' FOR UPDATE;' );
  wrtsrcln;

  --
  -- Create SQL to store media data and set properties.
  --
  --  --
  --  -- Store media data for column %media-col-name%
  --  --
  --  IF in_%media-col-name% IS NOT NULL
  --  THEN
  --    SELECT dtbl.doc_size, dtbl.mime_type, dtbl.blob_content INTO
  --           upload_size, upload_mimetype, upload_blob
  --      FROM %doctable-name% dtbl WHERE dtbl.name = in_%media-col-name%;
  --    IF upload_size > 0
  --    THEN
  --      dbms_lob.copy( local_%media-col-name%.source.localData,
  --                     upload_blob,
  --                     upload_size );
  --      local_%media-col-name%.setLocal();
  --      BEGIN
  --        local_%media-col-name%.setProperties(%format-ctx-arg%);
  --      EXCEPTION
  --        WHEN OTHERS THEN
  --  '%set-content-length%'
  --          local_%media-col-name%.mimeType := upload_mimetype;
  --      END;
  --    END IF;
  --    DELETE FROM %doctable-name% dtbl WHERE dtbl.name = in_%media-col-name%;
  --  END IF;
  --
  FOR i IN 2 .. selected_columns.COUNT LOOP
    store_media_sql := store_media_template;
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    store_media_sql := REPLACE( store_media_sql,
                                '%media-col-arg-name%',
                                sql_ident( IN_, column_name ) );
    store_media_sql := REPLACE( store_media_sql,
                                '%media-col-local-name%',
                                sql_ident( LOCAL_, column_name ) );
    store_media_sql := REPLACE( store_media_sql,
                                '%doctable-name%',
                                doctable_name );
    IF column_type = 'ORDIMAGE'
    THEN
      store_media_sql := REPLACE( store_media_sql, '%set-props-args%', '' );
    ELSIF column_type = 'ORDDOC'
    THEN
      store_media_sql := REPLACE( store_media_sql,
                                  '%set-props-args%',
                                  sql_ident( LOCAL_, column_name, CTX_ ) || 
                                  ', FALSE' );
    ELSE
      store_media_sql := REPLACE( store_media_sql,
                                  '%set-props-args%',
                                  sql_ident( LOCAL_, column_name, CTX_ ) );
    END IF;
    IF column_type = 'ORDAUDIO' OR column_type = 'ORDVIDEO'
    THEN
      store_media_sql := REPLACE( store_media_sql, '%set-content-length%', '' );
    ELSE
      set_content_len_sql := '          ' ||
                             'local_' || column_name || '.contentLength' ||
                             ' := upload_size;' || LF;

      store_media_sql := REPLACE( store_media_sql,
                                  '%set-content-length%',
                                  set_content_len_sql );
    END IF;
    wrtsrc( store_media_sql );
  END LOOP;

  --
  -- Create update statement to update media objects
  --
  --   --
  --   -- Update interMedia objects in table
  --   --
  --   UPDATE %table-name% mtbl
  --     SET mtbl.%media-col-name% = local_%media-col-name% [,...]
  --     WHERE mtbl.%keycol-name% = in_%keycol-name%
  --
  wrtsrcln( '  --' );
  wrtsrcln( '  -- Update interMedia objects in table' );
  wrtsrcln( '  --' );
  wrtsrcln( '  UPDATE ' || table_name || ' mtbl' );
  sep := '    SET ';
  FOR i IN 2 .. selected_columns.COUNT LOOP
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    wrtsrc( sep || 'mtbl.' || column_name || ' = local_' || column_name );
    sep := ',' || LF || '        ';
  END LOOP;
  wrtsrcln;
  wrtsrcln( '    WHERE mtbl.' || selected_keycol || ' = ' || 
                       sql_ident( IN_, selected_keycol ) || ';' );
  wrtsrcln;

  --
  -- Create SQL to display template completion message
  --
  --   --
  --   -- Display completion message
  --   --
  --   htp.print( ... );
  --
  -- END %procedure-name%;
  --
  --   --
  --   -- Display completion message
  --   --
  --   htp.print( ... );
  wrtsrcln( upload_done_message  );

  --
  -- End of procedure
  --
  wrtsrcln( 'END ' || procedure_name || ';' );
END generate_upload_proc_source;


---------------------------------------------------------------------------
--  Name:
--      generate_upload_proc_sig
--
--  Description:
--      Generates upload procedure signature
--
---------------------------------------------------------------------------
PROCEDURE generate_upload_proc_sig( procedure_type IN VARCHAR2,
                                    selected_columns IN vc2_array,
                                    selected_keycol IN VARCHAR2,
                                    additional_columns IN vc2_array,
                                    procedure_name IN VARCHAR2,
                                    package_spec IN BOOLEAN DEFAULT FALSE )
IS
  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
BEGIN
  --
  -- Write procedure signature:
  --
  --  CREATE OR REPLACE PROCEDURE %procedure-name%
  --    ( in_%keycol_name% IN VARCHAR2,
  --      in_%media-col-name% IN VARCHAR2 DEFAULT NULL [, ...]
  --     [in_%other-col-name% IN VARCHAR2 DEFAULT NULL [, ...]] )
  --  AS
  --
  -- Or:
  --
  --  -- add to package: 
  --  
  --  PROCEDURE %procedure-name%
  --    ( in_%keycol_name% IN VARCHAR2,
  --      in_%media-col-name% IN VARCHAR2 DEFAULT NULL [, ...]
  --     [in_%other-col-name% IN VARCHAR2 DEFAULT NULL [, ...]] );
  --  
  --  -- add to package body:
  --  
  --  PROCEDURE %procedure-name%
  --    ( in_%keycol_name% IN VARCHAR2,
  --      in_%media-col-name% IN VARCHAR2 DEFAULT NULL [, ...]
  --     [in_%other-col-name% IN VARCHAR2 DEFAULT NULL [, ...]] )
  --  IS
  --
  IF procedure_type = 'Standalone'
  THEN
    wrtsrc( 'CREATE OR REPLACE ' );
  ELSE
    IF package_spec
    THEN
      wrtsrcln;
      wrtsrcln( '-- add to package' );
      wrtsrcln;
    ELSE
      wrtsrcln;
      wrtsrcln( '-- add to package body' );
      wrtsrcln;
    END IF;
  END IF;
  wrtsrcln( 'PROCEDURE ' || procedure_name );
  wrtsrc( '  ( ' || sql_ident( IN_, selected_keycol ) || IN_VARCHAR2 );
  FOR i IN 2 .. selected_columns.COUNT LOOP
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    wrtsrcln( ',' );
    wrtsrc( '    '  || sql_ident( IN_, column_name ) || in_varchar2_null );
  END LOOP;
  FOR i IN 2 .. additional_columns.COUNT LOOP
    wrtsrcln( ',' );
    wrtsrc( '    ' || sql_ident( IN_, additional_columns( i ) ) || in_varchar2_null );
  END LOOP;
  IF procedure_type = 'Standalone'
  THEN
    wrtsrcln( ' )' );
    wrtsrcln( 'AS' );
  ELSE
    IF package_spec
    THEN
      wrtsrcln( ' );' );
    ELSE
      wrtsrcln( ' )' );
      wrtsrcln( 'IS' );
    END IF;
  END IF;
END generate_upload_proc_sig;


---------------------------------------------------------------------------
--  Name:
--      view_upload_form
--
--  Description:
--      Generates a [template] HTML upload test form
--
---------------------------------------------------------------------------
PROCEDURE view_upload_form( procedure_type IN VARCHAR2,
                            table_name IN VARCHAR2,
                            doctable_name IN VARCHAR2,
                            selected_columns IN vc2_array,
                            selected_keycol IN VARCHAR2,
                            additional_columns IN vc2_array,
                            table_access IN VARCHAR2,
                            procedure_name IN VARCHAR2,
                            test_dad_name IN VARCHAR2 )
IS
  column_name VARCHAR2( 128 );
  column_type VARCHAR2( 128 );
  form_url VARCHAR2( 256 );
BEGIN
  --
  -- Generate URL for form action.
  --
  form_url := owa_util.get_cgi_env( 'SCRIPT_PREFIX' ) || '/' ||
              test_dad_name || '/';
  IF procedure_type = 'Standalone'
  THEN
    form_url := form_url || LOWER( procedure_name );
  ELSE
    form_url := form_url || 'package_name.' || LOWER( procedure_name );
  END IF;

  --
  -- Generate template upload form.
  --
  htp.print( '<HTML LANG="EN">' );
  htp.headOpen;
  htp.title( 'interMedia Code Wizard: Template Upload Form' );
  htp.headClose;
  htp.bodyOpen;
  htp.header( 2, '<I>inter</I>Media Code Wizard: Template Upload Form' );
  htp.formOpen( curl=>form_url, 
                cmethod=>'POST', 
                cenctype=>'multipart/form-data' );
  html_table_open( blayout=>TRUE );
  htp.tableRowOpen;
  htp.tableData( cvalue=>htmlf_label( sql_ident( IN_, LOWER( selected_keycol ) ), 
                                      UPPER( selected_keycol ) || ':' ),
                 cattributes=>'SCOPE="row"' );
  htp.tableData( cvalue=>htf.formText( cname=>sql_ident( IN_, LOWER( selected_keycol ) ) ,
					                   cattributes=>htmlf_id( sql_ident( IN_, LOWER( selected_keycol ) ) ) 
									 ) );									 
  htp.tableRowClose;

  FOR i IN 2 .. selected_columns.COUNT LOOP
    htp.tableRowOpen;
    extract_column_name_and_info( selected_columns( i ),
                                  column_name,
                                  column_type );
    htp.tableData( cvalue=>htmlf_label( sql_ident( IN_, LOWER( column_name ) ), 
	                                    UPPER( column_name ) || ':' ),
                   cattributes=>'SCOPE="row"' );
    htp.tableData( cvalue=>htf.formFile( cname=>sql_ident( IN_, LOWER( column_name ) ),
	                                     cattributes=>htmlf_id( sql_ident( IN_, LOWER( column_name ) ) ) 
										) );
    htp.tableRowClose;
  END LOOP;

  FOR i IN 2 .. additional_columns.COUNT LOOP
    htp.tableRowOpen;
    htp.tableData( cvalue=>htmlf_label( sql_ident( IN_, LOWER( additional_columns( i ) ) ), 
	                                    UPPER( additional_columns( i ) ) || ':' ),
                   cattributes=>'SCOPE="row"' );
    htp.tableData( cvalue=>htf.formText( cname=>sql_ident( IN_, LOWER( additional_columns( i ) ) ),
	                                     cattributes=>htmlf_id( sql_ident( IN_, LOWER( additional_columns( i ) ) ) ) 
										) );
    htp.tableRowClose;
  END LOOP;
  htp.tableClose;
  htp.formSubmit( cvalue=>'Upload media' );
  htp.formClose;
  htp.bodyClose;
  htp.htmlClose;

END view_upload_form;

---------------------------------------------------------------------------
--  Name:
--      wrtsrc
--
--  Description:
--      'Write' some SQL to the generated upload procedure.
---------------------------------------------------------------------------
PROCEDURE wrtsrc( sql_string IN VARCHAR2 )
IS
BEGIN
  source_buf := source_buf || sql_string;
END wrtsrc;


---------------------------------------------------------------------------
--  Name:
--      wrtsrcln
--
--  Description:
--      'Write' some SQL to the generated upload procedure with a new-line.
---------------------------------------------------------------------------
PROCEDURE wrtsrcln( sql_string IN VARCHAR2 )
IS
BEGIN
  source_buf := source_buf || sql_string || LF;
END wrtsrcln;


---------------------------------------------------------------------------
--  Name:
--      print_download_context
--
--  Description:
--      Print download context as hidden fields or query string parameters.
--
---------------------------------------------------------------------------
PROCEDURE print_download_context( procedure_type IN VARCHAR2 DEFAULT NULL,
                                  table_name IN VARCHAR2 DEFAULT NULL,
                                  selected_column IN VARCHAR2 DEFAULT NULL,
                                  selected_keycol IN VARCHAR2 DEFAULT NULL,
                                  procedure_name IN VARCHAR2 DEFAULT NULL,
                                  parameter_name IN VARCHAR2 DEFAULT NULL,
                                  selected_function IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
  print_context_data( 'procedure_type', procedure_type );
  print_context_data( 'table_name', table_name );
  print_context_data( 'selected_column', selected_column );
  print_context_data( 'selected_keycol', selected_keycol );
  print_context_data( 'procedure_name', procedure_name );
  print_context_data( 'parameter_name', parameter_name );
  print_context_data( 'selected_function', selected_function );
END print_download_context;


---------------------------------------------------------------------------
--  Name:
--      print_upload_context
--
--  Description:
--      Print upload context as hidden fields or query string parameters.
--
---------------------------------------------------------------------------
PROCEDURE print_upload_context( procedure_type IN VARCHAR2 DEFAULT NULL,
                                table_name IN VARCHAR2 DEFAULT NULL,
                                doctable_name IN VARCHAR2 DEFAULT NULL,
                                selected_columns IN vc2_array DEFAULT empty_array,
                                selected_keycol IN VARCHAR2 DEFAULT NULL,
                                additional_columns IN vc2_array DEFAULT empty_array,
                                table_access IN VARCHAR2 DEFAULT NULL,
                                procedure_name IN VARCHAR2 DEFAULT NULL,
                                selected_function IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
  print_context_data( 'procedure_type', procedure_type );
  print_context_data( 'table_name', table_name );
  print_context_data( 'doctable_name', doctable_name );
  print_context_data_array( 'selected_columns', selected_columns );
  print_context_data( 'selected_keycol', selected_keycol );
  print_context_data_array( 'additional_columns', additional_columns );
  print_context_data( 'table_access', table_access );
  print_context_data( 'procedure_name', procedure_name );
  print_context_data( 'selected_function', selected_function );
END print_upload_context;


---------------------------------------------------------------------------
--  Name:
--      print_context_data
--
--  Description:
--      Print context to HTML page, checking for NULL
--
---------------------------------------------------------------------------
PROCEDURE print_context_data( field_name IN VARCHAR2,
                              field_value IN VARCHAR2 )
IS
BEGIN
  IF field_value IS NOT NULL
  THEN
    htp.formHidden( cname=>field_name, cvalue=>field_value );
  END IF;
END;


---------------------------------------------------------------------------
--  Name:
--      print_context_data_array
--
--  Description:
--      Print hidden field array to HTML page, checking for empty array
--      containing just the dummy argument.
--
---------------------------------------------------------------------------
PROCEDURE print_context_data_array( field_name IN VARCHAR2,
                                    field_value_array IN vc2_array )
IS
BEGIN
  IF field_value_array.COUNT > 0 AND field_value_array( 1 ) <> 'empty'
  THEN
    FOR i IN 1 .. field_value_array.COUNT LOOP
      print_context_data( field_name, field_value_array( i ) );
    END LOOP;
  END IF;
END;


---------------------------------------------------------------------------
--  Name:
--      show_compilation_errors
--
--  Description:
--      Show compilation errors from USER_ERRORS table
---------------------------------------------------------------------------
PROCEDURE show_compilation_errors( procedure_name IN VARCHAR2 )
IS
  CURSOR errors_cursor( procedure_name_arg VARCHAR2 ) IS
    SELECT line, position, text FROM user_errors
      WHERE name = procedure_name_arg AND TYPE = 'PROCEDURE';
BEGIN
  html_p_open;
  html_table_open( csummary=>'List of compilation errors',
                   ccellspacing=>'5' );
  htp.tableRowOpen;
  htp.tableHeader( cvalue=>'Line' );
  htp.tableHeader( cvalue=>'Column' );
  htp.tableHeader( cvalue=>'Error text', calign=>'left' );
  htp.tableRowClose;
  FOR error IN errors_cursor( procedure_name ) LOOP
    htp.tableRowOpen;
    htp.tableData( cvalue=>htmlf_tt( error.line ), 
                   cattributes=>'ALIGN="right" VALIGN="top"' );
    htp.tableData( cvalue=>htmlf_tt( error.position ),
                   cattributes=>'ALIGN="right" VALIGN="top"' );
    htp.tableData( cvalue=>'<PRE>' || htf.escape_sc( error.text ) || '</PRE>', 
                   calign=>'left' );
    htp.tableRowClose;
  END LOOP;
  htp.tableClose;
  html_p_close;
END;


---------------------------------------------------------------------------
--  Name:
--      print_compiled_source_button
--
--  Description:
--      Creates a form to view compiled source code in database
---------------------------------------------------------------------------
PROCEDURE print_compiled_source_button( procedure_name IN VARCHAR2 )
IS
BEGIN
  html_p_open;
  htp.print( 'Click the <B>View</B> button to display the compiled PL/SQL' );
  htp.print( 'source code in a pop-up window.' );
  htp.print( 'To save the source in a file for editing, select' );
  htp.print( '<B>Save As...</B> from your browser''s <B>File</B>' );
  htp.print( 'pull-down menu.' );
  htp.ulistOpen;
  form_open( proc_name=>'view_compiled_source', target=>'_blank' );
  htp.formHidden( cname=>'procedure_name', cvalue=>procedure_name );
  htp.prn( 'Click to display generated source: ' );
  htp.formSubmit( cvalue=>'View' );
  form_close( menu_bar=>FALSE );
  htp.ulistClose;
  html_p_close;
END print_compiled_source_button;


---------------------------------------------------------------------------
--  Name:
--      view_compiled_source
--
--  Description:
--      View compiled source code in database
---------------------------------------------------------------------------
PROCEDURE view_compiled_source( procedure_name IN VARCHAR2 )
IS
  CURSOR source_cursor( procedure_name_arg VARCHAR2 ) IS
    SELECT text FROM user_source
      WHERE name = UPPER( procedure_name_arg ) AND TYPE = 'PROCEDURE';
BEGIN
  owa_util.mime_header( 'text/plain', TRUE );
  htp.prn( 'CREATE OR REPLACE ' );
  FOR source IN source_cursor( procedure_name ) LOOP
    htp.prn( source.text );
  END LOOP;
END view_compiled_source;


---------------------------------------------------------------------------
--  Name:
--      print_page_header
--
--  Description:
--      Output common header.
---------------------------------------------------------------------------
PROCEDURE print_page_header
IS
BEGIN
  htp.print( '<HTML LANG="EN">' );
  htp.headOpen;
  htp.title( wizard_title );
  htp.headClose;
  htp.bodyOpen( cattributes=>htmlf_attr( 'BGCOLOR', color_white ) );
  html_table_open( cattributes=>'WIDTH="100%"' );
  htp.tableRowOpen;
  htp.tableData( cvalue=>htmlf_text( cvalue=>wizard_name,
                                     csize=>'+2' ),
                 cattributes=>htmlf_attr( 'BGCOLOR', color_cream ),
                 calign=>'center' );
  htp.tableRowClose;
  htp.tableClose;
END print_page_header;


---------------------------------------------------------------------------
--  Name:
--      print_page_trailer
--
--  Description:
--      Output common trailer.
---------------------------------------------------------------------------
PROCEDURE print_page_trailer IS
BEGIN
  htp.bodyClose;
  htp.htmlClose;
END print_page_trailer;


---------------------------------------------------------------------------
--  Name:
--      print_message
--
--  Description:
--      Output a message with optional ruler
---------------------------------------------------------------------------
PROCEDURE print_message( message IN VARCHAR2,
                         ruler IN BOOLEAN DEFAULT FALSE,
                         end_paragraph IN BOOLEAN DEFAULT FALSE ) IS
BEGIN
    html_p_open;
    htmlp_text( cvalue=>'<B>' || message || '</B>',
                csize=>'+1', ccolor=>color_blue );
    IF ruler
    THEN
      html_hr;
      html_p_close;
    ELSIF end_paragraph
    THEN
      html_p_close;
    END IF;
END print_message;


---------------------------------------------------------------------------
--  Name:
--      print_error_message
--
--  Description:
--      Output a message with optional ruler
---------------------------------------------------------------------------
PROCEDURE print_error_message( message IN VARCHAR2 )
IS
BEGIN
    print_message( 'Error message: ' );
    htp.print( message );
    html_p_close;
END print_error_message;


---------------------------------------------------------------------------
--  Name:
--      html_xxx
--
--  Description:
--      HTML tag utility methods.
---------------------------------------------------------------------------
PROCEDURE html_p_open IS
BEGIN
  htp.print( '<P>' );
END html_p_open;

PROCEDURE html_p_close IS
BEGIN
  htp.print( '</P>' );
END html_p_close;

PROCEDURE html_hr IS
BEGIN
  htp.print( '<HR SIZE="1">' );
END html_hr;

PROCEDURE html_br( num_breaks IN NUMBER DEFAULT 1 ) IS
BEGIN
  FOR i IN 1..num_breaks
  LOOP
    htp.br;
  END LOOP;
END html_br;

PROCEDURE html_table_open( cborder IN VARCHAR2 DEFAULT '0',
                           ccellspacing IN VARCHAR2 DEFAULT '0',
                           csummary IN VARCHAR2 DEFAULT NULL,
                           blayout IN BOOLEAN DEFAULT FALSE,
                           cscope IN VARCHAR2 DEFAULT NULL,
                           cattributes IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
  htp.prn( '<TABLE' );
  htp.prn( htmlf_attr( 'BORDER', cborder ) );
  IF ccellspacing IS NOT NULL
  THEN
    htp.prn( htmlf_attr( 'CELLSPACING', ccellspacing ) );
  END IF;
  IF csummary IS NOT NULL
  THEN
    htp.prn( htmlf_attr( 'SUMMARY', csummary ) );
  ELSIF blayout
  THEN
    htp.prn( htmlf_attr( 'SUMMARY', 'Table used for HTML layout purposes only' ) );
  ELSE
    htp.prn( htmlf_attr( 'SUMMARY', '' ) );
  END IF;  
  IF cscope IS NOT NULL
  THEN
    htp.prn( htmlf_attr( 'SCOPE', cscope ) );
  END IF;
  IF cattributes IS NOT NULL
  THEN
    htp.prn( ' ' || cattributes );
  END IF;
  htp.print( '>' );
END html_table_open;

PROCEDURE html_table_close IS
BEGIN
  htp.print( '</TABLE>' );
END html_table_close;

FUNCTION htmlf_label( cname IN VARCHAR2,
                      ctext IN VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  RETURN '<LABEL' || htmlf_for( cname ) || '>' || ctext || '</LABEL>';
END htmlf_label;

PROCEDURE htmlp_label( cname IN VARCHAR2, 
                       ctext IN VARCHAR2 ) IS
BEGIN
  htp.print( htmlf_label( cname, ctext ) );
END htmlp_label;

FUNCTION htmlf_attr( cname IN VARCHAR2,
                     cvalue IN VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  RETURN ' ' || cname || '="' || cvalue || '"';
END htmlf_attr;

FUNCTION htmlf_for( cname IN VARCHAR2 ) RETURN VARCHAR2
IS
  pos INTEGER;
BEGIN
  pos := INSTR( cname, ' ' );
  IF pos = 0
  THEN
    RETURN htmlf_attr( 'FOR', LOWER( cname ) || '_id' );
  ELSE
    RETURN htmlf_attr( 'FOR', LOWER( SUBSTR( cname, 1, pos-1 ) ) || '_id' );
  END IF;
END htmlf_for;

FUNCTION htmlf_id( cname IN VARCHAR2 ) RETURN VARCHAR2
IS
  pos INTEGER;
BEGIN
  pos := INSTR( cname, ' ' );
  IF pos = 0
  THEN
    RETURN htmlf_attr( 'ID', LOWER( cname ) || '_id' );
  ELSE
    RETURN htmlf_attr( 'ID', LOWER( SUBSTR( cname, 1, pos-1 ) ) || '_id' );
  END IF;
END htmlf_id;

FUNCTION htmlf_tt( cdata IN VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  RETURN '<TT>' || cdata || '</TT>';
END htmlf_tt;

FUNCTION htmlf_text( cvalue IN VARCHAR2,
                     csize IN VARCHAR2 DEFAULT NULL,
                     ccolor IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 IS
BEGIN
    RETURN htf.fontOpen( csize=>csize, ccolor=>ccolor ) ||
           cvalue || htf.fontClose;
END htmlf_text;

PROCEDURE htmlp_text( cvalue IN VARCHAR2,
                      csize IN VARCHAR2 DEFAULT NULL,
                      ccolor IN VARCHAR2 DEFAULT NULL ) IS
BEGIN
  htp.print( htmlf_text( cvalue, csize, ccolor ) );
END htmlp_text;

FUNCTION htmlf_form_text_field( cname IN VARCHAR2,
                                clabel IN VARCHAR2,
                                csize IN VARCHAR2 DEFAULT NULL,
                                cmaxlength IN VARCHAR2 DEFAULT NULL,
                                cvalue IN VARCHAR2 DEFAULT NULL )
  RETURN VARCHAR2 IS
BEGIN
  IF clabel IS NULL
  THEN
    RETURN htf.formText( cname=>cname, 
                         csize=>csize,
                         cmaxlength=>cmaxlength,
                         cvalue=>cvalue,
                         cattributes=>htmlf_id( cname ) );
  ELSE
    RETURN htmlf_label( cname, clabel ) || LF ||
           htf.formText( cname=>cname, 
                         csize=>csize,
                         cmaxlength=>cmaxlength,
                         cvalue=>cvalue,
                         cattributes=>htmlf_id( cname ) );
  END IF;
END htmlf_form_text_field;

PROCEDURE htmlp_form_text_field( cname IN VARCHAR2,
                                 clabel IN VARCHAR2,
                                 csize IN VARCHAR2 DEFAULT NULL,
                                 cmaxlength IN VARCHAR2 DEFAULT NULL,
                                 cvalue IN VARCHAR2 DEFAULT NULL ) IS
BEGIN
  htp.print( htmlf_form_text_field( cname=>cname,
                                    clabel=>clabel,
                                    csize=>csize,
                                    cmaxlength=>cmaxlength,
                                    cvalue=>cvalue ) );
END htmlp_form_text_field;

FUNCTION htmlf_form_radio( cname IN VARCHAR2,
                           cvalue IN VARCHAR2,
                           clabel IN VARCHAR2,
                           cchecked IN OUT VARCHAR2,
                           cdefault IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2 
IS
BEGIN
  RETURN htf.formRadio( cname=>cname,
                        cvalue=>cvalue,
                        cchecked=>get_checked( cchecked, cvalue, cdefault ),
                        cattributes=>htmlf_id( cvalue ) ) || LF ||
         htmlf_label( cvalue, clabel );
END htmlf_form_radio;

PROCEDURE htmlp_form_radio( cname IN VARCHAR2,
                            cvalue IN VARCHAR2,
                            clabel IN VARCHAR2,
                            cchecked IN OUT VARCHAR2,
                            cdefault IN VARCHAR2 DEFAULT NULL ) IS
BEGIN
  htp.print( htmlf_form_radio( cname, cvalue, clabel, cchecked, cdefault ) );
END htmlp_form_radio;

FUNCTION htmlf_form_checkbox( cname IN VARCHAR2,
                              cvalue IN VARCHAR2,
                              clabel IN VARCHAR2,
                              cchecked IN OUT VARCHAR2,
                              cdefaults IN vc2_array DEFAULT empty_array ) 
  RETURN VARCHAR2 IS
BEGIN
  RETURN htf.formCheckbox( cname=>cname,
                           cvalue=>cvalue,
                           cchecked=>get_checked_array( cchecked, 
                                                        cvalue, 
                                                        cdefaults ),
                           cattributes=>htmlf_id( cvalue ) ) || LF ||
         htmlf_label( cvalue, clabel );
END htmlf_form_checkbox;

PROCEDURE htmlp_form_checkbox( cname IN VARCHAR2,
                               cvalue IN VARCHAR2,
                               clabel IN VARCHAR2,
                               cchecked IN OUT VARCHAR2,
                               cdefaults IN vc2_array DEFAULT empty_array ) IS
BEGIN
  htp.print( htmlf_form_checkbox( cname, cvalue, clabel, cchecked, cdefaults ) );
END htmlp_form_checkbox;

PROCEDURE htmlp_form_select_open( cname IN VARCHAR2, 
                                  clabel IN VARCHAR2 ) IS
BEGIN
  htmlp_label( cname, clabel );
  htp.print( '<SELECT' || htmlf_attr( 'NAME', cname ) || ' ' || 
                          htmlf_id( cname ) || '>' );
END htmlp_form_select_open;

PROCEDURE htmlp_form_select_option( cvalue IN VARCHAR2,
                                    cselected IN VARCHAR2 )
IS
  local_selected VARCHAR2( 10 ) := '';                                    
BEGIN
  IF cselected IS NOT NULL
  THEN
    local_selected := ' SELECTED';
  END IF;
  htp.print( '<OPTION' || local_selected || '>' || cvalue || '</OPTION>' );
END htmlp_form_select_option;

PROCEDURE htmlp_form_select_close IS
BEGIN
  htp.print( '</SELECT>' );
END htmlp_form_select_close; 


---------------------------------------------------------------------------
--  Name:
--      form_open
--
--  Description:
--      Begins an HTML form
---------------------------------------------------------------------------
PROCEDURE form_open( proc_name IN VARCHAR2,
                     request_method IN VARCHAR2 DEFAULT 'POST',
                     target IN VARCHAR2 DEFAULT NULL )
IS
BEGIN
  htp.formOpen( curl=>package_url( proc_name ), 
                cmethod=>request_method,
                ctarget=>target );
END form_open;


---------------------------------------------------------------------------
--  Name:
--      form_close
--
--  Description:
--      Ends an HTML form, with optional cancel, back, next, and
--      finish buttons, with step x of y.
---------------------------------------------------------------------------
PROCEDURE form_close( menu_bar IN BOOLEAN DEFAULT TRUE,
                      done_button IN BOOLEAN DEFAULT FALSE,
                      cancel_button IN BOOLEAN DEFAULT FALSE,
                      logout_button IN BOOLEAN DEFAULT FALSE,
                      back_button IN BOOLEAN DEFAULT FALSE,
                      next_button IN BOOLEAN DEFAULT FALSE,
                      finish_button IN BOOLEAN DEFAULT FALSE,
                      apply_button IN BOOLEAN DEFAULT FALSE,
                      step_num IN INTEGER DEFAULT 0,
                      num_steps IN INTEGER DEFAULT 0 ) IS
BEGIN
  IF menu_bar
  THEN
    html_p_open;
    html_table_open( cattributes=>'WIDTH="100%"' );
    htp.tableRowOpen;
    htp.print( '<TD ALIGN="left"' || htmlf_attr( 'BGCOLOR', color_cream ) || '>' );
    htmlp_text( cvalue=>'Select action: ', csize=>'+1', ccolor=>color_blue );
    IF done_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cname=>'form_action', cvalue=>'Done' );
    END IF;
    IF cancel_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cname=>'form_action', cvalue=>'Cancel' );
    END IF;
    IF logout_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cvalue=>'Logout' );
    END IF;
    IF back_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cname=>'form_action', cvalue=>'Back' );
    END IF;
    IF step_num > 0 AND num_steps > 0
    THEN
      htp.print( NBSP );
      htp.print( 'Step ' || step_num || ' of ' || num_steps );
    END IF;
    IF next_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cname=>'form_action', cvalue=>'Next' );
    END IF;
    IF finish_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cname=>'form_action', cvalue=>'Finish' );
    END IF;
    IF apply_button
    THEN
      htp.print( NBSP );
      htp.formSubmit( cname=>'form_action', cvalue=>'Apply' );
    END IF;
    htp.print( '</TD>' );
    htp.tableRowClose;
    htp.tableClose;
    html_p_close;
  END IF;
  htp.formClose;
END form_close;


---------------------------------------------------------------------------
--  Name:
--      get_checked
--
--  Description:
--      Get the value of the checked attribute based on a default
---------------------------------------------------------------------------
FUNCTION get_checked( checked_flag IN OUT VARCHAR2,
                      form_value IN VARCHAR2 DEFAULT NULL,
                      default_value IN VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2
IS
  return_checked_flag VARCHAR2( 10 );
BEGIN
  --
  -- Check for user-supplied value
  --
  IF default_value IS NULL
  THEN
    --
    -- No defualt, use current flag, resetting to blank for next time
    --
    return_checked_flag := checked_flag;
    checked_flag := NULL;
  ELSE
    --
    -- Returned checked if current value = default.
    --
    IF LOWER( form_value ) = LOWER( default_value )
    THEN
      return_checked_flag := 'checked';
      checked_flag := NULL;
    ELSE
      return_checked_flag := NULL;
    END IF;
  END IF;
  RETURN return_checked_flag;
END get_checked;


---------------------------------------------------------------------------
--  Name:
--      get_checked_array
--
--  Description:
--      Get the value of the checked attribute based on a default
---------------------------------------------------------------------------
FUNCTION get_checked_array( checked_flag IN OUT VARCHAR2,
                            form_value IN VARCHAR2 DEFAULT NULL,
                            default_values IN vc2_array DEFAULT empty_array )
    RETURN VARCHAR2
IS
  return_checked_flag VARCHAR2( 10 );
BEGIN
  IF default_values.COUNT > 1 AND default_values( 1 ) <> 'empty'
  THEN
    return_checked_flag := NULL;
    FOR i IN 2 .. default_values.COUNT LOOP
      return_checked_flag := get_checked( checked_flag,
                                          form_value,
                                          default_values( i ) );
      EXIT WHEN return_checked_flag IS NOT NULL;
    END LOOP;
  ELSE
    return_checked_flag := get_checked( checked_flag );
  END IF;
  RETURN return_checked_flag;
END get_checked_array;


---------------------------------------------------------------------------
--  Name:
--      package_url
--
--  Description:
--      Creates a URL to a procedure in the current package.
---------------------------------------------------------------------------
FUNCTION package_url( proc_name IN VARCHAR2 ) RETURN VARCHAR2 IS
BEGIN
  RETURN package_synonym || '.' || proc_name;
END package_url;


---------------------------------------------------------------------------
--  Name:
--      extract_column_name_and_info
--
--  Description:
--      Extracts column name and type info from NAME (TYPE) format.
---------------------------------------------------------------------------
PROCEDURE extract_column_name_and_info( column_name_info IN VARCHAR2,
                                        column_name OUT VARCHAR2,
                                        column_info OUT VARCHAR2 )
IS
  pos INTEGER;
BEGIN
  pos := INSTR( column_name_info, '(' );
  IF pos > 0
  THEN
    column_name := SUBSTR( column_name_info, 1, pos-1 );
    column_name := TRIM( column_name );
    column_info := SUBSTR( column_name_info, pos );
    column_info := REPLACE( column_info, '(' );
    column_info := REPLACE( column_info, ')' );
    column_info := TRIM( column_info );
  ELSE
    column_name := TRIM( column_name_info );
    column_info := NULL;
  END IF;
END extract_column_name_and_info;


---------------------------------------------------------------------------
--  Name:
--      extract_column_name_and_info
--
--  Description:
--      Extracts column name and type info from NAME (TYPE) format.
---------------------------------------------------------------------------
FUNCTION sql_ident( prefix IN VARCHAR2 DEFAULT '',
                    sql_name IN VARCHAR2,
                    postfix IN VARCHAR2 DEFAULT '' ) RETURN VARCHAR2
IS
BEGIN
  RETURN SUBSTR( prefix || sql_name || postfix, 1, 30 );
END sql_ident;


---------------------------------------------------------------------------
--  Package initialization
---------------------------------------------------------------------------
BEGIN

  --
  -- Local data
  --
  empty_array( 1 ) := 'empty';

END Ordplsgwycodewizard;
/

