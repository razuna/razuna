define theuser = &1

--------------------------------------------------------------------------------
-- Create_filename
--------------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION &theuser..create_filename (mimetype VARCHAR2, fname VARCHAR2)
RETURN VARCHAR2
AS
 thename VARCHAR2(200);
 dotpos NUMBER;
 ext VARCHAR2(10);
 mt VARCHAR2(50);
BEGIN
	 dotpos := INSTR(fname,'.', -1) ;
	 IF dotpos != 0 THEN
	 	thename := SUBSTR(fname, 1, dotpos);
	 ELSE
	 	thename := fname || '.';
	 END IF;

-- by default use what is after / in the mimetype as file extension
-- for example, image/gif will give gif as the extension.
ext := SUBSTR(mimetype, INSTR(mimetype, '/') + 1);

	 IF ext = 'jpeg' THEN
	 	ext := 'jpg'; -- We want jpg rather than jpeg....
	 ELSIF ext = 'foo' THEN  -- Not real, just an example...
	 	ext := 'bar';
	 -- other exceptions to file extensions here
	 END IF;

RETURN thename || ext;

END;
/

--------------------------------------------------------------------------------
-- Create_thumb_comp
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..create_thumb_comp
(theid IN NUMBER, verb IN VARCHAR2, tabname IN VARCHAR2, colname IN VARCHAR2)
IS
imgsrc ordsys.ordimage;
imgdst ordsys.ordimage;
BEGIN
-- select the source image
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET ' || colname || ' = Ordsys.OrdImage.init() WHERE img_id =' || theid || ' RETURNING image INTO :1'
RETURNING INTO imgsrc;

EXECUTE IMMEDIATE
'SELECT ' || colname || ' FROM ' || tabname || ' WHERE img_id =' || theid || ' for update' INTO imgdst;

-- process the image
imgsrc.processcopy(verb, imgdst);

-- Write the image back into the thumb row
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET ' || colname || ' = :1 WHERE img_id =' || theid USING imgdst;

END;
/

--------------------------------------------------------------------------------
-- Export_Image_Comp
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Export_Image_Comp
(theid NUMBER, tabname VARCHAR2, thedir varchar2)
IS
obj ORDSYS.ORDImage;
ctx RAW(64) :=NULL;
fname VARCHAR2(400);
newname VARCHAR2(400);
mimetype VARCHAR2(200);
BEGIN

-- get values from the table
EXECUTE IMMEDIATE
'SELECT i.comp, i.img_filename, i.comp.getmimetype() FROM ' || tabname || 
' i WHERE i.img_id =' || theid INTO obj, fname, mimetype;

-- Call the create_filename SP here
newname := create_filename(mimetype, fname);

-- export the image to the HD with the exact filename
obj.export(ctx,'file',thedir,newname);

END;
/

--------------------------------------------------------------------------------
-- Export_Image_Comp_Uw
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Export_Image_Comp_Uw
(theid NUMBER, tabname VARCHAR2, thedir varchar2)
IS
obj ORDSYS.ORDImage;
ctx RAW(64) :=NULL;
fname VARCHAR2(400);
newname VARCHAR2(400);
mimetype VARCHAR2(200);
BEGIN

-- get values from the table
EXECUTE IMMEDIATE
'SELECT i.comp_uw, i.img_filename, i.comp_uw.getmimetype() FROM ' || tabname || 
' i WHERE i.img_id =' || theid INTO obj, fname, mimetype;

-- Call the create_filename SP here
newname := create_filename(mimetype, fname);

-- export the image to the HD with the exact filename
obj.export(ctx,'file',thedir,newname);

END;
/

--------------------------------------------------------------------------------
-- Export_Image_Original
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Export_Image_Original
(theid NUMBER, tabname VARCHAR2, thedir varchar2)
IS
obj ORDSYS.ORDImage;
ctx RAW(64) :=NULL;
fname VARCHAR2(400);
newname VARCHAR2(400);
mimetype VARCHAR2(200);
BEGIN

