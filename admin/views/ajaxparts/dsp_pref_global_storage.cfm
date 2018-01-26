<!---
*
* Copyright (C) 2005-2008 Razuna
*
* This file is part of Razuna - Enterprise Digital Asset Management.
*
* Razuna is free software: you can redistribute it and/or modify
* it under the terms of the GNU Affero Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.
*
* Razuna is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU Affero Public License for more details.
*
* You should have received a copy of the GNU Affero Public License
* along with Razuna. If not, see <http://www.gnu.org/licenses/>.
*
* You may restribute this Program with a special exception to the terms
* and conditions of version 3.0 of the AGPL as described in Razuna's
* FLOSS exception. You should have received a copy of the FLOSS exception
* along with Razuna. If not, see <http://www.razuna.com/licenses/>.
*
--->
<cfoutput>
	<table width="700" border="0" cellspacing="0" cellpadding="0" class="grid">
		<tr>
			<td colspan="3">#defaultsObj.trans("global_storage_desc")#</td>
		</tr>
		<tr>
			<td colspan="3"><hr /></td>
		</tr>
		<!--- Local Storage --->
		<tr>
			<th class="textbold" colspan="3">Local Storage</th>
		</tr>
		<tr>
			<td align="center" valign="top"><input type="radio" name="conf_storage" value="local"<cfif gprefs.conf_storage EQ "local"> checked</cfif>></td>
			<td colspan="2">#defaultsObj.trans("global_storage_local_desc")#</td>
		</tr>
		<!--- <tr>
			<td></td>
			<td nowrap="true" valign="top">URL to your asset</td>
			<td><input type="text" name="conf_url_assets" id="conf_url_assets" style="width:300px;" value="#gprefs.conf_url_assets#" /></td>
		</tr>
		<tr>
			<td></td>
			<td></td>
			<td class="sub">This URL is being used in background jobs like sending out emails on asset expiration emails. Define only the first part of the URL, e.g. if your assets are accessible with https://mydomain.com/assets/1/.... then you only need to enter here https://mydomain.com. However, if your assets are accessible with https://mydomain.com/razuna/assets/1/... then enter https://mydomain.com/razuna</td>
		</tr> --->
		<!--- Nirvanix Storage #gprefs.conf_url_assets# --->
		<!--- <tr>
			<th class="textbold" colspan="3">Nirvanix Storage</th>
		</tr>
		<tr>
			<td align="center" valign="top"><input type="radio" name="conf_storage" value="nirvanix"<cfif gprefs.conf_storage EQ "nirvanix"> checked</cfif>></td>
			<td colspan="2">#defaultsObj.trans("global_storage_nirvanix_desc")#</td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Master Account Name</td>
			<td><input type="text" name="conf_nirvanix_master_name" id="conf_nirvanix_master_name" style="width:300px;" value="#gprefs.conf_nirvanix_master_name#" /></td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Master Account Password</td>
			<td><input type="password" name="conf_nirvanix_master_pass" id="conf_nirvanix_master_pass" style="width:300px;" value="#gprefs.conf_nirvanix_master_pass#" /></td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Nirvanix Application Key</td>
			<td><input type="text" name="conf_nirvanix_appkey" id="conf_nirvanix_appkey" style="width:300px;" value="#gprefs.conf_nirvanix_appkey#" /></td>
		</tr>
		<tr>
			<td></td>
			<td></td>
			<td><input type="button" name="validate" value="#defaultsObj.trans("validate")#" class="button" onclick="loadcontent('divvalidate','#myself#c.prefs_nvx_validate_master&nvxname=' + escape($('##conf_nirvanix_master_name').val()) + '&nvxpass=' + escape($('##conf_nirvanix_master_pass').val()) + '&nvxkey=' + escape($('##conf_nirvanix_appkey').val()));" /><div id="divvalidate"></div></td>
		</tr> --->
		<!--- Amazon --->
		<tr>
			<th style="padding-top:25px;" class="textbold" colspan="3">Amazon S3 or Eucalyptus Storage</th>
		</tr>
		<tr>
			<td align="center" valign="top"><input type="radio" name="conf_storage" value="amazon"<cfif gprefs.conf_storage EQ "amazon"> checked</cfif>></td>
			<td colspan="2" style="padding-bottom:25px;">#defaultsObj.trans("global_storage_amazon_desc")#</td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Access Key ID</td>
			<td><input type="text" name="conf_aws_access_key" id="conf_aws_access_key" style="width:300px;" value="#gprefs.conf_aws_access_key#" /></td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Secret Access Key</td>
			<td><input type="text" name="conf_aws_secret_access_key" id="conf_aws_secret_access_key" style="width:300px;" value="#gprefs.conf_aws_secret_access_key#" /></td>
		</tr>
		<tr>
			<td></td>
			<td>Bucket Location</td>
			<td>
				<select name="conf_aws_location" id="conf_aws_location" style="width:310px;">
					<option value="us-east"<cfif application.razuna.awslocation EQ "" OR application.razuna.awslocation EQ "us-east"> selected="selected"</cfif>>US Standard</option>
					<option value="us-east-2"<cfif application.razuna.awslocation EQ "us-east-2"> selected="selected"</cfif>>US East (Ohio)</option>
					<option value="us-west-2"<cfif application.razuna.awslocation EQ "us-west-2"> selected="selected"</cfif>>US West (Oregon)</option>
					<option value="us-west-1"<cfif application.razuna.awslocation EQ "us-west-1"> selected="selected"</cfif>>US West (N. California)</option>
					<option value="ca-central-1"<cfif application.razuna.awslocation EQ "ca-central-1"> selected="selected"</cfif>>Canada (Central)</option>
					<option value="EU"<cfif application.razuna.awslocation EQ "EU"> selected="selected"</cfif>>EU (Ireland)</option>
					<option value="eu-central-1"<cfif application.razuna.awslocation EQ "eu-central-1"> selected="selected"</cfif>>EU (Frankfurt)</option>
					<option value="eu-west-2"<cfif application.razuna.awslocation EQ "eu-west-2"> selected="selected"</cfif>>EU (London)</option>
					<option value="eu-west-3"<cfif application.razuna.awslocation EQ "eu-west-3"> selected="selected"</cfif>>EU (Paris)</option>
					<option value="ap-southeast-1"<cfif application.razuna.awslocation EQ "ap-southeast-1"> selected="selected"</cfif>>Asia Pacific (Singapore)</option>
					<option value="ap-southeast-2"<cfif application.razuna.awslocation EQ "ap-southeast-2"> selected="selected"</cfif>>Asia Pacific (Sidney)</option>
					<option value="ap-northeast-1"<cfif application.razuna.awslocation EQ "ap-northeast-1"> selected="selected"</cfif>>Asia Pacific (Tokyo)</option>
					<option value="ap-northeast-2"<cfif application.razuna.awslocation EQ "ap-northeast-2"> selected="selected"</cfif>>Asia Pacific (Seoul)</option>
					<option value="ap-south-1"<cfif application.razuna.awslocation EQ "ap-south-1"> selected="selected"</cfif>>Asia Pacific (Mumbai)</option>
					<option value="sa-east-1"<cfif application.razuna.awslocation EQ "sa-east-1"> selected="selected"</cfif>>South America (Sao Paulo)</option>
					<option value="cn-north-1"<cfif application.razuna.awslocation EQ "cn-north-1"> selected="selected"</cfif>>China (Beijing)</option>
					<option value="cn-northwest-1"<cfif application.razuna.awslocation EQ "cn-northwest-1"> selected="selected"</cfif>>China (Ningxia)</option>
				</select>
			</td>
		</tr>
		<tr>
			<td></td>
			<td></td>
			<td style="padding-bottom:25px;float:right;"><input type="button" name="validate" value="#defaultsObj.trans("validate")#" class="button" onclick="valaws();" /><div id="divvalidateaws"></div></td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Tenant in one bucket</td>
			<td>
				<input type="radio" name="conf_aws_tenant_in_one_bucket_enable" value="true"<cfif gprefs.conf_aws_tenant_in_one_bucket_enable EQ "true"> checked</cfif>> Yes
				<input type="radio" name="conf_aws_tenant_in_one_bucket_enable" value="false"<cfif gprefs.conf_aws_tenant_in_one_bucket_enable EQ "false"> checked</cfif>> No
			</td>
		</tr>
		<tr>
			<td></td>
			<td colspan="2" class="sub" style="padding-bottom:20px;">By default you have to assign each tenant a S3 bucket. If you select "Yes", then all tenants will be stored in one bucket separated by their ID. Please note: If you enable this on a production system, you will need to move assets MANUALLY in the bucket provided below!</td>
		</tr>
		<tr>
			<td></td>
			<td nowrap="true" valign="top">Bucket for all tenants</td>
			<td><input type="text" name="conf_aws_tenant_in_one_bucket_name" id="conf_aws_tenant_in_one_bucket_name" style="width:300px;" value="#gprefs.conf_aws_tenant_in_one_bucket_name#" /></td>
		</tr>
		<tr>
			<td></td>
			<td></td>
			<td class="sub">Provide the name of the bucket if you choose to store all tenants in one bucket</td>
		</tr>
		<!--- Akamai --->
		<tr>
			<th style="padding-top:25px;" class="textbold" colspan="3">Akamai</th>
		</tr>
		<tr>
			<td align="center" valign="top"><input type="radio" name="conf_storage" value="akamai"<cfif gprefs.conf_storage EQ "akamai"> checked</cfif>></td>
			<td colspan="2">#defaultsObj.trans("global_storage_akamai_desc")#</td>
		</tr>
		<tr>
			<td></td>
			<td>Security Token</td>
			<td><input type="text" name="conf_aka_token" id="conf_aka_token" style="width:300px;" value="#gprefs.conf_aka_token#" /></td>
		</tr>
	</table>
	<div style="text-align:right;padding-top:5px;padding-bottom:10px;float:right;">
		<input type="submit" name="save" value="#defaultsObj.trans("save")#" class="button" /> 
	</div>
	<div style="clear:both;"></div>
	<script type="text/javascript">
		function valaws(){
			// Get values
			var key = $('##conf_aws_access_key').val();
			var keysecret = $('##conf_aws_secret_access_key').val();
			var loc = $('##conf_aws_location :selected').val();
			// Show loading gif
			loadinggif('divvalidateaws');
			// Load
			loadcontent('divvalidateaws','#myself#c.prefs_aws_validate&awskey=' + encodeURIComponent(key) + '&awskeysecret=' + encodeURIComponent(keysecret) + '&awslocation=' + loc);
		}
	</script>
</cfoutput>
