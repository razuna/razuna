<cfcomponent output="false" extends="authentication">


	<cffunction name="checkuser" access="remote" output="false" returntype="query" returnformat="json"  >
		<!--- Je récupère mes arguments --->
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="user" required="true">
		<cfargument name="pass" required="true">
		<cfargument name="passhashed" type="numeric">

		<!--- Je controle la session --->
		<cfset var thesession = checkdb(arguments.api_key)>

		<!--- J'ai bien une session --->
		<cfif thesession>
			<cfset var thexml = "">

		 	<!--- Le mot de passe est-il crypté, si oui on décrypte --->
			<cfif arguments.passhashed>
				<cfset var pass = arguments.pass/>
			<cfelse>
				<cfset var pass = hash(arguments.pass, "MD5", "UTF-8")>
			</cfif>

		 	<!--- Le couple user mot de passe correspond? --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT u.USER_API_KEY, u.USER_ID
				FROM users u
				WHERE lower(u.user_login_name) = <cfqueryparam value="#lcase(arguments.user)#" cfsqltype="cf_sql_varchar">
				AND lower(u.user_pass) = <cfqueryparam value="#lcase(pass)#" cfsqltype="cf_sql_varchar">
			</cfquery>

			<!--- J'ai une réponse ou pas --->
			<cfif thexml.recordcount NEQ 0>

				<!--- Je demande tous les tenants --->
				<cfquery datasource="#application.razuna.api.dsn#" name="qry">
					SELECT distinct uh.CT_U_H_HOST_ID, h.HOST_NAME
					FROM ct_users_hosts uh
					INNER JOIN hosts h on h.HOST_ID = uh.CT_U_H_HOST_ID
					WHERE uh.CT_U_H_USER_ID = <cfqueryparam value="#lcase(thexml.USER_ID)#" cfsqltype="cf_sql_varchar">
				</cfquery>

				<!--- J'ai des tenants --->
				<cfif qry.recordcount NEQ 0>
					<cfset thexml = querynew("user_name,api_key,host_id,host_name")>
					<cfloop query="qry" >
						<cfset sub_user = arguments.user & "_" & qry.CT_U_H_HOST_ID>
						<!--- Pour chaque tenants, je recherche le user + tenant et remonte l'api-key --->
						<cfquery datasource="#application.razuna.api.dsn#" name="user_query">
							SELECT u.USER_API_KEY
							FROM users u
							WHERE lower(u.user_login_name) = <cfqueryparam value="#lcase(sub_user)#" cfsqltype="cf_sql_varchar">
						</cfquery>
						<!--- J'ai un résultat, je contruit ma boulette de retour --->
						<cfif user_query.recordcount NEQ 0>
							<cfset queryaddrow(thexml,1)>
							<cfset querysetcell(thexml,"user_name",sub_user)>
							<cfset querysetcell(thexml,"api_key",user_query.USER_API_KEY)>
							<cfset querysetcell(thexml,"host_id",qry.CT_U_H_HOST_ID)>
							<cfset querysetcell(thexml,"host_name",qry.HOST_NAME)>
						</cfif>
					</cfloop>
				</cfif>

			<!--- Pas de réponse, j'informe en retour --->
			<cfelse>
				<cfset thexml = querynew("responsecode,message")>
				<cfset queryaddrow(thexml,1)>
				<cfset querysetcell(thexml,"responsecode","1")>
				<cfset querysetcell(thexml,"message","User and password don't match with existing user")>
			</cfif>

		<!--- Pas de session --->
		<cfelse>
			<cfset var thexml = timeout()>

		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction/>

	<cffunction name="getCustomFields" access="remote" output="false" returntype="query" returnformat="json"  >
		<!--- Je récupère mes arguments --->
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="host_id" required="true" type="string">

		<!--- Je controle la session --->
		<cfset var thesession = checkdb(arguments.api_key)>

		<!--- J'ai bien une session --->
		<cfif thesession>
			<cfset var thexml = "">

		 	<!--- requete test --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT *
				FROM #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields c
				INNER JOIN #application.razuna.api.prefix["#arguments.api_key#"]#custom_fields_text ct ON ct.CF_ID_R = c.CF_ID
				WHERE c.HOST_ID = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#host_id#">
			</cfquery>

		<!--- Pas de session --->
		<cfelse>
			<cfset var thexml = timeout()>

		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction/>

	<cffunction name="setCustomFields" access="remote" output="false" returnformat="json"  >
		<!--- Je récupère mes arguments --->
		<cfargument name="api_key" required="true" type="string">
		<cfargument name="host_id" required="true" type="string">

		<!--- Les donnée à importer --->
		<cfset fields = [["#createuuid()#","checkbox",2,"T","all","","","true","true",2,"","ACE42BD2-6177-4371-80C7E047ACFAD517",1,"test pour import",2,"DB17B2CF-F35D-48D7-A68021CEE3494730"]]>

		<!--- Je controle la session --->
		<cfset var thesession = checkdb(arguments.api_key)>

		<!--- J'ai bien une session --->
		<cfif thesession>

		 	<cfloop array="#fields#" index="item">

				<!--- Set Values --->
				<cfset session.hostdbprefix = application.razuna.api.prefix["#arguments.api_key#"]>
				<cfset session.hostid = application.razuna.api.hostid["#arguments.api_key#"]>
				<cfset session.theuserid = application.razuna.api.userid["#arguments.api_key#"]>
				<!--- Set Arguments --->
				<cfset arguments.thestruct.langcount = 1>
				<cfset arguments.thestruct.cf_text_1 = #item[14]#>
				<cfset arguments.thestruct.cf_type = #item[2]#>
				<cfset arguments.thestruct.cf_enabled = #item[4]#>
				<cfset arguments.thestruct.cf_show = #item[5]#>
				<cfset arguments.thestruct.cf_select_list = #item[7]#>
				<!--- call internal method --->
				<cfinvoke component="global.cfc.custom_fields" method="add" thestruct="#arguments.thestruct#" returnVariable="theid">
				<!--- Return --->
				<cfset thexml.responsecode = 0>
				<cfset thexml.message = "Custom field successfully added">
				<cfset thexml.field_id = theid>
		 	</cfloop>
		 	
		<!--- Pas de session --->
		<cfelse>
			<cfset var thexml = timeout()>

		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction/>

	<cffunction name="updateCustomField" access="remote" output="false" returntype="string"  >
		<!--- Je récupère mes arguments --->
		<cfargument name="prefix" required="true" type="string">
		<cfargument name="cf_id" required="true" type="string">
		<cfargument name="select_list" required="true" type="string">