-- get values from the table
EXECUTE IMMEDIATE
'SELECT i.image, i.img_filename, i.image.getmimetype() FROM ' || tabname || 
' i WHERE i.img_id =' || theid INTO obj, fname, mimetype;

-- Call the create_filename SP here
IF mimetype != NULL THEN
newname := Create_Filename(mimetype, fname);
ELSE
newname := fname;
END IF;

-- export the image to the HD with the exact filename
obj.export(ctx,'file',thedir,newname);

END;
/

--------------------------------------------------------------------------------
-- Export_Image_Thumb
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Export_Image_Thumb
(theid NUMBER, tabname VARCHAR2, thedir varchar2)
IS
obj ORDSYS.ORDImage;
ctx RAW(64) :=NULL;
fname VARCHAR2(400);
newname VARCHAR2(400);
mimetype VARCHAR2(200);
BEGIN

-- get values from the table
EXECUTE IMMEDIATE
'SELECT i.thumb, i.img_filename, i.thumb.getmimetype() FROM ' || tabname || 
' i WHERE i.img_id =' || theid INTO obj, fname, mimetype;

-- Call the create_filename SP here
newname := create_filename(mimetype, fname);

-- export the image to the HD with the exact filename
obj.export(ctx,'file',thedir,newname);

END;
/

--------------------------------------------------------------------------------
-- Get_Cat_Image
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Cat_Image ( ID IN NUMBER, lang IN NUMBER, tabname IN VARCHAR2 )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);
BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
  EXECUTE IMMEDIATE
  'select mtbl.cat_image FROM ' || tabname || ' mtbl WHERE mtbl.cat_id_r =' || ID || ' AND mtbl.lang_id_r = ' || lang INTO localObject;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'ID', ID );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates 
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to 
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Cat_Image;
/

--------------------------------------------------------------------------------
-- Get_Comp
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Comp ( ID IN VARCHAR2, tabname IN VARCHAR2, review IN VARCHAR2 )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);

BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
  EXECUTE IMMEDIATE
    'select mtbl.comp FROM ' || tabname || ' mtbl WHERE mtbl.img_id =' || ID INTO localObject;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'ID', ID );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates 
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to 
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Comp;
/

--------------------------------------------------------------------------------
-- Get_Comp_Uw
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Comp_Uw ( ID IN VARCHAR2, tabname IN VARCHAR2, review IN VARCHAR2 )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);

BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
  EXECUTE IMMEDIATE
    'select mtbl.comp_uw FROM ' || tabname || ' mtbl WHERE mtbl.img_id =' || ID INTO localObject;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'ID', ID );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates 
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to 
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Comp_Uw;
/

--------------------------------------------------------------------------------
-- Get_Image
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Image ( ID IN VARCHAR2, tabname IN VARCHAR2, review IN VARCHAR2 )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);

BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
  EXECUTE IMMEDIATE
    'select mtbl.image FROM ' || tabname || ' mtbl WHERE mtbl.img_id =' || ID INTO localObject;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'ID', ID );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates 
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to 
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Image;
/

--------------------------------------------------------------------------------
-- Get_Logo
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Logo ( ID IN VARCHAR2, tabname IN VARCHAR2 )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);

BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
	EXECUTE IMMEDIATE
  'select mtbl.set2_intranet_logo FROM ' || tabname || ' mtbl WHERE mtbl.SET2_ID =' || ID INTO localObject;  
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'ID', ID );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates 
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to 
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Logo;
/

--------------------------------------------------------------------------------
-- Get_Thumb
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Thumb ( ID IN NUMBER, tabname IN VARCHAR2, review IN VARCHAR2 )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);
BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
  EXECUTE IMMEDIATE
  'select mtbl.thumb FROM ' || tabname || ' mtbl WHERE mtbl.img_id =' || ID INTO localObject;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'ID', ID );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates 
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to 
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Thumb;
/

