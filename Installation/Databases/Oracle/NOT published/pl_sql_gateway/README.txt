Copyright (c) Oracle Corporation 2001. All Rights Reserved.


         Oracle interMedia Code Wizard for the PL/SQL Gateway
         ====================================================


This file describes the steps required to install and use the interMedia
Code Wizard for the PL/SQL Gateway, hereafter referred to as the Code
Wizard.

See the "Oracle 9i Application Server Using the PL/SQL Gateway" book for
more information on the PL/SQL Gateway.



Contents
========

  Requirements
  About the Code Wizard
  Installation and Configuration
    Installing and configuring the Code Wizard in a development database 
    Installing and configuring the utility package in a deployment database
  Using the Code Wizard
    Creating a new DAD or choosing an existing DAD for use with the Code Wizard
    Authorizing a DAD using the Code Wizard's administration function
    Creating and testing media upload and retrieval procedures
    Using PL/SQL Gateway document tables
    Specifying time zone information to support browser caching
  Sample session
  Known restrictions



I. Requirements
===============

Requirements for installing and using the interMedia Code Wizard for the
PL/SQL Gateway:

1. Oracle PL/SQL Gateway installed with either:
   - Oracle9iAS 1.0.2 or later, or
   - Oracle8i database server 8.1.7 or Oracle9i database server 9.0.1 

2. Oracle interMedia release 8.1.7 or later



II. About the Code Wizard
=========================

The interMedia Code Wizard for the PL/SQL Gateway is an example of a tool
with which you create PL/SQL procedures for the PL/SQL Gateway to upload
and retrieve media data stored in a database using the interMedia object
types.  The Code Wizard guides you through a series of self-explanatory
steps to create either a media retrieval or media upload procedure.  You
can either create and compile stand-alone media access procedures or you
can generate the source of media access procedures for inclusion in a
PL/SQL package.  Once created, you can customize the procedures as
necessary to satisfy any specific application requirements.



III. Installation and Configuration
===================================

The Code Wizard is comprised of two PL/SQL packages: the Code Wizard
package itself, ORDPLSGWYCODEWIZARD, and a utility package, ORDPLSGWYUTIL.
Both packages must be installed in the ORDSYS schema.  For ease of use, a
synonym, ORDCWPKG, is created for the ORDSYS.ORDPLSGWYCODEWIZARD package
when you install the Code Wizard.

The utility package is used by the Code Wizard and by media retrieval
procedures created by the Code Wizard.  When you install the Code Wizard,
the utility package is installed automatically.  To deploy procedures
created by the Code Wizard to other databases in which the Code Wizard has
not been installed, you must install the utility package in those
databases.

This section describes how to install and configure the Code Wizard and
utility packages in a development database, and how to install and
configure the utility package only in a deployment database.

Note: If you reinstall the Code Wizard or utility packages, you may see
one or more of the following error messages, which should be ignored:

  ORA-00955: name is already used by an existing object


A. Installing and configuring the Code Wizard in a development database
-----------------------------------------------------------------------

1. Install the Code Wizard and utility packages.

   Start SQL*Plus and connect to the ORDSYS schema in the database:

->   sqlplus ORDSYS[/<ordsys-password>][@<connect_identifer>]

   Install the Code Wizard and utility packages:

->   SQL> @ordplsci.sql


2. Create the Code Wizard administration Database Access Descriptor (DAD).


                               IMPORTANT
                               ---------

        All Code Wizard administration functions, such as the
        authorization of other DADs to use the Code Wizard, must
        execute using the ORDSYS user.  Do not enter a password
        for the Code Wizard administration DAD.  Omitting the
        password from the administration DAD requires users to
        enter a password to access the administration functions,
        thus ensuring access by authorized users only.  Note that
        the Code Wizard's administration functions check the DAD
        name with which they are invoked to ensure it is the
        ORDCWADMIN DAD created in these instructions.


   Enter the URL of the PL/SQL Gateway Configuration page into your 
   browser's location bar. For example:

     http://<hostname>:<port>/pls/admin_/gateway.htm 

   Select the "Gateway Database Access Descriptor Settings" link.

   Select the "Add Default (blank configuration)" link.

   Enter the following information into the specified sections of the 
   "Create DAD Entry" form:

     Add Database Access Descriptor
       Database Access Descriptor Name:      ORDCWADMIN
       Schema Name:                          [leave blank]

     Database Connectivity Information
       Oracle User Name:                     ORDSYS
       Oracle Password:                      [IMPORTANT: leave blank]
       Oracle Connect String:                [leave blank or enter TNS name]

     Authentication Mode 
       Authentication Mode:                  Basic

     Session Cookie
       Session Cookie Name:                  [leave blank]

     Session State 
       Create a Stateful Session?            No

     Connection Pool Parameters 
       Enable Connection Pooling?            Yes

     Default(Home)Page 
       Default (Home) Page:                  ORDCWPKG.MENU

     Document Access Information 
       Document Table:                       [leave blank]
       Document Access Path:                 [leave blank]
       Document Access Procedure:            [leave blank]
       Extensions uploaded as Long Raw:      [leave blank]

     Path Aliasing 
       Path Alias:                           [leave blank]
       Path Alias Procedure:                 [leave blank]


