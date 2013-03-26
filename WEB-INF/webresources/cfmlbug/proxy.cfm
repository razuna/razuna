<cfsilent>

	<cfset url.cfc = Replace(url.cfc, ".cfc", "", "ALL")>

	<cfinvoke	COMPONENT="debugger.#url.cfc#"
					METHOD="#url.method#"
					ARGUMENTCOLLECTION="#url#"
					RETURNVARIABLE="result"
		>


</cfsilent><cfoutput>#SerializeJSon(result)#</cfoutput>