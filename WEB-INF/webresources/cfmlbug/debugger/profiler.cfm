<cfset request.simple = false>
<cfset request.page.title = "OpenBD Profiler">
<cfset request.page.heading = "OpenBD Profiler">
<cfinclude template="inc/header.inc">
<cfinclude template="inc/nav.inc">

<div class="group">

<div class="statsrow">
	
		<div class="alert-message success">
		<p><em>Max Mem</em> <span>1,857 MB</span></p>
		</div>
		
		<div class="alert-message success">
		<p><em>Free Mem</em> <span>102 MB</span></p>
		</div>

		<div class="alert-message success">
		<p><em>Used Mem</em> <span>20 MB</span></p>
		</div>

		<div class="alert-message info">
		<p><em>Requests</em> <span>1</span></p>
		</div>

		<div class="alert-message info">
		<p><em>Total Hits</em> <span>41</span></p>
		</div>

		<div class="alert-message warning">
		<p><em>Apps</em> <span>1</span></p>
		</div>

		<div class="alert-message warning">
		<p><em>Sessions</em> <span>0</span></p>
		</div>

		<div class="alert-message error">
		<p><em>File Hits</em> <span>186</span></p>
		</div>

		<div class="alert-message error">
		<p><em>File Misses</em> <span>17</span></p>
		</div>

</div>


