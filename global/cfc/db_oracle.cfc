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
		<!--- CREATE SEQUENCES
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE sequences 
		(
			theid		VARCHAR2(100), 
			thevalue	INT NOT NULL,
			CONSTRAINT SEQUENCES_PK PRIMARY KEY (theid)
		) 
		</cfquery>
		 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE cache 
		(
			cache_token varchar2(100 char) DEFAULT NULL,
			cache_type varchar2(20 char) DEFAULT NULL,
			host_id number DEFAULT NULL
		)
		</cfquery>
		<!--- Modules --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE modules 
		(
			MOD_ID 			NUMBER NOT NULL ENABLE, 
			MOD_NAME 		VARCHAR2(50 CHAR) NOT NULL ENABLE, 
			MOD_SHORT 		VARCHAR2(3 CHAR) NOT NULL ENABLE, 
			MOD_HOST_ID 	NUMBER DEFAULT NULL, 
		CONSTRAINT MODULES_PK PRIMARY KEY (MOD_ID), 
		CONSTRAINT MODULES_UK1 UNIQUE (MOD_NAME, MOD_SHORT, MOD_HOST_ID)
		)
		</cfquery>
		<!--- permissions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE permissions 
		(
			PER_ID 			NUMBER NOT NULL ENABLE, 
			PER_KEY  		VARCHAR2(50 CHAR) NOT NULL ENABLE, 
			PER_HOST_ID 	NUMBER DEFAULT NULL, 
			PER_ACTIVE 		NUMBER DEFAULT 1 NOT NULL ENABLE, 
			PER_MOD_ID 		NUMBER NOT NULL ENABLE,
			PER_LEVEL		VARCHAR2(10 CHAR),
			CONSTRAINT permissions_PK PRIMARY KEY (PER_ID), 
			CONSTRAINT permissions_FK_MODULES FOREIGN KEY (PER_MOD_ID)
			REFERENCES modules (MOD_ID) ENABLE
		)
		</cfquery>
		<!--- Groups --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE groups
		(	GRP_ID 				VARCHAR2(100 CHAR) NOT NULL ENABLE, 
			GRP_NAME 			VARCHAR2(50 CHAR), 
			GRP_HOST_ID 		NUMBER DEFAULT NULL, 
			GRP_MOD_ID 			NUMBER NOT NULL ENABLE, 
			GRP_TRANSLATION_KEY VARCHAR2(50 CHAR), 
			UPC_SIZE 			VARCHAR2(2 CHAR) DEFAULT NULL,
			UPC_FOLDER_FORMAT	VARCHAR2(5 CHAR) DEFAULT 'false',
			FOLDER_SUBSCRIBE	VARCHAR2(5 CHAR) DEFAULT 'false',
		CONSTRAINT GROUPS_PK PRIMARY KEY (GRP_ID), 
		CONSTRAINT GROUPS_UK1 UNIQUE (GRP_NAME, GRP_HOST_ID, GRP_MOD_ID), 
		CONSTRAINT GROUPS_FK_MODULES FOREIGN KEY (GRP_MOD_ID)
			REFERENCES modules (MOD_ID) ENABLE
		)
		</cfquery>
		<!--- Hosts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE hosts 
		(
		  HOST_ID           NUMBER                      NOT NULL,
		  HOST_NAME         VARCHAR2(100 CHAR),
		  HOST_PATH         VARCHAR2(50 CHAR),
		  HOST_CREATE_DATE  DATE,
		  HOST_DB_PREFIX    VARCHAR2(40 CHAR),
		  HOST_LANG         NUMBER,
		  HOST_TYPE			VARCHAR2(2 CHAR) DEFAULT 'F',
		  HOST_SHARD_GROUP	VARCHAR2(10 CHAR),
		  HOST_NAME_CUSTOM  VARCHAR2(200 CHAR),
		CONSTRAINT HOSTS_PK PRIMARY KEY (HOST_ID) ENABLE
		)
		</cfquery>
		<!--- Users --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE users 
		(
		  USER_ID              VARCHAR2(100 CHAR)       NOT NULL,
		  USER_LOGIN_NAME      VARCHAR2(50 CHAR)        NOT NULL,
		  USER_EMAIL           VARCHAR2(80 CHAR)        NOT NULL,
		  USER_FIRST_NAME      VARCHAR2(80 CHAR),
		  USER_LAST_NAME       VARCHAR2(80 CHAR),
		  USER_PASS            VARCHAR2(500 CHAR)       NOT NULL,
		  USER_COMPANY         VARCHAR2(80 CHAR),
		  USER_STREET          VARCHAR2(80 CHAR),
		  USER_STREET_NR       NUMBER(6),
		  USER_STREET_2        VARCHAR2(80 CHAR),
		  USER_STREET_NR_2     NUMBER(6),
		  USER_ZIP             NUMBER(7),
		  USER_CITY            VARCHAR2(50 CHAR),
		  USER_COUNTRY         VARCHAR2(60 CHAR),
		  USER_PHONE           VARCHAR2(30 CHAR),
		  USER_PHONE_2         VARCHAR2(30 CHAR),
		  USER_MOBILE          VARCHAR2(30 CHAR),
		  USER_FAX             VARCHAR2(30 CHAR),
		  USER_CREATE_DATE     TIMESTAMP,
		  USER_CHANGE_DATE     TIMESTAMP,
		  USER_ACTIVE          VARCHAR2(2 CHAR),
		  USER_IN_ADMIN        VARCHAR2(2 CHAR),
		  USER_IN_DAM          VARCHAR2(2 CHAR),
		  USER_SALUTATION      VARCHAR2(500 CHAR),
		  USER_IN_VP		   VARCHAR2(2 CHAR) DEFAULT 'F',
		  SET2_NIRVANIX_NAME   VARCHAR2(500 CHAR),
		  SET2_NIRVANIX_PASS   VARCHAR2(500 CHAR),
		  USER_API_KEY		   VARCHAR2(100 CHAR),
		  USER_EXPIRY_DATE DATE,
		CONSTRAINT USERS_PK PRIMARY KEY (USER_ID) ENABLE
		)
		</cfquery>
		<!--- Ct_Groups_Users --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_groups_users
		(	CT_G_U_GRP_ID 		VARCHAR2(100 CHAR) NOT NULL ENABLE, 
			CT_G_U_USER_ID 		VARCHAR2(100 CHAR) NOT NULL ENABLE,
			rec_uuid			VARCHAR2(100 CHAR),
			CONSTRAINT #arguments.thestruct.host_db_prefix#CTGU_PK PRIMARY KEY (rec_uuid),
			CONSTRAINT CT_GROUPS_USERS_UK1 UNIQUE (CT_G_U_GRP_ID, CT_G_U_USER_ID), 
			CONSTRAINT CT_GROUPS_USERS_GROUPS_FK1 FOREIGN KEY (CT_G_U_GRP_ID)
			REFERENCES groups (GRP_ID) ENABLE
		)
		</cfquery>
		<!--- CT_GROUPS_permissions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_groups_permissions
		(	CT_G_P_PER_ID 		NUMBER NOT NULL ENABLE, 
			CT_G_P_GRP_ID 		VARCHAR2(100 CHAR) NOT NULL ENABLE, 
		CONSTRAINT CT_GROUPS_permissions_UK1 UNIQUE (CT_G_P_PER_ID, CT_G_P_GRP_ID), 
		CONSTRAINT CT_GROUPS_permissions_FK2 FOREIGN KEY (CT_G_P_PER_ID)
		REFERENCES permissions (PER_ID) ENABLE, 
		CONSTRAINT CT_GROUPS_permissions_FK1 FOREIGN KEY (CT_G_P_GRP_ID)
		REFERENCES groups (GRP_ID) ENABLE
		)
		</cfquery>
		<!--- LOG_ACTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE log_actions 
		(
		  LOG_ACT_ID    NUMBER,
		  LOG_ACT_TEXT  VARCHAR2(200 CHAR),
		CONSTRAINT LOG_ACTIONS_PK PRIMARY KEY (LOG_ACT_ID) ENABLE
		)
		</cfquery>
		<!--- CT_USERS_HOSTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_users_hosts 
		(
		  CT_U_H_USER_ID  VARCHAR2(100 CHAR),
		  CT_U_H_HOST_ID  NUMBER,
		  rec_uuid		  VARCHAR2(100 CHAR),
		  CONSTRAINT CTUH_PK PRIMARY KEY (rec_uuid) ENABLE
		)
		</cfquery>
		<!--- USERS_LOGIN --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE users_login 
		(
		  USER_LOGIN_ID         NUMBER                  NOT NULL,
		  USER_ID               VARCHAR2(100 CHAR),
		  USER_LOGIN_DATE       DATE,
		  USER_LOGIN_TIME       DATE,
		  USER_LOGIN_PROJECT    NUMBER,
		  USER_LOGIN_SESSION    VARCHAR2(200 CHAR),
		  USER_LOGIN_DATESTAMP  DATE
		)
		</cfquery>
		<!--- wisdom --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE wisdom 
		(
		  WIS_ID      NUMBER,
		  WIS_TEXT    VARCHAR2(3000 CHAR),
		  WIS_AUTHOR  VARCHAR2(200 CHAR),
		  CONSTRAINT wisdom_PK PRIMARY KEY (WIS_ID) ENABLE
		)
		</cfquery>
		<!--- USERS_COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE users_comments
		(
		  USER_ID_R           VARCHAR2(100 CHAR),
		  USER_COMMENT        VARCHAR2(4000 CHAR),
		  CREATE_DATE         DATE,
		  CHANGE_DATE         DATE,
		  USER_COMMENT_BY     NUMBER,
		  USER_COMMENT_TITLE  VARCHAR2(500 CHAR),
		  COMMENT_ID          NUMBER
		)
		</cfquery>
		<!--- file_types --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE file_types
		(
		  TYPE_ID              VARCHAR2(5 CHAR)    CONSTRAINT FILE_TYPE_PK PRIMARY KEY,
		  TYPE_TYPE            VARCHAR2(3 CHAR),
		  TYPE_MIMECONTENT     VARCHAR2(50 CHAR),
		  TYPE_MIMESUBCONTENT  VARCHAR2(50 CHAR)
		)
		</cfquery>
		<!--- CT_USERS_REMOTEUSERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_users_remoteusers
		(
		   	CT_U_RU_ID                NUMBER NOT NULL ENABLE, 
			CT_U_RU_USER_ID           VARCHAR2(100 CHAR) NOT NULL ENABLE, 
			CT_U_RU_REMOTE_URL        VARCHAR2(4000 CHAR) NOT NULL ENABLE, 
			CT_U_RU_REMOTE_USER_ID    NUMBER NOT NULL ENABLE, 
			CT_U_RU_REMOTE_USER_NAME  VARCHAR2(4000 CHAR) NOT NULL ENABLE, 
			CT_U_RU_REMOTE_USER_EMAIL VARCHAR2(4000 CHAR), 
			CT_U_RU_REMOTE_CONFIRMED  NUMBER DEFAULT 0 NOT NULL ENABLE, 
			CT_U_RU_UUID              VARCHAR2(4000 CHAR) NOT NULL ENABLE, 
			CT_U_RU_VALIDUNTIL        DATE, 
			CT_U_RU_CONFIRMED         NUMBER DEFAULT 0 NOT NULL ENABLE, 
		CONSTRAINT CT_USERS_REMOTEUSERS_PK PRIMARY KEY (CT_U_RU_ID),
		CONSTRAINT CT_USERS_REMOTEUSERS_UK1 UNIQUE (CT_U_RU_USER_ID, CT_U_RU_REMOTE_URL, CT_U_RU_REMOTE_USER_ID),
		CONSTRAINT CT_USERS_REMOTEUSERS_UK2 UNIQUE (CT_U_RU_UUID),
		CONSTRAINT CT_USERS_REMOTEUSERS_USER_FK1 FOREIGN KEY (CT_U_RU_USER_ID)
				REFERENCES users (USER_ID) ON DELETE CASCADE ENABLE
		)
		</cfquery>
		<!--- WEBSERVICES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE webservices
		(
			SESSIONTOKEN 	VARCHAR2(100 CHAR), 
			TIMEOUT 		TIMESTAMP,
			GROUPOFUSER		VARCHAR2(2000 CHAR),
			USERID			VARCHAR2(100 CHAR),
			CONSTRAINT WEBSERVICES_PK PRIMARY KEY (SESSIONTOKEN)
		)
		</cfquery>
		<!--- SEARCH REINDEX --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE search_reindex
		(
			theid			VARCHAR2(100 CHAR),
			thevalue		NUMBER,
			thehostid		NUMBER,
			datetime		TIMESTAMP
		)
		</cfquery>
		<!--- CREATE TOOLS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE tools
		(
			thetool			VARCHAR2(100 CHAR),
			thepath			VARCHAR2(200 CHAR),
			CONSTRAINT TOOL_PK PRIMARY KEY (thetool)
		)
		</cfquery>
		<!--- CREATE CT_LABELS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_labels
		(
			ct_label_id 	varchar2(100 char),
		 	ct_id_r 		varchar2(100 char),
		 	ct_type 		varchar2(100 char),
		 	rec_uuid		VARCHAR2(100 char),
		 	PRIMARY KEY(rec_uuid)
		)
		</cfquery>
		<!--- CREATE RFS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE rfs
		(
			rfs_id 			varchar2(100 char),
			rfs_active 		number,
			rfs_server_name varchar2(200 char),
			rfs_imagemagick varchar2(200 char),
			rfs_ffmpeg 		varchar2(200 char),
			rfs_dcraw 		varchar2(200 char),
			rfs_exiftool 	varchar2(200 char),
			rfs_mp4box	 	varchar2(200 char),
			rfs_location 	varchar2(200 char),
			rfs_date_add 	timestamp,
			rfs_date_change timestamp,
			CONSTRAINT RFS_PK PRIMARY KEY (rfs_id)
		)
		</cfquery>

		<!--- ct_plugins_hosts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE ct_plugins_hosts
		(
			ct_pl_id_r		varchar2(100 char),
		  	ct_host_id_r	number,
		  	rec_uuid		varchar2(100 char)
		)
		</cfquery>

		<!--- plugins --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE plugins
		(
			p_id 			varchar2(100 char),
			p_path 			varchar2(500 char),
			p_active 		varchar2(5 char) DEFAULT 'false',
			p_name 			varchar2(500 char),
			p_url 			varchar2(500 char),
			p_version 		varchar2(20 char),
			p_author 		varchar2(500 char),
			p_author_url 	varchar2(500 char),
			p_description 	varchar2(2000 char),
			p_license 		varchar2(500 char),
			p_cfc_list 		varchar2(500 char),
			CONSTRAINT PLUGINS_PK PRIMARY KEY (p_id)
		)
		</cfquery>
		
		<!--- plugins_actions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE plugins_actions
		(
			action 			varchar2(200 char),
  			comp 			varchar2(200 char),
  			func 			varchar2(200 char),
  			args 			clob,
  			p_id 			varchar2(100 char),
  			p_remove		varchar2(10 char),
  			host_id 		number
		)
		</cfquery>

		<!--- options --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE options
		(
			opt_id			varchar2(100 char),
			opt_value		clob,
			rec_uuid		varchar2(100 char)
		)
		</cfquery>

		<!--- news --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE news
		(
			news_id			varchar2(100 char),
			news_title		varchar2(500 char),
			news_active		varchar2(6 char),
			news_text		clob,
			news_date		varchar2(20 char),
			CONSTRAINT NEWS_PK PRIMARY KEY (news_id)
		)
		</cfquery>
			
		<!---  --->
		<!--- END: CREATE TABLES --->
		<!---  --->
		<!---  --->
		<!--- START: INSERT VALUES --->
		<!---  --->
		<!--- SEQUENCES
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
		VALUES ('1', 'admin', 'admin@razuna.com', 'SystemAdmin', 'SystemAdmin', '778509C62BD8904D938FB85644EC4712', 'T', 'T', 'T')
		</cfquery>
		<!--- MODULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO modules
		(mod_id, mod_name, mod_short, mod_host_id)
		VALUES(	1, 'razuna', 'ecp', NULL)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO modules
		(mod_id, mod_name, mod_short, mod_host_id)
		VALUES(	2, 'admin', 'adm', NULL)
		</cfquery>
		<!--- DEFAULT ADMIN GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO groups
		(grp_id, grp_name, grp_host_id, grp_mod_id)
		VALUES(	'1', 'SystemAdmin', NULL, 2 )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO groups
		(grp_id, grp_name, grp_host_id, grp_mod_id)
		VALUES(	'2', 'Administrator', NULL, 2	)
		</cfquery>
		<!--- DEFAULT ADMIN CROSS TABLE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO ct_groups_users
		(CT_G_U_GRP_ID, CT_G_U_USER_ID, rec_uuid)
		VALUES(	'1', '1', '#createuuid()#')
		</cfquery>
		<!--- DEFAULT ADMIN permissions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (1,'SystemAdmin',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (2,'Administrator',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (3,'PER_USERS:N',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (4,'PER_USERS:R',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (5,'PER_USERS:W',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (6,'PER_GROUPS:N',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (7,'PER_GROUPS:R',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (8,'PER_GROUPS:W',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (9,'PER_GROUPS_ADMIN:N',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (10,'PER_GROUPS_ADMIN:R',null,1,2,null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		Insert into permissions (PER_ID,PER_KEY,PER_HOST_ID,PER_ACTIVE,PER_MOD_ID,PER_LEVEL) values (11,'PER_GROUPS_ADMIN:W',null,1,2,null)
		</cfquery>
		<!--- DEFAULT ADMIN permissions CROSS TABLE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 1, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 2, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 3, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 4, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 5, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 6, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 7, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 8, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 9, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 10, '1' )
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO	ct_groups_permissions( CT_G_P_PER_ID, CT_G_P_GRP_ID )VALUES( 11, '1' )
		</cfquery>
		<!--- wisdom --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		2, 'In giving advice, seek to help, not please, your friend.', 'Solon')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		3, 'A friend is one to whom you can pour out the contents of your heart, chaff and grain alike. Knowning that the gentlest of hands will take and sift it, keep what is worth keeping, and with a breath of kindness, blow the rest away.'
		, 'Anonymous')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		4, 'The most exciting phrase to hear in science, the one that heralds new discoveries, is not "Eureka" (I found it!) but "That''s funny ..."', 'Isaac Asimov')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		5, 'Everyone should carefully observe which way his heart draws him, and then choose that way with all his strength!'
		, 'Hasidic saying')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		6, 'Mend your speech a little, lest it may mar your fortunes.', 'Shakespeare, King Lear')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		7, 'In preparing for battle I have always found that plans are useless, but planning is indispensable.'
		, 'Dwight D. Eisenhower')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		8, 'It''s all right to aim high if you have plenty of ammunition.', 'Hawley R. Everhart')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		10, 'A great civilization is not concurred from without until it has destroyed itself from within.', 'Will Durant')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		11, 'Travel far enough away, my friend, and you''ll discover something of great beauty: your self', 'Cirque du Soleil')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		1, 'There are Painters who transform the sun to a yellow spot, but there are others who with the help of their art and their intelligence, transform a yellow spot into the sun.', 'Pablo Picasso')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		9, 'The significant problems we have cannot be solved at the same level of thinking with which we created them.'
		, 'Albert Einstein')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		12, 'Acquaintance, n.: A person whom we know well enough to borrow from, but not well enough to lend to. '
		, 'Ambrose Bierce')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		13, 'The best investment is in the tools of one''s trade.', 'Benjamin Franklin')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		14, 'We all agree that your theory is crazy -- but is it crazy enough?', 'Niels Bohr')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		15, 'Genius without education is like silver in the mine.', 'Benjamin Franklin')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		16, 'Anybody can sympathise with the sufferings of a friend, but it requires a very fine nature to sympathise with a friend''s success.', 'Oscar Wilde')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		17, 'Absurdity, n.: A statement or belief manifestly incosistent with one''s own.', 'Ambrose Bierce')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#"> 
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		18, 'There''s no trick to being a humorist when you have the whole government working for you.', 'Will Rogers')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		19, 'The real question is not whether machines think but whether men do. The mystery which surrounds a thinking machine already surrounds a thinking man.', 'B.F.Skinner')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		20, 'That we must all die, we always knew; I wish I had remembered it sooner.', 'Samuel Johnson')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		21, 'The key to living well is first to will that which is necessary and then to love that which is willed.', 'Irving Yalom')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		22, 'Always tell the truth. You will gratify some people and astonish the rest.', 'Mark Twain')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		23, 'See everything. Ignore a lot. Improve a little.', 'Pope John Paul II')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		24, 'Resentment is like taking poison and hoping the other person dies.', 'St. Augustine')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		25, 'Hope is definitely not the same thing as optimism. It is not the conviction that something will turn out well, but the certainty that something makes sense, regardless of how it turns out.', 'Vaclav Havel')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		26, 'We must never be ashamed of our tears, they are rain from heaven washing the dust from our hard hearts.', 'Charles Dickens')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		27, 'Our business in life is not to succeed, but to continue to fail in good spirits.', 'Robert Louis Stevenson')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		28, 'Be who you are and say what you feel because the people who mind don''t matter and the people who matter don''t mind.', 'Theodor Geisel')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		29, 'It is well to remember that the entire universe, with one trifling exception, is composed of others.', 'John Andrew Holmes')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		30, 'Fail to honor people, they fail to honor you.', 'Lao Tzu')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		31, 'You can leave anything out, as long as you know what it is.', 'Ernest Hemingway')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		32, 'The future is here. It''s just not evenly distributed yet.', 'William Gibson')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		33, 'The future always comes too fast and in the wrong order.', 'Alvin Toffler')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		34, 'There will always be people who are ahead of the curve, and people who are behind the curve. But knowledge moves the curve.', 'Bill James')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		35, 'History is a wave that moves through time slightly faster than we do.', 'Kim Stanley Robinson')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		36, 'Inspiration is for amateurs. I just get to work.', 'Chuck Close')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		37, 'The best and most beautiful things in the world cannot be seen or even touched. They must be felt with the heart.', 'Hellen Keller')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		38, 'Small opportunities are often the beginning of great enterprises.', 'Demosthenes')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		39, 'Simplicity is the utlimate sophistication.', 'Leonardo da Vinci')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		40, 'A journey of thousand miles begins with a single step.', 'Lao tzu')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		41, 'What we think, we become.', 'Buddha')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		42, 'Great minds discuss ideas. Average minds discuss events. Small minds discuss people.', 'Eleanor Roosevelt')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		43, 'Forget the place you are trying to get and see the beauty in right now', 'Some wise person')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		44, 'All that we are, is the result of our thoughts.', 'Buddha')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		45, 'Logic will get you from A to B. Imagination will take you everywhere.', 'Albert Einstein')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		46, 'Do not dwell on who let you down, cherish those whoe hold you up.', 'Unknown')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		47, 'People are made to be loved and things are made to be used. The confusion in this world is that people are used and things are loved!', 'Unknown')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		48, 'Make peace with your past so it will not destroy your present.', 'Paulo Coelho')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		49, 'Obstacles are those frightful things you see when you take your eyes off your goal.', 'Henry Ford')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		50, 'I feel like I can not feel.', 'Salvador Dali')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		51, 'To avoid criticism, do nothing, say nothing, and be nothing.', 'Elbert Hubbard')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		52, 'I am not upset that you lied to me, I am upset that from now on I can not believe you anymore.', 'Friedrich Nietzsche')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		53, 'Successful and great people are ordinary people with extraordinary determination.', 'Robert Schuller')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		54, 'Everything has beauty, but not everyone sees it.', 'Confucius')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO wisdom ( WIS_ID, WIS_TEXT, WIS_AUTHOR ) VALUES ( 
		55, 'Wanting to be someone else is a waste of the person you are.', 'Kurt Cobain')
		</cfquery>
		<!--- FILE TYPES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('doc', 'doc', 'application', 'vnd.ms-word')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('docx', 'doc', 'application', 'vnd.ms-word')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('xls', 'doc', 'application', 'vnd.ms-excel')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('xlsx', 'doc', 'application', 'vnd.ms-excel')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ppt', 'doc', 'application', 'vnd.ms-powerpoint')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pptx', 'doc', 'application', 'vnd.ms-powerpoint')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pdf', 'doc', 'application', 'pdf')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('txt', 'doc', 'application', 'txt')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('psd', 'img', 'application', 'photoshop')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('eps', 'img', 'application', 'eps')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ai', 'img', 'application', 'photoshop')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('jpg', 'img', 'image', 'jpg')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('jpeg', 'img', 'image', 'jpeg')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('gif', 'img', 'image', 'gif')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('png', 'img', 'image', 'png')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('bmp', 'img', 'image', 'bmp')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('cal', 'img', null, null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('dcm', 'img', null, null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('fpx', 'img', 'image', 'vnd.fpx')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pbm', 'img', 'image', 'pbm')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pgm', 'img', 'image', 'x-portable-graymap')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ppm', 'img', 'image', 'x-portable-pixmap')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pnm', 'img', 'image', 'x-portable-anymap')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pcx', 'img', 'image', 'pcx')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pct', 'img', null, null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('rpx', 'img', null, null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ras', 'img', 'image', 'ras')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('tga', 'img', 'image', 'tga')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('tif', 'img', 'image', 'tif')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('tiff', 'img', 'image', 'tiff')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('wbmp', 'img', 'image', 'vnd.wap.wbmp')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('nef', 'img', 'image', 'nef')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('swf', 'vid', 'application', 'x-shockwave-flash')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('flv', 'vid', 'application', 'x-shockwave-flash')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('f4v', 'vid', 'application', 'x-shockwave-flash')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mov', 'vid', 'video', 'quicktime')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('m4v', 'vid', 'video', 'quicktime')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('avi', 'vid', 'video', 'avi')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('3gp', 'vid', 'video', '3gpp')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('rm', 'vid', 'application', 'vnd.rn-realmedia')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mpg', 'vid', 'video', 'mpeg')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mp4', 'vid', 'video', 'mp4v-es')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('wmv', 'vid', 'video', 'x-ms-wmv')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('vob', 'vid', 'video', 'mpeg')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ogv', 'vid', 'video', 'ogv')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('webm', 'vid', 'video', 'webm')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mts', 'vid', 'video', 'mts')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('m2ts', 'vid', 'video', 'm2ts')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('m2t', 'vid', 'video', 'm2t')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('aff', 'aud', null, null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('aft', 'aud', null, null)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('au', 'aud', 'audio', 'basic')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ram', 'aud', 'audio', 'x-pn-realaudio')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('wav', 'aud', 'audio', 'x-wav')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mp3', 'aud', 'audio', 'mpeg')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('aiff', 'aud', 'audio', 'x-aiff')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('aif', 'aud', 'audio', 'x-aiff')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('aifc', 'aud', 'audio', 'x-aiff')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('snd', 'aud', 'audio', 'basic')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mid', 'aud', 'audio', 'mid')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('m3u', 'aud', 'audio', 'x-mpegurl')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('rmi', 'aud', 'audio', 'mid')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ra', 'aud', 'audio', 'x-pn-realaudio')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('flac', 'aud', 'audio', 'flac')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ogg', 'aud', 'audio', 'ogg')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('m4a', 'aud', 'audio', 'x-m4a')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('arw', 'img', 'image', 'arw')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('cr2', 'img', 'image', 'cr2')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('crw', 'img', 'image', 'crw')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ciff', 'img', 'image', 'ciff')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('cs1', 'img', 'image', 'cs1')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('erf', 'img', 'image', 'erf')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mef', 'img', 'image', 'mef')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mrw', 'img', 'image', 'mrw')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('nrw', 'img', 'image', 'nrw')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('pef', 'img', 'image', 'pef')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('psb', 'img', 'application', 'photoshop')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('raf', 'img', 'image', 'raf')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('raw', 'img', 'image', 'raw')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('rw2', 'img', 'image', 'rw2')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('rwl', 'img', 'image', 'rwl')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('srw', 'img', 'image', 'srw')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('3fr', 'img', 'image', '3fr')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ari', 'img', 'image', 'ari')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('srf', 'img', 'image', 'srf')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('sr2', 'img', 'image', 'sr2')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('bay', 'img', 'image', 'bay')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('cap', 'img', 'image', 'cap')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('iiq', 'img', 'image', 'iiq')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('eip', 'img', 'image', 'eip')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('dcr', 'img', 'image', 'dcr')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('drf', 'img', 'image', 'drf')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('k25', 'img', 'image', 'k25')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('kdc', 'img', 'image', 'kdc')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('dng', 'img', 'image', 'dng')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('fff', 'img', 'image', 'fff')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mos', 'img', 'image', 'mos')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('orf', 'img', 'image', 'orf')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('ptx', 'img', 'image', 'ptx')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('r3d', 'img', 'image', 'r3d')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('rwz', 'img', 'image', 'rwz')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('x3f', 'img', 'image', 'x3f')
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		INSERT INTO file_types VALUES ('mxf', 'vid', 'video', 'mxf')
		</cfquery>
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
		<cfset arguments.thestruct.theschema = application.razuna.theschema>
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
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#assets_temp 
		(
			TEMPID 			VARCHAR2(200 CHAR), 
			FILENAME 		VARCHAR2(255 CHAR), 
			EXTENSION 		VARCHAR2(20 CHAR), 
			DATE_ADD 		TIMESTAMP, 
			FOLDER_ID		VARCHAR2(100 CHAR), 
			WHO				VARCHAR2(100 CHAR), 
			FILENAMENOEXT	VARCHAR2(255 CHAR), 
			PATH 			CLOB, 
			MIMETYPE		VARCHAR2(255 CHAR), 
			THESIZE			VARCHAR2(100 CHAR),
			GROUPID			VARCHAR2(100 CHAR),
			SCHED_ACTION	NUMBER,
			SCHED_ID		VARCHAR2(100 CHAR),
			FILE_ID			VARCHAR2(100 CHAR),
			LINK_KIND		VARCHAR2(20 CHAR),
			HOST_ID			NUMBER,
			md5hash			VARCHAR2(100 CHAR),
			CONSTRAINT #arguments.thestruct.host_db_prefix#ASSETSTEMP PRIMARY KEY (TEMPID)
		)
		
		</cfquery>
		
		<!--- XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#xmp 
		(
			id_r					VARCHAR2(100 CHAR),
			asset_type				VARCHAR2(10 CHAR),
			subjectcode				VARCHAR2(300 CHAR),
			creator					VARCHAR2(300 CHAR),
			title					VARCHAR2(500 CHAR),
			authorsposition			VARCHAR2(300 CHAR),
			captionwriter			VARCHAR2(300 CHAR),
			ciadrextadr				VARCHAR2(300 CHAR),
			category				VARCHAR2(300 CHAR),
			supplementalcategories	CLOB,
			urgency					VARCHAR2(300 CHAR),
			description				CLOB,
			ciadrcity				VARCHAR2(300 CHAR),
			ciadrctry				VARCHAR2(300 CHAR),
			location				VARCHAR2(300 CHAR),
			ciadrpcode				VARCHAR2(300 CHAR),
			ciemailwork				VARCHAR2(300 CHAR),
			ciurlwork				VARCHAR2(300 CHAR),
			citelwork				VARCHAR2(300 CHAR),
			intellectualgenre		VARCHAR2(300 CHAR),
			instructions			CLOB,
			source					VARCHAR2(300 CHAR),
			usageterms				CLOB,
			copyrightstatus			CLOB,
			transmissionreference	VARCHAR2(300 CHAR),
			webstatement			CLOB,
			headline				VARCHAR2(500 CHAR),
			datecreated				VARCHAR2(200 CHAR),
			city					VARCHAR2(300 CHAR),
			ciadrregion				VARCHAR2(300 CHAR),
			country					VARCHAR2(300 CHAR),
			countrycode				VARCHAR2(300 CHAR),
			scene					VARCHAR2(300 CHAR),
			state					VARCHAR2(300 CHAR),
			credit					VARCHAR2(300 CHAR),
			rights					CLOB,
			colorspace				varchar2(50 char),
			xres					varchar2(30 char),
			yres					varchar2(30 char),
			resunit					varchar2(20 char),
			HOST_ID					NUMBER
		)  
		
		</cfquery>
		
		<!--- CART --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#cart
		(
		  CART_ID           	VARCHAR2(200 CHAR),
		  USER_ID           	VARCHAR2(100 CHAR),
		  CART_QUANTITY     	NUMBER,
		  CART_PRODUCT_ID   	VARCHAR2(100 CHAR),
		  CART_CREATE_DATE  	DATE,
		  CART_CREATE_TIME  	TIMESTAMP,
		  CART_CHANGE_DATE  	DATE,
		  CART_CHANGE_TIME  	TIMESTAMP,
		  CART_FILE_TYPE    	VARCHAR2(5 CHAR),
		  cart_order_email 		varchar2(150 CHAR),
		  cart_order_message 	varchar2(2000 CHAR), 
		  cart_order_done 		varchar2(1 CHAR), 
		  cart_order_date 		timestamp,
		  cart_order_user_r 	VARCHAR2(100 CHAR),
		  HOST_ID				NUMBER
		)
		
		</cfquery>
		
		<!--- FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders
		(
		  FOLDER_ID             VARCHAR2(100 CHAR),
		  FOLDER_NAME           VARCHAR2(200 CHAR),
		  FOLDER_LEVEL          NUMBER,
		  FOLDER_ID_R           VARCHAR2(100 CHAR),
		  FOLDER_MAIN_ID_R      VARCHAR(100),
		  FOLDER_OWNER          VARCHAR(100),
		  FOLDER_CREATE_DATE    DATE,
		  FOLDER_CREATE_TIME    TIMESTAMP,
		  FOLDER_CHANGE_DATE    DATE,
		  FOLDER_CHANGE_TIME    TIMESTAMP,
		  FOLDER_IS_IMG_FOLDER  VARCHAR2(2 CHAR),
		  FOLDER_IMG_PUB_ID     NUMBER,
		  FOLDER_OF_USER        VARCHAR2(2 CHAR) DEFAULT NULL,
		  FOLDER_IS_COLLECTION  VARCHAR2(2 CHAR) DEFAULT NULL,
		  FOLDER_IS_VID_FOLDER  VARCHAR2(2 CHAR),
		  FOLDER_VID_PUB_ID		NUMBER,
		  FOLDER_AVAILABLE_DSC  NUMBER DEFAULT 1,
		  FOLDER_SHARED			VARCHAR2(2 CHAR) DEFAULT 'F',
		  FOLDER_NAME_SHARED	VARCHAR2(200 CHAR),
		  LINK_PATH				VARCHAR2(200 CHAR),
		  share_dl_org			varchar2(1 char) DEFAULT 'f',
		  share_dl_thumb		varchar2(1 char) DEFAULT 't',
     	  share_comments		varchar2(1 char) DEFAULT 'f',
		  share_upload			varchar2(1 char) DEFAULT 'f',
		  share_order			varchar2(1 char) DEFAULT 'f',
		  share_order_user		VARCHAR2(100 CHAR),
		  HOST_ID				NUMBER,
		  IN_TRASH			   	VARCHAR2(2 CHAR) DEFAULT 'F',
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDER_PK PRIMARY KEY (FOLDER_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDERS_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- FOLDERS DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_desc
		(
		  FOLDER_ID_R  	VARCHAR2(100 CHAR),
		  LANG_ID_R    	NUMBER,
		  FOLDER_DESC  	CLOB,
		  HOST_ID		NUMBER,
		  rec_uuid		VARCHAR2(100 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FD_PK PRIMARY KEY (rec_uuid) ENABLE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDERS_DESC_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- FOLDERS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_groups
		(
		  FOLDER_ID_R     	VARCHAR2(100 CHAR),
		  GRP_ID_R        	VARCHAR2(100 CHAR),
		  GRP_PERMISSION  	VARCHAR2(2 CHAR),
		  HOST_ID			NUMBER,
		  rec_uuid			VARCHAR2(100 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FG_PK PRIMARY KEY (rec_uuid) ENABLE,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FOLDERS_GROUPS_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- FILES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files
		(
		  FILE_ID              	VARCHAR2(100 CHAR),
		  FOLDER_ID_R          	VARCHAR2(100 CHAR) DEFAULT NULL,
		  FILE_CREATE_DATE     	DATE,
		  FILE_CREATE_TIME     	TIMESTAMP,
		  FILE_CHANGE_DATE     	DATE,
		  FILE_CHANGE_TIME     	TIMESTAMP,
		  FILE_OWNER           	VARCHAR2(100 CHAR),
		  FILE_TYPE            	VARCHAR2(5 CHAR),
		  FILE_NAME            	VARCHAR2(500 CHAR),
		  FILE_EXTENSION       	VARCHAR2(20 CHAR),
		  FILE_NAME_NOEXT      	VARCHAR2(200 CHAR),
		  FILE_CONTENTTYPE     	VARCHAR2(100 CHAR),
		  FILE_CONTENTSUBTYPE  	VARCHAR2(100 CHAR),
		  FILE_REMARKS         	CLOB,
		  FILE_ONLINE          	VARCHAR2(2 CHAR),
		  FILE_NAME_ORG        	VARCHAR2(200 CHAR),
		  FILE_SIZE			   	VARCHAR2(100 CHAR),
		  LUCENE_KEY		   	VARCHAR2(2000 CHAR),
		  SHARED			   	VARCHAR2(2 CHAR) DEFAULT 'F',
		  LINK_KIND			   	VARCHAR2(20 CHAR),
		  LINK_PATH_URL		   	VARCHAR2(2000 CHAR),
		  FILE_META				CLOB,
		  HOST_ID				NUMBER,
		  PATH_TO_ASSET		    VARCHAR2(500 CHAR),
		  CLOUD_URL				VARCHAR2(500 CHAR),
		  CLOUD_URL_ORG		   	VARCHAR2(500 CHAR),
		  HASHTAG			   	VARCHAR2(100 CHAR),
		  IS_AVAILABLE			VARCHAR2(1) DEFAULT 0,
		  CLOUD_URL_EXP		   	NUMBER,
		  IN_TRASH			   	VARCHAR2(2 CHAR) DEFAULT 'F',
		  IS_INDEXED		  	VARCHAR2(1 CHAR) DEFAULT 0,
		  FILE_UPC_NUMBER		VARCHAR2(15 CHAR),
		  EXPIRY_DATE DATE,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FILE_PK PRIMARY KEY (FILE_ID),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FILES_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		</cfquery>
		
		<!--- FILES DESC --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_desc
		(
		  ID_INC		 VARCHAR2(100 CHAR) NOT NULL,
		  FILE_ID_R      VARCHAR2(100 CHAR),
		  LANG_ID_R      NUMBER,
		  FILE_DESC      VARCHAR2(4000 CHAR),
		  FILE_KEYWORDS  VARCHAR2(4000 CHAR),
		  HOST_ID		 NUMBER,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#FILES_DESC_PK PRIMARY KEY (ID_INC)
		)
		
		</cfquery>
		
		<!--- IMAGES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images
		(
		  IMG_ID              VARCHAR2(100 CHAR),
		  METABLOB        	  VARCHAR2(2 CHAR),
		  METAEXIF            VARCHAR2(2 CHAR),
		  METAIPTC            VARCHAR2(2 CHAR),
		  METAXMP             VARCHAR2(2 CHAR),
		  IMAGE               VARCHAR2(2 CHAR),
		  THUMB               VARCHAR2(2 CHAR),
		  COMP                VARCHAR2(2 CHAR),
		  COMP_UW             VARCHAR2(2 CHAR),
		  IMG_GROUP           VARCHAR2(100 CHAR) DEFAULT NULL,
		  IMG_PUBLISHER       VARCHAR2(200 CHAR),
		  IMG_FILENAME        VARCHAR2(500 CHAR),
		  FOLDER_ID_R         VARCHAR2(100 CHAR) DEFAULT NULL,
		  IMG_CUSTOM_ID       VARCHAR2(500 CHAR),
		  IMG_ONLINE          VARCHAR2(2 CHAR),
		  IMG_OWNER           VARCHAR2(100 CHAR),
		  IMG_CREATE_DATE     DATE,
		  IMG_CREATE_TIME     TIMESTAMP,
		  IMG_CHANGE_DATE     DATE,
		  IMG_CHANGE_TIME     TIMESTAMP,
		  IMG_RANKING         NUMBER,
		  IMG_SINGLE_SALE     VARCHAR2(2 CHAR),
		  IMG_IS_NEW          VARCHAR2(2 CHAR),
		  IMG_SELECTION       VARCHAR2(2 CHAR),
		  IMG_IN_PROGRESS     VARCHAR2(2 CHAR),
		  IMG_ALIGNMENT       VARCHAR2(200 CHAR),
		  IMG_LICENSE         VARCHAR2(200 CHAR),
		  IMG_DOMINANT_COLOR  VARCHAR2(200 CHAR),
		  IMG_COLOR_MODE      VARCHAR2(200 CHAR),
		  IMG_IMAGE_TYPE      VARCHAR2(200 CHAR),
		  IMG_CATEGORY_ONE    CLOB,
		  IMG_REMARKS         CLOB,
		  IMG_EXTENSION       VARCHAR2(20 CHAR),
		  THUMB_EXTENSION	  VARCHAR2(20 CHAR),
		  THUMB_WIDTH         NUMBER,
		  THUMB_HEIGHT        NUMBER,
		  IMG_FILENAME_ORG    VARCHAR2(500 CHAR),
		  IMG_WIDTH           NUMBER,
  		  IMG_HEIGHT          NUMBER,
	 	  IMG_SIZE            VARCHAR2(100 CHAR),
  		  THUMB_SIZE          VARCHAR2(100 CHAR),
		  LUCENE_KEY		  VARCHAR2(2000 CHAR),
		  SHARED			  VARCHAR2(2 CHAR) DEFAULT 'F',
		  LINK_KIND			  VARCHAR2(20 CHAR),
		  LINK_PATH_URL		  VARCHAR2(2000 CHAR),
		  IMG_META			  CLOB,
		  HOST_ID			  NUMBER,
		  PATH_TO_ASSET		  VARCHAR2(500 CHAR),
		  CLOUD_URL			  VARCHAR2(500 CHAR),
		  CLOUD_URL_ORG		  VARCHAR2(500 CHAR),
		  HASHTAG			  VARCHAR2(100 CHAR),
		  IS_AVAILABLE		  VARCHAR2(1) DEFAULT 0,
		  CLOUD_URL_EXP		  NUMBER,
		  IN_TRASH			  VARCHAR2(2 CHAR) DEFAULT 'F',
		  IS_INDEXED		  VARCHAR2(1 CHAR) DEFAULT 0,
		  IMG_UPC_NUMBER	  VARCHAR2(15 CHAR),
		  EXPIRY_DATE DATE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#IMAGE_PK PRIMARY KEY (IMG_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#IMAGE_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- IMAGES CLOB --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images_text
		(
		  ID_INC		   VARCHAR2(100 CHAR),
		  IMG_ID_R         VARCHAR2(100 CHAR) NOT NULL,
		  LANG_ID_R        NUMBER NOT NULL,
		  IMG_KEYWORDS     VARCHAR2(4000 CHAR),
		  IMG_DESCRIPTION  VARCHAR2(4000 CHAR),
		  HOST_ID		 NUMBER,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#IMAGES_TEXT_PK PRIMARY KEY (ID_INC),
		CONSTRAINT #arguments.thestruct.host_db_prefix#IMAGE_TEXT_FK_IMG FOREIGN KEY (IMG_ID_R)
	REFERENCES #arguments.thestruct.host_db_prefix#images (IMG_ID)
	ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- LOG ASSETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_assets
		(
		  LOG_ID			VARCHAR2(100 CHAR) NOT NULL, 
		  LOG_USER			VARCHAR2(100 CHAR), 
		  LOG_ACTION		VARCHAR2(100 CHAR), 
		  LOG_DATE			DATE, 
		  LOG_TIME			TIMESTAMP, 
		  LOG_DESC			VARCHAR2(500 CHAR), 
		  LOG_FILE_TYPE		VARCHAR2(5 CHAR), 
		  LOG_BROWSER		VARCHAR2(500 CHAR), 
		  LOG_IP			VARCHAR2(200 CHAR), 
		  LOG_TIMESTAMP		TIMESTAMP, 
		  HOST_ID			NUMBER,
		  ASSET_ID_R		VARCHAR2(100 CHAR),
		  FOLDER_ID			VARCHAR2(100 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_ASSETS_PK PRIMARY KEY (LOG_ID)
		)
		
		</cfquery>
		
		<!--- LOG FOLDERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_folders
		(
		  LOG_ID			VARCHAR2(100 CHAR) NOT NULL, 
		  LOG_USER			VARCHAR2(100 CHAR), 
		  LOG_ACTION		VARCHAR2(100 CHAR), 
		  LOG_DATE			DATE, 
		  LOG_TIME			TIMESTAMP, 
		  LOG_DESC			VARCHAR2(500 CHAR), 
		  LOG_BROWSER		VARCHAR2(500 CHAR), 
		  LOG_IP			VARCHAR2(200 CHAR), 
		  LOG_TIMESTAMP		TIMESTAMP, 
		  HOST_ID			NUMBER,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_FOLDERS_PK PRIMARY KEY (LOG_ID)
		)
		
		</cfquery>
		
		<!--- LOG USERS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_users
		(
		  LOG_ID			VARCHAR2(100 CHAR) NOT NULL, 
		  LOG_USER			VARCHAR2(100 CHAR), 
		  LOG_ACTION		VARCHAR2(100 CHAR), 
		  LOG_DATE			DATE, 
		  LOG_TIME			TIMESTAMP, 
		  LOG_DESC			VARCHAR2(500 CHAR), 
		  LOG_BROWSER		VARCHAR2(500 CHAR), 
		  LOG_IP			VARCHAR2(200 CHAR), 
		  LOG_TIMESTAMP		TIMESTAMP,
		  LOG_SECTION		VARCHAR2(10 CHAR),
		  HOST_ID			NUMBER,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_USERS_PK PRIMARY KEY (LOG_ID)
		)
		
		</cfquery>
		
		<!--- LOG SEARCH --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_search
		(
		  LOG_ID          	VARCHAR2(100 CHAR) NOT NULL,
		  LOG_USER        	VARCHAR2(100 CHAR),
		  LOG_DATE        	DATE,
		  LOG_TIME        	TIMESTAMP,
		  LOG_SEARCH_FOR  	VARCHAR2(2000 CHAR),
		  LOG_FOUNDITEMS  	NUMBER,
		  LOG_SEARCH_FROM 	VARCHAR2(50 CHAR),
		  LOG_TIMESTAMP   	TIMESTAMP,
		  LOG_BROWSER     	VARCHAR2(500 CHAR), 
		  LOG_IP 		  	VARCHAR2(200 CHAR), 
		  HOST_ID			NUMBER,
		CONSTRAINT #arguments.thestruct.host_db_prefix#LOG_SEARCH_PK PRIMARY KEY (LOG_ID)
		)
		
		</cfquery>
		
		<!--- SETTINGS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings
		(
		  SET_ID    VARCHAR2(500 CHAR) NOT NULL,
		  SET_PREF  CLOB,
		  HOST_ID	NUMBER,
		  rec_uuid			VARCHAR(100),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#settings_PK PRIMARY KEY (rec_uuid) ENABLE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#SETTINGS_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES hosts (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- SETTINGS 2 --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings_2
		(
		  SET2_ID                       NUMBER NOT NULL,
		  SET2_DATE_FORMAT              VARCHAR2(20 CHAR),
		  SET2_DATE_FORMAT_DEL          VARCHAR2(3 CHAR),
		  SET2_META_KEYWORDS            CLOB,
		  SET2_META_DESC                CLOB,
		  SET2_META_AUTHOR              VARCHAR2(200 CHAR),
		  SET2_META_PUBLISHER           VARCHAR2(200 CHAR),
		  SET2_META_COPYRIGHT           VARCHAR2(200 CHAR),
		  SET2_META_ROBOTS              VARCHAR2(200 CHAR),
		  SET2_META_REVISIT             VARCHAR2(200 CHAR),
		  SET2_META_CUSTOM              CLOB,
		  SET2_URL_SP_ORIGINAL          VARCHAR2(2 CHAR),
		  SET2_URL_SP_THUMB             VARCHAR2(2 CHAR),
		  SET2_URL_SP_COMP              VARCHAR2(2 CHAR),
		  SET2_URL_SP_COMP_UW           VARCHAR2(2 CHAR),
		  SET2_INTRANET_LOGO            VARCHAR2(2 CHAR),
		  SET2_URL_APP_SERVER           VARCHAR2(2 CHAR),
		  SET2_ORA_PATH_INTERNAL        VARCHAR2(2 CHAR),
		  SET2_CREATE_IMGFOLDERS_WHERE  NUMBER,
		  SET2_IMG_FORMAT               VARCHAR2(4 CHAR),
		  SET2_IMG_THUMB_WIDTH          NUMBER,
		  SET2_IMG_THUMB_HEIGTH         NUMBER,
		  SET2_IMG_COMP_WIDTH           NUMBER,
		  SET2_IMG_COMP_HEIGTH          NUMBER,
		  SET2_IMG_DOWNLOAD_ORG         VARCHAR2(2 CHAR),
		  SET2_DOC_DOWNLOAD             VARCHAR2(2 CHAR),
		  SET2_INTRANET_REG_EMAILS      VARCHAR2(2 CHAR),
		  SET2_INTRANET_REG_EMAILS_SUB  VARCHAR2(2 CHAR),
		  SET2_INTRANET_GEN_DOWNLOAD    VARCHAR2(2 CHAR),
		  SET2_CAT_WEB                  VARCHAR2(2 CHAR),
		  SET2_CAT_INTRA                VARCHAR2(2 CHAR),
		  SET2_URL_WEBSITE              VARCHAR2(200 CHAR),
		  SET2_PAYMENT_PRE              VARCHAR2(2 CHAR),
		  SET2_PAYMENT_BILL             VARCHAR2(2 CHAR),
		  SET2_PAYMENT_POD              VARCHAR2(2 CHAR),
		  SET2_PAYMENT_CC               VARCHAR2(2 CHAR),
		  SET2_PAYMENT_CC_CARDS         VARCHAR2(500 CHAR),
		  SET2_PAYMENT_PAYPAL           VARCHAR2(2 CHAR),
		  SET2_PATH_IMAGEMAGICK         VARCHAR2(200 CHAR),
		  SET2_EMAIL_SERVER             VARCHAR2(200 CHAR),
		  SET2_EMAIL_FROM               VARCHAR2(200 CHAR),
		  SET2_EMAIL_SMTP_USER          VARCHAR2(200 CHAR),
		  SET2_EMAIL_SMTP_PASSWORD      VARCHAR2(200 CHAR),
		  SET2_EMAIL_SERVER_PORT        NUMBER,
		  SET2_EMAIL_USE_SSL			VARCHAR2(5 CHAR) DEFAULT 'false',
		  SET2_EMAIL_USE_TLS			VARCHAR2(5 CHAR) DEFAULT 'false',
		  SET2_ORA_PATH_INCOMING		VARCHAR2(2 CHAR),
		  SET2_ORA_PATH_INCOMING_BATCH	VARCHAR2(2 CHAR),
		  SET2_ORA_PATH_OUTGOING		VARCHAR2(2 CHAR),
		  SET2_VID_PREVIEW_HEIGTH		NUMBER,
		  SET2_VID_PREVIEW_WIDTH		NUMBER,
		  SET2_PATH_FFMPEG				VARCHAR2(200 CHAR),
		  SET2_VID_PREVIEW_TIME			VARCHAR2(10 CHAR),
		  SET2_VID_PREVIEW_START		VARCHAR2(10 CHAR),
		  SET2_URL_SP_VIDEO				VARCHAR2(2 CHAR),
		  SET2_URL_SP_VIDEO_PREVIEW		VARCHAR2(2 CHAR),
		  SET2_VID_PREVIEW_AUTHOR		VARCHAR2(200 CHAR),
		  SET2_VID_PREVIEW_COPYRIGHT	VARCHAR2(200 CHAR),
		  SET2_CAT_VID_WEB				VARCHAR2(2 CHAR),
		  SET2_CAT_VID_INTRA			VARCHAR2(2 CHAR),
		  SET2_CAT_AUD_WEB				VARCHAR2(2 CHAR),
		  SET2_CAT_AUD_INTRA			VARCHAR2(2 CHAR),
		  SET2_CREATE_VIDFOLDERS_WHERE	NUMBER,
		  SET2_PATH_TO_ASSETS			VARCHAR2(500 CHAR),
		  SET2_PATH_TO_EXIFTOOL         VARCHAR2(300 CHAR),
		  SET2_NIRVANIX_NAME			VARCHAR2(500 CHAR),
		  SET2_NIRVANIX_PASS			VARCHAR2(500 CHAR),
		  HOST_ID						NUMBER,
		  SET2_AWS_BUCKET				VARCHAR2(100 CHAR),
		  SET2_LABELS_USERS				CLOB,
		  SET2_MD5CHECK					VARCHAR2(5 CHAR) DEFAULT 'false',
		  SET2_AKA_URL					VARCHAR2(500 CHAR),
		  SET2_AKA_IMG					VARCHAR2(200 CHAR),
		  SET2_AKA_VID					VARCHAR2(200 CHAR),
		  SET2_AKA_AUD					VARCHAR2(200 CHAR),
		  SET2_AKA_DOC					VARCHAR2(200 CHAR),
		  SET2_COLORSPACE_RGB			VARCHAR2(5 CHAR) DEFAULT 'false',
		  SET2_CUSTOM_FILE_EXT			VARCHAR2(5 CHAR) DEFAULT 'true',
		  SET2_RENDITION_METADATA		VARCHAR2(5 CHAR) DEFAULT 'false',
		  rec_uuid						VARCHAR2(100 CHAR),
		  SET2_UPC_ENABLED				VARCHAR2(5 CHAR) DEFAULT 'false',
		  SET2_NEW_USER_EMAIL_SUB  VARCHAR2(200 CHAR),
		  SET2_NEW_USER_EMAIL_BODY  VARCHAR2(4000 CHAR),
		  SET2_DUPLICATES_EMAIL_SUB  	VARCHAR(50),
		  SET2_DUPLICATES_EMAIL_BODY  	VARCHAR(1000),SET2_FOLDER_SUBSCRIBE_EMAIL_SUB  	VARCHAR2(50 CHAR),
		  SET2_FOLDER_SUBSCRIBE_EMAIL_BODY  	VARCHAR2(1000 CHAR),
		  SET2_ASSET_EXPIRY_EMAIL_SUB  	VARCHAR2(50 CHAR),
		  SET2_ASSET_EXPIRY_EMAIL_BODY  	VARCHAR2(1000 CHAR),
		  SET2_DUPLICATES_EMAIL_SUB  	VARCHAR2(50 CHAR),
		  SET2_DUPLICATES_EMAIL_BODY  	VARCHAR2(2000 CHAR),
		  SET2_DUPLICATES_META  	VARCHAR2(2000 CHAR),
		  SET2_FOLDER_SUBSCRIBE_META  	VARCHAR2(2000 CHAR),
		  SET2_ASSET_EXPIRY_META  	VARCHAR2(2000 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#SETTINGS2_PK PRIMARY KEY (rec_uuid) ENABLE,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#SETTINGS2_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES hosts (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- TEMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#temp
		(
		  TMP_TOKEN     VARCHAR2(100 CHAR),
		  TMP_FILENAME  VARCHAR2(2000 CHAR),
		  HOST_ID		NUMBER
		)
		
		</cfquery>
		
		<!--- COLLECTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections
		(
		  COL_ID        	VARCHAR2(100 CHAR) NOT NULL,
		  FOLDER_ID_R   	VARCHAR2(100 CHAR) DEFAULT NULL,
		  COL_OWNER     	VARCHAR2(100 CHAR),
		  CREATE_DATE   	DATE,
		  CREATE_TIME   	TIMESTAMP,
		  CHANGE_DATE   	DATE,
		  CHANGE_TIME   	TIMESTAMP,
		  COL_TEMPLATE  	VARCHAR2(100 CHAR),
		  COL_SHARED		VARCHAR2(2 CHAR) DEFAULT 'F',
		  COL_NAME_SHARED	VARCHAR2(200 CHAR),
		  share_dl_org		varchar2(1 char) DEFAULT 'f',
		  share_dl_thumb	varchar2(1 char) DEFAULT 't',
     	  share_comments	varchar2(1 char) DEFAULT 'f',
		  share_upload		varchar2(1 char) DEFAULT 'f',
		  share_order		varchar2(1 char) DEFAULT 'f',
		  share_order_user	VARCHAR2(100 CHAR),
		  col_released		VARCHAR2(5 CHAR) DEFAULT 'false',
		  col_copied_from	VARCHAR2(100 CHAR),
		  HOST_ID			NUMBER,
		  IN_TRASH			VARCHAR2(2 CHAR) DEFAULT 'F',
		CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_PK PRIMARY KEY (COL_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES hosts (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- COLLECTIONS CLOB --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_text
		(
		  COL_ID_R      VARCHAR2(100 CHAR),
		  LANG_ID_R     NUMBER,
		  COL_DESC      VARCHAR2(4000 CHAR),
		  COL_KEYWORDS  VARCHAR2(4000 CHAR),
		  COL_NAME      VARCHAR2(200 CHAR),
		  HOST_ID		 NUMBER,
		  rec_uuid			VARCHAR2(100 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#COLCT_PK PRIMARY KEY (rec_uuid) ENABLE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_TEXT_#arguments.thestruct.host_db_prefix#FK1 FOREIGN KEY (COL_ID_R)
	REFERENCES #arguments.thestruct.host_db_prefix#collections (COL_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- COLLECTIONS FILES CROSS TABLE --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_ct_files
		(
		  COL_ID_R       	VARCHAR2(100 CHAR),
		  FILE_ID_R      	VARCHAR2(100 CHAR),
		  COL_FILE_TYPE  	VARCHAR2(5 CHAR),
		  COL_ITEM_ORDER  	NUMBER,
		  COL_FILE_FORMAT  	VARCHAR2(100 CHAR),
		  HOST_ID		 	NUMBER,
		  rec_uuid			VARCHAR2(100 CHAR),
		  IN_TRASH			VARCHAR2(2 CHAR) DEFAULT 'F',
		  CONSTRAINT #arguments.thestruct.host_db_prefix#CCTF_PK PRIMARY KEY (rec_uuid) ENABLE
		)
		
		</cfquery>
		
		<!--- COLLECTIONS GROUPS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_groups
		(
		  COL_ID_R       	VARCHAR2(100 CHAR),
		  GRP_ID_R			VARCHAR2(100 CHAR),
		  GRP_PERMISSION	VARCHAR2(2 CHAR),
		  HOST_ID		 	NUMBER,
		  rec_uuid			VARCHAR2(100 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#COLCG_PK PRIMARY KEY (rec_uuid) ENABLE,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#COLLECTIONS_GROUPS_FK1 FOREIGN KEY (COL_ID_R)
	      REFERENCES #arguments.thestruct.host_db_prefix#collections (COL_ID) ON DELETE SET NULL ENABLE
		)
		
		</cfquery>
		
		<!--- USER FAVORITES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_favorites
		(
		  USER_ID_R  	VARCHAR2(100 CHAR),
		  FAV_TYPE   	VARCHAR2(8 CHAR),
		  FAV_ID     	VARCHAR2(100 CHAR),
		  FAV_KIND   	VARCHAR2(8 CHAR),
		  FAV_ORDER  	NUMBER,
		  HOST_ID		NUMBER,
		  rec_uuid			VARCHAR2(100 CHAR),
		  CONSTRAINT #arguments.thestruct.host_db_prefix#UF_PK PRIMARY KEY (rec_uuid) ENABLE,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#USERS_FAVORITES_FK1 FOREIGN KEY (USER_ID_R)
	      REFERENCES USERS (USER_ID) ON DELETE SET NULL ENABLE
		)
		
		</cfquery>
		
		<!--- VIDEOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos
		(
		VID_ID					VARCHAR2(100 CHAR),
		VID_FILENAME			VARCHAR2(500 CHAR),
		FOLDER_ID_R				VARCHAR2(100 CHAR),
		VID_CUSTOM_ID			VARCHAR2(500 CHAR),
		VID_ONLINE				VARCHAR2(2 CHAR),
		VID_OWNER				VARCHAR2(100 CHAR),
		VID_CREATE_DATE			DATE,
		VID_CREATE_TIME			TIMESTAMP,
		VID_CHANGE_DATE			DATE,
		VID_CHANGE_TIME			TIMESTAMP,
		VID_RANKING				NUMBER,
		VID_SINGLE_SALE			VARCHAR2(2 CHAR),
		VID_IS_NEW				VARCHAR2(2 CHAR),
		VID_SELECTION			VARCHAR2(2 CHAR),
		VID_IN_PROGRESS			VARCHAR2(2 CHAR),
		VID_LICENSE				VARCHAR2(200 CHAR),
		VID_CATEGORY_ONE		CLOB,
		VID_REMARKS				CLOB,
		VID_WIDTH				NUMBER,
		VID_HEIGHT				NUMBER,
		VID_FRAMERESOLUTION		NUMBER,
		VID_FRAMERATE			NUMBER,
		VID_VIDEODURATION		NUMBER,
		VID_COMPRESSIONTYPE		CLOB,
		VID_BITRATE				NUMBER,
		VID_EXTENSION			VARCHAR2(20 CHAR),
		VID_MIMETYPE			CLOB,
		VID_PREVIEW_WIDTH		NUMBER,
		VID_PREVIEW_HEIGTH		NUMBER,
		VID_GROUP				VARCHAR2(100 CHAR) DEFAULT NULL,
		VID_PUBLISHER			VARCHAR2(200 CHAR),
		VID_NAME_ORG			VARCHAR2(200 CHAR),
		VID_NAME_IMAGE			VARCHAR2(200 CHAR),
		VID_NAME_PRE			VARCHAR2(200 CHAR),
		VID_NAME_PRE_IMG		VARCHAR2(200 CHAR),
	 	VID_SIZE                VARCHAR2(100 CHAR),
	 	VID_PREV_SIZE           VARCHAR2(100 CHAR),
	 	LUCENE_KEY		   		VARCHAR2(2000 CHAR),
	 	SHARED			  		VARCHAR2(2 CHAR) DEFAULT 'F',
	 	LINK_KIND			    VARCHAR2(20 CHAR),
		LINK_PATH_URL		    VARCHAR2(2000 CHAR),
		VID_META				CLOB,
		HOST_ID					NUMBER,
		PATH_TO_ASSET		    VARCHAR2(500 CHAR),
		CLOUD_URL				VARCHAR2(500 CHAR),
		CLOUD_URL_ORG		    VARCHAR2(500 CHAR),
		HASHTAG			   		VARCHAR2(100 CHAR),
		IS_AVAILABLE			VARCHAR2(1) DEFAULT 0,
		CLOUD_URL_EXP		    NUMBER,
		IN_TRASH			   	VARCHAR2(2 CHAR) DEFAULT 'F',
		IS_INDEXED		  		VARCHAR2(1 CHAR) DEFAULT 0,
		VID_UPC_NUMBER			VARCHAR2(15 CHAR),
		EXPIRY_DATE DATE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#VIDEO_PK PRIMARY KEY (VID_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#VIDEO_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		</cfquery>
		
		<!--- VIDEOS CLOB --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos_text
		(
		  ID_INC		   VARCHAR2(100 CHAR) NOT NULL,
		  VID_ID_R         VARCHAR2(100 CHAR) NOT NULL,
		  LANG_ID_R        NUMBER NOT NULL,
		  VID_KEYWORDS     VARCHAR2(4000 CHAR),
		  VID_DESCRIPTION  VARCHAR2(4000 CHAR),
		  VID_TITLE		   VARCHAR2(4000 CHAR),
		  HOST_ID		 NUMBER,
		  CONSTRAINT #arguments.thestruct.host_db_prefix#VIDEOS_TEXT_PK PRIMARY KEY (ID_INC),
		CONSTRAINT #arguments.thestruct.host_db_prefix#VIDEO_TEXT_FK_VID FOREIGN KEY (VID_ID_R)
		REFERENCES #arguments.thestruct.host_db_prefix#VIDEOS (VID_ID) ON DELETE CASCADE ENABLE
		)
		</cfquery>

		<!--- SCHEDULES --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules
		(
			SCHED_ID 			 VARCHAR2(100 CHAR) NOT NULL,
			SET2_ID_R 			 NUMBER,
			SCHED_USER 			 VARCHAR2(100 CHAR),
			SCHED_STATUS 		 VARCHAR2(1 CHAR) DEFAULT 1,
			SCHED_METHOD 		 VARCHAR2(10 CHAR),
			SCHED_NAME 			 VARCHAR2(255 CHAR),
			SCHED_FOLDER_ID_R    VARCHAR2(100 CHAR),
			SCHED_ZIP_EXTRACT 	 NUMBER,
			SCHED_SERVER_FOLDER  VARCHAR2(4000 CHAR),
			SCHED_SERVER_RECURSE NUMBER DEFAULT 1,
			SCHED_SERVER_FILES   NUMBER DEFAULT 0,
			SCHED_MAIL_POP 		 VARCHAR2(255 CHAR),
			SCHED_MAIL_USER 	 VARCHAR2(255 CHAR),
			SCHED_MAIL_PASS 	 VARCHAR2(255 CHAR),
			SCHED_MAIL_SUBJECT 	 VARCHAR2(255 CHAR),
			SCHED_FTP_SERVER 	 VARCHAR2(255 CHAR),
			SCHED_FTP_USER 		 VARCHAR2(255 CHAR),
			SCHED_FTP_PASS 		 VARCHAR2(255 CHAR),
			SCHED_FTP_PASSIVE    NUMBER DEFAULT 0,
			SCHED_FTP_FOLDER 	 VARCHAR2(255 CHAR),
			SCHED_INTERVAL       VARCHAR2(255 CHAR),
			SCHED_START_DATE     DATE,
			SCHED_START_TIME     TIMESTAMP,
			SCHED_END_DATE       DATE,
			SCHED_END_TIME       TIMESTAMP,
			HOST_ID				 NUMBER,
			SCHED_FTP_EMAIL       VARCHAR2(500 CHAR),
			sched_upl_template	 VARCHAR2(100 CHAR),
			sched_ad_user_groups VARCHAR2(4000 CHAR),
		CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_PK PRIMARY KEY (SCHED_ID),
		CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_FK2 FOREIGN KEY (SCHED_USER)
		REFERENCES users (USER_ID) ON DELETE SET NULL ENABLE,
		CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_HOSTS_FK3 FOREIGN KEY (HOST_ID) 
		REFERENCES hosts (HOST_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- SCHEDULES_LOG --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		 CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules_log
		(
			SCHED_LOG_ID        VARCHAR2(100 CHAR) NOT NULL,
			SCHED_ID_R          VARCHAR2(100 CHAR),
			SCHED_LOG_USER      VARCHAR2(100 CHAR),
			SCHED_LOG_ACTION    VARCHAR2(10 CHAR),
			SCHED_LOG_DATE      DATE,
			SCHED_LOG_TIME      TIMESTAMP,
			SCHED_LOG_DESC      VARCHAR2(4000 CHAR),
			HOST_ID		 NUMBER,
			NOTIFIED    VARCHAR2(5 CHAR),
		CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_LOG_PK PRIMARY KEY (SCHED_LOG_ID),
CONSTRAINT #arguments.thestruct.host_db_prefix#SCHEDULES_LOG_FK1 FOREIGN KEY (SCHED_ID_R)
	REFERENCES #arguments.thestruct.host_db_prefix#schedules (SCHED_ID) ON DELETE CASCADE ENABLE
		)
		
		</cfquery>
		
		<!--- CUSTOM FIELDS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields
		(
			cf_id 			VARCHAR2(100 CHAR), 
			cf_type	 		VARCHAR2(20 CHAR), 
			cf_order 		NUMBER, 
			cf_enabled 		VARCHAR2(2 CHAR), 
			cf_show			VARCHAR2(10 CHAR),
			cf_group 		VARCHAR2(100 CHAR),
			cf_select_list	VARCHAR2(4000 CHAR),
			cf_in_form		VARCHAR2(10 CHAR) DEFAULT 'true',
			cf_edit			VARCHAR2(2000 CHAR) DEFAULT 'true',
			HOST_ID			NUMBER,
			CONSTRAINT #arguments.thestruct.host_db_prefix#CUSTOM_FIELDS_PK PRIMARY KEY (CF_ID)
		)
		
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_text
		(
			cf_id_r			VARCHAR2(100 CHAR), 
			lang_id_r 		NUMBER, 
			cf_text			VARCHAR2(4000 CHAR),
			HOST_ID		 	NUMBER,
			rec_uuid		VARCHAR2(100 CHAR),
			CONSTRAINT #arguments.thestruct.host_db_prefix#cft_PK PRIMARY KEY (rec_uuid) ENABLE,
			CONSTRAINT #arguments.thestruct.host_db_prefix#cf_text FOREIGN KEY (cf_id_r) REFERENCES #arguments.thestruct.host_db_prefix#custom_fields (cf_id) ON DELETE CASCADE
		)
		
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_values
		(
			cf_id_r			VARCHAR2(100 CHAR), 
			asset_id_r 		VARCHAR2(100 CHAR), 
			cf_value		VARCHAR2(4000 CHAR),
			HOST_ID		 	NUMBER,
			rec_uuid		VARCHAR(100),
			CONSTRAINT #arguments.thestruct.host_db_prefix#CFV_PK PRIMARY KEY (rec_uuid) ENABLE,
			CONSTRAINT #arguments.thestruct.host_db_prefix#cf_values FOREIGN KEY (cf_id_r) REFERENCES #arguments.thestruct.host_db_prefix#custom_fields (cf_id) ON DELETE CASCADE
		)
		
		</cfquery>
		
		<!--- COMMENTS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#comments
		(
			COM_ID			VARCHAR2(100 CHAR),
			ASSET_ID_R		VARCHAR2(100 CHAR),
			ASSET_TYPE		VARCHAR2(10 CHAR),
			USER_ID_R		VARCHAR2(100 CHAR),
			COM_TEXT		CLOB,
			COM_DATE		TIMESTAMP,
			HOST_ID		 NUMBER,
			CONSTRAINT #arguments.thestruct.host_db_prefix#COMMENTS_PK PRIMARY KEY (COM_ID)
		)
		
		</cfquery>
		
		<!--- Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#versions
		(
			asset_id_r			VARCHAR2(100 CHAR),
			ver_version			NUMBER DEFAULT NULL,
			ver_type			VARCHAR2(5 CHAR),
			ver_date_add		TIMESTAMP,
			ver_who				VARCHAR2(100 CHAR),
			ver_filename_org 	VARCHAR2(200 CHAR),
			ver_extension	 	VARCHAR2(20 CHAR),
			thumb_width			NUMBER,
			thumb_height		NUMBER,
			img_width			NUMBER,
			img_height			NUMBER,
			img_size			VARCHAR2(100 CHAR),
			thumb_size			VARCHAR2(100 CHAR),
			vid_size			VARCHAR2(100 CHAR),
			vid_width			NUMBER,
			vid_height			NUMBER,
			vid_name_image		VARCHAR2(200 CHAR),
			HOST_ID		 		NUMBER,
			cloud_url_org		VARCHAR2(500 CHAR),
			ver_thumbnail		VARCHAR2(200 CHAR),
			meta_data			CLOB,
			hashtag				VARCHAR2(100 CHAR),
			rec_uuid			VARCHAR2(100 CHAR),
			cloud_url_thumb		VARCHAR2(500 CHAR),
			file_size			VARCHAR2(100 CHAR),
			CONSTRAINT #arguments.thestruct.host_db_prefix#versions_PK PRIMARY KEY (rec_uuid) ENABLE
		)
		</cfquery>
		
		<!--- Translations --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#languages
		(
			lang_id				NUMBER NOT NULL,
			lang_name			VARCHAR2(100 CHAR) NOT NULL,
			lang_active			VARCHAR2(2 CHAR) default 'f',
			HOST_ID				NUMBER,
			rec_uuid			VARCHAR2(100 CHAR),
			CONSTRAINT #arguments.thestruct.host_db_prefix#languages_PK PRIMARY KEY (rec_uuid) ENABLE
		)
		</cfquery>
		
		<!--- AUDIOS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios
		(
			aud_ID              VARCHAR2(100 CHAR),
			FOLDER_ID_R         VARCHAR2(100 CHAR),
			aud_CREATE_DATE     DATE,
			aud_CREATE_TIME     TIMESTAMP,
			aud_CHANGE_DATE     DATE,
			aud_CHANGE_TIME     TIMESTAMP,
			aud_OWNER           VARCHAR2(100 CHAR),
			aud_TYPE            VARCHAR2(5 CHAR),
			aud_NAME            VARCHAR2(500 CHAR),
			aud_EXTENSION       VARCHAR2(20 CHAR),
			aud_NAME_NOEXT      VARCHAR2(200 CHAR),
			aud_CONTENTTYPE     VARCHAR2(100 CHAR),
			aud_CONTENTSUBTYPE  VARCHAR2(100 CHAR),
			aud_ONLINE          VARCHAR2(2 CHAR),
			aud_NAME_ORG        VARCHAR2(200 CHAR),
			aud_GROUP           VARCHAR2(100 CHAR) DEFAULT NULL,
			aud_size			VARCHAR2(100 CHAR),
			LUCENE_KEY		   	VARCHAR2(2000 CHAR),
			SHARED			   	VARCHAR2(2 CHAR) DEFAULT 'F',
			aud_meta			CLOB,
			LINK_KIND			VARCHAR2(20 CHAR),
		  	LINK_PATH_URL		VARCHAR2(2000 CHAR),
		  	HOST_ID				NUMBER,
		  	PATH_TO_ASSET		VARCHAR2(500 CHAR),
		  	CLOUD_URL			VARCHAR2(500 CHAR),
		  	CLOUD_URL_2		    VARCHAR2(500 CHAR),
		  	CLOUD_URL_ORG		VARCHAR2(500 CHAR),
		  	HASHTAG			    VARCHAR2(100 CHAR),
		  	IS_AVAILABLE		VARCHAR2(1) DEFAULT 0,
		  	CLOUD_URL_EXP		NUMBER,
		  	IN_TRASH			VARCHAR2(2 CHAR) DEFAULT 'F',
			IS_INDEXED		  	VARCHAR2(1 CHAR) DEFAULT 0,
			AUD_UPC_NUMBER		VARCHAR2(15 CHAR),
			EXPIRY_DATE DATE,
			CONSTRAINT #arguments.thestruct.host_db_prefix#audios_PK PRIMARY KEY (aud_ID),
			CONSTRAINT #arguments.thestruct.host_db_prefix#AUDIOS_HOSTS_FK1 FOREIGN KEY (HOST_ID) REFERENCES HOSTS (HOST_ID) ON DELETE CASCADE ENABLE
		)
		</cfquery>
		
		<!--- AUDIOS TEXT --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios_text
		(
			ID_INC		   		VARCHAR2(100 CHAR) NOT NULL,
			aud_ID_R			VARCHAR2(100 CHAR),
			LANG_ID_R			NUMBER,
			aud_DESCRIPTION     VARCHAR2(4000 CHAR),
			aud_KEYWORDS		VARCHAR2(4000 CHAR),
			HOST_ID		 		NUMBER,
			CONSTRAINT #arguments.thestruct.host_db_prefix#AUDIOS_TEXT_PK PRIMARY KEY (ID_INC),
			CONSTRAINT #arguments.thestruct.host_db_prefix#audios_DESC_FK_FILE FOREIGN KEY (aud_ID_R)
			REFERENCES #arguments.thestruct.host_db_prefix#audios (aud_ID) ON DELETE CASCADE
		)
		</cfquery>
		
		<!--- SHARE OPTIONS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options
		(
			asset_id_r		VARCHAR2(100 CHAR),
			host_id			NUMBER,
			group_asset_id	VARCHAR2(100 CHAR),
			folder_id_r		VARCHAR2(100 CHAR),
			asset_type		varchar2(6 CHAR),
			asset_format	varchar2(100 CHAR),
			asset_dl		varchar2(1 CHAR) DEFAULT '0',
			asset_order		varchar2(1 CHAR) DEFAULT '0',
			asset_selected	varchar2(1 CHAR) DEFAULT '0',
			rec_uuid			VARCHAR2(100 CHAR),
			CONSTRAINT #arguments.thestruct.host_db_prefix#share_options_pk PRIMARY KEY (rec_uuid) ENABLE
		)
		</cfquery>
		
		<!--- ERRORS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#errors
		(
			id				NUMBER,
			err_header		varchar(2000),
			err_text		CLOB,
			err_date		timestamp,
			host_id			NUMBER,
			CONSTRAINT #arguments.thestruct.host_db_prefix#errors_PK PRIMARY KEY (id)
		)
		</cfquery>
		
		<!--- Upload Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates 
		(
		  	upl_temp_id			varchar2(100 CHAR) NOT NULL,
		  	upl_date_create 	timestamp DEFAULT NULL,
		  	upl_date_update		timestamp DEFAULT NULL,
		  	upl_who				varchar2(100 CHAR) DEFAULT NULL,
		  	upl_active			VARCHAR2(1 CHAR) DEFAULT '0',
		  	host_id				number DEFAULT NULL,
		  	upl_name			varchar2(200 CHAR) DEFAULT NULL,
		  	upl_description		varchar2(2000 CHAR) DEFAULT NULL,
		  	PRIMARY KEY (upl_temp_id)
		)
		</cfquery>
		
		<!--- Upload Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates_val
		(
		  	upl_temp_id_r		varchar2(100 CHAR) NOT NULL,
		  	upl_temp_field		varchar2(300 CHAR) DEFAULT NULL,
		  	upl_temp_value		varchar2(100 CHAR) DEFAULT NULL,
		  	upl_temp_type		varchar2(5 CHAR) DEFAULT NULL,
		  	upl_temp_format		varchar2(10 CHAR) DEFAULT NULL,
		  	host_id				number DEFAULT NULL,
		  	rec_uuid			VARCHAR2(100 CHAR),
		  	CONSTRAINT #arguments.thestruct.host_db_prefix#UTV_PK PRIMARY KEY (rec_uuid) ENABLE	
		)
		</cfquery>
		
		<!--- CREATE WIDGETS --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#widgets 
		(
		  widget_id				varchar2(100 CHAR),
		  col_id_r				varchar2(100 CHAR),
		  folder_id_r			varchar2(100 CHAR),
		  widget_name			varchar2(200 CHAR),
		  widget_description	varchar2(1000 CHAR),
		  widget_permission 	varchar2(2 CHAR),
		  widget_password 		varchar2(100 CHAR),
		  widget_style 			varchar2(2 CHAR),
		  widget_dl_org 		varchar2(2 CHAR),
		  widget_dl_thumb 		varchar2(2 CHAR) DEFAULT 't',
		  widget_uploading 		varchar2(2 CHAR),
		  host_id 				number,
		  PRIMARY KEY (widget_id)
		)
		</cfquery>
		
		<!--- Additional Versions --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#additional_versions (
		  av_id					varchar2(100 CHAR) NOT NULL,
		  asset_id_r			varchar2(100 CHAR) DEFAULT NULL,
		  folder_id_r			varchar2(100 CHAR) DEFAULT NULL,
		  av_type				varchar2(45 CHAR) DEFAULT NULL,
		  av_link_title			varchar2(200 CHAR) DEFAULT NULL,
		  av_link_url 			varchar2(500 CHAR) DEFAULT NULL,
		  host_id 				number DEFAULT NULL,
		  av_link 				varchar2(2 CHAR) DEFAULT '1',
		  thesize 				varchar2(100 CHAR) DEFAULT '0',
  		  thewidth 				varchar2(50 CHAR) DEFAULT '0',
  		  theheight				varchar2(50 CHAR) DEFAULT '0',
  		  hashtag			   	VARCHAR2(100 CHAR),
  		  av_thumb_url			varchar2(500 CHAR) DEFAULT NULL,
		  PRIMARY KEY (av_id)
		)
		</cfquery>
		
		<!--- Files XMP --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_xmp (
		  asset_id_r 			varchar2(100 CHAR),
		  author 				varchar2(200 CHAR),
		  rights 				varchar2(1000 CHAR),
		  authorsposition 		varchar2(200 CHAR),
		  captionwriter 		varchar2(300 CHAR),
		  webstatement 			varchar2(500 CHAR),
		  rightsmarked 			varchar2(10 CHAR),
		  host_id 				number,
		  PRIMARY KEY (asset_id_r)
		)
		</cfquery>
		
		<!--- Labels --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#labels (
		label_id 		varchar2(100 char),
  		label_text 		varchar2(200 char),
  		label_date		timestamp,
  		user_id			varchar2(100 char),
  		host_id			number,
  		label_id_r		varchar2(100 char),
  		label_path		varchar2(500 char),
  		PRIMARY KEY (label_id)
		)
		</cfquery>
		
		<!--- Import Templates --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#import_templates (
		imp_temp_id 		varchar2(100 char),
  		imp_date_create	 	timestamp,
  		imp_date_update		timestamp,
  		imp_who				varchar2(100 char),
  		imp_active 			varchar2(1 char) DEFAULT '0',
  		host_id				number,
  		imp_name			varchar2(200 char),
  		imp_description 	varchar2(2000 char),
  		PRIMARY KEY (imp_temp_id)
		)
		</cfquery>
		
		<!--- Import Templates Values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#import_templates_val (
  		imp_temp_id_r		varchar2(100 char),
  		rec_uuid			varchar2(100 char),
  		imp_field			varchar2(200 char),
  		imp_map				varchar2(200 char),
  		host_id				number,
  		imp_key				number,
  		PRIMARY KEY (rec_uuid)
		)
		</cfquery>

		<!--- Customization --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom (
	  	custom_id			varchar2(200 char),
		custom_value		varchar2(2000 char),
		host_id				number
		)
		</cfquery>
		
		<!--- RAZ-2831 : Metadata export template --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#export_template (
	  	exp_id				varchar2(100 char),
		exp_field			varchar2(200 char),
		exp_value			varchar2(2000 char),
		exp_timestamp		timestamp, 
		user_id				varchar2(100 char),
		host_id				number,
		PRIMARY KEY (exp_id)
		)
		</cfquery>
		
		<!--- Social accounts --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_accounts (
	  	identifier			varchar2(200 char),
		provider			varchar2(100 char),
		user_id_r			varchar2(100 char),
		jr_identifier		varchar2(500 char),
		profile_pic_url		varchar2(1000 char),
		host_id				number
		)
		</cfquery>

		<!--- Watermark --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#wm_templates (
	  	wm_temp_id 			varchar2(100 char),
	  	wm_name				varchar2(200 char),
		wm_active			varchar2(6 char) DEFAULT 'false',
		host_id 			number,
		PRIMARY KEY (wm_temp_id)
		)
		</cfquery>

		<!--- Watermark values --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#wm_templates_val (
	  	wm_temp_id_r 		varchar2(100 char),
		wm_use_image 		varchar2(6 char) DEFAULT 'false',
		wm_use_text 		varchar2(6 char) DEFAULT 'false',
		wm_image_opacity 	varchar2(4 char),
		wm_text_opacity 	varchar2(4 char),
		wm_image_position 	varchar2(10 char),
		wm_text_position 	varchar2(10 char),
		wm_text_content 	varchar2(400 char),
		wm_text_font 		varchar2(100 char),
		wm_text_font_size 	varchar2(5 char),
		wm_image_path 		varchar2(300 char),
		host_id 			number,
		rec_uuid 			varchar2(100 char),
		PRIMARY KEY (rec_uuid)
		)
		</cfquery>

		<!--- Smart Folders --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#smart_folders 
		(
			sf_id 			varchar2(100 char),
			sf_name 		varchar2(500 char),
			sf_date_create 	timestamp,
			sf_date_update 	timestamp,
			sf_type 		varchar2(100 char),
			sf_description 	varchar2(2000 char),
			sf_who	 		varchar2(100 char),
			host_id 		number,
			PRIMARY KEY (sf_id)
		)
		</cfquery>

		<!--- Smart Folders Properties --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#smart_folders_prop
		(
			sf_id_r 		varchar2(100 char),
			sf_prop_id 		varchar2(500 char),
			sf_prop_value 	varchar2(2000 char),
			host_id 		number,
			PRIMARY KEY (sf_id_r)
		)
		</cfquery>
		
		<!--- Folder subscribe --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE TABLE #arguments.thestruct.host_db_prefix#folder_subscribe
		(
			fs_id  						varchar2(100 char) NOT NULL,
			host_id 					number DEFAULT NULL,
			folder_id 					varchar2(100 char) DEFAULT NULL,
			user_id						varchar2(100 char) DEFAULT NULL,
			mail_interval_in_hours		number(6) DEFAULT NULL,
			last_mail_notification_time timestamp DEFAULT NULL,
			asset_keywords				varchar2(3 char) DEFAULT 'F',
			asset_description			varchar2(3 char) DEFAULT 'F',
			auto_entry	varchar2(5 CHAR) DEFAULT 'false',
			PRIMARY KEY (fs_id)
		)
		</cfquery>
		
	</cffunction>
	
	
	<!--- Create Indexes --->
	<cffunction name="create_indexes" access="public" output="false">
		<cfargument name="thestruct" type="Struct">
		<!--- Start creating indexes --->
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_cache_token ON #arguments.thestruct.theschema#.cache(cache_token)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_cache_type ON #arguments.thestruct.theschema#.cache(cache_type)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_cache_host_id ON #arguments.thestruct.theschema#.cache(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_mod_sort ON #arguments.thestruct.theschema#.modules(MOD_SHORT)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_mod_hostid ON #arguments.thestruct.theschema#.modules(MOD_HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX PER_MOD_ID ON #arguments.thestruct.theschema#.permissions(PER_MOD_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX per_hostid ON #arguments.thestruct.theschema#.permissions(PER_HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX per_active ON #arguments.thestruct.theschema#.permissions(PER_ACTIVE)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX GRP_MOD_ID ON #arguments.thestruct.theschema#.groups(GRP_MOD_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX grp_hostid ON #arguments.thestruct.theschema#.groups(GRP_HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_hostname ON #arguments.thestruct.theschema#.hosts(HOST_NAME)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_hostname_custom ON #arguments.thestruct.theschema#.hosts(HOST_NAME_CUSTOM)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX idx_hosttype ON #arguments.thestruct.theschema#.hosts(HOST_TYPE)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX CT_G_U_GRP_ID ON #arguments.thestruct.theschema#.ct_groups_users(ct_g_u_grp_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX ct_g_u_user_id ON #arguments.thestruct.theschema#.ct_groups_users(ct_g_u_user_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX CT_G_P_PER_ID ON #arguments.thestruct.theschema#.ct_groups_permissions(CT_G_P_PER_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX CT_G_P_GRP_ID ON #arguments.thestruct.theschema#.ct_groups_permissions(CT_G_P_GRP_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX ct_u_h_user_id ON #arguments.thestruct.theschema#.ct_users_hosts(ct_u_h_user_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
  		CREATE INDEX ct_u_h_host_id ON #arguments.thestruct.theschema#.ct_users_hosts(CT_U_H_HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX CT_U_RU_USER_ID ON #arguments.thestruct.theschema#.ct_users_remoteusers(CT_U_RU_USER_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#t_date ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#assets_temp(DATE_ADD)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#t_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#assets_temp(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_id ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#cart(CART_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_user ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#cart(USER_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_done ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#cart(cart_order_done)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#raz1_cart_user_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#cart(cart_order_user_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_name ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(FOLDER_NAME)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_id_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_owner ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(folder_owner)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_col ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(FOLDER_IS_COLLECTION)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_shared ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(FOLDER_SHARED)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fo_user ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders(FOLDER_OF_USER)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_desc(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_fidr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_desc(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_lang ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_desc(LANG_ID_R)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_grpid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_groups(grp_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_grpperm ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_groups(GRP_PERMISSION)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_groups(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fg_fidr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#folders_groups(folder_id_r)		
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_name ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(FILE_NAME)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_folderid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_name_org ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(FILE_NAME_ORG)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_pathtoasset ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(PATH_TO_ASSET)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_ext ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(FILE_EXTENSION)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_type ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(FILE_TYPE)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_owner ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(file_owner)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_createdate ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files(FILE_CREATE_DATE)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_desc(file_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#df_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_desc(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#fd_lang2 ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_desc(LANG_ID_R)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_name ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images(IMG_FILENAME)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_name_org ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images(IMG_FILENAME_ORG)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_folderid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_group ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images(img_group)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_pathtoasset ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images(PATH_TO_ASSET)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#img_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#it_IMG_ID_R ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images_text(img_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#it_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images_text(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#it_lang ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#images_text(LANG_ID_R)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#la_user ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_assets(log_user)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#la_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_assets(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lf_userid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_folders(log_user)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lf_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_folders(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lf_action ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_folders(LOG_ACTION)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_user ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_users(log_user)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_action ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_users(LOG_ACTION)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_users(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#lu_section ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_users(LOG_SECTION)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ls_user ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_search(log_user)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ls_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_search(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ls_searchfrom ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#log_search(LOG_SEARCH_FROM)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#set_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#set_id ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings(SET_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#set2_HOST_ID ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings_2(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#set2_id ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#settings_2(SET2_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_fid_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_text_id ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_text(col_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_text_lang ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_text(LANG_ID_R)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_ct_files(col_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_fileid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_ct_files(file_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_filetype ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_ct_files(COL_FILE_TYPE)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#col_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_ct_files(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cg_colid_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_groups(col_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cg_grpid_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_groups(grp_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cg_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#collections_groups(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#uf_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_favorites(user_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#uf_id ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_favorites(fav_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#uf_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#users_favorites(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_group ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos(vid_group)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_folderid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_pathtoasset ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos(PATH_TO_ASSET)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_owner ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos(vid_owner)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vid_hash ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos(HASHTAG)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vt_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos_text(vid_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vt_lang ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos_text(LANG_ID_R)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#vt_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#videos_text(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_user ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules(SCHED_USER)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#sched_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules_log(sched_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#schedl_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#schedules_log(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cf_enabled ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields(cf_enabled)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cf_show ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields(cf_show)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cf_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cft_id ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_text(cf_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cft_lang ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_text(lang_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cft_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_text(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cfv_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_values(cf_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cfv_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_values(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#cfv_assetid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom_fields_values(asset_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_assettype ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#comments(ASSET_TYPE)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#co_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#comments(asset_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#l_active ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#languages(lang_active)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#l_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#languages(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_folderid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_group ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios(aud_group)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#aud_pathtoasset ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios(PATH_TO_ASSET)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#at_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios_text(aud_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#at_lang ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios_text(LANG_ID_R)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#at_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#audios_text(HOST_ID)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_asset_type ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(asset_type)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_folderid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_assetselected ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(asset_selected)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_groupid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(group_asset_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_assetidr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(asset_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#so_format ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#share_options(asset_format)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ut_active ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates(upl_active)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#ut_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#utv_idr ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates_val(upl_temp_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#utv_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#upload_templates_val(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#w_folderid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#widgets(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#w_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#widgets(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#w_colid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#widgets(col_id_r)		
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_id_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#additional_versions(asset_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_fid_r ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#additional_versions(folder_id_r)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_link ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#additional_versions(av_link)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#av_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#additional_versions(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#files_xmp_hostid ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#files_xmp(host_id)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#labels_text ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#labels(label_text)
		</cfquery>
		<cfquery datasource="#arguments.thestruct.dsn#">
		CREATE INDEX #arguments.thestruct.host_db_prefix#custom ON #arguments.thestruct.theschema#.#arguments.thestruct.host_db_prefix#custom(custom_id)
		</cfquery>
		<cfreturn />
	</cffunction>
		
	<!--- Clear database completely --->
	<cffunction name="clearall" access="public" output="false">
		<!--- Query tables --->
		<cfquery datasource="#session.firsttime.database#" name="qrytbl">
		SELECT object_name
		FROM user_objects 
		WHERE object_type='TABLE'
		</cfquery>
		<!--- Loop and drop tables --->
		<cfloop query="qrytbl">
			<cftry>
				<cfquery datasource="#session.firsttime.database#">
				DROP TABLE #object_name# CASCADE CONSTRAINTS
				</cfquery>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
		<!--- Query Sequences --->
		<cfquery datasource="#session.firsttime.database#" name="qryseq">
		SELECT sequence_name
		FROM all_sequences
		WHERE sequence_owner = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#ucase(application.razuna.theschema)#">
		</cfquery>
		<!--- Loop over Sequences and remove them --->
		<cfloop query="qryseq">
			<cftry>
				<cfquery datasource="#session.firsttime.database#">
				DROP SEQUENCE #sequence_name#
				</cfquery>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
		<cfreturn />
	</cffunction>
		
</cfcomponent>