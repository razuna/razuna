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
	<div>
		<p><strong>#qry_plugin.p_name#</strong></p>
		<p>#qry_plugin.p_description#</p>
		<p>#myFusebox.getApplicationData().defaults.trans("plugin_version")#: #qry_plugin.p_version# | <a href="#qry_plugin.p_url#" target="_blank">#qry_plugin.p_url#</a></p>
		<p>#myFusebox.getApplicationData().defaults.trans("plugin_author")#: #qry_plugin.p_author# | <a href="#qry_plugin.p_author_url#" target="_blank">#qry_plugin.p_author_url#</a></p>
		<p>#qry_plugin.p_license#</p>
	</div>
</cfoutput>