--------------------------------------------------------------------------------
-- Get_Doc_Preview
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Doc_Preview ( id IN number, tabname IN VARCHAR2, review IN VARCHAR2, theorder in number )
AS
  localObject ORDSYS.ORDIMAGE;
  localBlob  BLOB;
  localBfile BFILE;
  httpStatus NUMBER;
  lastModDate VARCHAR2(256);

BEGIN
  --
  -- Retrieve the object from the database into a local object.
  --
  BEGIN
  EXECUTE IMMEDIATE
  'select fp.file_preview FROM ' || tabname || ' fp WHERE fp.file_id_r = ' || id || ' AND fp.file_preview_order = ' || theorder INTO localObject;
  --'select mtbl.image FROM ' || tabname || ' mtbl WHERE mtbl.img_id =' || ID INTO localObject;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      ordplsgwyutil.resource_not_found( 'id', id );
      RETURN;
  END;

  --
  -- Check update time if browser sent If-Modified-Since header
  --
  IF ordplsgwyutil.cache_is_valid( localObject.getUpdateTime() )
  THEN
    owa_util.status_line( ordplsgwyutil.http_status_not_modified );
    RETURN;
  END IF;

  --
  -- Figure out where the image is.
  --
  IF localObject.isLocal() THEN
    --
    -- Data is stored locally in the localData BLOB attribute
    --
    localBlob := localObject.getContent();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBlob );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'FILE' THEN
    --
    -- Data is stored as a file from which ORDSource creates
    -- a BFILE.
    --
    localBfile  := localObject.getBFILE();
    owa_util.mime_header( localObject.getMimeType(), FALSE );
    ordplsgwyutil.set_last_modified( localObject.getUpdateTime() );
    owa_util.http_header_close();
    IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
      wpg_docload.download_file( localBfile );
    END IF;

  ELSIF UPPER( localObject.getSourceType() ) = 'HTTP' THEN
    --
    -- The image is referenced as an HTTP entity, so we have to
    -- redirect the client to the URL which ORDSource provides.
    --
    owa_util.redirect_url( localObject.getSource() );

  ELSE
    --
    -- The image is stored in an application-specific data
    -- source type for which no default action is available.
    --
    NULL;
  END IF;
END Get_Doc_Preview;
/

--------------------------------------------------------------------------------
-- Get_Xml
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Get_Xml
(theid IN VARCHAR2, tabname IN VARCHAR2)
AS
  localObject XMLTYPE;
  localBlob  BLOB;
  STMT VARCHAR2(2000);
  DOFF   INTEGER := 1;
  SOFF   INTEGER := 1;
  WARNMSG  VARCHAR2(100);
  NL     VARCHAR2(1) := '';
  LANG_CTX INTEGER := DBMS_LOB.DEFAULT_LANG_CTX;
BEGIN
-- Retrieve the object from the database into a local object.
DBMS_LOB.CREATETEMPORARY( localBlob, TRUE, DBMS_LOB.CALL );

STMT := 'select mtbl.metaxmp FROM ' || tabname || ' mtbl WHERE mtbl.img_id =' || theid;

EXECUTE IMMEDIATE
STMT INTO localObject;

owa_util.mime_header( 'text/xml', FALSE );
IF owa_util.get_cgi_env( 'REQUEST_METHOD' ) <> 'HEAD' THEN
   DBMS_LOB.CONVERTTOBLOB(localBlob, localObject.getClobVal(), 
   DBMS_LOB.LOBMAXSIZE, SOFF, DOFF,
   NLS_CHARSET_ID('WE8ISO8859P1'), LANG_CTX, warnmsg);
   WPG_DOCLOAD.DOWNLOAD_FILE( localBlob );
END IF;