3. Specify time zone information.

   After installing the Code Wizard and utility packages, and creating the
   administration DAD, you must set the time zone information.  Enter the
   Code Wizard's administration URL in your browser's location bar, then
   enter the ORDSYS user name and password when prompted by the browser.
   For example:

     http://host:post/pls/ordcwadmin

   Select "Time zone management" from the main menu, then click the "Next"
   button.  Set the time zone information as appropriate, then click the
   "Apply" button.  Detailed information on how to specify time zone
   information is provided later.  

   To log out (clear HTTP authentication information), select "Logout"
   from the main menu, then click the "Next" button. The log out function
   redirects the request to the PL/SQL Gateway's built-in "logmeoff"
   function.  See the PL/SQL Gateway documentation for more information.


B. Installing and configuring the utility package in a deployment database
--------------------------------------------------------------------------

1. Install the utility package

   Start SQL*Plus and connect to the ORDSYS schema in the database:

->   sqlplus ORDSYS[/<ordsys-password>][@<connect_identifer>]

   Install the utility package:

->   SQL> @ordplsui.sql


2. Specify time zone information

   After installing the Code Wizard or utility packages, you must specify
   the time zone information using SQL*Plus to execute the
   ORDPLSGWYUTIL.set_timezone procedure.  For example:

   Start SQL*Plus and connect to the ORDSYS schema in the database:

->   sqlplus ORDSYS[/<ordsys-password>][@<connect_identifer>]

   Specify time zone information.  For example:

->   SQL> EXEC ORDPLSGWYUTIL.SET_TIMEZONE( server_timezone=>'EST' );
                              --or--
->   SQL> EXEC ORDPLSGWYUTIL.SET_TIMEZONE( server_gmtdiff=>-5 );

   Detailed information on how to specify time zone information is
   provided later.



IV. Using the Code Wizard
=========================

Follow these steps to use the Code Wizard to create and test media upload
and retrieval procedures:

1. Create a new DAD or choose an existing DAD for use with the Code Wizard
2. Authorize use of the DAD using the Code Wizard's administration function
3. Create and test media upload and retrieval procedures

This section covers the following topics:

- Creating a new DAD or choosing an existing DAD for use with the Code Wizard
- Authorizing a DAD using the Code Wizard's administration function
- Creating and testing media upload and retrieval procedures
- Using PL/SQL Gateway document tables
- Specifying time zone information to support browser caching


A. Creating a new DAD or choosing an existing DAD for use with the Code Wizard
------------------------------------------------------------------------------

To create media upload or retrieval procedures, you must select one or
more DADs for use with the Code Wizard.  To prevent the unauthorized
browsing of schema tables and to prevent the unauthorized creation of
media access procedures, you must authorize each DAD using the Code
Wizard's administration function.  Depending on your database and
application security requirements, you may choose to create and authorize
one or more new DADs specifically for use with the Code Wizard, or you may
choose to authorize the use of one or more existing DADs.

Oracle recommends that any DAD authorized for use with the Code Wizard
uses some form of user authentication mechanism.  The simplest approach is
to create or use a DAD that uses database authentication.  To use this
approach, select the Basic Authentication Mode and omit the Password in
the DAD specification.  Alternatively, you may choose to use a DAD that
specifies an existing application-specific authentication mechanism.

See the "Oracle 9i Application Server Using the PL/SQL Gateway" book for
more information on configuring DADs.

The following example illustrates how to create a DAD to create and test
media upload and retrieval procedures in the SCOTT schema.

