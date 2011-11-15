<!--- Convert heigth / width for video --->
<script language="javascript">
// Will convert the value given in the width and set it in the heigth
function aspectheight(inp,out){
		//Check that the input value is mod, if not correct it
		if (inp.value%2 == 1){
			inp.value = inp.value - 1;
		}
		var theaspect = document.getElementById('set2_vid_preview_width').value / document.getElementById('set2_vid_preview_heigth').value;
		if (theaspect != 2){
			alert('<cfoutput>#defaultsObj.trans("correct_video_aspect")#</cfoutput>');
			var bytwo = inp.value / 2;
			if (bytwo%2 == 1){
			bytwo = bytwo - 1;
			}
			document.getElementById('set2_vid_preview_heigth').value = bytwo;
		}
}
// Will convert the value given in the heigth and set it in the width
function aspectwidth(inp,out){
		//Check that the input value is mod, if not correct it
		if (inp.value%2 == 1){
			inp.value = inp.value - 1;
		}
		var theaspect = document.getElementById('set2_vid_preview_heigth').value / document.getElementById('set2_vid_preview_width').value;
		if (theaspect != 2){
			alert('<cfoutput>#defaultsObj.trans("correct_video_aspect")#</cfoutput>');
			var bytwo = inp.value * 2;
			if (bytwo%2 == 1){
			bytwo = bytwo - 1;
			}
			document.getElementById('set2_vid_preview_width').value = bytwo;
		}
}
</script>
