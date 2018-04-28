Hi <?php echo htmlspecialchars($_POST['name']); ?>.
You are <?php echo (int)$_POST['age']; ?> years old.

<?php
	echo("in phppppppp");
?>

<form action="tester.php" method="post">
	<input type="text" name="name">
	<input type="text" name="age">
	<input type="submit">
</form>
