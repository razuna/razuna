<cfset request.page.title = "Nullsoft Scriptable Install System and OpenBD Local"><cfset request.page.section = "engine">
<cfset request.page.desc	= "Nullsoft Scriptable Install System (NSIS) and OpenBD.Local">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
      <li><a href="./?/engine">Server</a></li>
      <li class="active"><a href="./?/local_nsis"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1 style="text-transform:none">Nullsoft Scriptable Install System (NSIS)</h1>

		<cfinclude template="pages/sidebar_server.inc" />
		
		<div class="section">

<p>OpenBD.Local Windows Runtime environment allows you to package up webapps as complete
downloadable applications that will have a presence in the main System Tray.</p>

<p>It ships with everything you need, including the Java Runtime. All you need to do
is to supply the OpenBD Web App folder.</p>

<p>OpenBD.Local is Windows Jetty Service container where you can deploy any Java application... and of
course fits right in the hand of OpenBD!</p>

<p>To be able to create simple installation of your OpenBD CFML Applications I have made tests with
Nullsofts Scriptable Install System (NSIS) which also is an Open Source tool.</p>

<p>This document will try to simplify the basic steps to create NSIS Script for your applications.
For this I will use the Oracle Tablespace Report (OTR) as an example on what you need to do and what
to think of to get your Installation Tool up-and-running as fast as possible.</p>

<p>
<ol>
	<li>First of all you need to download OpenBD.Local from <a href="http://openbd.org/local/" onfocus="this.blur();">http://openbd.org/local</a></li>
	<li>Next is to download the openbd.war from <a href="http://openbd.org/downloads/" onfocus="this.blur();">http://openbd.org/downloads/</a></li>
	<li>Finally download the NSIS Tool from <a href="http://nsis.sourceforge.net/Main_Page" onfocus="this.blur();">http://nsis.sourceforge.net/Main_Page</a></li>
</ol>
</p>

<h2>Let's get started</h2>

<p>
Create a folder somewhere. for example C:\Deploy
</p>

<p>
Unzip the openbdlocal.zip in this folder. It will generate a new subfolder with the name openbd-local.
</p>

<p>
This you can now rename into whatever you want. In my case I changed the directory name to OpenBD-OTR
(I want to push OpenBD and the OTR : )
</p>

<p>
This folder will contain the openbd.exe and some more files including the webapp directory. In this webapp
directory simply unpack the openbd.war. You can decide whether or not to keep the bluedragon/administrator.
In my case I need that to setup my Datasources for the OTR. You might use a local Java based DB within your
application and could then maybe skip this.
</p>
<p>
Next you deploy your application in the webapp directory. In the case of OTR I have placed the otr in a
subdirectory under webapp eg. C:\Deploy\OpenBD-OTR\otr.
</p>
<p>
I then edited the index.cfm which comes with the openbd.war to redirect to my otr directory rather than
the OpenBD manual, which is the standard setup.
</p>
<p>
Next you decide what port "your" Jetty should use.  Default OpenBD.Local is configured to use the port 32124.
</p>
<p>
This is located in the openbd-local.ini file. Just change it some port you would like to use. I have chosen
the port 8080.
</p>
<p><strong>NOTE:</strong> Using port 80 on a PC can be problematic depending on other local software.
Typical such software could be Skype. Skype is occupying the port 80 and before you spend a lot of time
trying to figure out why your OpenBD.Local or OpenBD Desktop don't work on your PC, either shut down Skype
or change the port to anything else, just not port 80.
</p>

<h2>Starting OpenBD.Local</h2>
<p>
To get your application to run simply double-click on the openbd.exe and you will get a new icon in your
system tray. With a right-click on this icon you'll get a menu with an Open and a Exit choice. Open will start
your default browser and browse to your web app. If it works, you can exit the OpenBD.Local again.
</p>
<h2>Time for NSIS</h2>
<p>
We're assuming you have the NullSoft Installer downloaded. Just install this into its default location.
On my Laptop it got installed under C:\Program Files (x86)\NSIS
</p>
<p>
If you want to stylish the Installer Header with an OpenBD Logo I have prepared the following .BMP image
that you have to save into the directory<br />
C:\Program Files (x86)\NSIS\Contrib\Graphics\Header<br />
<img src="/manual/pages/openbd_inst_header.bmp" alt="" width="150" height="57" border="0"> Right-Click and select Save As...

