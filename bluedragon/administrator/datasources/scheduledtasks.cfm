<!---
    Copyright (C) 2008 - Open BlueDragon Project - http://www.openbluedragon.org
    
    Contributing Developers:
    Matt Woodward - matt@mattwoodward.com

    This file is part of the Open BlueDragon Administrator.

    The Open BlueDragon Administrator is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Open BlueDragon Administrator is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
    
    You should have received a copy of the GNU General Public License 
    along with the Open BlueDragon Administrator.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfsilent>
  <cfparam name="scheduledTaskMessage" type="string" default="" />
  <cfparam name="scheduledTasks" type="array" default="#arrayNew(1)#" />
  <cfparam name="scheduledTaskAction" type="string" default="create" />
  <cfparam name="scheduledTaskActionLabel" type="string" default="Create a" />
  
  <cftry>
    <cfset scheduledTasks = Application.scheduledTasks.getScheduledTasks() />
    <cfcatch type="bluedragon.adminapi.scheduledtasks">
      <cfset scheduledTaskMessage = CFCATCH.Message />
      <cfset scheduledTaskMessageType = "error" />
    </cfcatch>
  </cftry>
  
  <cfif StructKeyExists(session, "scheduledTask")>
    <cfset scheduledTask = session.scheduledTask[1] />
    
    <cfif !StructKeyExists(scheduledTask, "tasktype")>
      <cfset scheduledTask.tasktype = "" />
    </cfif>
    
    <cfset scheduledTaskAction = "update" />
    <cfset scheduledTaskActionLabel = "Edit">
    <cfelse>
      <cfset scheduledTask = {name:'', urltouse:'', porttouse:'', tasktype:'',
	                        startdate:'', starttime:'', enddate:'', endtime:'', 
	                        interval:-1, username:'', password:'', resolvelinks:false, 
                                requesttimeout:'', publish:false, publishpath:'', publishfile:'', 
	                        proxyserver:'', proxyport:''} />
  </cfif>
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <script type="text/javascript">
      function validate(f) {
        var timeCheck =  /(1|2|3|4|5|6|7|8|9|00|01|02|03|04|05|06|07|08|09|10|11|12|13|14|15|16|17|18|19|20|21|22|23):(0|1|2|3|4|5)\d{1}/;
        var dateCheck =  /^(?=\d)(?:(?:(?:(?:(?:0?[13578]|1[02])(\/|-|\.)31)\1|(?:(?:0?[1,3-9]|1[0-2])(\/|-|\.)(?:29|30)\2))(?:(?:1[6-9]|[2-9]\d)?\d{2})|(?:0?2(\/|-|\.)29\3(?:(?:(?:1[6-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))|(?:(?:0?[1-9])|(?:1[0-2]))(\/|-|\.)(?:0?[1-9]|1\d|2[0-8])\4(?:(?:1[6-9]|[2-9]\d)?\d{2}))($|\ (?=\d)))?(((0?[1-9]|1[012])(:[0-5]\d){0,2}(\ [AP]M))|([01]\d|2[0-3])(:[0-5]\d){1,2})?$/;
        var numericCheck = /^\d{1,}$/;
        var urlCheck = /^(http|https|ftp):\/\//;
        var runIntervalValue = "";
      
        for (var i = 0; i < f.runinterval.length; i++) {
          if (f.runinterval[i].checked) {
            runIntervalValue = f.runinterval[i].value;
          }
        }
			  
        if (f.name.value.length == 0) {
          alert("Please enter the task name");
	  return false;
	} else if (f.urltouse.value.length == 0 || !urlCheck.test(f.urltouse.value) || 
	           (urlCheck.test(f.urltouse.value) && f.urltouse.value.length <= 7)) {
          alert("Please enter a valid URL");
          return false;
        } else if (f.porttouse.value.length > 0 && !numericCheck(f.porttouse.value)) {
          alert("Please enter a valid numeric value for the port");
          return false;
        } else if (f.startdate.value.length > 0 && !dateCheck.test(f.startdate.value)) {
	  alert("Please enter a valid start date");
	  return false;
	} else if (f.enddate.value.length > 0 && !dateCheck(f.enddate.value)) {
	  alert("Please enter a valid end date");
	  return false;
	} else if (runIntervalValue == "once" && (f.starttime_once.value.length == 0 || 
	  !timeCheck.test(f.starttime_once.value))) {
	  alert("Please enter a valid start time for the one-time task");
	  return false;
	} else if (runIntervalValue == "recurring" && f.tasktype.value == "") {
	  alert("Please select the interval for the recurring task");
	  return false;
	} else if (runIntervalValue == "recurring" && (f.starttime_recurring.value.length == 0 || 
	  !timeCheck.test(f.starttime_recurring.value))) {
	  alert("Please enter a valid start time for the recurring task");
	  return false;
	} else if (runIntervalValue == "daily" && (f.interval.value.length == 0 || !numericCheck(f.interval.value) || 
	  f.interval.value > 86400)) {
	  alert("Please enter a valid number of seconds for the daily task.\nThis number may not exceed 86400.");
	  return false;
	} else if (f.starttime_daily.value.length > 0 && !timeCheck.test(f.starttime_daily.value)) {
	  alert("Please enter a valid start time for the daily task");
	  return false;
	} else if (f.endtime_daily.value.length > 0 && !timeCheck.test(f.endtime_daily.value)) {
	  alert("Please enter a valid end time for the daily task");
	  return false;
	} else if (f.publish[0].checked && (f.publishpath.value.length == 0 || f.publishfile.value.length == 0)) {
	  alert("Please enter a path and file name to which to publish the file");
	  return false;
	} else if (f.requesttimeout.value.length > 0 && !numericCheck.test(f.requesttimeout.value)) {
	  alert("Please enter a numeric value for request timeout");
	  return false;
	}
	
	return true;
      }
	
      function deleteScheduledTask(task) {
        if(confirm("Are you sure you want to delete this scheduled task?")) {
          location.replace("_controller.cfm?action=deleteScheduledTask&name=" + task);
        }
      }
    </script>
    
    <h2>Scheduled Tasks</h2>

    <cfif StructKeyExists(session, "message") && session.message.text != "">
      <div class="alert-message #session.message.type# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#session.message.text#</p>
      </div>
    </cfif>

    <cfif scheduledTaskMessage != "">
      <div class="alert-message #scheduledTaskMessageType# fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<p>#scheduledTaskMessage#</p>
      </div>
    </cfif>

    <cfif StructKeyExists(session, "errorFields") && IsArray(session.errorFields) && ArrayLen(session.errorFields) gt 0>
      <div class="alert-message block-message error fade in" data-alert="alert">
	<a class="close" href="##">x</a>
	<h5>The following errors occurred:</h5>
	<ul>
	  <cfloop index="i" from="1" to="#ArrayLen(session.errorFields)#">
	    <li>#session.errorFields[i][2]#</li>
	  </cfloop>
	</ul>
      </div>
    </cfif>
        
    <cfif ArrayLen(scheduledTasks) gt 0>
      <table>
	<tr bgcolor="##f0f0f0">
	  <th style="width:100px;">Actions</th>
	  <th>Task</th>
	  <th>URL</th>
	  <th>Interval</th>
	  <th>Start Date/Time</th>
	  <th>End Date/Time</th>
	</tr>
	<cfloop index="i" from="1" to="#ArrayLen(scheduledTasks)#">
	  <tr>
	    <td>
	      <a href="_controller.cfm?action=runScheduledTask&name=#scheduledTasks[i].name#" alt="Run Task" title="Run Task"><img src="../images/control_play_blue.png" border="0" width="16" height="16" /></a>
	      <!--- TODO: enable this once 'pause' is added as an action for scheduled tasks in the engine 
		  <a href="_controller.cfm?action=pauseScheduledTask&name=#scheduledTasks[i].name#" alt="Pause Task" 
		     title="Pause Task">
		    <img src="../images/control_pause_blue.png" border="0" width="16" height="16" />
		  </a> --->
	      <a href="_controller.cfm?action=editScheduledTask&name=#URLEncodedFormat(scheduledTasks[i].name)#" alt="Edit Task" title="Edit Task"><img src="../images/pencil.png" border="0" width="16" height="16" /></a>
	      <a href="javascript:void(0);" onclick="javascript:deleteScheduledTask('#JSStringFormat(scheduledTasks[i].name)#');" alt="Delete Task" title="Delete Task"><img src="../images/cancel.png" border="0" width="16" height="16" /></a>
	    </td>
	    <td>#scheduledTasks[i].name#</td>
	    <td>#scheduledTasks[i].urltouse#</td>
	    <td>
	      <cfif StructKeyExists(scheduledTasks[i], "tasktype") && scheduledTasks[i].tasktype != "">
		#LCase(scheduledTasks[i].tasktype)# 
		<cfif scheduledTasks[i].interval != -1>
		  every #scheduledTasks[i].interval# seconds
		  <cfelse>
		    @ #LSTimeFormat(scheduledTasks[i].starttime, "short")#
		</cfif>
		<cfelseif !StructKeyExists(scheduledTasks[i], "tasktype") && 
			  structKeyExists(scheduledTasks[i], "interval") && 
			  scheduledTasks[i].interval != "">
		  Every #scheduledTasks[i].interval# seconds
	      </cfif>
	    </td>
	    <td>#scheduledTasks[i].startdate# #LSTimeFormat(scheduledTasks[i].starttime, "short")#</td>
	    <td>
	      #scheduledTasks[i].enddate#
	      <cfif scheduledTasks[i].endtime != "">&nbsp;#LSTimeFormat(scheduledTasks[i].endtime, "short")#</cfif>
	    </td>
	  </tr>
	</cfloop>
      </table>
    </cfif>
    
    <br />

    <form name="scheduledTaskForm" action="_controller.cfm?action=processScheduledTaskForm" method="post" 
	  onsubmit="javascript:return validate(this);">
      <table>
	<tr bgcolor="##dedede">
	  <th colspan="2"><h5>#scheduledTaskActionLabel# Scheduled Task</h5></th>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Task Name</td>
	  <td>
	    <input type="text" name="name" id="name" class="span8" maxlength="50" value="#scheduledTask.name#" tabindex="1" />
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" valign="top">Duration</td>
	  <td>
	    <div class="inline-inputs">
	      <span>Start Date:</span>&nbsp;
	      <input type="text" name="startdate" id="startdate" class="span2" maxlength="10" 
		     value="#scheduledTask.startdate#" tabindex="2" />&nbsp;
	      <span>End Date:</span>&nbsp;
	      <input type="text" name="enddate" id="enddate" class="span2" maxlength="10" 
		     value="#scheduledTask.enddate#" tabindex="3" />
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" valign="top">Interval</td>
	  <td>
	    <div class="span10">
	      <div class="row">
		<div class="inline-inputs">
		  <input type="radio" name="runinterval" id="runintervalOnce" value="once"
			 <cfif scheduledTask.tasktype == "ONCE"> checked="true"</cfif> tabindex="4" />
		  <span>One Time</span>&nbsp;
		  <span>@</span>&nbsp;
		  <input type="text" name="starttime_once" id="starttime_once" size="5" maxlength="5"
			 <cfif scheduledTask.tasktype == "ONCE" && scheduledTask.starttime != ""> value="#timeFormat(scheduledTask.starttime, 'HH:mm')#"</cfif> 
			 tabindex="5" />
		</div>
	      </div>
	      <div class="row" style="padding-top:2px;">
		<div class="inline-inputs">
		  <input type="radio" name="runinterval" id="runintervalRecurring" value="recurring"
			 <cfif (scheduledTask.tasktype == "DAILY" || scheduledTask.tasktype == "WEEKLY" || scheduledTask.tasktype == "MONTHLY") && scheduledTask.interval == -1> checked="true"</cfif> 
			 tabindex="6" />
		  <span>Recurring</span>&nbsp;
		  <select name="tasktype" id="tasktype" tabindex="7">
		    <option value="" selected="true">- select -</option>
		    <option value="DAILY"<cfif scheduledTask.tasktype == "DAILY" && scheduledTask.interval == -1> selected="true"</cfif>>daily</option>
		    <option value="WEEKLY"<cfif scheduledTask.tasktype == "WEEKLY" && scheduledTask.interval == -1> selected="true"</cfif>>weekly</option>
		    <option value="MONTHLY"<cfif scheduledTask.tasktype == "MONTHLY" && scheduledTask.interval == -1> selected="true"</cfif>>monthly</option>
		  </select>
		  &nbsp;<span>@</span>&nbsp;
		  <input type="text" name="starttime_recurring" id="starttime_recurring" class="span2" maxlength="5"
			 <cfif scheduledTask.interval == -1 && 
			       (scheduledTask.tasktype == "DAILY" || 
			       scheduledTask.tasktype == "WEEKLY" || 
			       scheduledTask.tasktype == "MONTHLY")>value="#timeFormat(scheduledTask.starttime, 'HH:mm')#"</cfif> 
			 tabindex="8" />
		</div>
	      </div>
	      <div class="row" style="padding-top:2px;">
		<div class="inline-inputs">
		  <input type="radio" name="runinterval" id="runintervalDaily" value="daily"
			 <cfif (scheduledTask.tasktype == "" || scheduledTask.tasktype == "DAILY") && 
			       scheduledTask.interval != -1> checked="true"</cfif> tabindex="9" />
		  <span>Daily</span>&nbsp;
		  <span>every</span>&nbsp;
		  <input type="text" name="interval" id="interval" class="span2" maxlength="5"
			 <cfif (scheduledTask.tasktype == "" || scheduledTask.tasktype == "DAILY") && 
			       scheduledTask.interval != -1> value="#scheduledTask.interval#"</cfif> 
			 tabindex="10" />&nbsp;
		  <span>seconds from</span>&nbsp;
		  <input type="text" name="starttime_daily" id="starttime_daily" class="span2" maxlength="5"
			 <cfif (scheduledTask.tasktype == "" || scheduledTask.tasktype == "DAILY") && 
			       scheduledTask.interval != -1> value="#timeFormat(scheduledTask.starttime, 'HH:mm')#"</cfif> 
			 tabindex="11" />&nbsp;
		  <span>to</span>&nbsp;
		  <input type="text" name="endtime_daily" id="endtime_daily" class="span2" maxlength="5"
			 <cfif (scheduledTask.tasktype == "" || scheduledTask.tasktype == "DAILY") && 
			       scheduledTask.interval != -1 && scheduledTask.endtime != ""> value="#timeFormat(scheduledTask.endtime, 'HH:mm')#"</cfif> 
			 tabindex="12" />
		</div>
	      </div>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" valign="top">Full URL</td>
	  <td>
	    <input type="text" name="urltouse" id="urltouse" class="span12"
		   <cfif scheduledTask.urltouse == ""> value="http://"<cfelse> value="#scheduledTask.urltouse#"</cfif> 
		   tabindex="13" /><br />
	    <div class="inline-inputs" style="padding-top:2px;">
	      <span>Port</span>&nbsp;
	      <input type="text" name="porttouse" id="porttouse" class="span2" maxlength="5"
		     <cfif scheduledTask.porttouse == -1 || scheduledTask.porttouse == ""> value=""<cfelse> value="#scheduledTask.porttouse#"</cfif> 
		     tabindex="14" />
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Login Details</td>
	  <td>
	    <div class="inline-inputs">
	      <span>User Name:</span>
	      <input type="text" name="username" id="username" class="span4" value="#scheduledTask.username#" tabindex="15" />&nbsp;
	      <span>Password:</span>
	      <input type="password" name="password" id="password" class="span4" value="#scheduledTask.password#" tabindex="16" />
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" valign="top">Proxy Server</td>
	  <td>
	    <input type="text" name="proxyserver" id="proxyserver" class="span8" value="#scheduledTask.proxyserver#" tabindex="17" /><br />
	    <div class="inline-inputs" style="padding-top:2px;">
	      <span>Port</span>&nbsp;
	      <input type="text" name="proxyport" id="proxyport" class="span2" maxlength="5" value="#scheduledTask.proxyport#" 
		     tabindex="18" />
	    </div>
	    <!---
		TODO: enable this once proxyuser and proxypassword are added to the engine <br />
		User Name: <input type="text" name="proxyuser" size="20" value="#scheduledTask.proxyuser#" />&nbsp;
		Password: <input type="password" name="proxypassword" size="20" value="#scheduledTask.proxypassword#" /> --->
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0" valign="top">Publish Results to File</td>
	  <td>
	    <div class="span10">
	      <div class="row">
		<div class="inline-inputs">
		  <input type="radio" name="publish" id="publishTrue" value="true"
			 <cfif StructKeyExists(scheduledTask, "publish") && IsBoolean(scheduledTask.publish) && scheduledTask.publish> checked="true"</cfif> 
			 tabindex="19" />
		  <span>Yes</span>&nbsp;
		  <input type="radio" name="publish" id="publishFalse" value="false"
			 <cfif (StructKeyExists(scheduledTask, "publish") && (!IsBoolean(scheduledTask.publish) || !scheduledTask.publish)) || !StructKeyExists(scheduledTask, "publish")> checked="true"</cfif> 
			 tabindex="20" />
		  <span>No</span>
		</div>
	      </div>
	      <div class="row" style="padding-top:2px;">
		<div class="inline-inputs">
		  <span>Path:</span>
		  <input type="text" name="publishpath" id="publishpath" class="span8"
			 value="#scheduledTask.publishpath#" tabindex="21" />
		</div>
	      </div>
	      <div class="row" style="padding-top:2px;">
		<div class="inline-inputs">
		  <span>Path Type:</span>
		  <input type="radio" name="uridirectory" id="uridirectoryTrue" value="true" tabindex="22" />
		  <span>Relative</span>&nbsp;
		  <input type="radio" name="uridirectory" id="uridirectoryFalse" value="false" 
			 checked="true" tabindex="23" />
		  <span>Absolute</span>
		</div>
	      </div>
	      <div class="row" style="padding-top:2px;">
		<div class="inline-inputs">
		  <span>File Name:</span>
		  <input type="text" name="publishfile" id="publishfile" class="span8" 
			 value="#scheduledTask.publishfile#" tabindex="24" />
		</div>
	      </div>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Resolve Internal URLs</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="radio" name="resolvelinks" id="resolvelinksTrue" value="true"
		     <cfif scheduledTask.resolvelinks> checked="true"</cfif> tabindex="25" />
	      <span>Yes</span>&nbsp;
	      <input type="radio" name="resolvelinks" id="resolvelinksFalse" value="false"
		     <cfif (IsBoolean(scheduledTask.resolvelinks) && !scheduledTask.resolvelinks) || scheduledTask.resolvelinks == ""> checked="true"</cfif> 
		     tabindex="26" />
	      <span>No</span>
	    </div>
	  </td>
	</tr>
	<tr>
	  <td bgcolor="##f0f0f0">Request Timeout</td>
	  <td>
	    <div class="inline-inputs">
	      <input type="text" name="requesttimeout" id="requesttimeout" class="span2" maxlength="5" 
		     value="#scheduledTask.requesttimeout#" tabindex="27" /> <span>seconds</span>
	    </div>
	  </td>
	</tr>
	<tr bgcolor="##dedede">
	  <td>&nbsp;</td>
	  <td>
	    <input type="submit" class="btn primary" name="submit" value="Submit" tabindex="28" />
	  </td>
	</tr>
      </table>
      <input type="hidden" name="scheduledTaskAction" value="#scheduledTaskAction#" />
      <input type="hidden" name="existingScheduledTaskName" value="#scheduledTask.name#" />
    </form>
  </cfoutput>
  <cfset StructDelete(session, "scheduledTask", false) />
</cfsavecontent>