EXCEPTION
WHEN OTHERS THEN
   OWA_UTIL.STATUS_LINE(500, 'Internal Error 500', TRUE);
   htp.print('Internal Error 500 - ' || 'EXCEPTION caught in get_xml select '||SQLCODE|| NL ||SQLERRM || NL || stmt);
  RETURN;
END;
/

--------------------------------------------------------------------------------
-- Import_Cat_Image
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Import_Cat_Image
(filename IN VARCHAR2, tabname IN VARCHAR2, lang IN NUMBER, recid IN NUMBER)
IS
img ordsys.ordimage;
ctx RAW(64) := NULL;
BEGIN

-- get the table for updating
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET cat_image = Ordsys.OrdImage.init() WHERE cat_id_r = ' || recid || ' AND lang_id_r = ' || lang ;
EXECUTE IMMEDIATE
'Select cat_image from ' || tabname || ' WHERE cat_id_r = ' || recid || ' AND lang_id_r = ' || lang || ' for update ' INTO img;

-- -- now import the image
img.importfrom(ctx, 'file', 'ADMIN_INCOMING', filename);
 
-- -- and update the table
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET cat_image = :1 WHERE cat_id_r = ' || recid || ' AND lang_id_r = ' || lang USING img;

END;
/

--------------------------------------------------------------------------------
-- Import_thumb_comp
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..import_thumb_comp
(theid IN NUMBER, filename IN VARCHAR2, tabname IN VARCHAR2, colname IN VARCHAR2, thedir in varchar2)
IS
img ordsys.ordimage;
ctx RAW(64) := NULL;
BEGIN

-- init the column
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET ' || colname || ' = Ordsys.OrdImage.init() WHERE img_id =' || theid;

-- select the column
EXECUTE IMMEDIATE
'Select ' || colname || ' from ' || tabname || ' WHERE img_id = ' || theid || ' for update ' INTO img;

-- now read the image
img.importfrom(ctx, 'file', thedir, filename);

-- Write the image back into table
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET ' || colname || ' = :1 WHERE img_id =' || theid USING img;

END;
/

--------------------------------------------------------------------------------
-- Import_Image
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Import_Image
(dest_id IN NUMBER, filename IN VARCHAR2, tabname IN VARCHAR2, thedir in varchar2)
IS
img ordsys.ordimage;
sig ordsys.ordimagesignature;
ctx RAW(64) := NULL;
metav XMLSequenceType;
meta_root VARCHAR2(40);
xmlORD XMLTYPE;
xmlXMP XMLTYPE;
xmlEXIF XMLTYPE;
xmlIPTC XMLTYPE;
width integer;
height integer;
-- adding a exception handler here to catch weird images that the signature can not handle
no_signature exception;
pragma exception_init (no_signature, -29400);

BEGIN
-- insert a empty row into the images table
EXECUTE IMMEDIATE
'INSERT INTO ' || tabname || ' (img_id, image, imagesignature) VALUES (' || dest_id || ', ordsys.ordimage.init(), ordsys.ordimagesignature.init()) RETURNING image, imagesignature INTO :1, :2'
RETURNING INTO img, sig;

-- now read the image
img.importfrom(ctx, 'file', thedir, filename);

-- get width and height of the image
width := img.getwidth();
height := img.getheight();

-- generate the signature but only if width and height is bigger then 21 pixels or else we get errors
if width > 21 and height > 21
then
sig.generateSignature(img);
end if;

-- and update the table with the read image from above
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET image = :1, imagesignature = :2 WHERE img_id = ' || dest_id USING img, sig;

-- select the image again
EXECUTE IMMEDIATE
'SELECT image FROM ' || tabname || ' WHERE img_id = ' || dest_id INTO img;

-- extract all the metadata
metav := img.getMetadata( 'ALL' );
-- process the result array to discover what types of metadata were returned
FOR i IN 1..metav.COUNT() LOOP
meta_root := metav(i).getRootElement();
CASE meta_root
WHEN 'ordImageAttributes' THEN xmlORD := metav(i);
WHEN 'xmpMetadata' THEN xmlXMP := metav(i);
WHEN 'iptcMetadata' THEN xmlIPTC := metav(i);
WHEN 'exifMetadata' THEN xmlEXIF := metav(i);
ELSE NULL;
END CASE;
END LOOP;

