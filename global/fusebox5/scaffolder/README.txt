This is a new development by Kevin Roche to experiment with scaffolding for Fusebox 5.5. With help from Peter Bell.
********** 23 Nov 2007 - NOTE ************
Latest upload includes the GUI interface. At present the GUI interface only works with the index.cfm style of Fusebox. Sean and I are working on integrating it with the main fusebox framework.

Please read the word document Fusebox_scaffolding_002.doc for more information on how to use the GUI interface.

Fo the moment please ensure that the project and datasource names are the same as the project name was a recent improvement and all the required changes have not yet been completed. 

********** Quick Start ************

To make use of the scaffolding copy the extensions/scaffolding/ directory to a directory called scaffolder under your coldFusion root. You can try running it elsewhere but there may be chnages reqired and it has not been tested in any other directory.

Currently you will have to add the following line to the start your index.cfm file (later this will be part of fusebox 5.5):

<cfinclude template="/scaffolder/manager.cfm">

If you wish to use the reactor templates, the generated code will require you to have Doug Hughes' reactor and the reactor lexicon installed too.

If you wish to use the coldspring templates the generated code will require ColdSpring and the coldspring lexicon installed.

Run index.cfm?scaffolding.go=display

The GUI interface will display and you can make all the required choices before generating your code. When complete you can click on generate and scaffolder will create the directories for model, view, controller, udfs and subdirectorys named using the name of the datasource. (should be the project but this is not working yet).

EG. if the datasource is FuseForum:

/myapplication/
/myapplication/controller/
/myapplication/controller/FuseForum/
/myapplication/model/
/myapplication/model/mFuseForum/
/myapplication/view/
/myapplication/view/vFuseForum/
/myapplication/view/vLayout/
/myapplication/udfs/

The generated code will probably not quite work at the moment as I have made lots of changes lately and there are some unfixed bugs.

Now comes the slow bit - debug.....

*********** Options available during the scaffolding process *************

The scaffolder extension does two things:
1/ Introspect the Database to create an XML Metadata description.
2/ Use the XML Metadata description to create code from a set of templates.

You can simply use it as above to create an application based on the chosen templates, but there are some other possibilities. As a first choice you can modify the XML that is created and so change the generated code. There is a description of the XML in the document "Fusebox Scaffolding XML" which can be found in the same directgory as this file. 

The second choice is to change the templates. If you wish to do this it is suggested that you make a copy of an existing set to another subdirectory. The templates can be found in the subdirectories of the templates directory. Each set of templates has its own subdirectory.

*** 13/Nov/2007 - Kevin Roche
BUG:  Reactor Templates: When the Datasource and Project names are different some generated code is wrong.

TODO: ColdSpring Templates: Update code template for the basic Gateway to support joins to child and iterator.
TODO: ColdSpring Templates: Create code templates for JSON AJAX support.

TODO: Transfer Templates: Create templates to support Transfer ORM - Volunteers needed.

TODO: Fusebox 5.5: Integrate with core. Add ability to trigger Scaffolder with URL parameters.

TODO: Metadata.cfc: Support for MYSQL DBMS - Volunteers needed.
TODO: Metadata.cfc: Support for ORACLE DBMS - Volunteers needed.

*** 13/Nov/2007 - Kevin Roche
I finally got time to work on this again after a few weeks of hectic madness. Spent the whole evening generating code and finding bugs in the generated code, using the ColdSpring Templates.

I am uploading what I have done so far as it makes my life easier to download it all from SVN onto the various machines I have to test it on. I have hopefully fixed the following bugs, but more testing will be done over the next few days:

BUG:  Currently the code only works on Windows platform. 
	- Now should be OK on Unix or Linux but I haven't tested it yet.
BUG:  Code has to be copied to a directory called \scaffolder\ under the ColdFusion Root. 
	- should now work anywhere in the web root, testing underway.

I have also made a large number of changes to the very buggy ColdSpring templates but in the process I have broken the Reactor templates. I will fix them soon.

*** 27/Sep/2007 - Kevin Roche
We are going for a release of the Alpha on Monday. There are still a number of known issues with the generated code. My real goal is that the code should run when first generated but that eludes me at present with the ColdSpring Templates and I have not had time to restest the Reactor Templates since I made a bug fix for the problem caused when the Database name and Datasource name do not match. I have gone over to driving all the file paths from the Datasource name.

I have a problem with the ColdSpring code which means that the code refuses to initialise when a boolean is encounted ion the code. I think this must be somthing to do with using 1 and 0 versus True and False. So it probably easy to fix will work on that today.

*** 07/Sep/2007 - Kevin Roche
Just made an improvement to cftempate so that the Quick Start will work better. I forgot to suggest the init paramaters in the quick start and realised that they were required in most cases. It only worked on my machine wuthout them beacuse of a mapping I had. Now it will work out for you what they should be so in almost every case you won't need them.

