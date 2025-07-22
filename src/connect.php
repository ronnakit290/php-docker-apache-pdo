<?php
$servername = "mysql-db";   // หรือใช้ "mysql" ถ้าชื่อ container คือ mysql
$username = "user";
$password = "password";
$dbname = "testdb";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