</p>
<p>
You should find the NSIS program in your Start Menu. Just start it up.
</p>
<div align="center"><img src="/manual/pages/local-nsis_main.jpg" alt="" width="609" height="364" border="0"></div>
<h3>Let's make an installer.</h3>
<p>
There are 2 ways you can do this. One with very little work on your part, the "Installer based on a ZIP file".
</p>
<h3>Zip2Exe</h3>
<p>
For this you simply zip the content of your openbd-local (or in my case OpenBD-OTR) folder.
</p>
<p>
Here I recommend that you do the zip inside the OpenBD-OTR folder and not one level above. If you do this one
level up it will result in a zip file containing paths like OpenBD-OTR\jre etc. Then in the dialog-box you give
an Installer Name and a Default Folder which most likely will be something similar OpenBD-OTR.

</p>
<div align="center"><img src="/manual/pages/local-zip2exe.jpg" alt="" width="636" height="575" border="0"></div>
<p>
This will then result in a, not wanted, installation path. E.g. C:\Program Files (x86)\OpenBD-OTR\OpenBD-OTR.
</p>
<p>
So to avoid this, simply zip the files in the OpenBD-OTR folder.
</p>
<p>
The other way to create an Installer generates a bit more work for you but you can create much nicer installer
and have more control over what the installer will do. I am not going to go into detail on this, rather giving
you the basic steps to get this up-and-running fast. It will contain splash screen etc.
</p>
<h3>Compile NSI scripts</h3>
<p>
First we need to create a script file with everything needed to install your CFML application.
</p>
<p>

I created a file otr_setup.nsi and placed it on the same level as my OpenBD-OTR directory
</p>
<p>
The hard work is to list All files in your application including the OpenBD and the OpenBD.Local.
</p>
<p>
Therefor I have bundled my otr_setup.nsi within my OTR installer and you can grab this and use it as a base for
your own application. Just drop my otr specific files and replace them with yours. You can also grab this reduced
<a href="/manual/pages/openbd_setup.txt" onfocus="this.blur();">openbd_setup.nsi</a>. In this file I have allready taken out the
OTR related references and you can start out with this file.
</p>
<h4>otr_setup.nsi</h4>
<p>
This file will start with the following
</p>
<pre>
;--------------------------------
;Include Modern UI

  !include "MUI2.nsh"

; The name of the installer
; *** Change this to fit your application name
Name "OpenBD-OTR"

; The file to write
OutFile "setup.exe"

; The default installation directory
; *** InstallDir $PROGRAMFILES\OpenBD-OTR
InstallDir C:\MyCompany\OpenBD-OTR

</pre>
<p>
Here you will change the Name to fit your Application. It will show up at the top of your installer dialog as
a header "OpenBD-OTR Setup"
</p>
<p>
OutFile can also be changed if you rather like to use install.exe for example.
</p>
<p>
InstallDir can also be changed to something that fits your application. You can place your application under 
Program Files which is a Predefined Variable within NSIS.<br />
It does generate problems on Windows Vista - Windows 7 when you try to place your application under the
Program Files directory. Windows is protecting this folder and if your application tries to manipulate
templates inside your app folder or save some file for temporary usage it will not work.
</p>
<p>
Due to this problem I have decided to place my application under the directory C:\MyCompany\OpenBd-OTR
</p>
<pre>
; Registry key to check for directory (so if you install again, it will
; overwrite the old one automatically)
InstallDirRegKey HKLM "Software\OpenBD-OTR" "Install_Dir"
</pre>
<p>
This is a section for the Windows Registry which will be used later for the un-installer.
</p>
<pre>

; Request application privileges for Windows Vista (user / admin)
RequestExecutionLevel user
</pre>
<p>
This is an issue on Vista and above. Can be set to user or admin. Since there are .ini files around in
OpenBD.Local Windows will complain if you set this value to user and install your application under the
Program Files directory, so keep this set to admin.
</p>
<p>
To avoid any problem just don't install under Program Files and you can keep this value set to "user".
</p>
<p>
<pre>
; Splash
XPStyle on

Function .onInit
	# the plugins dir is automatically deleted when the installer exits
	InitPluginsDir
	File /oname=$PLUGINSDIR\splash.bmp "c:\Deploy\OpenBD-OTR\webapp\otr\images\installer.bmp"
	#optional
	#File /oname=$PLUGINSDIR\splash.wav "C:\myprog\sound.wav"

	advsplash::show 2000 600 400 0x1856B1 $PLUGINSDIR\splash

	Pop $0 ; $0 has '1' if the user closed the splash screen early,
			; '0' if everything closed normally, and '-1' if some error occurred.
