<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fusebox>
<!--
	Example fusebox.xml control file. Shows how to define circuits, classes,
	parameters and global fuseactions.

	This is just a test namespace for the plugin custom attribute example
-->
<fusebox xmlns:test="test">
	<circuits>
		<!-- illustrates defaults for parent ("") and relative ("true") -->
		<circuit alias="m" path="../../global/host/dam/model/" parent="" />
		<circuit alias="v" path="../../global/host/dam/views/" parent="" />
		<circuit alias="c" path="../../global/host/dam/controller/" relative="true" />
		<circuit alias="l" path="../../global/host/dam/views/layouts/" parent="v" />
		<circuit alias="ajax" path="../../global/host/dam/views/ajaxparts/" parent="v" />
	</circuits>

	<classes>
		<class alias="login" classpath="global.cfc.login" type="component" constructor="init"/>
		<class alias="groups" classpath="global.cfc.groups" type="component" constructor="init"/>
		<class alias="groups_users" classpath="global.cfc.groups_users" type="component" constructor="init"/>
		<class alias="users" classpath="global.cfc.users" type="component" constructor="init"/>
		<class alias="global" classpath="global.cfc.global" type="component" constructor="init"/>
		<class alias="hosts" classpath="global.cfc.hosts" type="component" constructor="init"/>
		<class alias="settings" classpath="global.cfc.settings" type="component" constructor="init"/>
		<class alias="folders" classpath="global.cfc.folders" type="component" constructor="init"/>
		<!-- <class alias="global" classpath="model.global" type="component" constructor="init"/> -->
		<class alias="security" classpath="global.cfc.security" type="component" constructor="init"/>
		<class alias="modules" classpath="global.cfc.modules" type="component" constructor="init"/>
		<!-- start : folder files -->
		<class alias="images" classpath="global.cfc.images" type="component" constructor="init"/>
		<class alias="videos" classpath="global.cfc.videos" type="component" constructor="init"/>
		<class alias="files" classpath="global.cfc.files" type="component" constructor="init"/>
		<class alias="audios" classpath="global.cfc.audios" type="component" constructor="init"/>
		<!-- end : folder files -->
		<class alias="assets" classpath="global.cfc.assets" type="component" constructor="init"/>
		<class alias="rssparser" classpath="global.cfc.rssparser" type="component" constructor="init"/>
		<class alias="email" classpath="global.cfc.email" type="component" constructor="init"/>
		<class alias="ftp" classpath="global.cfc.ftp" type="component" constructor="init"/>
		<class alias="basket" classpath="global.cfc.basket" type="component" constructor="init"/>
		<class alias="favorites" classpath="global.cfc.favorites" type="component" constructor="init"/>
		<class alias="xmp" classpath="global.cfc.xmp" type="component" constructor="init"/>
		<class alias="search" classpath="global.cfc.search" type="component" constructor="init"/>
		<class alias="collections" classpath="global.cfc.collections" type="component" constructor="init"/>
		<class alias="scheduler" classpath="global.cfc.scheduler" type="component" constructor="init"/>
		<class alias="log" classpath="global.cfc.log" type="component" constructor="init"/>
		<class alias="lucene" classpath="global.cfc.lucene" type="component" constructor="init"/>
		<class alias="custom_fields" classpath="global.cfc.custom_fields" type="component" constructor="init"/>
		<!-- <class alias="nirvanix" classpath="global.cfc.nirvanix" type="component" constructor="init"/> -->
		<class alias="amazon" classpath="global.cfc.amazon" type="component" constructor="init"/>
		<class alias="comments" classpath="global.cfc.comments" type="component" constructor="init"/>
		<class alias="versions" classpath="global.cfc.versions" type="component" constructor="init"/>
		<class alias="defaults" classpath="global.cfc.defaults" type="component" constructor="init"/>
		<class alias="backuprestore" classpath="global.cfc.backuprestore" type="component" constructor="init"/>
		<class alias="views" classpath="global.cfc.views" type="component" constructor="init"/>
		<class alias="widgets" classpath="global.cfc.widgets" type="component" constructor="init"/>
		<class alias="labels" classpath="global.cfc.labels" type="component" constructor="init"/>
		<class alias="rfs" classpath="global.cfc.rfs" type="component" constructor="init"/>
		<class alias="import" classpath="global.cfc.import" type="component" constructor="init"/>
		<class alias="plugins" classpath="global.cfc.plugins" type="component" constructor="init"/>
		<class alias="api" classpath="global.cfc.api" type="component" constructor="init"/>
		<class alias="akamai" classpath="global.cfc.akamai" type="component" constructor="init"/>
		<class alias="resourcemanager" classpath="global.cfc.ResourceManager" type="component" constructor="init"/>
		<class alias="smartfolders" classpath="global.cfc.smartfolders" type="component" constructor="init"/>
		<class alias="oauth" classpath="global.cfc.oauth" type="component" constructor="init"/>
		<class alias="dropbox" classpath="global.cfc.dropbox" type="component" constructor="init"/>
	</classes>

	<parameters>
		<parameter name="defaultFuseaction" value="c.login" />
		<!-- you may want to change this to: 
		development-circuit-load, development-full-load, production -->
		<parameter name="mode" value="development-full-load" />
		<parameter name="conditionalParse" value="false" />
		<!-- change this to something more secure: -->
		<parameter name="password" value="razfbreload" />
		<!-- strict-mode prohibits url-params in xfa-definitions -->
		<parameter name="strictMode" value="true" />
		<parameter name="errortemplatesPath" value="/fusebox5/errortemplates/" />
		<parameter name="characterEncoding" value="utf-8" />
		
		<!-- 
		<parameter name="queryStringStart" value="/" />
		<parameter name="queryStringSeparator" value="/" />
		<parameter name="queryStringEqual" value="/" />
		 -->
		
		<parameter name="fuseactionVariable" value="fa" />
		<parameter name="debug" value="false" />
		
		<!--
			These are all default values that can be overridden:
		<parameter name="fuseactionVariable" value="fuseaction" />
		<parameter name="precedenceFormOrUrl" value="form" />
		<parameter name="scriptFileDelimiter" value="cfm" />
		<parameter name="maskedFileDelimiters" value="htm,cfm,cfml,php,php4,asp,aspx" />
		<parameter name="characterEncoding" value="utf-8" />
		<paramater name="strictMode" value="false" />
		<parameter name="allowImplicitCircuits" value="false" />
		<parameter name="debug" value="false" />
		-->
	</parameters>

	<globalfuseactions>
		<appinit>
			<fuseaction action="m.initialize"/>
		</appinit>
		<!--
		<preprocess>
			<fuseaction action="m.preprocess"/>
		</preprocess>
		<postprocess>
			<fuseaction action="m.postprocess"/>
		</postprocess>
		-->
	</globalfuseactions>

	<plugins>
		<phase name="preProcess">
			<!-- <plugin name="global" template="global" /> -->
			<!--
			<plugin name="prePP" template="example_plugin" test:abc="123">
				<parameter name="def" value="456" />
			</plugin>
			-->
		</phase>
		<phase name="preFuseaction">
		</phase>
		<phase name="postFuseaction">
		</phase>
		<phase name="fuseactionException">
		</phase>
		<phase name="postProcess">
		</phase>
		<phase name="processError">
		</phase>
	</plugins>

</fusebox>
