var gotodiv = function(mydiv,theurl){
	var thediv = Ext.get(mydiv);
	//Ext.MessageBox.alert('Good Job', thediv);	
	thediv.load({
		url: '<cfoutput>#myself#</cfoutput>ajax.dummy'
		});
	}

Ext.onReady(function(){

	// MENUS
    var menutabs = new Ext.TabPanel({
        renderTo: 'tabsmenu',
        activeTab: 0,
        width:260,
        plain:true,
        defaults:{autoHeight: true},
        items:[{
                title: 'CMS',
                autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.menu_cms'}
            },{
                title: 'DAM',
                autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.menu_dam'}
            },{
                title: 'Setup',
				disabled:false,
                autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.menu_settings'}
            }
        ]
    });
	
	// INTRO
	var introtab = new Ext.Panel({
        renderTo: 'tab_intro',
        defaults:{autoHeight: true, autoWidth: true},
		title: '<cfoutput>#defaultsObj.trans("welcome_to_ecp")#</cfoutput>',
        contentEl:'text_intro'
    });
	
	// SETUP
	var settab = new Ext.TabPanel({
        renderTo: 'tab_setup',
        activeTab: 0,
        plain:true,
        defaults:{autoHeight: true, autoWidth: true},
        items:[{
				title: '<cfoutput>#defaultsObj.trans("installation_checklist")#</cfoutput>',
            	autoLoad: {url: '<cfoutput>#myself#</cfoutput>c.mainchecklist'}
				},{
				title: 'System Information',
				autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.mainsysteminfo'}
			}
        ]
    });
	
	// WISDOM
	var introtab = new Ext.Panel({
        renderTo: 'tab_wisdom',
        defaults:{autoHeight: true, autoWidth: true},
		title: 'Wisdom of Today',
        contentEl:'text_wisdom'
    });
	
	// SUPPORT
	var settab = new Ext.TabPanel({
        renderTo: 'tab_support',
        activeTab: 0,
        plain:true,
        defaults:{autoHeight: true, autoWidth: true},
        items:[{
				title: 'Razuna Blog',
            	autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.mainblog'}
				/*
				This refreshes the tab each time it is clicked
				,
				listeners:{
                            activate : function(panel){
                                  panel.getUpdater().refresh();
                             }
                        }
				*/
				},{
				title: 'Support',
            	autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.mainsupport'}
			}
        ]
    });
	
});
