<!---
Copyright 2006-07 Objective Internet Ltd - http://www.objectiveinternet.com

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
--->

<!--- 
This is a template descriptor file for the Reactor Templates.
The templates will create a complete maintenance application for the selected database 
tables using the Reactor ORM Framework and Fusebox 5.5
It assumes that all the tables have a field defined as integer, identity as primary key.
 --->
 
<!--- Create a description of each of the templates. --->
<!--- This is the list for reactor ORM --->
<!--- TODO: Create a similar list for Transfer and use a separate subdirectory for each one. --->
<cfscript>
//Supporting files: udf_appendParam.cfm, dsp_layout.cfm, fusebox.xml, reactor.xml
	stFileData = structNew();
	stFileData.templateFile = "udf_appendParam";
	stFileData.outputFile = "udf_appendParam";
	stFileData.MVCpath = "#destinationFilePath#udfs#variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "dsp_layout";
	stFileData.outputFile = "dsp_layout";
	stFileData.MVCpath = "#destinationFilePath#view#variables.OSdelimiter#vLayout#variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "dsp_menu";
	stFileData.outputFile = "dsp_menu";
	stFileData.MVCpath = "#destinationFilePath#view#variables.OSdelimiter#vLayout#variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "act_setupErrorsFromReactor";
	stFileData.outputFile = "act_setupErrorsFromReactor";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "fusebox.xml";
	stFileData.outputFile = "fusebox.xml";
	stFileData.MVCpath = "#destinationFilePath#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "fusebox.init";
	stFileData.outputFile = "fusebox.init";
	stFileData.MVCpath = "#destinationFilePath#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
//Reactor XML
	stFileData = structNew();
	stFileData.templateFile = "reactor";
	stFileData.outputFile = "reactor";
	stFileData.MVCpath = "#destinationFilePath#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "xml";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);

//View: dsp_list_, disp_display_, dsp_form_
	stFileData = structNew();
	stFileData.templateFile = "dsp_list_";
	stFileData.outputFile = "dsp_list_";
	stFileData.MVCpath = "#destinationFilePath#view#variables.OSdelimiter#v#variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "dsp_display_";
	stFileData.outputFile = "dsp_display_";
	stFileData.MVCpath = "#destinationFilePath#view#variables.OSdelimiter#v#variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "dsp_form_";
	stFileData.outputFile = "dsp_form_";
	stFileData.MVCpath = "#destinationFilePath#view#variables.OSdelimiter#v#variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
//Controller: circuit.xml.cfm
	stFileData = structNew();
	stFileData.templateFile = "base_circuit.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "listing.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "display.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.perObject = "true";
	stFileData.suffix = "cfm";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "add_form.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "action_add.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "edit_form.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "action_update.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.suffix = "cfm";
	stFileData.useAliasInName = "false";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "action_delete.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#controller#variables.OSdelimiter##variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
//Model:
	stFileData = structNew();
	stFileData.templateFile = "Gateway";
	stFileData.outputFile = "Gateway";
	stFileData.MVCpath = "#destinationFilePath#model#variables.OSdelimiter#m#variables.project##variables.OSdelimiter#Gateway#variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfc";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "getAllWithJoin";
	stFileData.outputFile = "Gateway";
	stFileData.MVCpath = "#destinationFilePath#model#variables.OSdelimiter#m#variables.project##variables.OSdelimiter#Gateway#variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfc";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "getNWithJoin";
	stFileData.outputFile = "Gateway";
	stFileData.MVCpath = "#destinationFilePath#model#variables.OSdelimiter#m#variables.project##variables.OSdelimiter#Gateway#variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfc";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "getRecordCount";
	stFileData.outputFile = "Gateway";
	stFileData.MVCpath = "#destinationFilePath#model#variables.OSdelimiter#m#variables.project##variables.OSdelimiter#Gateway#variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "true";
	stFileData.suffix = "cfc";
	stFileData.perObject = "true";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "model_circuit.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#model#variables.OSdelimiter#m#variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "false";
	stFileData.overwrite = "false";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
	
	stFileData = structNew();
	stFileData.templateFile = "initialise.xml";
	stFileData.outputFile = "circuit.xml";
	stFileData.MVCpath = "#destinationFilePath#model#variables.OSdelimiter#m#variables.project##variables.OSdelimiter#";
	stFileData.inPlace = "true";
	stFileData.overwrite = "true";
	stFileData.useAliasInName = "false";
	stFileData.suffix = "cfm";
	stFileData.perObject = "false";
	ArrayAppend(aTemplateFiles,stFileData);
</cfscript>


