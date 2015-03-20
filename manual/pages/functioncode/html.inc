<p>
The html() fucntion is a wrapper to the very powerful Java <a href="http://jsoup.org/">JSoup parsing library</a> that gives a very
flexible selector and manipulation API for managing HTML code.
</p>


<pre class="cfml">
<cfscript>

http = Http( url='http://www.openbd.org/', result="requestHTML");
doc  = html( requestHTML.filecontent );

allLinks = doc.select("a[href]");
for ( x = 1; x <= ArrayLen(allLinks); x++ ){
  WriteOutput("&lt;li>" & allLinks[x].attr("href") & " / " & allLinks[x].text() & "&lt;/li>" );
}
</cfscript>
</pre>

<p>
Each selector returns a rich object that has methods you can use to either further select, introspect or modify the HTML block.   You can see
this by performing a <a href="./?/tag/CFDUMP">CFDUMP</a> on the object.
</p>

<p>
Selectors will either return a single <a href="http://jsoup.org/apidocs/org/jsoup/nodes/Element.html">Element</a> object, or an array of Elements.
</p>

<h4>Selector syntax (<a href="http://jsoup.org/apidocs/org/jsoup/select/Selector.html">reproduced</a>)</h4>
<p>A selector is a chain of simple selectors, seperated by combinators. Selectors are case insensitive (including against elements, attributes, and attribute values).</p>
<p> The universal selector (*) is implicit when no element selector is supplied (i.e. <code>*.header</code> and <code>.header</code> is equivalent). </p>

