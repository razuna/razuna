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
  <cfset errorFieldList = "" />
  
  <cfif StructKeyExists(session, "errorFields")>
    <cfloop array="#session.errorFields#" index="errorField">
      <cfset errorFieldList = ListAppend(errorFieldList, errorField[1], ",") />
    </cfloop>
  </cfif>
  
  <cfsetting showdebugoutput="false" />
</cfsilent>
<cfsavecontent variable="request.content">
  <cfoutput>
    <div class="container" style="padding:40px;margin-top:20px;width:520px;border:4px solid ##dedede;">
      <img src="images/openBD-500.jpg" width="500" height="98" />
      <cfif StructKeyExists(session, "errorFields")>
	<div class="alert-message error">
	  <cfloop array="#session.errorFields#" index="errorField">
	    <p>#errorField[2]#</p>
	  </cfloop>
	</div>
      </cfif>
      <cfif StructKeyExists(session, "message")>
	<div class="alert-message info">
	  <p>#session.message#</p>
	</div>
      </cfif>
      <form name="loginForm" action="_loginController.cfm?action=processLoginForm" method="post">
	<fieldset>
	  <div class="clearfix">
	    <label for="password">Password</label>
	    <div class="input">
	      <input class="span4" id="password" name="password" type="password" />
	    </div>
	  </div>
	  <div class="clearfix">
	    <div class="input">
	      <input type="submit" class="btn primary" value="Login" />
	    </div>
	  </div>
	</fieldset>
      </form>
    </div>

    <script type="text/javascript">
      document.forms.loginForm.password.focus();
    </script>
  </cfoutput>

  <cfset StructDelete(session, "message", false) />
  <cfset StructDelete(session, "errorFields", false) />
</cfsavecontent>
