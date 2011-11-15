<cfset thecfapp = hash(right(REReplace(getDirectoryFromPath(getCurrentTemplatePath()),'[^A-Za-z]','','all'),64))>
<cfapplication
	name="#thecfapp#"
	sessionmanagement="Yes"
	sessiontimeout="#CreateTimeSpan(0,3,0,0)#"
	setClientCookies="yes"
>
<!--- Initiate --->
<cfobject component="global.cfc.settings" name="settingsobj">
<!--- Set Config --->
<cfset settingsobj.getconfigdefault()>