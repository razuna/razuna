<!DOCTYPE html> 
<html> 
<head> 
  <meta content="text/html; charset=ISO-8859-1" 
 http-equiv="content-type"> 
  <title>index</title> 
</head> 
<body>
	
<script src="http://widgets.twimg.com/j/2/widget.js"></script>
<script>
new TWTR.Widget({
  version: 2,
  type: 'profile',
  rpp: 5,
  interval: 30000,
  width: 'auto',
  height: 300,
  theme: {
    shell: {
      background: '#d6d6d6',
      color: '#000000'
    },
    tweets: {
      background: '#ffffff',
      color: '#000000',
      links: '#30631b'
    }
  },
  features: {
    scrollbar: true,
    loop: false,
    live: true,
    hashtags: true,
    timestamp: true,
    avatars: true,
    behavior: 'all'
  }
}).render().setUser('razunahq').start();
</script>

</body> 
</html>