<?

// This is just an example of a script that receives the rollout completion notice

$start_time = addslashes($_POST['start_time']);
$duration = addslashes($_POST['duration']);
$from_ip = addslashes($_POST['from']);
$log = addslashes($_POST['log']);
$on_host = addslashes($_POST['on_host']);
$comment = addslashes($_POST['comment']);
$hostname = addslashes($_POST['hostname']);

// Now do something with the data, like insert it into a database

?>
