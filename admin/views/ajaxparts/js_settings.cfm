function loadpref(){
	
	document.getElementById('rightside').innerHTML='<form name="myForm" id="myForm"><div id="rightside_sub"></div></form>;
	
	var prefglobal = new Ext.TabPanel({
        renderTo: 'rightside',
        defaults:{autoHeight: true, autoWidth: true},
		activeTab: 0,
        plain:true,
        defaults:{autoHeight: true, autoWidth: true},
        items:[{
				title: '<cfoutput>#defaultsObj.trans("installation_checklist")#</cfoutput>',
            	autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.mainsysteminfo'}
				},{
				title: 'System Information',
				autoLoad: {url: '<cfoutput>#myself#</cfoutput>ajax.mainsysteminfo'}
			}
        ]
    });
		
		 
}