<div class="contentrow">
		
		<table class="queries">
		
		<tbody>
		
		<tr>
			<td width="20px" align="center">16</td>
			<td width="20px" align="center"><a href="javascript:ProfilerKill(16);" class="kill" title="kill">kill</a></td>
			<td>/alantest/db.cfm
				<div class="file"><strong>template:</strong> E:/OpenBD/openbd/webapp/alantest/db.cfm</div>
			</td>
			<td width="1%">127.0.0.1</td>
			<td style="text-align: right;" nowrap="nowrap">1,090,758<div class="file"><strong>ms</strong></div></td>
			<td style="text-align: right;">63,822<div class="file"><strong>bytes</strong></div></td>
			<td>
				<div class="sqltime">CFQUERY; ExecTime: 144580 ms</div>
				<div class="sql">select now(), Sleep(20)</div>
		 	</td>
		 	<td width="20px" align="center"><a title="inspect" class="inspect-show" href="#">inspect</a></td>
		</tr>
		
		<tr class="inspect"><td colspan="7">
			<div class="inspectbox">
				<div id="inspectPanelDetail">
					<p>	<nocfml>
						<cffunction name="getPrevEmployment" returntype="query" output="false">
							<cfargument name="contactid" required="true" default="" />
							
							<cfset var qry = true />
							<cfquery name="qry" datasource="#application.datasource#">
							 SELECT ACCOUNT.NAME AS ACCOUNT_NAME, ACCOUNT.ID AS ACCOUNT_ID, ACCOUNT__C, CONTACT__C, END_DATE__C, P.NAME, P.ID, START_DATE__C, TITLE__C 
							 FROM PREVIOUS_EMPLOYMENT__C P
							 JOIN ACCOUNT ON P.ACCOUNT__C = ACCOUNT.ID
							 WHERE CONTACT__C = '#arguments.contactid#'
							</cfquery>
	
						<cfreturn qry>
						</cffunction>
					</nocfml></p>
				</div>
			</div>
		</td>
		<td width="20px" align="center"></td></tr>
		
		
		<tr>
			<td width="20px" align="center">16</td>
			<td width="20px" align="center"><a href="javascript:ProfilerKill(16);" class="kill" title="kill">kill</a></td>
			<td>/alantest/db.cfm
				<div class="file"><strong>template:</strong> E:/OpenBD/openbd/webapp/alantest/db.cfm</div>
			</td>
			<td width="1%">127.0.0.1</td>
			<td style="text-align: right;" nowrap="nowrap">1,090,758<div class="file"><strong>ms</strong></div></td>
			<td style="text-align: right;">63,822<div class="file"><strong>bytes</strong></div></td>
			<td style="">
				<div class="sqltime">CFQUERY; ExecTime: 144580 ms</div>
				<div class="sql">select now(),Sleep(20)</div>
		 	</td>
		 	<td width="20px" align="center"><a title="inspect" class="inspect-show" href="#">inspect</a></td>
		</tr>
		
		<tr class="inspect"><td colspan="7">
			<div class="inspectbox">
				<div id="inspectPanelDetail">
					<p>	<nocfml>
						<cffunction name="getPrevEmployment" returntype="query" output="false">
							<cfargument name="contactid" required="true" default="" />
							
							<cfset var qry = true />
							<cfquery name="qry" datasource="#application.datasource#">
							 SELECT ACCOUNT.NAME AS ACCOUNT_NAME, ACCOUNT.ID AS ACCOUNT_ID, ACCOUNT__C, CONTACT__C, END_DATE__C, P.NAME, P.ID, START_DATE__C, TITLE__C 
							 FROM PREVIOUS_EMPLOYMENT__C P
							 JOIN ACCOUNT ON P.ACCOUNT__C = ACCOUNT.ID
							 WHERE CONTACT__C = '#arguments.contactid#'
							</cfquery>
	
						<cfreturn qry>
						</cffunction>
					</nocfml></p>
				</div>
			</div>
		</td>
		<td width="20px" align="center"></td></tr>
		
		
		<tr>
			<td width="20px" align="center">16</td>
			<td width="20px" align="center"><a href="javascript:ProfilerKill(16);" class="kill" title="kill">kill</a></td>
			<td>/alantest/db.cfm
				<div class="file"><strong>template:</strong> E:/OpenBD/openbd/webapp/alantest/db.cfm</div>
			</td>
			<td width="1%">127.0.0.1</td>
			<td style="text-align: right;" nowrap="nowrap">1,090,758<div class="file"><strong>ms</strong></div></td>
			<td style="text-align: right;">63,822<div class="file"><strong>bytes</strong></div></td>
			<td style="">
				<div class="sqltime">CFQUERY; ExecTime: 144580 ms</div>
				<div class="sql">select now(),Sleep(20)</div>
			</td>
			<td width="20px" align="center"><a title="inspect" class="inspect-show" href="#">inspect</a></td>
		</tr>
		
		<tr class="inspect"><td colspan="7">
			<div class="inspectbox">
				<div id="inspectPanelDetail">
					<p>	<nocfml>
						<cffunction name="getPrevEmployment" returntype="query" output="false">
							<cfargument name="contactid" required="true" default="" />
							
							<cfset var qry = true />
							<cfquery name="qry" datasource="#application.datasource#">
							 SELECT ACCOUNT.NAME AS ACCOUNT_NAME, ACCOUNT.ID AS ACCOUNT_ID, ACCOUNT__C, CONTACT__C, END_DATE__C, P.NAME, P.ID, START_DATE__C, TITLE__C 
							 FROM PREVIOUS_EMPLOYMENT__C P
							 JOIN ACCOUNT ON P.ACCOUNT__C = ACCOUNT.ID
							 WHERE CONTACT__C = '#arguments.contactid#'
							</cfquery>
	
						<cfreturn qry>
						</cffunction>
					</nocfml></p>
				</div>
			</div>
		</td>
		<td width="20px" align="center"></td></tr>
		
		
		<tr>
			<td width="20px" align="center">16</td>
			<td width="20px" align="center"><a href="javascript:ProfilerKill(16);" class="kill" title="kill">kill</a></td>
			<td>/alantest/db.cfm
				<div class="file"><strong>template:</strong> E:/OpenBD/openbd/webapp/alantest/db.cfm</div>
			</td>
			<td width="1%">127.0.0.1</td>
			<td style="text-align: right;" nowrap="nowrap">1,090,758<div class="file"><strong>ms</strong></div></td>
			<td style="text-align: right;">63,822<div class="file"><strong>bytes</strong></div></td>
			<td>
				<div class="sqltime">CFQUERY; ExecTime: 144580 ms</div>
				<div class="sql">select now(), Sleep(20)</div>
		 	</td>
		 	<td width="20px" align="center"><a title="inspect" class="inspect-show" href="#">inspect</a></td>
		</tr>
		
		<tr class="inspect"><td colspan="7">
			<div class="inspectbox">
				<div id="inspectPanelDetail">
					<p>	<nocfml>
						<cffunction name="getPrevEmployment" returntype="query" output="false">
							<cfargument name="contactid" required="true" default="" />
							
							<cfset var qry = true />
							<cfquery name="qry" datasource="#application.datasource#">
							 SELECT ACCOUNT.NAME AS ACCOUNT_NAME, ACCOUNT.ID AS ACCOUNT_ID, ACCOUNT__C, CONTACT__C, END_DATE__C, P.NAME, P.ID, START_DATE__C, TITLE__C 
							 FROM PREVIOUS_EMPLOYMENT__C P
							 JOIN ACCOUNT ON P.ACCOUNT__C = ACCOUNT.ID
							 WHERE CONTACT__C = '#arguments.contactid#'
							</cfquery>
	
						<cfreturn qry>
						</cffunction>
					</nocfml></p>
				</div>
			</div>
			<div class="screenshot">
				<p><img src="img/debug-screen.jpg"/></p>
			</div>
		</td>
		<td width="20px" align="center"><a class="show-window" title="show in window" href="#">inspect</a></td>
		</tr>
		
		</tbody>
		</table>

	
</div><!--- .contentrow --->

</div><!--- .group --->

<cfinclude template="inc/footer.inc">