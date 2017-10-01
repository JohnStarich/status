<?php
error_reporting(E_ALL ^ E_WARNING);

function domainIsUp($domain, $port, $udp=false){
	if($udp)
		$domain = 'udp://' . $domain;
	$starttime = microtime(true);
	$file = fsockopen ($domain, $port, $errno, $errstr, 1);
	$stoptime = microtime(true);
	$status = false;
	if (!$file) $status = 0; // Site is down
	else {
		fclose($file);
		$status = ($stoptime - $starttime) * 1000;
		$status = floor($status)+1;
	}
	return $status;
}

if(! file_exists('services.json')) {
	echo '[Error] services.json does not exist';
	die();
}
$service_domains = json_decode(
	file_get_contents('services.json'),
	$assoc=true
);
if($error_code = json_last_error()) {
	$msg = json_last_error_msg();
	echo "[Error] parsing services.json - $error_code: $msg";
	die();
}

?>
<html>
<head>
	<title>Systems Status Report</title>
	<link rel="stylesheet" type="text/css" href="css/style.css">
	<link rel="stylesheet" type="text/css" href="css/status.css">
</head>
<body>
<h1>Systems Status</h1>
<div id="server_status">
<?php

if (count($service_domains) == 0) {
	echo "No domains defined.\n";
	die();
}

foreach ($service_domains as $service_domain => $services) {
	echo "<div class='domain'>\n<div class='domain-name'>$service_domain</div>\n";
	if (count($services) == 0) {
		echo "No services defined.\n";
	}
	else {
		echo "<ul class='ports'>\n";
		foreach ($services as $service => $connection_info) {
			$type = 'TCP';
			if(array_key_exists('protocol', $connection_info))
				$type = strtoupper($connection_info['protocol']);
			if($type != 'UDP' && $type != 'TCP') {
				echo "[Error] Invalid protocol in services.json: '$type'";
				die();
			}

			if(! array_key_exists('address', $connection_info)) {
				echo "[Error] No address provided for service $service in domain $service_domain";
				die();
			}
			$domain = $connection_info['address'];

			if(! array_key_exists('port', $connection_info)) {
				echo "[Error] No port provided for service $service in domain $service_domain";
				die();
			}
			$port = $connection_info['port'];

			$status = 'down';
			if(domainIsUp($domain, $port, $type == 'UDP'))
				$status = 'up';
			echo "<li class='domain-status $status description'>\n$service\n</li>\n";
		}
		echo "</ul>\n";
	}
	echo "</div>\n";
}

?>
</div>
<div id="update-time" data-epoch="<?php echo time()*1000; ?>">Last updated at <?php echo date('h:i a (M d)'); ?> UTC</div>
<script type="text/javascript">
	var update_time = document.getElementById("update-time");
	if(update_time.dataset.epoch) {
		var date = new Date(parseInt(update_time.dataset.epoch));
		update_time.innerText = "Last updated at " + date.toLocaleTimeString();
	}
	update_time = null;

	window.setTimeout(function() {
		window.location.reload(true);
	}, 5 * 60 * 1000);
</script>
</body>
</html>
