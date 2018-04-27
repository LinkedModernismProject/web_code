<?php
	echo("in phppppppp");

	$q1_why = $_POST['q1_why'];
	$q2_service = $_POST['q2_service'];
	$q3_state = $_POST['q3_state'];
	$q4_comments = $_POST['q4_comments'];
	#$x = $_POST['']
	print "In the php!!!!!!!!!!!!!!!!!!!!!!!!";
	print_r($_POST);
	print $q2_service;
	print $q3_state;
	print $q4_comments;
	print 'after the php~~~~~~~~~~~~~~~~~';
	echo "Tester!!!!!!!!!!";
	print_r("Tester!!!!!!!!!!");
	print_r($_REQUEST);
	$dFile = "dataFile.txt";
	$fi = fopen($dFile, 'w') or die("Sorry dude, can't open file");
	fwrite($fi, "Hellloooooo")
	fwrite($fi, $q1_why);
	fclose($fi);
?>