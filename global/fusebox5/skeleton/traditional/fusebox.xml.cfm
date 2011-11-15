<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE fusebox>
<!--
	Example fusebox.xml control file. Shows how to define circuits, classes,
	parameters and global fuseactions.

	This is just a test namespace for the plugin custom attribute example
-->
<fusebox xmlns:test="test">
	<!--
		this is a model-view-controller application
		there is one public controller circuit (controller/, aliased to app)
		there is one internal model circuit (model/time/, aliased to time)
		there are two internal view circuits:
			view/display, aliased to display
			view/layout, aliased to layout
	-->
	<circuits>
		<!-- illustrates defaults for parent ("") and relative ("true") -->
		<circuit alias="time" path="model/time/" parent="" />
		<circuit alias="display" path="view/display/" parent="" />
		<circuit alias="layout" path="view/layout/" parent="" />
		<circuit alias="app" path="controller/" relative="true" />
	</circuits>

	<!--
	<classes>
		<class alias="MyClass" type="component" classpath="path.to.SomeCFC" constructor="init" />
	</classes>
	-->

	<parameters>
		<parameter name="defaultFuseaction" value="app.welcome" />
		<!-- you may want to change this to development-full-load mode: -->
		<parameter name="mode" value="development-circuit-load" />
		<parameter name="conditionalParse" value="true" />
		<!-- change this to something more secure: -->
		<parameter name="password" value="skeleton" />
		<parameter name="strictMode" value="true" />
		<parameter name="debug" value="true" />
		<!-- we use the core file error templates -->
		<parameter name="errortemplatesPath" value="/fusebox5/errortemplates/" />
		<!--
			These are all default values that can be overridden:
		<parameter name="fuseactionVariable" value="fuseaction" />
		<parameter name="precedenceFormOrUrl" value="form" />
		<parameter name="scriptFileDelimiter" value="cfm" />
		<parameter name="maskedFileDelimiters" value="htm,cfm,cfml,php,php4,asp,aspx" />
		<parameter name="characterEncoding" value="utf-8" />
		<parameter name="strictMode" value="false" />
		<parameter name="allowImplicitCircuits" value="false" />
		-->
	</parameters>

	<globalfuseactions>
		<appinit>
			<fuseaction action="time.initialize"/>
		</appinit>
		<!--
		<preprocess>
			<fuseaction action="time.preprocess"/>
		</preprocess>
		<postprocess>
			<fuseaction action="time.postprocess"/>
		</postprocess>
		-->
	</globalfuseactions>

	<plugins>
		<phase name="preProcess">
			<!--
			<plugin name="prePP" template="example_plugin" test:abc="123">
				<parameter name="def" value="456" />
			</plugin>
			-->
		</phase>
		<!--
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
		-->
	</plugins>

</fusebox>
