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
<cfcomponent extends="extQueryCaching">

<!--- Read XMP DB --->
<cffunction name="readxmpdb" output="false">
	<cfargument name="thestruct" type="struct">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("images")>
		<!--- Query --->
		<cfquery datasource="#application.razuna.datasource#" name="xmp" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#readxmpdb */ 
		id_r,
		subjectcode iptcsubjectcode, 
		creator, 
		title, 
		authorsposition authorstitle, 
		captionwriter descwriter, 
		ciadrextadr iptcaddress, 
		category, 
		supplementalcategories categorysub, 
		urgency, 
		description, 
		ciadrcity iptccity, 
		ciadrctry iptccountry, 
		location iptclocation, 
		ciadrpcode iptczip, 
		ciemailwork iptcemail, 
		ciurlwork iptcwebsite, 
		citelwork iptcphone, 
		intellectualgenre iptcintelgenre, 
		instructions iptcinstructions, 
		source iptcsource, 
		usageterms iptcusageterms, 
		copyrightstatus copystatus, 
		transmissionreference iptcjobidentifier, 
		webstatement copyurl, 
		headline iptcheadline, 
		datecreated iptcdatecreated, 
		city iptcimagecity, 
		ciadrregion iptcimagestate, 
		country iptcimagecountry, 
		countrycode iptcimagecountrycode, 
		scene iptcscene, 
		state iptcstate, 
		credit iptccredit, 
		rights copynotice,
		colorspace,
		xres,
		yres,
		resunit
		FROM #session.hostdbprefix#xmp
		WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	<cfreturn xmp>
</cffunction>

<!--- For writing the XMP below but in a cfthread --->
<cffunction name="xmpwritethread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Loop over the file_id (important when working on more then one image) --->
	<!--- <cfinvoke method="xmpwrite" thestruct="#arguments.thestruct#" /> --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="xmpwrite" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- Write the XMP XML to the filesystem --->
<cffunction name="xmpwrite" output="false" returntype="void">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam name="arguments.thestruct.frombatch" default="F">
	<cfparam name="arguments.thestruct.batch_replace" default="true">
	<cfset var md5hash = "">
	<!--- Declare all variables or else you will get errors in the page --->
	<cfparam default="" name="arguments.thestruct.xmp_document_title">
	<cfparam default="" name="arguments.thestruct.xmp_author">
	<cfparam default="" name="arguments.thestruct.xmp_author_title">
	<cfparam default="" name="arguments.thestruct.xmp_description">
	<cfparam default="" name="arguments.thestruct.xmp_keywords">
	<cfparam default="" name="arguments.thestruct.xmp_description_writer">
	<cfparam default="" name="arguments.thestruct.xmp_copyright_status">
	<cfparam default="" name="arguments.thestruct.xmp_copyright_notice">
	<cfparam default="" name="arguments.thestruct.xmp_copyright_info_url">
	<cfparam default="" name="arguments.thestruct.xmp_category">
	<cfparam default="" name="arguments.thestruct.xmp_supplemental_categories">
	<cfparam default="" name="arguments.thestruct.iptc_contact_address">
	<cfparam default="" name="arguments.thestruct.iptc_contact_city">
	<cfparam default="" name="arguments.thestruct.iptc_contact_state_province">
	<cfparam default="" name="arguments.thestruct.iptc_contact_postal_code">
	<cfparam default="" name="arguments.thestruct.iptc_contact_country">
	<cfparam default="" name="arguments.thestruct.iptc_contact_phones">
	<cfparam default="" name="arguments.thestruct.iptc_contact_emails">
	<cfparam default="" name="arguments.thestruct.iptc_contact_websites">
	<cfparam default="" name="arguments.thestruct.iptc_content_headline">
	<cfparam default="" name="arguments.thestruct.iptc_content_subject_code">
	<cfparam default="" name="arguments.thestruct.iptc_date_created">
	<cfparam default="" name="arguments.thestruct.iptc_intellectual_genre">
	<cfparam default="" name="arguments.thestruct.iptc_scene">
	<cfparam default="" name="arguments.thestruct.iptc_image_location">
	<cfparam default="" name="arguments.thestruct.iptc_image_city">
	<cfparam default="" name="arguments.thestruct.iptc_image_country">
	<cfparam default="" name="arguments.thestruct.iptc_image_state_province">
	<cfparam default="" name="arguments.thestruct.iptc_iso_country_code">
	<cfparam default="" name="arguments.thestruct.iptc_status_job_identifier">
	<cfparam default="" name="arguments.thestruct.iptc_status_instruction">
	<cfparam default="" name="arguments.thestruct.iptc_status_provider">
	<cfparam default="" name="arguments.thestruct.iptc_status_source">
	<cfparam default="" name="arguments.thestruct.iptc_status_rights_usage_terms">
	<cfparam default="" name="arguments.thestruct.xmp_origin_urgency">
	<cfparam default="" name="arguments.thestruct.img_keywords">
	<cfparam default="" name="arguments.thestruct.img_desc">
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Loop --->
	<cfloop list="#arguments.thestruct.file_id#" delimiters="," index="i">
		<!--- Params --->
		<cfset arguments.thestruct.file_id = i>
		<cfset arguments.thestruct.newid = i>
		<!--- Get the original filename --->
		<cfquery datasource="#application.razuna.datasource#" name="qryfilenameorg">
		SELECT i.img_filename_org, i.folder_id_r, i.img_extension, i.link_kind, i.link_path_url, i.lucene_key, i.path_to_asset,
		x.subjectcode, x.creator, x.title, x.authorsposition, x.captionwriter, x.ciadrextadr, x.category, x.supplementalcategories, x.urgency,
  		x.description, x.ciadrcity, x.ciadrctry, x.location as thelocation, x.ciadrpcode, x.ciemailwork, x.ciurlwork, x.citelwork, x.intellectualgenre,
  		x.instructions, x.source, x.usageterms, x.copyrightstatus, x.transmissionreference, x.webstatement, x.headline, x.datecreated,
  		x.city, x.ciadrregion, x.country, x.countrycode, x.scene, x.state, x.credit, x.rights, x.colorspace, d.img_keywords, d.img_description
		FROM #session.hostdbprefix#images i 
		LEFT JOIN #session.hostdbprefix#xmp x ON x.id_r = i.img_id AND x.host_id = i.host_id
		LEFT JOIN #session.hostdbprefix#images_text d ON d.img_id_r = i.img_id AND d.host_id = i.host_id
		WHERE i.img_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
		AND i.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
		<!--- Go to top of loop if file data not in DB --->
		<cfif qryfilenameorg.recordcount EQ 0>
			<cfcontinue>
		</cfif>
		<!--- Assign link_kind --->
		<cfset arguments.thestruct.qrydetail = qryfilenameorg>
		<cfset arguments.thestruct.link_kind = qryfilenameorg.link_kind>
		<cfset arguments.thestruct.qryfile.filename = qryfilenameorg.img_filename_org>
		<cfset arguments.thestruct.qrydetail.lucene_key = qryfilenameorg.lucene_key>
		<cfset arguments.thestruct.qrydetail.path_to_asset = qryfilenameorg.path_to_asset>
		<!--- If the extension is JPG OR JPEG --->
		<!--- <cfif qryfilenameorg.img_extension EQ "JPG" OR qryfilenameorg.img_extension EQ "JPEG"> --->
		<cfset arguments.thestruct.filenameorg = qryfilenameorg.img_filename_org>
		<cfset arguments.thestruct.qryfile.folder_id = qryfilenameorg.folder_id_r>
		<cfset arguments.thestruct.qrydetail.folder_id_r = qryfilenameorg.folder_id_r>
		<cfset arguments.thestruct.qrydetail.filenameorg = qryfilenameorg.img_filename_org>
		<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.assetpath#/#session.hostid#/#qryfilenameorg.path_to_asset#">
		<cfset arguments.thestruct.path_to_asset = qryfilenameorg.path_to_asset>
		<cfif qryfilenameorg.link_kind EQ "lan">
			<cfset arguments.thestruct.thesource = qryfilenameorg.link_path_url>
		<cfelse>
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.assetpath#/#session.hostid#/#qryfilenameorg.path_to_asset#/#qryfilenameorg.img_filename_org#">
		</cfif>
		<!--- Start --->
		<cfif arguments.thestruct.frombatch EQ "F">
			<!--- Because we have many languages sometimes we put together the keywords and description here --->
			<cfif structkeyexists(arguments.thestruct,"langcount")>
				<cfloop list="#arguments.thestruct.langcount#" index="langindex">
					<cfparam name="arguments.thestruct.keywords_#langindex#" default="">
					<cfparam name="arguments.thestruct.desc_#langindex#" default="">
					<cfset thiskeywords = "arguments.thestruct.keywords_#langindex#">
					<cfset arguments.thestruct.img_keywords = arguments.thestruct.img_keywords & evaluate(thiskeywords)>
					<cfif langindex LT langcount>
						<cfset arguments.thestruct.img_keywords = arguments.thestruct.img_keywords & ", ">
					</cfif>
					<cfset thisdesc = "arguments.thestruct.desc_#langindex#">
					<cfset arguments.thestruct.img_desc = arguments.thestruct.img_desc & evaluate(thisdesc)>
					<cfif langindex LT langcount>
						<cfset arguments.thestruct.img_desc = arguments.thestruct.img_desc & ", ">
					</cfif>
				</cfloop>
			</cfif>
		<!--- We come from BATCHING --->
		<cfelse>
			<!--- Check if replace or append and then add to existing values --->
			<cfif !arguments.thestruct.batch_replace>
				<cfif qryfilenameorg.img_description NEQ "">
					<cfset arguments.thestruct.img_desc = qryfilenameorg.img_description & " " & arguments.thestruct.img_desc>
				</cfif>
				<cfif qryfilenameorg.img_keywords NEQ "">
					<cfset arguments.thestruct.img_keywords = qryfilenameorg.img_keywords & " " & arguments.thestruct.img_keywords>
				</cfif>
				<cfif qryfilenameorg.subjectcode NEQ "">
					<cfset arguments.thestruct.iptc_content_subject_code = qryfilenameorg.subjectcode & " " & arguments.thestruct.iptc_content_subject_code>
				</cfif>
				<cfif qryfilenameorg.creator NEQ "">
					<cfset arguments.thestruct.xmp_author = qryfilenameorg.creator & " " & arguments.thestruct.xmp_author>
				</cfif>
				<cfif qryfilenameorg.title NEQ "">
					<cfset arguments.thestruct.xmp_document_title = qryfilenameorg.title & " " & arguments.thestruct.xmp_document_title>
				</cfif>
				<cfif qryfilenameorg.authorsposition NEQ "">
					<cfset arguments.thestruct.xmp_author_title = qryfilenameorg.authorsposition & " " & arguments.thestruct.xmp_author_title>
				</cfif>
				<cfif qryfilenameorg.captionwriter NEQ "">
					<cfset arguments.thestruct.xmp_description_writer = qryfilenameorg.captionwriter & " " & arguments.thestruct.xmp_description_writer>
				</cfif>
				<cfif qryfilenameorg.ciadrextadr NEQ "">
					<cfset arguments.thestruct.iptc_contact_address = qryfilenameorg.ciadrextadr & " " & arguments.thestruct.iptc_contact_address>
				</cfif>
				<cfif qryfilenameorg.category NEQ "">
					<cfset arguments.thestruct.xmp_category = qryfilenameorg.category & " " & arguments.thestruct.xmp_category>
				</cfif>
				<cfif qryfilenameorg.supplementalcategories NEQ "">
					<cfset arguments.thestruct.xmp_supplemental_categories = qryfilenameorg.supplementalcategories & " " & arguments.thestruct.xmp_supplemental_categories>
				</cfif>
				<cfif qryfilenameorg.urgency NEQ "">
					<cfset arguments.thestruct.xmp_origin_urgency = qryfilenameorg.urgency & " " & arguments.thestruct.xmp_origin_urgency>
				</cfif>
				<cfif qryfilenameorg.ciadrcity NEQ "">
					<cfset arguments.thestruct.iptc_contact_city = qryfilenameorg.ciadrcity & " " & arguments.thestruct.iptc_contact_city>
				</cfif>
				<cfif qryfilenameorg.ciadrctry NEQ "">
					<cfset arguments.thestruct.iptc_contact_country = qryfilenameorg.ciadrctry & " " & arguments.thestruct.iptc_contact_country>
				</cfif>
				<cfif qryfilenameorg.thelocation NEQ "">
					<cfset arguments.thestruct.iptc_image_location = qryfilenameorg.thelocation & " " & arguments.thestruct.iptc_image_location>
				</cfif>
				<cfif qryfilenameorg.ciadrpcode NEQ "">
					<cfset arguments.thestruct.iptc_contact_postal_code = qryfilenameorg.ciadrpcode & " " & arguments.thestruct.iptc_contact_postal_code>
				</cfif>
				<cfif qryfilenameorg.ciemailwork NEQ "">
					<cfset arguments.thestruct.iptc_contact_emails = qryfilenameorg.ciemailwork & " " & arguments.thestruct.iptc_contact_emails>
				</cfif>
				<cfif qryfilenameorg.ciurlwork NEQ "">
					<cfset arguments.thestruct.iptc_contact_websites = qryfilenameorg.ciurlwork & " " & arguments.thestruct.iptc_contact_websites>
				</cfif>
				<cfif qryfilenameorg.citelwork NEQ "">
					<cfset arguments.thestruct.iptc_contact_phones = qryfilenameorg.citelwork & " " & arguments.thestruct.iptc_contact_phones>
				</cfif>
				<cfif qryfilenameorg.intellectualgenre NEQ "">
					<cfset arguments.thestruct.iptc_intellectual_genre = qryfilenameorg.intellectualgenre & " " & arguments.thestruct.iptc_intellectual_genre>
				</cfif>
				<cfif qryfilenameorg.instructions NEQ "">
					<cfset arguments.thestruct.iptc_status_instruction = qryfilenameorg.instructions & " " & arguments.thestruct.iptc_status_instruction>
				</cfif>
				<cfif qryfilenameorg.source NEQ "">
					<cfset arguments.thestruct.iptc_status_source = qryfilenameorg.source & " " & arguments.thestruct.iptc_status_source>
				</cfif>
				<cfif qryfilenameorg.usageterms NEQ "">
					<cfset arguments.thestruct.iptc_status_rights_usage_terms = qryfilenameorg.usageterms & " " & arguments.thestruct.iptc_status_rights_usage_terms>
				</cfif>
				<cfif qryfilenameorg.transmissionreference NEQ "">
					<cfset arguments.thestruct.iptc_status_job_identifier = qryfilenameorg.transmissionreference & " " & arguments.thestruct.iptc_status_job_identifier>
				</cfif>
				<cfif qryfilenameorg.webstatement NEQ "">
					<cfset arguments.thestruct.xmp_copyright_info_url = qryfilenameorg.webstatement & " " & arguments.thestruct.xmp_copyright_info_url>
				</cfif>
				<cfif qryfilenameorg.headline NEQ "">
					<cfset arguments.thestruct.iptc_content_headline = qryfilenameorg.headline & " " & arguments.thestruct.iptc_content_headline>
				</cfif>
				<cfif qryfilenameorg.scene NEQ "">
					<cfset arguments.thestruct.iptc_scene = qryfilenameorg.scene & " " & arguments.thestruct.iptc_scene>
				</cfif>
				<cfif qryfilenameorg.rights NEQ "">
					<cfset arguments.thestruct.xmp_copyright_notice = qryfilenameorg.rights & " " & arguments.thestruct.xmp_copyright_notice>
				</cfif>
			</cfif>
			<!--- Because we have many languages sometimes we put together the keywords and description here --->
			<cfif structkeyexists(arguments.thestruct,"langcount")>
				<cfloop list="#arguments.thestruct.langcount#" index="langindex">
					<!--- If we come from all we need to change the desc and keywords arguments name --->
					<cfif arguments.thestruct.what EQ "all">
						<cfset alldesc = "all_desc_#langindex#">
						<cfset allkeywords = "all_keywords_#langindex#">
						<cfset thisdesc = "arguments.thestruct.img_desc_#langindex#">
						<cfset thiskeywords = "arguments.thestruct.img_keywords_#langindex#">
						<cfset "#thisdesc#" =  evaluate(alldesc)>
						<cfset "#thiskeywords#" =  evaluate(allkeywords)>
					</cfif>
					<cfset thiskeywords="arguments.thestruct.img_keywords_#langindex#">
					<cfset arguments.thestruct.img_keywords = arguments.thestruct.img_keywords & evaluate(thiskeywords)>
					<cfif langindex LT langcount>
						<cfset arguments.thestruct.img_keywords = arguments.thestruct.img_keywords & ", ">
					</cfif>
					<cfset thisdesc="arguments.thestruct.img_desc_#langindex#">
					<cfset arguments.thestruct.img_desc = arguments.thestruct.img_desc & evaluate(thisdesc)>
					<cfif langindex LT langcount>
						<cfset arguments.thestruct.img_desc = arguments.thestruct.img_desc & ", ">
					</cfif>
				</cfloop>
			</cfif>
		</cfif>
		<!--- Create the XMP XML file --->
		<cfoutput>
		<!--- Create the file content --->
		<cftry>
			<cfsavecontent variable="thexmp">-xmp:all=<!--- Remove all fileds first --->