-- Update metadata columns
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET metaORDImage = :1, metaEXIF = :2, metaIPTC = :3, metaXMP = :4 WHERE img_id =' || dest_id
USING xmlORD, xmlEXIF, xmlIPTC, xmlXMP;

-- If a exception is raised then continue from here
exception
when no_signature
then

-- and update the table with the read image from above
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET image = :1 WHERE img_id = ' || dest_id USING img;

-- select the image again
EXECUTE IMMEDIATE
'SELECT image FROM ' || tabname || ' WHERE img_id = ' || dest_id INTO img;

-- extract all the metadata
metav := img.getMetadata( 'ALL' );
-- process the result array to discover what types of metadata were returned
FOR i IN 1..metav.COUNT() LOOP
meta_root := metav(i).getRootElement();
CASE meta_root
WHEN 'ordImageAttributes' THEN xmlORD := metav(i);
WHEN 'xmpMetadata' THEN xmlXMP := metav(i);
WHEN 'iptcMetadata' THEN xmlIPTC := metav(i);
WHEN 'exifMetadata' THEN xmlEXIF := metav(i);
ELSE NULL;
END CASE;
END LOOP;

-- Update metadata columns
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET metaORDImage = :1, metaEXIF = :2, metaIPTC = :3, metaXMP = :4 WHERE img_id =' || dest_id
USING xmlORD, xmlEXIF, xmlIPTC, xmlXMP;

END;
/

--------------------------------------------------------------------------------
-- Import_Intranet_Logo
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Import_Intranet_Logo
(filename VARCHAR2, tabname VARCHAR2)
IS
img ordsys.ordimage;
ctx RAW(64) := NULL;
BEGIN
-- get the table for updating
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET set2_intranet_logo = Ordsys.OrdImage.init() RETURNING set2_intranet_logo INTO :1' 
RETURNING INTO img;

EXECUTE IMMEDIATE
'Select set2_intranet_logo from ' || tabname || ' WHERE set2_id = 1 for update ' INTO img;

-- now import the image
img.importfrom(ctx, 'file', 'ADMIN_INCOMING', filename);

-- and update the table
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET set2_intranet_logo = :1 WHERE set2_id = 1' USING img;

END Import_Intranet_Logo;
/

--------------------------------------------------------------------------------
-- Import_Doc_Preview
--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE &theuser..Import_doc_preview
(filename IN VARCHAR2, tabname IN VARCHAR2, recid IN NUMBER, thedir in varchar2, theorder in number)
IS
img ordsys.ordimage;
ctx RAW(64) := NULL;
BEGIN

-- get the table for updating
EXECUTE IMMEDIATE
'insert into ' || tabname || ' (file_id_r, file_preview, file_name, file_preview_order) VALUES(:1, ordsys.ordimage.init(), :2, :3)' USING recid, filename, theorder;

EXECUTE IMMEDIATE
'Select file_preview from ' || tabname || ' WHERE file_name = :1 ' INTO img USING filename;

-- now import the image
img.importfrom(ctx, 'file', thedir, filename);

-- and update the table
EXECUTE IMMEDIATE
'UPDATE ' || tabname || ' SET file_preview = :1 WHERE file_name = :2 ' USING img, filename;

END;
/

--------------------------------------------------------------------------------
-- Meta_From_File
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..Meta_From_File
(theid NUMBER, dir_name VARCHAR2, file_name VARCHAR, tabname VARCHAR2)
AS
   image ORDSYS.ORDImage;
   comp ORDSYS.ORDImage;
   comp_uw ORDSYS.ORDImage;
   thumb ORDSYS.ORDImage;
   meta XMLTYPE;
