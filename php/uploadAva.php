<?php

// CHAPTER 1. UPLOADING FILE
// STEP 1. Check passed data to this php file
if (empty($_REQUEST["id"])) {
    $returnArray["message"] = "Missing required information";
    return;
}

// pass POST via htmlencrypt and assign to $id
$id = htmlentities($_REQUEST["id"]);



// STEP 2. Create a folder for user with name of his ID
$folder = "/Applications/XAMPP/xamppfiles/htdocs/Twitter/ava/" . $id;

// if it doesn't exist
if (!file_exists($folder)) {
    mkdir($folder, 0777, true);
}



// STEP 3. Move uploaded file
$folder = $folder . "/" . basename($_FILES["file"]["name"]);

if (move_uploaded_file($_FILES["file"]["tmp_name"], $folder)) {
    $returnArray["status"] = "200";
    $returnArray["message"] = "The file has been uploaded";
} else {
    $returnArray["status"] = "300";
    $returnArray["message"] = "Error while uploading";
}



// CHAPTER 2. UPDATING AVA PATH
// STEP 4. Build connection
// Secure way to build conn
$file = parse_ini_file("../../../Twitter.ini");

// store in php var inf from ini var
$host = trim($file["dbhost"]);
$user = trim($file["dbuser"]);
$pass = trim($file["dbpass"]);
$name = trim($file["dbname"]);

// include access.php to call func from access.php file
require ("secure/access.php");
$access = new access($host, $user, $pass, $name);
$access->connect();



// STEP 5. Save path to uploaded file in db
$path = "http://localhost/Twitter/ava/" . $id . "/ava.jpg";
$access->updateAvaPath($path, $id);



// STEP 6. Get new user information after updating
$user = $access->selectUserViaID($id);

$returnArray["id"] = $user["id"];
$returnArray["username"] = $user["username"];
$returnArray["fullname"] = $user["fullname"];
$returnArray["email"] = $user["email"];
$returnArray["ava"] = $user["ava"];



// STEP 7. Close connection
$access->disconnect();


// STEP 8. Feedback array to app user
echo json_encode($returnArray);


?>
