<!-- NITA modif -->
		<cfargument name="user_id" required="true" type="string">
<!-- NITA modif -->		

		<cfquery datasource="#application.razuna.datasource#" name="qry_user">
		SELECT user_api_key
		FROM users
		WHERE user_id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#user_id#">
		</cfquery>
<!-- NITA modif -->
		<cfset checkdb(qry_user.user_api_key)>
<!-- NITA modif -->
		<cfquery datasource="#application.razuna.datasource#" name="qry">
			UPDATE #prefix#custom_fields
			SET 
			CF_SELECT_LIST = <cfqueryparam cfsqltype="cf_sql_varchar" value="#select_list#">
			WHERE CF_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cf_id#" >
		</cfquery>

		<cfquery datasource="#application.razuna.api.dsn#" name="qry">
			SELECT CF_SELECT_LIST
			FROM #prefix#custom_fields
			WHERE CF_ID = <cfqueryparam cfsqltype="cf_sql_varchar" value="#CF_ID#">
		</cfquery>

		<cfloop query="qry" >
			<cfset result = #CF_SELECT_LIST#>
		</cfloop>
<!-- NITA modif -->
		<!--- Flush Cache --->
		<cfset resetcachetoken(qry_user.user_api_key, "general")>
<!-- NITA modif -->
		<!--- Return --->
		<cfreturn result>

	</cffunction/>


	<cffunction name="getThesaurus" access="remote" output="false" returntype="string" >
		<!--- Je récupère mes arguments --->
		<cfargument name="prefix" required="true" type="string">
		<cfargument name="cf_id" required="true" type="string">
		<cfargument name="search_value" required="true" type="string">

		<cfset var result = "">

		<cfset result = "">
		<cfif LEN(search_value) GTE 2>
	 		<!--- requete --->
			<cfquery datasource="#application.razuna.api.dsn#" name="qry">
				SELECT DISTINCT t.ASSOCIATEDVALUE
				FROM #prefix#thesaurus t
				WHERE lower(t.value) LIKE <cfqueryparam value="%#lcase(search_value)#%" cfsqltype="cf_sql_varchar">
			</cfquery>
			<!--- J'ai des valeurs --->
			<cfif qry.recordcount NEQ 0>
				<cfloop query="qry" >
					<cfset result = result&","&#ASSOCIATEDVALUE#>
				</cfloop>
			</cfif>
		</cfif>

		<!--- Return --->
		<cfreturn result>
	</cffunction/>

	<cffunction name="manipulate" access="remote" output="false" returntype="query" returnformat="json"  >
		<cfset var thexml = "">

		<!--- Je détruit --->
		<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
			DROP TABLE IF EXISTS raz1_thesaurus
		</cfquery>

		<!--- Je Crée --->
		<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
			CREATE TABLE raz1_thesaurus
			(
				value varchar(255),
				associatedValue varchar(255)
			)
		</cfquery>

		<!--- J'ajoute --->
		<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
			INSERT INTO raz1_thesaurus (VALUE, ASSOCIATEDVALUE) VALUES 
			('TATOUAGE', 'PARURE'),
			('BIJOU', 'PARURE'),
			('CHAUSSURE', 'PARURE'),
			('COSTUME', 'PARURE'),
			('CARICATURE', 'ART_GRAPHIQUE'),
			('DESSIN', 'ART_GRAPHIQUE'),
			('CALLIGRAPHIE', 'ART_GRAPHIQUE'),
			('PEINTURE RUPESTRE', 'ART_GRAPHIQUE'),
			('AFFICHE', 'ART_GRAPHIQUE'),
			('ACTEUR', 'ARTISTE '),
			('CALLIGRAPHE', 'ARTISTE '),
			('CINEASTE', 'ARTISTE '),
			('MUSICIEN', 'ARTISTE '),
			('PEINTRE', 'ARTISTE '),

		</cfquery>

	 	<!--- requete test --->
		<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
			SELECT *
			FROM raz1_thesaurus u
			WHERE u.value LIKE '%o%'
		</cfquery>

		<!--- Return --->
		<cfreturn thexml>
	</cffunction/>

	<cffunction name="test" access="remote" output="false" returntype="query" returnformat="json"  >
		<!--- Je récupère mes arguments --->
		<cfargument name="api_key" required="true" type="string">

		<!--- Je controle la session --->
		<cfset var thesession = checkdb(arguments.api_key)>

		<!--- J'ai bien une session --->
		<cfif thesession>
			<cfset var thexml = "">

		 	<!--- requete test --->
			<cfquery datasource="#application.razuna.api.dsn#" name="thexml">
				SELECT *
				FROM ct_users_hosts u
			</cfquery>

		<!--- Pas de session --->
		<cfelse>
			<cfset var thexml = timeout()>

		</cfif>
		<!--- Return --->
		<cfreturn thexml>
	</cffunction/>
</cfcomponent>