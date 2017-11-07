<script type="text/javascript">
	// Save Comment
	function addcomment(fileid,type){
		var thecom = $("#comment" + fileid).val();
		// Save Comment and reload list
		$('#divlatcomment' + fileid).load('index.cfm?fa=c.share_comments_add', { file_id:fileid, type:type, comment:thecom } );
		// Empty textarea
		document.getElementById('comment' + fileid).value = '';
	}
	// New function to first get all the selected files
	function orderSelectedFiles() {
		// Get the selections
		var artimage = getimageselection();
		var artvideo = getvideoselection();
		var artaudio = getaudioselection();
		var artfile = getfileselection();
		// For URL
		var items = '&artofimage=' + artimage + '&artofvideo=' + artvideo + '&artofaudio=' + artaudio + '&artoffile=' + artfile;
		// Show window
		showwindow('index.cfm?fa=ajax.share_order' + items,'Order',500,1);
	}
</script>