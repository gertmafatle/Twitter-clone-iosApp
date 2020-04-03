<?php
// Declare classe to access this php file
class access {

    // connection global variables
    var $host = null;
    var $user = null;
    var $pass = null;
    var $name = null;
    var $conn = null;
    var $result = null;


    // constructing class
    function __construct($dbhost, $dbuser, $dbpass, $dbname) {

        $this->host = $dbhost;
        $this->user = $dbuser;
        $this->pass = $dbpass;
        $this->name = $dbname;

    }


    // connection function
    public function connect() {

        // establish connection and store it in $conn
        $this->conn = new mysqli($this->host, $this->user, $this->pass, $this->name);

        // if error
        if (mysqli_connect_errno()) {
            echo 'Could not connect to database';
        }

        // support all languages
        $this->conn->set_charset("utf8");

    }


    // disconnection function
    public function disconnect() {

        if ($this->conn != null) {
            $this->conn->close();
        }

    }


    // Insert user details
    public function registerUser($username, $password, $salt, $email, $fullname) {

        // sql command
        $sql = "INSERT INTO users SET username=?, password=?, salt=?, email=?, fullname=?";

        // store query result in $statement
        $statement = $this->conn->prepare($sql);

        // if error
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // bind 5 param of type string to be placed in $sql command
        $statement->bind_param("sssss", $username, $password, $salt, $email, $fullname);

        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Select user information
    public function selectUser($username) {

        $returArray = array();

        // sql command
        $sql = "SELECT * FROM users WHERE username='".$username."'";

        // assign result we got from $sql to $result var
        $result = $this->conn->query($sql);

        // if we have at least 1 result returned
        if ($result != null && (mysqli_num_rows($result) >= 1 )) {

            // assign results we got to $row as associative array
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if (!empty($row)) {
                $returArray = $row;
            }

        }

        return $returArray;

    }


    // Save email confiramtion message's token
    public function saveToken($table, $id, $token) {

        // sql statement
        $sql = "INSERT INTO $table SET id=?, token=?";

        // prepare statement to be executed
        $statement = $this->conn->prepare($sql);

        // error occured
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // bind paramateres to sql statement
        $statement->bind_param("is", $id, $token);

        // launch / execute and store feedback in $returnValue
        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Get ID of user via $emailToken he received via email's $_GET
    function getUserID($table, $token) {

        $returnArray = array();

        // sql statement
        $sql = "SELECT id FROM $table WHERE token = '".$token."'";

        // launch sql statement
        $result = $this->conn->query($sql);

        // if $result is not empty ant storing some content
        if ($result != null && (mysqli_num_rows($result) >= 1)) {

            // content from $result convert to assoc array and store in $row
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if (!empty($row)) {
                $returnArray = $row;
            }
        }

        return $returnArray;

    }


    // Change status of emailConfirmation column
    function emailConfirmationStatus($status, $id) {

        $sql = "UPDATE users SET emailConfirmed=? WHERE id=?";
        $statement = $this->conn->prepare($sql);

        if (!$statement) {
            throw new Exception($statement->error);
        }

        $statement->bind_param("ii", $status, $id);

        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Delete token once email is confirmed
    function deleteToken($table, $token) {

        $sql = "DELETE FROM $table WHERE token=?";
        $statement = $this->conn->prepare($sql);

        if (!$statement) {
            throw new Exception($statement->error);
        }

        $statement->bind_param("s", $token);

        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Get full user information
    public function getUser($username) {

        // declare array to store all information we got
        $returnArray = array();

        // sql statement
        $sql = "SELECT * FROM users WHERE username='".$username."'";

        // execute / query $sql
        $result = $this->conn->query($sql);

        // if we got some result
        if ($result != null && (mysqli_num_rows($result) >= 1)) {

            // assign result to $row as assoc array
            $row = $result->fetch_array(MYSQLI_ASSOC);

            // if assigned to $row. Assign everything $returnArray
            if (!empty($row)) {
                $returnArray = $row;
            }
        }

        return $returnArray;

    }


    // Select user information with Email
    public function selectUserViaEmail($email) {

        $returArray = array();

        // sql command
        $sql = "SELECT * FROM users WHERE email='".$email."'";

        // assign result we got from $sql to $result var
        $result = $this->conn->query($sql);

        // if we have at least 1 result returned
        if ($result != null && (mysqli_num_rows($result) >= 1 )) {

            // assign results we got to $row as associative array
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if (!empty($row)) {
                $returArray = $row;
            }

        }

        return $returArray;

    }


    // Updating password via link we got on via 'reset password email'
    public function updatePassword($id, $password, $salt) {

        $sql = "UPDATE users SET password=?, salt=? WHERE id=?";
        $statement = $this->conn->prepare($sql);

        if (!$statement) {
            throw new Exception($statement->error);
        }

        $statement->bind_param("ssi", $password, $salt, $id);

        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Saving ava path in db
    function updateAvaPath($path, $id) {

        // sql statement
        $sql = "UPDATE users SET ava=? WHERE id=?";

        // prepare to be executed
        $statement = $this->conn->prepare($sql);

        // error occured
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // bind parameters to sql statement
        $statement->bind_param("si", $path, $id);

        // assign execution result to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Select user information with Id
    public function selectUserViaID($id) {

        $returArray = array();

        // sql command
        $sql = "SELECT * FROM users WHERE id='".$id."'";

        // assign result we got from $sql to $result var
        $result = $this->conn->query($sql);

        // if we have at least 1 result returned
        if ($result != null && (mysqli_num_rows($result) >= 1 )) {

            // assign results we got to $row as associative array
            $row = $result->fetch_array(MYSQLI_ASSOC);

            if (!empty($row)) {
                $returArray = $row;
            }

        }

        return $returArray;

    }


    // Insert post in database
    public function insertPost($id, $uuid, $text, $path) {
        
        // sql statement
        $sql = "INSERT INTO posts SET id=?, uuid=?, text=?, path=?";
        
        // prepare sql to be executed
        $statement = $this->conn->prepare($sql);

        // error occured
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // binding param in place of "?"
        $statement->bind_param("isss", $id, $uuid, $text, $path);

        // execute statement and assign result of execution to $returnValue
        $returnValue = $statement->execute();

        return $returnValue;

    }


    // Select all posts + user information made by user with relevant $id
    public function selectPosts($id) {

        // declare array to store selected information
        $returnArray = array();

        // sql JOIN
        $sql = "SELECT posts.id,
		posts.uuid,
        posts.text,
        posts.path,
        posts.date,
        users.id,
        users.username,
        users.fullname,
        users.email,
        users.ava
        FROM Twitter.posts JOIN Twitter.users ON
        posts.id = $id AND users.id = $id ORDER by date DESC";

        // prepare to be executed
        $statement = $this->conn->prepare($sql);

        // error ocured
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // execute sql
        $statement->execute();

        // result we got in execution
        $result = $statement->get_result();

        // each time append to $returnArray new row one by one when it is found
        while ($row = $result->fetch_assoc()) {
            $returnArray[] = $row;
        }

        return $returnArray;

    }


    // Delete post according to passed uui
    public function deletePost($uuid) {

        // sql statement to be executed
        $sql = "DELETE FROM posts WHERE uuid = ?";

        // prepare to be executed after binded params in place of ?
        $statement = $this->conn->prepare($sql);

        // error occured while preparation or sql statement
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // bind param in place of ? and assign var
        $statement->bind_param("s", $uuid);
        $statement->execute();

        // assign numb of affected rows to $returnValue, to see did deleted or not
        $returnValue = $statement->affected_rows;

        return $returnValue;

    }


    // Search / Select user
    public function selectUsers($word, $username) {

        // var to store all returned inf from db
        $returnArray = array();

        // sql statement to be executed if not entered word
        $sql = "SELECT id, username, email, fullname, ava FROM users WHERE NOT username = '".$username."'";

        // if word entered alter sql statement for wider search
        if (!empty($word)) {
            $sql .= " AND ( username LIKE ? OR fullname LIKE ? )";
        }

        // prepare to be executed as soon as vars are binded
        $statement = $this->conn->prepare($sql);

        // error occured
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // if word entered bind params
        if (!empty($word)) {
            $word = '%' . $word . '%'; // %bob%
            $statement->bind_param("ss", $word, $word);
        }

        // execute statement
        $statement->execute();

        // assign returned results to $result var
        $result = $statement->get_result();

        // every time when we convert $result to assoc array append to $row
        while ($row = $result->fetch_assoc()) {

            // store all append $rows in $returnArray
            $returnArray[] = $row;
        }

        // feedback result
        return $returnArray;

    }


    // Update user function in our db via $id
    public function updateUser($username, $fullname, $email, $id) {

        // sql statement
        $sql = "UPDATE users SET username=?, fullname=?, email=? WHERE id=?";

        // prepare to be executed as soon as we bind param in place of '?'
        $statement = $this->conn->prepare($sql);

        // if error occured
        if (!$statement) {
            throw new Exception($statement->error);
        }

        // binding param in place of '?'
        $statement->bind_param("sssi", $username, $fullname, $email, $id);

        // assign execution result to $returnValue
        $returnValue = $statement->execute();
        
        return $returnValue;

    }



}


?>









