<p>The data structure when listInfo is data or overlay will have 2 keys; diff and revisions.
	Revisions is an array containing all the revisions covered in the diff.
	Diff is an array or all the lines covered in the diff.</p>
<table class="zebra-striped">
	<thead>
		<tr>
			<th>Code</th>
			<th>Status</th>
			<th>Line Keys</th>
			<th>Revision Keys</th>
			<th>Description</th>
		</tr>
	</thead>
	<tbody>
		<tr>
			<td>P</td>
			<td>Pristine</td>
			<td>status,source,revision</td>
			<td>line,status</td>
			<td>Each revision will have entry</td>
		</tr>
		<tr>
			<td>A</td>
			<td>Add</td>
			<td>status,revision</td>
			<td>line,status,source</td>
			<td>Revisions prior to being added will not have an entry</td>
		</tr>
		<tr>
			<td>D</td>
			<td>Removed</td>
			<td>status,revision</td>
			<td>line,status,source</td>
			<td>Revisions after being removed will not have an entry</td>
		</tr>
		<tr>
			<td>U</td>
			<td>Updated</td>
			<td>status,revision</td>
			<td>line,status,source</td>
			<td>Revision that the change happened on will have status "U"</td>
		</tr>
	</tbody>
</table>

<p>Example overlay</p>

<pre>
{ "diff": [
    { "status": "P",
      "source": "hello world!",
      "revision": {
        "1": {
          "line": 1,
          "status": "P"
        },
        "2": {
          "line": 1,
          "status": "P"
        }
      }
    },
    { "status": "U",
      "revision": {
        "1": {
          "line": 2,
          "status": "P",
          "source": "hola mundo."
        },
        "2": {
          "line": 2,
          "status": "U",
          "source": "hola mundo!"
        }
      }
    },
    { "status": "D",
      "revision": {
        "1": {
          "line": 3,
          "status": "P",
          "source": "hi world..."
        }
      }
    },
    { "status": "A",
      "revision": {
        "2": {
          "line": 3,
          "status": "A",
          "source": "Bonjour le monde!"
        }
      }
    }
  ],
  "revisions": [1,2]
}
</pre>