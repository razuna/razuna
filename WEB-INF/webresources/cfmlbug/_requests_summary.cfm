<cfsilent>
	<!---
	$Id: _requests_summary.cfm 2121 2012-06-22 10:29:03Z alan $

	Loads the summary for the table
		--->

	<cffunction name="getAge" returntype="string">
		<cfargument name="res" required="false" default="s">

		<cfscript>
		var SECS_MS		= 1000;
  	var	MINS_MS		= 60 * SECS_MS;
  	var HOUR_MS		= 60 * MINS_MS;
  	var DAY_MS		= 24 * HOUR_MS;
  	var WEEK_MS 	= 7 * DAY_MS;
  	var MONTH_MS 	= 31 * DAY_MS;
  	var YEAR_MS   = 52 * WEEK_MS;
		var age 			= GetTickCount();

    if ( age < 0 )
    	age = age * -1;

    var	ageString	= "";

    //-- Years
    var years	= int( age / YEAR_MS );
    if ( years > 0 ){
      ageString = ageString & years & " year";
      if ( years >= 1 ){
	      ageString = ageString & "s";
				return ageString & " +";
      }

      ageString = ageString & " ";
      age	= age - ( years * YEAR_MS );
    }

    if ( res.charAt(0) == 'y' )	return ageString.trim();

    //-- Months
    var months	= int( age / MONTH_MS );
    if ( months > 0 ){
      ageString = ageString & months & " month";
      if ( months > 1 ){
	      ageString = ageString & "s";
				if ( months >= 2 )
					return ageString & " +";
      }

      ageString = ageString & " ";
      age	= age - ( months * MONTH_MS );
    }

    if ( res.charAt(0) == 'm' )	return ageString.trim();

    //-- Days
    var days	= int( age / DAY_MS );
    if ( days > 0 ){
      ageString = ageString & days & "day";
      if ( days > 1 ){
				ageString = ageString & "s";
      }
      ageString = ageString & " ";
      age	= age - ( days * DAY_MS );
    }

    if ( res.charAt(0) == 'd' ){
			ageString = ageString.trim();
			if ( ageString == "" ){
				var hours	= int( age / HOUR_MS );
				if ( hours == 0 )
					return "&lt; 1hr";
				else
					return "&lt; " & hours & "hrs";
			}else
				return ageString;
		}

    //-- Hours
    var hours	= int( age / HOUR_MS );
    if ( hours > 0 ){
      ageString = ageString & hours & "hr";
      if ( hours > 1 ){
        ageString = ageString & "s";
      }

      ageString = ageString & " ";
      age	= age - ( hours * HOUR_MS );
    }

    if ( res.charAt(0) == 'h' )	return ageString.trim();

    //-- Minutes
    var mins	= int( age / MINS_MS );
    if ( mins > 0 ){
      ageString = ageString & mins & "m";
      if ( mins > 1 ){
        ageString = ageString & "s";
      }

      ageString = ageString & " ";
      age	= age - ( mins * MINS_MS );
    }

    if ( res.charAt(0) == 'M' )	return ageString.trim();

    //-- Seconds
    var seconds	= Round(age / SECS_MS);
    if ( seconds > 0 ){
      ageString = ageString & seconds & "s";
    }

    return ageString.trim();
    </cfscript>
	</cffunction>


<cfset mem	= SystemMemory()>
<cfset fc = SystemFilecacheinfo()>

</cfsilent><cfoutput>
<div class="statsrow">
	<div class="alert-message success"><p><em>Current Time</em> <span>#TimeFormat( now(), "HH:mm:ss" )#</span></p></div>
	<div class="alert-message success"><p><em>Uptime</em> <span>#getAge("s")#</span></p></div>
</div>

<div class="statsrow">
	<div class="alert-message success"><p><em>Max Memory</em> <span>#NumberFormat( mem.max / 1024000 )# MB</span></p></div>
	<div class="alert-message success"><p><em>Free Memory</em> <span>#NumberFormat( mem.free / 1024000 )# MB</span></p></div>
	<div class="alert-message success"><p><em>Used Memory</em> <span>#NumberFormat( mem.used / 1024000 )# MB</span></p></div>
</div>

<div class="statsrow">
	<div class="alert-message info"><p><em>Current Requests</em> <span>#NumberFormat( DebuggerGetActiveRequestCount() )#</span></p></div>
	<div class="alert-message info"><p><em>Total Requests</em> <span>#NumberFormat( DebuggerGetRequestCount() )#</span></p></div>
</div>

<div class="statsrow">
	<div class="alert-message warning"><p><em>Applications</em> <span>#NumberFormat( Applicationcount() )#</span></p></div>
	<div class="alert-message warning"><p><em>Sessions</em> <span>#NumberFormat( SessionCount() )#</span></p></div>
</div>

<div class="statsrow">
	<div class="alert-message error"><p><em>File Cache Hits</em> <span>#NumberFormat( fc.hits )#</span></p></div>
	<div class="alert-message error"><p><em>File Cache Misses</em> <span>#NumberFormat( fc.misses )#</span></p></div>
</div>
</cfoutput>