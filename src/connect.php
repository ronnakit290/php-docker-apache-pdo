<?php
$servername = "mysql";
$username = "mysql_user";
$password = "mysql_password";
$dbname = "testdb";

$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
