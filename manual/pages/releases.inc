<cfset request.page.title = "Engine Releases"><cfset request.page.section = "support">
<cfset request.page.desc	= "Discover the release notes">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
    	<li><a href="./?/support">Support</li>
      <li class="active"><a href="./?/releases"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">Release Notes</h1>

		<cfinclude template="pages/sidebar_support.inc" />

		<div class="section">

<h2>3.0 - March 2013</h2>

<ul>
<li>fixed CFMODULE dynamic bug for NAME="" attribute</li>
<li>added cron.1min to cron functionality</li>
<li>fixed the onApplicationStart() loading update</li>
<li>fixed exception handling edge case</li>
<li>OnSessionStart()/OnApplicationStart() update</li>
<li>Database Connection Pooling Refactor</li>
<ul>
  <li>Reduced memory overhead</li>
  <li>added function DataSourceActivePoolStats()</li>
  <li>per-page pooling feature added</li>
    <li>connectionperpage flag added to query XML block</li>
    <li>added connectionperpage to DataSourceCreate()</li>
</ul>
<li>added support for mongouri schemes in MongoRegister()</li>
<li>fixed #506: MongoDB's MongoDeregister() and MongoRegister() problem</li>
<li>Updated mongo-2.10.1.jar  [/WEB-INF/lib/ updated]</li>
<li>DeserializeJSon() strictmode supports deep query detection</li>
<li>fixed CFFILE UPLOAD/FileUpload() error when destination is full path to file</li>
<li>fixed XmlParse() documentation bug</li>
<li>fixed AmazonSQS custom regions [/WEB-INF/lib/ updated]</li>
<li>added: <formurlmaintaincase>false</formurlmaintaincase> feature</li>
<li>fixed #498: IsJSON throws exception on complex datatypes</li>
<li>Support for URL in FileRead()</li>
<li>fixed #502: ImageNew can not read an URL as specified by function</li>
<li>Support for multi-regions in Amazon S3, SQS and SimpleDB</li>
<li>Removed AmazonSQSSetHost() function</li>
<li>Updated MongoCollectionIndexEnsure() function</li>
<li>Removed MongoCollectionIndexCreate() deprecated API call</li>
<li>Updated MongoGridFSGet() to support inline returns</li>
<li>Memcached set() error resolved if too big</li>
<li>Trim column names in http() for CSV reading</li>
<li>Added MongoCollectionAggregate()</li>
<li>Updated mongo.jar [/WEB-INF/lib/ updated]</li>
<li>MongoSessionManager more tolerant of outages</li>
<li>fixed #471: output="yes" [/WEB-INF/lib/ updated]</li>
<li>FTP functions added [/WEB-INF/lib/ updated]</li>
<ul>
  <li>FtpClose()</li>
  <li>FtpOpen()</li>
  <li>FtpCmd()</li>
  <li>FtpCreateDir()</li>
  <li>FtpExists()</li>
  <li>FtpExistsDir()</li>
  <li>FtpExistsFile()</li>
  <li>FtpGetCurrentDir()</li>
  <li>FtpGetCurrentUrl()</li>
  <li>FtpGetFile()</li>
  <li>FtpList()</li>
  <li>FtpPutFile()</li>
  <li>FtpRemove()</li>
  <li>FtpRemoveDir()</li>
  <li>FtpRename()</li>
  <li>FtpSetCurrentDir()</li>
  <li>FtpSite()</li>
</ul>
<li>fixed bug when passing a CFFUNCTION argument value as an argument to a constructor</li>
<li>fixed #485: Unexpected behaviour from structKeyExists if a null value from database is involved</li>
<li>fixed the session loading order</li>
<li>http() returns the structure instead of a boolean</li>
<li>added QueryEach() / {}.each()</li>
<li>fixed #373: added support for CLIENTCERT/CLIENTCERTPASSWORD in CFHTTP/Http()</li>
<li>fixed support for component return type in cfscript declared function</li>
<li>automatically treat application/json as string in CFHTTP result</li>
<li>fixed bug recently introduced in 4.2.1 CFHTTP gzip support</li>
<li>fixed YSOD on bad charset value in CFHTTP. Blank values are now ignored.</li>
<li>added Http() function</li>
<li>upgraded to 4.2.1 of HttpComponents for CFHTTP</li>
<li>added StructEach() / StructFilter() / {}.each()</li>
<li>added ArrayEach() / ArrayFilter() / ArrayFindAll() / [].each()</li>
<li>added &lt;CFLOOP ARRAY="" ITEM="" INDEX=""> combination support</li>
<li>GetFileInfo() throws exception on missing file</li>
<li>fixed MongoDB embedded $regex</li>
<li>added AttributeCollection to &lt;CFSCHEDULE></li>
<li>added: "for ( row in query )" cfscript looping</li>
<li>fixed #475: FTP: folder names with spaces are not listed properly</li>
<li>added defaultlist attribute to &lt;CFQUERYPARAM> / QueryRun / QueryOfQueryRun()</li>
<li>fixed &lt;CFSEARCH> to use English analyzer when language is English</li>
<li>fixed combining of tokens in &lt;CFINDEX> custom body</li>
<li>component{} script support</li>
<li>fixed #483: Adding support for customtagpaths to the &lt;CFAPPLICATION> tag</li>
<li>fixed encoding of Mongo _id</li>
<li>fixed #482: returnformat='json'</li>
<li>Collapsing content in the dump/error pages</li>
<li>added the 'default' caching engine for CacheGet/CachePut</li>
<li>fixed #481: FORM scope is empty in cfc used as rest with multiform data</li>
<li>Updated plugins SalesForce/Vision</li>
<li>Updated CFLOCK manual</li>
<li>Fixed &lt;CFFUNCTION JSONCASE=""> bug</li>
<li>Fixed Mongo Date Conversion from local to UTC</li>
<li>Fixed MongoQuery Conversion</li>
<li>Cache CFFUNCTION fixed</li>
<li>OpenBD Archived introduced</li>
<ul>
  <li>MappingCreateArchive()</li>
  <li>MappingAdd()</li>
</ul>
<li>this.sessionstorage enabled to use Mongo/Memcache</li>
<li>Cache Functions Refactored</li>
<ul>
  <li>Added Storage Engines</li>
  <li>Support for CFFUNCTION caching</li>
  <li>Mongo / Memcache / CouchBase support</li>
</ul>
<li>CFMLBug monitoring</li>
<li>SalesForce Plugin added to core [/WEB-INF/lib/ updated]</li>
<li>JSON Encoding Defaults</li>
<ul>
  <li>Set how dates and case are defaults via bluedragon.xml</li>
  <li>Control case via CFFUNCTION for remote calls</li>
  <li>Control it through the client side variables</li>
</ul>
<li>Active threads named with Request URI</li>
<li>Updated MongoDB functions:</li>
<ul>
  <li>fixed parameter name in MongoIsValid()</li>
  <li>Return _id for the MongoCollectionInsert()</li>
  <li>Auto close of connections after idle period</li>
