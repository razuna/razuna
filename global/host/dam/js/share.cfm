<script language="javascript" type="text/javascript">
// Save Comment
function addcomment(fileid,type){
	var thecom = escape($("#comment" + fileid).val());
	// Save Comment and reload list
	loadcontent('divlatcomment' + fileid,'index.cfm?fa=c.share_comments_add&file_id=' + fileid + '&type=' + type + '&comment=' + thecom);
	// Empty textarea
	document.getElementById('comment' + fileid).value = '';
}
</script>