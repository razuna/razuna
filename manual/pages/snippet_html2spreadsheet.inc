<cfset request.page.section = "support">
<cfset request.page.title = "Export an HTML table to a Spreadsheet (XLS)">
<cfset request.page.desc	= "Bootstrap snippet to show you how to create an HTML file from a Spreadsheet">

<div class="subnav">
  <div class="container">
    <ul class="breadcrumb">
    	<li><a href="./?/support">Support</li>
      <li class="active"><a href="./?/snippet_html2spreadsheet"><cfoutput>#request.page.title#</cfoutput></a></li>
    </ul>
  </div>
</div>


<div class="content" id="content">
	<div class="container cf">

		<h1>Export an HTML table to a Spreadsheet (XLS)</h1>

		<cfinclude template="pages/sidebar_support.inc" />
				
		<div class="section">
		
			<p>If is often you wish to give users the ability to export a previously rendered HTML &lt;TABLE&gt; to the offline XLS Spreadsheet format.
			Instead of re-rendering the table, you can simply take the html block (via Javascript if on the client side) and then pass it back to the server
			who will then convert it to a spreadsheet object.</p>
			
			<p>This is done using the very powerful <a href="./?/function/html">html()</a> and <a href="./?/function/SpreadSheetNew">SpreadSheetNew</a> OpenBD CFML functions.</p>


<pre>
&lt;cfscript>
tableBody = "&lt;table>&lt;tr>&lt;td>a&lt;/td>&lt;td>b&lt;/td>&lt;td>c&lt;/td>&lt;/tr>&lt;/table>";
doc = <a href="./?/function/html">html( tableBody )</a>;

// Replace the anchor tags
e = doc.select("a");
for ( x=1; x <= <a href="./?/function/ArrayLen">ArrayLen(e)</a>; x++ ){
  ee = e[x];
  t = ee.html();
  ee.after( t );
  ee.remove();
}

// Create the spreadsheet object
xls = <a href="./?/function/SpreadSheetNew">SpreadSheetNew()</a>;

// Loop over each TR/row of the table
tr = doc.select( "tbody tr" );
for ( trx=1; trx <= <a href="./?/function/ArrayLen">ArrayLen(tr)</a>; trx++ ){

  trrow	= tr[trx];

  // Loop over each column
  tds	= trrow.select("td, th");

  for ( tdx=1; tdx <= ArrayLen(tds); tdx++ ){
    tdcell    = tds[tdx];
    cellText  = tdcell.text();
    <a href="./?/function/SpreadsheetColumnFitToSize">SpreadsheetColumnFitToSize( xls, tdx )</a>;
    <a href="./?/function/SpreadsheetSetCellValue">SpreadsheetSetcellvalue ( xls, cellText, trx, tdx )</a>;
  }
}

xlsFile = <a href="./?/function/ExpandPath">ExpandPath("/WEB-INF/tmp/#GetTickCount()#.xls")</a>;
<a href="./?/function/SpreadsheetSetCellValue">SpreadsheetWrite( xls, xlsFile, true )</a>;
&lt;/cfscript><nocfml>
</pre>

		</div><!-- .section -->

	</div><!--- .container --->
</div><!--- .content --->