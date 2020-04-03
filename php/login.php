<?php
// STEP 1. Declare variables to store user information
// array will store all informaiton
if ( empty($_REQUEST["username"]) || empty($_REQUEST["password"])) {

    $returnArray["status"] = "400";
    $returnArray["message"] = "Missing required information";
    return;

}

// Secure parsing of username and password variables
$username = htmlentities($_REQUEST["username"]);
$password = htmlentities($_REQUEST["password"]);



// STEP 2. Build Connection
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



// STEP 3. Get user
$user = $access->getUser($username);

if (empty($user)) {

    $returnArray["status"] = "403";
    $returnArray["message"] = "User is not found";
    echo json_encode($returnArray);
    return;

}



// STEP 4. Check validity of entered user information and information from database
// 4.1 Get password and salt from database
$secure_password = $user["password"];
$salt = $user["salt"];


// 4.2 Check if entered passwords match with password from database
if ($secure_password == sha1($password . $salt)) {

    $returnArray["status"] = "200";
    $returnArray["message"] = "Logged in successfully";
    $returnArray["id"] = $user["id"];
    $returnArray["username"] = $user["username"];
    $returnArray["email"] = $user["email"];
    $returnArray["fullname"] = $user["fullname"];
    $returnArray["ava"] = $user["ava"];
    echo json_encode($returnArray);
    return;

} else {

    $returnArray["status"] = "403";
    $returnArray["message"] = "Password do not match";
    echo json_encode($returnArray);
    return;

}


// STEP 5. Close connection after registration
$access->disconnect();



// STEP 6. JSON data
echo json_encode($returnArray);




?>