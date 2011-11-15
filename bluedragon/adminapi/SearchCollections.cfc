<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    David C. Epler - dcepler@dcepler.net
    Matt Woodward - matt@mattwoodward.com
    Nitai - nitai@razuna.com

    This file is part of the Open BlueDragon Admin API.

    The Open BlueDragon Admin API is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Admin API is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Admin API.  If not, see 
    <http://www.gnu.org/licenses/>.
    --->
<cfcomponent 
   displayname="SearchCollections" 
   output="false" 
   extends="Base" 
   hint="Manages search collections - OpenBD Admin API">
  
  <cffunction name="getSearchCollections" access="public" output="false" returntype="query" 
	      hint="Returns a query containing defined search collections">

    <cfset checkLoginStatus() />
    
    <cfset var collections = CollectionList() />
    
    <cfif collections.RecordCount == 0>
      <cfthrow message="No search collections defined" type="bluedragon.adminapi.searchcollections" />
      <cfelse>
	<cfreturn collections />
    </cfif>
  </cffunction>
  
  <cffunction name="getSearchCollection" access="public" output="false" returntype="struct" 
	      hint="Returns a struct containing details about a search collection">
    <cfargument name="name" type="string" required="true" hint="The name of the search collection to retrieve" />
    
    <cfset var localConfig = getConfig() />
    <cfset var searchCollections = [] />
    <cfset var searchCollection = {} />
    <cfset var i = 0 />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig, "cfcollection") || !StructKeyExists(localConfig.cfcollection, "collection")>
      <cfthrow message="No search collections defined" type="bluedragon.adminapi.searchcollections" />
      <cfelse>
	<cfset searchCollections = localConfig.cfcollection.collection />
	
	<cfloop index="i" from="1" to="#ArrayLen(searchCollections)#">
	  <cfif CompareNoCase(searchCollections[i].name, arguments.name) == 0>
	    <cfset searchCollection.name = searchCollections[i].name />
	    <cfset searchCollection.path = searchCollections[i].path />
	    <cfset searchCollection.storebody = searchCollections[i].storebody />
	    <cfset searchCollection.language = searchCollections[i].language />
	    
	    <cfreturn StructCopy(searchCollection) />
	  </cfif>
	</cfloop>
    </cfif>
    
    <!--- if we get here we didn't find it --->
    <cfthrow message="A search collection with that name does not exist" type="bluedragon.adminapi.searchcollections" />
  </cffunction>
  
  <cffunction name="createSearchCollection" access="public" output="true" returntype="void" 
	      hint="Creates a search collection">
    <cfargument name="name" type="string" required="true" hint="The name of the search collection" />
    <cfargument name="path" type="string" required="true" hint="The path where the search collection will be stored" />
    <cfargument name="language" type="string" required="true" hint="The language of the search collection" />
    <cfargument name="storebody" type="boolean" required="true" 
		hint="Boolean indicating whether or not to store the document body in the search collection" />
    <cfargument name="relative" type="boolean" required="true" 
		hint="Boolean indicating whether or not the path is relative or not" />
    
    <cfset checkLoginStatus() />
    
    <cfif arguments.path == "">
      <cfset CollectionCreate(collection=arguments.name, language=arguments.language, storebody=arguments.storebody) />
      <cfelse>
    	<cfset CollectionCreate(collection=arguments.name, language=arguments.language, storebody=arguments.storebody, path=arguments.path, relative=arguments.relative) />
    </cfif>
  </cffunction>

  <cffunction name="deleteSearchCollection" access="public" output="false" returntype="void" 
	      hint="Deletes a search collection by name">
    <cfargument name="name" type="string" required="true" hint="The name of the collection to delete" />

    <cfset checkLoginStatus() />

    <cfcollection action="delete" collection="#arguments.name#" />
  </cffunction>
  
  <cffunction name="indexSearchCollection" access="public" output="false" returntype="struct" 
	      hint="Indexes a search collection and returns the status struct from the cfindex call">
    <cfargument name="collection" type="string" required="true" hint="The name of the collection on which to perform the index" />
    <cfargument name="action" type="string" required="true" hint="The indexing action to be performed" />
    <cfargument name="type" type="string" required="true" hint="The type of index" />
    <cfargument name="key" type="string" required="true" hint="The path and filename for index type 'file'; the path for index type 'path'" />
    <cfargument name="language" type="string" required="true" hint="The language of the collection" />
    <cfargument name="urlpath" type="string" required="false" default="" hint="The URL prepended to search result documents" />
    <cfargument name="extensions" type="string" required="false" default="*" hint="Comma-delimited list of file extensions to index" />
    <cfargument name="recurse" type="boolean" required="false" default="false" hint="Boolean indicating whether or not to recurse subdirectories under the path being indexed" />
    
    <cfset var status = {} />
    
    <cfset checkLoginStatus() />
    
    <cfif CompareNoCase(arguments.type, "path") == 0 || CompareNoCase(arguments.type, "file") == 0>
      <cfindex collection="#arguments.collection#" action="#arguments.action#" 
	       type="#arguments.type#" key="#arguments.key#"  
	       urlpath="#arguments.urlpath#" extensions="#arguments.extensions#" 
	       language="#arguments.language#" recurse="#arguments.recurse#" 
	       status="status" />
      <cfelseif CompareNoCase(arguments.type, "website") == 0>
	<cfindex collection="#arguments.collection#" action="#arguments.action#" 
		 type="#arguments.type#" key="#arguments.key#" 
		 language="#arguments.language#" status="status" />
    </cfif>
    
    <cfreturn status />
  </cffunction>
  
  <cffunction name="getSupportedLanguages" access="public" output="false" returntype="array" 
	      hint="Returns an array containing the supported languages for collections">
    <cfset checkLoginStatus() />
    
    <cfreturn CreateObject("java", "com.bluedragon.search.AnalyzerFactory").getSupportedLanguages() />
  </cffunction>

  <cffunction name="getIndexableFileExtensions" access="public" output="false" returntype="array" 
	      hint="Returns the file extensions from each of the available document handlers">
    <cfscript>
      checkLoginStatus();
      
      var allExts = CreateObject("java", "java.util.TreeSet").init();
      var fileExtensions = [];
      var textExts = CreateObject("java", "com.bluedragon.search.index.crawl.handler.FileHandlerTextImpl").init(JavaCast("boolean", "false")).getExtensions().iterator();
      var mp3Exts = CreateObject("java", "com.bluedragon.search.index.crawl.handler.FileHandlerMP3Impl").init(JavaCast("boolean", "false")).getExtensions().iterator();
      var jpgExts = CreateObject("java", "com.bluedragon.search.index.crawl.handler.FileHandlerJPGImpl").init(JavaCast("boolean", "false")).getExtensions().iterator();
      var wordExts = CreateObject("java", "com.bluedragon.search.index.crawl.handler.FileHandlerWordImpl").init(JavaCast("boolean", "false")).getExtensions().iterator();
      var htmlExts = CreateObject("java", "com.bluedragon.search.index.crawl.handler.FileHandlerHTMLImpl").init(JavaCast("boolean", "false")).getExtensions().iterator();
      var pdfExts = CreateObject("java", "com.bluedragon.search.index.crawl.handler.FileHandlerPDFImpl").init(JavaCast("boolean", "false")).getExtensions().iterator();

      while(textExts.hasNext()) {
        allExts.add(textExts.next());
      }

      while(mp3Exts.hasNext()) {
        allExts.add(mp3Exts.next());
      }

      while(jpgExts.hasNext()) {
        allExts.add(jpgExts.next());
      }

      while(wordExts.hasNext()) {
        allExts.add(wordExts.next());
      }

      while(htmlExts.hasNext()) {
        allExts.add(htmlExts.next());
      }

      while(pdfExts.hasNext()) {
        allExts.add(pdfExts.next());
      }

      var allExtsIterator = allExts.iterator();

      while(allExtsIterator.hasNext()) {
        ArrayAppend(fileExtensions, allExtsIterator.next());
      }

      return fileExtensions;
    </cfscript>
  </cffunction>
  
</cfcomponent>