</ul>
<li>fixed datasource security detection</li>
<li>Updated SpreadSheetQueryRead() / SpreadSheetGetCellValue() evaluates formula's</li>
<li>fixed #461: [COMPAT] AttributeCollection does not work with CFLAP</li>
<li>fixed #409: [COMPAT] GetComponentMetaData function not implemented</li>
<li>fixed #470: CFDIRECTORY doesn't honour SORT attribute</li>
<li>fixed #471: output="yes" no longer evaluates to output="true" for onRequest</li>
<li>added support for ternary operator in cfscript</li>
<li>fixed #460:	Allow vars in loops in cfscript</li>
<li>fixed #467: ArraySlice index error</li>
<li>updated Apache Compress removing from Tika [/WEB-INF/lib/ updates]</li>
<li>removed overhead associated with FileUpload()</li>
<li>added docx xlsx pptx odt to CFINDEX </li>
<li>fixed CFINDEX query attribute</li>
<li>fixed CFFTP big size</li>
<li>fixed CFFUNCTION default output</li>
<li>fixed ScopeMisMatch after cfscript exception</li>
<li>upgraded Apache Lucene to 3.6.0 [/WEB-INF/lib/ updates]</li>
<li>search WORD/EXCEL fix [/WEB-INF/lib/ updates]</li>
<li>fixed query cache name collision</li>
<li>Set the Locale to UK for Cookie setting</li>
<li>Increased cookie NEVER to 20 years</li>
<li>updated JSoup1.6.2 [/WEB-INF/lib/ updated]</li>
<li>fixed datasource connection pooling for maxConnections</li>
<li>updated the CFAJAXPROXY to only encode params it needs to</li>
<li>fixed NPE when TYPE is missing from cfscript param statement</li>
<li>fix #454: &lt;input type=checkbox> setForm()</li>
<li>fix #454: &lt;select> Option tag not sending 1 with setForm()</li>
<li>fixed CFSCRIPT language=java error</li>
<li>added AmazonS3Read() overwrite attribute</li>
<li>added MongoDB GridFS functions</li>
<ul>
  <li>MongoGridFSSave()</li>
  <li>MongoGridFSRemove()</li>
  <li>MongoGridFSFindOne()</li>
  <li>MongoGridFSFind()</li>
  <li>MongoGridFSGet()</li>
</ul>
<li>CFVIDEOPLAYER upgraded FlowPlayer to 3.2.8</li>
<li>[Desktop] Fixed 'Export to WAR' feature</li>
<li>upgraded Mongo.jar [/WEB-INF/lib/ updated]</li>
<li>fixed: CFINDEX query type can take in both string and query object</li>
<li>fixed: CFDIRECTORY recurse=true; directory + name paths</li>
<li>added: delimiter to CreateUUID() </li>
<li>updated aw20org.jar [/WEB-INF/lib/ updated]</li>
<li>added serialization support for java</li>
<li>fixed subtle try/catch exception edge case</li>
<li>fixed MongoCollectionIndexCreate() unique bug</li>
<li>IpGetMXRecords() removed trailing period</li>
<li>added attributes to HtmlCodeFormat()</li>
<li>fixed #435: CFDIRECTORY with listinfo only has the file names and leaves off the relative path</li>
<li>fixed DataSource server validation; added "openbdnocheck" to URL string </li>
<li>[Desktop] Updates</li>
<ul>
  <li>Added ContextPath</li>
  <li>Auto Startup on Windows flag</li>
  <li>Auto Server Startup on GUI startup</li>
  <li>JVM Memory updated</li>
  <li>Perm Gen Memory Live Statistics</li>
  <li>Flag to leave target WEB-INF/ untouched</li>
  <li>Settings persisted</li>
  <li>Minimize to System Tray</li>
  <li>WebApp root history</li>
  <li>Start-Server Console tab now in focus</li>
  <li>Small UI bugs ironed out </li>
</ul>
<li>updated CFAJAXPROXY to correct CFC path issue</li>
<li>fixed #436: Windows install serviceDelete error</li>
<li>fixed #433: Default log file location</li>
<li>fixed #430: GetNumericdate() throws error</li>
<li>fixed #431: automatically trim whitespace from columnnames</li>
<li>fixed #431: missing number fields in spreadsheet after SpreadsheetRemoveColumn</li>
<li>new Zip/ZipList/Unzip functions</li>
<li>CFZIP now leverages Apache Compress library fixing issues with foreign characters</li>
<li>fixed #429: ValueList function doesn't work on queries created by CFDIRECTORY with listinfo="Name"</li>
<li>fixed #428: cfquery.currentRow is default 0</li>
<li>fixed #425: ImagePaste() returns error: attribute passed in was not of type image</li>
<li>fixed #416: cfscript, language=javascript, internal server error</li>
<li>fixed #412: CFQuery fails to validate JDBC hoststring where multiple hosts are specified</li>
<li>added Bouncy Castle distribution [/WEB-INF/lib/ updated]</li>
<li>DebuggerPlugin respects the <ipaddresses> list to control access</li>
<li>removed the need for file:// in the plugin jar list</li>
<li>updated log4j JAR [/WEB-INF/lib/ updated]</li>
<li>fixed #263: Bug with variablename validation with CFPARAM and ISVALID()</li>
<li>fixed #407: Single instance (custom OpenBD install) fails to pick up plugins</li>
<li>fixed #405: The tag cfhtmlhead throws a bad template error</li>
</ul>

<h2>2.0.2 - January 2012</h2>

<ul>
<li>fixed #202: Web Services error on Single-instance installations</li>
<li>added StructListNew()</li>
<li>fixed #403: Default params in CFC methods in CFSCRIPT loses values</li>
<li>fixed #245: unnamed function argument not found</li>
<li>fixed #52: support for typed array TYPE in CFARGUMENT</li>
<li>added function SocketConnect() / SocketServerStart() / SocketServerStop() / SocketServerGetClients()</li>
<li>added function SpreadSheetQueryRead()/SpreadSheetQueryWrite()</li>
<li>added function GetApplicationMetaData()</li>
<li>added support for 'this.datasource' in Application.cfc / CFAPPLICATION</li>
<li>updated CFHTTP file/path downloads straight to file, using no memory</li>
<li>added "runonce" flag to CFINCLUDE/RenderInclude()</li>
<li>fixed SpreadSheetNew() XLSX [/WEB-INF/lib/ updated]</li>
<li>updated AmazonRegisterDataSource() to support multiple regions</li>
<li>added QueryAddRow() function to turn a struct into a row</li>
<li>fixed QueryRun() list=true bug</li>
<li>fixed QuotedValue() list bug</li>
<li>fixed 399: CFCOOKIE does not support argument collection</li>
<li>fixed 105: Application.cfc, this.customTagPaths supported</li>
</ul>

<h2>2.0.1 - December 2011</h2>

<ul>
<li>ImageResize tweaked for better scaling results</li>
<li>rewrote the SearchEngineFriendlyURLFilter</li>
<li>updated OpenBD Desktop to remove core plugins</li>
<li>fixed #397: OpenBD Desktop Shadow Folder not working as expected</li>
<li>updated Ready2Run Jetty for Windows Service</li>
<li>cfinvoke supports attributeCollection</li>
<li>fixed CFDIRECTORY/DirectoryList() to match other engines</li>
<li>remove run-once scheduled tasks from schedule engine</li>
<li>upgraded to Apache Lucene 3.5 [/WEB-INF/lib/ updated]</li>
<li>fixed CFINDEX atttributecollection bug</li>
<li>added defaultreturn param for ValueList()/QuotedValueList()</li>
<li>fixed #368: Enabled SearchEngineFriendlyURLFilter by default</li>
<li>fixed #386: SearchEngineFriendlyURLFilter fails on templates with multiple dots</li>
<li>fixed #390: CFC method with returntype="void" doesn't throw error when method returns</li>
<li>fixed #391: 2.0 Get Directory From Path Error</li>
<li>fixed #393: CFMAIL TAG difference in behaviour with attributes</li>
</ul>


