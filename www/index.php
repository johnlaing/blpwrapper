<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
    "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">

<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en-us">
<head>
   <meta http-equiv="content-type" content="text/html; charset=utf-8" />
   <title>RBloomberg</title>
   <meta name="author" content="Ana Nelson" />

   <!--- Blueprint CSS Framework -->
   <link rel="stylesheet" href="/css/blueprint/screen.css" type="text/css" media="screen, projection">
   <link rel="stylesheet" href="/css/blueprint/print.css" type="text/css" media="print">
   <!--[if IE]>
      <link rel="stylesheet" href="/css/blueprint/ie.css" type="text/css" media="screen, projection">
   <![endif]-->

   <!-- CodeRay syntax highlighting CSS -->
   <link rel="stylesheet" href="/css/pygments.css" type="text/css" />

   <!-- Homepage CSS -->
   <link rel="stylesheet" href="/css/site.css" type="text/css" media="screen, projection" />
</head>
<body>

<div class="container">

   <div class="column span-20 prepend-2 first">
      <h1>RBloomberg</h1>
<p>Homepage of the RBloomberg.</p>
<?php

$domain=ereg_replace('[^\.]*\.(.*)$','\1',$_SERVER['HTTP_HOST']);
$group_name=ereg_replace('([^\.]*)\..*$','\1',$_SERVER['HTTP_HOST']);

?>

<?php if ($handle=fopen('http://'.$domain.'/export/projtitl.php?group_name='.$group_name,'r')){
$contents = '';
while (!feof($handle)) {
	$contents .= fread($handle, 8192);
}
fclose($handle);
echo $contents; } ?>

<!-- end of project description -->

<p> No content added. </p>

<p> The <strong>project summary page</strong> you can find <a href="http://<?php echo $domain; ?>/projects/<?php echo $group_name; ?>/"><strong>here</strong></a>. </p>
   </div>

   <div class="column span-20 prepend-2 append-2 first last" id="footer">
     <hr />
     <p>This website was created with <a href="http://webby.rubyforge.org">Webby</a></p>
   </div>

</div>
</body>
</html>
