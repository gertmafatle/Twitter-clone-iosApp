 <?php

class email {


    // Generate unique token for user when he got confirmation email message
    function generateToken($length) {

        // some characters
        $characters = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890";

        // get length of characters string
        $charactersLength= strlen($characters);

        $token = '';

        // generate random char from $characters every time until it is less than $charactersLength
        for ($i = 0; $i < $length; $i++) {
            $token .= $characters[rand(0, $charactersLength-1)];
        }

        return $token;

    }


    // Open confirmation template user gonna receive
    function confirmationTemplate() {

        // open file
        $file = fopen("templates/confirmationTemplate.html", "r") or die("Unable to open file");

        // store content of file in $template var
        $template = fread($file, filesize("templates/confirmationTemplate.html"));

        fclose($file);

        return $template;

    }


    // Open confirmation template user gonna receive
    function resetPasswordTemplate() {

        // open file
        $file = fopen("templates/resetPasswordTemplate.html", "r") or die("Unable to open file");

        // store content of file in $template var
        $template = fread($file, filesize("templates/resetPasswordTemplate.html"));

        fclose($file);

        return $template;

    }


    // Send email with php
    function sendEmail($details) {

        // information of email
        $subject = $details["subject"];
        $to = $details["to"];
        $fromName = $details["fromName"];
        $fromEmail = $details["fromEmail"];
        $body = $details["body"];

        // header required by some of smtp or mail sites
        $headers = "MIME-Version: 1.0" . "\r\n";
        $headers .= "Content-type:text/html;content=UTF-8" . "\r\n";
        $headers .= "From: " . $fromName . " <" . $fromEmail . ">" . "\r\n"; // From Akhmed Idigov <akhmed@gmail.com>

        // php func to send email finaly
        mail($to, $subject, $body, $headers);

    }


}



?>