<h2>2.0 - November 2011</h2>

<ul>
<li>fixed #382: CFLOOP missing CHARSET attribute
</li><li>added MongoXXX() integration to MongoDB
</li><li>CronTagPlugin promoted to core engine
</li><li>LoginPlugin promoted to core engine [/WEB-INF/lib/ updated]
</li><li>upgraded MySQL JAR 5.1.18
</li><li>added DirectoryDelete() with recurse
</li><li>DirectoryList() matching CFDIRECTORY for function
</li><li>AmazonS3Read/AmazonS3Write can read/write objects as well as file
</li><li>fixed FileMove() to take in file and/or directory
</li><li>added CFSCRIPT language='javascript'
</li><li>fixed isArray() for inner XML documents
</li><li>fixed exception handling [/WEB-INF/lib/openbdplugin-debugger.jar updated]
</li><li>fixed #36: CFSCHEDULE action=pause/resume not supported
</li><li>fixed #175: Feature Request: Ability to pause scheduler so no scheduled tasks run
</li><li>fixed #381: GetDirectoryfrompath() removing trail slash
</li><li>upgraded YUI Compressor JAR
</li><li>CFAJAXPROXY now supports complex object passing
</li><li>fixed CFHTTP gzip encoding
</li><li>CFSMTP plugin integrated to core branch [/WEB-INF/lib/ updated]
</li><li>SpreadSheet plugin integrated to core branch [/WEB-INF/lib/ updated]
</li><li>fixed #376: Update PDFbox to support PDF 1.3+
</li><li>refactored internal rendering engine
</li><li>fixed #379: Collections not being registered properly anymore
</li><li>improved CFLOG; recreate missing directories/files
</li><li>improved CFAJAXPROXY handling
</li><li>fixed CFSCRIPT exception handling [edge case]
</li><li>fixed #313: javacast to String[] for Object parameter
</li><li>fixed npe when array index is non-existant variable
</li><li>fixed ImageRead()/ImageWrite() functions
</li><li>fixed CFSTYLESHEET/CFJAVASCRIPT recreate missing directory
</li><li>updated fileXXX() functions to support native
</li><li>fixed CollectionFactory on startup for Search
</li><li>added: flush() method for CFSCRIPT usage
</li><li>fixed #377: Single quotes aren't escaped when using functions inside CFQUERY
</li><li>upgraded Apache Lucene to 3.4.0
</li><li>Added extra attributes to CollectionSearch()
</li><li>better handling for invalid emails in CFMAIL
</li><li>added #203: Feature Request: DateTimeFormat()
</li><li>fixed #229: Added CollectionStatus() for a single collection
</li><li>fixed #375:	Add statusCode attribute to CFLOCATION
</li><li>added GetHttpStatusLabel() function
</li><li>added toBoolean() function
</li><li>added QueryRenameColumn() function
</li><li>fixed Lucene search query, reset it back to 0
</li><li>Fixed CollectionCreate()/CFINDEX on Linux
</li><li>fixed ysod on bad function parameter count
</li><li>Search Refactored<ul>
   <li>performance/memory improvements
   </li><li>added CollectionCreate()
   </li><li>added CollectionList()
   </li><li>added CollectionDelete()
   </li><li>added CollectionListCategory()
   </li><li>added CollectionIndexCustom()
   </li><li>added CollectionIndexPath()
   </li><li>added CollectionIndexFile()
   </li><li>added CollectionIndexWeb()
   </li><li>added CollectionIndexDelete()
   </li><li>added CollectionIndexPurge()
   </li><li>added support for indexing: MP3/JPG/TIFF files
   </li><li>added support for limitless custom attributes</li>
	</ul></li>
<li>fixed whitespace tab issue in JSON
</li><li>upgraded Jackson JSON parser to 1.8.3
</li><li>fixed #365: UDFs when copied into other scopes do not work without named arguments
</li><li>upgraded Apache Lucene to 3.3.0
</li><li>added fixEOL() function
</li><li>added JSONDATE encoding support<ul>
	<li>CFFUNCTION added for JSONDATE="LONG|CFML|JSON|HTTP"</li>
	<li>SerializeJSON() new attribute to support encoding</li>
	</ul></li>
<li>added named-param support for throw()
</li><li>fixed #364: Inconsistent pass by value behaviour with arrays
</li><li>fixed #313: javacast support for string[]
</li><li>fixed #146: javacast support for java classes
</li><li>fixed #40: javacast support for BigDecimal, short, char and byte types
</li><li>added #363: Add GetMailUndeliveredDirectory()
</li><li>added 'catchemail' to outgoing email to redirect all mail to a mailbox
</li><li>added <rewritebluedragonxml> flag to stop bluedragon.xml from updating
</li><li>fixed #315: Enhancement: CFJAVASCRIPT support a PATH attribute
</li><li>added html() function
</li><li>refactored string functions
</li><li>fixed #360: CFSTYLESHEET hash clash or incorrect hash wrong files to load
</li><li>fixed #361: Bug with multiple Application.cfc files; same application name
</li><li>added AmazonSQSSetHost()
</li><li>added AmazonSDBGetAttributes() support for consistentRead
</li><li>fixed #359: ImageDrawText() has incorrect code for new Font(fontstr,size,style)
</li><li>added #347: CFDBInfo support
</li><li>added StructEquals() function
</li><li>added #222: Add support for fall through on tag based CFSWITCH
</li><li>fixed #348: Function with returntype="void" and output="true" has a
  WDDX packet not the output
</li><li>fixed #355: isValid </li><li>invalid type 'component' specified
</li><li>fixed #351: Syntax error for chained functions with new Component
</li><li>fixed #353: ArgumentCollection doesn't work for variables as functions
</li><li>fixed #354: Cannot modify array returned from string.split()
</li><li>fixed #352:	"local variable [varname] cannot be declared twice"
</li><li>fixed TAB issue in DeserializeJSon()
</li><li>[GAE] Fixed the GoogleFileIO problem
</li><li>added format= support to ImageGetBlob()
</li><li>added tiff support to ImageRead()
</li><li>fixed bug with ImageCrop()
</li><li>fixed #284: additional fix when using implicit struct/arrays
</li><li>[GAE] #312:	googleQuery where clause with single character
</li><li>fixed #303:	CreateTime() uses incorrect default date
</li><li>added #296: &lt;CFPROCPARAM list="true|false" />
</li><li>updated DeserializeJSON()<ul><li>switched to Jackson JSON parsing library
   </li><li>added 'file' parameter to function
</li></li></ul>
<li>[Desktop] Allow for web.xml to be in the shadow folder
</li><li>reduced memory footprint on cfSession
</li><li>fixed #284: CFLOOP list reference issue
</li><li>fixed #339: Internal Server Error in Debug output
</li><li>fixed #344: Error in SpreadsheetFormatColumn(s)
</li><li>fixed SpreadSheetAddInfo() function on blank XLS files
</li><li>fixed #343: Problem in SpreadSheetInfo() function
</li><li>fixed #342: Compatibility issue : generateSecretKey()
</li><li>fixed #340: VFS functions </li><li>Case sensitive for s3://
</li><li>added &lt;div id='openbddebug'> to Debugger output
</li><li>fixed #337: CFDIRECTORY ACTION is case sensitive
</li><li>fixed #338: DateConvert() displays 24 instead of 00 for midnight
</li><li>Amazon Updates<ul>
   <li>added checked S3 connection and FileNotFound Exception
   </li><li>update amazon S3 classes avoid using generic Exception
   </li><li>encode and fix signed url</li>
   </li></ul>
