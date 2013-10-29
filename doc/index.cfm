<!DOCTYPE html>
	<head>
		<title>CFC Browser</title>
		<meta http-equiv="content-type" content="text/html;charset=utf-8" />
		<style type="text/css">
			#top {
				letter-spacing: 5px;
				border-bottom: 1px solid black;
				padding: 10px;
			}
			#top a{
				font-weight: bold;
			}
			#left {
				float: left;
				padding-right: 40px;
				white-space: nowrap;
			}
			#right {
				float: left;
				width: 700px;
			}
		</style>
	</head>
	<body>
		<!--- Top --->
		<div id="top">
			<a href="index.cfm?action=list&type=cfc">CFC</a> | <a href="index.cfm?action=list&type=api2">API</a>
		</div>
		<div style="clear:both;padding-bottom:20px;"></div>
		<!--- Left --->
		<div id="left">
			<cfif structKeyExists(url,"action")>
				<cfdirectory action="list" directory="#session.path_up#global/#url.type#" name="list_cfc" filter="*.cfc" />
				<!--- Show cfcs --->
				<cfloop query="list_cfc">
					<cfoutput><li><a href="index.cfm?action=detail&type=#url.type#&cfc=#listfirst(name,'.')#">#name#</a></li></cfoutput>
				</cfloop>
			</cfif>
		</div>
		<!--- Right --->
		<div id="right">
			<cfif structKeyExists(url,"action") AND url.action EQ "detail">
				<!--- Set CFC or api --->
				<cfif url.type EQ "cfc">
					<cfset p = session.path_cfc>
				<cfelse>
					<cfset p = session.path_api>
				</cfif>
				<!--- Read metadata --->
				<cfset meta = GetComponentmetadata("#p#.#url.cfc#")>
				<cfoutput>
					<!--- Display name --->
					<h1>#meta.fullname#</h1>
					<p>Extends: #meta.extends.fullname#</p>
					<h2>Functions</h2>
					<!--- Print out function list --->
					<cfloop array="#meta.functions#" index="a">
						<a href="###a.name#">#a.name#</a> | 
					</cfloop>
					<cfloop array="#meta.functions#" index="a">
						<h3><a name="#a.name#">#a.name#</a></h3>
						<table>
							<cfif structKeyExists(a,"hint")>
								<tr>
									<td nowrap="nowrap">Hint:</td>
									<td>#a.hint#</td>
								</tr>
							</cfif>
							<cfif structKeyExists(a,"access")>
								<tr>
									<td nowrap="nowrap">Access:</td>
									<td>#a.access#</td>
								</tr>
							</cfif>
							<cfif structKeyExists(a,"returntype")>
								<tr>
									<td nowrap="nowrap">Returntype:</td>
									<td>#a.returntype#</td>
								</tr>
							</cfif>
							<tr>
								<td nowrap="nowrap" valign="top">Parameters:</td>
								<td>
									<cfloop array="#a.parameters#" index="p">
										<cfdump var="#p#" label="#p.name#">
									</cfloop>
								</td>
							</tr>
						</table>
					</cfloop>
				</cfoutput>
			</cfif>
		</div>
	</body>

</html>