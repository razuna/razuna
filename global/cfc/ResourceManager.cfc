<!---
/**
 *
 * Copyright (c) 2010 David Beale
 *		
 **/
--->
<cfcomponent name="ResourceManager"
	hint="Provides support for Adobe Flex style Resource Bundles"
>
	<!--- INIT --->

	<cffunction name="init"
		hint="Constructor" 
		access="public" 
		returntype="ResourceManager" 
		output="false" 
	>
		<cfargument name="resourcePackagePath" hint="Flex style Resource Package folder path" type="string" required="true" /> 
		<cfargument name="baseLocale" hint="Base locale to fall back on if there are no matches for a particular key and locale" type="string" required="false" default="en_US" /> 
		<cfargument name="propertiesEncoding" hint="File Encoding of Resource Bundle properties files" type="string" required="false" default="UTF-8" /> 

		<cfset variables.resourcePackagePath = expandPath(arguments.resourcePackagePath) />
		<cfset variables.baseLocale = arguments.baseLocale />
		<cfset variables.propertiesEncoding = arguments.propertiesEncoding />

		<cfreturn this />
	</cffunction>


	<!--- PUBLIC --->

	<cffunction name="getString"
		hint="Get String from Resource Bundle" 
		access="public" 
		returntype="string" 
		output="false" 
	>
		<cfargument name="resourceBundleName" hint="Resource Bundle Name" type="string" required="true" /> 
		<cfargument name="key" hint="Resource Key" type="string" required="true" />
		<cfargument name="values" hint="Array of values to substitute for $1, $2 etc in the resource string" type="array" required="false" default="#arrayNew(1)#" />
		<cfargument name="locale" hint="Resource Locale" type="string" required="false" default="#this.getLocaleCode()#" />

		<!--- LOCALS --->
		<cfset var resource = '' />
		<cfset var resourceBundle = structNew() />
		<cfset var currentLocale = '' />
		<cfset var count = 0 />
		<cfset var result = '' />
		<cfset var valueCount = 0 />
		
		<cfset currentLocale = arguments.locale />
		
		<!--- Loop through locale fall back values --->
		<cfloop index="count" from="1" to="5">
		
			<cfset resourceBundle = variables.getResourceBundle(arguments.resourceBundleName, currentLocale) />
			<cfset currentLocal = resourceBundle.locale />
			
			<cfif structKeyExists( resourceBundle, arguments.key ) >
			
				<cfif arrayLen(arguments.values) eq 0 >			
					<cfreturn resourceBundle[arguments.key] />
				<cfelse>
					<cfset result = resourceBundle[arguments.key] />
					
					<!--- Do Substitutions --->
					<cfloop index="valueCount" from="1" to="#arrayLen(arguments.values)#">
						<cfset result = replaceNoCase(result, '$'&valueCount, arguments.values[valueCount], 'all') />
					</cfloop>
					
					<cfreturn result />
				</cfif>
			
			<cfelse>

				<!--- Fall back --->
				<cfset currentLocale = variables.getLocaleFallBack(currentLocale) />
				
				<cfif currentLocale eq ''>
					<cfthrow type="com.bealearts.util.Internationalisation.RESOURCE_NOT_FOUND" message="Resource not found" detail="Resource key '#arguments.key#' in Resource Bundle '#arguments.resourceBundleName#' in locale or fall back locale not found for '#currentLocale#'" />
				</cfif>
			
			</cfif>
			
		</cfloop>	
		

		<cfthrow type="com.bealearts.util.Internationalisation.RESOURCE_NOT_FOUND" message="Resource not found" detail="Resource key '#arguments.key#' in Resource Bundle '#arguments.resourceBundleName#' in locale or fall back locale not found for '#currentLocale#'" />	

	</cffunction>
	


	<cffunction name="getLocaleCode"
		hint="Get current request's Locale code" 
		access="public" 
		returntype="string" 
		output="false" 
	> 
		<cfif getPageContext().getResponse().getLocale().getCountry() eq '' >
			<cfreturn getPageContext().getResponse().getLocale().getLanguage() />
		<cfelse>	
			<cfreturn getPageContext().getResponse().getLocale().getLanguage() & '_' & getPageContext().getResponse().getLocale().getCountry() />		
		</cfif>
	</cffunction>
	
	
	
	<cffunction name="setLocaleCode"
		hint="Set current request's Locale code" 
		access="public" 
		returntype="string" 
		output="false" 
	> 
		<cfargument name="locale" hint="Locale Code" type="string" required="true" />
		
		<cfset setLocale( arguments.locale ) />
		
	</cffunction>	



	<cffunction name="getLocaleChain"
		hint="Get array of locale codes with a resource package available" 
		access="public" 
		returntype="array" 
		output="false" 
	> 
		<!--- LOCALS --->
		<cfset var locales = arrayNew(1) />
		<cfset var packages = queryNew('') />
		
		<cfdirectory action="list" name="packages" directory="#variables.resourcePackagePath#" type="dir" listInfo="name" />
		
		<cfloop query="packages">
			<cfif left(packages.name, 1) neq '.' >
				<cfset arrayAppend(locales, packages.name) />
			</cfif>
		</cfloop>
		
		<cfreturn locales />		
	</cffunction>
	
	
	<cffunction name="getLocaleDirection"
		hint="Get language direction (rtl|rtl) for the locale code" 
		access="public" 
		returntype="string" 
		output="false" 
	> 
		<cfargument name="locale" hint="Resource Locale" type="string" required="false" default="#this.getLocaleCode()#" />

		<cfif createObject('java', 'java.awt.ComponentOrientation').getOrientation( createObject('java', 'java.util.Locale').init(arguments.locale) ).isLeftToRight() >
			<cfreturn 'ltr' />
		<cfelse>
			<cfreturn 'rtl' />	
		</cfif>
		
	</cffunction>		
	
	
	<!--- PRIVATE --->
	
	<cfset variables.resourcePackagePath = '' />
	<cfset variables.resourcePackage = structNew() />
	<cfset variables.baseLocale = '' />
	<cfset variables.propertiesEncoding = '' />
	
	
	<cffunction name="getResourceBundle"
		hint="Get Resource Bundle from Resource Bundle (with cache)" 
		access="private" 
		returntype="struct" 
		output="false" 
	> 
		<cfargument name="resourceBundleName" hint="Resource Bundle Name" type="string" required="true" />
		<cfargument name="locale" hint="Resource Locale" type="string" required="false" default="#this.getLocaleCode()#" />

		<!--- LOCALS --->
		<cfset var resourceBundle = structNew() />
		<cfset var localePackage = structNew() />
		<cfset var properties = '' />
		<cfset var propertyFile = '' />
		<cfset var propertyName = '' />
		<cfset var currentLocale = '' />
		<cfset var count = 0 />
		
		<cfset currentLocale = arguments.locale />
		
		<!--- Loop through locale fall back values --->
		<cfloop index="count" from="1" to="5">
				
			<!--- Get Locale Package --->
			<cfset localePackage = variables.getLocalePackage( currentLocale ) />
			<cfset currentLocale = localePackage.locale />
			
			<!--- Check for Resource Bundle in cache --->
			<cfif structKeyExists(localePackage, arguments.resourceBundleName) >
			
				<!--- Get Resoure Bundle --->
				<cfreturn localePackage[arguments.resourceBundleName] />
			
			<cfelse>
				
				<!--- Create Resoure Bundle --->
				<cfset localePackage[arguments.resourceBundleName] = structNew() />
				<cfset localePackage[arguments.resourceBundleName].locale = currentLocale />
				<cfset resourceBundle = localePackage[arguments.resourceBundleName] />
	
				<!--- Load Resource Bundle --->
				<cfif fileExists( variables.resourcePackagePath & '/' & currentLocale & '/' & arguments.resourceBundleName & '.properties' ) >
	
					<cfset propertyFile = createObject('java', 'java.util.Properties') />
					<cfset propertyFile.load( createObject('java', 'java.io.InputStreamReader').init( createObject('java', 'java.io.FileInputStream').init( variables.resourcePackagePath & '/' & currentLocale & '/' & arguments.resourceBundleName & '.properties' ), variables.propertiesEncoding) ) />
					
					<!--- Load Properties --->
					<cfset properties = propertyFile.propertyNames() />
					<cfloop condition="#properties.hasMoreElements()#">
						<cfset propertyName = properties.nextElement() />
						<cfset resourceBundle[propertyName] = propertyFile.getProperty( propertyName ) />
					</cfloop>
	
					<cfreturn resourceBundle />
									
				<cfelse>

					<!--- Fall back --->
					<cfset currentLocale = variables.getLocaleFallBack(currentLocale) />
					
					<cfif currentLocale eq ''>
						<cfthrow type="com.bealearts.util.Internationalisation.RESOURCE_BUNDLE_NOT_FOUND" message="Resource Bundle not found" detail="Resource Bundle '#arguments.resourceBundleName#' in locale or fall back locale not found for '#currentLocale#'" />
					</cfif>
				
				</cfif>
				
			</cfif>

		</cfloop>

		
		<cfthrow type="com.bealearts.util.Internationalisation.RESOURCE_BUNDLE_NOT_FOUND" message="Resource Bundle not found" detail="Resource Bundle '#arguments.resourceBundleName#' in locale or fall back locale not found for '#currentLocale#'" />

	</cffunction>
	
	
	
	<cffunction name="getLocalePackage"
		hint="Get Locale Package from Resource Bundle (with cache)" 
		access="private" 
		returntype="struct" 
		output="false" 
	> 
		<cfargument name="locale" hint="Resource Locale" type="string" required="false" default="#this.getLocaleCode()#" />

		<!--- LOCALS --->
		<cfset var currentLocale = '' />
		<cfset var count = 0 />
		
		<cfset currentLocale = arguments.locale />
		
		<!--- Loop through locale fall back values --->
		<cfloop index="count" from="1" to="5">
		
			<!--- Check for locale in cache --->
			<cfif structKeyExists(variables.resourcePackage, currentLocale) >
			
				<!--- Return Locale --->
				<cfreturn variables.resourcePackage[currentLocale] />
			
			<cfelse>
			
				<!--- Check for locale on filesystem --->
				<cfif directoryExists( variables.resourcePackagePath & '/' & currentLocale & '/' ) >
				
					<!--- Create Locale in cache --->
					<cfset variables.resourcePackage[currentLocale] = structNew() />
					<cfset variables.resourcePackage[currentLocale].locale = currentLocale />
					
					<cfreturn variables.resourcePackage[currentLocale] />
				
				<cfelse>
	
					<!--- Fall back --->
					<cfset currentLocale = variables.getLocaleFallBack(currentLocale) />
					
					<cfif currentLocale eq ''>
						<cfthrow type="com.bealearts.util.Internationalisation.LOCALE_NOT_FOUND" message="Locale not found" detail="No locale or fall back locale not found for '#arguments.locale#'" />
					</cfif>
								
				</cfif>
				
			</cfif>
			
		</cfloop>	

	
		<cfthrow type="com.bealearts.util.Internationalisation.LOCALE_NOT_FOUND" message="Locale not found" detail="No locale or fall back locale not found for '#arguments.locale#'" />
		
	</cffunction>	
	


	<cffunction name="getLocaleFallBack"
		hint="Get fall back Locale code" 
		access="private" 
		returntype="string" 
		output="false" 
	> 
		<cfargument name="locale" hint="Locale" type="string" required="false" default="#this.getLocaleCode()#" />
	
		<cfif not findNoCase('_', arguments.locale) >
			<!--- Country --->
			<cfreturn getToken(arguments.locale, 1, '_') />
		<cfelseif arguments.locale eq 'en'>
			<!--- No Match --->
			<cfreturn '' />
		<cfelse>
			<!--- Default --->
			<cfreturn variables.baseLocale />
		</cfif>
	
	</cffunction>
	
</cfcomponent>