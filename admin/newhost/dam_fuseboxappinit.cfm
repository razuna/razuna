<cfinvoke component="global.cfc.settings" method="getconfigdefault" />
<cfset application.razuna.trans = createObject('component', 'global.cfc.ResourceManager').init('translations', 'en')>