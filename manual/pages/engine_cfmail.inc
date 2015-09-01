<cfset request.page.section = "engine">
<cfset request.page.title 	= "OpenBD Outgoing Email">
<cfset request.page.desc		= "OpenBD handling of outgoing email">


<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/engine">Server</a></li>
      <li class="active"><a href="./?/engine_cfmail"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">Outgoing Email</h1>

		<cfinclude template="pages/sidebar_server.inc" />
		
		<div class="section">
		
			<p>
			You can generate email from your web application using the popular <a href="./?/tag/CFMAIL">CFMAIL</a> tag.   This tag includes
			some very interesting features that let you get a better handle on the life cycle of your email after your call to <a href="./?/tag/CFMAIL">CFMAIL</a>.
			</p>
			
			<h2>Spool Management</h2>
			
			<p>
			By default, when you call <a href="./?/tag/CFMAIL">CFMAIL</a> email is not sent immediately, but instead queued in the background
			and managed intelligently as it is transfered to an upstream MTA agent (such as sendmail or postfix).  You can control the amount
			of threads for this using the properties in the <a href="./?/engine_bluedragonxml#cfmail">bluedragon.xml</a> file.
			</p>
			
			<p>
			Emails are first saved into the <b>./cfmail/spool/</b> folder.  The call to <a href="./?/tag/CFMAIL">CFMAIL</a> will not return until the
			email has been saved in this folder.   This ensures any server crashes will not lose any email.
			</p>

			<p>
			The mail spooler will look for files in this folder periodically and attempt to deliver them.   If it fails to do this, this mail file be
			moved to the <b>./cfmail/undelivered/</b> folder.   You can look at the <b>./cfmail/mail.log</b> for reasons as to why this occurred.   You can
			have the email be resent (if you have resolved the problem) by simply copying the files from the <b>./cfmail/undelivered/</b> folder back into the
			<b>./cfmail/spool/</b> folder without having to restart the engine.
			</p>
			
			<p>
			You can manage this life cycle from within CFML code by using the callback routines of <a href="./?/tag/CFMAIL">CFMAIL</a> to alert you when
			emails have been successfully passed to the MTA agent or have failed.   You can get the path of the mail spool directory by calling the
			<a href="./?/function/getmailspooldirectory">GetMailSpoolDirectory()</a> function.
			</p>
			
			<h2>Email Development</h2>
			
			<p>
			Due to the rich email capabilities of OpenBD, it is very easy to build an environment that has a lot of outgoing emails.   However, during
			a development or staging phase, you may not wish emails to actually be sent to their original recipients, but instead to one or more test
			email boxes.
			</p>
			
			<p>
			Naturally you could control this using <a href="./?/tag/CFIF">CFIF</a> blocks in your code for when you are in production or development.  This
			can be somewhat troublesome and dangerous as you are relying on the developer to make sure they have caught all instances of outgoing email in
			the code base.
			</p>
			
			<p>
			OpenBD realizes this can be a headache and has a feature to help with this.   You can specify in the <a href="./?/engine_bluedragonxml#cfmail">bluedragon.xml</a>
			a list of email addresses that all <a href="./?/tag/CFMAIL">CFMAIL</a> tag calls will be redirected to.   This is called <b>catchemail</b>.
			</p>
			
			<p>
			You keep your <a href="./?/tag/CFMAIL">CFMAIL</a> code the exact same, but instead of being delivered to the emails specified there, they will
			instead be delivered to the email list specified in the <b>catchemail</b> block in the <a href="./?/engine_bluedragonxml#cfmail">bluedragon.xml</a>
			file.   The original intended recipients will be placed in a series of headers in the email, x-openbd-to/x-openbd-cc/x-openbd-bcc, so you can see who
			would have gotton the email if the catchemail feature was not intended.
			</p>
			
			<p>
			The logfile will still show the original recipients but will have an additional prefix to let you know that they didn't really get delivered there.
			Any CFC callbacks however, will still be for the original email addresses.   This way you can keep your business logic as close to production as possible
			without any nasty hacks.
			</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->