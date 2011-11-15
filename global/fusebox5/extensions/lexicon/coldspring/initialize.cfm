<cfscript>
	// @ Author Qasim Rasheed (qasimrasheed@gmail.com) 
	// Original idea taken by ColdSpring lexicon by Nathan Strutz.
	// Initializes ColdSpring into the current application scope (respecting the fusebox application key). This tag accepts one of more bean tag as children
	// usage:
	// 1. add the lexicon declaration to your circuit file:
	//    <circuit xmlns:cs="coldspring/">
	// 2. use the verb in a fuseaction:
	//    <cs:initialize  coldspringfactory="servicefactory" defaultproperties="default coldspring properties">
	//			<cs:bean beanDefinitionFile="..." />
	//			more bean tags......
	//    </cs:initialize>
	//
	if (fb_.verbInfo.executionMode is "start") {
		// coldspringfactory is optional:
		fb_.coldspringfactory = 'servicefactory';
        if (structKeyExists(fb_.verbInfo.attributes,"coldspringfactory")) {
            fb_.coldspringfactory = '#fb_.verbInfo.attributes.coldspringfactory#';
        }
        
        // default properties is optional:
        fb_.defaultproperties = '##structnew()##';
        if ( structKeyExists(fb_.verbInfo.attributes,"defaultproperties" ) ) {
            fb_.defaultproperties = fb_.verbInfo.attributes.defaultproperties;
        }
       	
       	// if it has no bean tag as children. 
        if ( not fb_.verbInfo.hasChildren ) {
        	fb_throw("fusebox.badGrammar.childTagMissing",
						"Child bean tag is missing",
						"Child bean tag is missing for verb 'initialize' in fuseaction #fb_.verbInfo.circuit#.#fb_.verbInfo.fuseaction#.");
        }
        
        // this is where the child <bean> verbs will store their data:        
        fb_.verbInfo.beans = arrayNew(1);
        
	} else {
		// set ColdSpring in this fusebox instance's application space
		fb_appendLine('<cfset myFusebox.getApplication().getApplicationData().#fb_.coldspringfactory# = createObject("component", "coldspring.beans.DefaultXmlBeanFactory").init( defaultProperties="#fb_.defaultproperties#" )/>');	
		fb_.i = 1;
		// load all bean definitions
		for ( fb_.i = 1; fb_.i lte arraylen( fb_.verbInfo.beans ); fb_.i = fb_.i + 1){
			fb_appendLine('<cfset myFusebox.getApplication().getApplicationData().#fb_.coldspringfactory#.loadBeansFromXmlFile( beanDefinitionFile="#fb_.verbInfo.beans[fb_.i]#" ) />');
		}		
	}
</cfscript>