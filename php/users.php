<?php

// STEP 1. Build Connection
// Secure way to store Connection Infromation
$file = parse_ini_file("../../../Twitter.ini");   // accessing the file with connection infromation

// retrieve data from file
$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

// include MySQLDAO.php for connection and interacting with db
require("secure/access.php");

// running MySQLDAO Class with constructed variables
$access = new access($host, $user, $pass, $name);
$access->connect();   // launch opend connection function



// STEP 2. Check passed data to this file from app
$word = null;
$username = htmlentities($_REQUEST["username"]);

if (!empty($_REQUEST["word"])) {
    $word = htmlentities($_REQUEST["word"]);
}



// STEP 3. Access searching func and retrieve data from server
$users = $access->selectUsers($word, $username);

if (!empty($users)) {
    $returnArray["users"] = $users;
} else {
    $returnArray["message"] = 'Could not find records';
}


// STEP 4. Close connection
$access->disconnect();


// STEP 5. Pass information back as json to user
echo json_encode($returnArray);



?>