<!--- Keywords ---><cfif ltrim(rereplace(arguments.thestruct.img_keywords,"\,","","all")) EQ "">-xmp:subject=
-keywords=<cfelse><cfloop delimiters="," index="key" list="#arguments.thestruct.img_keywords#"><cfif ltrim(key) NEQ "">-xmp:subject=#ltrim(key)#
-keywords=#ltrim(key)#</cfif>
</cfloop></cfif><!--- Creator --->
-xmp:creator=#arguments.thestruct.xmp_author#
-IPTC:By-line=#arguments.thestruct.xmp_author#
-xmp:rights=#replacenocase(ParagraphFormat(arguments.thestruct.xmp_copyright_notice),"<p>","","all")#
-IPTC:CopyrightNotice=#replacenocase(ParagraphFormat(arguments.thestruct.xmp_copyright_notice),"<p>","","all")#
-xmp:title=#arguments.thestruct.xmp_document_title#
-IPTC:ObjectName=#arguments.thestruct.xmp_document_title#
-xmp:description=#replacenocase(ParagraphFormat(arguments.thestruct.img_desc),"<p>","","all")#
-IPTC:Caption-Abstract=#replacenocase(ParagraphFormat(arguments.thestruct.img_desc),"<p>","","all")#
-xmp:AuthorsPosition=#arguments.thestruct.xmp_author_title#
-IPTC:By-lineTitle=#arguments.thestruct.xmp_author_title#
-xmp:CaptionWriter=#arguments.thestruct.xmp_description_writer#
-IPTC:Writer-Editor=#arguments.thestruct.xmp_description_writer#
-xmp:Category=#arguments.thestruct.xmp_category#
-iptc:Category=#arguments.thestruct.xmp_category#
-xmp:Headline=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_content_headline),"<p>","","all")#
-iptc:Headline=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_content_headline),"<p>","","all")#
-xmp:DateCreated=#arguments.thestruct.iptc_date_created#
-iptc:DateCreated=#arguments.thestruct.iptc_date_created#
-xmp:City=#arguments.thestruct.iptc_image_city#
-iptc:City=#arguments.thestruct.iptc_image_city#
-xmp:State=#arguments.thestruct.iptc_image_state_province#
-iptc:Province-State=#arguments.thestruct.iptc_image_state_province#
-xmp:Country=#arguments.thestruct.iptc_image_country#
-IPTC:Country-PrimaryLocationName=#arguments.thestruct.iptc_image_country#
-xmp:TransmissionReference=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_status_job_identifier),"<p>","","all")#
-IPTC:OriginalTransmissionReference=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_status_job_identifier),"<p>","","all")#
-xmp:Instructions=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_status_instruction),"<p>","","all")#
-IPTC:SpecialInstructions=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_status_instruction),"<p>","","all")#
-xmp:Credit=#arguments.thestruct.iptc_status_provider#
-iptc:Credit=#arguments.thestruct.iptc_status_provider#
-XMP-xmpPLUS:CreditLineReq=#arguments.thestruct.iptc_status_provider#
-xmp:Source=#arguments.thestruct.iptc_status_source#
-iptc:Source=#arguments.thestruct.iptc_status_source#
-xmp:Urgency=#arguments.thestruct.xmp_origin_urgency#
-iptc:Urgency=#arguments.thestruct.xmp_origin_urgency#<cfloop delimiters="," index="cats" list="#arguments.thestruct.xmp_supplemental_categories#">
-xmp:SupplementalCategories=#ltrim(cats)#
-iptc:SupplementalCategories=#ltrim(cats)#
</cfloop><!--- Iptc4 Core --->
-xmp:Location=#arguments.thestruct.iptc_image_location#
-XMP-iptcCore:Location=#arguments.thestruct.iptc_image_location#
-xmp:CountryCode=#arguments.thestruct.iptc_iso_country_code#
-XMP-iptcCore:CountryCode=#arguments.thestruct.iptc_iso_country_code#
-xmp:IntellectualGenre=#arguments.thestruct.iptc_intellectual_genre#
-XMP-iptcCore:IntellectualGenre=#arguments.thestruct.iptc_intellectual_genre#
-xmp:CiAdrExtadr=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_address),"<p>","","all")#
-XMP-iptcCore:CreatorAddress=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_address),"<p>","","all")#
-xmp:CiAdrCity=#arguments.thestruct.iptc_contact_city#
-XMP-iptcCore:CreatorCity=#arguments.thestruct.iptc_contact_city#
-xmp:CiAdrCtry=#arguments.thestruct.iptc_contact_country#
-XMP-iptcCore:CreatorCountry=#arguments.thestruct.iptc_contact_country#
-xmp:CiTelWork=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_phones),"<p>","","all")#
-XMP-iptcCore:CreatorWorkTelephone=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_phones),"<p>","","all")#
-xmp:CiAdrRegion=#arguments.thestruct.iptc_contact_state_province#
-XMP-iptcCore:CreatorRegion=#arguments.thestruct.iptc_contact_state_province#
-xmp:CiAdrPcode=#arguments.thestruct.iptc_contact_postal_code#
-XMP-iptcCore:CreatorPostalCode=#arguments.thestruct.iptc_contact_postal_code#
-xmp:CiEmailWork=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_emails),"<p>","","all")#
-XMP-iptcCore:CreatorWorkEmail=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_emails),"<p>","","all")#
-xmp:CiUrlWork=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_websites),"<p>","","all")#
-XMP-iptcCore:CreatorWorkURL=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_contact_websites),"<p>","","all")#<!--- Iptc Subject Code ---><cfloop delimiters="," index="subcode" list="#arguments.thestruct.iptc_content_subject_code#">
-xmp:SubjectCode=#ltrim(subcode)#
-XMP-iptcCore:SubjectCode=#ltrim(subcode)#
</cfloop><!--- Iptc Scene ---><cfloop delimiters="," index="scene" list="#arguments.thestruct.iptc_scene#">
-xmp:Scene=#ltrim(scene)# 
-XMP-iptcCore:Scene=#ltrim(scene)#
</cfloop>
-xmp:WebStatement=<cfif arguments.thestruct.xmp_copyright_info_url NEQ "">'#arguments.thestruct.xmp_copyright_info_url#'</cfif>
-XMP-xmpRights:WebStatement=<cfif arguments.thestruct.xmp_copyright_info_url NEQ "">'#arguments.thestruct.xmp_copyright_info_url#'</cfif>
<cfif arguments.thestruct.xmp_copyright_status EQ "true">-xmp:copyrightstatus='true'
-XMP-xmpRights:Marked='true'
<cfelseif arguments.thestruct.xmp_copyright_status EQ "false">-xmp:copyrightstatus='false'
-XMP-xmpRights:Marked='false'
<cfelse>-xmp:copyrightstatus=
-XMP-xmpRights:Marked=
</cfif>
-xmp:UsageTerms=#replacenocase(ParagraphFormat(arguments.thestruct.iptc_status_rights_usage_terms),"<p>","","all")#
			</cfsavecontent>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in writing the XML file to savecontent in function xmp.xmpwrite">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
		</cfoutput>
		<!--- Save XMP to DB --->
			<cfquery datasource="#application.razuna.datasource#">
			UPDATE #session.hostdbprefix#xmp
			SET
			subjectcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_content_subject_code#">,
			creator = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_author#">, 
			title = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_document_title#">, 
			authorsposition = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_author_title#">, 
			captionwriter = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_description_writer#">, 
			ciadrextadr = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_address#">, 
			category = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_category#">, 
			supplementalcategories = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_supplemental_categories#">, 
			urgency = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_origin_urgency#">, 
			description = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.img_desc#">, 
			ciadrcity = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_city#">, 
			ciadrctry = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_country#">, 
			location = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_image_location#">, 
			ciadrpcode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_postal_code#">, 
			ciemailwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_emails#">, 
			ciurlwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_websites#">, 
			citelwork = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_phones#">, 
			intellectualgenre = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_intellectual_genre#">, 
			instructions = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_status_instruction#">, 
			source = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_status_source#">, 
			usageterms = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_status_rights_usage_terms#">, 
			copyrightstatus = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_copyright_status#">, 
			transmissionreference = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_status_job_identifier#">, 
			webstatement = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_copyright_info_url#">, 
			headline = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_content_headline#">, 
			datecreated = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_date_created#">, 
			city = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_image_city#">, 
			ciadrregion = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_contact_state_province#">, 
			country = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_image_country#">, 
			countrycode = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_iso_country_code#">, 
			scene = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_scene#">, 
			state = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_image_state_province#">, 
			credit = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.iptc_status_provider#">, 
			rights  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.xmp_copyright_notice#">
			WHERE id_r = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND asset_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="img">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			</cfquery>
		<!--- Flush Cache --->
		<cfset resetcachetoken("images")>
		<cfset resetcachetoken("search")>
		<!--- Store XMP to file --->
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
		<!--- Check the platform and then decide on the Exiftool tag --->
		<cfif isWindows>
			<cfset theexe = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfelse>
			<cfset theexe = "#arguments.thestruct.thetools.exiftool#/exiftool">
			<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource," ","\ ","all")>
		</cfif>
		<!--- Storage: Local --->
		<cfif application.razuna.storage EQ "local">
			<cftry>
				<cfset arguments.thestruct.qryfile.path = arguments.thestruct.thesource>
				<!--- LOCATION OF XMP FILE --->
				<cfset thexmpfile = "#arguments.thestruct.assetpath#/#session.hostid#/#arguments.thestruct.path_to_asset#/xmp-#arguments.thestruct.file_id#">
				<!--- On Windows --->
				<cfif iswindows>
					<cfset thexmpfileraw = thexmpfile>
					<cfset thexmpfile = """#thexmpfile#""">
				<cfelse>
					<cfset thexmpfile = replacenocase(thexmpfile," ","\ ","all")>
					<cfset thexmpfile = replacenocase(thexmpfile,"&","\&","all")>
					<cfset thexmpfile = replacenocase(thexmpfile,"'","\'","all")>
					<cfset thexmpfileraw = thexmpfile>
				</cfif>
				<!--- Write XMP file to system --->
				<cffile action="write" file="#thexmpfileraw#" output="#tostring(thexmp)#" charset="utf-8">
				<!--- Write the sh script file --->
				<cfset thescript = createuuid()>
				<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.sh">
				<!--- On Windows a .bat --->
				<cfif iswindows>
					<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.bat">
				</cfif>
				<!--- Write files --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#theexe# -fast -fast2 -@ #thexmpfile# -overwrite_original #arguments.thestruct.thesource#" mode="777" charset="utf-8">
				<!--- Execute --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">
				<!--- Finally remove the XMP file --->
				<cfif FileExists(thexmpfile)>
					<cffile action="delete" file="#thexmpfile#">
				</cfif>
				<!--- MD5 hash file again since it has changed now --->
				<cfif FileExists(arguments.thestruct.thesource)>
					<cfset var md5hash = hashbinary(arguments.thestruct.thesource)>
				</cfif>
				<cfcatch type="any">
				    <cfset cfcatch.custom_message = "Error writing xml file in function xmp.xmpwrite">
					<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/> 
				</cfcatch>
			</cftry>
		<!--- Storage: Nirvanix --->
		<cfelseif application.razuna.storage EQ "nirvanix">
			<!--- Create temp directory --->
			<cfset arguments.thestruct.tempfolder = createuuid("")>
			<cfdirectory action="create" directory="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#" mode="775">
			<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#">
			<!--- LOCATION OF XMP FILE --->
			<cfset thexmpfile = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#/xmp-#arguments.thestruct.file_id#">
			<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#arguments.thestruct.tempfolder#.sh">
			<!--- Set source --->
			<cfset arguments.thestruct.thesource = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.filenameorg#">
			<!--- On Windows --->
			<cfif iswindows>
				<cfset thexmpfile = """#thexmpfile#""">
				<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#arguments.thestruct.tempfolder#.bat">
			</cfif>
			<!--- Write XMP file --->
			<cffile action="write" file="#thexmpfile#" output="#tostring(thexmp)#" charset="utf-8">
			<!--- Download image --->
			<cfhttp url="http://services.nirvanix.com/#arguments.thestruct.nvxsession#/razuna/#session.hostid#/#arguments.thestruct.path_to_asset#/#arguments.thestruct.filenameorg#" file="#arguments.thestruct.filenameorg#" path="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#"></cfhttp>
			<!--- Remove file on Nirvanix or else we get errors during uploading --->
			<cfset var remtt = createUUID("")>
			<cfthread name="#remtt#" intstruct="#arguments.thestruct#">
				<cfinvoke component="nirvanix" method="DeleteFiles">
					<cfinvokeargument name="filePath" value="/#attributes.intstruct.path_to_asset#/#attributes.intstruct.filenameorg#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait --->
			<cfthread action="join" name="#remtt#" />
			<!--- Write XMP to image with Exiftool --->
			<cfexecute name="#theexe#" arguments="-fast -fast2 -@ #thexmpfile# -overwrite_original #arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.filenameorg#" timeout="10" />
			<!--- MD5 hash file again since it has changed now --->
			<cfif FileExists(arguments.thestruct.thesource)>
				<cfset var md5hash = hashbinary(arguments.thestruct.thesource)>
			</cfif>
			<!--- Upload file again to its original position --->
			<cfset var uptt = createUUID("")>
			<cfthread name="#uptt#" intstruct="#arguments.thestruct#">
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#attributes.intstruct.path_to_asset#">
					<cfinvokeargument name="uploadfile" value="#attributes.intstruct.thepath#/incoming/#attributes.intstruct.tempfolder#/#attributes.intstruct.filenameorg#">
					<cfinvokeargument name="nvxsession" value="#attributes.intstruct.nvxsession#">
				</cfinvoke>
			</cfthread>
			<!--- Wait --->
			<cfthread action="join" name="#uptt#" />
			<!--- Remove the tempfolder but only if image has been uploaded already --->
			<cfif directoryExists("#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#")>
				<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#" recurse="true">
			</cfif>
		</cfif>
		<!--- Update images db with the new Lucene_Key --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix#images
		SET 
		lucene_key = <cfqueryparam value="#arguments.thestruct.thesource#" cfsqltype="cf_sql_varchar">,
		hashtag = <cfqueryparam value="#md5hash#" cfsqltype="CF_SQL_VARCHAR">,
		is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		WHERE img_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfloop>
</cffunction>

