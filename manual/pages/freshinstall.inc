<cfset request.page.title = "Installation Success">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li class="active"><a href="./?/plugin_cfsmtp"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

<h1>Congratulations &hellip;</h1>

<p>&hellip; since you are reading this, means the installation went well and you are now ready to start using OpenBD CFML.</p>

<p>
	Some information about your current installation:
</p>

<table>
<thead>
	<tr>
		<th>Title</th>
		<th>Details</th>
	</tr>
</thead>
<tbody>
<cfoutput>
<cfloop collection="#server.bluedragon#" item="k">
<tr>
	<td align="right"><strong>#k#:</strong></td>
	<td style="padding-left: 10px;">#server.bluedragon[k]#</td>
</tr>
</cfloop>
<tr>
	<td align="right"><strong>path_translated:</strong></td>
	<td style="padding-left: 10px;">#cgi.PATH_TRANSLATED#</td>
</tr>
<tr>
	<td align="right"><strong>server:</strong></td>
	<td style="padding-left: 10px;">#cgi.SERVER_NAME#:#cgi.server_port#</td>
</tr>
<tr>
	<td align="right"><strong>current time:</strong></td>
	<td style="padding-left: 10px;">#now()#</td>
</tr>
</cfoutput>
</tbody>
</table>

<p><a href="./">Continue to the manual</a></p>

	</div><!--- .container --->
</div><!--- .content --->