<table>
<tbody>
<tr>
<th>Pattern</th>
<th>Matches</th>
<th>Example</th>
</tr>
<tr>
<td><code>*</code></td>
<td>any element</td>
<td><code>*</code></td>
</tr>
<tr>
<td><code>tag</code></td>
<td>elements with the given tag name</td>
<td><code>div</code></td>
</tr>
<tr>
<td><code>ns|E</code></td>
<td>elements of type E in the namespace <i>ns</i></td>
<td><code>fb|name</code> finds <code>&lt;fb:name&gt;</code> elements</td>
</tr>
<tr>
<td><code>#id</code></td>
<td>elements with attribute ID of &quot;id&quot;</td>
<td><code>div#wrap</code>, <code>#logo</code></td>
</tr>
<tr>
<td><code>.class</code></td>
<td>elements with a class name of &quot;class&quot;</td>
<td><code>div.left</code>, <code>.result</code></td>
</tr>
<tr>
<td><code>[attr]</code></td>
<td>elements with an attribute named &quot;attr&quot; (with any value)</td>
<td><code>a[href]</code>, <code>[title]</code></td>
</tr>
<tr>
<td><code>[^attrPrefix]</code></td>
<td>elements with an attribute name starting with &quot;attrPrefix&quot;. Use to find elements with HTML5 datasets</td>
<td><code>[^data-]</code>, <code>div[^data-]</code></td>
</tr>
<tr>
<td><code>[attr=val]</code></td>
<td>elements with an attribute named &quot;attr&quot;, and value equal to &quot;val&quot;</td>
<td><code>img[width=500]</code>, <code>a[rel=nofollow]</code></td>
</tr>
<tr>
<td><code>[attr^=valPrefix]</code></td>
<td>elements with an attribute named &quot;attr&quot;, and value starting with &quot;valPrefix&quot;</td>
<td><code>a[href^=http:]</code></td>
</tr>
<tr>
<td><code>[attr$=valSuffix]</code></td>
<td>elements with an attribute named &quot;attr&quot;, and value ending with &quot;valSuffix&quot;</td>
<td><code>img[src$=.png]</code></td>
</tr>
<tr>
<td><code>[attr*=valContaining]</code></td>
<td>elements with an attribute named &quot;attr&quot;, and value containing &quot;valContaining&quot;</td>
<td><code>a[href*=/search/]</code></td>
</tr>
<tr>
<td><code>[attr~=<em>regex</em>]</code></td>
<td>elements with an attribute named &quot;attr&quot;, and value matching the regular expression</td>
<td><code>img[src~=(?i)\\.(png|jpe?g)]</code></td>
</tr>
<tr>
<td></td>
<td>The above may be combined in any order</td>
<td><code>div.header[title]</code></td>
</tr>
<tr>
<td colspan="3"><h4>Combinators</h4></td>
</tr>
<tr>
<td><code>E F</code></td>
<td>an F element descended from an E element</td>
<td><code>div a</code>, <code>.logo h1</code></td>
</tr>
<tr>
<td><code>E &gt; F</code></td>
<td>an F direct child of E</td>
<td><code>ol &gt; li</code></td>
</tr>
<tr>
<td><code>E + F</code></td>
<td>an F element immediately preceded by sibling E</td>
<td><code>li + li</code>, <code>div.head + div</code></td>
</tr>
<tr>
<td><code>E ~ F</code></td>
<td>an F element preceded by sibling E</td>
<td><code>h1 ~ p</code></td>
</tr>
<tr>
<td><code>E, F, G</code></td>
<td>all matching elements E, F, or G</td>
<td><code>a[href], div, h3</code></td>
</tr>
<tr>
<td colspan="3"><h4>Pseudo selectors</h4></td>
</tr>
<tr>
<td><code>:lt(<em>n</em>)</code></td>
<td>elements whose sibling index is less than <em>n</em></td>
<td><code>td:lt(3)</code> finds the first 2 cells of each row</td>
</tr>
<tr>
<td><code>:gt(<em>n</em>)</code></td>
<td>elements whose sibling index is greater than <em>n</em></td>
<td><code>td:gt(1)</code> finds cells after skipping the first two</td>
</tr>
<tr>
<td><code>:eq(<em>n</em>)</code></td>
<td>elements whose sibling index is equal to <em>n</em></td>
<td><code>td:eq(0)</code> finds the first cell of each row</td>
</tr>
<tr>
<td><code>:has(<em>selector</em>)</code></td>
<td>elements that contains at least one element matching the <em>selector</em></td>
<td><code>div:has(p)</code> finds divs that contain p elements </td>
</tr>
<tr>
<td><code>:not(<em>selector</em>)</code></td>
<td>elements that do not match the <em>selector</em>.
</tr>
<tr>
<td><code>:contains(<em>text</em>)</code></td>
<td>elements that contains the specified text. The search is case insensitive. The text may appear in the found element, or any of its descendants.</td>
<td><code>p:contains(jsoup)</code> finds p elements containing the text &quot;jsoup&quot;.</td>
</tr>
<tr>
<td><code>:matches(<em>regex</em>)</code></td>
<td>elements whose text matches the specified regular expression. The text may appear in the found element, or any of its descendants.</td>
<td><code>td:matches(\\d+)</code> finds table cells containing digits. <code>div:matches((?i)login)</code> finds divs containing the text, case insensitively.</td>
</tr>
<tr>
<td><code>:containsOwn(<em>text</em>)</code></td>
<td>elements that directly contains the specified text. The search is case insensitive. The text must appear in the found element, not any of its descendants.</td>
<td><code>p:containsOwn(jsoup)</code> finds p elements with own text &quot;jsoup&quot;.</td>
</tr>
<tr>
<td><code>:matchesOwn(<em>regex</em>)</code></td>
<td>elements whose own text matches the specified regular expression. The text must appear in the found element, not any of its descendants.</td>
<td><code>td:matchesOwn(\\d+)</code> finds table cells directly containing digits. <code>div:matchesOwn((?i)login)</code> finds divs containing the text, case insensitively.</td>
</tr>
<tr>
<td></td>
<td>The above may be combined in any order and with other selectors</td>
<td><code>.light:contains(name):eq(0)</code></td>
</tr>
</tbody>
</table>