FunctionEnd
</pre>
</p>
<p>
The Splash screen can be used or not.  If you don't want one, just leave this section out. You can
even make sure to get on your users nerves by playing them a wav file when the Splash screen is displayed :)
</p>
<p>
I created an image for the OTR. The format has to be BMP.
</p>
<div align="center"><img src="/manual/pages/local-installer.jpg" alt="" width="650" height="400" border="0"></div>

<p>
Next we define the pages to be used.
</p>
<p>
<pre>
; Pages

;--------------------------------
;Interface Settings

  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_BITMAP "${NSISDIR}\Contrib\Graphics\Header\nsis.bmp" ; optional
  !define MUI_ABORTWARNING

  !insertmacro MUI_PAGE_LICENSE "OpenBD-OTR\license\openbd.license"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES

;UninstPage uninstConfirm
;UninstPage instfiles
</pre>
</p>
<p>
The top 3 can be used or not. I preferred to add a header image to the installer dialogs. Made it
look a bit more professional. For this image use a standard image file from the NSIS Software or the
one with the OpenBD logo provided above.
</p>
<p>
The !insertmacro MUI_PAGE_LICENSE can be used or not. In my case I selected to display the GNU 3
license used in OpenBD.
</p>
<p>
MUI_PAGE_COMPONENTS gives you the opportunity to create a start menu or not. Your application is
always selected and can't be de-selected.
</p>

<p>
MUI_PAGE_DIRECTORY is the dialog to define where to install your App. Since we previously defined
the following:
</p>
<p>
<pre>
; The default installation directory
InstallDir C:\MyCompany\OpenBD-OTR
</pre>
</p>
<p>
The default value will be C:\MyCompany\OpenBd-OTR
</p>
<p>
MUI_PAGE_INSTFILES is simply the page which is displayed during the installation
</p>
<p>
MUI_UNPAGE_CONFIRM and MUI_UNPAGE_INSTFILES are the 2 dialogs which will be displayed in case someone
uninstalls your App. First they have to confirm that they really want to uninstall and then the screen
showing the process of the uninstall.
</p>

<p>
<pre>
;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "English"

</pre>
</p>
<p>
Here you define the language for the installer. There is an example in the NSIS installation how to
create a language selection Page. I didn't need this so I just selected one language, in this case English.
</p>
<p>
From here on the heavy work starts. Our files to be installed. To make it easy I will add my <a href="/manual/pages/openbd_setup.txt" onfocus="this.blur();">otr_setup.nsi</a>
in a cut version where just the OpenBD.Local and the OpenBD itself is included and where you simply add your own files.
</p>
<p>
There is an Install and an Uninstall section.
</p>

<p>
<pre>
; The stuff to install
Section "OTR (required)"

  SectionIn RO

  ; Set output path to the installation directory.
  SetOutPath $INSTDIR