Note: To test media upload procedures, the name of a document table must
      be specified in the DAD.  When testing an upload procedure, you may
      choose the DAD you use to create the procedure, or you may use the
      DAD used to access the application.  You may choose a document table
      name when you create a DAD, edit a DAD to specify the document table
      name at a later time, or use an existing DAD that already specifies
      a document table name. This example illustrates specifying the
      document table name when you create the DAD.

   Enter the URL of the PL/SQL Gateway Configuration page into your 
   browser's location bar. For example:

     http://<hostname>:<port>/pls/admin_/gateway.htm 

   Select the "Gateway Database Access Descriptor Settings" link.

   Select the "Add Default (blank configuration)" link.

   Enter the following information into the specified sections of the 
   "Create DAD Entry" form:

     Add Database Access Descriptor
       Database Access Descriptor Name:      SCOTTCW
       Schema Name:                          [leave blank]

     Database Connectivity Information
       Oracle User Name:                     SCOTT
       Oracle Password:                      [leave blank]
       Oracle Connect String:                [leave blank or enter TNS name]

     Authentication Mode 
       Authentication Mode:                  Basic

     Session Cookie
       Session Cookie Name:                  [leave blank]

     Session State 
       Create a Stateful Session?            No

     Connection Pool Parameters 
       Enable Connection Pooling?            Yes

     Default(Home)Page 
       Default (Home) Page:                  ORDCWPKG.MENU

     Document Access Information 
       Document Table:                       MEDIA_UPLOAD_TABLE
       Document Access Path:                 [leave blank]
       Document Access Procedure:            [leave blank]
       Extensions uploaded as Long Raw:      [leave blank]

     Path Aliasing 
       Path Alias:                           [leave blank]
       Path Alias Procedure:                 [leave blank]


B. Authorizing a DAD using the Code Wizard's administration function
--------------------------------------------------------------------

To authorize a DAD for use with the Code Wizard, enter the Code Wizard's
administration URL into your browser's location bar, then enter the ORDSYS
user name and password when prompted by the browser.  For example:

  http://host:port/pls/ordcwadmin

Select the "DAD authorization" function from the main menu, then click the
"Next" button.  Type in the name of the DAD you wish to authorize together
with the user name, then click the "Apply" button.  Note that duplicate
DADs are not allowed and each authorized DAD must indicate which database
schema the user is authorized to access with the Code Wizard using the
DAD.  Use this same screen to delete the authorization for any existing
DADs that no longer need to use the Code Wizard.

To log out (clear HTTP authentication information), select the "Logout"
function from the main menu, then click the "Next" button.  The log out
function redirects the request to the PL/SQL Gateway's built-in "logmeoff"
function.  See the PL/SQL Gateway documentation for more information.


C. Creating and testing media upload and retrieval procedures
-------------------------------------------------------------

To start the Code Wizard, enter the appropriate URL into your browser's
location bar, then enter the user name and password when prompted by the
browser.  If the DAD is configured specifically for use with the Code
Wizard, simply enter the DAD name. Alternatively, to use another DAD,
enter the DAD name together with Code Wizard package name and main menu
procedure name, ORDCWPKG.MENU, after the DAD name.  For example:

  http://host:port/pls/scottcw

           -- or --

  http://host:port/pls/mediadad/ordcwpkg.menu

Once logged in, you can log out (clear HTTP authentication information) at
any time by selecting the "Logout" function from the main menu, then
clicking the "Next" button.  The log out function redirects the request to
the PL/SQL Gateway's built-in "logmeoff" function.  See the PL/SQL Gateway
documentation for more information.

To create a media retrieval or upload procedure, select the appropriate
function, then click the "Next" button.  The Code Wizard then guides you
through a series of self-explanatory steps to create the procedure.  Each
step includes explanatory text that describes how to proceed.  

If you create a stand-alone media upload or retrieval procedure, you will
have the opportunity to test the procedure at the end.

A sample session described later in this document illustrates how to
create and test a media upload procedure and a media retrieval procedure.


D. Using PL/SQL Gateway document tables
---------------------------------------

All files uploaded using the PL/SQL Gateway are stored in a document
table.  Media upload procedures created by the Code Wizard automatically
move uploaded media from the specified document table to the application's
table.  To avoid transient files appearing temporarily in a document table
used by another application component, use a document table that is not
being used to store documents permanently.

Be sure to specify the selected document table in the application's
Database Access Descriptor (DAD).  If the DAD already specifies a
different document table, create a new DAD for media uploads.

