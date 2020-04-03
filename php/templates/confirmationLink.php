<?php

// STEP 1. Chech required & passed inf
if (empty($_GET["token"])) {
    echo 'Missing required information';
    return;
}

$token = htmlentities($_GET["token"]);



// STEP 2. Build connection
// Secure way to build conn
$file = parse_ini_file("../../../../Twitter.ini");

// store in php var inf from ini var
$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

// include access.php to call func from access.php file
require ("../secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();



// STEP 3. Get id of user
// store in $id the result of func
$id = $access->getUserID("emailTokens", $token);

if (empty($id["id"])) {
    echo 'User with this token is not found';
    return;
}



// STEP 4. Change status of confirmation and delete token
// assign result of func executed to $result var
$result = $access->emailConfirmationStatus(1, $id["id"]);

if ($result) {
    
    // 4.1 Delete token from 'emailTokens' table of db in mysql
    $access->deleteToken("emailTokens", $token);
    echo 'Thank You! Your email is now confirmed';
    
}



// STEP 5. Close connection
$access->disconnect();



?>