<li>fixed #246: REEscape update
</li><li>fixed #302: CFFORM preserveData only preserves type="text"
</li><li>fixed #260: Update ParseDatetime() to handle HTTP time strings
</li><li>fixed #155: Allow ability to loop over Java byte array
</li><li>fixed #335: XmlValidate() outputs the error message, line and
  column numbers in different order
</li><li>[GAE] Fixed the FileUpload()
</li><li>fixed #331: FileRead function not work with files opened in binary mode
</li><li>[Desktop] Bundled the official plugins; optional on/off
</li><li>[Desktop] Added the ability to customize extensions
</li><li>[Desktop] Bundled the manual and admin console
</li><li>fixed #325: XSLT processor throws error
</li><li>added Logger() function
</li><li>fixed #329: Misspelled Image Function: ImageSetantialisaing()
</li><li>fixed DeSerializeJSon() on blank strings
</li><li>fixed #272 enhancement: add linedelimiter parameter to Csvwrite()
</li><li>fixed directorylist() bug with s3 url on linux
</li><li>updated documentation for CFCACHECONTENT
</li><li>fixed #320: Pass by ref on Xpath no longer functions
</li><li>added 'customdata' to the CFMAIL callback
</li><li>fixed looping around the dates
</li><li>[GAE] added cfcomponent.cfc to the WAR
</li><li>[STD] Updated the MySQL driver to 5,1,15
</li><li>[Desktop] Added in Google Proxy option
</li><li>[GAE] fixed GoogleKey()
</li><li>added CFMAIL callback for onMailSend()/onMailFail()
</li><li>[STD] added function: getMailSpoolDirectory()
</li><li>[Desktop] create default index.cfm for GAE deployment
</li><li>[GAE] fixed remote CFC processing
</li><li>[Desktop] fixed #317: Missing servlet mappings in WEB-XML
</li><li>fixed #139: TagContext order in cfcatch is in opposite direction
</li><li>fixed XALAN memory leak for XmlSearch()
</li><li>added support for PRIORITY attribute in CFMAIL
</li><li>added new ReEscape function
</li><li>fixed #292: added CFINTERFACE support
</li><li>fixed #186: ParseDateTime support for unix style date/time
</li><li>fixed #294: LSisDate performance
</li><li>fixed #307: BinaryEncode & BinaryDecode with Hex or UU algorithm
</li><li>fixed #188: CFMX incompatability </li><li>session timeouts
</li><li>fixed #286: DeSerializeJSON does not handle null values correctly.
</li><li>fixed #293: Using SetProfilestring with a file not yet created fails
</li><li>fixed #288: CFCOOKIE Invalid expires date format with non english locale
</li><li>fixed #141: CFIMAGE Fails Silently When srcfile Doesn't Exist
</li><li>fixed #132: CFIMAGE nameconflict="makeunique" not working
</li><li>fixed #304: CFPOP auto generation of ATTACHMENTPATH directory
</li><li>fixed #306: CFPOP GENERATEUNIQUEFILENAMES attribute support for booleans
</li><li>src maintenance for Google App Engine Merge
</li><li>support for CFZIP action=ZIP/UNZIP and FILE pseudonyms
</li><li>fixed #298: returntype for CFTRANSACTION
</li><li>fixed #297: bug in compare/comparenocase
</li><li>fixed CFHTTPPARAM
</li><li>fixed deserializejson when input is a string
</li><li>fixed onSessionEnd missing application scope
</li><li>added 'attributeCollection' support to core functions
</li><li>changed 'image' to 'name' in ImageXX() functions
</li><li>added flag to keep function/cffunction vars scoped
</li><li>fixed AmazonGetSignedURL() call
</li><li>fixed #290: cfscript switch support of unquoted negative numbers
</li><li>fixed potential NPE introduced in extended function support
</li><li>added Image function support<ul>
   <li>ImageNew()
   </li><li>ImageRead()
   </li><li>ImageWrite()
   </li><li>ImageWriteBase64()
   </li><li>ImageReadBase64()
   </li><li>IsImage()
   </li><li>ImageGetExifMetaData()
   </li><li>ImageGetExitTag()
   </li><li>ImageInfo()
   </li><li>ImageGetWidth()
   </li><li>ImageGetHeight()
   </li><li>ImageGetBufferedImage()
   </li><li>ImageBlob()
   </li><li>ImageCrop()
   </li><li>ImageBlur()
   </li><li>ImageSharpen()
   </li><li>ImageNegative()
   </li><li>ImageGrayScale()
   </li><li>ImageFlip()
   </li><li>ImagePaste()
   </li><li>ImageResize()
   </li><li>ImageRotate()
   </li><li>ImageAddBorder()
   </li><li>ImageClearRect()
   </li><li>ImageDrawRect()
   </li><li>ImageDrawRoundRect()
   </li><li>ImageDrawArc()
   </li><li>ImageDrawBeveledRect()
   </li><li>ImageDrawLine()
   </li><li>ImageDrawLines()
   </li><li>ImageDrawPoint()
   </li><li>ImageDrawOval()
   </li><li>ImageDrawText()
   </li><li>ImageDrawingColor()
   </li><li>ImageSetBackgroundColor()
   </li><li>ImageSetAntialisasing()
   </li><li>ImageXORDrawingMode()
   </li><li>ImageReflection()
   </li><li>ImageContrastBrightness()
   </li><li>toDataURI()</li>
   </li></ul>
<li>added support for PUBDATE in CFFEED
</li><li>extended function support in CFSCRIPT
</li><li>Amazon Updates<ul>
   <li>added AmazonS3GetInfo()
   </li><li>updated AmazonS3List() to return sub-directories
   </li><li>updated AmazonS3Write() to support meta-data and storage class</li>
</li></ul>
<li>strict mode added for ArrayPassingByReference flag
</li><li>CFSCRIPT::java added export of methods
</li><li>CFSCRIPT::java added import support
</li><li>added attributeCollection/docs support for:<ul>
   <li>CFABORT
   </li><li>CFASSOCIATE
   </li><li>CFCHARTDATA
   </li><li>CFCOL
   </li><li>CFCONTENT
   </li><li>CFDIRECTORY
   </li><li>CFDUMP
   </li><li>CFERROR
   </li><li>CFEXECUTE
   </li><li>CFFILE
   </li><li>CFFLUSH
   </li><li>CFHEADER
   </li><li>CFHTMLBODY
   </li><li>CFHTMLHEAD
   </li><li>CFHTTP
   </li><li>CFHTTPPARAM
   </li><li>CFINCLUDE
   </li><li>CFLOCATION
   </li><li>CFLOCK
   </li><li>CFLOG
   </li><li>CFMAIL
   </li><li>CFMAILPART
   </li><li>CFMAILPARAM
   </li><li>CFOUTPUT
   </li><li>CFPAUSE
   </li><li>CFRETHROW
   </li><li>CFSAVECONTENT
   </li><li>CFTIMER
   </li><li>CFTHROW
   </li><li>CFWDDX
   </li><li>CFIMAGE
   </li><li>CFZIP
   </li><li>CFFEED</li>
  </li></ul>
 <li>added CFSAVECONTENT TRIM="true|false" attribute
