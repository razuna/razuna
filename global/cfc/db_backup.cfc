<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfcomponent output="false">
	
	<!--- Setup the DB if DB is not here --->
	<cffunction name="setup" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
				
		<!---  --->
		<!--- START: CREATE TABLES --->
		<!---  --->
		 
		<!--- CREATE BACKUP STATUS DB --->
		<cftry>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE backup_status 
		(
			back_id		VARCHAR(100), 
			back_date	timestamp,
			host_id		BIGINT
		) 
		</cfquery>
		<cfcatch type="database"></cfcatch>
		</cftry>
		 
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.cache 
		(
			cache_token varchar(100) DEFAULT NULL,
			cache_type varchar(20) DEFAULT NULL,
			host_id bigint DEFAULT NULL
		)
		</cfquery>
		<!--- CREATE MODULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.modules 
		(
			MOD_ID 			BIGINT NOT NULL, 
			MOD_NAME 		VARCHAR(50) NOT NULL, 
			MOD_SHORT 		VARCHAR(3) NOT NULL, 
			MOD_HOST_ID 	BIGINT DEFAULT NULL
		)
		</cfquery>
		<!--- CREATE PERMISSION --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.permissions 
		(
			PER_ID 			BIGINT NOT NULL, 
			PER_KEY  		VARCHAR(50) NOT NULL, 
			PER_HOST_ID 	BIGINT DEFAULT NULL, 
			PER_ACTIVE 		BIGINT DEFAULT 1 NOT NULL, 
			PER_MOD_ID 		BIGINT NOT NULL,
			PER_LEVEL		VARCHAR(10)
		)
		</cfquery>
		<!--- CREATE GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.groups
		(	
			GRP_ID 				VARCHAR(100) NOT NULL, 
			GRP_NAME 			VARCHAR(50), 
			GRP_HOST_ID 		BIGINT DEFAULT NULL, 
			GRP_MOD_ID 			BIGINT NOT NULL, 
			GRP_TRANSLATION_KEY VARCHAR(50)
		)
		</cfquery>
		<!--- CREATE HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.hosts 
		(
		  HOST_ID           BIGINT NOT NULL,
		  HOST_NAME         VARCHAR(100),
		  HOST_PATH         VARCHAR(50),
		  HOST_CREATE_DATE  DATE,
		  HOST_DB_PREFIX    VARCHAR(40),
		  HOST_LANG         BIGINT,
		  HOST_TYPE			VARCHAR(2) DEFAULT 'F',
		  HOST_SHARD_GROUP	VARCHAR(10),
		  HOST_NAME_CUSTOM  VARCHAR(200)
		)
		</cfquery>
		<!--- CREATE USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.users 
		(
		  USER_ID              VARCHAR(100) NOT NULL,
		  USER_LOGIN_NAME      VARCHAR(50) NOT NULL,
		  USER_EMAIL           VARCHAR(80) NOT NULL,
		  USER_FIRST_NAME      VARCHAR(80),
		  USER_LAST_NAME       VARCHAR(80),
		  USER_PASS            VARCHAR(500) NOT NULL,
		  USER_COMPANY         VARCHAR(80),
		  USER_STREET          VARCHAR(80),
		  USER_STREET_NR       BIGINT(6),
		  USER_STREET_2        VARCHAR(80),
		  USER_STREET_NR_2     BIGINT(6),
		  USER_ZIP             BIGINT(7),
		  USER_CITY            VARCHAR(50),
		  USER_COUNTRY         VARCHAR(60),
		  USER_PHONE           VARCHAR(30),
		  USER_PHONE_2         VARCHAR(30),
		  USER_MOBILE          VARCHAR(30),
		  USER_FAX             VARCHAR(30),
		  USER_CREATE_DATE     DATE,
		  USER_CHANGE_DATE     DATE,
		  USER_ACTIVE          VARCHAR(2),
		  USER_IN_ADMIN        VARCHAR(2),
		  USER_IN_DAM          VARCHAR(2),
		  USER_SALUTATION      VARCHAR(500),
		  USER_IN_VP		   VARCHAR(2) DEFAULT 'F',
		  SET2_NIRVANIX_NAME   VARCHAR(500),
		  SET2_NIRVANIX_PASS   VARCHAR(500),
		  USER_API_KEY		   VARCHAR(100)
		)
		</cfquery>
		<!--- CREATE CT_GROUPS_USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.ct_groups_users
		(	
		CT_G_U_GRP_ID 		VARCHAR(100) NOT NULL, 
		CT_G_U_USER_ID 		VARCHAR(100) NOT NULL,
		rec_uuid			VARCHAR(100)
		)
		</cfquery>
		<!--- CREATE CT_GROUPS_PERMISSIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.ct_groups_permissions
		(	
		CT_G_P_PER_ID 		BIGINT NOT NULL, 
		CT_G_P_GRP_ID 		VARCHAR(100) NOT NULL		
		)
		</cfquery>
		<!--- CREATE LOG_ACTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.log_actions 
		(
		  LOG_ACT_ID    BIGINT,
		  LOG_ACT_TEXT  VARCHAR(200)
		)
		</cfquery>
		<!--- CREATE CT_USERS_HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.ct_users_hosts 
		(
		  CT_U_H_USER_ID  VARCHAR(100),
		  CT_U_H_HOST_ID  BIGINT,
		  rec_uuid		  VARCHAR(100)
		)
		</cfquery>
		<!--- CREATE USERS_LOGIN --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.users_login 
		(
		  USER_LOGIN_ID         BIGINT NOT NULL,
		  USER_ID               VARCHAR(100),
		  USER_LOGIN_DATE       DATE,
		  USER_LOGIN_TIME       TIMESTAMP,
		  USER_LOGIN_PROJECT    BIGINT,
		  USER_LOGIN_SESSION    VARCHAR(200),
		  USER_LOGIN_DATESTAMP  DATE
		)
		</cfquery>
		<!--- CREATE WISDOM --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.wisdom 
		(
		  WIS_ID      BIGINT,
		  WIS_TEXT    VARCHAR(3000),
		  WIS_AUTHOR  VARCHAR(200)
		)
		</cfquery>
		<!--- CREATE USERS_COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.users_comments
		(
		  USER_ID_R           VARCHAR(100),
		  USER_COMMENT        VARCHAR(4000),
		  CREATE_DATE         DATE,
		  CHANGE_DATE         DATE,
		  USER_COMMENT_BY     BIGINT,
		  USER_COMMENT_TITLE  VARCHAR(500),
		  COMMENT_ID          BIGINT
		)
		</cfquery>
		<!--- CREATE FILE_TYPES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.file_types
		(
		  TYPE_ID              VARCHAR(5),
		  TYPE_TYPE            VARCHAR(3),
		  TYPE_MIMECONTENT     VARCHAR(50),
		  TYPE_MIMESUBCONTENT  VARCHAR(50)
		)
		</cfquery>
		<!--- CREATE CT_USERS_REMOTEUSERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.ct_users_remoteusers
		(
		   	CT_U_RU_ID                BIGINT NOT NULL, 
			CT_U_RU_USER_ID           VARCHAR(100) NOT NULL, 
			CT_U_RU_REMOTE_URL        VARCHAR(4000) NOT NULL, 
			CT_U_RU_REMOTE_USER_ID    VARCHAR(100) NOT NULL, 
			CT_U_RU_REMOTE_USER_NAME  VARCHAR(4000) NOT NULL, 
			CT_U_RU_REMOTE_USER_EMAIL VARCHAR(4000), 
			CT_U_RU_REMOTE_CONFIRMED  BIGINT DEFAULT 0 NOT NULL, 
			CT_U_RU_UUID              VARCHAR(4000) NOT NULL, 
			CT_U_RU_VALIDUNTIL        DATE, 
			CT_U_RU_CONFIRMED         BIGINT DEFAULT 0 NOT NULL
		)
		</cfquery>
		<!--- CREATE WEBSERVICES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.webservices
		(
			SESSIONTOKEN 	VARCHAR(100), 
			TIMEOUT 		TIMESTAMP,
			GROUPOFUSER		VARCHAR(20),
			USERID			VARCHAR(100)
		)
		</cfquery>
		<!--- CREATE SEARCH REINDEX --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.search_reindex
		(
			theid			VARCHAR(100),
			thevalue		BIGINT,
			thehostid		BIGINT,
			datetime		TIMESTAMP
		)
		</cfquery>
		<!--- CREATE TOOLS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.tools
		(
			thetool			VARCHAR(100),
			thepath			VARCHAR(200)
		)
		</cfquery>
		<!--- CREATE CT_LABELS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.ct_labels
		(
			ct_label_id 	varchar(100),
		 	ct_id_r 		varchar(100),
		 	ct_type 		varchar(100),
		 	rec_uuid		VARCHAR(100)
		)
		</cfquery>
		<!--- CREATE RFS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.rfs
		(
			rfs_id 			varchar(100),
			rfs_active 		BIGINT,
			rfs_server_name varchar(200),
			rfs_imagemagick varchar(200),
			rfs_ffmpeg 		varchar(200),
			rfs_dcraw 		varchar(200),
			rfs_exiftool 	varchar(200),
			rfs_mp4box	 	varchar(200),
			rfs_location 	varchar(200),
			rfs_date_add 	timestamp,
			rfs_date_change timestamp
		)
		</cfquery>

		<!--- ct_plugins_hosts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.ct_plugins_hosts
		(
			ct_pl_id_r		varchar(100),
		  	ct_host_id_r	BIGINT,
		  	rec_uuid		varchar(100)
		)
		</cfquery>

		<!--- plugins --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.plugins
		(
			p_id 			varchar(100),
			p_path 			varchar(500),
			p_active 		varchar(5) DEFAULT 'false',
			p_name 			varchar(500),
			p_url 			varchar(500),
			p_version 		varchar(20),
			p_author 		varchar(500),
			p_author_url 	varchar(500),
			p_description 	varchar(2000),
			p_license 		varchar(500),
			p_cfc_list 		varchar(500)
		)
		</cfquery>
		
		<!--- plugins_actions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.plugins_actions
		(
			action 			varchar(200),
  			comp 			varchar(200),
  			func 			varchar(200),
  			args 			clob,
  			p_id 			varchar(100),
  			p_remove		varchar(10),
  			host_id 		int
		)
		</cfquery>
		
		<!--- options --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.options
		(
			opt_id			varchar(100),
			opt_value		clob,
			rec_uuid		varchar(100)
		)
		</cfquery>

		<!--- news --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.news
		(
			news_id			varchar(100),
			news_title		varchar(500),
			news_active		varchar(6),
			news_text		clob,
			news_date		varchar(20)
		)
		</cfquery>

		<!---  --->
		<!--- END: CREATE TABLES --->
		<!---  --->
		
	</cffunction>
	
	<!--- Create Tables --->
	<cffunction name="create_tables" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		
		<!--- ASSETS_TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#assets_temp 
		(
			TEMPID 			VARCHAR(200), 
			FILENAME 		VARCHAR(500), 
			EXTENSION 		VARCHAR(20), 
			DATE_ADD 		TIMESTAMP, 
			FOLDER_ID		VARCHAR(100), 
			WHO				VARCHAR(100), 
			FILENAMENOEXT	VARCHAR(500), 
			PATH 			VARCHAR(2000), 
			MIMETYPE		VARCHAR(200), 
			THESIZE			VARCHAR(100),
			GROUPID			VARCHAR(100),
			SCHED_ACTION	BIGINT,
			SCHED_ID		VARCHAR(100),
			FILE_ID			VARCHAR(100),
			LINK_KIND		VARCHAR(20),
			HOST_ID			BIGINT,
			md5hash			VARCHAR(100)
		)
		</cfquery>
		
		<!--- XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#xmp 
		(
			id_r					VARCHAR(100),
			asset_type				varchar(10),
			subjectcode				varchar(300),
			creator					varchar(300),
			title					varchar(500),
			authorsposition			varchar(300),
			captionwriter			varchar(300),
			ciadrextadr				varchar(300),
			category				varchar(300),
			supplementalcategories	VARCHAR(4000),
			urgency					varchar(300),
			description				VARCHAR(4000),
			ciadrcity				varchar(300),
			ciadrctry				varchar(300),
			location				varchar(300),
			ciadrpcode				varchar(300),
			ciemailwork				varchar(300),
			ciurlwork				varchar(300),
			citelwork				varchar(300),
			intellectualgenre		varchar(300),
			instructions			VARCHAR(2000),
			source					varchar(300),
			usageterms				VARCHAR(4000),
			copyrightstatus			VARCHAR(4000),
			transmissionreference	varchar(300),
			webstatement			varchar(500),
			headline				varchar(500),
			datecreated				varchar(200),
			city					varchar(300),
			ciadrregion				varchar(300),
			country					varchar(300),
			countrycode				varchar(300),
			scene					varchar(300),
			state					varchar(300),
			credit					varchar(300),
			rights					VARCHAR(4000),
			colorspace				varchar(50),
			xres					varchar(30),
			yres					varchar(30),
			resunit					varchar(20),
			HOST_ID					BIGINT
		)  
		</cfquery>
		
		<!--- CART --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#cart
		(
		  CART_ID           	VARCHAR(200),
		  USER_ID           	VARCHAR(100),
		  CART_QUANTITY     	BIGINT,
		  CART_PRODUCT_ID   	VARCHAR(100),
		  CART_CREATE_DATE  	DATE,
		  CART_CREATE_TIME  	TIMESTAMP,
		  CART_CHANGE_DATE  	DATE,
		  CART_CHANGE_TIME  	TIMESTAMP,
		  CART_FILE_TYPE    	VARCHAR(5),
		  cart_order_email 		varchar(150),
		  cart_order_message 	varchar(2000),
		  cart_order_done 		varchar(1), 
		  cart_order_date 		timestamp,
		  cart_order_user_r 	VARCHAR(100),
		  HOST_ID				BIGINT
		)
		</cfquery>
				
		<!--- FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#folders
		(
		  FOLDER_ID             VARCHAR(100),
		  FOLDER_NAME           VARCHAR(200),
		  FOLDER_LEVEL          BIGINT,
		  FOLDER_ID_R           VARCHAR(100) DEFAULT NULL,
		  FOLDER_MAIN_ID_R      VARCHAR(100),
		  FOLDER_OWNER          VARCHAR(100),
		  FOLDER_CREATE_DATE    DATE,
		  FOLDER_CREATE_TIME    TIMESTAMP,
		  FOLDER_CHANGE_DATE    DATE,
		  FOLDER_CHANGE_TIME    TIMESTAMP,
		  FOLDER_IS_IMG_FOLDER  VARCHAR(2),
		  FOLDER_IMG_PUB_ID     BIGINT,
		  FOLDER_OF_USER        VARCHAR(2) DEFAULT NULL,
		  FOLDER_IS_COLLECTION  VARCHAR(2) DEFAULT NULL,
		  FOLDER_IS_VID_FOLDER  VARCHAR(2),
		  FOLDER_VID_PUB_ID		BIGINT,
		  FOLDER_AVAILABLE_DSC  BIGINT DEFAULT 1,
		  FOLDER_SHARED			VARCHAR(2) DEFAULT 'F',
		  FOLDER_NAME_SHARED	VARCHAR(200),
		  LINK_PATH				VARCHAR(200),
		  share_dl_org			varchar(1) DEFAULT 'f',
     	  share_comments		varchar(1) DEFAULT 'f',
		  share_upload			varchar(1) DEFAULT 'f',
		  share_order			varchar(1) DEFAULT 'f',
		  share_order_user		VARCHAR(100),
		  HOST_ID				BIGINT
		)
		</cfquery>
		
		<!--- FOLDERS DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#folders_desc
		(
		  FOLDER_ID_R		VARCHAR(100),
		  LANG_ID_R			BIGINT,
		  FOLDER_DESC		VARCHAR(1000),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- FOLDERS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#folders_groups
		(
		  FOLDER_ID_R		VARCHAR(100),
		  GRP_ID_R			VARCHAR(100) DEFAULT NULL,
		  GRP_PERMISSION	VARCHAR(2),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- FILES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#files
		(
		  FILE_ID              VARCHAR(100),
		  FOLDER_ID_R          VARCHAR(100) DEFAULT NULL,
		  FILE_CREATE_DATE     DATE,
		  FILE_CREATE_TIME     TIMESTAMP,
		  FILE_CHANGE_DATE     DATE,
		  FILE_CHANGE_TIME     TIMESTAMP,
		  FILE_OWNER           VARCHAR(100),
		  FILE_TYPE            VARCHAR(5),
		  FILE_NAME            VARCHAR(200),
		  FILE_EXTENSION       VARCHAR(20),
		  FILE_NAME_NOEXT      VARCHAR(200),
		  FILE_CONTENTTYPE     VARCHAR(100),
		  FILE_CONTENTSUBTYPE  VARCHAR(100),
		  FILE_REMARKS         VARCHAR(4000),
		  FILE_ONLINE          VARCHAR(2),
		  FILE_NAME_ORG        VARCHAR(200),
		  FILE_SIZE			   VARCHAR(100),
		  LUCENE_KEY		   VARCHAR(2000),
		  SHARED			   VARCHAR(2) DEFAULT 'F',
		  LINK_KIND			   VARCHAR(20),
		  LINK_PATH_URL		   VARCHAR(2000),
		  FILE_META			   CLOB,
		  HOST_ID			   BIGINT,
		  PATH_TO_ASSET		   VARCHAR(500),
		  CLOUD_URL			   VARCHAR(500),
		  CLOUD_URL_ORG		   VARCHAR(500),
		  HASHTAG			   VARCHAR(100),
		  IS_AVAILABLE		   VARCHAR(1) DEFAULT 0,
		  CLOUD_URL_EXP		   BIGINT
		)
		</cfquery>
		
		<!--- FILES DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#files_desc
		(
		  FILE_ID_R      VARCHAR(100),
		  LANG_ID_R      BIGINT,
		  FILE_DESC      VARCHAR(1000),
		  FILE_KEYWORDS  VARCHAR(2000),
		  ID_INC		 VARCHAR(100),
		  HOST_ID		 BIGINT
		)
		</cfquery>
		
		<!--- IMAGES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#images
		(
		  IMG_ID              VARCHAR(100),
		  METABLOB        	  VARCHAR(1),
		  METAEXIF            VARCHAR(1),
		  METAIPTC            VARCHAR(1),
		  METAXMP             VARCHAR(1),
		  IMAGE               VARCHAR(1),
		  THUMB               VARCHAR(1),
		  COMP                VARCHAR(1),
		  COMP_UW             VARCHAR(1),
		  IMG_GROUP           VARCHAR(100) DEFAULT NULL,
		  IMG_PUBLISHER       VARCHAR(200),
		  IMG_FILENAME        VARCHAR(500),
		  FOLDER_ID_R         VARCHAR(100) DEFAULT NULL,
		  IMG_CUSTOM_ID       VARCHAR(100),
		  IMG_ONLINE          VARCHAR(2),
		  IMG_OWNER           VARCHAR(100),
		  IMG_CREATE_DATE     DATE,
		  IMG_CREATE_TIME     TIMESTAMP,
		  IMG_CHANGE_DATE     DATE,
		  IMG_CHANGE_TIME     TIMESTAMP,
		  IMG_RANKING         BIGINT,
		  IMG_SINGLE_SALE     VARCHAR(2),
		  IMG_IS_NEW          VARCHAR(2),
		  IMG_SELECTION       VARCHAR(2),
		  IMG_IN_PROGRESS     VARCHAR(2),
		  IMG_ALIGNMENT       VARCHAR(200),
		  IMG_LICENSE         VARCHAR(200),
		  IMG_DOMINANT_COLOR  VARCHAR(200),
		  IMG_COLOR_MODE      VARCHAR(200),
		  IMG_IMAGE_TYPE      VARCHAR(200),
		  IMG_CATEGORY_ONE    VARCHAR(2000),
		  IMG_REMARKS         VARCHAR(1),
		  IMG_EXTENSION       VARCHAR(20),
		  THUMB_EXTENSION	  VARCHAR(20),
		  THUMB_WIDTH         BIGINT,
		  THUMB_HEIGHT        BIGINT,
		  IMG_FILENAME_ORG    VARCHAR(500),
		  IMG_WIDTH           BIGINT,
  		  IMG_HEIGHT          BIGINT,
	 	  IMG_SIZE            VARCHAR(100),
  		  THUMB_SIZE          VARCHAR(100),
		  LUCENE_KEY		  VARCHAR(2000),
		  SHARED			  VARCHAR(2) DEFAULT 'F',
		  LINK_KIND			  VARCHAR(20),
		  LINK_PATH_URL		  VARCHAR(2000),
		  IMG_META			  CLOB,
		  HOST_ID			  BIGINT,
		  PATH_TO_ASSET		  VARCHAR(500),
		  CLOUD_URL			   VARCHAR(500),
		  CLOUD_URL_ORG		   VARCHAR(500),
		  HASHTAG			   VARCHAR(100),
		  IS_AVAILABLE		 VARCHAR(1) DEFAULT 0,
		  CLOUD_URL_EXP		   BIGINT
		)
		</cfquery>
		
		<!--- IMAGES TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#images_text
		(
		  IMG_ID_R         VARCHAR(100) NOT NULL,
		  LANG_ID_R        BIGINT NOT NULL,
		  IMG_KEYWORDS     VARCHAR(4000),
		  IMG_DESCRIPTION  VARCHAR(4000),
		  ID_INC		   VARCHAR(100),
		  HOST_ID		   BIGINT
		)
		</cfquery>
		
		<!--- LOG ASSETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#log_assets
		(
		  LOG_ID			VARCHAR(100) NOT NULL, 
		  LOG_USER			VARCHAR(100), 
		  LOG_ACTION		VARCHAR(100), 
		  LOG_DATE			DATE, 
		  LOG_TIME			TIMESTAMP, 
		  LOG_DESC			VARCHAR(4000), 
		  LOG_FILE_TYPE		VARCHAR(5), 
		  LOG_BROWSER		VARCHAR(500), 
		  LOG_IP			VARCHAR(200), 
		  LOG_TIMESTAMP		TIMESTAMP,
		  HOST_ID			BIGINT,
		  asset_id_r		VARCHAR(100)
		)
		</cfquery>
		
		<!--- LOG FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#log_folders
		(
		  LOG_ID			VARCHAR(100) NOT NULL, 
		  LOG_USER			VARCHAR(100), 
		  LOG_ACTION		VARCHAR(100), 
		  LOG_DATE			DATE, 
		  LOG_TIME			TIMESTAMP, 
		  LOG_DESC			VARCHAR(4000), 
		  LOG_BROWSER		VARCHAR(500), 
		  LOG_IP			VARCHAR(200), 
		  LOG_TIMESTAMP		TIMESTAMP,
		  HOST_ID			BIGINT
		)
		</cfquery>
		
		<!--- LOG USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#log_users
		(
		  LOG_ID			VARCHAR(100) NOT NULL, 
		  LOG_USER			VARCHAR(100), 
		  LOG_ACTION		VARCHAR(100), 
		  LOG_DATE			DATE, 
		  LOG_TIME			TIMESTAMP, 
		  LOG_DESC			VARCHAR(4000), 
		  LOG_BROWSER		VARCHAR(500), 
		  LOG_IP			VARCHAR(200), 
		  LOG_TIMESTAMP		TIMESTAMP,
		  LOG_SECTION		VARCHAR(10),
		  HOST_ID			BIGINT
		)
		</cfquery>
		
		<!--- LOG SEARCH --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#log_search
		(
		  LOG_ID			VARCHAR(100) NOT NULL,
		  LOG_USER			VARCHAR(100),
		  LOG_DATE			DATE,
		  LOG_TIME			TIMESTAMP,
		  LOG_SEARCH_FOR	VARCHAR(2000),
		  LOG_FOUNDITEMS	BIGINT,
		  LOG_SEARCH_FROM	VARCHAR(50),
		  LOG_TIMESTAMP		TIMESTAMP,
		  LOG_BROWSER		VARCHAR(500), 
		  LOG_IP			VARCHAR(200),
		  HOST_ID			BIGINT
		)
		</cfquery>
				
		<!--- SETTINGS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#settings
		(
		  SET_ID			VARCHAR(100) NOT NULL,
		  SET_PREF			VARCHAR(2000),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- SETTINGS 2 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#settings_2
		(
		  SET2_ID                       BIGINT NOT NULL,
		  SET2_DATE_FORMAT              VARCHAR(20),
		  SET2_DATE_FORMAT_DEL          VARCHAR(3),
		  SET2_META_KEYWORDS            VARCHAR(260),
		  SET2_META_DESC                VARCHAR(500),
		  SET2_META_AUTHOR              VARCHAR(200),
		  SET2_META_PUBLISHER           VARCHAR(200),
		  SET2_META_COPYRIGHT           VARCHAR(200),
		  SET2_META_ROBOTS              VARCHAR(200),
		  SET2_META_REVISIT             VARCHAR(200),
		  SET2_META_CUSTOM              VARCHAR(1000),
		  SET2_URL_SP_ORIGINAL          VARCHAR(400),
		  SET2_URL_SP_THUMB             VARCHAR(400),
		  SET2_URL_SP_COMP              VARCHAR(400),
		  SET2_URL_SP_COMP_UW           VARCHAR(400),
		  SET2_INTRANET_LOGO            VARCHAR(1),
		  SET2_URL_APP_SERVER           VARCHAR(400),
		  SET2_ORA_PATH_INTERNAL        VARCHAR(400),
		  SET2_CREATE_IMGFOLDERS_WHERE  BIGINT,
		  SET2_IMG_FORMAT               VARCHAR(4),
		  SET2_IMG_THUMB_WIDTH          BIGINT,
		  SET2_IMG_THUMB_HEIGTH         BIGINT,
		  SET2_IMG_COMP_WIDTH           BIGINT,
		  SET2_IMG_COMP_HEIGTH          BIGINT,
		  SET2_IMG_DOWNLOAD_ORG         VARCHAR(2),
		  SET2_DOC_DOWNLOAD             VARCHAR(2),
		  SET2_INTRANET_REG_EMAILS      VARCHAR(1000),
		  SET2_INTRANET_REG_EMAILS_SUB  VARCHAR(500),
		  SET2_INTRANET_GEN_DOWNLOAD    VARCHAR(2),
		  SET2_CAT_WEB                  VARCHAR(2),
		  SET2_CAT_INTRA                VARCHAR(2),
		  SET2_URL_WEBSITE              VARCHAR(400),
		  SET2_PAYMENT_PRE              VARCHAR(2),
		  SET2_PAYMENT_BILL             VARCHAR(2),
		  SET2_PAYMENT_POD              VARCHAR(2),
		  SET2_PAYMENT_CC               VARCHAR(2),
		  SET2_PAYMENT_CC_CARDS         VARCHAR(500),
		  SET2_PAYMENT_PAYPAL           VARCHAR(2),
		  SET2_PATH_IMAGEMAGICK         VARCHAR(500),
		  SET2_EMAIL_SERVER             VARCHAR(200),
		  SET2_EMAIL_FROM               VARCHAR(200),
		  SET2_EMAIL_SMTP_USER          VARCHAR(200),
		  SET2_EMAIL_SMTP_PASSWORD      VARCHAR(200),
		  SET2_EMAIL_SERVER_PORT        BIGINT,
		  SET2_ORA_PATH_INCOMING		VARCHAR(500),
		  SET2_ORA_PATH_INCOMING_BATCH	VARCHAR(500),
		  SET2_ORA_PATH_OUTGOING		VARCHAR(500),
		  SET2_VID_PREVIEW_HEIGTH		BIGINT,
		  SET2_VID_PREVIEW_WIDTH		BIGINT,
		  SET2_PATH_FFMPEG				VARCHAR(500),
		  SET2_VID_PREVIEW_TIME			VARCHAR(10),
		  SET2_VID_PREVIEW_START		VARCHAR(10),
		  SET2_URL_SP_VIDEO				VARCHAR(500),
		  SET2_URL_SP_VIDEO_PREVIEW		VARCHAR(500),
		  SET2_VID_PREVIEW_AUTHOR		VARCHAR(200),
		  SET2_VID_PREVIEW_COPYRIGHT	VARCHAR(200),
		  SET2_CAT_VID_WEB				VARCHAR(2),
		  SET2_CAT_VID_INTRA			VARCHAR(2),
		  SET2_CAT_AUD_WEB				VARCHAR(2),
		  SET2_CAT_AUD_INTRA			VARCHAR(2),
		  SET2_CREATE_VIDFOLDERS_WHERE	BIGINT,
		  SET2_PATH_TO_ASSETS			VARCHAR(500),
		  SET2_PATH_TO_EXIFTOOL         VARCHAR(500),
		  SET2_NIRVANIX_NAME			VARCHAR(500),
		  SET2_NIRVANIX_PASS			VARCHAR(500),
		  HOST_ID						BIGINT,
		  SET2_AWS_BUCKET				VARCHAR(100),
		  SET2_LABELS_USERS				VARCHAR(2) DEFAULT 't',
		  SET2_MD5CHECK					VARCHAR(5) DEFAULT 'false',
		  SET2_AKA_URL					VARCHAR(500),
		  SET2_AKA_IMG					VARCHAR(200),
		  SET2_AKA_VID					VARCHAR(200),
		  SET2_AKA_AUD					VARCHAR(200),
		  SET2_AKA_DOC					VARCHAR(200),
		  rec_uuid						VARCHAR(100)
		)
		</cfquery>
				
		<!--- TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#temp
		(
		  TMP_TOKEN     VARCHAR(100),
		  TMP_FILENAME  VARCHAR(300),
		  HOST_ID		BIGINT
		)
		</cfquery>
		
		<!--- COLLECTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#collections
		(
		  COL_ID        	VARCHAR(100) NOT NULL,
		  FOLDER_ID_R   	VARCHAR(100) DEFAULT NULL,
		  COL_OWNER     	VARCHAR(100),
		  CREATE_DATE   	DATE,
		  CREATE_TIME   	TIMESTAMP,
		  CHANGE_DATE   	DATE,
		  CHANGE_TIME   	TIMESTAMP,
		  COL_TEMPLATE  	VARCHAR(100),
		  COL_SHARED		VARCHAR(2) DEFAULT 'F',
		  COL_NAME_SHARED	VARCHAR(200),
		  share_dl_org		varchar(1) DEFAULT 'f',
     	  share_comments	varchar(1) DEFAULT 'f',
		  share_upload		varchar(1) DEFAULT 'f',
		  share_order		varchar(1) DEFAULT 'f',
		  share_order_user	VARCHAR(100),
		  col_released		VARCHAR(5) DEFAULT 'false',
		  col_copied_from	VARCHAR(100),
		  HOST_ID			BIGINT
		)
		</cfquery>
		
		<!--- COLLECTIONS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#collections_text
		(
		  COL_ID_R      VARCHAR(100),
		  LANG_ID_R     BIGINT,
		  COL_DESC      VARCHAR(1000),
		  COL_KEYWORDS  VARCHAR(2000),
		  COL_NAME      VARCHAR(300),
		  HOST_ID		BIGINT,
		  rec_uuid		VARCHAR(100)
		)
		</cfquery>
		
		<!--- COLLECTIONS FILES CROSS TABLE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#collections_ct_files
		(
		  COL_ID_R       	VARCHAR(100),
		  FILE_ID_R      	VARCHAR(100),
		  COL_FILE_TYPE  	VARCHAR(5),
		  COL_ITEM_ORDER  	BIGINT,
		  COL_FILE_FORMAT  	VARCHAR(100),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- COLLECTIONS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#collections_groups
		(
		  COL_ID_R       	VARCHAR(100),
		  GRP_ID_R			VARCHAR(100) DEFAULT NULL,
		  GRP_PERMISSION	VARCHAR(2),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100)	
		)
		</cfquery>
		
		<!--- USER FAVORITES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#users_favorites
		(
		  USER_ID_R  VARCHAR(100),
		  FAV_TYPE   VARCHAR(8),
		  FAV_ID     VARCHAR(100),
		  FAV_KIND   VARCHAR(8),
		  FAV_ORDER  BIGINT,
		  HOST_ID	 BIGINT,
		  rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- VIDEOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#videos
		(
		VID_ID					VARCHAR(100),
		VID_FILENAME			VARCHAR(200),
		FOLDER_ID_R				VARCHAR(100) DEFAULT NULL,
		VID_CUSTOM_ID			VARCHAR(100),
		VID_ONLINE				VARCHAR(2),
		VID_OWNER				VARCHAR(100),
		VID_CREATE_DATE			DATE,
		VID_CREATE_TIME			TIMESTAMP,
		VID_CHANGE_DATE			DATE,
		VID_CHANGE_TIME			TIMESTAMP,
		VID_RANKING				BIGINT,
		VID_SINGLE_SALE			VARCHAR(2),
		VID_IS_NEW				VARCHAR(2),
		VID_SELECTION			VARCHAR(2),
		VID_IN_PROGRESS			VARCHAR(2),
		VID_LICENSE				VARCHAR(200),
		VID_CATEGORY_ONE		VARCHAR(2000),
		VID_REMARKS				VARCHAR(1),
		VID_WIDTH				BIGINT,
		VID_HEIGHT				BIGINT,
		VID_FRAMERESOLUTION		BIGINT,
		VID_FRAMERATE			BIGINT,
		VID_VIDEODURATION		BIGINT,
		VID_COMPRESSIONTYPE		VARCHAR(4000),
		VID_BITRATE				BIGINT,
		VID_EXTENSION			VARCHAR(20),
		VID_MIMETYPE			VARCHAR(500),
		VID_PREVIEW_WIDTH		BIGINT,
		VID_PREVIEW_HEIGTH		BIGINT,
		VID_GROUP				VARCHAR(100) DEFAULT NULL,
		VID_PUBLISHER			VARCHAR(200),
		VID_NAME_ORG			VARCHAR(200),
		VID_NAME_IMAGE			VARCHAR(200),
		VID_NAME_PRE			VARCHAR(200),
		VID_NAME_PRE_IMG		VARCHAR(200),
	 	VID_SIZE                VARCHAR(100),
	 	VID_PREV_SIZE           VARCHAR(100),
	 	LUCENE_KEY		   		VARCHAR(2000),
	 	SHARED			 		VARCHAR(2) DEFAULT 'F',
	 	LINK_KIND			    VARCHAR(20),
		LINK_PATH_URL		    VARCHAR(2000),
		VID_META				CLOB,
		HOST_ID					BIGINT,
		PATH_TO_ASSET		  	VARCHAR(500),
		CLOUD_URL		   	    VARCHAR(500),
		CLOUD_URL_ORG		    VARCHAR(500),
		HASHTAG			   		VARCHAR(100),
		IS_AVAILABLE		  VARCHAR(1) DEFAULT 0,
		CLOUD_URL_EXP		   BIGINT
		)
		</cfquery>
		
		<!--- VIDEOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#videos_text
		(
		  VID_ID_R         VARCHAR(100) NOT NULL,
		  LANG_ID_R        BIGINT NOT NULL,
		  VID_KEYWORDS     VARCHAR(4000),
		  VID_DESCRIPTION  VARCHAR(4000),
		  VID_TITLE		   VARCHAR(400),
		  ID_INC		   VARCHAR(100),
		  HOST_ID		   BIGINT
		)
		</cfquery>
		
		<!--- SCHEDULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#schedules
		(
			SCHED_ID 			 VARCHAR(100) NOT NULL,
			SET2_ID_R 			 BIGINT,
			SCHED_USER 			 VARCHAR(100),
			SCHED_STATUS 		 VARCHAR(1) DEFAULT 1,
			SCHED_METHOD 		 VARCHAR(10),
			SCHED_NAME 			 VARCHAR(255),
			SCHED_FOLDER_ID_R    VARCHAR(100),
			SCHED_ZIP_EXTRACT 	 BIGINT,
			SCHED_SERVER_FOLDER  VARCHAR(4000),
			SCHED_SERVER_RECURSE BIGINT DEFAULT 1,
			SCHED_SERVER_FILES   BIGINT DEFAULT 0,
			SCHED_MAIL_POP 		 VARCHAR(255),
			SCHED_MAIL_USER 	 VARCHAR(255),
			SCHED_MAIL_PASS 	 VARCHAR(255),
			SCHED_MAIL_SUBJECT 	 VARCHAR(255),
			SCHED_FTP_SERVER 	 VARCHAR(255),
			SCHED_FTP_USER 		 VARCHAR(255),
			SCHED_FTP_PASS 		 VARCHAR(255),
			SCHED_FTP_PASSIVE    BIGINT DEFAULT 0,
			SCHED_FTP_FOLDER 	 VARCHAR(255),
			SCHED_INTERVAL       VARCHAR(255),
			SCHED_START_DATE     DATE,
			SCHED_START_TIME     TIMESTAMP,
			SCHED_END_DATE       DATE,
			SCHED_END_TIME       TIMESTAMP,
			HOST_ID				 BIGINT,
			sched_upl_template	 VARCHAR(100)
		)
		</cfquery>
		
		<!--- SCHEDULES_LOG --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#schedules_log
		(
			SCHED_LOG_ID        VARCHAR(100) NOT NULL,
			SCHED_ID_R          VARCHAR(100),
			SCHED_LOG_USER      VARCHAR(100),
			SCHED_LOG_ACTION    VARCHAR(10),
			SCHED_LOG_DATE      DATE,
			SCHED_LOG_TIME      TIMESTAMP,
			SCHED_LOG_DESC      VARCHAR(4000),
			HOST_ID				BIGINT
		)
		</cfquery>
		
		<!--- CUSTOM FIELDS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#custom_fields
		(
			cf_id 			VARCHAR(100), 
			cf_type	 		VARCHAR(20), 
			cf_order 		bigint, 
			cf_enabled 		VARCHAR(2), 
			cf_show			VARCHAR(10),
			cf_group 		VARCHAR(100),
			cf_select_list	VARCHAR(4000),
			cf_in_form		VARCHAR(10) DEFAULT 'true',
			cf_edit			VARCHAR(2000) DEFAULT 'true',
			host_id			BIGINT
		)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#custom_fields_text
		(
			cf_id_r			VARCHAR(100), 
			lang_id_r 		bigint, 
			cf_text			VARCHAR(500),
			HOST_ID			BIGINT,
			rec_uuid		VARCHAR(100)
			
		)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#custom_fields_values
		(
			cf_id_r			VARCHAR(100), 
			asset_id_r 		VARCHAR(100), 
			cf_value		VARCHAR(4000),
			HOST_ID			BIGINT,
			rec_uuid		VARCHAR(100)
		)
		</cfquery>
		
		<!--- COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#comments
		(
			COM_ID			VARCHAR(100),
			ASSET_ID_R		VARCHAR(100),
			ASSET_TYPE		VARCHAR(10),
			USER_ID_R		VARCHAR(100),
			COM_TEXT		VARCHAR(4000),
			COM_DATE		TIMESTAMP,
			HOST_ID			BIGINT
		)
		</cfquery>
		
		<!--- Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#versions
		(
			asset_id_r			VARCHAR(100),
			ver_version			BIGINT DEFAULT NULL,
			ver_type			VARCHAR(5),
			ver_date_add		TIMESTAMP,
			ver_who				VARCHAR(100),
			ver_filename_org 	VARCHAR(200),
			ver_extension	 	VARCHAR(20),
			thumb_width			BIGINT,
			thumb_height		BIGINT,
			img_width			BIGINT,
			img_height			BIGINT,
			img_size			VARCHAR(100),
			thumb_size			VARCHAR(100),
			vid_size			VARCHAR(100),
			vid_width			BIGINT,
			vid_height			BIGINT,
			vid_name_image		VARCHAR(200),
			HOST_ID				BIGINT,
			cloud_url_org		VARCHAR(500),
			ver_thumbnail		VARCHAR(200),
			hashtag				VARCHAR(100),
			rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- TRANSLATIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#languages
		(
			lang_id			BIGINT NOT NULL,
			lang_name		VARCHAR(100),
			lang_active		VARCHAR(2) default 'f',
			host_id			BIGINT,
			rec_uuid		VARCHAR(100)
		)
		</cfquery>
		
		<!--- AUDIOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#audios
		(
			aud_ID              VARCHAR(100),
			FOLDER_ID_R         VARCHAR(100) DEFAULT NULL,
			aud_CREATE_DATE     DATE,
			aud_CREATE_TIME     TIMESTAMP,
			aud_CHANGE_DATE     DATE,
			aud_CHANGE_TIME     TIMESTAMP,
			aud_OWNER           VARCHAR(100),
			aud_TYPE            VARCHAR(5),
			aud_NAME            VARCHAR(200),
			aud_EXTENSION       VARCHAR(20),
			aud_NAME_NOEXT      VARCHAR(200),
			aud_CONTENTTYPE     VARCHAR(100),
			aud_CONTENTSUBTYPE  VARCHAR(100),
			aud_ONLINE          VARCHAR(2),
			aud_NAME_ORG        VARCHAR(200),
			aud_GROUP           VARCHAR(100) DEFAULT NULL,
			aud_size			VARCHAR(100),
			LUCENE_KEY		   	VARCHAR(2000),
			SHARED			   	VARCHAR(2) DEFAULT 'F',
			aud_meta			CLOB,
			LINK_KIND			VARCHAR(20),
		 	LINK_PATH_URL		VARCHAR(2000),
		 	HOST_ID				BIGINT,
		 	PATH_TO_ASSET		VARCHAR(500),
		 	CLOUD_URL			VARCHAR(500),
		 	CLOUD_URL_2		    VARCHAR(500),
		    CLOUD_URL_ORG		VARCHAR(500),
		    HASHTAG			    VARCHAR(100),
		    IS_AVAILABLE		  VARCHAR(1) DEFAULT 0,
		    CLOUD_URL_EXP		   BIGINT
		)
		</cfquery>
		
		<!--- AUDIOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#audios_text
		(
			aud_ID_R			VARCHAR(100),
			LANG_ID_R			BIGINT,
			aud_DESCRIPTION     VARCHAR(4000),
			aud_KEYWORDS		VARCHAR(4000),
			ID_INC		   		VARCHAR(100),
			HOST_ID				BIGINT
		)
		</cfquery>
		
		<!--- SHARE OPTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#share_options
		(
			asset_id_r		VARCHAR(100),
			host_id			BIGINT,
			group_asset_id	VARCHAR(100),
			folder_id_r		VARCHAR(100),
			asset_type		varchar(6),
			asset_format	varchar(100),
			asset_dl		varchar(1) DEFAULT '0',
			asset_order		varchar(1) DEFAULT '0',
			asset_selected		varchar(1) DEFAULT '0',
			rec_uuid			VARCHAR(100)
		)
		</cfquery>
		
		<!--- ERRORS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#errors
		(
			id				BIGINT,
			err_text		CLOB,
			err_date		timestamp,
			host_id			BIGINT
		)
		</cfquery>
		
		<!--- Upload Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#upload_templates 
		(
		  	upl_temp_id			varchar(100) NOT NULL,
		  	upl_date_create 	timestamp NULL DEFAULT NULL,
		  	upl_date_update		timestamp NULL DEFAULT NULL,
		  	upl_who				varchar(100) DEFAULT NULL,
		  	upl_active			VARCHAR(1) DEFAULT '0',
		  	host_id				BIGINT DEFAULT NULL,
		  	upl_name			varchar(200) DEFAULT NULL,
		  	upl_description		varchar(2000) DEFAULT NULL
		)
		</cfquery>
		
		<!--- Upload Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#upload_templates_val
		(
		  	upl_temp_id_r		varchar(100) NOT NULL,
		  	upl_temp_field		varchar(300) DEFAULT NULL,
		  	upl_temp_value		varchar(100) DEFAULT NULL,
		  	upl_temp_type		varchar(5) DEFAULT NULL,
		  	upl_temp_format		varchar(10) DEFAULT NULL,
		  	host_id				BIGINT DEFAULT NULL,
		  	rec_uuid			VARCHAR(100)	
		)
		</cfquery>
		
		<!--- CREATE WIDGETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#widgets 
		(
		  	widget_id				varchar(100),
			col_id_r				varchar(100),
			folder_id_r				varchar(100),
			widget_name				varchar(200),
			widget_description		varchar(1000),
			widget_permission 		varchar(2),
			widget_password 		varchar(100),
			widget_style 			varchar(2),
			widget_dl_org 			varchar(2),
			widget_uploading 		varchar(2),
			host_id 				BIGINT
		)
		</cfquery>
		
		<!--- Additional Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#additional_versions (
		  av_id					varchar(100) NOT NULL,
		  asset_id_r			varchar(100) DEFAULT NULL,
		  folder_id_r			varchar(100) DEFAULT NULL,
		  av_type				varchar(45) DEFAULT NULL,
		  av_link_title			varchar(200) DEFAULT NULL,
		  av_link_url 			varchar(500) DEFAULT NULL,
		  host_id 				BIGINT DEFAULT NULL,
		  av_link 				varchar(2) DEFAULT '1',
		  thesize 				varchar(100) DEFAULT '0',
  		  thewidth 				varchar(50) DEFAULT '0',
  		  theheight				varchar(50) DEFAULT '0'
		)
		</cfquery>
		
		<!--- Files XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#files_xmp (
		  asset_id_r 			varchar(100),
		  author 				varchar(200),
		  rights 				varchar(1000),
		  authorsposition 		varchar(200),
		  captionwriter 		varchar(300),
		  webstatement 			varchar(500),
		  rightsmarked 			varchar(10),
		  host_id 				BIGINT
		)
		</cfquery>
		
		<!--- Labels --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#labels (
		label_id 		varchar(100),
  		label_text 		varchar(200),
  		label_date		timestamp,
  		user_id			varchar(100),
  		host_id			bigint,
  		label_id_r		varchar(100),
  		label_path		varchar(500),
		)
		</cfquery>
		
		<!--- Import Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#import_templates (
		imp_temp_id 		varchar(100),
  		imp_date_create	 	timestamp,
  		imp_date_update		timestamp,
  		imp_who				varchar(100),
  		imp_active 			varchar(1) DEFAULT '0',
  		host_id				bigint,
  		imp_name			varchar(200),
  		imp_description 	varchar(2000)
		)
		</cfquery>
		
		<!--- Import Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#import_templates_val (
  		imp_temp_id_r		varchar(100),
  		rec_uuid			varchar(100),
  		imp_field			varchar(200),
  		imp_map				varchar(200),
  		host_id				bigint,
  		imp_key				bigint
		)
		</cfquery>

		<!--- Customization --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#custom (
	  	custom_id			varchar(200),
		custom_value		varchar(500),
		host_id				bigint
		)
		</cfquery>
		
		<!--- Social accounts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#users_accounts (
	  	identifier			varchar(200),
		provider			varchar(100),
		user_id_r			varchar(100),
		jr_identifier		varchar(500),
		profile_pic_url		varchar(1000),
		host_id				bigint
		)
		</cfquery>

		<!--- Watermark --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#wm_templates (
	  	wm_temp_id 			varchar(100),
	  	wm_name				varchar(200),
		wm_active			varchar(6) DEFAULT 'false',
		host_id 			bigint
		)
		</cfquery>

		<!--- Watermark values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.tschema#.#arguments.thestruct.host_db_prefix#wm_templates_val (
	  	wm_temp_id_r 		varchar(100),
		wm_use_image 		varchar(6) DEFAULT 'false',
		wm_use_text 		varchar(6) DEFAULT 'false',
		wm_image_opacity 	varchar(4),
		wm_text_opacity 	varchar(4),
		wm_image_position 	varchar(10),
		wm_text_position 	varchar(10),
		wm_text_content 	varchar(400),
		wm_text_font 		varchar(100),
		wm_text_font_size 	varchar(5),
		wm_image_path 		varchar(300),
		host_id 			bigint,
		rec_uuid 			varchar(100)
		)
		</cfquery>	
				
	</cffunction>
		
	<!--- OPENBD CONFIG INTERACTION --->
	
	<cffunction name="bdgetConfig" access="private" output="false" returntype="struct" hint="Returns a struct representation of the OpenBD server configuration (bluedragon.xml)">
		<cfset var admin = "" />
			<cflock scope="Server" type="readonly" timeout="5">
				<cfset admin = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").getConfig().getCFMLData() />
			</cflock>
		<cfreturn admin.server />
	</cffunction>
	
	<cffunction name="bdsetConfig" access="private" output="false" returntype="void" hint="Sets the server configuration and tells OpenBD to refresh its settings">
		<cfargument name="currentConfig" type="struct" required="true" hint="The configuration struct, which is a struct representation of bluedragon.xml" />
			<cflock scope="Server" type="exclusive" timeout="5">
				<cfset admin.server = duplicate(arguments.currentConfig) />
				<cfset admin.server.openbdadminapi.lastupdated = DateFormat(now(), "dd/mmm/yyyy") & " " & TimeFormat(now(), "HH:mm:ss") />
				<cfset admin.server.openbdadminapi.version = "1.0" />
				<cfset xmlConfig = createObject("java", "com.naryx.tagfusion.xmlConfig.xmlCFML").init(admin) />
				<cfset success = createObject("java", "com.naryx.tagfusion.cfm.engine.cfEngine").writeXmlFile(xmlConfig) />
			</cflock>
	</cffunction>
	
	<cffunction name="bddatasourceExists" access="public" output="false" returntype="boolean" hint="Returns a boolean indicating whether or not a datasource with the specified name exists">
		<cfargument name="dsn" type="string" required="true" hint="The datasource name to check" />
		<cfset var dsnExists = true />
		<cfset var localConfig = bdgetConfig() />
		<cfset var i = 0 />
		<cfif not StructKeyExists(localConfig, "cfquery") or not StructKeyExists(localConfig.cfquery, "datasource")>
			<!--- no datasources at all, so this one doesn't exist ---->
			<cfset dsnExists = false />
		<cfelse>
			<cfloop index="i" from="1" to="#ArrayLen(localConfig.cfquery.datasource)#">
				<cfif localConfig.cfquery.datasource[i].name is arguments.dsn>
					<cfset dsnExists = true />
					<cfbreak />
				<cfelse>
					<cfset dsnExists = false />
				</cfif>
			</cfloop>
		</cfif>
		<cfreturn dsnExists />
	</cffunction>
	
	<cffunction name="BDsetDatasource" access="public" output="false" returntype="void" hint="Creates or updates a datasource">
		<cfargument name="name" type="string" required="true" hint="OpenBD Datasource Name" />
		<cfargument name="databasename" type="string" required="false" default="" hint="Database name on the database server" />
		<cfargument name="server" type="string" required="false" default="" hint="Database server host name or IP address" />
		<cfargument name="port"	type="numeric" required="false" default="0" hint="Port that is used to access the database server" />
		<cfargument name="username" type="string" required="false" default="" hint="Database username" />
		<cfargument name="password" type="string" required="false" default="" hint="Database password" />
		<cfargument name="hoststring" type="string" required="false" default="" hint="JDBC URL for 'other' database types. Databasename, server, and port arguments are ignored if a hoststring is provided." />
		<cfargument name="description" type="string" required="false" default="" hint="A description of this data source" />
		<cfargument name="initstring" type="string" required="false" default="" hint="Additional initialization settings" />
		<cfargument name="connectiontimeout" type="numeric" required="false" default="120" hint="Number of seconds OpenBD maintains an unused connection before it is destroyed" />
		<cfargument name="connectionretries" type="numeric" required="false" default="0" hint="Number of connection retry attempts to make" />
		<cfargument name="logintimeout" type="numeric" required="false" default="120" hint="Number of seconds before OpenBD times out the data source connection login attempt" />
		<cfargument name="maxconnections" type="numeric" required="false" default="3" hint="Maximum number of simultaneous database connections" />
		<cfargument name="perrequestconnections" type="boolean" required="false" default="false" hint="Indication of whether or not to pool connections" />
		<cfargument name="sqlselect" type="boolean" required="false" default="true" hint="Allow SQL SELECT statements from this datasource" />
		<cfargument name="sqlinsert" type="boolean" required="false" default="true" hint="Allow SQL INSERT statements from this datasource" />
		<cfargument name="sqlupdate" type="boolean" required="false" default="true" hint="Allow SQL UPDATE statements from this datasource" />
		<cfargument name="sqldelete" type="boolean" required="false" default="true" hint="Allow SQL DELETE statements from this datasource" />
		<cfargument name="sqlstoredprocedures" type="boolean" required="false" default="true" hint="Allow SQL stored procedure calls from this datasource" />
		<cfargument name="drivername" type="string" required="false" default="" hint="JDBC driver class to use" />
		<cfargument name="action" type="string" required="false" default="create" hint="Action to take on the datasource (create or update)" />
		<cfargument name="existingDatasourceName" type="string" required="false" default="" hint="The existing (old) datasource name so we know what to delete if this is an update" />
		<cfargument name="verificationQuery" type="string" required="false" default="" hint="Custom verification query for 'other' driver types" />
		
		<cfset var localConfig = bdgetConfig() />
		<cfset var datasourceSettings = structNew() />
		
		<!--- make sure configuration structure exists, otherwise build it --->
		<cfif (NOT StructKeyExists(localConfig, "cfquery")) OR (NOT StructKeyExists(localConfig.cfquery, "datasource"))>
			<cfset localConfig.cfquery.datasource = ArrayNew(1) />
		</cfif>
		
		<!--- if the datasource already exists and this isn't an update, throw an error --->
		<cfif bddatasourceExists(arguments.name) EQ "false">
			<!--- build up the universal datasource settings --->
			<cfscript>
				// Set the params
				datasourceSettings.name = trim(lcase(arguments.name));
				datasourceSettings.displayname = arguments.name;
				datasourceSettings.databasename = trim(arguments.databasename);
				datasourceSettings.username = trim(arguments.username);
				datasourceSettings.password = trim(arguments.password);
				datasourceSettings.drivername = trim(arguments.drivername);
				datasourceSettings.initstring = trim(arguments.initstring);
				datasourceSettings.sqlselect = ToString(arguments.sqlselect);
				datasourceSettings.sqlinsert = ToString(arguments.sqlinsert);
				datasourceSettings.sqlupdate = ToString(arguments.sqlupdate);
				datasourceSettings.sqldelete = ToString(arguments.sqldelete);
				datasourceSettings.sqlstoredprocedures = ToString(arguments.sqlstoredprocedures);
				datasourceSettings.logintimeout = ToString(arguments.logintimeout);
				datasourceSettings.connectiontimeout = ToString(arguments.connectiontimeout);
				datasourceSettings.connectionretries = ToString(arguments.connectionretries);
				datasourceSettings.maxconnections = ToString(arguments.maxconnections);
				datasourceSettings.perrequestconnections = ToString(arguments.perrequestconnections);
				datasourceSettings.hoststring = ToString(arguments.hoststring);
				// prepend the new datasource to the localconfig array
				arrayPrepend(localConfig.cfquery.datasource, structCopy(datasourceSettings));
				// update the config
				bdsetConfig(localConfig);
			</cfscript>
		</cfif>
	</cffunction>
		
</cfcomponent>