</pre>
</p>
<p>
Section references the MUI_PAGE_COMPONENTS. Remember that the user can't deselect your application only the start menu.
</p>
<p>
First to define is the Path which is done with the SetOutPath. Unfortunately (since we're creating this script manually)
we have to define this statement for all subdirectories.
</p>
<p>
<pre>
  ; Put file there
  File "OpenBD-OTR\openbd-local.ini"
  File "OpenBD-OTR\openbd-readme.txt"
  File "OpenBD-OTR\openbd.exe"
  File "OpenBD-OTR\openbd.ini"
  File "OpenBD-OTR\openbd.jar"
  File "OpenBD-OTR\openbdlocal.jar"
  File "otr_setup.nsi"

  SetOutPath $INSTDIR\jre\bin\client

  File "OpenBD-OTR\jre\bin\client\classes.jsa"
  File "OpenBD-OTR\jre\bin\client\jvm.dll"
  File "OpenBD-OTR\jre\bin\client\Xusage.txt"

  SetOutPath $INSTDIR\jre\bin\new_plugin

  File "OpenBD-OTR\jre\bin\new_plugin\msvcr71.dll"
  File "OpenBD-OTR\jre\bin\new_plugin\npjp2.dll"

</pre>
</p>

<p>
As seen above we have to use the SetOutPath for each directory.
</p>
<p>
First I install the main openbd-local files, and in my case, I included the NSIS script as well. You really don't
have to do this!
</p>
<p>
Changing the directory to the JRE and then list every file in each directory. This list will be pretty long so
I'm not gonna waste HTML Bytes for this. My script is, as mentioned, attached separately containing the complete
OpenBD.Local and OpenBD.
</p>
<p>
<pre>
  ; Write the installation path into the registry
  WriteRegStr HKLM SOFTWARE\OpenBD-OTR "Install_Dir" "$INSTDIR"

  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenBD-OTR" "DisplayName" "OpenBD-OTR"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenBD-OTR" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenBD-OTR" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenBD-OTR" "NoRepair" 1
  WriteUninstaller "uninstall.exe"

SectionEnd

</pre>
</p>
<p>
The Application Section ends with some Registry stuff which is used for the uninstaller part. What you will
need to change here will be the OpenBD-OTR and change it to something that fits your application.

</p>
<p>
The next section will be for the Start menu.
</p>
<p>
<pre>
; Optional section (can be disabled by the user)
Section "Start Menu Shortcuts"

  CreateDirectory "$SMPROGRAMS\OpenBD-OTR"
  CreateShortCut "$SMPROGRAMS\OpenBD-OTR\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
  CreateShortCut "$SMPROGRAMS\OpenBD-OTR\OpenBD-OTR.lnk" "$INSTDIR\openbd.exe" "" "$INSTDIR\openbd.exe" 0

SectionEnd

</pre>
</p>
<p>
The same thing to change in this part. the Application Name OpenBD-OTR into your Application Name. It's shortcuts
for the openbd.exe and the uninstaller.exe which will show up in the start-menu.
</p>
<p>
<pre>
; Uninstaller

Section "Uninstall"

  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\OpenBD-OTR"
  DeleteRegKey HKLM SOFTWARE\OpenBD-OTR

  ; Remove files and uninstaller
  Delete "$INSTDIR\openbd-local.ini"
  Delete "$INSTDIR\openbd-readme.txt"
  Delete "$INSTDIR\openbd.exe"
  Delete "$INSTDIR\openbd.ini"
  Delete "$INSTDIR\openbd.jar"
  Delete "$INSTDIR\openbdlocal.jar"
  Delete "$INSTDIR\otr_setup.nsi"
  Delete "$INSTDIR\jre\bin\client\classes.jsa"
  Delete "$INSTDIR\jre\bin\client\jvm.dll"

</pre>
</p>

<p>
This is pretty much the same list as in the installation part. Only the file path is
based on the Installation Directory. It starts by deleting some Registry Keys.
</p>
<p>
<pre>
  ; Delete $INSTDIR\otr_setup.nsi
  Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\$INSTDIR\*.*"

  ; Remove directories used
  RMDir /r "$SMPROGRAMS\OpenBD-OTR"
  RMDir /r "$INSTDIR\jre"
  RMDir /r "$INSTDIR\license"
  RMDir /r "$INSTDIR\webapp"
  RMDir "$INSTDIR"

SectionEnd

</pre>
</p>
<p>
The section ends by deleting the uninstall.exe and the Start Menu shortcuts. Removing Directories etc.
</p>
<p>
I am pretty sure that the RMDir /r would delete directories and files in one go but I decided to go the
filelist way. 1, I had the list from the installation part and could pretty quick replace the File with
Delete and the source Path to the $INSTDIR. 2. The uninstall dialog box will show a progress that it's
working and what it is doing. I'm pretty sure you can select the RMDir /r here though.
</p>
<h3>Time to compile</h3>

<p>
Now we're ready to create our installer.
</p>

<p>
Start the NSIS "Compile NSI Scripts"
</p>

<p>
<div align="center"><img src="/manual/pages/local-compiler.jpg" alt="" width="742" height="562" border="0"></div>
</p>

<p>
As you can see you have more options to compile your script. A simple way is simply to drag the file onto
the NSIS compiler.
</p>

<p>
In the scripts Menu you can select compression level. On my OTR Project the difference between the default
version and the Best Compressor was about 15 MB. Best Compression takes of course a bit longer but the
installer-file a user has to download will be smaller, so this was my selection.
</p>

<p>
When done you test your setup program right away from the compiler by just clicking on the "Test Installer" button.
</p>

<h2>That's All Folks!</h2>

<p>
I hope this little guide will help you get started with OpenBD.Local, Your own OpenBD Application and the NSIS Installer.
</p>

<p>
If you have any questions feel free to contact me over <a href="mailto:dothebizznow@gmail.com" onfocus="this.blur();">dothe...now@gmail.com</a> or over the mailing list at openbd.org
and I will do my best to help you out. If not me than there are lots of really good people on this mailing list that
are always there to help out!!
</p>

<p>
Mats Str&ouml;mberg<br />
NETWORK 23<br />
Switzerland
</p>

		</div><!--- .section --->

	</div><!--- .container --->
</div><!--- .content --->