</li><li>added underlying attributeCollection support for tags </li>

</li>
</ul>

<h2>1.4 - October 2010</h2>

<ul><li> fixed #282: dateformat bug introduced in fix for #234
</li><li> fixed #151: "fullname" key not included in cfc metadata
</li><li> added &lt;CFSCRIPT lang="java"&gt;
</li><li> added system functions
<ul><li>  SystemMemory()
</li><li>  SystemFileCacheInfo()
</li><li>  SystemFileCacheList()

</li><li>  SystemFileCacheFlush()
</li><li>  SessionCount( [appname] )
</li></ul>
</li><li> fixed #147: LSDateFormat handling of nulls
</li><li> fixed #234: DateFormat handling of mask containing single quote
</li><li> fixed #236: ListSort with numeric sort of dates
</li><li> fixed need for init function in component when using 'new' operator
</li><li> added hooks for custom languages &lt;CFSCRIPT lang=""&gt;

</li><li> Upgraded Lucene to 3.0.2
</li><li> added
<ul><li> FileUpload()
</li><li> FileUploadAll()
</li></ul>
</li><li> added CFFILE ACTION=UPLOADALL
</li><li> added network functions
<ul><li>  IPResolveDomain()
</li><li>  IPReverseLookup()

</li><li>  IPGetMXRecords()
</li><li>  IPAsInteger()
</li><li>  IPInRange()
</li><li>  IPNetworkAddress()
</li><li>  IPBroadcastAddress()
</li><li>  IPGetLowAddress()
</li><li>  IPGetHighAddress()
</li><li>  IPToCIDR()
</li><li>  IPGetCount()

</li></ul>
</li><li> fixed #276: SerializeJson should not escape simple quote
</li><li> fixed #41: issue with argumentCollection and named arguments
</li><li> fixed #154: CFFTP ignores timeout values
</li><li> fixed #97: server.coldfusion.productversion should use comma as separator as opposed to a period
</li><li> fixed #227: CFDIRECTORY silently fails trying to create directory
</li><li> fixed #267: CFTEXTAREA does not accept text using Safari
</li><li> fixed #269: CFDIRECTORY action="list" attribute "filter" fails when bracket characters in filter string
</li><li> fixed #279: CFDIRECTORY bug with "type"

</li><li> fixed #281: CFDIRECTORY listInfo additional support
</li><li> fixed #280: QueryDeleteRow() fails if only one row is in Query
</li><li> fixed #278: XMLValidate() result messages are of an incomplete format
</li><li> added ApplicationList()/ApplicationCount()/ApplicationRemove()
</li><li> added
<ul><li> DataLoad()
</li><li> DataSave()
</li></ul>
</li><li> updated onApplicationStart() loading times for diff apps at once

</li><li> updated the CFSCHEDULE to calculate the starttime faster
</li><li> fixed #273: NPE when passing array with undefined elements to a function
</li><li> improved CFQUERY background=true; for higher volume queries
</li><li> fixed Application.cfc form-upload problem onMissingTemplate()
</li><li> added QueryRequestMetrics() to track how much per-request querys
</li><li> fixed the H2 database URL parsing
</li><li> fixed "Response committed, cannot add header" in redirects
</li><li> added more detail to the [server] properties
</li><li> updated the database pooling manager for quick failures

</li><li> fixed increasing timeout issue with SQL Server datasources
</li><li> added Console()/ConsoleOutput() debugging functions
</li><li> added support for CFMAIL useSSL and useTLS attributes
</li><li> added support for Eucalyptus Walrus cloud storage
</li><li> added Amazon S3 functions
<ul><li>  AmazonS3Read()
</li><li>  AmazonS3Write()
</li><li>  AmazonS3Delete()
</li><li>  AmazonS3Rename()

</li><li>  AmazonS3SetAcl()
</li><li>  AmazonS3ListBuckets()
</li><li>  AmazonS3List()
</li><li>  AmazonS3GetUrl()
</li></ul>
</li><li> rewritten Amazon S3 access library (removed JetS3)
</li><li> fixed #150: CFSELECT queryPositon attribute
</li><li> fixed &lt;cfreturn&gt; bug when inside a CFOUTPUT inside a CFC

</li><li> fixed base component.cfc to include init() method
</li><li> added support for arrays in for...in loops in cfscript
</li><li> fixed #254: Can't flush cfquery cache
</li><li> fixed #255: MySQL results are "undefined class" instead of "null"
</li><li> improved CFDUMP; add OUTPUT and ABORT support
</li><li> added WriteDump()
</li><li> fixed ARGUMENTCOLLECTION bug inside CFINVOKE with arguments
</li><li> updated Amazon Function support
<ul><li>  added AmazonRegisterDatasource()

</li><li>  renamed Amazon functions to be consistent
</li><li>  rejigged functions to support named-parameter calling
</li></ul>
</li><li> cookie updates: SetCookie() added; httponly flag support
</li><li> renamed functions to: CSVRead()/CSVWrite()
</li><li> added WriteLog()/DataSourceInfo()
</li><li> added support for core functions to have named/params
</li><li> fixed tag parser for catching &lt;#cf tags
</li><li> added NOCFML tag

</li><li> improved initial cfml parsing speed
</li><li> fixed isValid("integer",xx) bug
</li><li> fixed NA#3332: Indexing a query with categories using CFINDEX
</li><li> fixed thread/lock treated as reserved word
</li><li> added support for transaction in cfscript
</li><li> added style="document-wrapped" to CFCOMPONENT
</li><li> fixed #241: use of "import" as variable name or function name in CFC throws error
</li><li> fixed transaction treated as reserved word
</li><li> fixed Application.cfc onMissingTemplate() "application" scope missing

</li><li> added support for lock and thread in cfscript
</li><li> fixed multiple attribute support for cfscript param operator
</li><li> added support for dynamic values in abort, exit and throw operators
</li><li> fixed issue passing SessionHeader back to Salesforce web service
</li><li> added support for exit, param and rethrow, throw operators in cfscript
</li><li> fixed handling of missing cfscript endtag error
</li><li> fixed NA#3327: cfimap does not support download of non-ascii named attachments
</li></ul>

<h2>1.3 - April 2010</h2>

<ul><li> fixed NPE due to recent parser update
</li><li> added support for abort operator in cfscript
</li><li> Moved out the CFSMTP tag into its own plugin implementation
</li><li> Added per-file caching support to imported components
</li><li> Added type= attribute into the javascript block
</li><li> fixed NPE in debugging switch statements in cfscript
</li><li> Added support for PATH attribute to CFIMPORT
</li><li> Added import statement support to cfscript

</li><li> added: Server.cfc onServerStart() support
</li><li> fixed #217: Retain file date after CFFILE copy/move
</li><li> fixed NA#3319: With scheduled tasks, seconds field of start/end time is ignored
</li><li> fixed NPE in cfschedule engine
</li><li> fixed NA#3318: Interval scheduled tasks with end time near midnight not processed properly
</li><li> added support for 'new' operator
</li><li> fixed #215: Unexpected behavior using java.util.collections shuffle
</li><li> added qualifier parameter to readcsv function
</li><li> added ReadCSV(); Updated ToCSV()

