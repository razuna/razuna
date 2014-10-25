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
	
	<cfset this.tableoptions = "ENGINE=InnoDB CHARACTER SET utf8 COLLATE utf8_bin ROW_FORMAT=DYNAMIC;">
	
	<!--- Setup the DB if DB is not here --->
	<cffunction name="setup" access="public" output="false">
		<cfargument name="thestruct" type="Struct">

		<!---  --->
		<!--- START: CREATE TABLES --->
		<!---  --->
		<!--- CREATE SEQUENCES
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.sequences 
		(
			theid varchar(100), 
			thevalue INT NOT NULL, 
			PRIMARY KEY (theid)
		) 
		#this.tableoptions#
		</cfquery>
		 --->
		 <!--- ALLOW  INDEX KEY PREFIXES LARGER THAN 767 BYTES. 
		 	Change needed for mysql versions >= 5.6 
		--->
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn#">
				  SET GLOBAL innodb_large_prefix = 1;
			</cfquery>
		<cfcatch></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn#">
				  SET GLOBAL innodb_file_format = barracuda;
			</cfquery>
		<cfcatch></cfcatch>
		</cftry>
		<cftry>
			<cfquery datasource="#arguments.thestruct.dsn#">
				  SET GLOBAL innodb_file_per_table = true;
			</cfquery>
		<cfcatch></cfcatch>
		</cftry>

		<!--- CREATE CACHE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.cache 
		(
			cache_token varchar(100) DEFAULT NULL,
			cache_type varchar(20) DEFAULT NULL,
			host_id int DEFAULT NULL,
			KEY cache_token (cache_token),
			KEY cache_type (cache_type),
			KEY host_id (host_id)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE MODULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.modules 
		(
			MOD_ID 			INT NOT NULL, 
			MOD_NAME 		VARCHAR(50) NOT NULL, 
			MOD_SHORT 		VARCHAR(3) NOT NULL, 
			MOD_HOST_ID 	INT DEFAULT NULL, 
			PRIMARY KEY (MOD_ID),
			KEY idx_mod_sort (MOD_SHORT),
  			KEY idx_mod_hostid (MOD_HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE PERMISSION --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.permissions 
		(
			PER_ID 			INT NOT NULL, 
			PER_KEY  		VARCHAR(50) NOT NULL, 
			PER_HOST_ID 	INT DEFAULT NULL, 
			PER_ACTIVE 		INT DEFAULT 1 NOT NULL, 
			PER_MOD_ID 		INT NOT NULL,
			PER_LEVEL		VARCHAR(10),
			PRIMARY KEY (PER_ID),
			KEY PER_MOD_ID (PER_MOD_ID),
			KEY per_hostid (PER_HOST_ID),
		    KEY per_active (PER_ACTIVE),
			FOREIGN KEY (PER_MOD_ID) REFERENCES modules (MOD_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.groups
		(	
			GRP_ID 				VARCHAR(100) NOT NULL, 
			GRP_NAME 			VARCHAR(50), 
			GRP_HOST_ID 		INT DEFAULT NULL, 
			GRP_MOD_ID 			INT NOT NULL, 
			GRP_TRANSLATION_KEY VARCHAR(50), 
			UPC_SIZE			VARCHAR(2) DEFAULT NULL,
			UPC_FOLDER_FORMAT	VARCHAR(5) DEFAULT 'false',
			FOLDER_SUBSCRIBE	VARCHAR(5) DEFAULT 'false',
			FOLDER_REDIRECT VARCHAR(100),
			PRIMARY KEY (GRP_ID),
			KEY GRP_MOD_ID (GRP_MOD_ID),
  			KEY grp_hostid (GRP_HOST_ID),
			FOREIGN KEY (GRP_MOD_ID) REFERENCES modules (MOD_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.hosts 
		(
		  HOST_ID           INT NOT NULL,
		  HOST_NAME         VARCHAR(100),
		  HOST_PATH         VARCHAR(50),
		  HOST_CREATE_DATE  DATE,
		  HOST_DB_PREFIX    VARCHAR(40),
		  HOST_LANG         INT,
		  HOST_TYPE			VARCHAR(2) DEFAULT 'F',
		  HOST_SHARD_GROUP	VARCHAR(10),
		  HOST_NAME_CUSTOM  VARCHAR(200),
		  PRIMARY KEY (HOST_ID),
		  KEY idx_hostname (HOST_NAME),
		  KEY idx_hostname_custom (HOST_NAME_CUSTOM),
		  KEY idx_hosttype (HOST_TYPE)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.users 
		(
		  USER_ID              VARCHAR(100) NOT NULL,
		  USER_LOGIN_NAME      VARCHAR(50) NOT NULL,
		  USER_EMAIL           VARCHAR(80) NOT NULL,
		  USER_FIRST_NAME      VARCHAR(80),
		  USER_LAST_NAME       VARCHAR(80),
		  USER_PASS            text NOT NULL,
		  USER_COMPANY         VARCHAR(80),
		  USER_STREET          VARCHAR(80),
		  USER_STREET_NR       INT(6),
		  USER_STREET_2        VARCHAR(80),
		  USER_STREET_NR_2     INT(6),
		  USER_ZIP             INT(7),
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
		  USER_SALUTATION      VARCHAR(255),
		  USER_IN_VP		   VARCHAR(2) DEFAULT 'F',
		  SET2_NIRVANIX_NAME   VARCHAR(500),
		  SET2_NIRVANIX_PASS   VARCHAR(500),
		  USER_API_KEY		   VARCHAR(100),
		  USER_EXPIRY_DATE 	   DATE,
		  user_search_selection VARCHAR(100),
		  PRIMARY KEY (USER_ID)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE CT_GROUPS_USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_groups_users
		(	
		CT_G_U_GRP_ID 		VARCHAR(100) NOT NULL, 
		CT_G_U_USER_ID 		VARCHAR(100) NOT NULL,
		rec_uuid			VARCHAR(100),
		PRIMARY KEY (rec_uuid),
		KEY CT_G_U_GRP_ID (ct_g_u_grp_id),
  		KEY ct_g_u_user_id (ct_g_u_user_id),
		FOREIGN KEY (CT_G_U_GRP_ID) REFERENCES groups (GRP_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE CT_GROUPS_PERMISSIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_groups_permissions
		(	
		CT_G_P_PER_ID 		INT NOT NULL, 
		CT_G_P_GRP_ID 		VARCHAR(100) NOT NULL,
		KEY CT_G_P_PER_ID (CT_G_P_PER_ID),
  		KEY CT_G_P_GRP_ID (CT_G_P_GRP_ID),
		FOREIGN KEY (CT_G_P_PER_ID) REFERENCES permissions (PER_ID) ON DELETE CASCADE, 
		FOREIGN KEY (CT_G_P_GRP_ID)	REFERENCES groups (GRP_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE LOG_ACTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.log_actions 
		(
		  LOG_ACT_ID    INT,
		  LOG_ACT_TEXT  VARCHAR(200),
		  PRIMARY KEY (LOG_ACT_ID)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE CT_USERS_HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_users_hosts 
		(
		  CT_U_H_USER_ID  VARCHAR(100),
		  CT_U_H_HOST_ID  INT,
		  rec_uuid		  VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY ct_u_h_user_id (ct_u_h_user_id),
  		  KEY ct_u_h_host_id (CT_U_H_HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE USERS_LOGIN --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.users_login 
		(
		  USER_LOGIN_ID         INT NOT NULL,
		  USER_ID               VARCHAR(100),
		  USER_LOGIN_DATE       DATE,
		  USER_LOGIN_TIME       TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  USER_LOGIN_PROJECT    INT,
		  USER_LOGIN_SESSION    VARCHAR(200),
		  USER_LOGIN_DATESTAMP  DATE
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE WISDOM --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.wisdom 
		(
		  WIS_ID      INT,
		  WIS_TEXT    text,
		  WIS_AUTHOR  VARCHAR(200),
		  PRIMARY KEY (WIS_ID)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE USERS_COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.users_comments
		(
		  USER_ID_R           VARCHAR(100),
		  USER_COMMENT        text,
		  CREATE_DATE         DATE,
		  CHANGE_DATE         DATE,
		  USER_COMMENT_BY     INT,
		  USER_COMMENT_TITLE  text,
		  COMMENT_ID          INT
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE FILE_TYPES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.file_types
		(
		  TYPE_ID              VARCHAR(10),
		  TYPE_TYPE            VARCHAR(3),
		  TYPE_MIMECONTENT     VARCHAR(50),
		  TYPE_MIMESUBCONTENT  VARCHAR(50),
		  PRIMARY KEY (TYPE_ID)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE CT_USERS_REMOTEUSERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_users_remoteusers
		(
		   	CT_U_RU_ID                INT NOT NULL, 
			CT_U_RU_USER_ID           VARCHAR(100) NOT NULL, 
			CT_U_RU_REMOTE_URL        text NOT NULL, 
			CT_U_RU_REMOTE_USER_ID    VARCHAR(100) NOT NULL, 
			CT_U_RU_REMOTE_USER_NAME  text NOT NULL, 
			CT_U_RU_REMOTE_USER_EMAIL text, 
			CT_U_RU_REMOTE_CONFIRMED  INT DEFAULT 0 NOT NULL, 
			CT_U_RU_UUID              text NOT NULL, 
			CT_U_RU_VALIDUNTIL        DATE, 
			CT_U_RU_CONFIRMED         INT DEFAULT 0 NOT NULL, 
		PRIMARY KEY (CT_U_RU_ID),
		KEY CT_U_RU_USER_ID (CT_U_RU_USER_ID),
		FOREIGN KEY (CT_U_RU_USER_ID) REFERENCES users (USER_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE WEBSERVICES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.webservices
		(
			SESSIONTOKEN 	VARCHAR(100), 
			TIMEOUT 		TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			GROUPOFUSER		VARCHAR(2000),
			USERID			VARCHAR(100),
			PRIMARY KEY (SESSIONTOKEN)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE SEARCH REINDEX --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.search_reindex
		(
			theid			VARCHAR(100),
			thevalue		INT,
			thehostid		INT,
			datetime		TIMESTAMP DEFAULT '0000-00-00 00:00:00'
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE TOOLS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.tools
		(
			thetool			VARCHAR(100),
			thepath			VARCHAR(200),
			PRIMARY KEY (thetool)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE CT_LABELS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_labels
		(
			ct_label_id 	varchar(100),
		 	ct_id_r 		varchar(100),
		 	ct_type 		varchar(100),
		 	rec_uuid		VARCHAR(100),
		 	PRIMARY KEY(rec_uuid)
		)
		#this.tableoptions#
		</cfquery>
		<!--- CREATE RFS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.rfs
		(
			rfs_id 			varchar(100),
			rfs_active 		INT,
			rfs_server_name varchar(200),
			rfs_imagemagick varchar(200),
			rfs_ffmpeg 		varchar(200),
			rfs_dcraw 		varchar(200),
			rfs_exiftool 	varchar(200),
			rfs_mp4box	 	varchar(200),
			rfs_location 	varchar(200),
			rfs_date_add 	timestamp DEFAULT '0000-00-00 00:00:00',
			rfs_date_change timestamp DEFAULT '0000-00-00 00:00:00',
			PRIMARY KEY (rfs_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- ct_plugins_hosts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_plugins_hosts
		(
			ct_pl_id_r		varchar(100),
		  	ct_host_id_r	int,
		  	rec_uuid		varchar(100)
		)
		#this.tableoptions#
		</cfquery>

		<!--- plugins --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.plugins
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
			p_cfc_list 		varchar(500),
			PRIMARY KEY (p_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- plugins_actions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.plugins_actions
		(
			action 			varchar(200),
  			comp 			varchar(200),
  			func 			varchar(200),
  			args 			text,
  			p_id 			varchar(100),
  			p_remove		varchar(10),
  			host_id 		int
		)
		#this.tableoptions#
		</cfquery>

		<!--- options --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.options
		(
			opt_id			varchar(100),
			opt_value		text,
			rec_uuid		varchar(100)
		)
		#this.tableoptions#
		</cfquery>

		<!--- news --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.news
		(
			news_id			varchar(100),
			news_title		varchar(500),
			news_active		varchar(6),
			news_text		text,
			news_date		varchar(20),
			host_id 		int default 0,
			PRIMARY KEY (news_id)
		)
		#this.tableoptions#
		</cfquery>

		<!--- ct_aliases --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.ct_aliases
		(
			asset_id_r 		varchar(100) DEFAULT NULL,
			folder_id_r 	varchar(100) DEFAULT NULL,
			type 			varchar(10) DEFAULT NULL,
			rec_uuid 		varchar(100) DEFAULT NULL,
			KEY asset_id_r (asset_id_r),
			KEY folder_id_r (folder_id_r)
		)
		#this.tableoptions#
		</cfquery>

		<!--- folder_subscribe_groups --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		  CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folder_subscribe_groups (
		  folder_id varchar(100) DEFAULT NULL,
		  group_id varchar(100) DEFAULT NULL,
		  KEY folder_id (folder_id),
		  KEY group_id (group_id)
		) #this.tableoptions#
		</cfquery>
	

		<!---  --->
		<!--- END: CREATE TABLES --->
		<!---  --->
		
		<!--- If we come from import then dont do this --->
		<cfif NOT structkeyexists(arguments.thestruct,"fromimport")>
		
			<!---  --->
			<!--- START: INSERT VALUES --->
			<!---  --->
			
			<!--- SEQUENCES
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('categories_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('collection_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('content_id_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('ct_users_remoteusers_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('ctuag_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('ctug_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('ctuh_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('file_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('folder_seq', 3)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('groupsadmin_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('groups_seq', 3)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('hostid_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('img_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('keywords_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('log_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('menuesid_seq', 5)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('permissions_seq', 12)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('pub_grp_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('pub_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('schedule_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('sched_log_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('userlogin_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('users_lists_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('users_seq', 5)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('user_ship_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('valuelist_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.sequences
			(theid, thevalue)
			VALUES('customfield_seq', 0)
			</cfquery>
			 --->
			<!--- USERS --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.users
			(USER_ID, USER_LOGIN_NAME, USER_EMAIL, USER_FIRST_NAME, USER_LAST_NAME, USER_PASS, USER_ACTIVE, USER_IN_ADMIN, USER_IN_DAM)
			VALUES ('1', 'admin', 'admin@razuna.com', 'SystemAdmin', 'SystemAdmin', '778509C62BD8904D938FB85644EC4712', 'T', 'T', 'T')
			</cfquery>
			<!--- MODULES --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.modules
			(mod_id, mod_name, mod_short, mod_host_id)
			VALUES(	1, 'razuna', 'ecp', NULL)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.modules
			(mod_id, mod_name, mod_short, mod_host_id)
			VALUES(	2, 'admin', 'adm', NULL)
			</cfquery>
			<!--- DEFAULT ADMIN GROUPS --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.groups
			(grp_id, grp_name, grp_host_id, grp_mod_id)
			VALUES(	'1', 'SystemAdmin', NULL, 2 )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.groups
			(grp_id, grp_name, grp_host_id, grp_mod_id)
			VALUES(	'2', 'Administrator', NULL, 2	)
			</cfquery>
			<!--- DEFAULT ADMIN CROSS TABLE --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.ct_groups_users
			(CT_G_U_GRP_ID, CT_G_U_USER_ID, rec_uuid)
			VALUES(	'1', '1', '#createuuid()#')
			</cfquery>
			<!--- DEFAULT ADMIN PERMISSIONS --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (1,'SystemAdmin',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (2,'Administrator',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (3,'PER_USERS:N',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (4,'PER_USERS:R',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (5,'PER_USERS:W',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (6,'PER_GROUPS:N',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (7,'PER_GROUPS:R',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (8,'PER_GROUPS:W',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (9,'PER_GROUPS_ADMIN:N',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (10,'PER_GROUPS_ADMIN:R',null,1,2,null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into #arguments.thestruct.theschema#.permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (11,'PER_GROUPS_ADMIN:W',null,1,2,null)
			</cfquery>
			<!--- DEFAULT ADMIN PERMISSIONS CROSS TABLE --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 1, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 2, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 3, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 4, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 5, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 6, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 7, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 8, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 9, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 10, '1' )
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	#arguments.thestruct.theschema#.ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 11, '1' )
			</cfquery>
			<!--- WISDOM --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			2, 'In giving advice, seek to help, not please, your friend.', 'Solon') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			3, 'A friend is one to whom you can pour out the contents of your heart, chaff and grain alike. Knowning that the gentlest of hands will take and sift it, keep what is worth keeping, and with a breath of kindness, blow the rest away.'
			, 'Anonymous') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			4, 'The most exciting phrase to hear in science, the one that heralds new discoveries, is not "Eureka" (I found it!) but "That''s funny ..."'
			, 'Isaac Asimov') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			5, 'Everyone should carefully observe which way his heart draws him, and then choose that way with all his strength!'
			, 'Hasidic saying') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			6, 'Mend your speech a little, lest it may mar your fortunes.', 'Shakespeare, King Lear')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#"> 
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			7, 'In preparing for battle I have always found that plans are useless, but planning is indispensable.'
			, 'Dwight D. Eisenhower') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			8, 'It''s all right to aim high if you have plenty of ammunition.', 'Hawley R. Everhart')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#"> 
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			10, 'A great civilization is not concurred from without until it has destroyed itself from within.'
			, 'Will Durant') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			11, 'Travel far enough away, my friend, and you''ll discover something of great beauty: your self'
			, 'Cirque du Soleil') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			1, 'There are Painters who transform the sun to a yellow spot, but there are others who with the help of their art and their intelligence, transform a yellow spot into the sun.'
			, 'Pablo Picasso') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			9, 'The significant problems we have cannot be solved at the same level of thinking with which we created them.'
			, 'Albert Einstein') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			12, 'Acquaintance, n.: A person whom we know well enough to borrow from, but not well enough to lend to. '
			, 'Ambrose Bierce') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			13, 'The best investment is in the tools of one''s trade.', 'Benjamin Franklin')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#"> 
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			14, 'We all agree that your theory is crazy -- but is it crazy enough?', 'Niels Bohr')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#"> 
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			15, 'Genius without education is like silver in the mine.', 'Benjamin Franklin')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#"> 
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			16, 'Anybody can sympathise with the sufferings of a friend, but it requires a very fine nature to sympathise with a friend''s success.', 'Oscar Wilde') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			17, 'Absurdity, n.: A statement or belief manifestly incosistent with one''s own.', 'Ambrose Bierce')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#"> 
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			18, 'There''s no trick to being a humorist when you have the whole government working for you.', 'Will Rogers')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			19, 'The real question is not whether machines think but whether men do. The mystery which surrounds a thinking machine already surrounds a thinking man.', 'B.F.Skinner') 
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			20, 'That we must all die, we always knew; I wish I had remembered it sooner.', 'Samuel Johnson')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			21, 'The key to living well is first to will that which is necessary and then to love that which is willed.', 'Irving Yalom')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			22, 'Always tell the truth. You will gratify some people and astonish the rest.', 'Mark Twain')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			23, 'See everything. Ignore a lot. Improve a little.', 'Pope John Paul II')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			24, 'Resentment is like taking poison and hoping the other person dies.', 'St. Augustine')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			25, 'Hope is definitely not the same thing as optimism. It is not the conviction that something will turn out well, but the certainty that something makes sense, regardless of how it turns out.', 'Vaclav Havel')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			26, 'We must never be ashamed of our tears, they are rain from heaven washing the dust from our hard hearts.', 'Charles Dickens')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			27, 'Our business in life is not to succeed, but to continue to fail in good spirits.', 'Robert Louis Stevenson')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			28, 'Be who you are and say what you feel because the people who mind don''t matter and the people who matter don''t mind.', 'Theodor Geisel')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			29, 'It is well to remember that the entire universe, with one trifling exception, is composed of others.', 'John Andrew Holmes')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			30, 'Fail to honor people, they fail to honor you.', 'Lao Tzu')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			31, 'You can leave anything out, as long as you know what it is.', 'Ernest Hemingway')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			32, 'The future is here. It''s just not evenly distributed yet.', 'William Gibson')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			33, 'The future always comes too fast and in the wrong order.', 'Alvin Toffler')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			34, 'There will always be people who are ahead of the curve, and people who are behind the curve. But knowledge moves the curve.', 'Bill James')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			35, 'History is a wave that moves through time slightly faster than we do.', 'Kim Stanley Robinson')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			36, 'Inspiration is for amateurs. I just get to work.', 'Chuck Close')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			37, 'The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.', 'Hellen Keller')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			38, 'Small opportunities are often the beginning of great enterprises.', 'Demosthenes')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			39, 'Simplicity is the utlimate sophistication.', 'Leonardo da Vinci')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			40, 'A journey of thousand miles begins with a single step.', 'Lao tzu')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			41, 'What we think, we become.', 'Buddha')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			42, 'Great minds discuss ideas. Average minds discuss events. Small minds discuss people.', 'Eleanor Roosevelt')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			43, 'Forget the place you are trying to get and see the beauty in right now', 'Some wise person')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			44, 'All that we are, is the result of our thoughts.', 'Buddha')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			45, 'Logic will get you from A to B. Imagination will take you everywhere.', 'Albert Einstein')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			46, 'Do not dwell on who let you down, cherish those whoe hold you up.', 'Unknown')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			47, 'People are made to be loved and things are made to be used. The confusion in this world is that people are used and things are loved!', 'Unknown')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			48, 'Make peace with your past so it will not destroy your present.', 'Paulo Coelho')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			49, 'Obstacles are those frightful things you see when you take your eyes off your goal.', 'Henry Ford')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			50, 'I feel like I can not feel.', 'Salvador Dali')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			51, 'To avoid criticism, do nothing, say nothing, and be nothing.', 'Elbert Hubbard')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			52, 'I am not upset that you lied to me, I am upset that from now on I can not believe you anymore.', 'Friedrich Nietzsche')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			53, 'Successful and great people are ordinary people with extraordinary determination.', 'Robert Schuller')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			54, 'Everything has beauty, but not everyone sees it.', 'Confucius')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			55, 'Wanting to be someone else is a waste of the person you are.', 'Kurt Cobain')
			</cfquery>
			<!--- FILE TYPES --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('doc', 'doc', 'application', 'vnd.ms-word')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('docx', 'doc', 'application', 'vnd.ms-word')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('xls', 'doc', 'application', 'vnd.ms-excel')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('xlsx', 'doc', 'application', 'vnd.ms-excel')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ppt', 'doc', 'application', 'vnd.ms-powerpoint')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pptx', 'doc', 'application', 'vnd.ms-powerpoint')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pdf', 'doc', 'application', 'pdf')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('txt', 'doc', 'application', 'txt')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('psd', 'img', 'application', 'photoshop')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ai', 'img', 'application', 'photoshop')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('eps', 'img', 'application', 'eps')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('jpg', 'img', 'image', 'jpg')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('jpeg', 'img', 'image', 'jpeg')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('gif', 'img', 'image', 'gif')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('png', 'img', 'image', 'png')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('bmp', 'img', 'image', 'bmp')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('cal', 'img', null, null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('dcm', 'img', null, null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('fpx', 'img', 'image', 'vnd.fpx')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pbm', 'img', 'image', 'pbm')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pgm', 'img', 'image', 'x-portable-graymap')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ppm', 'img', 'image', 'x-portable-pixmap')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pnm', 'img', 'image', 'x-portable-anymap')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pcx', 'img', 'image', 'pcx')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pct', 'img', null, null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('rpx', 'img', null, null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ras', 'img', 'image', 'ras')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('tga', 'img', 'image', 'tga')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('tif', 'img', 'image', 'tif')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('tiff', 'img', 'image', 'tiff')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('wbmp', 'img', 'image', 'vnd.wap.wbmp')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('nef', 'img', 'image', 'nef')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('swf', 'vid', 'application', 'x-shockwave-flash')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('flv', 'vid', 'application', 'x-shockwave-flash')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('f4v', 'vid', 'application', 'x-shockwave-flash')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mov', 'vid', 'video', 'quicktime')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('m4v', 'vid', 'video', 'quicktime')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('avi', 'vid', 'video', 'avi')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('3gp', 'vid', 'video', '3gpp')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('rm', 'vid', 'application', 'vnd.rn-realmedia')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mpg', 'vid', 'video', 'mpeg')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mp4', 'vid', 'video', 'mp4v-es')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('wmv', 'vid', 'video', 'x-ms-wmv')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('vob', 'vid', 'video', 'mpeg')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ogv', 'vid', 'video', 'ogv')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('webm', 'vid', 'video', 'webm')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mts', 'vid', 'video', 'mts')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('m2ts', 'vid', 'video', 'm2ts')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('m2t', 'vid', 'video', 'm2t')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('aff', 'aud', null, null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('aft', 'aud', null, null)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('au', 'aud', 'audio', 'basic')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ram', 'aud', 'audio', 'x-pn-realaudio')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('wav', 'aud', 'audio', 'x-wav')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mp3', 'aud', 'audio', 'mpeg')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('aiff', 'aud', 'audio', 'x-aiff')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('aif', 'aud', 'audio', 'x-aiff')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('aifc', 'aud', 'audio', 'x-aiff')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('snd', 'aud', 'audio', 'basic')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mid', 'aud', 'audio', 'mid')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('m3u', 'aud', 'audio', 'x-mpegurl')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('rmi', 'aud', 'audio', 'mid')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ra', 'aud', 'audio', 'x-pn-realaudio')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('flac', 'aud', 'audio', 'flac')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ogg', 'aud', 'audio', 'ogg')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('m4a', 'aud', 'audio', 'x-m4a')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('arw', 'img', 'image', 'arw')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('cr2', 'img', 'image', 'cr2')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('crw', 'img', 'image', 'crw')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ciff', 'img', 'image', 'ciff')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('cs1', 'img', 'image', 'cs1')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('erf', 'img', 'image', 'erf')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mef', 'img', 'image', 'mef')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mrw', 'img', 'image', 'mrw')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('nrw', 'img', 'image', 'nrw')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('pef', 'img', 'image', 'pef')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('psb', 'img', 'application', 'photoshop')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('raf', 'img', 'image', 'raf')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('raw', 'img', 'image', 'raw')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('rw2', 'img', 'image', 'rw2')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('rwl', 'img', 'image', 'rwl')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('srw', 'img', 'image', 'srw')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('3fr', 'img', 'image', '3fr')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ari', 'img', 'image', 'ari')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('srf', 'img', 'image', 'srf')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('sr2', 'img', 'image', 'sr2')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('bay', 'img', 'image', 'bay')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('cap', 'img', 'image', 'cap')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('iiq', 'img', 'image', 'iiq')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('eip', 'img', 'image', 'eip')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('dcr', 'img', 'image', 'dcr')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('drf', 'img', 'image', 'drf')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('k25', 'img', 'image', 'k25')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('kdc', 'img', 'image', 'kdc')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('dng', 'img', 'image', 'dng')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('fff', 'img', 'image', 'fff')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mos', 'img', 'image', 'mos')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('orf', 'img', 'image', 'orf')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('ptx', 'img', 'image', 'ptx')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('r3d', 'img', 'image', 'r3d')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('rwz', 'img', 'image', 'rwz')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('x3f', 'img', 'image', 'x3f')
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO #arguments.thestruct.theschema#.file_types VALUES ('mxf', 'vid', 'video', 'mxf')
			</cfquery>
		</cfif>
	</cffunction>
	
	<!--- Create Host Remote --->
	<cffunction name="create_host_remote" access="remote" output="false">
		<cfargument name="dsn" type="string" required="true">
		<cfargument name="theschema" type="string" required="true">
		<cfargument name="host_db_prefix" type="string" required="true">
		<!--- Params --->
		<cfset arguments.thestruct = structnew()>
		<cfset arguments.thestruct.dsn = arguments.dsn>
		<cfset arguments.thestruct.theschema = arguments.theschema>
		<cfset arguments.thestruct.host_db_prefix = arguments.host_db_prefix>
		<!--- Create Tables --->
		<cfinvoke method="create_tables" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- Create Host --->
	<cffunction name="create_host" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		<cfset arguments.thestruct.theschema = application.razuna.theschema>
		<!--- Create Tables --->
		<cfinvoke method="create_tables" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- Create Tables --->
	<cffunction name="create_tables" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		
		<!--- ASSETS_TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#assets_temp 
		(
			TEMPID 			VARCHAR(200), 
			FILENAME 		VARCHAR(255), 
			EXTENSION 		VARCHAR(20), 
			DATE_ADD 		TIMESTAMP DEFAULT '0000-00-00 00:00:00', 
			FOLDER_ID		VARCHAR(100), 
			WHO				VARCHAR(100), 
			FILENAMENOEXT	VARCHAR(255), 
			PATH 			TEXT, 
			MIMETYPE		VARCHAR(255), 
			THESIZE			VARCHAR(100),
			GROUPID			VARCHAR(100),
			SCHED_ACTION	INT,
			SCHED_ID		VARCHAR(100),
			FILE_ID			VARCHAR(100),
			LINK_KIND		VARCHAR(20),
			HOST_ID			INT,
			md5hash			VARCHAR(100),
			PRIMARY KEY (TEMPID),
		    KEY #arguments.thestruct.host_db_prefix#t_date (DATE_ADD),
			KEY #arguments.thestruct.host_db_prefix#t_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#xmp 
		(
			id_r					VARCHAR(100),
			asset_type				varchar(10),
			subjectcode				varchar(1000),
			creator					varchar(1000),
			title					varchar(1000),
			authorsposition				varchar(1000),
			captionwriter				varchar(1000),
			ciadrextadr				varchar(1000),
			category				varchar(1000),
			supplementalcategories			text,
			urgency					varchar(500),
			description				text,
			ciadrcity				varchar(500),
			ciadrctry				varchar(500),
			location					varchar(500),
			ciadrpcode				varchar(300),
			ciemailwork				varchar(300),
			ciurlwork				varchar(300),
			citelwork				varchar(300),
			intellectualgenre			varchar(500),
			instructions				text,
			source					varchar(1000),
			usageterms				text,
			copyrightstatus				text,
			transmissionreference			varchar(500),
			webstatement				text,
			headline				varchar(1000),
			datecreated				varchar(200),
			city					varchar(1000),
			ciadrregion				varchar(500),
			country					varchar(500),
			countrycode				varchar(500),
			scene					varchar(500),
			state					varchar(500),
			credit					varchar(1000),
			rights					text,
			colorspace				varchar(50),
			xres					varchar(30),
			yres					varchar(30),
			resunit					varchar(20),
			host_id					int,
			KEY #arguments.thestruct.host_db_prefix#xmp_idr (id_r),
   		    	KEY #arguments.thestruct.host_db_prefix#xmp_hostid (host_id),
			KEY #arguments.thestruct.host_db_prefix#xmp_type (asset_type)
		)  
		#this.tableoptions#
		</cfquery>
		
		<!--- CART --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#cart
		(
		  CART_ID           	VARCHAR(200),
		  USER_ID           	VARCHAR(100),
		  CART_QUANTITY     	INT,
		  CART_PRODUCT_ID   	VARCHAR(100),
		  CART_CREATE_DATE  	DATE,
		  CART_CREATE_TIME  	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  CART_CHANGE_DATE  	DATE,
		  CART_CHANGE_TIME  	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  CART_FILE_TYPE    	VARCHAR(5),
		  cart_order_email 		varchar(150),
		  cart_order_message 	varchar(2000),
		  cart_order_done 		varchar(1), 
		  cart_order_date 		timestamp DEFAULT '0000-00-00 00:00:00',
		  cart_order_user_r 	VARCHAR(100),
		  HOST_ID				INT,
		  KEY #arguments.thestruct.host_db_prefix#cart_id (CART_ID),
		  KEY #arguments.thestruct.host_db_prefix#cart_user (USER_ID),
		  KEY #arguments.thestruct.host_db_prefix#cart_done (cart_order_done),
		  KEY #arguments.thestruct.host_db_prefix#cart_user_r (cart_order_user_r)
		)
		#this.tableoptions#
		</cfquery>
				
		<!--- FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders
		(
		  FOLDER_ID             VARCHAR(100),
		  FOLDER_NAME           VARCHAR(200),
		  FOLDER_LEVEL          INT,
		  FOLDER_ID_R           VARCHAR(100),
		  FOLDER_MAIN_ID_R      VARCHAR(100),
		  FOLDER_OWNER          VARCHAR(100),
		  FOLDER_CREATE_DATE    DATE,
		  FOLDER_CREATE_TIME    TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  FOLDER_CHANGE_DATE    DATE,
		  FOLDER_CHANGE_TIME    TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  FOLDER_IS_IMG_FOLDER  VARCHAR(2),
		  FOLDER_IMG_PUB_ID     INT,
		  FOLDER_OF_USER        VARCHAR(2) DEFAULT NULL,
		  FOLDER_IS_COLLECTION  VARCHAR(2) DEFAULT NULL,
		  FOLDER_IS_VID_FOLDER  VARCHAR(2),
		  FOLDER_VID_PUB_ID		INT,
		  FOLDER_AVAILABLE_DSC  INT DEFAULT 1,
		  FOLDER_SHARED			VARCHAR(2) DEFAULT 'F',
		  FOLDER_NAME_SHARED	VARCHAR(200),
		  LINK_PATH				VARCHAR(200),
		  share_dl_org			varchar(1) DEFAULT 'f',
		  share_dl_thumb		varchar(1) DEFAULT 't',
     	  	  share_comments		varchar(1) DEFAULT 'f',
		  share_upload			varchar(1) DEFAULT 'f',
		  share_order			varchar(1) DEFAULT 'f',
		  share_order_user		VARCHAR(100),
		  share_inherit			VARCHAR(1) DEFAULT 'f',
		  HOST_ID				INT,
		  IN_TRASH		   		VARCHAR(2) DEFAULT 'F',
		  in_search_selection	VARCHAR(5) DEFAULT 'false',
		  PRIMARY KEY (FOLDER_ID),
		  KEY #arguments.thestruct.host_db_prefix#fo_hostid (HOST_ID),
		  KEY #arguments.thestruct.host_db_prefix#fo_id (folder_id),
		  KEY #arguments.thestruct.host_db_prefix#fo_name (FOLDER_NAME),
		  KEY #arguments.thestruct.host_db_prefix#fo_id_r (folder_id_r),
		  KEY #arguments.thestruct.host_db_prefix#fo_owner (folder_owner),
		  KEY #arguments.thestruct.host_db_prefix#fo_col (FOLDER_IS_COLLECTION),
		  KEY #arguments.thestruct.host_db_prefix#fo_shared (FOLDER_SHARED),
		  KEY #arguments.thestruct.host_db_prefix#fo_user (FOLDER_OF_USER),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- FOLDERS DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_desc
		(
		  FOLDER_ID_R  VARCHAR(100),
		  LANG_ID_R    INT,
		  FOLDER_DESC  text,
		  HOST_ID	   INT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#fod_hostid (HOST_ID),
		  KEY #arguments.thestruct.host_db_prefix#fod_fidr (folder_id_r),
		  KEY #arguments.thestruct.host_db_prefix#fod_lang (LANG_ID_R),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- FOLDERS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_groups
		(
		  FOLDER_ID_R     VARCHAR(100),
		  GRP_ID_R        VARCHAR(100),
		  GRP_PERMISSION  VARCHAR(2),
		  HOST_ID		  INT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#fg_grpid (grp_id_r),
		  KEY #arguments.thestruct.host_db_prefix#fg_grpperm (GRP_PERMISSION),
		  KEY #arguments.thestruct.host_db_prefix#fg_hostid (HOST_ID),
		  KEY #arguments.thestruct.host_db_prefix#fg_fidr (folder_id_r),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- FILES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files
		(
		  FILE_ID              VARCHAR(100),
		  FOLDER_ID_R          VARCHAR(100) DEFAULT NULL,
		  FILE_CREATE_DATE     DATE,
		  FILE_CREATE_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  FILE_CHANGE_DATE     DATE,
		  FILE_CHANGE_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  FILE_OWNER           VARCHAR(100),
		  FILE_TYPE            VARCHAR(5),
		  FILE_NAME            VARCHAR(500),
		  FILE_EXTENSION       VARCHAR(20),
		  FILE_NAME_NOEXT      VARCHAR(200),
		  FILE_CONTENTTYPE     VARCHAR(100),
		  FILE_CONTENTSUBTYPE  VARCHAR(100),
		  FILE_REMARKS         TEXT,
		  FILE_ONLINE          VARCHAR(2),
		  FILE_NAME_ORG        VARCHAR(200),
		  FILE_SIZE			   VARCHAR(100),
		  LUCENE_KEY		   VARCHAR(2000),
		  SHARED			   VARCHAR(2) DEFAULT 'F',
		  LINK_KIND			   VARCHAR(20),
		  LINK_PATH_URL		   VARCHAR(2000),
		  FILE_META			   LONGTEXT,
		  HOST_ID			   INT,
		  PATH_TO_ASSET		   VARCHAR(500),
		  CLOUD_URL			   VARCHAR(500),
		  CLOUD_URL_ORG		   VARCHAR(500),
		  HASHTAG			   VARCHAR(100),
		  IS_AVAILABLE		   VARCHAR(1) DEFAULT 0,
		  CLOUD_URL_EXP		   INT,
		  IN_TRASH		   	   VARCHAR(2) DEFAULT 'F',
		  IS_INDEXED		   VARCHAR(1) DEFAULT 0,
		  FILE_UPC_NUMBER	   VARCHAR(15),
		  EXPIRY_DATE DATE,
		PRIMARY KEY (FILE_ID),
		KEY #arguments.thestruct.host_db_prefix#files_hostid (HOST_ID),
	    KEY #arguments.thestruct.host_db_prefix#files_name (FILE_NAME),
	    KEY #arguments.thestruct.host_db_prefix#files_folderid (folder_id_r),
	    KEY #arguments.thestruct.host_db_prefix#files_name_org (FILE_NAME_ORG),
	    KEY #arguments.thestruct.host_db_prefix#files_pathtoasset (PATH_TO_ASSET),
	    KEY #arguments.thestruct.host_db_prefix#files_ext (FILE_EXTENSION),
	    KEY #arguments.thestruct.host_db_prefix#files_type (FILE_TYPE),
	    KEY #arguments.thestruct.host_db_prefix#files_owner (file_owner),
	    KEY #arguments.thestruct.host_db_prefix#files_createdate (FILE_CREATE_DATE),
	    KEY #arguments.thestruct.host_db_prefix#files_hashtag (HASHTAG),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- FILES DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_desc
		(
		  ID_INC		 VARCHAR(100),
		  FILE_ID_R      VARCHAR(100),
		  LANG_ID_R      INT,
		  FILE_DESC      text,
		  FILE_KEYWORDS  text,
		  HOST_ID				INT,
		PRIMARY KEY (ID_INC),
		KEY #arguments.thestruct.host_db_prefix#fd_idr (file_id_r),
	    KEY #arguments.thestruct.host_db_prefix#fd_hostid (HOST_ID),
	    KEY #arguments.thestruct.host_db_prefix#fd_lang (LANG_ID_R)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- IMAGES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images
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
		  IMG_CUSTOM_ID       VARCHAR(500),
		  IMG_ONLINE          VARCHAR(2),
		  IMG_OWNER           VARCHAR(100),
		  IMG_CREATE_DATE     DATE,
		  IMG_CREATE_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  IMG_CHANGE_DATE     DATE,
		  IMG_CHANGE_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  IMG_RANKING         INT,
		  IMG_SINGLE_SALE     VARCHAR(2),
		  IMG_IS_NEW          VARCHAR(2),
		  IMG_SELECTION       VARCHAR(2),
		  IMG_IN_PROGRESS     VARCHAR(2),
		  IMG_ALIGNMENT       VARCHAR(200),
		  IMG_LICENSE         VARCHAR(200),
		  IMG_DOMINANT_COLOR  VARCHAR(200),
		  IMG_COLOR_MODE      VARCHAR(200),
		  IMG_IMAGE_TYPE      VARCHAR(200),
		  IMG_CATEGORY_ONE    text,
		  IMG_REMARKS         longtext,
		  IMG_EXTENSION       VARCHAR(20),
		  THUMB_EXTENSION	  VARCHAR(20),
		  THUMB_WIDTH         INT,
		  THUMB_HEIGHT        INT,
		  IMG_FILENAME_ORG    VARCHAR(500),
		  IMG_WIDTH           INT,
  		  IMG_HEIGHT          INT,
	 	  IMG_SIZE            VARCHAR(100),
  		  THUMB_SIZE          VARCHAR(100),
		  LUCENE_KEY		  VARCHAR(2000),
		  SHARED			  VARCHAR(2) DEFAULT 'F',
		  LINK_KIND			  VARCHAR(20),
		  LINK_PATH_URL		  VARCHAR(2000),
		  IMG_META			  LONGTEXT,
		  HOST_ID			  INT,
		  PATH_TO_ASSET		  VARCHAR(500),
		  CLOUD_URL			  VARCHAR(500),
		  CLOUD_URL_ORG		  VARCHAR(500),
		  HASHTAG			  VARCHAR(100),
		  IS_AVAILABLE		  VARCHAR(1) DEFAULT 0,
		  CLOUD_URL_EXP		  INT,
		  IN_TRASH		   	  VARCHAR(2) DEFAULT 'F',
		  IS_INDEXED		  VARCHAR(1) DEFAULT 0,
		  IMG_UPC_NUMBER	  VARCHAR(15),
		  EXPIRY_DATE DATE,
		PRIMARY KEY (IMG_ID),
		KEY #arguments.thestruct.host_db_prefix#img_name (IMG_FILENAME),
	  	KEY #arguments.thestruct.host_db_prefix#img_name_org (IMG_FILENAME_ORG),
	  	KEY #arguments.thestruct.host_db_prefix#img_folderid (folder_id_r),
	  	KEY #arguments.thestruct.host_db_prefix#img_group (img_group),
	  	KEY #arguments.thestruct.host_db_prefix#img_pathtoasset (PATH_TO_ASSET),
	  	KEY #arguments.thestruct.host_db_prefix#img_hostid (HOST_ID),
	  	KEY #arguments.thestruct.host_db_prefix#img_hashtag (HASHTAG),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- IMAGES TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images_text
		(
		  ID_INC		   VARCHAR(100),
		  IMG_ID_R         VARCHAR(100) NOT NULL,
		  LANG_ID_R        INT NOT NULL,
		  IMG_KEYWORDS     text,
		  IMG_DESCRIPTION  text,
		  HOST_ID		   INT,
		PRIMARY KEY (ID_INC),
		KEY #arguments.thestruct.host_db_prefix#it_IMG_ID_R (img_id_r),
		KEY #arguments.thestruct.host_db_prefix#it_hostid (HOST_ID),
		KEY #arguments.thestruct.host_db_prefix#it_lang (LANG_ID_R)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- LOG ASSETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_assets
		(
		  LOG_ID 			VARCHAR(100) NOT NULL, 
		  LOG_USER 			VARCHAR(100), 
		  LOG_ACTION 		VARCHAR(100), 
		  LOG_DATE			DATE, 
		  LOG_TIME 			TIMESTAMP DEFAULT '0000-00-00 00:00:00', 
		  LOG_DESC 			text, 
		  LOG_FILE_TYPE 	VARCHAR(5), 
		  LOG_BROWSER 		text, 
		  LOG_IP		 	VARCHAR(200), 
		  LOG_TIMESTAMP 	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  HOST_ID			INT,
		  ASSET_ID_R		VARCHAR(100),
		  FOLDER_ID			VARCHAR(100),
		  PRIMARY KEY (LOG_ID),
		  KEY #arguments.thestruct.host_db_prefix#la_user (log_user),
  		  KEY #arguments.thestruct.host_db_prefix#la_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- LOG FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_folders
		(
		  LOG_ID 			VARCHAR(100) NOT NULL, 
		  LOG_USER 			VARCHAR(100), 
		  LOG_ACTION 		VARCHAR(100), 
		  LOG_DATE 			DATE, 
		  LOG_TIME 			TIMESTAMP DEFAULT '0000-00-00 00:00:00', 
		  LOG_DESC 			text, 
		  LOG_BROWSER 		text, 
		  LOG_IP 			VARCHAR(200), 
		  LOG_TIMESTAMP 	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  HOST_ID			INT, 
		  PRIMARY KEY (LOG_ID),
		  KEY #arguments.thestruct.host_db_prefix#lf_userid (log_user),
		  KEY #arguments.thestruct.host_db_prefix#lf_hostid (HOST_ID),
		  KEY #arguments.thestruct.host_db_prefix#lf_action (LOG_ACTION)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- LOG USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_users
		(
		  LOG_ID 			VARCHAR(100) NOT NULL, 
		  LOG_USER 			VARCHAR(100), 
		  LOG_ACTION 		VARCHAR(100), 
		  LOG_DATE 			DATE, 
		  LOG_TIME 			TIMESTAMP DEFAULT '0000-00-00 00:00:00', 
		  LOG_DESC 			text, 
		  LOG_BROWSER 		text, 
		  LOG_IP 			VARCHAR(200), 
		  LOG_TIMESTAMP 	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  LOG_SECTION 		VARCHAR(10),
		  HOST_ID			INT,
		  PRIMARY KEY (LOG_ID),
		  KEY #arguments.thestruct.host_db_prefix#lu_user (log_user),
		  KEY #arguments.thestruct.host_db_prefix#lu_action (LOG_ACTION),
		  KEY #arguments.thestruct.host_db_prefix#lu_hostid (HOST_ID),
		  KEY #arguments.thestruct.host_db_prefix#lu_section (LOG_SECTION)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- LOG SEARCH --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_search
		(
		  LOG_ID          	VARCHAR(100) NOT NULL,
		  LOG_USER        	VARCHAR(100),
		  LOG_DATE        	DATE,
		  LOG_TIME        	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  LOG_SEARCH_FOR  	text,
		  LOG_FOUNDITEMS  	INT,
		  LOG_SEARCH_FROM 	VARCHAR(50),
		  LOG_TIMESTAMP 	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  LOG_BROWSER 		text, 
		  LOG_IP 			VARCHAR(200),
		  HOST_ID			INT, 
		  PRIMARY KEY (LOG_ID),
		  KEY #arguments.thestruct.host_db_prefix#ls_user (log_user),
		  KEY #arguments.thestruct.host_db_prefix#ls_hostid (HOST_ID),
		  KEY #arguments.thestruct.host_db_prefix#ls_searchfrom (LOG_SEARCH_FROM)
		)
		#this.tableoptions#
		</cfquery>
				
		<!--- SETTINGS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings
		(
		  SET_ID    VARCHAR(500) NOT NULL,
		  SET_PREF  text,
		  HOST_ID	INT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#set_hostid (HOST_ID),
  		  KEY #arguments.thestruct.host_db_prefix#set_id (SET_ID),
		  FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- SETTINGS 2 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings_2
		(
		  SET2_ID                       INT NOT NULL,
		  SET2_DATE_FORMAT              VARCHAR(20),
		  SET2_DATE_FORMAT_DEL          VARCHAR(3),
		  SET2_META_KEYWORDS            text,
		  SET2_META_DESC                text,
		  SET2_META_AUTHOR              VARCHAR(200),
		  SET2_META_PUBLISHER           VARCHAR(200),
		  SET2_META_COPYRIGHT           VARCHAR(200),
		  SET2_META_ROBOTS              VARCHAR(200),
		  SET2_META_REVISIT             VARCHAR(200),
		  SET2_META_CUSTOM              text,
		  SET2_URL_SP_ORIGINAL          text,
		  SET2_URL_SP_THUMB             text,
		  SET2_URL_SP_COMP              text,
		  SET2_URL_SP_COMP_UW           text,
		  SET2_INTRANET_LOGO            VARCHAR(1),
		  SET2_URL_APP_SERVER           text,
		  SET2_ORA_PATH_INTERNAL        text,
		  SET2_CREATE_IMGFOLDERS_WHERE  INT,
		  SET2_IMG_FORMAT               VARCHAR(4),
		  SET2_IMG_THUMB_WIDTH          INT,
		  SET2_IMG_THUMB_HEIGTH         INT,
		  SET2_IMG_COMP_WIDTH           INT,
		  SET2_IMG_COMP_HEIGTH          INT,
		  SET2_IMG_DOWNLOAD_ORG         VARCHAR(2),
		  SET2_DOC_DOWNLOAD             VARCHAR(2),
		  SET2_INTRANET_REG_EMAILS      text,
		  SET2_INTRANET_REG_EMAILS_SUB  text,
		  SET2_INTRANET_GEN_DOWNLOAD    VARCHAR(2),
		  SET2_CAT_WEB                  VARCHAR(2),
		  SET2_CAT_INTRA                VARCHAR(2),
		  SET2_URL_WEBSITE              text,
		  SET2_PAYMENT_PRE              VARCHAR(2),
		  SET2_PAYMENT_BILL             VARCHAR(2),
		  SET2_PAYMENT_POD              VARCHAR(2),
		  SET2_PAYMENT_CC               VARCHAR(2),
		  SET2_PAYMENT_CC_CARDS         text,
		  SET2_PAYMENT_PAYPAL           VARCHAR(2),
		  SET2_PATH_IMAGEMAGICK         text,
		  SET2_EMAIL_SERVER             VARCHAR(200),
		  SET2_EMAIL_FROM               VARCHAR(200),
		  SET2_EMAIL_SMTP_USER          VARCHAR(200),
		  SET2_EMAIL_SMTP_PASSWORD      VARCHAR(200),
		  SET2_EMAIL_SERVER_PORT        INT,
		  SET2_EMAIL_USE_SSL			VARCHAR(5) DEFAULT 'false',
		  SET2_EMAIL_USE_TLS			VARCHAR(5) DEFAULT 'false',
		  SET2_ORA_PATH_INCOMING		text,
		  SET2_ORA_PATH_INCOMING_BATCH	text,
		  SET2_ORA_PATH_OUTGOING		text,
		  SET2_VID_PREVIEW_HEIGTH		INT,
		  SET2_VID_PREVIEW_WIDTH		INT,
		  SET2_PATH_FFMPEG				text,
		  SET2_VID_PREVIEW_TIME			VARCHAR(10),
		  SET2_VID_PREVIEW_START		VARCHAR(10),
		  SET2_URL_SP_VIDEO				text,
		  SET2_URL_SP_VIDEO_PREVIEW		text,
		  SET2_VID_PREVIEW_AUTHOR		VARCHAR(200),
		  SET2_VID_PREVIEW_COPYRIGHT	VARCHAR(200),
		  SET2_CAT_VID_WEB				VARCHAR(2),
		  SET2_CAT_VID_INTRA			VARCHAR(2),
		  SET2_CAT_AUD_WEB				VARCHAR(2),
		  SET2_CAT_AUD_INTRA			VARCHAR(2),
		  SET2_CREATE_VIDFOLDERS_WHERE	INT,
		  SET2_PATH_TO_ASSETS			text,
		  SET2_PATH_TO_EXIFTOOL         text,
		  SET2_NIRVANIX_NAME			VARCHAR(500),
		  SET2_NIRVANIX_PASS			VARCHAR(500),
		  HOST_ID						INT,
		  SET2_AWS_BUCKET				VARCHAR(100),
		  SET2_LABELS_USERS				text,
		  SET2_MD5CHECK					VARCHAR(5) DEFAULT 'false',
		  SET2_AKA_URL					VARCHAR(500),
		  SET2_AKA_IMG					VARCHAR(200),
		  SET2_AKA_VID					VARCHAR(200),
		  SET2_AKA_AUD					VARCHAR(200),
		  SET2_AKA_DOC					VARCHAR(200),
		  SET2_COLORSPACE_RGB			VARCHAR(5) DEFAULT 'false',
		  SET2_CUSTOM_FILE_EXT			VARCHAR(5) DEFAULT 'true',
		  SET2_RENDITION_METADATA		VARCHAR(5) DEFAULT 'false',
		  rec_uuid						VARCHAR(100),
		  SET2_UPC_ENABLED				VARCHAR(5) DEFAULT 'false',
		  SET2_NEW_USER_EMAIL_SUB  	VARCHAR(50),
		  SET2_NEW_USER_EMAIL_BODY  	VARCHAR(4000),
		  SET2_FOLDER_SUBSCRIBE_EMAIL_SUB  	VARCHAR(50),
		  SET2_FOLDER_SUBSCRIBE_EMAIL_BODY  	VARCHAR(1000),
		  SET2_ASSET_EXPIRY_EMAIL_SUB  	VARCHAR(50),
		  SET2_ASSET_EXPIRY_EMAIL_BODY  	VARCHAR(1000),
		  SET2_DUPLICATES_EMAIL_SUB  	VARCHAR(50),
		  SET2_DUPLICATES_EMAIL_BODY  	VARCHAR(2000),
		  SET2_DUPLICATES_META  	VARCHAR(2000),
		  SET2_FOLDER_SUBSCRIBE_META  	VARCHAR(2000),
		  SET2_ASSET_EXPIRY_META  	VARCHAR(2000),
		  SET2_META_EXPORT  	VARCHAR(1) DEFAULT 'f',
		  SET2_SAML_XMLPATH_EMAIL  	VARCHAR(100),
		  SET2_SAML_XMLPATH_PASSWORD  	VARCHAR(100),
		  SET2_SAML_HTTPREDIRECT  VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#set2_HOST_ID (HOST_ID),
  		  KEY #arguments.thestruct.host_db_prefix#set2_id (SET2_ID),
		  FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#temp
		(
		  TMP_TOKEN     VARCHAR(100),
		  TMP_FILENAME  text,
		  HOST_ID		INT
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- COLLECTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections
		(
		  col_id        	VARCHAR(100) NOT NULL,
		  folder_id_r   	VARCHAR(100) DEFAULT NULL,
		  col_owner     	VARCHAR(100),
		  create_date   	DATE,
		  create_time   	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  change_date   	DATE,
		  change_time   	TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		  col_template  	VARCHAR(100),
		  col_shared		VARCHAR(2) DEFAULT 'F',
		  col_name_shared	VARCHAR(200),
		  share_dl_org		varchar(1) DEFAULT 'f',
		  share_dl_thumb	varchar(1) DEFAULT 't',
     	  share_comments	varchar(1) DEFAULT 'f',
		  share_upload		varchar(1) DEFAULT 'f',
		  share_order		varchar(1) DEFAULT 'f',
		  share_order_user	VARCHAR(100),
		  col_released		VARCHAR(5) DEFAULT 'false',
		  col_copied_from	VARCHAR(100),
		  host_id			INT,
		  IN_TRASH		   	VARCHAR(2) DEFAULT 'F',
		PRIMARY KEY (COL_ID),
		KEY #arguments.thestruct.host_db_prefix#co_hostid (HOST_ID),
 		KEY #arguments.thestruct.host_db_prefix#co_fid_r (folder_id_r),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- COLLECTIONS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_text
		(
		  COL_ID_R      VARCHAR(100),
		  LANG_ID_R     INT,
		  COL_DESC      text,
		  COL_KEYWORDS  text,
		  COL_NAME      text,
		  HOST_ID		INT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#col_text_id (col_id_r),
		  KEY #arguments.thestruct.host_db_prefix#col_text_lang (LANG_ID_R),
		  FOREIGN KEY (COL_ID_R) REFERENCES #arguments.thestruct.host_db_prefix#collections (COL_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- COLLECTIONS FILES CROSS TABLE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_ct_files
		(
		  COL_ID_R       	VARCHAR(100),
		  FILE_ID_R      	VARCHAR(100),
		  COL_FILE_TYPE  	VARCHAR(5),
		  COL_ITEM_ORDER  	INT,
		  COL_FILE_FORMAT  	VARCHAR(100),
		  HOST_ID			INT,
		  rec_uuid			VARCHAR(100),
		  IN_TRASH		   	VARCHAR(2) DEFAULT 'F',
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#col_idr (col_id_r),
		  KEY #arguments.thestruct.host_db_prefix#col_fileid (file_id_r),
		  KEY #arguments.thestruct.host_db_prefix#col_filetype (COL_FILE_TYPE),
		  KEY #arguments.thestruct.host_db_prefix#col_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- COLLECTIONS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_groups
		(
		  COL_ID_R       	VARCHAR(100),
		  GRP_ID_R			VARCHAR(100),
		  GRP_PERMISSION	VARCHAR(2),
		  HOST_ID			INT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#cg_colid_r (col_id_r),
		  KEY #arguments.thestruct.host_db_prefix#cg_grpid_r (grp_id_r),
		  KEY #arguments.thestruct.host_db_prefix#cg_hostid (HOST_ID),
		  FOREIGN KEY (COL_ID_R) REFERENCES #arguments.thestruct.host_db_prefix#collections (COL_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- USER FAVORITES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_favorites
		(
		  USER_ID_R  VARCHAR(100),
		  FAV_TYPE   VARCHAR(8),
		  FAV_ID     VARCHAR(100),
		  FAV_KIND   VARCHAR(8),
		  FAV_ORDER  INT,
		  HOST_ID	 INT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  KEY #arguments.thestruct.host_db_prefix#uf_idr (user_id_r),
		  KEY #arguments.thestruct.host_db_prefix#uf_id (fav_id),
		  KEY #arguments.thestruct.host_db_prefix#uf_hostid (HOST_ID),
		  FOREIGN KEY (USER_ID_R) REFERENCES users (USER_ID) ON DELETE SET NULL
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- VIDEOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos
		(
		VID_ID					VARCHAR(100),
		VID_FILENAME			VARCHAR(500),
		FOLDER_ID_R				VARCHAR(100) DEFAULT NULL,
		VID_CUSTOM_ID			VARCHAR(500),
		VID_ONLINE				VARCHAR(2),
		VID_OWNER				VARCHAR(100),
		VID_CREATE_DATE			DATE,
		VID_CREATE_TIME			TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		VID_CHANGE_DATE			DATE,
		VID_CHANGE_TIME			TIMESTAMP DEFAULT '0000-00-00 00:00:00',
		VID_RANKING				INT,
		VID_SINGLE_SALE			VARCHAR(2),
		VID_IS_NEW				VARCHAR(2),
		VID_SELECTION			VARCHAR(2),
		VID_IN_PROGRESS			VARCHAR(2),
		VID_LICENSE				VARCHAR(200),
		VID_CATEGORY_ONE		text,
		VID_REMARKS				longtext,
		VID_WIDTH				INT,
		VID_HEIGHT				INT,
		VID_FRAMERESOLUTION		INT,
		VID_FRAMERATE			INT,
		VID_VIDEODURATION		INT,
		VID_COMPRESSIONTYPE		text,
		VID_BITRATE				INT,
		VID_EXTENSION			VARCHAR(20),
		VID_MIMETYPE			text,
		VID_PREVIEW_WIDTH		INT,
		VID_PREVIEW_HEIGTH		INT,
		VID_GROUP				VARCHAR(100) DEFAULT NULL,
		VID_PUBLISHER			VARCHAR(200),
		VID_NAME_ORG			VARCHAR(200),
		VID_NAME_IMAGE			VARCHAR(200),
		VID_NAME_PRE			VARCHAR(200),
		VID_NAME_PRE_IMG		VARCHAR(200),
	 	VID_SIZE                VARCHAR(100),
	 	VID_PREV_SIZE           VARCHAR(100),
	 	LUCENE_KEY		   		VARCHAR(2000),
	 	SHARED			  		VARCHAR(2) DEFAULT 'F',
	 	LINK_KIND				VARCHAR(20),
		LINK_PATH_URL			VARCHAR(2000),
		VID_META				LONGTEXT,
		HOST_ID					INT,
		PATH_TO_ASSET		    VARCHAR(500),
		CLOUD_URL			    VARCHAR(500),
		CLOUD_URL_ORG		    VARCHAR(500),
		HASHTAG			   		VARCHAR(100),
		IS_AVAILABLE		    VARCHAR(1) DEFAULT 0,
		CLOUD_URL_EXP		    INT,
		IN_TRASH		   		VARCHAR(2) DEFAULT 'F',
		IS_INDEXED		  		VARCHAR(1) DEFAULT 0,
		VID_UPC_NUMBER 			VARCHAR(15),
		EXPIRY_DATE DATE,
		PRIMARY KEY (VID_ID),
		KEY #arguments.thestruct.host_db_prefix#vid_group (vid_group),
	    KEY #arguments.thestruct.host_db_prefix#vid_folderid (folder_id_r),
	    KEY #arguments.thestruct.host_db_prefix#vid_pathtoasset (PATH_TO_ASSET),
	    KEY #arguments.thestruct.host_db_prefix#vid_hostid (HOST_ID),
	    KEY #arguments.thestruct.host_db_prefix#vid_owner (vid_owner),
	    KEY #arguments.thestruct.host_db_prefix#vid_hash (HASHTAG),
		FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- VIDEOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos_text
		(
		  ID_INC		   VARCHAR(100),
		  VID_ID_R         VARCHAR(100) NOT NULL,
		  LANG_ID_R        INT NOT NULL,
		  VID_KEYWORDS     text,
		  VID_DESCRIPTION  text,
		  VID_TITLE		   text,
		  HOST_ID				INT,
		PRIMARY KEY (ID_INC),
		KEY #arguments.thestruct.host_db_prefix#vt_idr (vid_id_r),
		KEY #arguments.thestruct.host_db_prefix#vt_lang (LANG_ID_R),
		KEY #arguments.thestruct.host_db_prefix#vt_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- SCHEDULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules
		(
			SCHED_ID 			 VARCHAR(100) NOT NULL,
			SET2_ID_R 			 INT,
			SCHED_USER 			 VARCHAR(100),
			SCHED_STATUS 		 VARCHAR(1) DEFAULT 1,
			SCHED_METHOD 		 VARCHAR(10),
			SCHED_NAME 			 VARCHAR(255),
			SCHED_FOLDER_ID_R    VARCHAR(100),
			SCHED_ZIP_EXTRACT 	 INT,
			SCHED_SERVER_FOLDER  text,
			SCHED_SERVER_RECURSE INT DEFAULT 1,
			SCHED_SERVER_FILES   INT DEFAULT 0,
			SCHED_MAIL_POP 		 VARCHAR(255),
			SCHED_MAIL_USER 	 VARCHAR(255),
			SCHED_MAIL_PASS 	 VARCHAR(255),
			SCHED_MAIL_SUBJECT 	 VARCHAR(255),
			SCHED_FTP_SERVER 	 VARCHAR(255),
			SCHED_FTP_USER 		 VARCHAR(255),
			SCHED_FTP_PASS 		 VARCHAR(255),
			SCHED_FTP_PASSIVE    INT DEFAULT 0,
			SCHED_FTP_FOLDER 	 VARCHAR(255),
			SCHED_INTERVAL       VARCHAR(255),
			SCHED_START_DATE     DATE,
			SCHED_START_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			SCHED_END_DATE       DATE,
			SCHED_END_TIME       TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			HOST_ID				 INT,
			SCHED_FTP_EMAIL       VARCHAR(500),
			sched_upl_template	 VARCHAR(100),
			sched_ad_user_groups text,
			PRIMARY KEY (SCHED_ID),
			KEY #arguments.thestruct.host_db_prefix#sched_user (SCHED_USER),
	  		KEY #arguments.thestruct.host_db_prefix#sched_hostid (HOST_ID),
			FOREIGN KEY (SCHED_USER) REFERENCES users (USER_ID) ON DELETE SET NULL,
			FOREIGN KEY (HOST_ID) REFERENCES #arguments.thestruct.theschema#.hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- SCHEDULES_LOG --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		 CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules_log
		(
			SCHED_LOG_ID        VARCHAR(100) NOT NULL,
			SCHED_ID_R          VARCHAR(100),
			SCHED_LOG_USER      VARCHAR(100),
			SCHED_LOG_ACTION    VARCHAR(10),
			SCHED_LOG_DATE      DATE,
			SCHED_LOG_TIME      TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			SCHED_LOG_DESC      text,
			HOST_ID				INT,
			NOTIFIED    VARCHAR(5),
		PRIMARY KEY (SCHED_LOG_ID),
		KEY #arguments.thestruct.host_db_prefix#sched_idr (sched_id_r),
  		KEY #arguments.thestruct.host_db_prefix#schedl_hostid (HOST_ID),
  		KEY #arguments.thestruct.host_db_prefix#sched_logtime(SCHED_LOG_TIME),
  		KEY #arguments.thestruct.host_db_prefix#notified(sched_id_r, notified),
		FOREIGN KEY (SCHED_ID_R) REFERENCES #arguments.thestruct.host_db_prefix#schedules (SCHED_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- CUSTOM FIELDS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields
		(
			cf_id 			VARCHAR(100), 
			cf_type	 		VARCHAR(20), 
			cf_order 		INT, 
			cf_enabled 		VARCHAR(2), 
			cf_show			VARCHAR(10),
			cf_group 		VARCHAR(100),
			cf_select_list	TEXT,
			cf_in_form		VARCHAR(10) DEFAULT 'true',
			cf_edit			VARCHAR(2000) DEFAULT 'true',
			HOST_ID			INT,
			cf_xmp_path		VARCHAR(500),
			PRIMARY KEY (cf_id),
			KEY #arguments.thestruct.host_db_prefix#cf_enabled (cf_enabled),
   		    KEY #arguments.thestruct.host_db_prefix#cf_show (cf_show),
		    KEY #arguments.thestruct.host_db_prefix#cf_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_text
		(
			cf_id_r			VARCHAR(100), 
			lang_id_r 		INT, 
			cf_text			text,
			HOST_ID			INT,
			rec_uuid			VARCHAR(100),
			PRIMARY KEY (rec_uuid),
			KEY #arguments.thestruct.host_db_prefix#cft_id (cf_id_r),
			KEY #arguments.thestruct.host_db_prefix#cft_lang (lang_id_r),
			KEY #arguments.thestruct.host_db_prefix#cft_hostid (HOST_ID),
			FOREIGN KEY (cf_id_r) REFERENCES #arguments.thestruct.host_db_prefix#custom_fields (cf_id) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_values
		(
			cf_id_r			VARCHAR(100), 
			asset_id_r 		VARCHAR(100), 
			cf_value		text,
			HOST_ID			INT,
			rec_uuid			VARCHAR(100),
			PRIMARY KEY (rec_uuid),
			KEY #arguments.thestruct.host_db_prefix#cfv_idr (cf_id_r),
		    KEY #arguments.thestruct.host_db_prefix#cfv_hostid (HOST_ID),
		    KEY #arguments.thestruct.host_db_prefix#cfv_assetid (asset_id_r),
			FOREIGN KEY (cf_id_r) REFERENCES #arguments.thestruct.host_db_prefix#custom_fields (cf_id) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#comments
		(
			COM_ID			VARCHAR(100),
			ASSET_ID_R		VARCHAR(100),
			ASSET_TYPE		VARCHAR(10),
			USER_ID_R		VARCHAR(100),
			COM_TEXT		TEXT,
			COM_DATE		TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			HOST_ID			INT,
			PRIMARY KEY (COM_ID),
			KEY #arguments.thestruct.host_db_prefix#co_assettype (ASSET_TYPE),
  			KEY #arguments.thestruct.host_db_prefix#co_idr (asset_id_r)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#versions
		(
			asset_id_r			VARCHAR(100),
			ver_version			INT DEFAULT NULL,
			ver_type			VARCHAR(5),
			ver_date_add		TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			ver_who				VARCHAR(100),
			ver_filename_org 	VARCHAR(200),
			ver_extension	 	VARCHAR(20),
			thumb_width			INT,
			thumb_height		INT,
			img_width			INT,
			img_height			INT,
			img_size			VARCHAR(100),
			thumb_size			VARCHAR(100),
			vid_size			VARCHAR(100),
			vid_width			INT,
			vid_height			INT,
			vid_name_image		VARCHAR(200),
			HOST_ID				INT,
			cloud_url_org		VARCHAR(500),
			ver_thumbnail		VARCHAR(200),
			meta_data			LONGTEXT,
			hashtag				VARCHAR(100),
			rec_uuid			VARCHAR(100),
			cloud_url_thumb		VARCHAR(500),
			file_size			VARCHAR(100),
			PRIMARY KEY (rec_uuid)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- TRANSLATIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#languages
		(
			lang_id			INT NOT NULL,
			lang_name		VARCHAR(100),
			lang_active		VARCHAR(2) default 'f',
			HOST_ID			INT,
			rec_uuid			VARCHAR(100),
			PRIMARY KEY (rec_uuid),
			UNIQUE KEY  UNIQUE_HOSTID_LANGID (lang_id,HOST_ID),
			KEY #arguments.thestruct.host_db_prefix#l_active (lang_active),
  			KEY #arguments.thestruct.host_db_prefix#l_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- AUDIOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios
		(
			aud_ID              VARCHAR(100),
			FOLDER_ID_R         VARCHAR(100) DEFAULT NULL,
			aud_CREATE_DATE     DATE,
			aud_CREATE_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			aud_CHANGE_DATE     DATE,
			aud_CHANGE_TIME     TIMESTAMP DEFAULT '0000-00-00 00:00:00',
			aud_OWNER           VARCHAR(100),
			aud_TYPE            VARCHAR(5),
			aud_NAME            VARCHAR(500),
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
			aud_meta			LONGTEXT,
			LINK_KIND			VARCHAR(20),
		    LINK_PATH_URL		VARCHAR(2000),
		    HOST_ID				INT,
		    PATH_TO_ASSET		VARCHAR(500),
		    CLOUD_URL			VARCHAR(500),
		    CLOUD_URL_2		    VARCHAR(500),
		  	CLOUD_URL_ORG		VARCHAR(500),
		  	HASHTAG			    VARCHAR(100),
		  	IS_AVAILABLE		VARCHAR(1) DEFAULT 0,
		  	CLOUD_URL_EXP		INT,
		  	IN_TRASH		   	VARCHAR(2) DEFAULT 'F',
		  	IS_INDEXED		 	VARCHAR(1) DEFAULT 0,
		  	AUD_UPC_NUMBER		VARCHAR(15),
		  	EXPIRY_DATE DATE,
			PRIMARY KEY (aud_ID),
			KEY #arguments.thestruct.host_db_prefix#aud_hostid (HOST_ID),
	     		KEY #arguments.thestruct.host_db_prefix#aud_folderid (folder_id_r),
			KEY #arguments.thestruct.host_db_prefix#aud_group (aud_group),
			KEY #arguments.thestruct.host_db_prefix#aud_pathtoasset (PATH_TO_ASSET),
			KEY #arguments.thestruct.host_db_prefix#aud_hashtag (HASHTAG),
			FOREIGN KEY (HOST_ID) REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- AUDIOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios_text
		(
			id_inc				VARCHAR(100),
			aud_ID_R			VARCHAR(100),
			LANG_ID_R			INT,
			aud_DESCRIPTION     TEXT,
			aud_KEYWORDS		TEXT,
			HOST_ID				INT,
			PRIMARY KEY (id_inc),
			KEY #arguments.thestruct.host_db_prefix#at_idr (aud_id_r),
		    KEY #arguments.thestruct.host_db_prefix#at_lang (LANG_ID_R),
		    KEY #arguments.thestruct.host_db_prefix#at_hostid (HOST_ID)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- SHARE OPTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options
		(
			asset_id_r		VARCHAR(100),
			host_id			int,
			group_asset_id	VARCHAR(100),
			folder_id_r		VARCHAR(100),
			asset_type		varchar(6),
			asset_format	varchar(100),
			asset_dl		varchar(1) DEFAULT '0',
			asset_order		varchar(1) DEFAULT '0',
			asset_selected	varchar(1) DEFAULT '0',
			rec_uuid			VARCHAR(100),
			PRIMARY KEY (rec_uuid),
			KEY #arguments.thestruct.host_db_prefix#so_hostid (host_id),
		    KEY #arguments.thestruct.host_db_prefix#so_asset_type (asset_type),
		    KEY #arguments.thestruct.host_db_prefix#so_folderid (folder_id_r),
		    KEY #arguments.thestruct.host_db_prefix#so_assetselected (asset_selected),
		    KEY #arguments.thestruct.host_db_prefix#so_groupid (group_asset_id),
		    KEY #arguments.thestruct.host_db_prefix#so_assetidr (asset_id_r),
		    KEY #arguments.thestruct.host_db_prefix#so_format (asset_format)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- ERRORS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#errors
		(
			id				int,
			err_header		varchar(2000),
			err_text		TEXT,
			err_date		timestamp DEFAULT '0000-00-00 00:00:00',
			host_id			int,
			PRIMARY KEY (id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Upload Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates 
		(
		  	upl_temp_id			varchar(100) NOT NULL,
		  	upl_date_create 	timestamp NULL DEFAULT NULL,
		  	upl_date_update		timestamp NULL DEFAULT NULL,
		  	upl_who				varchar(100) DEFAULT NULL,
		  	upl_active			VARCHAR(1) DEFAULT '0',
		  	host_id				int DEFAULT NULL,
		  	upl_name			varchar(200) DEFAULT NULL,
		  	upl_description		varchar(2000) DEFAULT NULL,
		  	PRIMARY KEY (upl_temp_id),
		  	KEY #arguments.thestruct.host_db_prefix#ut_active (upl_active),
  			KEY #arguments.thestruct.host_db_prefix#ut_hostid (host_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Upload Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates_val
		(
		  	upl_temp_id_r		varchar(100) NOT NULL,
		  	upl_temp_field		varchar(300) DEFAULT NULL,
		  	upl_temp_value		varchar(100) DEFAULT NULL,
		  	upl_temp_type		varchar(5) DEFAULT NULL,
		  	upl_temp_format		varchar(10) DEFAULT NULL,
		  	host_id				int DEFAULT NULL,
		  	rec_uuid			VARCHAR(100),
		  	PRIMARY KEY (rec_uuid),
		  	KEY #arguments.thestruct.host_db_prefix#utv_idr (upl_temp_id_r),
  			KEY #arguments.thestruct.host_db_prefix#utv_hostid (host_id)	
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- CREATE WIDGETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#widgets 
		(
		  widget_id				varchar(100),
		  col_id_r				varchar(100),
		  folder_id_r			varchar(100),
		  widget_name			varchar(200),
		  widget_description	varchar(1000),
		  widget_permission 	varchar(2),
		  widget_password 		varchar(100),
		  widget_style 			varchar(2),
		  widget_dl_org 		varchar(2),
		  widget_dl_thumb 		varchar(2) DEFAULT 't',
		  widget_uploading 		varchar(2),
		  host_id 				int,
		  PRIMARY KEY (widget_id),
		  KEY #arguments.thestruct.host_db_prefix#w_folderid (folder_id_r),
		  KEY #arguments.thestruct.host_db_prefix#w_hostid (host_id),
		  KEY #arguments.thestruct.host_db_prefix#w_colid (col_id_r)
		) 
		#this.tableoptions#
		</cfquery>
		
		<!--- Additional Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#additional_versions (
		  av_id					varchar(100),
		  asset_id_r			varchar(100),
		  folder_id_r			varchar(100),
		  av_type				varchar(45),
		  av_link_title			varchar(200),
		  av_link_url 			varchar(500),
		  host_id 				int,
		  av_link 				varchar(2) DEFAULT '1',
		  thesize 				varchar(100) DEFAULT '0',
  		  thewidth 				varchar(50) DEFAULT '0',
  		  theheight				varchar(50) DEFAULT '0',
  		  hashtag			   	VARCHAR(100),
  		  av_thumb_url			varchar(500),
		  PRIMARY KEY (av_id),
		  KEY #arguments.thestruct.host_db_prefix#av_id_r (asset_id_r),
		  KEY #arguments.thestruct.host_db_prefix#av_fid_r (folder_id_r),
		  KEY #arguments.thestruct.host_db_prefix#av_link (av_link),
		  KEY #arguments.thestruct.host_db_prefix#av_hostid (host_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Files XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_xmp (
		  asset_id_r 			varchar(100),
		  author 				varchar(200),
		  rights 				varchar(1000),
		  authorsposition 		varchar(200),
		  captionwriter 		varchar(300),
		  webstatement 			varchar(500),
		  rightsmarked 			varchar(10),
		  host_id 				int,
		  PRIMARY KEY (asset_id_r),
		  KEY #arguments.thestruct.host_db_prefix#files_xmp_hostid (host_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Labels --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#labels (
		label_id 		varchar(100),
  		label_text 		varchar(200),
  		label_date		timestamp DEFAULT '0000-00-00 00:00:00',
  		user_id			varchar(100),
  		host_id			int,
  		label_id_r		varchar(100),
  		label_path		varchar(500),
  		PRIMARY KEY (label_id),
  		KEY #arguments.thestruct.host_db_prefix#labels_id (label_id),
  		KEY #arguments.thestruct.host_db_prefix#labels_text (label_text)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Import Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#import_templates (
		imp_temp_id 		varchar(100),
  		imp_date_create	 	timestamp DEFAULT '0000-00-00 00:00:00',
  		imp_date_update		timestamp DEFAULT '0000-00-00 00:00:00',
  		imp_who				varchar(100),
  		imp_active 			varchar(1) DEFAULT '0',
  		host_id				int,
  		imp_name			varchar(200),
  		imp_description 	varchar(2000),
  		PRIMARY KEY (imp_temp_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Import Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#import_templates_val (
  		imp_temp_id_r		varchar(100),
  		rec_uuid			varchar(100),
  		imp_field			varchar(200),
  		imp_map				varchar(200),
  		host_id				int,
  		imp_key				int,
  		PRIMARY KEY (rec_uuid)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Customization --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom (
	  	custom_id			varchar(200),
		custom_value		varchar(2000),
		host_id				int,
		KEY #arguments.thestruct.host_db_prefix#custom_id (custom_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- RAZ-2831 : Metadata export template --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#export_template (
	  	exp_id				varchar(100),
		exp_field			varchar(200),
		exp_value			varchar(2000),
		exp_timestamp		timestamp default '0000-00-00 00:00:00',
		user_id				varchar(100),
		host_id				int,
		PRIMARY KEY (exp_id)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Social accounts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_accounts (
	  	identifier			varchar(200),
		provider			varchar(100),
		user_id_r			varchar(100),
		jr_identifier		varchar(500),
		profile_pic_url		varchar(1000),
		host_id				int
		)
		#this.tableoptions#
		</cfquery>

		<!--- Watermark --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#wm_templates (
	  	wm_temp_id 			varchar(100),
	  	wm_name				varchar(200),
		wm_active			varchar(6) DEFAULT 'false',
		host_id 			int,
		PRIMARY KEY (wm_temp_id)
		)
		#this.tableoptions#
		</cfquery>

		<!--- Watermark values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#wm_templates_val (
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
		host_id 			int,
		rec_uuid 			varchar(100),
		PRIMARY KEY (rec_uuid)
		)
		#this.tableoptions#
		</cfquery>

		<!--- Smart Folders --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#smart_folders 
		(
			sf_id 			varchar(100),
			sf_name 		varchar(500),
			sf_date_create 	timestamp DEFAULT '0000-00-00 00:00:00',
			sf_date_update 	timestamp DEFAULT '0000-00-00 00:00:00',
			sf_type 		varchar(100),
			sf_description 	varchar(2000),
			sf_who	 		varchar(100),
			sf_zipextract	 	varchar(1),
			host_id 		int,
			PRIMARY KEY (sf_id)
		)
		#this.tableoptions#
		</cfquery>

		<!--- Smart Folders Properties --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#smart_folders_prop
		(
			sf_id_r 		varchar(100),
			sf_prop_id 		varchar(500),
			sf_prop_value 	varchar(2000),
			host_id 		int,
			PRIMARY KEY (sf_id_r)
		)
		#this.tableoptions#
		</cfquery>
		
		<!--- Folder subscribe --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folder_subscribe
		(
			fs_id  						varchar(100) NOT NULL,
			host_id 					int DEFAULT NULL,
			folder_id 					varchar(100) DEFAULT NULL,
			user_id						varchar(100) DEFAULT NULL,
			mail_interval_in_hours		int(6) DEFAULT NULL,
			last_mail_notification_time timestamp DEFAULT '0000-00-00 00:00:00',
			asset_keywords				varchar(3) DEFAULT 'F',
			asset_description			varchar(3) DEFAULT 'F',
			auto_entry	varchar(5) DEFAULT 'false',
			PRIMARY KEY (fs_id),
			KEY folder_id (folder_id),
  			KEY user_id (user_id)
		)
		#this.tableoptions#
		</cfquery>
		
	</cffunction>
	
	<!--- Clear database completely --->
	<cffunction name="clearall" access="public" output="false">
		<!--- Query Tables --->
		<cfquery datasource="#session.firsttime.database#" name="qrytables">
		SELECT table_name
		FROM information_schema.tables
		WHERE table_schema = '#session.firsttime.db_schema#'
		</cfquery>
		<!--- Loop and drop tables --->
		<cfloop query="qrytables">			
			<cfquery datasource="#session.firsttime.database#">
			SET foreign_key_checks = 0
			</cfquery>
			<cftry>
				<cfquery datasource="#session.firsttime.database#">
				DROP TABLE #table_name#
				</cfquery>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
		<cfreturn />
	</cffunction>
		
</cfcomponent>