If you choose to create a new document table, the Code Wizard will create
a table with the following format:

  CREATE TABLE document-table-name
    ( name           VARCHAR2(256) UNIQUE NOT NULL,
      mime_type      VARCHAR2(128),
      doc_size       NUMBER,
      dad_charset    VARCHAR2(128),
      last_updated   DATE,
      content_type   VARCHAR2(128),
      blob_content   BLOB );

See the "Oracle 9i Application Server Using the PL/SQL Gateway" book for
more information on file upload and document tables.


E. Specifying time zone information to support browser caching
--------------------------------------------------------------

User response times are improved and network traffic is reduced if a
browser can cache resources received from a server and subsequently use
those cached resources to satisfy future requests.  This section descibes
at a very high level how the browser caching mechanism works and how the
Code Wizard utility package to support that mechanism.  When reading this
discussion, note that all HTTP date/time stamps are expressed in Greenwich
Mean Time (GMT).

All HTTP responses include a Date header, which indicates the date and
time when the response was generated.  When a server sends a resource in
response to a request from a browser, it can also include the
Last-Modified HTTP response header, which indicates the date and time when
the requested resource was last modified.  It is important to note that
the Last-Modified header must not be later than the Date header. 

After receiving and caching a resource, if a browser needs to retrieve the
same resource again, it sends a request to the server with the
If-Modified-Since request header specified as the value of the
Last-Modified date returned by the server when the resource was previously
retrieved and cached.  When the server receives the request, it compares
the date in the If-Modified-Since request header with the last update time
of the resource.  Assuming the resource still exists, if the resource
hasn't changed since it was cached by the browser, the server responds
with an HTTP 304 Not Modified status with no response body, which
indicates that the browser can use the resource currently stored in its
cache.  Assuming once again the resource still exists, if the request
does not include an If-Modified-Since header or if the resource has been
updated since it was cached by the browser, the server responds with an
HTTP 200 OK status and sends the resource to the browser.  See the HTTP
specification for more information.

The ORDImage, ORDAudio, ORDVideo and ORDDoc objects all possess an
updateTime attribute stored as a DATE in the embedded ORDSource object.
However, the Oracle8i database has no support for time zones or daylight
savings time, and has no rules for converting a DATE value stored in a
database to GMT.  Therefore, the Code Wizard utility package called by
media retrieval procedures uses an approximation when converting a media
object's updateTime attribute to GMT.

When a response is first returned to a browser, a media retrieval
procedure sets the Last-Modified HTTP response header based on the
updateTime attribute.  If a request for media data includes an
If-Modified-Since header, the media retrieval procedure compares the value
with the updateTime attribute and returns an appropriate response.  If the
resource in the browser's cache is still valid, an HTTP 304 Not Modified
status is returned with no response body.  If the resource has been
updated since it was cached by the browser, then an HTTP 200 OK status is
returned with the media resource as the response body.

Media retrieval procedures created by the Code Wizard call the Code Wizard
utility package to convert a DATE value stored in the database to GMT.
The utility package uses the time zone information specified using the
Code Wizard or the ORDPLSGWYUTIL.set_timezone procedure to convert a
database date/time stamp to GMT.  To ensure the resulting date conforms to
the rule for the Last-Modified date described earlier, the time zone
information must be specified correctly.

For a database that resides in a time zone that never adjusts for daylight
savings time, simply specify the time zone's offset from GMT.  For example,
+2 or -10.

For a database that resides in a time zone that does adjust for daylight
savings time, there are two options.  The recommended approach is to
specify the time zone identifier or offset from GMT for the time zone's
daylight savings time.  For example, for the US/Eastern time zone, specify
EST or -4.  Using this approach, you need never adjust the time zone
information once it has been set.

Alternatively, you can make the semi-annual time-zone changes necessary to
adjust for daylight savings time.  However, note that the date/time stamp
of a media object can never be expressed precisely in GMT, because the
Oracle8i database has no support for time zones or daylight savings time,
and has no rules for converting a DATE value to GMT.  However, typically
this is not an issue, as the Last-Modified header is normally used only
for determining cache validity.  Note that the Oracle9i database does have
support for time zones and daylight savings time.

If the time zone information is not specified correctly, or if you choose
to make semi-annual daylight savings changes, but forget to change the
setting, incorrect HTTP headers can be generated, as shown in the
following example, which illustrates an image uploaded to a database in
the US/Eastern time zone on August 17th, where the time zone setting is
set to EST (Eastern Standard Time):

  HTTP/1.1 200 OK
  Date: Fri, 17 Aug 2001 14:00:09 GMT
  Last-Modified: Fri, 17 Aug 2001 14:59:09 GMT
  Content-Length: 17014
  Content-Type: image/gif