</li><li> fixed NA#3315: cfschedule requestTimeout value of 0 or less not handled properly
</li><li> fixed NA#3314: scheduled task with start/end time of 2am not handled properly
</li><li> updated CreateObject(); defaults to 'component' if only 1 param
</li><li> various core memory usage optimizations
</li><li> made the following improvements to the CFDOCUMENT tag:
<ul><li> default headers/footers to align left to match commercial BD and CF
</li><li> support 'srcFile' attribute with relative paths
</li><li> support 'src' attribute with relative URLs
</li><li> support attributes 'backgroundVisible', 'author', 'title', 'subject' and 'keywords'

</li><li> improve error reporting when PDF generation fails
</li><li> support encryption even if 'ownerpassword', 'userpassword' and 'permissions' aren't set
</li><li> fix bug with 'name' attribute being ignored
</li><li> support 'mimetype' attribute value of 'text/plain'
</li><li> support 'permissions' attribute value of 'AllowFillIn'
</li><li> if 'permissions' attribute is not present then default to no permissions
</li><li> support 'encryption' attribute value of '40-bit' and '128-bit'
</li><li> support &lt;body&gt; tags 'bgcolor' attribute in HTML that's being converted to PDF

</li><li> support some HTML tags in header and footer sections
</li><li> return an error for permissions that are not valid with 40-bit encryption
</li><li> fix bug with totalpagecount and multiple sections
</li><li> add support for totalsectionpagecount and currentsectionpagenumber
</li></ul>
</li><li> improved fix for NA#3308: cfcache action="FLUSH" doesn't flush cached files with another server url part
</li><li> added GetTagStack()
</li><li> fixed NA#3308: cfcache action="FLUSH" doesn't flush cached files with another server url part
</li><li> fixed NA#2814: secondary fix for *.*.* wildcards