One bug found is that when the Datasource and Database names are different the code in the fusebox.xml is wrong. For the time being you can edit it. I will fix that soon.

*** 06/Sep/2007 - Kevin Roche
OK, So I know you think I spent the summer enjoying myself and forgot all about Fusebox Scaffolding!

Actually spent a lot of it in my Girlfriends Bathroom where I fitted a new Bathroom Suite with help from a plumber. On top of that the expected flow of work did not slow down.

One customer who have been using CF5 for many years finally decided to upgrade to CF7 a week after CF8 was released. So we have been installing a bunch of CF7 instances and also getting out first CF8 customer going. 

Enough of the excuses.... 

This week I finally got around to working out how to make the Scaffolding work with multiple sets of templates and moved the existing reactor templates to a subdirectory of the templates directory so that there can be any number of templates for different purposes or frameworks. <more/>

The current reactor templates have some serious limitations. Firstly they assume that every table has an integer primary key which is auto incrementing (Identity in SQL Server).

One of the problems in Reactor was that it requires that any generated (calculated) field use the name and data type of an exsiting field. So when I want to create a filed containing a record count for a table there has to be a suitable integer field to use as a dummy. I really wanted to have a way to deal with tables where the primary key was an arbitary field or a UUID but can see a way to do that 100% reliably with reactor. This was the bug mentioned in the entry below. Maybe Transfer will do it better, I will wait to find out.

*** 18/Jun/2007 - Kevin Roche

Finally got time to work on this and have fixed the bug that stopped it working without an existing scaffolding.xml file.

The code will now generate an application that uses Reactor to drive the model. There is still a bug in the generated code that I have to track down and fix. The code that creates a record count method does not find a valid fieldname for the counter so falls over when executed, in reactor. Will try and track this down in the next few days.

*** 10/Apr/2007 - Kevin Roche

Now creates a fully working application with reactor as ORM.

http://svn.fuseboxframework.org/framework/branches/dev/extensions/scaffolding/

This particular version I have called Version 0.1 Alpha.

It is supposed to allow you to point it at a SQL server database and will introspect it and create a maintenance application which allows you to list, display, add, edit and delete records from the each of the tables.

This version makes use of reactor so you will need fusebox 5 and reactor. 

I have been using fusebox 5.0 and I am about to begin testing it with fusebox 5.1 so there may be issues there.

It uses conventions to decide how to display the contents and the conventions could well be a cause of argument.

There are some issues with it (or reactor not sure which) when a table has multiple links to another table.

Most of the code is in two CFCs in the scaffolder subdirectory. metadata.cfc and cftemplate.cfc. The original cftemplate cfc has been modified to have a suitable init method and also to update individual funcions in CFCs and individual fuseactions in circuits.

There is also a templates subdirectory with the templates which are used to generate the application in it.

The process is essentially a two step process where the database introspection causes an XML file to be generated and that is then used to generate the code.

Once the code is created you can remove the scaffolder and the generated program should work without it.

My questions are:

1/ Is there a better way to do the XML reading and writing?

2/ Should I break the metadata.cfc into several smaller ones or merge the two CFCs into a single CFC?

3/ What other improvements should I make?

4/ Are either of you knowlegeable in another DBMS so that we can support MySQL or Oracle?

My future intentions are:

1/ Try this code with more databases to see what bugs there are. (So far there has only been one database tested).

2/ Create another set of templates for Transfer.

Kevin Roche


*** 05/Mar/2007 - Kevin Roche

New documentation in word format Fusebox Scaffolding XML 001.doc

Now code will introspect a database and create the controller XML and view fuses.

Next steps are the Reactor.xml and other reactor files.


*** 20/Feb/2007 - Kevin Roche

Proof of concept with the following files being generated from a sample XML file:

dsp_list_xxx.cfm
dsp_form_xxx.cfm
dsp_view_xxx.cfm
circuit.xml.cfm

I decided to make a couple of changes to the XML compared with my blog posting. 
I have modified the type attribute and the format attribute. Will update the documents soon. 

I also made a couple of small changes to the CFTemplate, and I am considering some more. 
In particular I am passing a component to CFTemplate to hold the metadata and it has methods 
to get all the stuff I need. At the moment there are about 10 lines at the top of each template 
that creates some local variables because they are used several times in the template.

The same lines are in most of the templates, so I am considering moving them into the CFC code 
instead, but that would make CFTemplate more dependant on my CFC but the templates less dependant 
on my CFC. So I am not sure yet the best way to do it.


*** 20/Feb/2007 - To Do List **********************************************

1/ Clean up the generator and update the documents on the XML.
2/ Split the template for circuit.xml.cfm into one per fuseaction.
3/ Allow the update of a fuseaction in an existing circuit.xml.cfm file.
4/ Put each file in the correct place in the directory structure.
5/ Update the code which creates the XML file using Reactor to the latest version of the XML.
6/ Refactor all of the above and implement as a Plug-In.
7/ Write an XML generator for Transfer.

But not necessarily in that order!


