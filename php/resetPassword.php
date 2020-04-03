<?php

// STEP 1. Get information passed to this file
if (empty($_REQUEST["email"])) {
    $returnArray["message"] = "Missing required information";
    echo json_encode($returnArray);
    return;
}

// Secure way to store information in $email var
$email = htmlentities($_REQUEST["email"]);


// STEP 2. Build connection
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



// STEP 3. Check if email is found in db as registered email address
// store all result of func in $user var
$user = $access->selectUserViaEmail($email);

// if there is any information stoting in $user variable
if (empty($user)) {
    $returnArray["message"] = "Email not found";
    echo json_encode($returnArray);
    return;
}



// STEP 4. Emailing
// include email.php
require ("secure/email.php");

// store all class in $email var
$email = new email();

// Generate unique string token assoc with user in our db
$token = $email->generateToken(20);

// Store unique token in our db
$access->saveToken("passwordTokens", $user["id"], $token);

// Prepare email messsage
$details = array();
$details["subject"] = "Password reset request on Twitter";
$details["to"] = $user["email"];
$details["fromName"] = "Akhmed Idigov";
$details["fromEmail"] = "akhmedidigov@gmail.com";

// Load html template
$template = $email->resetPasswordTemplate();
$template = str_replace("{token}", $token, $template);
$details["body"] = $template;

// Send email to user
$email->sendEmail($details);



// STEP 5. Return message to mobile app
$returnArray["email"] = $user["email"];
$returnArray["message"] = "We have sent you email to reset password";
echo json_encode($returnArray);



// STEP 6. Close connection
$access->disconnect();


?>