</li><li> fixed support for more complex values in implicit struct/array creation
</li><li> fixed NA#3309: CFQUERYBATCH throws exception if spool directory doesn't exist
</li><li> fixed support for CFTRY block with CFFINALLY but no CFCATCH
</li><li> support 'finally' in cfscript
</li><li> added CFFINALLY support to CFTRY..CFCATCH
</li><li> fixed #199: JsStringFormat() encoding unicode safe
</li><li> added isInstanceOf() function (issue #123)
</li><li> fixed #209: support for string based keys in implicit struct creation
</li><li> fixed issue with validation of local variables

</li><li> fixed #208 Custom Tag in &lt;cfthread&gt;
</li><li> cfchart now supports date/time values and will use DateAxis if date/time data is detected for series
</li><li> added support for 'include' operator
</li><li> added renderInclude() function
</li><li> cfstylesheet supports INLINE/HEAD/FOOTER
</li><li> fixed support of local variable declaration without initial value
</li><li> updated CFMAIL/CFCHART/QueryServer/QuerySlowLog for VFS

</li><li> expanded support for specifying absolute paths as $/a/b/... (see #204)
</li><li> updated CFLOG/CFTRACE to utilise VFS
</li><li> fixed NA#3262: cfdirectory * ISE if the 'action' attribute is a variable and no 'name' attribute
</li><li> fixed #204: The VFS broke portable absolute paths such as $/usr/webapps/work on Windows
</li><li> fixed #168: Plugin Manager Infinite Loop Failure * Bombs Tomcat
</li><li> updated webservices/cfjavascript/cfstylesheet to utilise VFS
</li><li> update fix for bug NA#3288 to allow tasks to run on the end date but not after
</li><li> added support for operator support in &lt;cfif&gt;/&lt;cfelseif&gt;

</li><li> refix of NA#1450: Invoking CFC methods with PACKAGE access with CFINVOKE
</li><li> refix of NA#1751: CFINCLUDing file that was just created does not work
</li><li> fixed DataSourceDelete() bug
</li><li> fixed NA#3301: timeout attribute not honored by &lt;cfftp&gt; tag
</li><li> fixed problem with creation of collections due to GAEVFS [FileUtils.getCanonicalPath()]
</li><li> GAE support (phase 1 of 2) added use of GAEVFS in key areas (merged from OpenBD-Google branch).
</li><li> fixed bug with ANTLR parser try/catching of java exceptions

</li><li> fixed bug with ANTLR parser incorrectly identifying assignment statement as implicit struct
</li><li> fixed #196: OpenBD won't run on ServletExec 6.0 (and possibly some other Servlet/JSP Engine brands)
</li><li> fixed bug in implicit struct/array creation with non-primary expression values
</li><li> added support for implicit struct/array creation
</li><li> added support for operators: +=, -=,&nbsp;%=, /=, *=, &amp;=, ++, --,&nbsp;%, ==,&nbsp;!=, &lt;, &gt;,&lt;=, &gt;=,&nbsp;!, ||, &amp;&amp;

</li><li> new ANTLR based parser for cfscript/expression engine
</li><li> fixed NA#3288: scheduled task * daily task with enddate in the past continues to run
</li><li> fixed NA#3292: scheduled tasks * do not delete the task from bluedragon.xml once enddate is reached
</li><li> fixed NA#3284: Errors with Date Functions when no day value is provided
</li><li> fixed #181: Added ListCompact()
</li><li> fixed #164: SerializeJSon() key case
</li><li> fixed #121: conversion error when "E-"
</li><li> fixed #185: HtmlCleanUp() not bubbling up all errors
</li><li> fixed #190: Treating as a number "-."

</li><li> fixed #143: HtmlEditFormat() double encoding
</li><li> fixed #192: deserializeJSON() mistreating stringed-numbers
</li><li> fixed #162: isJSON() for simple strings
</li><li> isValid('email') now less strict
</li><li> added JSONP support to remote calling CFC's
</li><li> update CFSCHEDULE engine to make sure only one instance
</li><li> update CFMAIL mail sending code to match latest BD 7.1 code
</li><li> fixed NA#3285: CFMAIL sometimes fails to send an email
</li><li> fixed CFMAIL setting Message-ID now persists

</li><li> added: ThrowObject() / Throw()
</li><li> added: QueryDeleteColumn()/QueryColumnArray()
</li><li> added: QueryIsEmpty()/QueryRowStruct()/QueryColumnList()
</li><li> added #187: Include Java Exception Classes in CFCATCH
</li><li> added DataSourceCreate()/DataSourceDelete()/DataSourceIsValid()
</li><li> fixed #180: Improve handling of IllegalAccessException when invoking methods
</li><li> fixed #178: cfc output missing from response when it throws an exception
</li><li> expanded the fix for NA#3260 to include newly written files (not just appending to existing files)
</li><li> fixed NA#3260: CFFILE leaks descriptors when appending to a file

</li><li> ported NA#3282: output missing when cfc function throws an Exception
</li><li> fixed NA#3219: xmlParse() does not resolve SYSTEM ENTITY
</li><li> fixed NA#3281: &lt;CFINCLUDE page="a.cfc?method=b"&gt; fails on Jetty
</li><li> fixed onRequestStart() / onApplicationStart() return values
</li><li> fixed #172: Expired daily scheduled task runs
</li><li> improved #157: CFJAVASCRIPT: Positional/Unique names

</li><li> fixed NA#3172: CFDIRECTORY * sort attribute won't work without column name
</li><li> added QueryRun()/QueryOfQueryRun()
</li><li> added ArrayRest()/ArraySlice()/ArrayReverse()
</li><li> added ArrayConcat()/ArrayValueCount()/ArrayValueCountNoCase()/ListSwap()
</li><li> added htmlHead()/htmlBody()
</li><li> added ReMatch()/ReMatchNoCase()
</li><li> added ListIndexExists()
</li><li> added ArrayIndexExists()
</li><li> added CFHTMLBODY with POSITION attribute; optional endtag

</li><li> improved CFHTMLHEAD with POSITION attribute; optional endtag
</li><li> added ListTrim()
</li><li> added ArrayLast()/ArrayFirst()/ArrayGet()
</li><li> added ArrayFind()/ArrayContains() functions
</li><li> added ArrayFindNoCase()/ArrayContainsNoCase() functions
</li><li> added HashBinary() function
</li><li> updated SQL Server drivers
</li><li> fixed NA#3275: SearchEngineFriendlyURLFilter may sometimes match a request to the wrong alias
</li></ul>

<h2>1.2 - October 2009</h2>

<ul><li> added Location() function
</li><li> added ToCSV() / ToHTML() functions for query output
</li><li> fixed NA#3226: arguments scope does not like being duplicated more than once
</li><li> updated text-mining to be Apache POI3.5 compliant

</li><li> fixed handling of utf-8 strings in HtmlTidy function
</li><li> fixed NA#3272: QoQ ordering on numeric strings
</li><li> fixed NA#3268: A cfimage resize produces poor quality image
</li><li> mass StringBuffer replacement
</li><li> pluginManager now auto-discovers plugins
</li><li> added HtmlSourceFormat() for printing formatted HTML
</li><li> added HtmlTidy() for cleaning HTML content

</li><li> fixed encoded filename for CFSMTP
</li><li> separate error log for background queries
</li><li> added full support for Nirvanix Cloud Storage API
</li><li> fixed Amazon S3 handler
</li><li> improve error message when CFIMAGE tag fails to modify contrast/brightness.
</li><li> fixed #126: SES Filter and Query String Blanked Out When PathInfo is Present
</li><li> added "server.query.slowlog" tracking
</li><li> added AmazonSimpleDB SetDBStruct() method

</li><li> fixed isValid() for email causing high cpu usage
</li><li> fixed NA#3249: cfimage - transparent .gif files have black backgrounds after edited
</li><li> fixed #133: compilation error when accessing web service where cfc resides in a directory path that includes '-' in a directory name
</li><li> fixed #136: POST to remote CFC method throws error and returns SOAP instead of simple values
</li><li> fixed CFIMAGE FONTCOLOR support
</li><li> removed CFGRAPHDATA from getSupportedTags() output
</li><li> added core Amazon SimpleQueueService support functions
</li><li> fixed CFAJAXPROXY callback function
</li><li> fixed #135: cfexecute - java.io.exception: error=24, too many open files

</li><li> fixed NA#3240: cfindex doesn't provide good title and summary
</li><li> fixed NA#3238: url variables with the same name are appended rather than overwritten
</li><li> fixed NA#3237/NA#3236: issues with '+' operator in QoQ when both operands are query columns
</li><li> updated Amazon SimpleDB support
</li><li> fixed NA#3231: scheduled tasks don't run at correct time
</li><li> fixed support of CFDUMP TOP for CFCs
</li><li> fixed CFAJAXPROXY NullPointerException/JS problem
</li><li> fixed DeserializeJSon() to preserve leading zero's in numbers as strings
</li><li> fixed #115: nesting of CFINVOKE within CFINVOKEARGUMENT

</li><li> fixed#6: further fix for &lt;cfdump&gt; for cfquery now printing the params passed
</li><li> fixed #124: getTempFile does not create the file
</li><li> updated fix for NA#3217: sql inserts from a function does not escape single quotes
</li><li> further fix for #43/#44 when values are equal but underlying element types are string/numeric
</li><li> added support for CFDOCUMENTITEM and CFDOCUMENTSECTION
</li><li> fixed NA#3217: sql inserts from a function does not escape single quotes
</li><li> CFHTTP: disable preemptive authentication, allowing for support of digest authentication

</li><li> support compilation using Java 6
</li><li> add irc support
</li><li> CFDOCUMENT fix: avoid potential NPE if font directory does not exist
</li><li> fixed #114: CFDOCUMENT drops html entities from PDF
</li><li> fixed #113: SerializeJSON() handling of nulls
</li><li> fixed minor issue with defaulting of CFDOCUMENT font directories
</li><li> fixed #111: improved font support for unicode characters in CFDOCUMENT
</li><li> fixed CFFEED ACTION=CREATE publisheddate / duplicate title

</li><li> added "server.system.resourcepath" to specify a different path for the web resources (cfvideoplayer etc) (supports $)
</li><li> fix NA#3071
</li><li> fixed #109: getRealPath Null
</li><li> fixed CacheGet(.); throws exception instead of returning null
</li><li> fix NA#3071: NPE when deserializing CFC with CFSCRIPT in pseudo-constructor
</li><li> fixed CFTHREAD/CFJOIN name="" bug when using CreateUUiD()
</li><li> fixed NA#3209: value "component" for CFFUNCTION RETURNTYPE and CFARGUMENT TYPE
</li></ul>

<h2>1.0.1 - January 2009</h2>

<ul><li> make sure cfpop closes connection when exception occurs
</li><li> fixed NA#3162: cfftp actions exists and existsFile always use passive mode
</li><li> fixed NA#3158: allow "default" to used as a named argument in cfscript
</li><li> fixed #79: QoQ min doesn't work with Date
</li><li> added support for ArrayIsDefined() function
</li><li> added new function ArrayTrim() function

</li><li> fixed NA#3156: CFPOP fails to read email that has invalid characters in addresses
</li><li> added CFFEED ACTION="CREATE"
</li><li> fixed NA#3152: can't add empty string to column of type int or decimal
</li><li> fixed NA#3151: custom fields return empty when indexing pdf files
</li><li> enchancement CFSMTP 'application' attribute to get at proper scope
</li><li> enchancement CFSMTP ip address now available on callback CFC's
</li><li> fixed CFSMTP logging
</li><li> added a better fix for #65
</li><li> fixed #73: arrayLen on binary variable fails

</li><li> added new function HtmlGetPrintableText()
</li><li> added JMX MBeans for cfEngines
</li><li> added JMX functions
</li><li> fixed #70: added support for CF_SQL_TIMESTAMP in QueryNew
</li><li> admin console password issue. Now defaults to 'admin'
</li><li> added jTDS and Microsoft SQL Server driver jars
</li><li> fixed #68: LSDateformat now handles blank string
</li><li> added support for admin to check the mail spool

</li></ul>

<h2>1.0 - March 2008</h2>

<ul><li> added: toBase62() / fromBase62() functions
</li><li> fix error reporting issue introduced in fix for #3128
</li><li> fixed #53: cfassociate bug with custom tag nested more than 2 levels deep within itself
</li><li> add support for this.mappings
</li><li> added: 'SystemReloadConfig()' function for reloading the bluedragon.xml file
</li><li> fixed #65: ClassCastException when accessing a web service that modifies the url variables in Application.cfc
</li><li> fixed#6: &lt;cfdump&gt; for cfquery now printing the params passed

</li><li> fixed#15: &lt;cfdump&gt; only output the styles once
</li><li> added: LISTINFO parameter to &lt;cfdirectory&gt;
</li><li> fixed#30: Add TYPE to the &lt;cfdirectory&gt;
</li><li> added 'cfcachecontent'/'filecache' to the CacheStats()/CacheDeleteAll() methods
</li><li> added IsJSON() / DeSerializeJSON() / SerializeJSON()

</li><li> new DirectoryCreate() DirectoryList() DirectoryDelete()
</li><li> added FileXXX functions; VFS support
</li><li> map cfthread.ERROR metadata variable to cfthread.EXCEPTION for CF compatibilty
</li><li> fixed NA#3136: cfqueryparam * cf_sql_timestamp is inserting inaccurate milliseconds
</li><li> added CFLOOP FILE=X [CHARACTERS=Y]
</li><li> added CFLOOP ARRAY=X

</li><li> added H2 Embedded Database
</li><li> added CFSMTP
</li><li> added Amazon SimpleDB support for CFQUERY + functions
</li><li> added CacheGetAll() function to retrieve all active caches in the engine
</li><li> fixed NA#3130: Default error handler does not handle Bad File Exceptions
</li><li> fixed NA#3128: Internal Server Error occurs when catching a rethrown exception within a function and Debug Output is enabled
</li><li> don't record rethrown exceptions twice in debug output
</li><li> fixed #64 and #NA3134: cfquery without name attribute throws error
</li><li> fixed #61: support cfloop'ing over strings that can be converted to dates

</li><li> upgraded Lucene to 2.4.0
</li><li> fixed #60: Error when invoking UDF with optional arguments
</li><li> fixed NA#3100: simple variables need to be passed by value to CFC methods
</li><li> fixed NA#3119: CFMAPPING RELATIVEPATH attribute does not honor IIS virtual directories
</li><li> fixed #58: Unexpected exception passing String[] to java method
</li><li> fix for MySQL column aliases not being honoured without using useOldAliasMetadataBehavior
</li><li> add support for result variable that specifies the ID of an inserted row
</li><li> fixed #55: Double close bug in cfexecute
</li><li> fixed NA#3112: cfExecute fails with "too many open files" error

</li><li> fix incrementing of newconnections datasource counter
</li><li> fixed NA#2779: No error thrown for a non-empty directory with &lt;cfdirectory action="delete"&gt; without recurse="true"
</li><li> fixed NA#2769: DateDiff function returns unexpected results for dates spanning daylight savings time.
</li><li> fixed NA#3090: client.lastvisit always reports the current time
</li><li> fixed NA#3114: can't invoke CFC private functions within CFTHREAD
</li><li> improve checking for required attributes with CFFILE tag
</li><li> fixed #49: namespaces not honored in cffunction

</li><li> no longer apply DST to cfwddx datetime offset output
</li><li> fixed NA#2890: CFREGISTRY fails to create key under branch that doesn't exist
</li><li> fix bug with CFEXECUTE output and error output
</li><li> fixed NA#3105: cfwddx datetime is not converting to local time
</li><li> fixed NA#2969: remote CFC method call now honours xml return type
</li><li> added in Memcached support
</li><li> added in new abstracted cache implementation
</li><li> fixed NA#3101: Web Service Name cannot be used in cfinvoke tag

</li><li> fixed NA#2934: Exception not thrown when web service cffunction is missing returnType
</li><li> fixed NA#2976: cffile upload nameconflict makeunique fails if multiple files uploaded in same millisecond
</li><li> fixed potential NPE in query batch log if spool directory is not valid
</li><li> fixed reference to OpenBlueDragon.jar for Web services handling
</li><li> deep copy attributes passed to cfthread
</li><li> fixed #38: support cfexecute errorvariable and errorfile
</li><li> fixed #22: support cfthread and thread scope, and full scope access in cfthread body
</li><li> fixed NA#3071: CFC serialization to a file
</li><li> fixed #35: CFEXECUTE arguments passed as an array are split on space

</li><li> support same api as CF8 for cfthread
</li><li> fixed #24: support cfthread action
</li><li> added support for sleep() function
</li><li> fixed NA#3082: constructing java.util.HashMap or java.util.Hashtable from CF struct
</li><li> added support for "Generate UUID as CFTOKEN value" option
</li><li> fixed NA#3079: built-in function initialization error
</li><li> fixed NA#3078: "is-type-of" for CFC in custom tag path (without package)
</li><li> fixed NA#3076: CFCACHE does not flush on file modification
</li><li> added following functionality to CFIMAGE: ability to crop, rotate, add border, adjust brightness and contrast, and apply gray scale filter.

</li><li> fixed #32: cfhttpparam type 'file' is ignored when a file is PUT with cfhttp
</li><li> fixed NA#3073: evaluation of CFLOOP ITEM variable as indirect reference
</li><li> upgraded Lucene to 2.3.2
</li><li> support for OnMissingMethod
</li><li> new fix for NA#2978
</li><li> fixed internal server error when username/password is passed to cfhttp
</li><li> refactored QoQ preparedData
</li><li> add PADDING=<i> attribute to CFQUERYPARAM for padding out numbers</i>

</li><li> refactored CFQUERY to support different implementations
</li><li> fixed NA#3060: issue with trim() on loop index
</li><li> add MonthAsString locale parameter support
</li><li> fixed #18: MonthAsString doesn't output month in current locale
</li><li> fixed #9: cfdump styles updated for xhtml 1.0 compliance
</li><li> fixed NA#3056: SearchEngineFriendlyURLFilter causes duplicate query string parameters
</li><li> fixed potential NPE in mail sending when backup server used
</li><li> fixed NA#3054: Support setting mail host in message-id
</li><li> fixed NA#3045: expandPath results wrong with Apache mod_rewrite.

</li><li> include hostname in file cache key
</li><li> fixed NA#3052: missing &lt;tempdirectory&gt; causes NullPointerException
</li><li> updated coldfusion productname and version variables
</li><li> fixed NA#3051: avoid potential file not found on cfcache file expiry
</li><li> fixed NA#3022: CFCACHE issue with pages containing iso-8859-15 chars
</li><li> fixed NA#3024: xmlParse and CFXML strip the &lt;!DOCTYPE ..&gt; element

</li><li> fixed NA#3028: numberformat issue with mask "09"
</li><li> fixed NA#2999: support string operators on java object operands
</li><li> fixed NA#3031: cfdump of getFunctionList causes internal server error
</li><li> fixed NA#3036: added support for addAll java method for CFARRAY
</li><li> fixed NA#3037: CFTRANSACTION end tag not required for rollback or commit
</li><li> fixed NA#3039: StructKeyExists returns true when value is null
</li><li> fixed NA#3038: Function stored in local variable can't be invoked
</li><li> fixed NA#3040: cfargument type="string" doesn't support java object
</li><li> fixed NA#3042: CFEXIT METHOD="LOOP" within CFELSE or CFELSEIF

</li><li> updated fix for NA#2638 (again): NPE caused by serializing childless xml nodes
</li><li> fixed NA#3046: application scope only times out when session scope enabled
</li><li> fixed NA#3047: Issue with calling of a java method in inner class that extends another inner class that implements a public interface
</li><li> fixed NA#3048: Java Map put() method converts key to string
</li></ul>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->
