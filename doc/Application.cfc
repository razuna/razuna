component output="false" {

/* **************************** APPLICATION VARIABLES **************************** */

// The application name
THIS.name = "Doc";

// Life span, as a real number of days, of the application, including all Application scope variables.
THIS.applicationTimeout = createTimeSpan(0, 1, 0, 0);

// Whether the application supports Client scope variables.
THIS.clientManagement = false;

// Where Client variables are stored; can be cookie, registry, or the name of a data source.
THIS.clientStorage = "cookie"; //cookie||registry||datasource

// Name of the data source from which the query retrieves data. 
THIS.datasource = "";

// Whether to store login information in the Cookie scope or the Session scope.
THIS.loginStorage = "cookie"; //cookie||session

// Whether the application supports Session scope variables.
THIS.sessionManagement = true;

// Life span, as a real number of days, of the user session, including all Session variables.
THIS.sessionTimeout = createTimeSpan(0, 0, 30, 0);

// Whether to set CFID and CFTOKEN cookies for a domain (not just a host).
THIS.setDomainCookies = false;

/* **************************** APPLICATION METHODS **************************** */

/**
@hint "Runs when an application times out or the server is shutting down."
@ApplicationScope "The application scope."
*/
public void function onApplicationEnd(struct ApplicationScope=structNew()) {

return;
}


/**
@hint "Runs when ColdFusion receives the first request for a page in the application."
*/
public boolean function onApplicationStart() {

return true;
}


/**
@hint "Intercepts any HTTP or AMF calls to an application based on CFC request."
@cfcname "Fully qualified dotted path to the CFC."

@method "The name of the method invoked."
@args "The arguments (struct) with which the method is invoked."
*/
public void function onCFCRequest(required string cfcname, required string method, required string args) {

return;
}


/**
@hint "Runs when an uncaught exception occurs in the application."
@Exception "The ColdFusion Exception object. For information on the structure of this object, see the description of the cfcatch variable in the cfcatch description."
@EventName "The name of the event handler that generated the exception. If the error occurs during request processing and you do not implement an onRequest method, EventName is the empty string."

note: This method is commented out because it should only be used in special cases
*/
/*
public void function onError(required any Exception, required string EventName) {
return;
}
*/


/**
@hint "Runs when a request specifies a non-existent CFML page."
@TargetPage "The path from the web root to the requested CFML page."
note: This method is commented out because it should only be used in special cases
*/
/*
public boolean function onMissingTemplate(required string TargetPage) {
return true;
}
*/


/**
@hint "Runs when a request starts, after the onRequestStart event handler. If you implement this method, it must explicitly call the requested page to process it."
@TargetPage "Path from the web root to the requested page."
note: This method is commented out because it should only be used in special cases
*/
/*
public void function onRequest(required string TargetPage) {
return;
}
*/


/**
@hint "Runs at the end of a request, after all other CFML code."

*/
public void function onRequestEnd() {
return;

}


/**
@hint "Runs when a request starts."
@TargetPage "Path from the web root to the requested page."
*/
public boolean function onRequestStart(required string TargetPage) {

return true;
}


/**
@hint "Runs when a session ends."
@SessionScope "The Session scope"

@ApplicationScope "The Application scope"
*/
public void function onSessionEnd(required struct SessionScope, struct ApplicationScope=structNew()) {

return;
}


/**
@hint "Runs when a session starts."
*/
public void function onSessionStart() {
	// Get path
	var path_config = "#Expandpath('.')#/config.cfm";
	// Get Profile string
	session.path_cfc = GetProfilestring(path_config,'default','path_cfc');
	session.path_api = GetProfilestring(path_config,'default','path_api');
	// path here
	session.path_here = Expandpath('.');
	session.path_up = Expandpath('../');
	return;
}

}