In this example, the Last-Modified date is ahead of the response Date,
which expresses the current time when the response is sent.  Therefore, in
this example, the Last-Modified date is in the future.  Typically, this
does not result in any visible error messages, but may result in the
resource being cached incorrectly or not cached at all.



V. Sample session
=================

This sample session uses the SCOTT schema to illustrate the creation of
media upload and retrieval procedures.  Substitute a different schema name
to use a different schema.

This script assumes the Code Wizard has been installed.

1. Create a table to store images for the demonstration.

   Start SQL*Plus and connect to the SCOTT schema in the database:

->   sqlplus SCOTT/TIGER[@<connect_identifer>]

   Create the table:

->   SQL> CREATE TABLE cw_images_table( id NUMBER PRIMARY KEY,
                                        description VARCHAR2(30) NOT NULL,
                                        location VARCHAR2(30),
                                        image ORDSYS.ORDIMAGE );


2. Create the SCOTTCW DAD to be used to create the procedures.

   Enter the URL of the PL/SQL Gateway Configuration page into your 
   browser's location bar.  For example:

     http://<hostname>:<port>/pls/admin_/gateway.htm 

   Select the "Gateway Database Access Descriptor Settings" link.

   Select the "Add Default (blank configuration)" link.

   Enter the following information into the specified sections of the 
   "Create DAD Entry" form:

     Add Database Access Descriptor
       Database Access Descriptor Name:      SCOTTCW
       Schema Name:                          [leave blank]

     Database Connectivity Information
       Oracle User Name:                     SCOTT
       Oracle Password:                      [leave blank]
       Oracle Connect String:                [leave blank or enter TNS name]

     Authentication Mode 
       Authentication Mode:                  Basic

     Session Cookie
       Session Cookie Name:                  [leave blank]

     Session State 
       Create a Stateful Session?            No

     Connection Pool Parameters 
       Enable Connection Pooling?            Yes

     Default(Home)Page 
       Default (Home) Page:                  ORDCWPKG.MENU

     Document Access Information 
       Document Table:                       CW_SAMPLE_UPLOAD_TABLE
       Document Access Path:                 [leave blank]
       Document Access Procedure:            [leave blank]
       Extensions uploaded as Long Raw:      [leave blank]

     Path Aliasing 
       Path Alias:                           [leave blank]
       Path Alias Procedure:                 [leave blank]


3. Authorize the use of the SCOTTCW DAD and SCOTT schema with the Code Wizard.

   Enter the Code Wizard's administration URL into your browser's location
   bar, then enter the ORDSYS user name and password when prompted by the
   browser.  For example:

     http://host:port/pls/ordcwadmin

   Select the DAD authorization function from the Code Wizard's main menu
   and click the Next botton.  Type in the name of the demonstration DAD,
   SCOTTCW, and the SCOTT user name, then click the "Apply" button.  Click
   the "Done" button when the confirmation screen is displayed.


4. Change DADs to the SCOTTCW DAD.

   Select the Change DAD function from the Code Wizard's main menu.
   Select the SCOTTCW DAD, if it is not already selected, then click the
   "Next" button.  The browser will then prompt you for the user name and
   password. Enter SCOTT and TIGER, then press the "OK" button.  The main
   menu now displays the Current DAD as SCOTTCW and the current schema as
   SCOTT2.


