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
<cfcomponent>

<cffunction name="Init" access="public" output="false" returntype="rssparser">
	<cfreturn THIS />
</cffunction>

	
<cffunction name="rssParse" returnType="array" output="true" hint="Attempts to parse the RSS feed for the items.">
	<cfargument name="thefeed" type="string" required="true" hint="the feed url">
	<cfargument name="themany" type="numeric" default="0" required="no" hint="how many records do we want to show">
	<cfset var xmlData = "">
	<cfset var result = arrayNew(1)>
	<cfset var x = "">
	<cfset var items = "">
	<cfset var xPath = "">
	<cfset var node = "">
	
		<cfcachecontent action="cache" cachename="razunacache" cachedwithin="#CreateTimeSpan(0,1,0,0)#">
			<cfhttp url="#arguments.thefeed#" method="get" throwonerror="no" timeout="6">
		</cfcachecontent>
		
			<cfset xmlData = xmlParse(arguments.thefeed)>
			
			<cfif xmlData.xmlRoot.xmlName is "rss">
				<cfset xPath = "//item">
			<cfelse>
				<cfset xPath = "//:item">
			</cfif>
					
			<cfset items = xmlSearch(xmlData,xPath)>
		
			<!--- If the many is set then use it else use how many records the feed is returning --->
			
			<cfif #arguments.themany# EQ 0>
				<cfset howmany = #arrayLen(items)#>
			<cfelseif #arguments.themany# GT #arrayLen(items)#>
				<cfset howmany = #arrayLen(items)#>
			<cfelse>
				<cfset howmany = #arguments.themany#>
			</cfif>
		
			
			<cfloop index="x" from="1" to="#howmany#">
				<cfset node = structNew()>
				<cfset node.maintitle = xmlData.xmlRoot.Channel.title.xmlText>
				<cfset node.mainlink = xmlData.xmlRoot.Channel.link.xmlText>
				<cfset node.title = items[x].title.xmlText>
				<cfset node.link = items[x].link.xmlText>
				<cfset node.desc = items[x].description.xmlText>
				<cfset result[arrayLen(result)+1] = duplicate(node)>
			</cfloop>
		
	<cfreturn result>
		
</cffunction>
	
	
</cfcomponent>