<!--- Prepare thread --->
<cffunction name="xmpwritekeydesc" output="false">
	<cfargument name="thestruct" type="struct">
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="xmpwritekeydesc_thread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- READ THE KEYWORDS AND DESCRIPION AND WRITE IT TO THE DB --->
<cffunction name="xmpwritekeydesc_thread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Declare Function Variables --->
	<cfset var keywords = "">
	<cfset var description = "">
	<cfset var thexmlcode = "">
	<cfset var themeta = "">
	<cftry>
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
		<!--- Check the platform and then decide on the Exiftool tag --->
		<cfif isWindows>
			<cfset theexe = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfelse>
			<cfset theexe = "#arguments.thestruct.thetools.exiftool#/exiftool">
		</cfif>
		<cfset theasset = arguments.thestruct.thesource>
		<!--- On Windows a bat --->
		<cfif isWindows>
			<cfexecute name="#theexe#" arguments="-X #theasset#" timeout="60" variable="themeta" />
		<cfelse>
			<!--- The script --->
			<cfset var thescript = createuuid()>
			<!--- Set script --->
			<cfset thesh = gettempdirectory() & "/#thescript#.sh">
			<!--- Write files --->
			<cffile action="write" file="#thesh#" output="#theexe# -fast -fast2 -X #theasset#" mode="777" charset="utf-8">
			<!--- Execute --->
			<cfexecute name="#thesh#" timeout="60" variable="themeta" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#thesh#">
		</cfif>
		<cfif themeta NEQ "">
			<!--- Parse Metadata which is now XML --->
			<cfset var thexml = xmlparse(ToString(themeta.getBytes(),'utf-8'))>
			<!--- Description from XMP --->
			<cfset x = xmlSearch(thexml, "//*/*/*[name()='XMP-dc:Description']")>
			<cfset y = xmlSearch(thexml, "//*/*/*[name()='IPTC:Caption-Abstract']")>
			<cfif arraylen(x) GT 0>
				<cfset description = trim(#x[1].xmlText#)>
			</cfif>
			<cfif arraylen(y) GT 0>
				<cfset description = trim(#y[1].xmlText#)>
			</cfif>
			<!--- Keywords from XMP (they are in the subject param) --->
			<cfset x = xmlSearch(thexml, "//*/*/*[name()='XMP-dc:Subject']/*/*")>
			<cfset y = xmlSearch(thexml, "//*/*/*[name()='IPTC:Keywords']/*/*")>
			<!--- If Keywords is empty because there is only ONE keyword then --->
			<cfif arraylen(x) EQ 0>
				<cfset x = xmlSearch(thexml, "//*/*/*[name()='XMP-dc:Subject']")>
			</cfif>
			<cfif arraylen(y) EQ 0>
				<cfset y = xmlSearch(thexml, "//*/*/*[name()='IPTC:Keywords']")>
			</cfif>
			<cfif arraylen(x) GT 0>
				<cfloop from="1" to="#arraylen(x)#" index="i">
					<cfset keywords = keywords & x[i].xmlText>
					<cfif arraylen(x) NEQ i>
						<cfset keywords = keywords & ",">
					</cfif>
				</cfloop>
			</cfif>
			<cfif arraylen(y) GT 0>
				<cfset keywords = "">
				<cfloop from="1" to="#arraylen(y)#" index="i">
					<cfset keywords = keywords & y[i].xmlText>
					<cfif arraylen(y) NEQ i>
						<cfset keywords = keywords & ",">
					</cfif>
				</cfloop>
			</cfif>	
			<!--- 
			Append the keywords and description to the images_text table. Since XMP is not multilingual we just insert it into 
			every language there is 
			--->
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<cfset newkeywords = "">
				<cfset newdescription = "">
				<cfparam name="arguments.thestruct.file_desc_#langindex#" default="">
				<cfparam name="arguments.thestruct.file_keywords_#langindex#" default="">
				<!--- Grab the user input --->
				<cfif structKeyExists(arguments.thestruct,'uploadkind') AND arguments.thestruct.uploadkind EQ "many">
					<cfset userdesc="file_desc_" & "#countnr#" & "_" & "#langindex#">
					<cfset userkeywords="file_keywords_" & "#countnr#" & "_" & "#langindex#">
				<cfelse>
					<cfset userdesc="arguments.thestruct.file_desc_" & "#langindex#">
					<cfset userkeywords="arguments.thestruct.file_keywords_" & "#langindex#">
				</cfif>
				<cfif userdesc CONTAINS #langindex#>
					<!--- Now put xmp values and user values together  --->
					<cfif evaluate(userkeywords) EQ "">
						<cfset newkeywords = keywords>
					<cfelse>
						<cfset newkeywords = evaluate(userkeywords) & "," & keywords>
					</cfif>
					<cfif evaluate(userdesc) EQ "">
						<cfset newdescription = description>
					<cfelse>
						<cfset newdescription = evaluate(userdesc) & " " & description>
					</cfif>
					<cftry>
						<!--- Append to DB --->
						<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#images_text
						SET 
						<cfif newkeywords EQ ",">
							img_keywords = <cfqueryparam value="" cfsqltype="cf_sql_varchar">
						<cfelse>
							img_keywords = <cfqueryparam value="#ltrim(newkeywords)#" cfsqltype="cf_sql_varchar">
						</cfif>,
						img_description = <cfqueryparam value="#ltrim(newdescription)#" cfsqltype="cf_sql_varchar">
						WHERE <cfif structKeyExists(arguments.thestruct,'newid')> img_id_r = <cfqueryparam value="#arguments.thestruct.newid#" cfsqltype="CF_SQL_VARCHAR"><cfelse>img_id_r = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR"></cfif>
						AND lang_id_r = <cfqueryparam value="#langindex#" cfsqltype="cf_sql_numeric">
						</cfquery>
						<cfcatch type="any">
							<cfset cfcatch.custom_message = "Error in image upload keywords in function xmp.xmpwritekeydesc_thread">
							<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
						</cfcatch>
					</cftry>
				</cfif>
			</cfloop>
		</cfif>
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function xmp.xmpwritekeydesc_thread">
			<!--- <cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/> --->
		</cfcatch>
	</cftry>
</cffunction>

<!--- Read the XMP parse it --->
<cffunction name="xmpparse" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Declare all variables or else you will get errors in the page --->
	<cfset xmp = structnew()>
	<cfset xmp.keywords = "">
	<cfset xmp.description = "">
	<cfset xmp.iptcsubjectcode = "">
	<cfset xmp.iptcscene = "">
	<cfset xmp.creator = "">
	<cfset xmp.title = "">
	<cfset xmp.authorstitle = "">
	<cfset xmp.descwriter = "">
	<cfset xmp.iptcaddress = "">
	<cfset xmp.iptccity = "">
	<cfset xmp.iptcstate = "">
	<cfset xmp.iptczip = "">
	<cfset xmp.iptccountry = "">
	<cfset xmp.iptcphone = "">
	<cfset xmp.iptcemail = "">
	<cfset xmp.iptcwebsite = "">
	<cfset xmp.iptcheadline = "">
	<cfset xmp.iptcdatecreated = "">
	<cfset xmp.iptcintelgenre = "">
	<cfset xmp.iptclocation = "">
	<cfset xmp.iptcimagecity = "">
	<cfset xmp.iptcimagestate = "">
	<cfset xmp.iptcimagecountry = "">
	<cfset xmp.iptcimagecountrycode = "">
	<cfset xmp.iptcjobidentifier = "">
	<cfset xmp.iptcinstructions = "">
	<cfset xmp.iptccredit = "">
	<cfset xmp.iptcsource = "">
	<cfset xmp.iptcusageterms = "">
	<cfset xmp.urgency = "">
	<cfset xmp.description = "">
	<cfset xmp.copynotice = "">
	<cfset xmp.copystatus = "">
	<cfset xmp.copyurl = "">
	<cfset xmp.category = "">
	<cfset xmp.categorysub = "">
	<cfset xmp.orgwidth = "">
	<cfset xmp.orgheight = "">
	<cfset xmp.colorspace = "">
	<cfset xmp.xres = "">
	<cfset xmp.yres = "">
	<cfset xmp.resunit = "">
	<cfset xmp.filetype = "">
	<cfset var thecoma = "">
	<cfset var themeta = "">
	<cfset var orientation = "">
	<cftry>
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
		<!--- Check the platform and then decide on the Exiftool tag --->
		<cfif isWindows>
			<cfset theexe = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfelse>
			<cfset theexe = "#arguments.thestruct.thetools.exiftool#/exiftool">
		</cfif>
		<cfset theasset = arguments.thestruct.thesource>
		<!--- On Windows a bat --->
		<cfif isWindows>
			<cfexecute name="#theexe#" arguments="-fast -fast2 -X #theasset#" timeout="60" variable="themeta" />
		<cfelse>
			<!--- New parsing code --->
			<cfset var thescript = createuuid()>
			<!--- Set script --->
			<cfset var thesh = gettempdirectory() & "/#thescript#.sh">
			<!--- Write files --->
			<cffile action="write" file="#thesh#" output="#theexe# -fast -fast2 -X #theasset#" mode="777" charset="utf-8">
			<!--- Execute --->
			<cfexecute name="#thesh#" timeout="60" variable="themeta" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#thesh#">
		</cfif>
		<!--- Parse Metadata which is now XML --->
		<cfset var thexml = xmlparse(ToString(themeta.getBytes(),'utf-8'))>
		<!--- <cfset var thexml = xmlparse(themeta)> --->
		<cfset thexml = xmlSearch(thexml, "//rdf:Description/")>
		<!--- orientation --->
		<cftry>
			<cfset orientation = trim(#thexml[1]["IFD0:Orientation"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- iptcsubjectcode --->
		<cftry>
			<cfset xmp.iptcsubjectcode = trim(#thexml[1]["XMP-iptcCore:SubjectCode"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- scene --->
		<cftry>
			<cfset xmp.iptcscene = trim(#thexml[1]["XMP-iptcCore:Scene"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- creator or IPTC:By-line --->
		<cftry>
			<cfset xmp.creator = trim(#thexml[1]["XMP-dc:Creator"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.creator EQ "">
			<cftry>
				<cfset xmp.creator = trim(#thexml[1]["IPTC:By-line"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- document title --->
		<cftry>
			<cfset xmp.title = trim(#thexml[1]["XMP-dc:Title"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.title EQ "">
			<cftry>
				<cfset xmp.title = trim(#thexml[1]["IPTC:ObjectName"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- AuthorsPosition --->
		<cftry>
			<cfset xmp.authorstitle = trim(#thexml[1]["XMP-photoshop:AuthorsPosition"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.authorstitle EQ "">
			<cftry>
				<cfset xmp.authorstitle = trim(#thexml[1]["IPTC:By-lineTitle"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- CaptionWriter --->
		<cftry>
			<cfset xmp.descwriter = trim(#thexml[1]["XMP-photoshop:CaptionWriter"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.descwriter EQ "">
			<cftry>
				<cfset xmp.descwriter = trim(#thexml[1]["IPTC:Writer-Editor"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- iptcaddress --->
		<cftry>
			<cfset xmp.iptcaddress = trim(#thexml[1]["XMP-iptcCore:CreatorAddress"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- Category --->
		<cftry>
			<cfset xmp.category = trim(#thexml[1]["XMP-photoshop:Category"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.category EQ "">
			<cftry>
				<cfset xmp.category = trim(#thexml[1]["IPTC:Category"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- Supplementalcategories --->
		<cftry>
			<cfset xmp.categorysub = trim(#thexml[1]["XMP-photoshop:SupplementalCategories"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.categorysub EQ "">
			<cftry>
				<cfset xmp.categorysub = trim(#thexml[1]["IPTC:SupplementalCategories"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- Urgency --->
		<cftry>
			<cfset xmp.urgency = trim(#thexml[1]["XMP-photoshop:Urgency"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.urgency EQ "">
			<cftry>
				<cfset xmp.urgency = trim(#thexml[1]["IPTC:Urgency"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- Description from XMP --->
		<cftry>
			<cfset xmp.description = trim(#thexml[1]["XMP-dc:Description"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.description EQ "">
			<cftry>
				<cfset xmp.description = trim(#thexml[1]["IPTC:Caption-Abstract"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- Keywords from XMP (they are in the subject param) --->
		<cftry>
			<cfset x = thexml[1]["XMP-dc:Subject"]["rdf:Bag"]["rdf:li"]>
			<cfcatch type="any">
				<cfset x = newarray(1)>
			</cfcatch>
		</cftry>
		<cftry>
			<cfset y = thexml[1]["IPTC:Keywords"]["rdf:Bag"]["rdf:li"]>
			<cfcatch type="any">
				<cfset y = newarray(1)>
			</cfcatch>
		</cftry>
		<!--- If subject XML is empty then check for single keyword --->
		<cfif arraylen(x) EQ 0>
			<cftry>
				<cfset xmp.keywords = thexml[1]["XMP-dc:Subject"].xmltext>
				<cfcatch type="any"></cfcatch>
			</cftry>
		<cfelse>
			<cfloop from="1" to="#arraylen(x)#" index="i">
				<cfset xmp.keywords = xmp.keywords & x[i].xmlText>
				<cfif arraylen(x) NEQ i>
					<cfset xmp.keywords = xmp.keywords & ",">
				</cfif>
			</cfloop>
		</cfif>
		<cfif arraylen(y) EQ 0>
			<cftry>
				<cfset xmp.keywords = thexml[1]["IPTC:Keywords"].xmltext>
				<cfcatch type="any"></cfcatch>
			</cftry>
		<cfelse>
			<cfset xmp.keywords = "">
			<cfloop from="1" to="#arraylen(y)#" index="i">
				<cfset xmp.keywords = xmp.keywords & y[i].xmlText>
				<cfif arraylen(y) NEQ i>
					<cfset xmp.keywords = xmp.keywords & ",">
				</cfif>
			</cfloop>
		</cfif>
		<!--- city --->
		<cftry>
			<cfset xmp.iptccity = trim(#thexml[1]["XMP-iptcCore:CreatorCity"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- state --->
		<cftry>
			<cfset xmp.iptcstate = trim(#thexml[1]["XMP-iptcCore:CreatorRegion"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- country --->
		<cftry>
			<cfset xmp.iptccountry = trim(#thexml[1]["XMP-iptcCore:CreatorCountry"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- location --->
		<cftry>
			<cfset xmp.iptclocation = trim(#thexml[1]["XMP-iptcCore:Location"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- zip --->
		<cftry>
			<cfset xmp.iptczip = trim(#thexml[1]["XMP-iptcCore:CreatorPostalCode"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- email --->
		<cftry>
			<cfset xmp.iptcemail = trim(#thexml[1]["XMP-iptcCore:CreatorWorkEmail"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- web --->
		<cftry>
			<cfset xmp.iptcwebsite = trim(#thexml[1]["XMP-iptcCore:CreatorWorkURL"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- phone --->
		<cftry>
			<cfset xmp.iptcphone = trim(#thexml[1]["XMP-iptcCore:CreatorWorkTelephone"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- IntellectualGenre --->
		<cftry>
			<cfset xmp.iptcintelgenre = trim(#thexml[1]["XMP-iptcCore:IntellectualGenre"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- Instructions --->
		<cftry>
			<cfset xmp.iptcinstructions = trim(#thexml[1]["XMP-photoshop:Instructions"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcinstructions EQ "">
			<cftry>
				<cfset xmp.iptcinstructions = trim(#thexml[1]["IPTC:SpecialInstructions"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- Credit --->
		<cftry>
			<cfset xmp.iptccredit = trim(#thexml[1]["XMP-photoshop:Credit"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptccredit EQ "">
			<cftry>
				<cfset xmp.iptccredit = trim(#thexml[1]["IPTC:Credit"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- Source --->
		<cftry>
			<cfset xmp.iptcsource = trim(#thexml[1]["XMP-photoshop:Source"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcsource EQ "">
			<cftry>
				<cfset xmp.iptcsource = trim(#thexml[1]["IPTC:Source"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- UsageTerms --->
		<cftry>
			<cfset xmp.iptcusageterms = trim(#thexml[1]["XMP-xmpRights:UsageTerms"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<!--- Rights --->
		<cftry>
			<cfset xmp.copynotice = trim(#thexml[1]["XMP-dc:Rights"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.copynotice EQ "">
			<cftry>
				<cfset xmp.copynotice = trim(#thexml[1]["IPTC:CopyrightNotice"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- copyrightstatus --->
		<cftry>
			<cfset xmp.copystatus = trim(#thexml[1]["XMP-xmpRights:Marked"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.copystatus EQ "">
			<cftry>
				<cfset xmp.copystatus = trim(#thexml[1]["Photoshop:CopyrightFlag"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- TransmissionReference --->
		<cftry>
			<cfset xmp.iptcjobidentifier = trim(#thexml[1]["XMP-photoshop:TransmissionReference"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcjobidentifier EQ "">
			<cftry>
				<cfset xmp.iptcjobidentifier = trim(#thexml[1]["IPTC:OriginalTransmissionReference"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- WebStatement --->
		<cftry>
			<cfset xmp.copyurl = trim(#thexml[1]["XMP-xmpRights:WebStatement"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.copyurl EQ "">
			<cftry>
				<cfset xmp.copyurl = trim(#thexml[1]["Photoshop:URL"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- headline --->
		<cftry>
			<cfset xmp.iptcheadline = trim(#thexml[1]["XMP-photoshop:Headline"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcheadline EQ "">
			<cftry>
				<cfset xmp.iptcheadline = trim(#thexml[1]["IPTC:Headline"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- datecreated --->
		<cftry>
			<cfset xmp.iptcdatecreated = trim(#thexml[1]["XMP-photoshop:DateCreated"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcdatecreated EQ "">
			<cftry>
				<cfset xmp.iptcdatecreated = trim(#thexml[1]["IPTC:DateCreated"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- city --->
		<cftry>
			<cfset xmp.iptcimagecity = trim(#thexml[1]["XMP-photoshop:City"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcimagecity EQ "">
			<cftry>
				<cfset xmp.iptcimagecity = trim(#thexml[1]["IPTC:City"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- state --->
		<cftry>
			<cfset xmp.iptcimagestate = trim(#thexml[1]["XMP-photoshop:State"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcimagestate EQ "">
			<cftry>
				<cfset xmp.iptcimagestate = trim(#thexml[1]["IPTC:Province-State"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- country --->
		<cftry>
			<cfset xmp.iptcimagecountry = trim(#thexml[1]["XMP-photoshop:Country"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		<cfif xmp.iptcimagecountry EQ "">
			<cftry>
				<cfset xmp.iptcimagecountry = trim(#thexml[1]["IPTC:Country-PrimaryLocationName"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfif>
		<!--- countrycode --->
		<cftry>
			<cfset xmp.iptcimagecountrycode = trim(#thexml[1]["XMP-iptcCore:CountryCode"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
		
		<cftry>
			<!--- Get height and width --->
			<cfset xmp.orgwidth = gettoken(trim(#thexml[1]["Composite:ImageSize"].xmltext#),1,'x')>
			<cfset xmp.orgheight = gettoken(trim(#thexml[1]["Composite:ImageSize"].xmltext#),2,'x')>
		<cfcatch type="any"></cfcatch>
		</cftry>

		<!--- Get fileType --->
		<cftry>
			<cfset xmp.filetype = trim(#thexml[1]["File:FileType"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>

		<!--- Get information according to filetype --->
		<cfif xmp.filetype EQ "psd">
			<cfif xmp.orgwidth EQ "" AND xmp.orgheight EQ "">
				<cftry>
					<cfset xmp.orgwidth = trim(#thexml[1]["Photoshop:ImageWidth"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
				<cftry>
					<cfset xmp.orgheight = trim(#thexml[1]["Photoshop:ImageHeight"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<cftry>
				<cfset xmp.colorspace = trim(#thexml[1]["Photoshop:ColorMode"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset xmp.xres = trim(#thexml[1]["Photoshop:XResolution"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset xmp.yres = trim(#thexml[1]["Photoshop:YResolution"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset xmp.resunit = trim(#thexml[1]["Photoshop:DisplayedUnitsX"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		<cfelseif xmp.filetype EQ "png">
			<cfif xmp.orgwidth EQ "" AND xmp.orgheight EQ "">
				<cftry>
					<cfset xmp.orgwidth = trim(#thexml[1]["PNG:ImageWidth"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
				<cftry>
					<cfset xmp.orgheight = trim(#thexml[1]["PNG:ImageHeight"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<cftry>
				<cfset xmp.colorspace = trim(#thexml[1]["PNG:ColorType"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset xmp.xres = trim(#thexml[1]["PNG:PixelsPerUnitX"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset xmp.yres = trim(#thexml[1]["PNG:PixelsPerUnitY"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cftry>
				<cfset xmp.resunit = trim(#thexml[1]["PNG:PixelUnits"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
		<cfelse>
			<cfif xmp.orgwidth EQ "">
				<!--- Width --->
				<cftry>
					<cfset xmp.orgwidth = trim(#thexml[1]["File:ImageWidth"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
				<cfif xmp.orgwidth EQ "">
					<cftry>
						<cfset xmp.orgwidth = trim(#thexml[1]["SubIFD1:ImageWidth"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgwidth EQ "">
					<cftry>
						<cfset xmp.orgwidth = trim(#thexml[1]["SubIFD:ImageWidth"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgwidth EQ "">
					<cftry>
						<cfset xmp.orgwidth = trim(#thexml[1]["IFD0:ImageWidth"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgwidth EQ "">
					<cftry>
						<cfset xmp.orgwidth = trim(#thexml[1]["ExifIFD:ExifImageWidth"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgwidth EQ "">
			            	<cftry>
			                	<cfset xmp.orgwidth = trim(#thexml[1]["#xmp.filetype#:ImageWidth"].xmltext#)>
			                   	<cfcatch type="any"></cfcatch>
			                	</cftry>
			          	</cfif>
		          </cfif>
			<!--- Height --->
			<cfif xmp.orgheight EQ "">
				<cftry>
					<cfset xmp.orgheight = trim(#thexml[1]["File:ImageHeight"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
				<cfif xmp.orgheight EQ "">
					<cftry>
						<cfset xmp.orgheight = trim(#thexml[1]["SubIFD1:ImageHeight"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgheight EQ "">
					<cftry>
						<cfset xmp.orgheight = trim(#thexml[1]["SubIFD:ImageHeight"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgheight EQ "">
					<cftry>
						<cfset xmp.orgheight = trim(#thexml[1]["IFD0:ImageHeight"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgheight EQ "">
					<cftry>
						<cfset xmp.orgheight = trim(#thexml[1]["ExifIFD:ExifImageHeight"].xmltext#)>
						<cfcatch type="any"></cfcatch>
					</cftry>
				</cfif>
				<cfif xmp.orgheight EQ "">
			            	<cftry>
			                	<cfset xmp.orgheight = trim(#thexml[1]["#xmp.filetype#:ImageHeight"].xmltext#)>
				             <cfcatch type="any"></cfcatch>
				             </cftry>
			            </cfif>
		        	</cfif>
			<!--- ColorSpace --->
			<cftry>
				<cfset xmp.colorspace = trim(#thexml[1]["ICC-header:ColorSpaceData"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cfif xmp.colorspace EQ "">
				<cftry>
					<cfset xmp.colorspace = trim(#thexml[1]["ExifIFD:ColorSpace"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<!--- Xresolution --->
			<cftry>
				<cfset xmp.xres = trim(#thexml[1]["IFD0:XResolution"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cfif xmp.xres EQ "">
				<cftry>
					<cfset xmp.xres = trim(#thexml[1]["JFIF:XResolution"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<cfif xmp.xres EQ "">
				<cftry>
					<cfset xmp.xres = trim(#thexml[1]["Photoshop:XResolution"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<!--- Yresolution --->
			<cftry>
				<cfset xmp.yres = trim(#thexml[1]["IFD0:YResolution"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cfif xmp.yres EQ "">
				<cftry>
					<cfset xmp.yres = trim(#thexml[1]["JFIF:YResolution"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<cfif xmp.yres EQ "">
				<cftry>
					<cfset xmp.yres = trim(#thexml[1]["Photoshop:YResolution"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
			<!--- Resolution Unit --->
			<cftry>
				<cfset xmp.resunit = trim(#thexml[1]["IFD0:ResolutionUnit"].xmltext#)>
				<cfcatch type="any"></cfcatch>
			</cftry>
			<cfif xmp.resunit EQ "">
				<cftry>
					<cfset xmp.resunit = trim(#thexml[1]["JFIF:ResolutionUnit"].xmltext#)>
					<cfcatch type="any"></cfcatch>
				</cftry>
			</cfif>
		</cfif>
		<!--- If orientation contain "rotate" then revert Width and Height --->
		<cfif orientation CONTAINS "rotate">
			<!--- Store width and height in temp vars first --->
			<cfset var w = xmp.orgwidth>
			<cfset var h = xmp.orgheight>
			<cfset xmp.orgwidth = h>
			<cfset xmp.orgheight = w>
		</cfif>
		<!--- Catch the error --->
		<cfcatch type="any">
			<cfset cfcatch.custom_message = "Error in function xmp.xmpparse">
		 	<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
		</cfcatch>
	</cftry>
	<!--- Return variable --->
	<cfreturn xmp>
</cffunction>

<!--- WRITE METADATA IN THREAD --->
<cffunction name="metatofile" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Set arguments --->
	<cfset arguments.thestruct.dsn = variables.dsn>
	<cfset arguments.thestruct.setid = variables.setid>
	<!--- The tool paths --->
	<cfinvoke component="settings" method="get_tools" returnVariable="arguments.thestruct.thetools" />
	<!--- Start the thread for updating --->
	<!--- <cfset tt = CreateUUid()> --->
	<!--- <cfinvoke method="metatofilethread" thestruct="#arguments.thestruct#" /> --->
	<cfthread intstruct="#arguments.thestruct#">
		<cfinvoke method="metatofilethread" thestruct="#attributes.intstruct#" />
	</cfthread>
</cffunction>

<!--- Write Metadata to files --->
<cffunction name="metatofilethread" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Param --->
	<cfparam default="F" name="arguments.thestruct.frombatch">
	<cfparam default="" name="arguments.thestruct.file_keywords">
	<cfparam default="" name="arguments.thestruct.file_desc">
	<cfparam default="" name="arguments.thestruct.author">
	<cfparam default="" name="arguments.thestruct.rights">
	<cfparam default="" name="arguments.thestruct.authorsposition">
	<cfparam default="" name="arguments.thestruct.captionwriter">
	<cfparam default="" name="arguments.thestruct.webstatement">
	<cfparam default="" name="arguments.thestruct.rightsmarked">
	<cfparam default="#session.hostid#" name="arguments.thestruct.hostid">
	<cfset var md5hash = "">
	<!--- Query the record --->
	<cfquery datasource="#variables.dsn#" name="arguments.thestruct.qrydetail">
	SELECT  f.file_id, f.folder_id_r, f.file_extension, f.file_type, f.file_name, f.file_name_org filenameorg, f.link_path_url, 
	f.link_kind, f.lucene_key, f.path_to_asset, f.cloud_url_org
	FROM #session.hostdbprefix#files f
	WHERE f.file_id = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
	AND f.host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
	</cfquery>
	<!--- Set the source --->
	<cfif arguments.thestruct.qrydetail.link_kind EQ "lan">
		<cfset arguments.thestruct.thesource = arguments.thestruct.qrydetail.link_path_url>
	<cfelse>
		<cfset arguments.thestruct.thesource = "#arguments.thestruct.assetpath#/#arguments.thestruct.hostid#/#arguments.thestruct.qrydetail.path_to_asset#/#arguments.thestruct.qrydetail.filenameorg#">
	</cfif>
	<!--- We are NOT coming from batching --->
	<cfif arguments.thestruct.frombatch EQ "F">
		<!--- Because we have many languages we put together the keywords and description here --->
		<cfif structkeyexists(arguments.thestruct,"langcount")>
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<cfset thiskeywords="arguments.thestruct.file_keywords_" & "#langindex#">
				<cfif evaluate(thiskeywords) NEQ "">
					<cfset arguments.thestruct.file_keywords = arguments.thestruct.file_keywords & evaluate(thiskeywords)>
					<cfif langindex LT langcount>
						<cfset arguments.thestruct.file_keywords = arguments.thestruct.file_keywords>
					</cfif>
					<cfset thisdesc="arguments.thestruct.file_desc_" & langindex>
					<cfset arguments.thestruct.file_desc = arguments.thestruct.file_desc & evaluate(thisdesc)>
					<cfif langindex LT langcount>
						<cfset arguments.thestruct.file_desc = arguments.thestruct.file_desc & " ">
					</cfif>
				</cfif>
			</cfloop>
		</cfif>
	<!--- We come from BATCHING --->
	<cfelse>
		<!--- We reset the desc and keywords by each loop or else they get the values from the previous record --->
		<cfset arguments.thestruct.img_desc = "">
		<cfset arguments.thestruct.img_keywords = "">
		<!--- Reset the xmlxmp struct --->
		<cfset xmlxmp = structnew()>
		<!--- call the compontent to read the XMP --->
		<cfinvoke method="xmpparse" returnvariable="xmlxmp" thestruct="#arguments.thestruct#">
		<!--- If there are values in the existing image then set the desc and keywords, thus we ADD the values from batching --->
		<cfset arguments.thestruct.img_desc = xmlxmp.description>
		<cfset arguments.thestruct.img_keywords = xmlxmp.keywords>
		<!--- Because we have many languages sometimes we put together the keywords and description here --->
		<cfif structkeyexists(arguments.thestruct,"langcount")>
			<cfloop list="#arguments.thestruct.langcount#" index="langindex">
				<!--- If we come from all we need to change the desc and keywords arguments name --->
				<cfif arguments.thestruct.what EQ "all">
					<cfset alldesc = "all_desc_" & langindex>
					<cfset allkeywords = "all_keywords_" & langindex>
					<cfset thisdesc = "arguments.thestruct.img_desc_" & langindex>
					<cfset thiskeywords = "arguments.thestruct.img_keywords_" & langindex>
					<cfset "#thisdesc#" =  evaluate(alldesc)>
					<cfset "#thiskeywords#" =  evaluate(allkeywords)>
				</cfif>
				<cfset thiskeywords="arguments.thestruct.img_keywords_" & langindex>
				<cfset arguments.thestruct.img_keywords = arguments.thestruct.img_keywords & evaluate(thiskeywords)>
				<cfif #langindex# LT #langcount#>
					<cfset arguments.thestruct.img_keywords = arguments.thestruct.img_keywords>
				</cfif>
				<cfset thisdesc="arguments.thestruct.img_desc_" & langindex>
				<cfset arguments.thestruct.img_desc = arguments.thestruct.img_desc & evaluate(thisdesc)>
				<cfif #langindex# LT #langcount#>
					<cfset arguments.thestruct.img_desc = arguments.thestruct.img_desc & " ">
				</cfif>
			</cfloop>
		</cfif>
	</cfif>
	<!--- Remove the last comma of the keyword string --->
	<cfset theright = trim(right(arguments.thestruct.file_keywords,2))>
	<!--- If the last char is a comma remove it --->
	<cfif theright EQ ",">
		<cfset thelen = len(arguments.thestruct.file_keywords)>
		<cfset thelen = thelen - 2>
		<cfset arguments.thestruct.file_keywords = mid(arguments.thestruct.file_keywords,1,thelen)>
	</cfif>
	<!--- Go grab the platform --->
	<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
	<!--- Check the platform and then decide on the Exiftool tag --->
	<cfif isWindows>
		<cfset theexe = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
	<cfelse>
		<cfset theexe = "#arguments.thestruct.thetools.exiftool#/exiftool">
		<cfset arguments.thestruct.thesource = replacenocase(arguments.thestruct.thesource," ","\ ","all")>
	</cfif>
	<!--- Storage: Local --->
	<cfif application.razuna.storage EQ "local">
		<cftry>
			<!--- Clear keywords from PDF (this should solve issues where keywords is shown multiple times in Acrobat) --->
			<cfexecute name="#theexe#" arguments="-fast -fast2 -XMP-pdf:Keywords= -overwrite_original #arguments.thestruct.thesource#" timeout="60" />
			<cfexecute name="#theexe#" arguments="-fast -fast2 -XMP-dc:subject= -overwrite_original #arguments.thestruct.thesource#" timeout="60" />
			<cfexecute name="#theexe#" arguments="-fast -fast2 -PDF:Keywords= -overwrite_original #arguments.thestruct.thesource#" timeout="60" />
			<!--- On Windows a .bat --->
			<cfif iswindows>
				<cfexecute name="#theexe#" arguments="-fast -fast2 -PDF:Subject='#arguments.thestruct.file_desc#' -XMP-dc:Description='#arguments.thestruct.file_desc#' -XMP-pdf:Keywords='#arguments.thestruct.file_keywords#' -PDF:Keywords='#arguments.thestruct.file_keywords#' -XMP-dc:Rights='#arguments.thestruct.rights#' -XMP-xmpRights:Marked='#arguments.thestruct.rightsmarked#' -XMP-xmpRights:WebStatement='#arguments.thestruct.webstatement#' -XMP-photoshop:AuthorsPosition='#arguments.thestruct.authorsposition#' -XMP-photoshop:CaptionWriter='#arguments.thestruct.captionwriter#' -XMP-dc:Creator='#arguments.thestruct.author#' -PDF:Author='#arguments.thestruct.author#' -overwrite_original #arguments.thestruct.thesource#" timeout="60" />
			<cfelse>
				<!--- Write the sh script file --->
				<cfset thescript = createuuid()>
				<cfset arguments.thestruct.thesh = GetTempDirectory() & "/#thescript#.sh">
				<!--- Write files --->
				<cffile action="write" file="#arguments.thestruct.thesh#" output="#theexe# -fast -fast2 -PDF:Subject='#arguments.thestruct.file_desc#' -XMP-dc:Description='#arguments.thestruct.file_desc#' -XMP-pdf:Keywords='#arguments.thestruct.file_keywords#' -PDF:Keywords='#arguments.thestruct.file_keywords#' -XMP-dc:Rights='#arguments.thestruct.rights#' -XMP-xmpRights:Marked='#arguments.thestruct.rightsmarked#' -XMP-xmpRights:WebStatement='#arguments.thestruct.webstatement#' -XMP-photoshop:AuthorsPosition='#arguments.thestruct.authorsposition#' -XMP-photoshop:CaptionWriter='#arguments.thestruct.captionwriter#' -XMP-dc:Creator='#arguments.thestruct.author#' -PDF:Author='#arguments.thestruct.author#' -overwrite_original #arguments.thestruct.thesource#" mode="777" charset="utf-8">
				<!--- Execute --->
				<cfexecute name="#arguments.thestruct.thesh#" timeout="60" />
				<!--- Delete scripts --->
				<cffile action="delete" file="#arguments.thestruct.thesh#">	
			</cfif>
			<!--- MD5 hash file again since it has changed now --->
			<cfif FileExists(arguments.thestruct.thesource)>
				<cfset var md5hash = hashbinary(arguments.thestruct.thesource)>
			</cfif>
			<cfcatch type="any">
				<cfset cfcatch.custom_message = "Error in metadata writing for files in function xmp.metatofilethread">
				<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
			</cfcatch>
		</cftry>
	<!--- Storage: Nirvanix --->
	<cfelseif application.razuna.storage EQ "nirvanix" OR application.razuna.storage EQ "amazon">
		<!--- Create temp directory --->
		<cfset arguments.thestruct.tempfolder = createuuid("")>
		<cfdirectory action="create" directory="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#" mode="775">
		<cfset arguments.thestruct.qryfile.path = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#">
		<!--- Set the source --->
		<cfset arguments.thestruct.thesource = "#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.qrydetail.filenameorg#">
		<!--- Download file --->
		<cfif application.razuna.storage EQ "nirvanix">
			<!--- Finally download --->
			<cfhttp url="#arguments.thestruct.qrydetail.cloud_url_org#" file="#arguments.thestruct.qrydetail.filenameorg#" path="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#"></cfhttp>
			<cfthread name="download#arguments.thestruct.file_id#" />
		<cfelseif application.razuna.storage EQ "amazon">
			<cfthread name="download#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Download">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qrydetail.path_to_asset#/#attributes.intstruct.qrydetail.filenameorg#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thepath#/incoming/#attributes.intstruct.tempfolder#/#attributes.intstruct.qrydetail.filenameorg#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
		</cfif>	
		<!--- Wait for the thread above until the file is downloaded fully --->
		<cfthread action="join" name="download#arguments.thestruct.file_id#" />
		<!--- Write XMP to image with Exiftool --->
		<cfexecute name="#theexe#" arguments="-fast -fast2 -PDF:Subject='#arguments.thestruct.file_desc#' -XMP-dc:Description='#arguments.thestruct.file_desc#' -XMP-pdf:Keywords='#arguments.thestruct.file_keywords#' -PDF:Keywords='#arguments.thestruct.file_keywords#' -XMP-dc:Rights='#arguments.thestruct.rights#' -XMP-xmpRights:Marked='#arguments.thestruct.rightsmarked#' -XMP-xmpRights:WebStatement='#arguments.thestruct.webstatement#' -XMP-photoshop:AuthorsPosition='#arguments.thestruct.authorsposition#' -XMP-photoshop:CaptionWriter='#arguments.thestruct.captionwriter#' -XMP-dc:Creator='#arguments.thestruct.author#' -PDF:Author='#arguments.thestruct.author#' -overwrite_original #arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.qrydetail.filenameorg#" timeout="10" />
		<!--- Upload file again to its original position --->
		<!--- NIRVANIX --->
		<cfif application.razuna.storage EQ "nirvanix">
			<!--- <cfthread name="upload#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#"> --->
				<!--- Remove file on Nirvanix or else we get errors during uploading --->
				<cfinvoke component="nirvanix" method="DeleteFiles">
					<cfinvokeargument name="filePath" value="/#arguments.thestruct.qrydetail.path_to_asset#/#arguments.thestruct.qrydetail.filenameorg#">
					<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
				</cfinvoke>
				<cfinvoke component="nirvanix" method="Upload">
					<cfinvokeargument name="destFolderPath" value="/#arguments.thestruct.qrydetail.path_to_asset#">
					<cfinvokeargument name="uploadfile" value="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#/#arguments.thestruct.qrydetail.filenameorg#">
					<cfinvokeargument name="nvxsession" value="#arguments.thestruct.nvxsession#">
				</cfinvoke>
			<!--- </cfthread> --->
		<!--- AMAZON --->
		<cfelseif application.razuna.storage EQ "amazon">
			<cfthread name="upload#arguments.thestruct.file_id#" intstruct="#arguments.thestruct#">
				<cfinvoke component="amazon" method="Upload">
					<cfinvokeargument name="key" value="/#attributes.intstruct.qrydetail.path_to_asset#/#attributes.intstruct.qrydetail.filenameorg#">
					<cfinvokeargument name="theasset" value="#attributes.intstruct.thepath#/incoming/#attributes.intstruct.tempfolder#/#attributes.intstruct.qrydetail.filenameorg#">
					<cfinvokeargument name="awsbucket" value="#attributes.intstruct.awsbucket#">
				</cfinvoke>
			</cfthread>
		</cfif>
		<!--- MD5 hash file again since it has changed now --->
		<cfif FileExists(arguments.thestruct.thesource)>
			<cfset var md5hash = hashbinary(arguments.thestruct.thesource)>
		</cfif>
		<!--- Remove the tempfolder but only if image has been uploaded already --->
		<!--- <cfthread action="join" name="upload#arguments.thestruct.file_id#" /> --->
		<cfdirectory action="delete" directory="#arguments.thestruct.thepath#/incoming/#arguments.thestruct.tempfolder#" recurse="true">
	</cfif>
	<!--- Update images db with the new Lucene_Key --->
	<cfquery datasource="#variables.dsn#">
	UPDATE #session.hostdbprefix#files
	SET 
	lucene_key = <cfqueryparam value="#arguments.thestruct.thesource#" cfsqltype="cf_sql_varchar">,
	hashtag = <cfqueryparam value="#md5hash#" cfsqltype="CF_SQL_VARCHAR">,
	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
	WHERE file_id = <cfqueryparam value="#arguments.thestruct.file_id#" cfsqltype="CF_SQL_VARCHAR">
	AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#arguments.thestruct.hostid#">
	</cfquery>
	<!--- Flush Cache --->
	<cfset resetcachetoken("files")>
</cffunction>

<!--- Get metadata for PDF --->
<cffunction name="getpdfxmp" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Parse Metadata which is now XML --->
	<cfset var thexml = xmlparse(ToString(arguments.thestruct.pdf_xmp.getBytes(),'utf-8'))>
	<cfset thexml = xmlSearch(thexml, "//rdf:Description/")>
	<!--- Params --->
	<cfset var thexmp = structnew()>
	<cfset thexmp.author = "">
	<cfset thexmp.rights = "">
	<cfset thexmp.AuthorsPosition = "">
	<cfset thexmp.CaptionWriter = "">
	<cfset thexmp.WebStatement = "">
	<cfset thexmp.rightsmarked = "">
	<!--- Parse the XMP --->
	<cftry>
		<cfset thexmp.author = trim(#thexml[1]["PDF:Author"].xmltext#)>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<cfif thexmp.author EQ "">
		<cftry>
			<cfset thexmp.author = trim(#thexml[1]["XMP-dc:Creator"].xmltext#)>
			<cfcatch type="any"></cfcatch>
		</cftry>
	</cfif>
	<cftry>
		<cfset thexmp.rights = trim(#thexml[1]["XMP-dc:Rights"].xmltext#)>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<cftry>
		<cfset thexmp.AuthorsPosition = trim(#thexml[1]["XMP-photoshop:AuthorsPosition"].xmltext#)>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<cftry>
		<cfset thexmp.CaptionWriter = trim(#thexml[1]["XMP-photoshop:CaptionWriter"].xmltext#)>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<cftry>
		<cfset thexmp.WebStatement = trim(#thexml[1]["XMP-xmpRights:WebStatement"].xmltext#)>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<cftry>
		<cfset thexmp.rightsmarked = trim(#thexml[1]["XMP-xmpRights:Marked"].xmltext#)>
		<cfcatch type="any"></cfcatch>
	</cftry>
	<!--- Write to DB --->
	<cfquery datasource="#application.razuna.datasource#">
	INSERT INTO #session.hostdbprefix#files_xmp
	(asset_id_r, author, rights, authorsposition, captionwriter, webstatement, rightsmarked, host_id)
	VALUES(
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.newid#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thexmp.author#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thexmp.rights#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thexmp.AuthorsPosition#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thexmp.CaptionWriter#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thexmp.WebStatement#">,
		<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#thexmp.rightsmarked#">,
		<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
	)
	</cfquery>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Export metadata --->
<cffunction name="meta_export" output="true">
	<cfargument name="thestruct" type="struct">
	<cfparam name="arguments.thestruct.exportname" default="#randRange(1,10000)#">
	<cfinvoke component="defaults" method="trans" transid="download_metadata_output" returnvariable="download_metadata_output" />
	<!--- Set local var --->
	<cfset var qry = "">
	<!--- Feedback --->
	<cfoutput><br/><strong>#download_metadata_output#</strong><br /></cfoutput>
	<cfflush>
	<!--- Param --->
	<!--- RAZ-2831 : Set metadata fields as per Export template --->
	<cfif structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount NEQ 0>
		<cfset img_columns = ''>
		<cfset doc_columns = ''>
		<cfset aud_columns = ''>
		<cfset vid_columns = ''>
		<!--- Get selected metadata to export --->
		<cfloop query="arguments.thestruct.export_template">
			<cfif exp_field EQ 'images_metadata'>
				<cfset arguments.thestruct.img_columns = ReplaceList(arguments.thestruct.export_template.exp_value,"img_id,img_filename,img_description,img_keywords,img_labels,img_create_time,img_change_time,img_width,img_height,img_size,img_upc_number,img_type,img_folder_id,img_foldername,img_file_url", "id,filename,description,keywords,labels,create_date,change_date,width,height,size,upc_number,type,folder_id,foldername,file_url")>
			</cfif>
			<cfif exp_field EQ 'files_metadata'>
				<cfset arguments.thestruct.doc_columns = ReplaceList(arguments.thestruct.export_template.exp_value,"file_id,file_name,file_desc,file_keywords,file_labels,file_create_time,file_change_time,file_size,file_upc_number,file_type,file_folder_id,file_foldername,file_file_url", "id,filename,description,keywords,labels,create_date,change_date,size,upc_number,type,folder_id,foldername,file_url")>
			</cfif>
			<cfif exp_field EQ 'audios_metadata'>
				<cfset arguments.thestruct.aud_columns = ReplaceList(arguments.thestruct.export_template.exp_value,"aud_id,aud_name,aud_description,aud_keywords,aud_labels,aud_create_time,aud_change_time,aud_size,aud_upc_number,aud_type,aud_folder_id,aud_foldername,aud_file_url", "id,filename,description,keywords,labels,create_date,change_date,size,upc_number,type,folder_id,foldername,file_url")>
			</cfif>
			<cfif exp_field EQ 'videos_metadata'>
				<cfset arguments.thestruct.vid_columns = ReplaceList(arguments.thestruct.export_template.exp_value,"vid_id,vid_filename,vid_description,vid_keywords,vid_labels,vid_create_time,vid_change_time,vid_width,vid_height,vid_size,vid_upc_number,vid_type,vid_folder_id,vid_foldername,vid_file_url", "id,filename,description,keywords,labels,create_date,change_date,width,height,size,upc_number,type,folder_id,foldername,file_url")>
			</cfif>
		</cfloop>
		<!--- Set Columns for Export --->
		<cfset arguments.thestruct.meta_fields = "">
		<cfif structKeyExists(arguments.thestruct,'img_columns')>
			<cfset arguments.thestruct.meta_fields = listappend(arguments.thestruct.meta_fields,"#arguments.thestruct.img_columns#",',')>
		</cfif>
		<cfif structKeyExists(arguments.thestruct,'doc_columns')>
			<cfset arguments.thestruct.meta_fields = listappend(arguments.thestruct.meta_fields,"#arguments.thestruct.doc_columns#",',')>
		</cfif>
		<cfif structKeyExists(arguments.thestruct,'aud_columns')>
			<cfset arguments.thestruct.meta_fields = listappend(arguments.thestruct.meta_fields,"#arguments.thestruct.aud_columns#",',')>
		</cfif>
		<cfif structKeyExists(arguments.thestruct,'vid_columns')>
			<cfset arguments.thestruct.meta_fields = listappend(arguments.thestruct.meta_fields,"#arguments.thestruct.vid_columns#",',')>
		</cfif>
		<cfset arguments.thestruct.meta_fields="#listremoveduplicates(arguments.thestruct.meta_fields)#">
	<cfelse>
		<cfset arguments.thestruct.meta_fields = "id,type,filename,file_url,foldername,folder_id,create_date,change_date,labels,keywords,description,iptcsubjectcode,creator,title,authorstitle,descwriter,iptcaddress,category,categorysub,urgency,iptccity,iptccountry,iptclocation,iptczip,iptcemail,iptcwebsite,iptcphone,iptcintelgenre,iptcinstructions,iptcsource,iptcusageterms,copystatus,iptcjobidentifier,copyurl,iptcheadline,iptcdatecreated,iptcimagecity,iptcimagestate,iptcimagecountry,iptcimagecountrycode,iptcscene,iptcstate,iptccredit,copynotice,pdf_author,pdf_rights,pdf_authorsposition,pdf_captionwriter,pdf_webstatement,pdf_rightsmarked">
	</cfif>
	<!--- Set for custom fields --->
	<cfset arguments.thestruct.cf_show = "all">
	<!--- Add another query structure for gettext --->
	<cfset arguments.thestruct.qry = querynew("id")>
	<!--- Create query object to store results --->
	<cfset arguments.thestruct.tq = querynew(arguments.thestruct.meta_fields)>
	<!--- Get all custom fields --->
	<cfinvoke component="custom_fields" method="get" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_cfields" />
	<!--- If this is from basket --->
	<cfif arguments.thestruct.what EQ "basket">
		<!--- Read Basket --->
		<cfinvoke component="basket" method="readbasket" returnvariable="thebasket">
		<!--- Loop over items in basket --->
		<cfloop query="thebasket">
			<!--- Set query --->
			<cfset QueryAddRow(arguments.thestruct.qry,1)>
			<cfset QuerySetCell(arguments.thestruct.qry, "id", cart_product_id)>
			<cfset arguments.thestruct.file_id = cart_product_id>
			<cfset arguments.thestruct.filetype = cart_file_type>
			<cfset arguments.thestruct.create_date = cart_create_date>
			<cfset arguments.thestruct.change_date = cart_change_date>
			<cfset arguments.thestruct.width = cart_width>
			<cfset arguments.thestruct.height = cart_height>
			<cfset arguments.thestruct.size = cart_size>
			<cfset arguments.thestruct.upc_number = upc_number>
			<!--- Get the files --->
			<cfinvoke method="loopfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
	<!--- For LABELS --->
	<!--- <cfelseif arguments.thestruct.what EQ "labels">
		<cfoutput><strong>Labels!</strong><br /></cfoutput>
		<cfdump var="#arguments.thestruct#"><cfabort>
		<cfflush> --->
	<!--- If we export all assets from folder --->
	<cfelseif arguments.thestruct.what EQ "folder">
		<!--- Get the cachetoken for here --->
		<cfset variables.cachetoken = getcachetoken("folders")>
		<!--- Get id from folder with type --->
		<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
		SELECT /* #variables.cachetoken#meta_export */ img_id AS theid, 'img' AS thetype, folder_id_r, 
		img_filename as url_file_name, cloud_url_org, img_create_time AS create_date, img_change_time AS change_date, img_size AS size, img_width AS width, img_height AS height, img_upc_number as upc_number
		FROM #session.hostdbprefix#images
		WHERE (img_group IS NULL OR img_group = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">) 
		<cfif arguments.thestruct.expwhat NEQ "all">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		</cfif>
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
		UNION ALL
		SELECT vid_id AS theid, 'vid' AS thetype,folder_id_r,vid_filename as url_file_name, cloud_url_org, vid_create_time AS create_date, vid_change_time AS change_date, vid_size AS size, vid_width AS width, vid_height AS height, vid_upc_number as upc_number
		FROM #session.hostdbprefix#videos
		WHERE (vid_group IS NULL OR vid_group = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">) 
		<cfif arguments.thestruct.expwhat NEQ "all">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		</cfif>
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
		UNION ALL
		SELECT aud_id AS theid, 'aud' AS thetype,folder_id_r,aud_name as url_file_name, cloud_url_org, aud_create_time AS create_date, aud_change_time AS change_date, aud_size AS size, NULL AS width, NULL As height, aud_upc_number as upc_number
		FROM #session.hostdbprefix#audios
		WHERE (aud_group IS NULL OR aud_group = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="">) 
		<cfif arguments.thestruct.expwhat NEQ "all">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		</cfif>
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
		UNION ALL
		SELECT file_id AS theid, 'doc' AS thetype,folder_id_r,file_name as url_file_name, cloud_url_org, file_create_time AS create_date, file_change_time AS change_date, file_size AS size, NULL AS width, NULL As height, file_upc_number as upc_number
		FROM #session.hostdbprefix#files
		WHERE host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
		<cfif arguments.thestruct.expwhat NEQ "all">
			AND folder_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.folder_id#">
		</cfif>
		</cfquery>
		<!--- Loop over items --->
		<cfloop query="qry">
			<!--- Set query --->
			<cfset QueryAddRow(arguments.thestruct.qry,1)>
			<cfset QuerySetCell(arguments.thestruct.qry, "id", theid)>
			<cfset arguments.thestruct.file_id = theid>
			<cfset arguments.thestruct.filetype = thetype>
			<cfset arguments.thestruct.create_date = create_date>
			<cfset arguments.thestruct.change_date = change_date>
			<cfset arguments.thestruct.width = width>
			<cfset arguments.thestruct.height = height>
			<cfset arguments.thestruct.size = size>
			<cfset arguments.thestruct.upc_number = upc_number>
			<!--- Get the files --->
			<cfinvoke method="loopfiles" thestruct="#arguments.thestruct#" />
		</cfloop>
	<!--- This is coming from a file list --->
	<cfelse>
		<cfset variables.cachetoken = getcachetoken("folders")>
		<!--- Loop over filelist --->
		<cfloop list="#session.file_id#" delimiters="," index="i">
			<!--- The first part is the ID the last the type --->
			<cfset arguments.thestruct.file_id = listfirst(i, "-")>
			<cfset arguments.thestruct.filetype = listlast(i, "-")>

			<!--- Get details about file --->
			<cfquery datasource="#application.razuna.datasource#" name="qry" cachedwithin="1" region="razcache">
			<cfif arguments.thestruct.filetype EQ 'img'>
			SELECT /* #variables.cachetoken#meta_export */ img_id AS theid, 'img' AS thetype, folder_id_r, 
			img_filename as url_file_name, cloud_url_org, img_create_time AS create_date, img_change_time AS change_date, img_size AS size, img_width AS width, img_height AS height, img_upc_number as upc_number
			FROM #session.hostdbprefix#images
			WHERE img_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			<cfelseif arguments.thestruct.filetype EQ 'vid'>
			SELECT vid_id AS theid, 'vid' AS thetype,folder_id_r,vid_filename as url_file_name, cloud_url_org, vid_create_time AS create_date, vid_change_time AS change_date, vid_size AS size, vid_width AS width, vid_height AS height, vid_upc_number as upc_number
			FROM #session.hostdbprefix#videos
			WHERE  vid_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			<cfelseif arguments.thestruct.filetype EQ 'aud'>
			SELECT aud_id AS theid, 'aud' AS thetype,folder_id_r,aud_name as url_file_name, cloud_url_org, aud_create_time AS create_date, aud_change_time AS change_date, aud_size AS size, NULL AS width, NULL As height, aud_upc_number as upc_number
			FROM #session.hostdbprefix#audios
			WHERE  aud_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			<cfelse>
			SELECT file_id AS theid, 'doc' AS thetype,folder_id_r,file_name as url_file_name, cloud_url_org, file_create_time AS create_date, file_change_time AS change_date, file_size AS size, NULL AS width, NULL As height, file_upc_number as upc_number
			FROM #session.hostdbprefix#files
			WHERE
			 file_id = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#arguments.thestruct.file_id#">
			AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
			AND in_trash = <cfqueryparam value="F" cfsqltype="CF_SQL_VARCHAR">
			</cfif>
			</cfquery>
			<!--- Loop over items --->
			<cfloop query="qry">
				<!--- Set query --->
				<cfset QueryAddRow(arguments.thestruct.qry,1)>
				<cfset QuerySetCell(arguments.thestruct.qry, "id", theid)>
				<cfset arguments.thestruct.file_id = theid>
				<cfset arguments.thestruct.filetype = thetype>
				<cfset arguments.thestruct.create_date = create_date>
				<cfset arguments.thestruct.change_date = change_date>
				<cfset arguments.thestruct.width = width>
				<cfset arguments.thestruct.height = height>
				<cfset arguments.thestruct.size = size>
				<cfset arguments.thestruct.upc_number = upc_number>
				<!--- Get the files --->
				<cfinvoke method="loopfiles" thestruct="#arguments.thestruct#" />
			</cfloop>
		</cfloop>
	</cfif>
	<!--- We got the query ready, continue export --->
	<!--- CVS --->
	<cfif arguments.thestruct.format EQ "csv">
		<cfinvoke method="export_csv" thestruct="#arguments.thestruct#" />
	<!--- XLS --->
	<cfelse>
		<!--- Add custom fields to meta fields --->
		<cfinvoke method="export_xls" thestruct="#arguments.thestruct#" />
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Loop to get files --->
<cffunction name="loopfiles" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Get the files according to the extension --->
	<cfswitch expression="#arguments.thestruct.filetype#">
		<!--- Images --->
		<cfcase value="img">
			<!--- Get asset detail --->
			<cfinvoke component="images" method="filedetail" theid="#arguments.thestruct.file_id#" thecolumn="img_filename, img_filename_org AS filenameorg, path_to_asset, cloud_url_org, folder_id_r, img_create_time, img_change_time, img_size" returnVariable="qry_image" />
			<cfset arguments.thestruct.filename = qry_image.img_filename>
			<cfset arguments.thestruct.folder_id_r = qry_image.folder_id_r>
			<!--- Get foldername --->
			<cfinvoke component="folders" method="getfoldername" folder_id="#arguments.thestruct.folder_id_r#" returnvariable="foldername" />
			<cfset arguments.thestruct.foldername = foldername>
			<!--- Get Labels --->
			<cfinvoke component="labels" method="getlabelstextexport" theid="#arguments.thestruct.file_id#" thetype="#arguments.thestruct.filetype#" returnVariable="arguments.thestruct.qry_labels" />
			<!--- Get Custom Fields --->
			<cfinvoke component="custom_fields" method="gettextvalues" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_cf" />
			<!--- Get keywords and description --->
			<cfinvoke component="images" method="gettext" qry="#arguments.thestruct.qry#" returnVariable="arguments.thestruct.qry_text" />
			<!--- Get XMP values --->
			<cfinvoke method="readxmpdb" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_xmp" />
			<!--- The file_url --->
			<cfif application.razuna.storage EQ "local">
				<cfset arguments.thestruct.file_url = "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#qry_image.path_to_asset#/#qry_image.filenameorg#">
			<cfelse>
				<cfset arguments.thestruct.file_url = qry_image.cloud_url_org>
			</cfif>
			<!--- Add Values to total query --->
			<cfif (structKeyExists(arguments.thestruct,"img_columns") AND arguments.thestruct.img_columns NEQ "") OR (structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount EQ 0)>
				<cfinvoke method="add_to_query" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfcase>
		<!--- Videos --->
		<cfcase value="vid">
			<!--- Get asset detail --->
			<cfinvoke component="videos" method="getdetails" vid_id="#arguments.thestruct.file_id#" ColumnList="v.vid_filename, v.vid_name_org AS filenameorg, v.path_to_asset, v.cloud_url_org, v.folder_id_r, v.vid_create_time, v.vid_change_time, v.vid_size" returnVariable="qry_video" />
			<cfset arguments.thestruct.filename = qry_video.vid_filename>
			<cfset arguments.thestruct.folder_id_r = qry_video.folder_id_r>
			<!--- Get foldername --->
			<cfinvoke component="folders" method="getfoldername" folder_id="#arguments.thestruct.folder_id_r#" returnvariable="foldername" />
			<cfset arguments.thestruct.foldername = foldername>
			<!--- Get Labels --->
			<cfinvoke component="labels" method="getlabelstextexport" theid="#arguments.thestruct.file_id#" thetype="#arguments.thestruct.filetype#" returnVariable="arguments.thestruct.qry_labels" />
			<!--- Get Custom Fields --->
			<cfinvoke component="custom_fields" method="gettextvalues" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_cf" />
			<!--- Get keywords and description --->
			<cfinvoke component="videos" method="gettext" qry="#arguments.thestruct.qry#" returnVariable="arguments.thestruct.qry_text" />
			<cfif application.razuna.storage EQ "local">
				<cfset arguments.thestruct.file_url = "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#qry_video.path_to_asset#/#qry_video.filenameorg#">
			<cfelse>
				<cfset arguments.thestruct.file_url = qry_video.cloud_url_org>
			</cfif>
			<!--- Add Values to total query --->
			<cfif structKeyExists(arguments.thestruct,"vid_columns") AND arguments.thestruct.vid_columns NEQ "" OR (structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount EQ 0)>
				<cfinvoke method="add_to_query" thestruct="#arguments.thestruct#" />
			</cfif>
		</cfcase>
		<!--- Audios --->
		<cfcase value="aud">
			<!--- Get asset detail --->
			<cfinvoke component="audios" method="detail" thestruct="#arguments.thestruct#" returnVariable="qry_audio" />
			<cfset arguments.thestruct.filename = qry_audio.detail.aud_name>
			<cfset arguments.thestruct.folder_id_r = qry_audio.detail.folder_id_r>
			<!--- Get foldername --->
			<cfinvoke component="folders" method="getfoldername" folder_id="#arguments.thestruct.folder_id_r#" returnvariable="foldername" />
			<cfset arguments.thestruct.foldername = foldername>
			<cftry>
				<cfset var audarray = ArrayNew(1)>
				<cfset audarray[1] = qry_audio.desc.aud_keywords>
				<cfset QueryAddcolumn(qry_audio.desc, "keywords", "varchar", audarray)>
				<cfset audarray[1] = qry_audio.desc.aud_description>
				<cfset QueryAddcolumn(qry_audio.desc, "description", "varchar", audarray)>
				<cfcatch type="any">
					<cfset QuerySetCell(qry_audio.desc, "keywords", qry_audio.desc.aud_keywords)>
					<cfset QuerySetCell(qry_audio.desc, "description", qry_audio.desc.aud_description)>
				</cfcatch>
			</cftry>
			<cfset arguments.thestruct.qry_text = qry_audio.desc>
			<!--- Get Labels --->
			<cfinvoke component="labels" method="getlabelstextexport" theid="#arguments.thestruct.file_id#" thetype="#arguments.thestruct.filetype#" returnVariable="arguments.thestruct.qry_labels" />
			<!--- Get Custom Fields --->
			<cfinvoke component="custom_fields" method="gettextvalues" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_cf" />
			<!--- Get keywords and description --->
			<cfinvoke component="audios" method="gettext" qry="#arguments.thestruct.qry#" returnVariable="arguments.thestruct.qry_text" />
			<cfif application.razuna.storage EQ "local">
				<cfset arguments.thestruct.file_url = "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#qry_audio.detail.path_to_asset#/#qry_audio.detail.filenameorg#">
			<cfelse>
				<cfset arguments.thestruct.file_url = qry_audio.detail.cloud_url_org>
			</cfif>
			<!--- Add Values to total query --->
			<cfif structKeyExists(arguments.thestruct,"aud_columns") AND arguments.thestruct.aud_columns NEQ "" OR (structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount EQ 0)>
				<cfinvoke method="add_to_query" thestruct="#arguments.thestruct#" />
			</cfif>	
		</cfcase>
		<!--- All other files --->
		<cfdefaultcase>
			<!--- Get asset detail --->
			<cfinvoke component="files" method="filedetail" theid="#arguments.thestruct.file_id#" thecolumn="file_name, file_name_org AS filenameorg, path_to_asset, cloud_url_org, folder_id_r" returnVariable="qry_doc" />
			<cfset arguments.thestruct.filename = qry_doc.file_name>
			<cfset arguments.thestruct.folder_id_r = qry_doc.folder_id_r>
			<!--- Get foldername --->
			<cfinvoke component="folders" method="getfoldername" folder_id="#arguments.thestruct.folder_id_r#" returnvariable="foldername" />
			<cfset arguments.thestruct.foldername = foldername>
			<!--- Get Labels --->
			<cfinvoke component="labels" method="getlabelstextexport" theid="#arguments.thestruct.file_id#" thetype="#arguments.thestruct.filetype#" returnVariable="arguments.thestruct.qry_labels" />
			<!--- Get Custom Fields --->
			<cfinvoke component="custom_fields" method="gettextvalues" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_cf" />
			<!--- Get keywords and description --->
			<cfinvoke component="files" method="gettext" qry="#arguments.thestruct.qry#" returnVariable="arguments.thestruct.qry_text" />
			<!--- Get PDF XMP --->
			<cfinvoke component="files" method="getpdfxmp" thestruct="#arguments.thestruct#" returnVariable="arguments.thestruct.qry_pdfxmp" />
			<cfif application.razuna.storage EQ "local">
				<cfset arguments.thestruct.file_url = "#session.thehttp##cgi.http_host##cgi.context_path#/assets/#session.hostid#/#qry_doc.path_to_asset#/#qry_doc.filenameorg#">
			<cfelse>
				<cfset arguments.thestruct.file_url = qry_doc.cloud_url_org>
			</cfif>
			<!--- Add Values to total query --->
			<cfif structKeyExists(arguments.thestruct,"doc_columns") AND arguments.thestruct.doc_columns NEQ "" OR (structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount EQ 0)>	
				<cfinvoke method="add_to_query" thestruct="#arguments.thestruct#" />
			</cfif>	
		</cfdefaultcase>
	</cfswitch>
	<!--- Feedback --->
	<cfoutput><strong> .</strong></cfoutput>
	<cfflush>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Export CSV --->
<cffunction name="export_csv" output="false">
	<cfargument name="thestruct" type="struct">		
	<!--- Create CSV --->
	<cfset var csv = csvwrite(arguments.thestruct.tq)>
	<cfif isdefined("arguments.thestruct.exportname")>
		<cfset var suffix = "#arguments.thestruct.exportname#">
	<cfelse>
		<cfset var suffix = "#session.hostid#-#session.theuserid#">
	</cfif>
	<!--- Write file to file system --->
	<cffile action="write" file="#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.csv" output="#csv#" charset="utf-8" nameconflict="overwrite">
	<!--- Serve the file --->
	<!--- <cfcontent type="application/force-download" variable="#csv#"> --->
	<!--- Feedback --->
	<!--- Show export file link only if export file is generated from a direct call to fuseaction. If called from other fuseactions then dont show link as file will be part of other download --->
	<cfif arguments.thestruct.fa EQ 'c.meta_export_do'>
		<cfoutput><p><a href="outgoing/metadata-export-#suffix#.csv"><strong style="color:green;">Here is your downloadable file</strong></a></p></cfoutput>
	</cfif>
	<cfflush>
	<!--- Call function to remove older files --->
	<cfinvoke method="remove_files" thestruct="#arguments.thestruct#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Export CLS --->
<cffunction name="export_xls" output="true">
	<cfargument name="thestruct" type="struct">
	<!--- Create Spreadsheet --->
	<cfif arguments.thestruct.format EQ "xls">
		<cfset var sxls = spreadsheetnew()>
	<cfelseif arguments.thestruct.format EQ "xlsx">
		<cfset var sxls = spreadsheetnew(true)>
	</cfif>
	<cfset fields = #arguments.thestruct.meta_fields#>
	<cfset create_date_pos = listFind(fields,'create_date')>
	<cfset change_date_pos = listfind(fields,'change_date')>
	<!--- Create header row --->
	<cfset SpreadsheetAddrow(sxls, arguments.thestruct.meta_fields, 1)>
	<cfset SpreadsheetFormatRow(sxls, {bold=TRUE, alignment="left"}, 1)>
	<cfset SpreadsheetColumnfittosize(sxls, "1-#len(arguments.thestruct.meta_fields)#")>
	<cfset SpreadsheetSetcolumnwidth(sxls, 1, 10000)>
	<!--- Add orders from query --->
	<cfif arguments.thestruct.export_template.recordcount NEQ 0>
		<cfset SpreadsheetFormatColumns(sxls, {dateformat="yyyy-mm-dd"}, '#create_date_pos#')>
		<cfset SpreadsheetFormatColumns(sxls, {dateformat="yyyy-mm-dd"}, '#change_date_pos#')>
	<cfelse>	 
		<cfset SpreadsheetFormatrow(sxls, {alignment="vertical_top"}, 2)>
	</cfif>
	<cfset SpreadsheetAddRows(sxls, arguments.thestruct.tq, 2)>
	<cfif isdefined("arguments.thestruct.exportname")>
		<cfset var suffix = "#arguments.thestruct.exportname#">
	<cfelse>
		<cfset var suffix = "#session.hostid#-#session.theuserid#">
	</cfif>
	<!--- Write file to file system --->
	<cfset SpreadsheetWrite(sxls,"#arguments.thestruct.thepath#/outgoing/metadata-export-#suffix#.#arguments.thestruct.format#",true)>
	<!--- Serve the file --->
    <!--- <cfcontent type="application/force-download" variable="#SpreadsheetReadbinary(sxls)#"> --->
	<!--- Feedback --->
	<!--- Show export file link only if export file is generated from a direct call to fuseaction. If called from other fuseactions then dont show link as file will be part of other download --->
	<cfif arguments.thestruct.fa EQ 'c.meta_export_do'>
		<cfoutput><p><a href="outgoing/metadata-export-#suffix#.#arguments.thestruct.format#"><strong style="color:green;">Here is your downloadable file</strong></a></p></cfoutput>
	</cfif>
	<cfflush>
	<!--- Call function to remove older files --->
	<cfinvoke method="remove_files" thestruct="#arguments.thestruct#" />
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Remove old export files --->
<cffunction name="remove_files" output="no">
	<cfargument name="thestruct" type="struct">
	<cftry>
		<!--- Set time for remove --->
		<cfset removetime = DateAdd("h", -6, "#now()#")>
		<!--- Now check directory on the hard drive. This will fix issue with files that were not successfully uploaded thus missing in the temp db --->
		<cfdirectory action="list" directory="#arguments.thestruct.thepath#/outgoing" name="thefiles" type="file">
		<!--- Loop over dirs --->
		<cfloop query="thefiles">
			<cfif datelastmodified LT removetime AND FileExists("#arguments.thestruct.thepath#/outgoing/#name#")>
				<cffile action="delete" file="#arguments.thestruct.thepath#/outgoing/#name#">
			</cfif>
		</cfloop>
		<cfcatch type="any"></cfcatch>
	</cftry>
</cffunction>

<!--- Add to query --->
<cffunction name="add_to_query" >
	<cfargument name="thestruct" type="struct">
	<cfset StrEscUtils = createObject("java", "org.apache.commons.lang.StringEscapeUtils")><!---  Create object whose methods will be used to escape HTML characters --->
	<cfinvoke component="defaults" method="getdateformat" returnvariable="thedateformat" dsn="#application.razuna.datasource#">
	<cfif structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount NEQ 0>
		<!--- Add row local query --->
		<cfset QueryAddRow(arguments.thestruct.tq,1)>
		<cfloop query="arguments.thestruct.export_template" >
			<cfif (structKeyExists(arguments.thestruct,'img_columns') AND "#arguments.thestruct.img_columns#" NEQ "" ) OR (structKeyExists(arguments.thestruct,'doc_columns') AND "#arguments.thestruct.doc_columns#" NEQ "" ) OR (structKeyExists(arguments.thestruct,'vid_columns') AND "#arguments.thestruct.vid_columns#" NEQ "" ) OR (structKeyExists(arguments.thestruct,'aud_columns') AND "#arguments.thestruct.aud_columns#" NEQ "" )>
				<cfif (#exp_field# EQ "images_metadata") OR (#exp_field# EQ "files_metadata") OR(#exp_field# EQ "videos_metadata") OR (#exp_field# EQ "audios_metadata")>
					<cfloop list="#valueList(arguments.thestruct.export_template.exp_value)#" index="idx" delimiters="," > 
						<!--- Add id --->
						<cfif ("#idx#" EQ "img_id" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_id" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_id"  AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_id")  AND "#arguments.thestruct.filetype#" EQ "aud"> 
							<cfset QuerySetCell(arguments.thestruct.tq, "id", arguments.thestruct.file_id)>
						</cfif>
						<!--- Add Type --->
						<cfif ("#idx#" EQ "img_type" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_type" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_type"  AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_type")  AND "#arguments.thestruct.filetype#" EQ "aud"> 
							<cfset QuerySetCell(arguments.thestruct.tq, "type", arguments.thestruct.filetype)>
						</cfif>
						<!--- Add FolderID --->
						<cfif ("#idx#" EQ "img_folder_id" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_folder_id" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_folder_id"  AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_folder_id")  AND "#arguments.thestruct.filetype#" EQ "aud"> 
							<cfset QuerySetCell(arguments.thestruct.tq, "folder_id", arguments.thestruct.folder_id_r)>
						</cfif>
						<!--- Add Folder Name --->
						<cfif ("#idx#" EQ "img_foldername" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_foldername" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_foldername"  AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_foldername")  AND "#arguments.thestruct.filetype#" EQ "aud"> 
							<cfset QuerySetCell(arguments.thestruct.tq, "foldername", arguments.thestruct.foldername)>
						</cfif>
						<!--- Add File URL --->
						<cfif ("#idx#" EQ "img_file_url" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_file_url" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_file_url"  AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_file_url")  AND "#arguments.thestruct.filetype#" EQ "aud"> 
							<cfset QuerySetCell(arguments.thestruct.tq, "file_url", arguments.thestruct.file_url)>
						</cfif>
						<!--- Add File Name --->
						<cfif ("#idx#" EQ "img_filename" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_name" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_filename" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_name" AND "#arguments.thestruct.filetype#" EQ "aud")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "filename", arguments.thestruct.filename)>
						</cfif>
						<!--- Add create time --->
						<cfif ("#idx#" EQ "img_create_time" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_create_time" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_create_time" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_create_time" AND "#arguments.thestruct.filetype#" EQ "aud")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "create_date", dateformat(arguments.thestruct.create_date,'#thedateformat#') & " " & timeformat(arguments.thestruct.create_date,'HH:mm:ss'))>
						</cfif>
						<!--- Add Change time --->
						<cfif ("#idx#" EQ "img_change_time" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_change_time" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_change_time" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_change_time" AND "#arguments.thestruct.filetype#" EQ "aud")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "change_date", dateformat(arguments.thestruct.change_date,'#thedateformat#') & " " & timeformat(arguments.thestruct.change_date,'HH:mm:ss'))>
						</cfif>
						<!--- Add Width --->
						<cfif ("#idx#" EQ "img_width" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "vid_width" AND "#arguments.thestruct.filetype#" EQ "vid")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "width", arguments.thestruct.width)>
						</cfif>
						<!--- Add Height --->
						<cfif ("#idx#" EQ "img_height" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "vid_height" AND "#arguments.thestruct.filetype#" EQ "vid")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "height", arguments.thestruct.height)>
						</cfif>
						<!--- Add Size --->
						<cfif ("#idx#" EQ "img_size" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_size" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_size" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_size" AND "#arguments.thestruct.filetype#" EQ "aud")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "size", arguments.thestruct.size)>
						</cfif>
						<!--- Add UPC number --->
						<cfif ("#idx#" EQ "img_upc_number" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_upc_number" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_upc_number" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_upc_number" AND "#arguments.thestruct.filetype#" EQ "aud")> 
							<cfset QuerySetCell(arguments.thestruct.tq, "upc_number", arguments.thestruct.upc_number)>
						</cfif>
						<!--- Add keywords and description --->
						<cfif arguments.thestruct.qry_text.recordcount NEQ 0>
							<cfloop query="arguments.thestruct.qry_text">
								<cfif tid EQ arguments.thestruct.file_id>
									<cfif ("#idx#" EQ "img_keywords" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_keywords" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_keywords" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_keywords" AND "#arguments.thestruct.filetype#" EQ "aud")> 
										<cfset QuerySetCell(arguments.thestruct.tq, "keywords", arguments.thestruct.qry_text.keywords)>
									</cfif>
									<cfif ("#idx#" EQ "img_description" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_desc" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_description" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_description" AND "#arguments.thestruct.filetype#" EQ "aud")>
										<cfset QuerySetCell(arguments.thestruct.tq, "description", arguments.thestruct.qry_text.description)>
									</cfif>
								</cfif>
							</cfloop>
						</cfif>
						<!--- Add Labels --->
						<cfif ("#idx#" EQ "img_labels" AND "#arguments.thestruct.filetype#" EQ "img") OR ("#idx#" EQ "file_labels" AND "#arguments.thestruct.filetype#" EQ "doc") OR ("#idx#" EQ "vid_labels" AND "#arguments.thestruct.filetype#" EQ "vid") OR ("#idx#" EQ "aud_labels" AND "#arguments.thestruct.filetype#" EQ "aud")> 
							<cfif arguments.thestruct.qry_labels NEQ "">
								<cfset QuerySetCell(arguments.thestruct.tq, "labels", arguments.thestruct.qry_labels)>
							</cfif>
						</cfif>
						<!--- Add custom fields --->
						<cfloop query="arguments.thestruct.qry_cfields">
          							<cfif idx eq "#cf_text#:#cf_id#">
	          							<cfquery name="qcf" dbtype="query">
									SELECT cf_value
									FROM arguments.thestruct.qry_cf
									WHERE cf_text = '#cf_text#'
								</cfquery>
	          							<cfset QuerySetCell(arguments.thestruct.tq, "#cf_text#:#cf_id#", "#StrEscUtils.unescapeHTML(qcf.cf_value)#")>
          							</cfif>
          						</cfloop>
					</cfloop>
				</cfif>
			</cfif>	
		</cfloop>
	<cfelse>	
		<!--- Add row local query --->
		<cfset QueryAddRow(arguments.thestruct.tq,1)>
		<!--- Add id --->
		<cfset QuerySetCell(arguments.thestruct.tq, "id", arguments.thestruct.file_id)>
		<!--- Add type --->
		<cfset QuerySetCell(arguments.thestruct.tq, "type", arguments.thestruct.filetype)>
		<!--- Add filename --->
		<cfset QuerySetCell(arguments.thestruct.tq, "filename", arguments.thestruct.filename)>
		<!--- Add file_url --->
		<cfset QuerySetCell(arguments.thestruct.tq, "file_url", arguments.thestruct.file_url)>
		<!--- Add folder_id_r --->
		<cfset QuerySetCell(arguments.thestruct.tq, "folder_id", arguments.thestruct.folder_id_r)>
		<!--- Add folder_name --->
		<cfset QuerySetCell(arguments.thestruct.tq, "foldername", arguments.thestruct.foldername)>
		<!--- Add create_date --->
		<cfset QuerySetCell(arguments.thestruct.tq, "create_date", dateformat(arguments.thestruct.create_date,'#thedateformat#') & "  " & timeformat(arguments.thestruct.create_date,'HH:mm:ss'))>
		<!--- Add change_date --->
		<cfset QuerySetCell(arguments.thestruct.tq, "change_date", dateformat(arguments.thestruct.change_date,'#thedateformat#') & " " & timeformat(arguments.thestruct.change_date,'HH:mm:ss'))>
		<!--- Add Labels --->
		<cfif arguments.thestruct.qry_labels NEQ "">
			<cfset QuerySetCell(arguments.thestruct.tq, "labels", arguments.thestruct.qry_labels)>
		</cfif>
	
	<!--- Add custom fields --->
	<cfloop query="arguments.thestruct.qry_cfields">
		<!--- Replace foreign chars in column names --->
		<cfset var cfcolumn = REReplace(cf_text, "([^[:alnum:]^-]+)", "_", "ALL") & ":#cf_id#">
		<cfset var qcf = "">
		<!--- Query the query first to see if there is already a column with this custom field there. If not then add column else set cell --->
		<cfquery name="qcf" dbtype="query">
		SELECT *
		FROM arguments.thestruct.tq
		WHERE id = '#arguments.thestruct.file_id#'
		</cfquery>
		<!--- Check if the above query returns the custom text column in the columnlist --->
		<cfset var qhas = ListFindNoCase(qcf.columnlist, cfcolumn)>
		<cfif qhas EQ 0>
			<!--- Add new column with value --->
			<cfset MyArray = ArrayNew(1)>
			<cfset MyArray[1] = "">
			<cfset QueryAddcolumn(arguments.thestruct.tq, cfcolumn, "varchar", MyArray)>
			<cfset arguments.thestruct.meta_fields = arguments.thestruct.meta_fields & "," & cfcolumn>
		</cfif>
	</cfloop>
	<!--- Add custom fields values --->
	<cfloop query="arguments.thestruct.qry_cf">
		<!--- Replace foreign chars in column names --->
		<cfset var cfcolumn = REReplace(cf_text, "([^[:alnum:]^-]+)", "_", "ALL") & ":#cf_id_r#">
		<cfset arguments.thestruct.qry_cf.cf_value =StrEscUtils.unescapeHTML(arguments.thestruct.qry_cf.cf_value)>
		<!--- Set Cell --->
		<cfset QuerySetCell(arguments.thestruct.tq, cfcolumn, cf_value)>
	</cfloop>
	<!--- Add keywords and description --->
	<cfif arguments.thestruct.qry_text.recordcount NEQ 0>
		<cfloop query="arguments.thestruct.qry_text">
			<cfif tid EQ arguments.thestruct.file_id>
			<cfset QuerySetCell(arguments.thestruct.tq, "keywords", keywords)>
			<cfset QuerySetCell(arguments.thestruct.tq, "description", description)>
			</cfif>
		</cfloop>
	</cfif>
	</cfif>
	<!--- Add XMP --->
	<!--- RAZ-2831 : Add metadata to Export file --->
	<cfif structKeyExists(arguments.thestruct,'export_template') AND arguments.thestruct.export_template.recordcount NEQ 0 AND structkeyexists(arguments.thestruct.export_template,"exp_field")>
		<cfif structKeyExists(arguments.thestruct,'qry_xmp')>
			<cfloop query="arguments.thestruct.qry_xmp">
				<!--- Loop to set images metadata values to selected metadata into export file--->
				<cfloop list="#valueList(arguments.thestruct.export_template.exp_value)#" index="idx" delimiters="," >
					<cfif id_r EQ arguments.thestruct.file_id AND isDefined('arguments.thestruct.qry_xmp.#idx#')>
						<cfset QuerySetCell(arguments.thestruct.tq, "#idx#", evaluate("arguments.thestruct.qry_xmp.#idx#"))>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
		<cfif structKeyExists(arguments.thestruct,'qry_pdfxmp')>
			<cfloop query="arguments.thestruct.qry_pdfxmp">
				<!--- Loop to set images metadata values to selected metadata into export file--->
				<cfloop list="#valueList(arguments.thestruct.export_template.exp_value)#" index="idx" delimiters="," >
					<cfif id_r EQ arguments.thestruct.file_id AND isDefined('arguments.thestruct.qry_pdfxmp.#idx#')>
						<cfset QuerySetCell(arguments.thestruct.tq, "#idx#", evaluate("arguments.thestruct.qry_pdfxmp.#idx#"))>
					</cfif>
				</cfloop>
			</cfloop>
		</cfif>
	<cfelse>
	<cfif structkeyexists(arguments.thestruct,"qry_xmp") AND arguments.thestruct.qry_xmp.recordcount NEQ 0 AND arguments.thestruct.filetype EQ "img">
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcsubjectcode", arguments.thestruct.qry_xmp.iptcsubjectcode)>
		<cfset QuerySetCell(arguments.thestruct.tq, "creator", arguments.thestruct.qry_xmp.creator)>
		<cfset QuerySetCell(arguments.thestruct.tq, "title", arguments.thestruct.qry_xmp.title)>
		<cfset QuerySetCell(arguments.thestruct.tq, "authorstitle", arguments.thestruct.qry_xmp.authorstitle)>
		<cfset QuerySetCell(arguments.thestruct.tq, "descwriter", arguments.thestruct.qry_xmp.descwriter)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcaddress", arguments.thestruct.qry_xmp.iptcaddress)>
		<cfset QuerySetCell(arguments.thestruct.tq, "category", arguments.thestruct.qry_xmp.category)>
		<cfset QuerySetCell(arguments.thestruct.tq, "categorysub", arguments.thestruct.qry_xmp.categorysub)>
		<cfset QuerySetCell(arguments.thestruct.tq, "urgency", arguments.thestruct.qry_xmp.urgency)>
		<!--- <cfset QuerySetCell(arguments.thestruct.tq, "description", arguments.thestruct.qry_xmp.description)> --->
		<cfset QuerySetCell(arguments.thestruct.tq, "iptccity", arguments.thestruct.qry_xmp.iptccity)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptccountry", arguments.thestruct.qry_xmp.iptccountry)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptclocation", arguments.thestruct.qry_xmp.iptclocation)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptczip", arguments.thestruct.qry_xmp.iptczip)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcemail", arguments.thestruct.qry_xmp.iptcemail)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcwebsite", arguments.thestruct.qry_xmp.iptcwebsite)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcphone", arguments.thestruct.qry_xmp.iptcphone)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcintelgenre", arguments.thestruct.qry_xmp.iptcintelgenre)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcinstructions", arguments.thestruct.qry_xmp.iptcinstructions)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcsource", arguments.thestruct.qry_xmp.iptcsource)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcusageterms", arguments.thestruct.qry_xmp.iptcusageterms)>
		<cfset QuerySetCell(arguments.thestruct.tq, "copystatus", arguments.thestruct.qry_xmp.copystatus)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcjobidentifier", arguments.thestruct.qry_xmp.iptcjobidentifier)>
		<cfset QuerySetCell(arguments.thestruct.tq, "copyurl", arguments.thestruct.qry_xmp.copyurl)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcheadline", arguments.thestruct.qry_xmp.iptcheadline)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcdatecreated", arguments.thestruct.qry_xmp.iptcdatecreated)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcimagecity", arguments.thestruct.qry_xmp.iptcimagecity)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcimagestate", arguments.thestruct.qry_xmp.iptcimagestate)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcimagecountry", arguments.thestruct.qry_xmp.iptcimagecountry)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcimagecountrycode", arguments.thestruct.qry_xmp.iptcimagecountrycode)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcscene", arguments.thestruct.qry_xmp.iptcscene)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptcstate", arguments.thestruct.qry_xmp.iptcstate)>
		<cfset QuerySetCell(arguments.thestruct.tq, "iptccredit", arguments.thestruct.qry_xmp.iptccredit)>
		<cfset QuerySetCell(arguments.thestruct.tq, "copynotice", arguments.thestruct.qry_xmp.copynotice)>
	<!--- For PDF XMP --->
	<cfelseif structkeyexists(arguments.thestruct,"qry_pdfxmp") AND arguments.thestruct.qry_pdfxmp.recordcount NEQ 0 AND arguments.thestruct.filetype EQ "doc">
		<cfset QuerySetCell(arguments.thestruct.tq, "pdf_author", arguments.thestruct.qry_pdfxmp.author)>
		<cfset QuerySetCell(arguments.thestruct.tq, "pdf_rights", arguments.thestruct.qry_pdfxmp.rights)>
		<cfset QuerySetCell(arguments.thestruct.tq, "pdf_authorsposition", arguments.thestruct.qry_pdfxmp.authorsposition)>
		<cfset QuerySetCell(arguments.thestruct.tq, "pdf_captionwriter", arguments.thestruct.qry_pdfxmp.captionwriter)>
		<cfset QuerySetCell(arguments.thestruct.tq, "pdf_webstatement", arguments.thestruct.qry_pdfxmp.webstatement)>
		<cfset QuerySetCell(arguments.thestruct.tq, "pdf_rightsmarked", arguments.thestruct.qry_pdfxmp.rightsmarked)>
		</cfif>
	</cfif>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Metadata: Add --->
<cffunction name="setmetadata" access="Public" output="false">
	<cfargument name="fileid" required="true">
	<cfargument name="type" required="true">
	<cfargument name="metadata" required="true">
	<!--- Set db and id --->
	<cfif arguments.type EQ "img">
		<cfset var thedb = "images_text">
		<cfset var theid = "img_id">
		<cfset var thedbid = "img_id">
		<cfset var theidr = "img_id_r">
		<cfset var lucenecategory = "img">
		<cfset var cachetype = "images">
		<cfset var thedesc = "img_description">
		<cfset var thekeys = "img_keywords">
	<cfelseif arguments.type EQ "vid">
		<cfset var thedb = "videos_text">
		<cfset var theid = "vid_id">
		<cfset var thedbid = "vid_id">
		<cfset var theidr = "vid_id_r">
		<cfset var lucenecategory = "vid">
		<cfset var cachetype = "videos">
		<cfset var thedesc = "vid_description">
		<cfset var thekeys = "vid_keywords">
	<cfelseif arguments.type EQ "aud">
		<cfset var thedb = "audios_text">
		<cfset var theid = "aud_id">
		<cfset var thedbid = "aud_id">
		<cfset var theidr = "aud_id_r">
		<cfset var lucenecategory = "aud">
		<cfset var cachetype = "audios">
		<cfset var thedesc = "aud_description">
		<cfset var thekeys = "aud_keywords">
	<cfelse>
		<cfset var thedb = "files_desc">
		<cfset var theid = "file_id">
		<cfset var thedbid = "file_id">
		<cfset var theidr = "file_id_r">
		<cfset var lucenecategory = "doc">
		<cfset var cachetype = "files">
		<cfset var thedesc = "file_desc">
		<cfset var thekeys = "file_keywords">
	</cfif>
	<!--- Loop over the assetid --->
	<cfloop list="#arguments.fileid#" index="i" delimiters=",">
		<!--- check if record is here --->
		<cfquery datasource="#application.razuna.datasource#" name="textishere">
		SELECT #theidr# as recid
		FROM #session.hostdbprefix##thedb#
		WHERE #theidr# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#i#">
		</cfquery>
		<!--- NOT found --->
		<cfif textishere.recordcount EQ 0>
			<!--- the id --->
			<cfset theid = i>
			<!--- Create record --->
			<cfquery datasource="#application.razuna.datasource#">
			INSERT INTO #session.hostdbprefix##thedb#
			(id_inc, host_id, lang_id_r, #theidr#)
			VALUES (
				<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createuuid("")#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
				<cfqueryparam cfsqltype="cf_sql_numeric" value="1">,
				<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
			)
			</cfquery>
		<cfelse>
			<cfset theid = i>
		</cfif>
		<!--- Add keywords and description to the asset --->
		<cfloop list="#arguments.metadata#" delimiters=";" index="i">
			<!--- Get the list items --->
			<cfset f = listFirst(i,":")>
			<cfset v = listLast(i,":")>
			<cfif f EQ "keywords" OR f EQ "description">
				<cfif f EQ "keywords">
					<cfset tf = thekeys>
				<cfelseif f EQ "description">
					<cfset tf = thedesc>
				</cfif>
				<cftry>
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix##thedb#
					SET #tf# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#v#">
					WHERE #theidr# = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
					</cfquery>
					<cfcatch type="database">
						<cfset cfcatch.custom_message = "Database error while adding keywords and description to asset in function xmp.setmetadata">
						<cfif not isdefined("errobj")><cfobject component="global.cfc.errors" name="errobj"></cfif><cfset errobj.logerrors(cfcatch)/>
					</cfcatch>
				</cftry>
			</cfif>
		</cfloop>
		<!--- If we are a image then also loop over the XMP fields --->
		<cfif arguments.type EQ "img">
			<!--- Check if there is a record for this asset --->
			<cfquery datasource="#application.razuna.datasource#" name="ishere">
			SELECT id_r
			FROM #session.hostdbprefix#xmp
			WHERE asset_type = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">
			AND id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
			</cfquery>
			<!--- If record is not here then do insert --->
			<cfif ishere.recordcount EQ 0>	
				<cfquery datasource="#application.razuna.datasource#">
				INSERT INTO #session.hostdbprefix#xmp
				(id_r, asset_type, host_id)
				VALUES(
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
					<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="img">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				)
				</cfquery>
			</cfif>
			<!--- Update records --->
			<cfloop list="#arguments.metadata#" delimiters=";" index="i">
				<!--- Get the list items --->
				<cfset f = listFirst(i,":")>
				<cfset v = listLast(i,":")>
				<cfif f NEQ "keywords">
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#xmp
					SET #f# = <cfqueryparam cfsqltype="CF_SQL_VARCHAR" value="#v#">
					WHERE id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
					</cfquery>
				</cfif>
			</cfloop>
		</cfif>
		<!--- Set for indexing --->
		<cfquery datasource="#application.razuna.datasource#">
		UPDATE #session.hostdbprefix##cachetype#
		SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
		WHERE #thedbid# = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
		AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
		</cfquery>
	</cfloop>
	<!--- Flush cache --->
	<cfset resetcachetoken(cachetype)>
	<cfset resetcachetoken("search")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Metadata: Add --->
<cffunction name="setmetadatacustom" access="Public" output="false">
	<cfargument name="fileid" required="true">
	<cfargument name="type" required="true">
	<cfargument name="metadata" required="true">
	<!--- Param --->
	<cfset var qry_custom = "">
	<!--- Loop over the assetid --->
	<cfloop list="#arguments.fileid#" index="i" delimiters=",">
		<!--- Set i into var --->
		<cfset theid = i>
		<!--- Loop over metadata --->
		<cfloop list="#arguments.metadata#" delimiters=";" index="i">
			<!--- Get the list items --->
			<cfset f = listFirst(i,":")>
			<cfset v = listLast(i,":")>
			<!--- Insert or update --->
			<cftransaction>
				<cfquery datasource="#application.razuna.datasource#" name="qry_custom">
				SELECT rec_uuid 
				FROM #session.hostdbprefix#custom_fields_values
				WHERE cf_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#f#">
				AND asset_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
				<!--- If record is NOT here --->
				<cfif qry_custom.recordcount EQ 0>
					<!--- Insert --->
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#custom_fields_values
					(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
					VALUES(
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#f#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#v#">,
						<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
						<cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#createUUID()#">
					)
					</cfquery>
				<cfelse>
					<cfquery datasource="#application.razuna.datasource#">
					UPDATE #session.hostdbprefix#custom_fields_values
					SET cf_value = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#v#">
					WHERE cf_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#f#">
					AND asset_id_r = <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="#theid#">
					AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
					</cfquery>
				</cfif>
			</cftransaction>
			<!--- Set for indexing --->
			<cfif arguments.type EQ "img">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#images
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE img_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.type EQ "vid">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#videos
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE vid_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.type EQ "aud">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#audios
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE aud_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			<cfelseif arguments.type EQ "doc">
				<!--- Set for indexing --->
				<cfquery datasource="#application.razuna.datasource#">
				UPDATE #session.hostdbprefix#files
				SET	is_indexed = <cfqueryparam cfsqltype="cf_sql_varchar" value="0">
				WHERE file_id = <cfqueryparam value="#theid#" cfsqltype="CF_SQL_VARCHAR">
				AND host_id = <cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">
				</cfquery>
			</cfif>
		</cfloop>
	</cfloop>
	<!--- Flush cache --->
	<cfif arguments.type EQ "img">
		<cfset resetcachetoken("images")>
	<cfelseif arguments.type EQ "vid">
		<cfset resetcachetoken("videos")>
	<cfelseif arguments.type EQ "aud">
		<cfset resetcachetoken("audios")>
	<cfelseif arguments.type EQ "doc">
		<cfset resetcachetoken("files")>
	</cfif>
	<cfset resetcachetoken("general")>
	<cfset resetcachetoken("search")>
	<!--- Return --->
	<cfreturn />
</cffunction>

<!--- Import custom metadata into custom fields --->
<cffunction name="xmpToCustomFields" output="false">
	<cfargument name="thestruct" type="struct">
	<!--- Declare all variables or else you will get errors in the page --->
	<cfset xmp = structnew()>
	<cfset var qry = "">
	<cftry>
		<!--- Go grab the platform --->
		<cfinvoke component="assets" method="iswindows" returnvariable="iswindows">
		<!--- Check the platform and then decide on the Exiftool tag --->
		<cfif isWindows>
			<cfset theexe = """#arguments.thestruct.thetools.exiftool#/exiftool.exe""">
		<cfelse>
			<cfset theexe = "#arguments.thestruct.thetools.exiftool#/exiftool">
		</cfif>
		<cfset theasset = arguments.thestruct.thesource>
		<!--- On Windows a bat --->
		<cfif isWindows>
			<cfexecute name="#theexe#" arguments="-fast -fast2 -X #theasset#" timeout="60" variable="themeta" />
		<cfelse>
			<!--- New parsing code --->
			<cfset var thescript = createuuid()>
			<!--- Set script --->
			<cfset var thesh = gettempdirectory() & "/#thescript#.sh">
			<!--- Write files --->
			<cffile action="write" file="#thesh#" output="#theexe# -fast -fast2 -X #theasset#" mode="777" charset="utf-8">
			<!--- Execute --->
			<cfexecute name="#thesh#" timeout="60" variable="themeta" />
			<!--- Delete scripts --->
			<cffile action="delete" file="#thesh#">
		</cfif>
		<!--- Parse Metadata which is now XML --->
		<cfset var thexml = xmlparse(themeta)>
		<cfset thexml = xmlSearch(thexml, "//rdf:Description/")>
		<!--- Get custom fields --->
		<cfinvoke component="custom_fields" method="get" fieldsenabled="true" xmppath="true" returnvariable="qry_cf" />
		<!--- Loop over custom fields --->
		<cfloop query="qry_cf">
			<!--- Get the custom metadata from XMP --->
			<cftry>
				<cfset xmpvalue = trim(#thexml[1]["#cf_xmp_path#"].xmltext#)>
				<!--- Add value to custom field value --->
				<!--- Insert or update --->
				<cfquery datasource="#application.razuna.datasource#" name="qry">
				SELECT cf_id_r
				FROM #session.hostdbprefix#custom_fields_values
				WHERE cf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cf_id#">
				AND asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.newid#">
				</cfquery>
				<!--- Insert --->
				<cfif qry.recordcount EQ 0>
					<cfquery datasource="#application.razuna.datasource#">
					INSERT INTO #session.hostdbprefix#custom_fields_values
					(cf_id_r, asset_id_r, cf_value, host_id, rec_uuid)
					VALUES(
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#cf_id#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.newid#">,
					<cfqueryparam cfsqltype="cf_sql_varchar" value="#xmpvalue#">,
					<cfqueryparam cfsqltype="cf_sql_numeric" value="#session.hostid#">,
					<cfqueryparam CFSQLType="cf_sql_varchar" value="#createuuid()#">
					)
					</cfquery>
				<!--- Update --->
				<cfelse>
					<cfquery datasource="#application.razuna.datasource#">
						UPDATE #session.hostdbprefix#custom_fields_values
						SET cf_value = <cfqueryparam cfsqltype="cf_sql_varchar" value="#xmpvalue#">
						WHERE cf_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#cf_if#">
						AND asset_id_r = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.thestruct.newid#">
					</cfquery>
				</cfif>
				<cfcatch type="any"></cfcatch>
			</cftry>
		</cfloop>
		<!--- Flush Cache --->
		<cfset resetcachetoken("search")>
		<cfset resetcachetoken("general")>
		<!--- On error --->
		<cfcatch type="any">
			<!--- <cfset consoleoutput(true)>
			<cfset console('Error on import of custom metadata')>
			<cfset console(cfcatch)> --->
		</cfcatch>
	</cftry>
	
	<!--- Return --->
	<cfreturn />
</cffunction>

</cfcomponent>
