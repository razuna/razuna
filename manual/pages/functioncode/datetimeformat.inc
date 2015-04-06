<p>
The following masks are used for this particular function.  Please note, some of these may differ from the standard
OpenBD DateFormat() and TimeFormat() masks.
</p>

<pre class="cfml">
<cfscript>
dt = DateTimeFormat( now(), "yyyy-MM-dd HH:mm:ss" );
</cfscript>
</pre>

<table border="0" cellpadding="0" cellspacing="3">
	<tbody>
		<tr>
			<th align="left">
				Letter
			</th>
			<th align="left">
				Date or Time
			</th>
			<th align="left">
				Examples
			</th>
		</tr>
		<tr>
			<td>
				<code>
					G
				</code>
			</td>
			<td>
				Era designator
			</td>
			<td>
				<code>
					AD
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					y
				</code>
			</td>
			<td>
				Year
			</td>
			<td>
				<code>
					1996
				</code>
				;
				<code>
					96
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					M
				</code>
			</td>
			<td>
				Month in year
			</td>
			<td>
				<code>
					July
				</code>
				;
				<code>
					Jul
				</code>
				;
				<code>
					07
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					w
				</code>
			</td>
			<td>
				Week in year
			</td>
			<td>
				<code>
					27
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					W
				</code>
			</td>
			<td>
				Week in month
			</td>
			<td>
				<code>
					2
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					D
				</code>
			</td>
			<td>
				Day in year
			</td>
			<td>
				<code>
					189
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					d
				</code>
			</td>
			<td>
				Day in month
			</td>
			<td>
				<code>
					10
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					F
				</code>
			</td>
			<td>
				Day of week in month
			</td>
			<td>
				<code>
					2
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					E
				</code>
			</td>
			<td>
				Day in week
			</td>
			<td>
				<code>
					Tuesday
				</code>
				;
				<code>
					Tue
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					a
				</code>
			</td>
			<td>
				Am/pm marker
			</td>
			<td>
				<code>
					PM
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					H
				</code>
			</td>
			<td>
				Hour in day (0-23)
			</td>
			<td>
				<code>
					0
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					k
				</code>
			</td>
			<td>
				Hour in day (1-24)
			</td>
			<td>
				<code>
					24
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					K
				</code>
			</td>
			<td>
				Hour in am/pm (0-11)
			</td>
			<td>
				<code>
					0
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					h
				</code>
			</td>
			<td>
				Hour in am/pm (1-12)
			</td>
			<td>
				<code>
					12
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					m
				</code>
			</td>
			<td>
				Minute in hour
			</td>
			<td>
				<code>
					30
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					s
				</code>
			</td>
			<td>
				Second in minute
			</td>
			<td>
				<code>
					55
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					S
				</code>
			</td>
			<td>
				Millisecond
			</td>
			<td>
				<code>
					978
				</code>
			</td>
		</tr>
		<tr bgcolor="#eeeeff">
			<td>
				<code>
					z
				</code>
			</td>
			<td>
				Time zone
			</td>
			<td>
				<code>
					Pacific Standard Time
				</code>
				;
				<code>
					PST
				</code>
				;
				<code>
					GMT-08:00
				</code>
			</td>
		</tr>
		<tr>
			<td>
				<code>
					Z
				</code>
			</td>
			<td>
				Time zone
			</td>
			<td>
				<code>
					-0800
				</code>
			</td>
		</tr>
	</tbody>
</table>
