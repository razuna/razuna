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
	<select id="preset_#incval.theformat#" onChange="setpreset('#incval.theformat#','#incval.theform#');">
		<option value="">Choose Preset</option>
		<option value="">---</option>
		<option value="">HD Presets</option>
		<option value="hd480">852x480</option>
		<option value="hd720">1280x720</option>
		<option value="hd1080">1920x1080</option>
		<option value="">---</option>
		<option value="sqcif">128x96</option>
		<option value="qqvga">160x120</option>
		<option value="qcif">176x144</option>
		<option value="cga">320x200</option>
		<option value="qvga">320x240</option>
		<option value="cif">352x288</option>
		<option value="ega">640x350</option>
		<option value="vga">640x480</option>
		<option value="4cif">704x576</option>
		<option value="svga">800x600</option>
		<option value="wvga">852x480</option>
		<option value="xga">1024x768</option>
		<option value="sxga">1280x1024</option>
		<option value="wxga">1366x768</option>
		<option value="16cif">1408x1152</option>
		<option value="wsxga">1600x1024</option>
		<option value="uxga">1600x1200</option>
		<option value="wuxga">1920x1200</option>
		<option value="qxga">2048x1536</option>
		<option value="woxga">2560x1600</option>
		<option value="qsxga">2560x2048</option>
		<option value="wqsxga">3200x2048</option>
		<option value="wquxga">3840x2400</option>
		<option value="hsxga">5120x4096</option>
		<option value="whsxga">6400x4096</option>
		<option value="whuxga">7680x4800</option>
	</select>
</cfoutput>