BEGIN
	-- ORIGINAL
    EXECUTE IMMEDIATE
    'SELECT image FROM ' || tabname || ' WHERE img_id = ' || theid || ' FOR UPDATE' INTO image;

    meta := XMLTYPE(BFILENAME(dir_name, file_name), NLS_CHARSET_ID('WE8MSWIN1252'));

    image.putMetadata(meta);

	EXECUTE IMMEDIATE
    'UPDATE ' || tabname || ' SET image = :1, metaxmp = :2 WHERE img_id = ' || theid USING image, meta;
	
	-- COMPING WATERMARKED
	EXECUTE IMMEDIATE
    'SELECT comp FROM ' || tabname || ' WHERE img_id = ' || theid || ' FOR UPDATE' INTO comp;

    meta := XMLTYPE(BFILENAME(dir_name, file_name), NLS_CHARSET_ID('WE8MSWIN1252'));

    comp.putMetadata(meta);
	
	EXECUTE IMMEDIATE
    'UPDATE ' || tabname || ' SET comp = :1, metaxmp = :2 WHERE img_id = ' || theid USING comp, meta;
	
	-- COMPING
	EXECUTE IMMEDIATE
    'SELECT comp_uw FROM ' || tabname || ' WHERE img_id = ' || theid || ' FOR UPDATE' INTO comp_uw;

    meta := XMLTYPE(BFILENAME(dir_name, file_name), NLS_CHARSET_ID('WE8MSWIN1252'));

    comp_uw.putMetadata(meta);
	
	EXECUTE IMMEDIATE
    'UPDATE ' || tabname || ' SET comp_uw = :1, metaxmp = :2 WHERE img_id = ' || theid USING comp_uw, meta;
	
	-- THUMBNAIL
	EXECUTE IMMEDIATE
    'SELECT thumb FROM ' || tabname || ' WHERE img_id = ' || theid || ' FOR UPDATE' INTO thumb;

    meta := XMLTYPE(BFILENAME(dir_name, file_name), NLS_CHARSET_ID('WE8MSWIN1252'));

    comp_uw.putMetadata(meta);
	
	EXECUTE IMMEDIATE
    'UPDATE ' || tabname || ' SET thumb = :1, metaxmp = :2 WHERE img_id = ' || theid USING thumb, meta;

END;
/

--------------------------------------------------------------------------------
-- meta_to_file
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..meta_to_file
(theid NUMBER, dir_name VARCHAR2, file_name VARCHAR2, tabname VARCHAR2)
AS
   Image ORDSYS.ORDImage;
   meta XMLTYPE;
   metas xmlsequencetype;
   buf CLOB;
   amount NUMBER;
   offset NUMBER;
   len NUMBER;
   F UTL_FILE.FILE_TYPE;
   domdoc DBMS_XMLDOM.DOMDocument;
   fil BFILE;
BEGIN
    EXECUTE IMMEDIATE
    'SELECT image FROM ' || tabname || ' WHERE img_id = ' || theid || ' FOR UPDATE' INTO image;
	
    metas := image.getMetadata();

    -- We could also write from xmpmeta

    FOR i IN 1..metas.COUNT LOOP
        meta := metas(i);
        IF meta.getRootElement = 'xmpMetadata' THEN
           domdoc := DBMS_XMLDOM.NewDomDocument(meta);
           DBMS_LOB.CREATETEMPORARY( buf, TRUE, DBMS_LOB.CALL );
           DBMS_XMLDOM.writeToCLOB(domdoc, buf);
           offset := 1;
           amount := 32000;
           F := UTL_FILE.FOPEN(dir_name, file_name,'W', amount);
           len := dbms_lob.getLength(buf);
           WHILE offset < len LOOP
               UTL_FILE.PUT(F, dbms_lob.SUBSTR(buf, amount, offset));
               offset := offset + amount;
           END LOOP;
           UTL_FILE.NEW_LINE(F);
           UTL_FILE.FCLOSE(F);
           DBMS_XMLDOM.freeDocument(domdoc);
       END IF;
    END LOOP;
