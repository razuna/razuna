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
		
		<!--- If we come from import then dont do this --->
		<cfif NOT structkeyexists(arguments.thestruct,"fromimport")>
			<!--- Create the DB on the filesystem --->
			<cfinvoke method="BDsetDatasource">
				<cfinvokeargument name="name" value="h2" />
				<cfinvokeargument name="databasename" value="h2" />
				<cfinvokeargument name="logintimeout" value="120" />
				<cfinvokeargument name="initstring" value="" />
				<cfinvokeargument name="connectionretries" value="0" />
				<cfinvokeargument name="connectiontimeout" value="120" />
				<cfinvokeargument name="username" value="razuna" />
				<cfinvokeargument name="password" value="razunadb" />
				<cfinvokeargument name="sqlstoredprocedures" value="true" />
				<cfinvokeargument name="hoststring" value="jdbc:h2:#arguments.thestruct.pathoneup#db/razuna;IGNORECASE=TRUE;MODE=Oracle;AUTO_RECONNECT=TRUE;LOG=0;CACHE_SIZE=300000;AUTO_SERVER=TRUE" />
				<cfinvokeargument name="sqlupdate" value="true" />
				<cfinvokeargument name="sqlselect" value="true" />
				<cfinvokeargument name="sqlinsert" value="true" />
				<cfinvokeargument name="sqldelete" value="true" />
				<cfinvokeargument name="perrequestconnections" value="false" />
				<cfinvokeargument name="drivername" value="org.h2.Driver" />
				<cfinvokeargument name="maxconnections" value="24" />
			</cfinvoke>
		</cfif>
		
		<!---  --->
		<!--- START: CREATE TABLES --->
		<!---  --->
		
		<!--- CREATE SEQUENCES
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE sequences 
		(
			theid		VARCHAR(100), 
			thevalue	BIGINT NOT NULL,
			CONSTRAINT SEQUENCES_PK PRIMARY KEY (theid)
		) 
		</cfquery>
		 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE cache 
		(
			cache_token varchar(100) DEFAULT NULL,
			cache_type varchar(20) DEFAULT NULL,
			host_id bigint DEFAULT NULL
		)
		</cfquery>
		<!--- CREATE MODULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE modules 
		(
			MOD_ID 			BIGINT NOT NULL, 
			MOD_NAME 		VARCHAR(50) NOT NULL, 
			MOD_SHORT 		VARCHAR(3) NOT NULL, 
			MOD_HOST_ID 	BIGINT DEFAULT NULL, 
			CONSTRAINT MODULES_PK PRIMARY KEY (MOD_ID), 
			CONSTRAINT MODULES_UK1 UNIQUE (MOD_NAME, MOD_SHORT, MOD_HOST_ID)
		)
		</cfquery>
		<!--- CREATE PERMISSION --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE permissions 
		(
			PER_ID 			BIGINT NOT NULL, 
			PER_KEY  		VARCHAR(50) NOT NULL, 
			PER_HOST_ID 	BIGINT DEFAULT NULL, 
			PER_ACTIVE 		BIGINT DEFAULT 1 NOT NULL, 
			PER_MOD_ID 		BIGINT NOT NULL,
			PER_LEVEL		VARCHAR(10),
			CONSTRAINT PERMISSIONS_PK PRIMARY KEY (PER_ID), 
			CONSTRAINT PERMISSIONS_FK_MODULES FOREIGN KEY (PER_MOD_ID)
			REFERENCES modules (MOD_ID)
		)
		</cfquery>
		<!--- CREATE GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE groups
		(	
			GRP_ID 				VARCHAR(100) NOT NULL, 
			GRP_NAME 			VARCHAR(50), 
			GRP_HOST_ID 		BIGINT DEFAULT NULL, 
			GRP_MOD_ID 			BIGINT NOT NULL, 
			GRP_TRANSLATION_KEY VARCHAR(50),
			UPC_SIZE 			VARCHAR(2) DEFAULT NULL,
			UPC_FOLDER_FORMAT	VARCHAR(5) DEFAULT 'false',
			FOLDER_SUBSCRIBE	VARCHAR(5) DEFAULT 'false',
			FOLDER_REDIRECT VARCHAR(100),
			CONSTRAINT GROUPS_PK PRIMARY KEY (GRP_ID), 
			CONSTRAINT GROUPS_FK_MODULES FOREIGN KEY (GRP_MOD_ID)
			REFERENCES modules (MOD_ID)
		)
		</cfquery>
		<!--- CREATE HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE hosts 
		(
		  HOST_ID           BIGINT NOT NULL,
		  HOST_NAME         VARCHAR(100),
		  HOST_PATH         VARCHAR(50),
		  HOST_CREATE_DATE  DATE,
		  HOST_DB_PREFIX    VARCHAR(40),
		  HOST_LANG         BIGINT,
		  HOST_TYPE			VARCHAR(2) DEFAULT 'F',
		  HOST_SHARD_GROUP	VARCHAR(10),
		  HOST_NAME_CUSTOM  VARCHAR(200),
		  CONSTRAINT HOSTS_PK PRIMARY KEY (HOST_ID)
		)
		</cfquery>
		<!--- CREATE USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE users 
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
		  USER_API_KEY		   VARCHAR(100),
		  USER_EXPIRY_DATE	   DATE,
		  user_search_selection VARCHAR(100),
		CONSTRAINT USERS_PK PRIMARY KEY (USER_ID)
		)
		</cfquery>
		<!--- CREATE CT_GROUPS_USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_groups_users
		(	
		CT_G_U_GRP_ID 		VARCHAR(100) NOT NULL, 
		CT_G_U_USER_ID 		VARCHAR(100) NOT NULL,
		rec_uuid			VARCHAR(100),
		PRIMARY KEY (rec_uuid),
		CONSTRAINT CT_GROUPS_USERS_UK1 UNIQUE (CT_G_U_GRP_ID, CT_G_U_USER_ID), 
		CONSTRAINT CT_GROUPS_USERS_GROUPS_FK1 FOREIGN KEY (CT_G_U_GRP_ID)
		REFERENCES groups (GRP_ID)
		)
		</cfquery>
		<!--- CREATE CT_GROUPS_PERMISSIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_groups_permissions
		(	
		CT_G_P_PER_ID 		BIGINT NOT NULL, 
		CT_G_P_GRP_ID 		VARCHAR(100) NOT NULL, 
		CONSTRAINT CT_GROUPS_PERMISSIONS_UK1 UNIQUE (CT_G_P_PER_ID, CT_G_P_GRP_ID), 
		CONSTRAINT CT_GROUPS_PERMISSIONS_FK2 FOREIGN KEY (CT_G_P_PER_ID)
		REFERENCES permissions (PER_ID), 
		CONSTRAINT CT_GROUPS_PERMISSIONS_FK1 FOREIGN KEY (CT_G_P_GRP_ID)
		REFERENCES groups (GRP_ID)
		)
		</cfquery>
		<!--- CREATE LOG_ACTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE log_actions 
		(
		  LOG_ACT_ID    BIGINT,
		  LOG_ACT_TEXT  VARCHAR(200),
		  CONSTRAINT LOG_ACTIONS_PK PRIMARY KEY (LOG_ACT_ID)
		)
		</cfquery>
		<!--- CREATE CT_USERS_HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_users_hosts 
		(
		  CT_U_H_USER_ID  VARCHAR(100),
		  CT_U_H_HOST_ID  BIGINT,
		  rec_uuid		  VARCHAR(100),
		  PRIMARY KEY (rec_uuid)
		)
		</cfquery>
		<!--- CREATE USERS_LOGIN --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE users_login 
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
		CREATE TABLE wisdom 
		(
		  WIS_ID      BIGINT,
		  WIS_TEXT    VARCHAR(3000),
		  WIS_AUTHOR  VARCHAR(200),
		  CONSTRAINT WISDOM_PK PRIMARY KEY (WIS_ID)
		)
		</cfquery>
		<!--- CREATE USERS_COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE users_comments
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
		<!--- CREATE file_types --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE file_types
		(
		  TYPE_ID              VARCHAR(10) CONSTRAINT FILE_TYPE_PK PRIMARY KEY,
		  TYPE_TYPE            VARCHAR(3),
		  TYPE_MIMECONTENT     VARCHAR(50),
		  TYPE_MIMESUBCONTENT  VARCHAR(50)
		)
		</cfquery>
		<!--- CREATE CT_USERS_REMOTEUSERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_users_remoteusers
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
			CT_U_RU_CONFIRMED         BIGINT DEFAULT 0 NOT NULL, 
		CONSTRAINT CT_USERS_REMOTEUSERS_PK PRIMARY KEY (CT_U_RU_ID),
		CONSTRAINT CT_USERS_REMOTEUSERS_UK1 UNIQUE (CT_U_RU_USER_ID, CT_U_RU_REMOTE_URL, CT_U_RU_REMOTE_USER_ID),
		CONSTRAINT CT_USERS_REMOTEUSERS_UK2 UNIQUE (CT_U_RU_UUID),
		CONSTRAINT CT_USERS_REMOTEUSERS_USER_FK1 FOREIGN KEY (CT_U_RU_USER_ID)
		REFERENCES users (USER_ID) ON DELETE CASCADE
		)
		</cfquery>
		<!--- CREATE WEBSERVICES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE webservices
		(
			SESSIONTOKEN 	VARCHAR(100), 
			TIMEOUT 		TIMESTAMP,
			GROUPOFUSER		VARCHAR(2000),
			USERID			VARCHAR(100), 
		CONSTRAINT WEBSERVICES_PK PRIMARY KEY (SESSIONTOKEN)
		)
		</cfquery>
		<!--- CREATE SEARCH REINDEX --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE search_reindex
		(
			theid			VARCHAR(100),
			thevalue		INT,
			thehostid		INT,
			datetime		TIMESTAMP
		)
		</cfquery>
		<!--- CREATE TOOLS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE tools
		(
			thetool			VARCHAR(100),
			thepath			VARCHAR(200),
			CONSTRAINT TOOLS_PK PRIMARY KEY (thetool)
		)
		</cfquery>
		<!--- CREATE CT_LABELS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_labels
		(
			ct_label_id 	varchar(100),
		 	ct_id_r 		varchar(100),
		 	ct_type 		varchar(100),
		 	rec_uuid		VARCHAR(100),
		 	PRIMARY KEY(rec_uuid)
		)
		</cfquery>
		<!--- CREATE RFS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE rfs
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
			rfs_date_change timestamp,
			PRIMARY KEY (rfs_id)
		)
		</cfquery>

		<!--- ct_plugins_hosts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_plugins_hosts
		(
			ct_pl_id_r		varchar(100),
		  	ct_host_id_r	BIGINT,
		  	rec_uuid		varchar(100)
		)
		</cfquery>

		<!--- plugins --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE plugins
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
		</cfquery>
		
		<!--- plugins_actions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE plugins_actions
		(
			action 			varchar(200),
  			comp 			varchar(200),
  			func 			varchar(200),
  			args 			clob,
  			p_id 			varchar(100),
  			p_remove		varchar(10),
  			host_id 		bigint
		)
		</cfquery>

		<!--- options --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE options
		(
			opt_id			varchar(100),
			opt_value		clob,
			rec_uuid		varchar(100)
		)
		</cfquery>

		<!--- news --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE news
		(
			news_id			varchar(100),
			news_title		varchar(500),
			news_active		varchar(6),
			news_text		clob,
			news_date		varchar(20),
			host_id 		bigint default 0,
			PRIMARY KEY (news_id)
		)
		</cfquery>
		
		<!--- ct_aliases --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_aliases
		(
			asset_id_r 		varchar(100) DEFAULT NULL,
			folder_id_r 	varchar(100) DEFAULT NULL,
			type 			varchar(10) DEFAULT NULL,
			rec_uuid 		varchar(100) DEFAULT NULL
		)
		</cfquery>

		<!--- folder_subscribe_groups --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		  CREATE TABLE #arguments.thestruct.host_db_prefix#folder_subscribe_groups (
		  folder_id varchar(100) DEFAULT NULL,
		  group_id varchar(100) DEFAULT NULL
		) 
		</cfquery>

		<!---  --->
		<!--- END: CREATE TABLES --->
		<!---  --->
		<cfif NOT structkeyexists(arguments.thestruct,"fromimport")>
			<!---  --->
			<!--- START: INSERT VALUES --->
			<!--- 
			
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('categories_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('collection_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('content_id_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ct_users_remoteusers_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ctuag_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ctug_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('ctuh_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('file_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('folder_seq', 3)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('groupsadmin_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('groups_seq', 3)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('hostid_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('img_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('keywords_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('log_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('menuesid_seq', 5)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('permissions_seq', 12)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('pub_grp_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('pub_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('schedule_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('sched_log_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('userlogin_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('users_lists_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('users_seq', 5)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('user_ship_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('valuelist_seq', 0)
			</cfquery>
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO sequences
			(theid, thevalue)
			VALUES('customfield_seq', 0)
			</cfquery>
			 --->
			<!--- USERS --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO users
			(USER_ID, USER_LOGIN_NAME, USER_EMAIL, USER_FIRST_NAME, USER_LAST_NAME, USER_PASS, USER_ACTIVE, USER_IN_ADMIN, USER_IN_DAM)
			VALUES ('1', 'admin', 'admin@razuna.com', 'SystemAdmin', 'SystemAdmin', '778509C62BD8904D938FB85644EC4712', 'T', 'T', 'T');
			</cfquery>
			<!--- MODULES --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO modules
			(mod_id, mod_name, mod_short, mod_host_id)
			VALUES(	1, 'razuna', 'ecp', NULL);
			INSERT INTO modules
			(mod_id, mod_name, mod_short, mod_host_id)
			VALUES(	2, 'admin', 'adm', NULL);
			</cfquery>
			<!--- DEFAULT ADMIN GROUPS --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO groups
			(grp_id, grp_name, grp_host_id, grp_mod_id)
			VALUES(	'1', 'SystemAdmin', NULL, 2 );
			INSERT INTO groups
			(grp_id, grp_name, grp_host_id, grp_mod_id)
			VALUES(	'2', 'Administrator', NULL, 2	);
			</cfquery>
			<!--- DEFAULT ADMIN CROSS TABLE --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO ct_groups_users
			(CT_G_U_GRP_ID, CT_G_U_USER_ID, rec_uuid)
			VALUES(	'1', '1', '#createuuid()#');
			</cfquery>
			<!--- DEFAULT ADMIN PERMISSIONS --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (1,'SystemAdmin',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (2,'Administrator',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (3,'PER_USERS:N',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (4,'PER_USERS:R',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (5,'PER_USERS:W',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (6,'PER_GROUPS:N',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (7,'PER_GROUPS:R',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (8,'PER_GROUPS:W',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (9,'PER_GROUPS_ADMIN:N',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (10,'PER_GROUPS_ADMIN:R',null,1,2,null);
			Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (11,'PER_GROUPS_ADMIN:W',null,1,2,null);
			</cfquery>
			<!--- DEFAULT ADMIN PERMISSIONS CROSS TABLE --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 1, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 2, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 3, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 4, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 5, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 6, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 7, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 8, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 9, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 10, '1' );
			INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 11, '1' );
			</cfquery>
			<!--- WISDOM --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			2, 'In giving advice, seek to help, not please, your friend.', 'Solon'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			3, 'A friend is one to whom you can pour out the contents of your heart, chaff and grain alike. Knowning that the gentlest of hands will take and sift it, keep what is worth keeping, and with a breath of kindness, blow the rest away.'
			, 'Anonymous'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			4, 'The most exciting phrase to hear in science, the one that heralds new discoveries, is not "Eureka" (I found it!) but "That''s funny ..."'
			, 'Isaac Asimov'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			5, 'Everyone should carefully observe which way his heart draws him, and then choose that way with all his strength!'
			, 'Hasidic saying'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			6, 'Mend your speech a little, lest it may mar your fortunes.', 'Shakespeare, King Lear'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			7, 'In preparing for battle I have always found that plans are useless, but planning is indispensable.'
			, 'Dwight D. Eisenhower'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			8, 'It''s all right to aim high if you have plenty of ammunition.', 'Hawley R. Everhart'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			10, 'A great civilization is not concurred from without until it has destroyed itself from within.'
			, 'Will Durant'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			11, 'Travel far enough away, my friend, and you''ll discover something of great beauty: your self'
			, 'Cirque du Soleil'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			1, 'There are Painters who transform the sun to a yellow spot, but there are others who with the help of their art and their intelligence, transform a yellow spot into the sun.'
			, 'Pablo Picasso'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			9, 'The significant problems we have cannot be solved at the same level of thinking with which we created them.'
			, 'Albert Einstein'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			12, 'Acquaintance, n.: A person whom we know well enough to borrow from, but not well enough to lend to. '
			, 'Ambrose Bierce'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			13, 'The best investment is in the tools of one''s trade.', 'Benjamin Franklin'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			14, 'We all agree that your theory is crazy -- but is it crazy enough?', 'Niels Bohr'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			15, 'Genius without education is like silver in the mine.', 'Benjamin Franklin'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			16, 'Anybody can sympathise with the sufferings of a friend, but it requires a very fine nature to sympathise with a friend''s success.', 'Oscar Wilde'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			17, 'Absurdity, n.: A statement or belief manifestly incosistent with one''s own.', 'Ambrose Bierce'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			18, 'There''s no trick to being a humorist when you have the whole government working for you.', 'Will Rogers');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			19, 'The real question is not whether machines think but whether men do. The mystery which surrounds a thinking machine already surrounds a thinking man.', 'B.F.Skinner'); 
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			20, 'That we must all die, we always knew; I wish I had remembered it sooner.', 'Samuel Johnson');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			21, 'The key to living well is first to will that which is necessary and then to love that which is willed.', 'Irving Yalom');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			22, 'Always tell the truth. You will gratify some people and astonish the rest.', 'Mark Twain');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			23, 'See everything. Ignore a lot. Improve a little.', 'Pope John Paul II');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			24, 'Resentment is like taking poison and hoping the other person dies.', 'St. Augustine');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			25, 'Hope is definitely not the same thing as optimism. It is not the conviction that something will turn out well, but the certainty that something makes sense, regardless of how it turns out.', 'Vaclav Havel');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			26, 'We must never be ashamed of our tears, they are rain from heaven washing the dust from our hard hearts.', 'Charles Dickens');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			27, 'Our business in life is not to succeed, but to continue to fail in good spirits.', 'Robert Louis Stevenson');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			28, 'Be who you are and say what you feel because the people who mind don''t matter and the people who matter don''t mind.', 'Theodor Geisel');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			29, 'It is well to remember that the entire universe, with one trifling exception, is composed of others.', 'John Andrew Holmes');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			30, 'Fail to honor people, they fail to honor you.', 'Lao Tzu');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			31, 'You can leave anything out, as long as you know what it is.', 'Ernest Hemingway');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			32, 'The future is here. It''s just not evenly distributed yet.', 'William Gibson');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			33, 'The future always comes too fast and in the wrong order.', 'Alvin Toffler');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			34, 'There will always be people who are ahead of the curve, and people who are behind the curve. But knowledge moves the curve.', 'Bill James');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			35, 'History is a wave that moves through time slightly faster than we do.', 'Kim Stanley Robinson');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			36, 'Inspiration is for amateurs. I just get to work.', 'Chuck Close');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			37, 'The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.', 'Hellen Keller');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			38, 'Small opportunities are often the beginning of great enterprises.', 'Demosthenes');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			39, 'Simplicity is the utlimate sophistication.', 'Leonardo da Vinci');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			40, 'A journey of thousand miles begins with a single step.', 'Lao tzu');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			41, 'What we think, we become.', 'Buddha');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			42, 'Great minds discuss ideas. Average minds discuss events. Small minds discuss people.', 'Eleanor Roosevelt');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			43, 'Forget the place you are trying to get and see the beauty in right now', 'Some wise person');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			44, 'All that we are, is the result of our thoughts.', 'Buddha');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			45, 'Logic will get you from A to B. Imagination will take you everywhere.', 'Albert Einstein');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			46, 'Do not dwell on who let you down, cherish those whoe hold you up.', 'Unknown');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			47, 'People are made to be loved and things are made to be used. The confusion in this world is that people are used and things are loved!', 'Unknown');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			48, 'Make peace with your past so it will not destroy your present.', 'Paulo Coelho');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			49, 'Obstacles are those frightful things you see when you take your eyes off your goal.', 'Henry Ford');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			50, 'I feel like I can not feel.', 'Salvador Dali');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			51, 'To avoid criticism, do nothing, say nothing, and be nothing.', 'Elbert Hubbard');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			52, 'I am not upset that you lied to me, I am upset that from now on I can not believe you anymore.', 'Friedrich Nietzsche');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			53, 'Successful and great people are ordinary people with extraordinary determination.', 'Robert Schuller');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			54, 'Everything has beauty, but not everyone sees it.', 'Confucius');
			INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
			55, 'Wanting to be someone else is a waste of the person you are.', 'Kurt Cobain');
			</cfquery>
			<!--- FILE TYPES --->
			<cfquery datasource="#arguments.thestruct.dsn#">
			INSERT INTO file_types VALUES ('doc', 'doc', 'application', 'vnd.ms-word');
			INSERT INTO file_types VALUES ('docx', 'doc', 'application', 'vnd.ms-word');
			INSERT INTO file_types VALUES ('xls', 'doc', 'application', 'vnd.ms-excel');
			INSERT INTO file_types VALUES ('xlsx', 'doc', 'application', 'vnd.ms-excel');
			INSERT INTO file_types VALUES ('ppt', 'doc', 'application', 'vnd.ms-powerpoint');
			INSERT INTO file_types VALUES ('pptx', 'doc', 'application', 'vnd.ms-powerpoint');
			INSERT INTO file_types VALUES ('pdf', 'doc', 'application', 'pdf');
			INSERT INTO file_types VALUES ('txt', 'doc', 'application', 'txt');
			INSERT INTO file_types VALUES ('psd', 'img', 'application', 'photoshop');
			INSERT INTO file_types VALUES ('eps', 'img', 'application', 'eps');
			INSERT INTO file_types VALUES ('ai', 'img', 'application', 'photoshop');
			INSERT INTO file_types VALUES ('jpg', 'img', 'image', 'jpg');
			INSERT INTO file_types VALUES ('jpeg', 'img', 'image', 'jpeg');
			INSERT INTO file_types VALUES ('gif', 'img', 'image', 'gif');
			INSERT INTO file_types VALUES ('png', 'img', 'image', 'png');
			INSERT INTO file_types VALUES ('bmp', 'img', 'image', 'bmp');
			INSERT INTO file_types VALUES ('cal', 'img', null, null);
			INSERT INTO file_types VALUES ('dcm', 'img', null, null);
			INSERT INTO file_types VALUES ('fpx', 'img', 'image', 'vnd.fpx');
			INSERT INTO file_types VALUES ('pbm', 'img', 'image', 'pbm');
			INSERT INTO file_types VALUES ('pgm', 'img', 'image', 'x-portable-graymap');
			INSERT INTO file_types VALUES ('ppm', 'img', 'image', 'x-portable-pixmap');
			INSERT INTO file_types VALUES ('pnm', 'img', 'image', 'x-portable-anymap');
			INSERT INTO file_types VALUES ('pcx', 'img', 'image', 'pcx');
			INSERT INTO file_types VALUES ('pct', 'img', null, null);
			INSERT INTO file_types VALUES ('rpx', 'img', null, null);
			INSERT INTO file_types VALUES ('ras', 'img', 'image', 'ras');
			INSERT INTO file_types VALUES ('tga', 'img', 'image', 'tga');
			INSERT INTO file_types VALUES ('tif', 'img', 'image', 'tif');
			INSERT INTO file_types VALUES ('tiff', 'img', 'image', 'tiff');
			INSERT INTO file_types VALUES ('wbmp', 'img', 'image', 'vnd.wap.wbmp');
			INSERT INTO file_types VALUES ('nef', 'img', 'image', 'nef');
			INSERT INTO file_types VALUES ('swf', 'vid', 'application', 'x-shockwave-flash');
			INSERT INTO file_types VALUES ('flv', 'vid', 'application', 'x-shockwave-flash');
			INSERT INTO file_types VALUES ('f4v', 'vid', 'application', 'x-shockwave-flash');
			INSERT INTO file_types VALUES ('mov', 'vid', 'video', 'quicktime');
			INSERT INTO file_types VALUES ('m4v', 'vid', 'video', 'quicktime');
			INSERT INTO file_types VALUES ('avi', 'vid', 'video', 'avi');
			INSERT INTO file_types VALUES ('3gp', 'vid', 'video', '3gpp');
			INSERT INTO file_types VALUES ('rm', 'vid', 'application', 'vnd.rn-realmedia');
			INSERT INTO file_types VALUES ('mpg', 'vid', 'video', 'mpeg');
			INSERT INTO file_types VALUES ('mp4', 'vid', 'video', 'mp4v-es');
			INSERT INTO file_types VALUES ('wmv', 'vid', 'video', 'x-ms-wmv');
			INSERT INTO file_types VALUES ('vob', 'vid', 'video', 'mpeg');
			INSERT INTO file_types VALUES ('ogv', 'vid', 'video', 'ogv');
			INSERT INTO file_types VALUES ('webm', 'vid', 'video', 'webm');
			INSERT INTO file_types VALUES ('mts', 'vid', 'video', 'mts');
			INSERT INTO file_types VALUES ('m2ts', 'vid', 'video', 'm2ts');
			INSERT INTO file_types VALUES ('m2t', 'vid', 'video', 'm2t');
			INSERT INTO file_types VALUES ('aff', 'aud', null, null);
			INSERT INTO file_types VALUES ('aft', 'aud', null, null);
			INSERT INTO file_types VALUES ('au', 'aud', 'audio', 'basic');
			INSERT INTO file_types VALUES ('ram', 'aud', 'audio', 'x-pn-realaudio');
			INSERT INTO file_types VALUES ('wav', 'aud', 'audio', 'x-wav');
			INSERT INTO file_types VALUES ('mp3', 'aud', 'audio', 'mpeg');
			INSERT INTO file_types VALUES ('aiff', 'aud', 'audio', 'x-aiff');
			INSERT INTO file_types VALUES ('aif', 'aud', 'audio', 'x-aiff');
			INSERT INTO file_types VALUES ('aifc', 'aud', 'audio', 'x-aiff');
			INSERT INTO file_types VALUES ('wma', 'aud', 'audio', 'x-ms-wma');
			INSERT INTO file_types VALUES ('snd', 'aud', 'audio', 'basic');
			INSERT INTO file_types VALUES ('mid', 'aud', 'audio', 'mid');
			INSERT INTO file_types VALUES ('m3u', 'aud', 'audio', 'x-mpegurl');
			INSERT INTO file_types VALUES ('rmi', 'aud', 'audio', 'mid');
			INSERT INTO file_types VALUES ('ra', 'aud', 'audio', 'x-pn-realaudio');
			INSERT INTO file_types VALUES ('flac', 'aud', 'audio', 'flac');
			INSERT INTO file_types VALUES ('ogg', 'aud', 'audio', 'ogg');
			INSERT INTO file_types VALUES ('m4a', 'aud', 'audio', 'x-m4a');
			INSERT INTO file_types VALUES ('arw', 'img', 'image', 'arw');
			INSERT INTO file_types VALUES ('cr2', 'img', 'image', 'cr2');
			INSERT INTO file_types VALUES ('crw', 'img', 'image', 'crw');
			INSERT INTO file_types VALUES ('ciff', 'img', 'image', 'ciff');
			INSERT INTO file_types VALUES ('cs1', 'img', 'image', 'cs1');
			INSERT INTO file_types VALUES ('erf', 'img', 'image', 'erf');
			INSERT INTO file_types VALUES ('mef', 'img', 'image', 'mef');
			INSERT INTO file_types VALUES ('mrw', 'img', 'image', 'mrw');
			INSERT INTO file_types VALUES ('nrw', 'img', 'image', 'nrw');
			INSERT INTO file_types VALUES ('pef', 'img', 'image', 'pef');
			INSERT INTO file_types VALUES ('psb', 'img', 'application', 'photoshop');
			INSERT INTO file_types VALUES ('raf', 'img', 'image', 'raf');
			INSERT INTO file_types VALUES ('raw', 'img', 'image', 'raw');
			INSERT INTO file_types VALUES ('rw2', 'img', 'image', 'rw2');
			INSERT INTO file_types VALUES ('rwl', 'img', 'image', 'rwl');
			INSERT INTO file_types VALUES ('srw', 'img', 'image', 'srw');
			INSERT INTO file_types VALUES ('3fr', 'img', 'image', '3fr');
			INSERT INTO file_types VALUES ('ari', 'img', 'image', 'ari');
			INSERT INTO file_types VALUES ('srf', 'img', 'image', 'srf');
			INSERT INTO file_types VALUES ('sr2', 'img', 'image', 'sr2');
			INSERT INTO file_types VALUES ('bay', 'img', 'image', 'bay');
			INSERT INTO file_types VALUES ('cap', 'img', 'image', 'cap');
			INSERT INTO file_types VALUES ('iiq', 'img', 'image', 'iiq');
			INSERT INTO file_types VALUES ('eip', 'img', 'image', 'eip');
			INSERT INTO file_types VALUES ('dcs', 'img', 'image', 'dcs');
			INSERT INTO file_types VALUES ('dcr', 'img', 'image', 'dcr');
			INSERT INTO file_types VALUES ('drf', 'img', 'image', 'drf');
			INSERT INTO file_types VALUES ('k25', 'img', 'image', 'k25');
			INSERT INTO file_types VALUES ('kdc', 'img', 'image', 'kdc');
			INSERT INTO file_types VALUES ('dng', 'img', 'image', 'dng');
			INSERT INTO file_types VALUES ('fff', 'img', 'image', 'fff');
			INSERT INTO file_types VALUES ('mos', 'img', 'image', 'mos');
			INSERT INTO file_types VALUES ('orf', 'img', 'image', 'orf');
			INSERT INTO file_types VALUES ('ptx', 'img', 'image', 'ptx');
			INSERT INTO file_types VALUES ('r3d', 'img', 'image', 'r3d');
			INSERT INTO file_types VALUES ('rwz', 'img', 'image', 'rwz');
			INSERT INTO file_types VALUES ('x3f', 'img', 'image', 'x3f');
			INSERT INTO file_types VALUES ('mxf', 'vid', 'video', 'mxf');
			</cfquery>
		</cfif>
		<!--- <cfquery datasource="#arguments.thestruct.dsn#" name="test">
		DROP ALL OBJECTS
		</cfquery> --->
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
		<!--- CREATE THE INDEXES --->
		<cfinvoke method="create_indexes" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- Create Host --->
	<cffunction name="create_host" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		<!--- Create Tables --->
		<cfinvoke method="create_tables" thestruct="#arguments.thestruct#">
		<!--- CREATE THE INDEXES --->
		<cfinvoke method="create_indexes" thestruct="#arguments.thestruct#">
	</cffunction>
	
	<!--- Create Tables --->
	<cffunction name="create_tables" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		
		<!--- ASSETS_TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#assets_temp 
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
			SCHED_ACTION	INT,
			SCHED_ID		VARCHAR(100),
			FILE_ID			VARCHAR(100),
			LINK_KIND		VARCHAR(20),
			HOST_ID			BIGINT,
			md5hash			VARCHAR(100),
			CONSTRAINT #arguments.thestruct.host_db_prefix#ASSETSTEMP PRIMARY KEY (TEMPID)
		)
		</cfquery>
		
		<!--- XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#xmp 
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
			supplementalcategories			VARCHAR(4000),
			urgency					varchar(500),
			description				VARCHAR(4000),
			ciadrcity				varchar(500),
			ciadrctry				varchar(500),
			location					varchar(500),
			ciadrpcode				varchar(300),
			ciemailwork				varchar(300),
			ciurlwork				varchar(300),
			citelwork				varchar(300),
			intellectualgenre			varchar(500),
			instructions				VARCHAR(4000),
			source					varchar(1000),
			usageterms				VARCHAR(4000),
			copyrightstatus				VARCHAR(4000),
			transmissionreference			varchar(500),
			webstatement				VARCHAR(4000),
			headline				varchar(1000),
			datecreated				varchar(200),
			city					varchar(1000),
			ciadrregion				varchar(500),
			country					varchar(500),
			countrycode				varchar(500),
			scene					varchar(500),
			state					varchar(500),
			credit					varchar(1000),
			rights					VARCHAR(4000),
			colorspace				varchar(50),
			xres					varchar(30),
			yres					varchar(30),
			resunit					varchar(20),
			HOST_ID				BIGINT
		)  
		</cfquery>
		
		<!--- CART --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#cart
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
		CREATE TABLE #arguments.thestruct.host_db_prefix#folders
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
		  share_dl_thumb		varchar(1) DEFAULT 't',
     	 	  share_comments		varchar(1) DEFAULT 'f',
		  share_upload			varchar(1) DEFAULT 'f',
		  share_order			varchar(1) DEFAULT 'f',
		  share_order_user		VARCHAR(100),
		  share_inherit			varchar(1) DEFAULT 'f',
		  HOST_ID				BIGINT,
		  IN_TRASH		   		VARCHAR(2) DEFAULT 'F',
		  in_search_selection	VARCHAR(5) DEFAULT 'false',
		  PRIMARY KEY (FOLDER_ID),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDERS_HOSTID_FK1 FOREIGN KEY (HOST_ID)
		  REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- FOLDERS DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#folders_desc
		(
		  FOLDER_ID_R		VARCHAR(100),
		  LANG_ID_R			BIGINT,
		  FOLDER_DESC		VARCHAR(1000),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDER_DESC_FK_HOSTID FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- FOLDERS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#folders_groups
		(
		  FOLDER_ID_R		VARCHAR(100),
		  GRP_ID_R			VARCHAR(100) DEFAULT NULL,
		  GRP_PERMISSION	VARCHAR(2),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDER_GROUPS_FK_HOSTID FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- FILES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#files
		(
		  FILE_ID              VARCHAR(100),
		  FOLDER_ID_R          VARCHAR(100) DEFAULT NULL,
		  FILE_CREATE_DATE     DATE,
		  FILE_CREATE_TIME     TIMESTAMP,
		  FILE_CHANGE_DATE     DATE,
		  FILE_CHANGE_TIME     TIMESTAMP,
		  FILE_OWNER           VARCHAR(100),
		  FILE_TYPE            VARCHAR(5),
		  FILE_NAME            VARCHAR(500),
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
		  CLOUD_URL_EXP		   BIGINT,
		  IN_TRASH		   	   VARCHAR(2) DEFAULT 'F',
		  IS_INDEXED		   VARCHAR(1) DEFAULT 0,
		  FILE_UPC_NUMBER      VARCHAR(15), 
		  EXPIRY_DATE DATE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#FILE_PK PRIMARY KEY (FILE_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#FILE_FK_HOST FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- FILES DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#files_desc
		(
		  FILE_ID_R      VARCHAR(100),
		  LANG_ID_R      BIGINT,
		  FILE_DESC      VARCHAR(1000),
		  FILE_KEYWORDS  VARCHAR(2000),
		  ID_INC		 VARCHAR(100),
		  HOST_ID		 BIGINT,
		  PRIMARY KEY (ID_INC)
		)
		</cfquery>
		
		<!--- IMAGES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#images
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
		  CLOUD_URL			  VARCHAR(500),
		  CLOUD_URL_ORG		  VARCHAR(500),
		  HASHTAG			  VARCHAR(100),
		  IS_AVAILABLE		  VARCHAR(1) DEFAULT 0,
		  CLOUD_URL_EXP		  BIGINT,
		  IN_TRASH		   	  VARCHAR(2) DEFAULT 'F',
		  IS_INDEXED		  VARCHAR(1) DEFAULT 0,
		  IMG_UPC_NUMBER      VARCHAR(15),
		  EXPIRY_DATE DATE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#IMAGE_PK PRIMARY KEY (IMG_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#IMAGE_FK_HOSTID FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- IMAGES TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#images_text
		(
		  IMG_ID_R         VARCHAR(100) NOT NULL,
		  LANG_ID_R        BIGINT NOT NULL,
		  IMG_KEYWORDS     VARCHAR(4000),
		  IMG_DESCRIPTION  VARCHAR(4000),
		  ID_INC		   VARCHAR(100),
		  HOST_ID		   BIGINT,
		  PRIMARY KEY (ID_INC)
		)
		</cfquery>
		
		<!--- LOG ASSETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#log_assets
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
		  ASSET_ID_R		VARCHAR(100),
		  FOLDER_ID			VARCHAR(100),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_ASSETS_PK PRIMARY KEY (LOG_ID)
		)
		</cfquery>
		
		<!--- LOG FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#log_folders
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
		  HOST_ID			BIGINT, 
		  CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_FOLDERS_PK PRIMARY KEY (LOG_ID)
		)
		</cfquery>
		
		<!--- LOG USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#log_users
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
		  HOST_ID			BIGINT,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_USERS_PK PRIMARY KEY (LOG_ID)
		)
		</cfquery>
		
		<!--- LOG SEARCH --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#log_search
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
		  HOST_ID			BIGINT, 
		CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_SEARCH_PK PRIMARY KEY (LOG_ID)
		)
		</cfquery>
				
		<!--- SETTINGS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#settings
		(
		  SET_ID			VARCHAR(500) NOT NULL,
		  SET_PREF			VARCHAR(2000),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		CONSTRAINT #arguments.thestruct.host_db_prefix#SETTINGS_FK FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- SETTINGS 2 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#settings_2
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
		  SET2_EMAIL_USE_SSL			VARCHAR(5) DEFAULT 'false',
		  SET2_EMAIL_USE_TLS			VARCHAR(5) DEFAULT 'false',
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
		  SET2_LABELS_USERS				VARCHAR(1000),
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
		  SET2_NEW_USER_EMAIL_SUB 	VARCHAR(500),
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
		  CONSTRAINT #arguments.thestruct.host_db_prefix#SETTINGS_2_FK FOREIGN KEY (HOST_ID)
		  REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#temp
		(
		  TMP_TOKEN     VARCHAR(100),
		  TMP_FILENAME  VARCHAR(300),
		  HOST_ID		BIGINT
		)
		</cfquery>
		
		<!--- COLLECTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#collections
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
		  share_dl_thumb	varchar(1) DEFAULT 't',
     	  share_comments	varchar(1) DEFAULT 'f',
		  share_upload		varchar(1) DEFAULT 'f',
		  share_order		varchar(1) DEFAULT 'f',
		  share_order_user	VARCHAR(100),
		  col_released		VARCHAR(5) DEFAULT 'false',
		  col_copied_from	VARCHAR(100),
		  HOST_ID			BIGINT,
		  IN_TRASH		   	VARCHAR(2) DEFAULT 'F',
		CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_PK PRIMARY KEY (COL_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_#arguments.thestruct.host_db_prefix#COL_FK1_HOSTS FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- COLLECTIONS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#collections_text
		(
		  COL_ID_R      VARCHAR(100),
		  LANG_ID_R     BIGINT,
		  COL_DESC      VARCHAR(1000),
		  COL_KEYWORDS  VARCHAR(2000),
		  COL_NAME      VARCHAR(300),
		  HOST_ID		BIGINT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_TEXT_#arguments.thestruct.host_db_prefix#FK1 FOREIGN KEY (COL_ID_R)
			REFERENCES #arguments.thestruct.host_db_prefix#collections (COL_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- COLLECTIONS FILES CROSS TABLE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#collections_ct_files
		(
		  COL_ID_R       	VARCHAR(100),
		  FILE_ID_R      	VARCHAR(100),
		  COL_FILE_TYPE  	VARCHAR(5),
		  COL_ITEM_ORDER  	BIGINT,
		  COL_FILE_FORMAT  	VARCHAR(100),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100),
		  IN_TRASH		   	VARCHAR(2) DEFAULT 'F',
		  PRIMARY KEY (rec_uuid)
		)
		</cfquery>
		
		<!--- COLLECTIONS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#collections_groups
		(
		  COL_ID_R       	VARCHAR(100),
		  GRP_ID_R			VARCHAR(100) DEFAULT NULL,
		  GRP_PERMISSION	VARCHAR(2),
		  HOST_ID			BIGINT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_GROUPS_FK1 FOREIGN KEY (col_id_r)
		  REFERENCES #arguments.thestruct.host_db_prefix#collections (col_id) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- USER FAVORITES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#users_favorites
		(
		  USER_ID_R  VARCHAR(100),
		  FAV_TYPE   VARCHAR(8),
		  FAV_ID     VARCHAR(100),
		  FAV_KIND   VARCHAR(8),
		  FAV_ORDER  BIGINT,
		  HOST_ID	 BIGINT,
		  rec_uuid			VARCHAR(100),
		  PRIMARY KEY (rec_uuid),
		CONSTRAINT #arguments.thestruct.host_db_prefix#USERS_FAVORITES_FK1 FOREIGN KEY (USER_ID_R)
			  REFERENCES users (USER_ID) ON DELETE SET NULL
		)
		</cfquery>
		
		<!--- VIDEOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#videos
		(
		VID_ID					VARCHAR(100),
		VID_FILENAME			VARCHAR(500),
		FOLDER_ID_R				VARCHAR(100) DEFAULT NULL,
		VID_CUSTOM_ID			VARCHAR(500),
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
		IS_AVAILABLE		  	VARCHAR(1) DEFAULT 0,
		CLOUD_URL_EXP		   	BIGINT,
		IN_TRASH		   		VARCHAR(2) DEFAULT 'F',
		IS_INDEXED		  		VARCHAR(1) DEFAULT 0,
		VID_UPC_NUMBER      	VARCHAR(15),
		EXPIRY_DATE DATE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#VIDEO_PK PRIMARY KEY (VID_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#VIDEO_FK1 FOREIGN KEY (HOST_ID)
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- VIDEOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#videos_text
		(
		  VID_ID_R         VARCHAR(100) NOT NULL,
		  LANG_ID_R        BIGINT NOT NULL,
		  VID_KEYWORDS     VARCHAR(4000),
		  VID_DESCRIPTION  VARCHAR(4000),
		  VID_TITLE		   VARCHAR(400),
		  ID_INC		   VARCHAR(100),
		  HOST_ID		   BIGINT,
		  PRIMARY KEY (ID_INC)
		)
		</cfquery>
		
		<!--- SCHEDULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#schedules
		(
			sched_id 			 varchar(100) not null,
			set2_id_r 			 bigint,
			sched_user 			 varchar(100),
			sched_status 		 varchar(1) default 1,
			sched_method 		 varchar(10),
			sched_name 			 varchar(255),
			sched_folder_id_r    varchar(100),
			sched_zip_extract 	 bigint,
			sched_server_folder  varchar(4000),
			sched_server_recurse bigint default 1,
			sched_server_files   bigint default 0,
			sched_mail_pop 		 varchar(255),
			sched_mail_user 	 varchar(255),
			sched_mail_pass 	 varchar(255),
			sched_mail_subject 	 varchar(255),
			sched_ftp_server 	 varchar(255),
			sched_ftp_user 		 varchar(255),
			sched_ftp_pass 		 varchar(255),
			sched_ftp_passive    bigint default 0,
			sched_ftp_folder 	 varchar(255),
			sched_interval       varchar(255),
			sched_start_date     date,
			sched_start_time     timestamp,
			sched_end_date       date,
			sched_end_time       timestamp,
			host_id				 bigint,
			sched_ftp_email       varchar(500),
			sched_upl_template	 varchar(100),
			sched_ad_user_groups varchar(4000),
			CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_PK PRIMARY KEY (SCHED_ID),
			CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_FK1 FOREIGN KEY (HOST_ID)
			REFERENCES hosts (HOST_ID) ON DELETE CASCADE,
			CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_FK2 FOREIGN KEY (SCHED_USER)
			REFERENCES users (USER_ID) ON DELETE SET NULL
		)
		</cfquery>
		
		<!--- SCHEDULES_LOG --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#schedules_log
		(
			sched_log_id        varchar(100) not null,
			sched_id_r          varchar(100),
			sched_log_user      varchar(100),
			sched_log_action    varchar(10),
			sched_log_date      date,
			sched_log_time      timestamp,
			sched_log_desc      varchar(4000),
			host_id				bigint,
			notified    VARCHAR(5),
		CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_LOG_PK PRIMARY KEY (SCHED_LOG_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_LOG_FK1 FOREIGN KEY (SCHED_ID_R)
		REFERENCES #arguments.thestruct.host_db_prefix#schedules (SCHED_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- CUSTOM FIELDS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#custom_fields
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
			host_id			BIGINT,
			cf_xmp_path		VARCHAR(500),
			PRIMARY KEY (cf_id)
		)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#custom_fields_text
		(
			cf_id_r			VARCHAR(100), 
			lang_id_r 		bigint, 
			cf_text			VARCHAR(500),
			HOST_ID			BIGINT,
			rec_uuid			VARCHAR(100),
			PRIMARY KEY (rec_uuid),
			CONSTRAINT #arguments.thestruct.host_db_prefix#cf_text FOREIGN KEY (cf_id_r) REFERENCES #arguments.thestruct.host_db_prefix#custom_fields (cf_id) ON DELETE CASCADE
		)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#custom_fields_values
		(
			cf_id_r			VARCHAR(100), 
			asset_id_r 		VARCHAR(100), 
			cf_value		VARCHAR(4000),
			HOST_ID			BIGINT,
			rec_uuid			VARCHAR(100),
			PRIMARY KEY (rec_uuid),
			CONSTRAINT #arguments.thestruct.host_db_prefix#cf_values FOREIGN KEY (cf_id_r) REFERENCES #arguments.thestruct.host_db_prefix#custom_fields (cf_id) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#comments
		(
			COM_ID			VARCHAR(100),
			ASSET_ID_R		VARCHAR(100),
			ASSET_TYPE		VARCHAR(10),
			USER_ID_R		VARCHAR(100),
			COM_TEXT		VARCHAR(4000),
			COM_DATE		TIMESTAMP,
			HOST_ID			BIGINT,
			CONSTRAINT #arguments.thestruct.host_db_prefix#comments_pk PRIMARY KEY (COM_ID)
		)
		</cfquery>
		
		<!--- Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#versions
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
			meta_data			CLOB,
			hashtag				VARCHAR(100),
			rec_uuid			VARCHAR(100),
			cloud_url_thumb		VARCHAR(500),
			file_size			VARCHAR(100),
			PRIMARY KEY (rec_uuid)
		)
		</cfquery>
		
		<!--- TRANSLATIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#languages
		(
			lang_id			BIGINT NOT NULL,
			lang_name		VARCHAR(100),
			lang_active		VARCHAR(2) default 'f',
			host_id			BIGINT,
			rec_uuid		VARCHAR(100),
			CONSTRAINT HOSTID_LANGID UNIQUE (HOST_ID, LANG_ID), 
			PRIMARY KEY (rec_uuid)
		)
		</cfquery>
		
		<!--- AUDIOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#audios
		(
			aud_ID              VARCHAR(100),
			FOLDER_ID_R         VARCHAR(100) DEFAULT NULL,
			aud_CREATE_DATE     DATE,
			aud_CREATE_TIME     TIMESTAMP,
			aud_CHANGE_DATE     DATE,
			aud_CHANGE_TIME     TIMESTAMP,
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
			aud_meta			CLOB,
			LINK_KIND			VARCHAR(20),
		 	LINK_PATH_URL		VARCHAR(2000),
		 	HOST_ID				BIGINT,
		 	PATH_TO_ASSET		VARCHAR(500),
		 	CLOUD_URL			VARCHAR(500),
		 	CLOUD_URL_2		    VARCHAR(500),
		    CLOUD_URL_ORG		VARCHAR(500),
		    HASHTAG			    VARCHAR(100),
		    IS_AVAILABLE		VARCHAR(1) DEFAULT 0,
		    CLOUD_URL_EXP		BIGINT,
		    IN_TRASH		   	VARCHAR(2) DEFAULT 'F',
		    IS_INDEXED		  	VARCHAR(1) DEFAULT 0,
		    AUD_UPC_NUMBER      VARCHAR(15),
		    EXPIRY_DATE DATE,
			CONSTRAINT #arguments.thestruct.host_db_prefix#audios_PK PRIMARY KEY (aud_ID),
			CONSTRAINT #arguments.thestruct.host_db_prefix#audios_FK1 FOREIGN KEY (HOST_ID) REFERENCES hosts (HOST_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- AUDIOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#audios_text
		(
			aud_ID_R			VARCHAR(100),
			LANG_ID_R			BIGINT,
			aud_DESCRIPTION     VARCHAR(4000),
			aud_KEYWORDS		VARCHAR(4000),
			ID_INC		   		VARCHAR(100),
			HOST_ID				BIGINT,
			PRIMARY KEY (ID_INC)
		)
		</cfquery>
		
		<!--- SHARE OPTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#share_options
		(
			asset_id_r		VARCHAR(100),
			host_id			BIGINT,
			group_asset_id	VARCHAR(100),
			folder_id_r		VARCHAR(100),
			asset_type		varchar(6),
			asset_format	varchar(100),
			asset_dl		varchar(1) DEFAULT '0',
			asset_order		varchar(1) DEFAULT '0',
			asset_selected	varchar(1) DEFAULT '0',
			rec_uuid		VARCHAR(100),
			PRIMARY KEY (rec_uuid)
		)
		</cfquery>
		
		<!--- ERRORS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#errors
		(
			id				BIGINT,
			err_header		varchar(2000),
			err_text		CLOB,
			err_date		timestamp,
			host_id			BIGINT,
			CONSTRAINT #arguments.thestruct.host_db_prefix#errors_PK PRIMARY KEY (id)
		)
		</cfquery>
		
		<!--- Upload Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#upload_templates 
		(
		  	upl_temp_id			varchar(100) NOT NULL,
		  	upl_date_create 	timestamp NULL DEFAULT NULL,
		  	upl_date_update		timestamp NULL DEFAULT NULL,
		  	upl_who				varchar(100) DEFAULT NULL,
		  	upl_active			VARCHAR(1) DEFAULT '0',
		  	host_id				BIGINT DEFAULT NULL,
		  	upl_name			varchar(200) DEFAULT NULL,
		  	upl_description		varchar(2000) DEFAULT NULL,
		  	PRIMARY KEY (upl_temp_id)
		)
		</cfquery>
		
		<!--- Upload Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#upload_templates_val
		(
		  	upl_temp_id_r		varchar(100) NOT NULL,
		  	upl_temp_field		varchar(300) DEFAULT NULL,
		  	upl_temp_value		varchar(100) DEFAULT NULL,
		  	upl_temp_type		varchar(5) DEFAULT NULL,
		  	upl_temp_format		varchar(10) DEFAULT NULL,
		  	host_id				BIGINT DEFAULT NULL,
		  	rec_uuid			VARCHAR(100),
		  	PRIMARY KEY (rec_uuid)	
		)
		</cfquery>
		
		<!--- CREATE WIDGETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#widgets 
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
		  host_id 				bigint,
		  PRIMARY KEY (widget_id)
		)
		</cfquery>
		
		<!--- Additional Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#additional_versions (
		  av_id					varchar(100) NOT NULL,
		  asset_id_r			varchar(100) DEFAULT NULL,
		  folder_id_r			varchar(100) DEFAULT NULL,
		  av_type				varchar(45) DEFAULT NULL,
		  av_link_title			varchar(200) DEFAULT NULL,
		  av_link_url 			varchar(500) DEFAULT NULL,
		  host_id 				bigint DEFAULT NULL,
		  av_link 				varchar(2) DEFAULT '1',
		  thesize 				varchar(100) DEFAULT '0',
  		  thewidth 				varchar(50) DEFAULT '0',
  		  theheight				varchar(50) DEFAULT '0',
  		  hashtag			   	VARCHAR(100),
  		  av_thumb_url			varchar(500) DEFAULT NULL,
		  PRIMARY KEY (av_id)
		)
		</cfquery>
		
		<!--- Files XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#files_xmp (
		  asset_id_r 			varchar(100),
		  author 				varchar(200),
		  rights 				varchar(1000),
		  authorsposition 		varchar(200),
		  captionwriter 		varchar(300),
		  webstatement 			varchar(500),
		  rightsmarked 			varchar(10),
		  host_id 				bigint,
		  PRIMARY KEY (asset_id_r)
		)
		</cfquery>
		
		<!--- Labels --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#labels (
		label_id 		varchar(100),
  		label_text 		varchar(200),
  		label_date		timestamp,
  		user_id			varchar(100),
  		host_id			bigint,
  		label_id_r		varchar(100),
  		label_path		varchar(500),
  		PRIMARY KEY (label_id)
		)
		</cfquery>
		
		<!--- Import Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#import_templates (
		imp_temp_id 		varchar(100),
  		imp_date_create	 	timestamp,
  		imp_date_update		timestamp,
  		imp_who				varchar(100),
  		imp_active 			varchar(1) DEFAULT '0',
  		host_id				bigint,
  		imp_name			varchar(200),
  		imp_description 	varchar(2000),
  		PRIMARY KEY (imp_temp_id)
		)
		</cfquery>
		
		<!--- Import Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#import_templates_val (
  		imp_temp_id_r		varchar(100),
  		rec_uuid			varchar(100),
  		imp_field			varchar(200),
  		imp_map				varchar(200),
  		host_id				bigint,
  		imp_key				bigint,
  		PRIMARY KEY (rec_uuid)
		)
		</cfquery>
		
		<!--- Customization --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#custom (
	  	custom_id			varchar(200),
		custom_value		varchar(2000),
		host_id				bigint
		)
		</cfquery>
		
		<!--- RAZ-2831 : Metadata export template --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#export_template (
	  	exp_id				varchar(100),
		exp_field			varchar(200),
		exp_value			varchar(2000),
		exp_timestamp		timestamp, 
		user_id				varchar(100),
		host_id				bigint,
		PRIMARY KEY (exp_id)
		)
		</cfquery>
		
		<!--- Social accounts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#users_accounts (
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
		CREATE TABLE #arguments.thestruct.host_db_prefix#wm_templates (
	  	wm_temp_id 			varchar(100),
	  	wm_name				varchar(200),
		wm_active			varchar(6) DEFAULT 'false',
		host_id 			bigint,
		PRIMARY KEY (wm_temp_id)
		)
		</cfquery>

		<!--- Watermark values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#wm_templates_val (
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
		rec_uuid 			varchar(100),
		PRIMARY KEY (rec_uuid)
		)
		</cfquery>

		<!--- Smart Folders --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#smart_folders 
		(
			sf_id 			varchar(100),
			sf_name 		varchar(500),
			sf_date_create 	timestamp,
			sf_date_update 	timestamp,
			sf_type 		varchar(100),
			sf_description 	varchar(2000),
			sf_who	 		varchar(100),
			sf_zipextract	 	varchar(1),
			host_id 		bigint,
			PRIMARY KEY (sf_id)
		)
		</cfquery>

		<!--- Smart Folders Properties --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#smart_folders_prop
		(
			sf_id_r 		varchar(100),
			sf_prop_id 		varchar(500),
			sf_prop_value 	varchar(2000),
			host_id 		bigint,
			PRIMARY KEY (sf_id_r)
		)
		</cfquery>
		
		<!--- Folder subscribe --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#folder_subscribe
		(
			fs_id  						varchar(100) NOT NULL,
			host_id 					bigint DEFAULT NULL,
			folder_id 					varchar(100) DEFAULT NULL,
			user_id						varchar(100) DEFAULT NULL,
			mail_interval_in_hours		BIGINT(6) DEFAULT NULL,
			last_mail_notification_time timestamp DEFAULT NULL,
			asset_keywords				varchar(3) DEFAULT 'F',
			asset_description			varchar(3) DEFAULT 'F',
			auto_entry	varchar(5) DEFAULT 'false',
			 PRIMARY KEY (fs_id)
		)
		</cfquery>
	</cffunction>
	
	<!--- Create Indexes --->
	<cffunction name="create_indexes" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		<!--- Start creating indexes --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_cache_token ON cache(cache_token);
		CREATE INDEX idx_cache_type ON cache(cache_type);
		CREATE INDEX idx_cache_host_id ON cache(host_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_mod_sort ON modules(MOD_SHORT);
		CREATE INDEX idx_mod_hostid ON modules(MOD_HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX PER_MOD_ID ON permissions(PER_MOD_ID);
		CREATE INDEX per_hostid ON permissions(PER_HOST_ID);
		CREATE INDEX per_active ON permissions(PER_ACTIVE);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX GRP_MOD_ID ON groups(GRP_MOD_ID);
  		CREATE INDEX grp_hostid ON groups(GRP_HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_hostname ON hosts(HOST_NAME);
		CREATE INDEX idx_hostname_custom ON hosts(HOST_NAME_CUSTOM);
		CREATE INDEX idx_hosttype ON hosts(HOST_TYPE);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX CT_G_U_GRP_ID ON ct_groups_users(ct_g_u_grp_id);
  		CREATE INDEX ct_g_u_user_id ON ct_groups_users(ct_g_u_user_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX CT_G_P_PER_ID ON ct_groups_permissions(CT_G_P_PER_ID);
  		CREATE INDEX CT_G_P_GRP_ID ON ct_groups_permissions(CT_G_P_GRP_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX ct_u_h_user_id ON ct_users_hosts(ct_u_h_user_id);
  		CREATE INDEX ct_u_h_host_id ON ct_users_hosts(CT_U_H_HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX CT_U_RU_USER_ID ON ct_users_remoteusers(CT_U_RU_USER_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#t_id ON #arguments.thestruct.host_db_prefix#assets_temp(TEMPID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#t_date ON #arguments.thestruct.host_db_prefix#assets_temp(DATE_ADD);
		CREATE INDEX #arguments.thestruct.host_db_prefix#t_hostid ON #arguments.thestruct.host_db_prefix#assets_temp(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#xmp_idr ON #arguments.thestruct.host_db_prefix#xmp(id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#xmp_hostid ON #arguments.thestruct.host_db_prefix#xmp(host_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#xmp_type ON #arguments.thestruct.host_db_prefix#xmp(asset_type);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_id ON #arguments.thestruct.host_db_prefix#cart(CART_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_user ON #arguments.thestruct.host_db_prefix#cart(USER_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_done ON #arguments.thestruct.host_db_prefix#cart(cart_order_done);
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_user_r ON #arguments.thestruct.host_db_prefix#cart(cart_order_user_r);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_hostid ON #arguments.thestruct.host_db_prefix#folders(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_id ON #arguments.thestruct.host_db_prefix#folders(folder_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_name ON #arguments.thestruct.host_db_prefix#folders(FOLDER_NAME);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_id_r ON #arguments.thestruct.host_db_prefix#folders(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_owner ON #arguments.thestruct.host_db_prefix#folders(folder_owner);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_col ON #arguments.thestruct.host_db_prefix#folders(FOLDER_IS_COLLECTION);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_shared ON #arguments.thestruct.host_db_prefix#folders(FOLDER_SHARED);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_user ON #arguments.thestruct.host_db_prefix#folders(FOLDER_OF_USER);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fod_hostid ON #arguments.thestruct.host_db_prefix#folders_desc(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fod_fidr ON #arguments.thestruct.host_db_prefix#folders_desc(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fod_lang ON #arguments.thestruct.host_db_prefix#folders_desc(LANG_ID_R);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_grpid ON #arguments.thestruct.host_db_prefix#folders_groups(grp_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_grpperm ON #arguments.thestruct.host_db_prefix#folders_groups(GRP_PERMISSION);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_hostid ON #arguments.thestruct.host_db_prefix#folders_groups(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_fidr ON #arguments.thestruct.host_db_prefix#folders_groups(folder_id_r);		
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_hostid ON #arguments.thestruct.host_db_prefix#files(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_name ON #arguments.thestruct.host_db_prefix#files(FILE_NAME);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_folderid ON #arguments.thestruct.host_db_prefix#files(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_name_org ON #arguments.thestruct.host_db_prefix#files(FILE_NAME_ORG);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_pathtoasset ON #arguments.thestruct.host_db_prefix#files(PATH_TO_ASSET);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_ext ON #arguments.thestruct.host_db_prefix#files(FILE_EXTENSION);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_type ON #arguments.thestruct.host_db_prefix#files(FILE_TYPE);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_owner ON #arguments.thestruct.host_db_prefix#files(file_owner);
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_createdate ON #arguments.thestruct.host_db_prefix#files(FILE_CREATE_DATE);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_idr ON #arguments.thestruct.host_db_prefix#files_desc(file_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_hostid ON #arguments.thestruct.host_db_prefix#files_desc(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_lang ON #arguments.thestruct.host_db_prefix#files_desc(LANG_ID_R);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_name ON #arguments.thestruct.host_db_prefix#images(IMG_FILENAME);
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_name_org ON #arguments.thestruct.host_db_prefix#images(IMG_FILENAME_ORG);
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_folderid ON #arguments.thestruct.host_db_prefix#images(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_group ON #arguments.thestruct.host_db_prefix#images(img_group);
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_pathtoasset ON #arguments.thestruct.host_db_prefix#images(PATH_TO_ASSET);
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_hostid ON #arguments.thestruct.host_db_prefix#images(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#it_IMG_ID_R ON #arguments.thestruct.host_db_prefix#images_text(img_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#it_hostid ON #arguments.thestruct.host_db_prefix#images_text(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#it_lang ON #arguments.thestruct.host_db_prefix#images_text(LANG_ID_R);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#la_user ON #arguments.thestruct.host_db_prefix#log_assets(log_user);
		CREATE INDEX #arguments.thestruct.host_db_prefix#la_hostid ON #arguments.thestruct.host_db_prefix#log_assets(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lf_userid ON #arguments.thestruct.host_db_prefix#log_folders(log_user);
		CREATE INDEX #arguments.thestruct.host_db_prefix#lf_hostid ON #arguments.thestruct.host_db_prefix#log_folders(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#lf_action ON #arguments.thestruct.host_db_prefix#log_folders(LOG_ACTION);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_user ON #arguments.thestruct.host_db_prefix#log_users(log_user);
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_action ON #arguments.thestruct.host_db_prefix#log_users(LOG_ACTION);
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_hostid ON #arguments.thestruct.host_db_prefix#log_users(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_section ON #arguments.thestruct.host_db_prefix#log_users(LOG_SECTION);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ls_user ON #arguments.thestruct.host_db_prefix#log_search(log_user);
		CREATE INDEX #arguments.thestruct.host_db_prefix#ls_hostid ON #arguments.thestruct.host_db_prefix#log_search(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#ls_searchfrom ON #arguments.thestruct.host_db_prefix#log_search(LOG_SEARCH_FROM);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#set_hostid ON #arguments.thestruct.host_db_prefix#settings(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#set_id ON #arguments.thestruct.host_db_prefix#settings(SET_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#set2_HOST_ID ON #arguments.thestruct.host_db_prefix#settings_2(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#set2_id ON #arguments.thestruct.host_db_prefix#settings_2(SET2_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_hostid ON #arguments.thestruct.host_db_prefix#collections(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_fid_r ON #arguments.thestruct.host_db_prefix#collections(folder_id_r);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_text_id ON #arguments.thestruct.host_db_prefix#collections_text(col_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_text_lang ON #arguments.thestruct.host_db_prefix#collections_text(LANG_ID_R);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_idr ON #arguments.thestruct.host_db_prefix#collections_ct_files(col_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_fileid ON #arguments.thestruct.host_db_prefix#collections_ct_files(file_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_filetype ON #arguments.thestruct.host_db_prefix#collections_ct_files(COL_FILE_TYPE);
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_hostid ON #arguments.thestruct.host_db_prefix#collections_ct_files(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cg_colid_r ON #arguments.thestruct.host_db_prefix#collections_groups(col_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cg_grpid_r ON #arguments.thestruct.host_db_prefix#collections_groups(grp_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cg_hostid ON #arguments.thestruct.host_db_prefix#collections_groups(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#uf_idr ON #arguments.thestruct.host_db_prefix#users_favorites(user_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#uf_id ON #arguments.thestruct.host_db_prefix#users_favorites(fav_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#uf_hostid ON #arguments.thestruct.host_db_prefix#users_favorites(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_group ON #arguments.thestruct.host_db_prefix#videos(vid_group);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_folderid ON #arguments.thestruct.host_db_prefix#videos(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_pathtoasset ON #arguments.thestruct.host_db_prefix#videos(PATH_TO_ASSET);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_hostid ON #arguments.thestruct.host_db_prefix#videos(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_owner ON #arguments.thestruct.host_db_prefix#videos(vid_owner);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_hash ON #arguments.thestruct.host_db_prefix#videos(HASHTAG);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vt_idr ON #arguments.thestruct.host_db_prefix#videos_text(vid_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vt_lang ON #arguments.thestruct.host_db_prefix#videos_text(LANG_ID_R);
		CREATE INDEX #arguments.thestruct.host_db_prefix#vt_hostid ON #arguments.thestruct.host_db_prefix#videos_text(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_user ON #arguments.thestruct.host_db_prefix#schedules(SCHED_USER);
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_hostid ON #arguments.thestruct.host_db_prefix#schedules(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_idr ON #arguments.thestruct.host_db_prefix#schedules_log(sched_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#schedl_hostid ON #arguments.thestruct.host_db_prefix#schedules_log(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_logtime ON #arguments.thestruct.host_db_prefix#schedules_log(SCHED_LOG_TIME);
		CREATE INDEX #arguments.thestruct.host_db_prefix#notified ON #arguments.thestruct.host_db_prefix#schedules_log(sched_id_r, notified);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cf_enabled ON #arguments.thestruct.host_db_prefix#custom_fields(cf_enabled);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cf_show ON #arguments.thestruct.host_db_prefix#custom_fields(cf_show);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cf_hostid ON #arguments.thestruct.host_db_prefix#custom_fields(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cft_id ON #arguments.thestruct.host_db_prefix#custom_fields_text(cf_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cft_lang ON #arguments.thestruct.host_db_prefix#custom_fields_text(lang_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cft_hostid ON #arguments.thestruct.host_db_prefix#custom_fields_text(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cfv_idr ON #arguments.thestruct.host_db_prefix#custom_fields_values(cf_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cfv_hostid ON #arguments.thestruct.host_db_prefix#custom_fields_values(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#cfv_assetid ON #arguments.thestruct.host_db_prefix#custom_fields_values(asset_id_r);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_assettype ON #arguments.thestruct.host_db_prefix#comments(ASSET_TYPE);
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_idr ON #arguments.thestruct.host_db_prefix#comments(asset_id_r);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#l_active ON #arguments.thestruct.host_db_prefix#languages(lang_active);
		CREATE INDEX #arguments.thestruct.host_db_prefix#l_hostid ON #arguments.thestruct.host_db_prefix#languages(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_hostid ON #arguments.thestruct.host_db_prefix#audios(HOST_ID);
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_folderid ON #arguments.thestruct.host_db_prefix#audios(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_group ON #arguments.thestruct.host_db_prefix#audios(aud_group);
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_pathtoasset ON #arguments.thestruct.host_db_prefix#audios(PATH_TO_ASSET);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#at_idr ON #arguments.thestruct.host_db_prefix#audios_text(aud_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#at_lang ON #arguments.thestruct.host_db_prefix#audios_text(LANG_ID_R);
		CREATE INDEX #arguments.thestruct.host_db_prefix#at_hostid ON #arguments.thestruct.host_db_prefix#audios_text(HOST_ID);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_hostid ON #arguments.thestruct.host_db_prefix#share_options(host_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_asset_type ON #arguments.thestruct.host_db_prefix#share_options(asset_type);
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_folderid ON #arguments.thestruct.host_db_prefix#share_options(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_assetselected ON #arguments.thestruct.host_db_prefix#share_options(asset_selected);
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_groupid ON #arguments.thestruct.host_db_prefix#share_options(group_asset_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_assetidr ON #arguments.thestruct.host_db_prefix#share_options(asset_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_format ON #arguments.thestruct.host_db_prefix#share_options(asset_format);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ut_active ON #arguments.thestruct.host_db_prefix#upload_templates(upl_active);
		CREATE INDEX #arguments.thestruct.host_db_prefix#ut_hostid ON #arguments.thestruct.host_db_prefix#upload_templates(host_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#utv_idr ON #arguments.thestruct.host_db_prefix#upload_templates_val(upl_temp_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#utv_hostid ON #arguments.thestruct.host_db_prefix#upload_templates_val(host_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#w_folderid ON #arguments.thestruct.host_db_prefix#widgets(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#w_hostid ON #arguments.thestruct.host_db_prefix#widgets(host_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#w_colid ON #arguments.thestruct.host_db_prefix#widgets(col_id_r);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_id_r ON #arguments.thestruct.host_db_prefix#additional_versions(asset_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_fid_r ON #arguments.thestruct.host_db_prefix#additional_versions(folder_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_link ON #arguments.thestruct.host_db_prefix#additional_versions(av_link);
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_hostid ON #arguments.thestruct.host_db_prefix#additional_versions(host_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_xmp_hostid ON #arguments.thestruct.host_db_prefix#files_xmp(host_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#labels_id ON #arguments.thestruct.host_db_prefix#labels(label_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#labels_text ON #arguments.thestruct.host_db_prefix#labels(label_text);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#custom ON #arguments.thestruct.host_db_prefix#custom(custom_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#folder_id ON #arguments.thestruct.host_db_prefix#folder_subscribe(folder_id);
		CREATE INDEX #arguments.thestruct.host_db_prefix#user_id ON #arguments.thestruct.host_db_prefix#folder_subscribe(user_id);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#asset_id_r  ON ct_aliases(asset_id_r);
		CREATE INDEX #arguments.thestruct.host_db_prefix#folder_id_r  ON ct_aliases(folder_id_r);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_hashtag  ON #arguments.thestruct.host_db_prefix#images(hashtag);
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_hashtag  ON #arguments.thestruct.host_db_prefix#audios(hashtag);
		CREATE INDEX #arguments.thestruct.host_db_prefix#file_hashtag  ON #arguments.thestruct.host_db_prefix#files(hashtag);
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#folder_group ON #arguments.thestruct.host_db_prefix#folder_subscribe_groups(folder_id,group_id);
		</cfquery>

		<cfreturn />
	</cffunction>
	
	<!--- Clear database completely --->
	<cffunction name="clearall" access="public" output="false">
		<!--- Query Tables --->
		<cfquery datasource="#session.firsttime.database#" name="qrytables">
		SELECT lower(table_name) as thetable
		FROM information_schema.tables
		WHERE table_catalog = 'RAZUNA'
		AND table_type = 'TABLE'
		ORDER BY table_name
		</cfquery>
		<!--- Loop and drop tables --->
		<cfloop query="qrytables">
			<cftry>
				<cfquery datasource="#session.firsttime.database#">
				ALTER TABLE #thetable# SET REFERENTIAL_INTEGRITY false
				</cfquery>
				<cfquery datasource="#session.firsttime.database#">
				DROP TABLE #thetable#
				</cfquery>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
		<!--- Query Sequences --->
		<cfquery datasource="#session.firsttime.database#" name="qryseq">
		SELECT sequence_name as theseq
		FROM information_schema.sequences
		WHERE IS_GENERATED = false
		</cfquery>
		<!--- Loop over Sequences and remove them --->
		<cfloop query="qryseq">
			<cfquery datasource="#session.firsttime.database#">
			DROP SEQUENCE #theseq#
			</cfquery>
		</cfloop>
		<cfreturn />
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