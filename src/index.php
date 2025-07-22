<?php
// PHP with PDO Demo
echo "<h1>PHP with PDO Support</h1>";

// Check if PDO is available
if (extension_loaded('pdo')) {
    echo "<p style='color: green;'>✓ PDO extension is loaded</p>";
    
    // List available PDO drivers
    $drivers = PDO::getAvailableDrivers();
    echo "<h2>Available PDO Drivers:</h2>";
    echo "<ul>";
    foreach ($drivers as $driver) {
        echo "<li>" . $driver . "</li>";
    }
    echo "</ul>";
} else {
    echo "<p style='color: red;'>✗ PDO extension is not loaded</p>";
}

// Display PHP info
echo "<h2>PHP Version: " . phpversion() . "</h2>";

// Example PDO connection to MySQL
echo "<h2>MySQL Database Connection Test</h2>";
try {
    $pdo = new PDO('mysql:host=mysql;dbname=testdb', 'testuser', 'testpass');
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "<p style='color: green;'>✓ MySQL database connection successful!</p>";
    
    // Test query
    $stmt = $pdo->query('SELECT VERSION() as version');
    $result = $stmt->fetch(PDO::FETCH_ASSOC);
    echo "<p>MySQL Version: " . $result['version'] . "</p>";
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>✗ Connection failed: " . $e->getMessage() . "</p>";
}

echo "<hr>";
echo "<h2>Database Management</h2>";
echo "<p><strong>phpMyAdmin:</strong> <a href='http://localhost:8081' target='_blank'>http://localhost:8081</a></p>";
echo "<p><strong>MySQL Credentials:</strong></p>";
echo "<ul>";
echo "<li>Host: mysql (or localhost:3306 from host machine)</li>";
echo "<li>Database: testdb</li>";
echo "<li>Username: testuser</li>";
echo "<li>Password: testpass</li>";
echo "<li>Root Password: rootpassword</li>";
echo "</ul>";
echo "<hr>";
echo "<p>This is served from the ./src directory mapped to Apache's htdocs.</p>";
?>