END;
/

--------------------------------------------------------------------------------
-- new_host
--------------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE &theuser..new_host
(thepref varchar2, theschema varchar2)
IS

BEGIN

--CREATE TRIGGERS

--update_file_content
execute immediate
'CREATE OR REPLACE TRIGGER ' || theschema || '.' || thepref || 'UPDATE_FILE_CONTENT AFTER DELETE OR INSERT OR UPDATE ON ' || theschema || '.' || thepref || 'FILES DECLARE v_job NUMBER; BEGIN IF DELETING THEN DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.optimize_index(''''' || thepref || 'doc_content_idx'''',''''FULL'''');'', SYSDATE); ELSE DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.sync_index(''''' || thepref || 'doc_content_idx'''');'', SYSDATE); END IF; END;';

--update_file_desc
execute immediate
'CREATE OR REPLACE TRIGGER ' || theschema || '.' || thepref || 'UPDATE_FILE_DESC AFTER INSERT OR UPDATE OR DELETE ON ' || theschema || '.' || thepref || 'FILES_DESC DECLARE v_job NUMBER; BEGIN IF DELETING THEN DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.optimize_index(''''' || thepref || 'doc_desc_idx'''',''''FULL'''');'', SYSDATE); ELSE DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.sync_index(''''' || thepref || 'doc_desc_idx'''');'', SYSDATE); END IF; END;';

--update_img_description
execute immediate
'CREATE OR REPLACE TRIGGER ' || theschema || '.' || thepref || 'UPDATE_IMG_DESCRIPTION AFTER INSERT OR UPDATE OR DELETE ON ' || theschema || '.' || thepref || 'IMAGES_TEXT DECLARE v_job NUMBER; BEGIN IF DELETING THEN DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.optimize_index(''''' || thepref || 'img_description_idx'''',''''FULL'''');'', SYSDATE); ELSE DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.sync_index(''''' || thepref || 'img_description_idx'''');'', SYSDATE); END IF; END;';

--update_img_keywords
execute immediate
'CREATE OR REPLACE TRIGGER ' || theschema || '.' || thepref || 'UPDATE_IMG_KEYWORDS AFTER INSERT OR UPDATE OR DELETE ON ' || theschema || '.' || thepref || 'IMAGES_TEXT DECLARE v_job NUMBER; BEGIN IF DELETING THEN DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.optimize_index(''''' || thepref || 'img_keywords_idx'''',''''FULL'''');'', SYSDATE); ELSE DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.sync_index(''''' || thepref || 'img_keywords_idx'''');'', SYSDATE); END IF; END;';

--update_img_xmp
execute immediate
'CREATE OR REPLACE TRIGGER ' || theschema || '.' || thepref || 'UPDATE_IMG_XMP AFTER INSERT OR UPDATE OR DELETE ON ' || theschema || '.' || thepref || 'IMAGES DECLARE v_job NUMBER; BEGIN IF DELETING THEN DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.optimize_index(''''' || thepref || 'img_xmp_idx'''',''''FULL'''');'', SYSDATE); ELSE DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.sync_index(''''' || thepref || 'img_xmp_idx'''');'', SYSDATE); END IF; END;';

--update_keywords_desc
execute immediate
'CREATE OR REPLACE TRIGGER ' || theschema || '.' || thepref || 'UPDATE_KEYWORDS_DESC AFTER INSERT OR UPDATE OR DELETE ON ' || theschema || '.' || thepref || 'FILES_DESC DECLARE v_job NUMBER; BEGIN IF DELETING THEN DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.optimize_index(''''' || thepref || 'doc_keywords_idx'''',''''FULL'''');'', SYSDATE); ELSE DBMS_JOB.SUBMIT (v_job, ''ctx_ddl.sync_index(''''' || thepref || 'doc_keywords_idx'''');'', SYSDATE); END IF; END;';

