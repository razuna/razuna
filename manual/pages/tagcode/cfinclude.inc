<p>
This tag, as well as its function version <a href="./?/function/renderinclude">RenderInclude()</a>, lets you include any page referenced (rendered as CFML) into the current
position of the template.    This is another way to split up common functionality.
</p>

<p>
A handy flag here is the <strong>runonce</strong> attribute.  This stops the referenced template from being included more than once in the given request.  An example of this
usage is if you used your included template to setup in-page functions (or even Javascript snippets), you can liberally put this file through your request files and it would
only ever get rendered once.  Naturally this is discouraged from a code maintenance point of view.
</p>

<p>
Consider the following example.  The template "runme.inc" would only get executed once, with the engine skipping over the next calls.   This works throughout the request, even
if the include is called from a different template with a different path.
</p>

<pre class="cfml">
&lt;cfinclude template="runme.inc" runonce="true" /&gt;
&lt;cfinclude template="runme.inc" /&gt;
&lt;cfinclude template="runme.inc" /&gt;
</pre>