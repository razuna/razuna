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
<div id="showcontent" />
<!--- Save Note 
<script language="javascript">
	function savenoteedit(newfid,noteid,colid,tagid){
		err = 1;
		if(document.getElementById('title').value == "")err=0;
			if(err==0){
				alert('<cfoutput>#gobj.trans("note_error_title")#</cfoutput>');
			}
			else{
				getEditorsHTML();
				ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.notesave&newfid=' + newfid + '&noteid=' + noteid, 'showcontent', '', '', 'post', 'thenote');
				if (colid != 0){
					setTimeout("thedelay('collist', 'colid=" + colid + "')", 1000);
				}
				else if (tagid != 0){
					setTimeout("thedelay('taglist', 'tagid=" + tagid + "')", 1000);
				}
				else{
					setTimeout("thedelay('noteslist','0')", 1000);
				}
			}
	}
</script>

<!--- Save Bookmark --->
<script language="javascript">
	function savebookedit(newfid,bookid,colid,tagid){
		err = 1;
		if(document.getElementById('title').value == "")err=0;
			if(err==0){
				alert('<cfoutput>#gobj.trans("bookmark_error_title")#</cfoutput>');
			}
			else{
				ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.bookmarksave&newfid=' + newfid + '&bookid=' + bookid, 'showcontent', '', '', 'post', 'thebook');
				if (colid != 0){
					setTimeout("thedelay('collist', 'colid=" + colid + "')", 1000);
				}
				else if (tagid != 0){
					setTimeout("thedelay('taglist', 'tagid=" + tagid + "')", 1000);
				}
				else{
					setTimeout("thedelay('bookmarkslist','0')", 1000);
				}
			}
	}
</script>

<!--- Save Password --->
<script language="javascript">
	function savepasswordedit(newfid,passid,colid,tagid){
		err = 1;
		if(document.getElementById('title').value == "")err=0;
			if(err==0){
				alert('<cfoutput>#gobj.trans("password_error_title")#</cfoutput>');
			}
			else{
				ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.passwordssave&newfid=' + newfid + '&passid=' + passid, 'showcontent', '', '', 'post', 'thepass');
				if (colid != 0){
					setTimeout("thedelay('collist', 'colid=" + colid + "')", 1000);
				}
				else if (tagid != 0){
					setTimeout("thedelay('taglist', 'tagid=" + tagid + "')", 1000);
				}
				else{
					setTimeout("thedelay('passwordslist','0')", 1000);
				}
			}
	}
</script>

<!--- Save Serial --->
<script language="javascript">
	function saveserialedit(newfid,serid,colid,tagid){
		err = 1;
		if(document.getElementById('title').value == "")err=0;
			if(err==0){
				alert('<cfoutput>#gobj.trans("serial_error_title")#</cfoutput>');
			}
			else{
				ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.serialssave&newfid=' + newfid + '&serid=' + serid, 'showcontent', '', '', 'post', 'theserial');
				if (colid != 0){
					setTimeout("thedelay('collist', 'colid=" + colid + "')", 1000);
				}
				else if (tagid != 0){
					setTimeout("thedelay('taglist', 'tagid=" + tagid + "')", 1000);
				}
				else{
					setTimeout("thedelay('serialslist','0')", 1000);
				}
			}
	}
</script>

<!--- SAVE DOCUMENT --->
<script language="javascript">
	function savedocedit(newfid,docid,colid,tagid){
		err = 1;
		if(document.getElementById('title').value == "")err=0;
			if(err==0){
				alert('<cfoutput>#gobj.trans("doc_error_title")#</cfoutput>');
			}
			else{
				ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.docssave&newfid=' + newfid + '&docid=' + docid, 'showcontent', '', '', 'post', 'thedoc');
				if (colid != 0){
					setTimeout("thedelay('collist', 'colid=" + colid + "')", 1000);
				}
				else if (tagid != 0){
					setTimeout("thedelay('taglist', 'tagid=" + tagid + "')", 1000);
				}
				else{
					setTimeout("thedelay('docslist','0')", 1000);
				}
			}
	}
</script>

<!--- ADD A NEW IMAGE --->
<script language="javascript">
	function saveimgedit(newfid,imgid,colid,tagid){
		err = 1;
		if(document.getElementById('title').value == "")err=0;
			if(err==0){
				alert('<cfoutput>#gobj.trans("img_error_title")#</cfoutput>');
			}
			else{
				ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.imgsave&newfid=' + newfid + '&imgid=' + imgid, 'showcontent', '', '', 'post', 'theimg');
				if (colid != 0){
					setTimeout("thedelay('collist', 'colid=" + colid + "')", 1000);
				}
				else if (tagid != 0){
					setTimeout("thedelay('taglist', 'tagid=" + tagid + "')", 1000);
				}
				else{
					setTimeout("thedelay('imglist','0')", 1000);
				}
			}
	}
</script>

<!--- ADD USER --->
<script language="javascript">
	function usersave(userid){
		err = 1;
		if(document.getElementById('username').value == "")err=0;
		if(document.getElementById('firstname').value == "")err=0;
		if(document.getElementById('lastname').value == "")err=0;
		if(document.getElementById('email').value == "")err=0;
		if(document.getElementById('pass').value != document.getElementById('pass2').value)err=2;
			if(err==0){
				alert('<cfoutput>#gobj.trans("fielderror")#</cfoutput>');
			}
			else if(err==2){
				alert('<cfoutput>#gobj.trans("password_confirm_error")#</cfoutput>');
			}
			else{
				ColdFusion.navigate('<cfoutput>#myself#c.userssave&thepath=#expandpath(".")#</cfoutput>&userid=' + userid, 'showcontent', '', '', 'post', 'theuser');
				setTimeout("thedelay('users','0')", 1000);
				}
	}
</script>

<!--- Get the content from the fckeditor --->
<script language="JavaScript">
	function getEditorsHTML(){
		// Get the content from the editor
		var oEditor = FCKeditorAPI.GetInstance('thetext'); 
		var tcontent = oEditor.GetXHTML();
		// set the values of the form
		document.thenote.thecontent.value = tcontent;
		} 
</script>

<!--- Add a short delay of one second when saving above --->
<script language="JavaScript">
	function thedelay(what,theid){
		//alert(colid);
		ColdFusion.navigate('<cfoutput>#myself#</cfoutput>c.' + what + '&' + theid,'rightside');
	}
</script>

--->