--CREATE PACKAGES

--the similar package

--spec
execute immediate
'CREATE OR REPLACE PACKAGE ' || theschema || '.' || thepref || 'similar AS TYPE TableRows IS REF CURSOR; PROCEDURE img_colour (theimgid IN number, thelang IN number, rowmax IN number, rowmin IN number, thelic IN varchar2, rc OUT TableRows); END ' || thepref || 'similar;';

--body
execute immediate
'CREATE OR REPLACE PACKAGE BODY ' || theschema || '.' || thepref || 'similar AS procedure img_colour (theimgid IN number, thelang IN number, rowmax IN number, rowmin IN number, thelic IN varchar2, rc OUT TableRows ) IS compare_sig ORDSYS.ORDImageSignature; begin SELECT t.imagesignature INTO compare_sig FROM ' || thepref || 'images t WHERE t.img_id = theimgid ; case thelic when ''all'' then open rc for SELECT rn, img_id, img_custom_id, img_description, img_publisher, img_license, howmany FROM ( SELECT ROWNUM AS rn, img_id, img_custom_id, img_publisher, img_license, img_description, howmany FROM ( SELECT i.img_id, i.img_custom_id, i.img_publisher, i.img_license, it.img_description, count(*) over() howmany FROM ' || thepref || 'images i LEFT JOIN ' || thepref || 'images_text it ON it.img_id_r = i.img_id AND it.lang_id_r = thelang WHERE ORDSYS.IMGSimilar(i.imagesignature, compare_sig,''color="0.4" texture="0.1" shape="0.4" location="0.1"'', 30)=1 AND lower(i.img_online) = ''t'' AND (lower(i.img_license) = ''royalty-free'' OR lower(i.img_license) = ''rights-managed'') GROUP BY img_id, img_custom_id, img_publisher, img_license, img_description) WHERE ROWNUM <= rowmax) WHERE rn > rowmin; when ''rf'' then open rc for SELECT rn, img_id, img_custom_id, img_description, img_publisher, img_license, howmany FROM (SELECT ROWNUM AS rn, img_id, img_custom_id, img_publisher, img_license, img_description, howmany FROM (SELECT i.img_id, i.img_custom_id, i.img_publisher, i.img_license, it.img_description, count(*) over() howmany FROM ' || thepref || 'images i LEFT JOIN ' || thepref || 'images_text it ON it.img_id_r = i.img_id AND it.lang_id_r = thelang 
WHERE ORDSYS.IMGSimilar(i.imagesignature, compare_sig,''color="0.4" texture="0.1" shape="0.4" location="0.1"'', 30)=1 AND lower(i.img_online) = ''t'' AND lower(i.img_license) = ''royalty-free'' GROUP BY img_id, img_custom_id, img_publisher, img_license, img_description) WHERE ROWNUM <= rowmax) WHERE rn > rowmin; when ''rm'' then open rc for SELECT rn, img_id, img_custom_id, img_description, img_publisher, img_license, howmany FROM (SELECT ROWNUM AS rn, img_id, img_custom_id, img_publisher, img_license, img_description, howmany FROM (SELECT i.img_id, i.img_custom_id, i.img_publisher, i.img_license, it.img_description, count(*) over() howmany FROM ' || thepref || 'images i LEFT JOIN ' || thepref || 'images_text it ON it.img_id_r = i.img_id AND it.lang_id_r = thelang WHERE ORDSYS.IMGSimilar(i.imagesignature, compare_sig,''color="0.4" texture="0.1" shape="0.4" location="0.1"'', 30)=1 AND lower(i.img_online) = ''t'' AND lower(i.img_license) = ''rights-managed'' GROUP BY img_id, img_custom_id, img_publisher, img_license, img_description) WHERE ROWNUM <= rowmax) WHERE rn > rowmin; end case; END img_colour; END ' || thepref || 'similar;';


END new_host;
/