5. Create and test a media upload procedure.

   Select the "Create media upload procedure" function from the main menu,
   then click the "Next" button.

   Step 1: Select database table and procedure type 

     - Select the CW_IMAGES_TABLE database table.
     - Select the "Standalone procedure" button.
     - Click the "Next" button.

   Step 2: Select PL/SQL Gateway document upload table 

     - If there are no document tables in the SCOTT schema, the Code
       Wizard displays a message indicating the situation. In this case,
       accept the default table name provided, CW_SAMPLE_UPLOAD_TABLE,
       then click the "Next" button.

     - If there are existing document tables, but the CW_SAMPLE_UPLOAD_TABLE
       is not among them, click the "Create new document table" button,
       accept the default table name provided, CW_SAMPLE_UPLOAD_TABLE,
       then click the "Next" button. 

     - If the CW_SAMPLE_UPLOAD_TABLE document table already exists, the
       "Use existing document table" and CW_SAMPLE_UPLOAD_TABLE buttons
       are checked already. Simply click the "Next" button.

   Step 3: Select data access and media column(s) 

     - The checkbox for the "IMAGE (ORDIMAGE)" column is checked already.
     - The "ID (Primary key)" column button is checked already.
     - Select the "Conditional insert or update" button.
     - Click the "Next" button.

   Step 4: Select additional columns and procedure name 

     - The checkbox for the "DESCRIPTION" column is checked already as
       this column has a NOT NULL constraint. (The checkbox for the 
       "LOCATION" column is not checked by default as there are no
       constraints on this column.)
     - Accept the procedure name provided, UPLOAD_CW_IMAGES_TABLE_IMAGE.
     - The "Create procedure in the database" button is checked already. 
     - Click the "Next" button.

   Step 5: Review selected options 

     - The following procedure creation options are displayed:
         Procedure type:        Standalone
         Table name:            CW_IMAGES_TABLE
         Media column(s):       IMAGE (ORDIMAGE)
         Key column:            ID
         Additional column(s):  DESCRIPTION
         Table access mode:     Conditional update or insert
         Procedure name:        UPLOAD_CW_IMAGES_TABLE_IMAGE
         Function:              Create procedure in the database
     - Click the "Next" button.

   Final step: Compile procedure and review generated source 

     - The Code Wizard displays the following message:
         "Procedure created successfully: UPLOAD_CW_IMAGES_TABLE_IMAGE"
     - Click the "View" button to view the generated source in a pop-up
       windows. Close the window after looking at the generated source.
     - Accept the DAD name provided, SCOTTCW, then click the "Test" button
       to display a template file upload HTML form in a pop-up window that
       you can use to test the generated procedure:
       - To customize the template file upload form, select "Save As..."
         from your browser's "File" pull-down menu to save the HTML source
         for editing.
       - Enter the number 1 for the ID column as the row's primary key
       - Click on the "Browse..." button and choose an image file to
         upload to the database.
       - Enter a description of the image.
       - Click the "Upload media" button.
       - The upload procedure displays a template completion page.
       - Close the pop-up window.
     - Click the "Done" button to return to the main menu.


6. Create and test a media retrieval procedure.

   Select the "Create media retrieval procedure" function from the main
   menu, then click the "Next" button.

   Step 1: Select database table and procedure type 

     - Select the CW_IMAGES_TABLE database table.
     - Select the "Standalone procedure" button.
     - Click the "Next" button.

   Step 2: Select media column and key column 

     - The "IMAGE (ORDIMAGE)" column button is checked already.
     - The "ID (Primary key)" column button is checked already.
     - Click the "Next" button.

   Step 3: Select procedure name and parameter name 

     - Accept the procedure name provided, GET_CW_IMAGES_TABLE_IMAGE.
     - Accept the parameter name provided, MEDIA_ID.
     - The "Create procedure in the database" button is checked already. 
     - Click the "Next" button.

   Step 4: Review selected options 

     - The following procedure creation options are displayed:
         Procedure type:  Standalone
         Table name:      CW_IMAGES_TABLE
         Media column:    IMAGE (ORDIMAGE)
         Key column:      ID
         Procedure name:  GET_CW_IMAGES_TABLE_IMAGE
         Parameter name:  MEDIA_ID
         Function:        Create procedure in the database
     - Click the "Next" button.

   Final step: Compile procedure and review generated source 

     - The Code Wizard displays the following message:
         "Procedure created successfully: GET_CW_IMAGES_TABLE_IMAGE"
     - Click the "View" button to view the generated source in a pop-up
       windows. Close the window after looking at the generated source.
     - Review the URL format used to retrieve images using the
       GET_CW_IMAGES_TABLE_IMAGE procedure.
     - Enter 1 as the Key paremeter, then click the "Test" button to
       test the procedure by retrieving the image uploaded earlier.
       - The uploaded image is displayed in a pop-up window.
       - Close the pop-up window.
     - Click the "Done" button to return to the main menu.


VI. Known restrictions
======================

1. Tables with composite primary keys are not supported.

   To use a table with a composite primary key, create an upload or
   download procedure, then edit the generated source to support all the
   primary key columns.  For example, for a media retrieval procedure,
   this might involve adding an additional parameter, then specifying that
   parameter in the WHERE clause of the SELECT statement.

2. User object types containing embedded interMedia object types are not 
   recognized by the Code Wizard.

