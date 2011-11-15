<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    David C. Epler - dcepler@dcepler.net
    Matt Woodward - matt@mattwoodward.com

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
<cfcomponent displayname="ScheduledTasks" 
	     output="false" 
	     extends="Base" 
	     hint="Manages scheduled tasks - OpenBD Admin API">

  <cffunction name="getScheduledTasks" access="public" output="false" returntype="array" 
	      hint="Returns an array of scheduled tasks, or a specific scheduled task based on the task name passed in">
    <cfargument name="task" type="string" required="false" hint="The name of the scheduled task to retrieve" />
    
    <cfset var localConfig = getConfig() />
    <cfset var tasks = [] />
    <cfset var returnArray = [] />
    <cfset var i = 0 />
    <cfset var sortKeys = [] />
    <cfset var sortKey = {} />

    <cfset checkLoginStatus() />
    
    <cfif !StructKeyExists(localConfig, "cfschedule") || !StructKeyExists(localConfig.cfschedule, "task")>
      <cfthrow message="No scheduled tasks configured" type="bluedragon.adminapi.scheduledtasks" />
      <cfelse>
	<cfif StructKeyExists(arguments, "task")>
	  <cfset tasks = localConfig.cfschedule.task />
	  
	  <cfloop index="i" from="1" to="#ArrayLen(tasks)#">
	    <cfif CompareNoCase(tasks[i].name, arguments.task) == 0>
	      <cfset returnArray[1] = tasks[i] />
	      <cfreturn returnArray />
	    </cfif>
	  </cfloop>
	  <cfelse>
	    <!--- set the sorting information --->
	    <cfset sortKey.keyName = "name" />
	    <cfset sortKey.sortOrder = "ascending" />
	    <cfset ArrayAppend(sortKeys, sortKey) />
	    
	    <cfreturn variables.udfs.sortArrayOfObjects(localConfig.cfschedule.task, sortKeys, false, false) />
	</cfif>
    </cfif>
  </cffunction>
  
  <cffunction name="setScheduledTask" access="public" output="false" returntype="void" 
	      hint="Creates or updates a scheduled task">
    <cfargument name="task" type="string" required="true" hint="The scheduled task name" />
    <cfargument name="url" type="string" required="true" hint="The URL the scheduled task will call" />
    <cfargument name="startdate" type="string" required="true" hint="The start date for the scheduled task (mm/dd/yyyy format)" />
    <cfargument name="starttime" type="string" required="true" hint="The start time for the scheduled task (24 hour format)" />
    <cfargument name="interval" type="string" required="true" 
		hint="The interval at which to run the scheduled task (number of seconds, once, daily, weekly, or monthly)" />
    <cfargument name="port" type="numeric" required="false" default="-1" hint="The port to use for the scheduled task URL" />
    <cfargument name="enddate" type="string" required="false" default="" hint="The end date for the scheduled task (mm/dd/yyyy format)" />
    <cfargument name="endtime" type="string" required="false" default="" hint="The end time for the scheduled task (24 hour format)" />
    <cfargument name="username" type="string" required="false" default="" hint="User name required by the URL being called by the scheduled task" />
    <cfargument name="password" type="string" required="false" default="" hint="Password required by the URL being called by the scheduled task" />
    <cfargument name="proxyserver" type="string" required="false" default="" hint="Proxy server to use for the scheduled task" />
    <cfargument name="proxyport" type="string" required="false" default="80" hint="Proxy server port to use for the scheduled task" />
    <cfargument name="publish" type="boolean" required="false" default="false" 
		hint="Boolean indicating whether or not to publish the results of the scheduled task to a file" />
    <cfargument name="path" type="string" required="false" default="" hint="The path to which to publish the results of the scheduled task" />
    <cfargument name="uridirectory" type="boolean" required="false" default="false" 
		hint="Boolean indicating whether or not the path to which the file will be published is relative (true) or absolute (false)" />
    <cfargument name="file" type="string" required="false" default="" hint="The file name to which to publish the results of the scheduled task" />
    <cfargument name="resolveurl" type="boolean" required="false" default="false" 
		hint="Boolean indicating whether or not to resolve internal URLs to full URLs" />
    <cfargument name="requesttimeout" type="numeric" required="false" default="30" hint="The request timeout for the scheduled task" />
    <cfargument name="action" type="string" required="false" default="create" hint="The action to take on the scheduled task (create or update)" />

    <cfset checkLoginStatus() />
    
    <cfif arguments.action == "create" && scheduledTaskExists(arguments.task)>
      <cfthrow type="bluedragon.adminapi.scheduledtasks" message="A scheduled task with that name already exists" />
    </cfif>
    
    <!--- Set some defaults to minimize the different versions of the cfschedule tag we'll have to use in here. 
	This will be much easier with attributecollection. From what I can tell, manipulating the XML file via setConfig() 
	does not register the scheduled task with the scheduler, because the XML looked fine but the scheduler didn't 
	pick up the scheduled task until after a restart. --->
    <cfif arguments.enddate == "" && arguments.endtime == "">
      <cfschedule action="update" 
		  task="#arguments.task#"
		  operation="HTTPRequest" 
		  url="#arguments.url#" 
		  port="#arguments.port#" 
		  startdate="#arguments.startdate#" 
		  starttime="#arguments.starttime#" 
		  interval="#arguments.interval#" 
		  username="#arguments.username#" 
		  password="#arguments.password#" 
		  proxyserver="#arguments.proxyserver#" 
		  proxyport="#arguments.proxyport#" 
		  publish="#arguments.publish#" 
		  path="#arguments.path#" 
		  uridirectory="#arguments.uridirectory#" 
		  file="#arguments.file#" 
		  resolveurl="#arguments.resolveurl#" 
		  requesttimeout="#arguments.requesttimeout#" />
      <cfelseif arguments.enddate != "" && arguments.endtime == "">
	<cfschedule action="update" 
		    task="#arguments.task#"
		    operation="HTTPRequest" 
		    url="#arguments.url#" 
		    port="#arguments.port#" 
		    startdate="#arguments.startdate#" 
		    starttime="#arguments.starttime#" 
		    enddate="#arguments.enddate#" 
		    interval="#arguments.interval#" 
		    username="#arguments.username#" 
		    password="#arguments.password#" 
		    proxyserver="#arguments.proxyserver#" 
		    proxyport="#arguments.proxyport#" 
		    publish="#arguments.publish#" 
		    path="#arguments.path#" 
		    uridirectory="#arguments.uridirectory#" 
		    file="#arguments.file#" 
		    resolveurl="#arguments.resolveurl#" 
		    requesttimeout="#arguments.requesttimeout#" />
	<cfelseif arguments.enddate == "" && arguments.endtime != "">
	  <cfschedule action="update" 
		      task="#arguments.task#"
		      operation="HTTPRequest" 
		      url="#arguments.url#" 
		      port="#arguments.port#" 
		      startdate="#arguments.startdate#" 
		      starttime="#arguments.starttime#" 
		      endtime="#arguments.endtime#" 
		      interval="#arguments.interval#" 
		      username="#arguments.username#" 
		      password="#arguments.password#" 
		      proxyserver="#arguments.proxyserver#" 
		      proxyport="#arguments.proxyport#" 
		      publish="#arguments.publish#" 
		      path="#arguments.path#" 
		      uridirectory="#arguments.uridirectory#" 
		      file="#arguments.file#" 
		      resolveurl="#arguments.resolveurl#" 
		      requesttimeout="#arguments.requesttimeout#" />
	  <cfelseif arguments.enddate != "" && arguments.endtime != "">
	    <cfschedule action="update" 
			task="#arguments.task#"
			operation="HTTPRequest" 
			url="#arguments.url#" 
			port="#arguments.port#" 
			startdate="#arguments.startdate#" 
			starttime="#arguments.starttime#" 
			enddate="#arguments.enddate#" 
			endtime="#arguments.endtime#" 
			interval="#arguments.interval#" 
			username="#arguments.username#" 
			password="#arguments.password#" 
			proxyserver="#arguments.proxyserver#" 
			proxyport="#arguments.proxyport#" 
			publish="#arguments.publish#" 
			path="#arguments.path#" 
			uridirectory="#arguments.uridirectory#" 
			file="#arguments.file#" 
			resolveurl="#arguments.resolveurl#" 
			requesttimeout="#arguments.requesttimeout#" />
    </cfif>
  </cffunction>
  
  <cffunction name="scheduledTaskExists" access="public" output="false" returntype="boolean" 
	      hint="Returns a boolean indicating whether or not a scheduled task with the name passed in exists">
    <cfargument name="task" type="string" required="true" hint="The name of the scheduled task to run" />
    
    <cfset var localConfig = getConfig() />
    <cfset var exists = false />
    <cfset var tasks = [] />
    <cfset var i = 0 />

    <cfset checkLoginStatus() />
    
    <cfif StructKeyExists(localConfig, "cfschedule") && StructKeyExists(localConfig.cfschedule, "task")>
      <cfset tasks = localConfig.cfschedule.task />
      
      <cfloop index="i" from="1" to="#ArrayLen(tasks)#">
	<cfif CompareNoCase(tasks[i].name, arguments.task) == 0>
	  <cfset exists = true />
	  <cfbreak />
	</cfif>
      </cfloop>
    </cfif>
    
    <cfreturn exists />
  </cffunction>
  
  <cffunction name="runScheduledTask" access="public" output="false" returntype="void" 
	      hint="Runs a scheduled task">
    <cfargument name="task" type="string" required="true" hint="The name of the scheduled task to run" />

    <cfset checkLoginStatus() />
    
    <cfschedule action="run" task="#arguments.task#" />
  </cffunction>
  
  <cffunction name="deleteScheduledTask" access="public" output="false" returntype="void" 
	      hint="Deletes a scheduled task">
    <cfargument name="task" type="string" required="true" hint="The name of the scheduled task to delete" />

    <cfset checkLoginStatus() />
    
    <cfschedule action="delete" task="#arguments.task#" />
  </cffunction>

</cfcomponent>
