<?php

// STEP 1. Build connection
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



// STEP 2. Check did pass data to this file
// if data passed - save a post
if (!empty($_REQUEST["uuid"]) && !empty($_REQUEST["text"])) {


    // STEP 2.1 Pass POST / GET via html encryp and assign to vars
    $id = htmlentities($_REQUEST["id"]);
    $uuid = htmlentities($_REQUEST["uuid"]);
    $text = htmlentities($_REQUEST["text"]);


    // STEP 2.2 Create a folder in server to store posts' pictures
    $folder = "/Applications/XAMPP/xamppfiles/htdocs/Twitter/posts/" . $id;

    // if no posts folder, creat it
    if (!file_exists($folder)) {
        mkdir($folder, 0777, true);
    }


    // STEP 2.3 Move uploaded file
    $folder = $folder . "/" . basename($_FILES["file"]["name"]);

    if (move_uploaded_file($_FILES["file"]["tmp_name"], $folder)) {
        $returnArray["message"] = "Post has been made with picture";
        $path = "http://localhost/Twitter/posts/" . $id . "/post-" . $uuid . ".jpg"; // ...Twitter/posts/7/post-12312312.jpg
    } else {
        $returnArray["message"] = "Post has been made without picture";
        $path = "";
    }


    // STEP 2.4 Save path and other post details in db
    $access->insertPost($id, $uuid, $text, $path);



// if id of the user is not passed but uuid of post is passed -> delete post
} else if (!empty($_REQUEST["uuid"]) && empty($_REQUEST["id"])) {


    // STEP 2.1 Get uuid of post and path to post picture passed to this php file via swift POST
    $uuid = htmlentities($_REQUEST["uuid"]);
    $path = htmlentities($_REQUEST["path"]);

    // STEP 2.2 Delete post according to uuid
    $result = $access->deletePost($uuid);

    if (!empty($result)) {
        $returnArray["message"] = "Successfully deleted";
        $returnArray["result"] = $result;


        // STEP 2.3 Delete file according to its path and if it exists
        if (!empty($path)) {

            // /Applications/XAMPP/xamppfiles/htdocs/Twitter/posts/46/image.jpg
            $path = str_replace("http://localhost/", "/Applications/XAMPP/xamppfiles/htdocs/", $path);

            // file deleted successfully
            if (unlink($path)) {
                $returnArray["status"] = "1000";
            // could not delete file
            } else {
                $returnArray["status"] = "400";
            }
        }


    } else {
        $returnArray["message"] = "Could not delete post";
    }


// if data are not passed - show posts except id of the user
} else {


    // STEP 2.1 Pass POST / GET via html encryp and assign passed id of user to $id var
    $id = htmlentities($_REQUEST["id"]);


    // STEP 2.2 Select posts + user related to $id
    $posts = $access->selectPosts($id);

    // STEP 2.3 If posts are found, append them to $returnArray
    if (!empty($posts)) {
        $returnArray["posts"] = $posts;
    }


}


// STEP 3. Close connection
$access->disconnect();


// STEP 4. Feedback information
echo json_encode($returnArray);



?>







