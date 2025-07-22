<?php
require_once 'connect.php';

// ฟังก์ชันสำหรับอ่านและรันไฟล์ SQL
function runSQLFile($conn, $filename) {
    if (!file_exists($filename)) {
        return "ไม่พบไฟล์ $filename";
    }
    
    $sql = file_get_contents($filename);
    
    // แยกคำสั่ง SQL ด้วย semicolon
    $statements = explode(';', $sql);
    
    $success_count = 0;
    $error_count = 0;
    $errors = [];
    
    foreach ($statements as $statement) {
        $statement = trim($statement);
        if (empty($statement) || substr($statement, 0, 2) === '--') {
            continue;
        }
        
        if ($conn->query($statement)) {
            $success_count++;
        } else {
            $error_count++;
            $errors[] = "Error: " . $conn->error . " in statement: " . substr($statement, 0, 100) . "...";
        }
    }
    
    return [
        'success' => $success_count,
        'errors' => $error_count,
        'error_details' => $errors
    ];
}

// ตรวจสอบว่ามีการส่งคำขอติดตั้งหรือไม่
$install_requested = isset($_POST['install']);
$install_result = null;

if ($install_requested) {
    // ลบฐานข้อมูลเก่า (ถ้ามี)
    $conn->query("DROP DATABASE IF EXISTS testdb");
    $conn->query("CREATE DATABASE testdb");
    $conn->select_db("testdb");
    
    // รันไฟล์สร้างตาราง
    $create_result = runSQLFile($conn, 'create_database.sql');
    
    // รันไฟล์ใส่ข้อมูลตัวอย่าง
    $data_result = runSQLFile($conn, 'sample_data.sql');
    
    $install_result = [
        'create' => $create_result,
        'data' => $data_result
    ];
}

// ตรวจสอบสถานะฐานข้อมูล
$database_exists = false;
$table_count = 0;
$herb_count = 0;

try {
    $result = $conn->query("SELECT COUNT(*) as count FROM information_schema.tables WHERE table_schema = 'testdb'");
    if ($result) {
        $row = $result->fetch_assoc();
        $table_count = $row['count'];
        $database_exists = $table_count > 0;
    }
    
    if ($database_exists) {
        $result = $conn->query("SELECT COUNT(*) as count FROM herbs");
        if ($result) {
            $row = $result->fetch_assoc();
            $herb_count = $row['count'];
        }
    }
} catch (Exception $e) {
    // ฐานข้อมูลยังไม่มี
}
?>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ติดตั้งฐานข้อมูลสมุนไพรตำบลบ้านดู่</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        body {
            font-family: 'Sarabun', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
        }
        .main-container {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.1);
            margin: 20px auto;
            padding: 30px;
            max-width: 800px;
        }
        .header {
            background: linear-gradient(45deg, #2E8B57, #228B22);
            color: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 30px;
        }
        .status-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .btn-install {
            background: linear-gradient(45deg, #FF6B6B, #FF8E53);
            border: none;
            border-radius: 50px;
            padding: 15px 40px;
            color: white;
            font-weight: bold;
            font-size: 1.1em;
        }
        .btn-view {
            background: linear-gradient(45deg, #4ECDC4, #44A08D);
            border: none;
            border-radius: 50px;
            padding: 15px 40px;
            color: white;
            font-weight: bold;
            font-size: 1.1em;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="main-container">
            <div class="header">
                <h1><i class="fas fa-database"></i> ติดตั้งฐานข้อมูลสมุนไพรตำบลบ้านดู่</h1>
                <p class="mb-0">ระบบจัดการฐานข้อมูลสมุนไพรแบบ 5NF</p>
            </div>

            <!-- สถานะฐานข้อมูล -->
            <div class="status-card card">
                <div class="card-header bg-info text-white">
                    <h5><i class="fas fa-info-circle"></i> สถานะฐานข้อมูล</h5>
                </div>
                <div class="card-body">
                    <?php if ($database_exists): ?>
                        <div class="alert alert-success" role="alert">
                            <i class="fas fa-check-circle"></i> 
                            <strong>ฐานข้อมูลพร้อมใช้งาน!</strong><br>
                            จำนวนตาราง: <?= $table_count ?> ตาราง<br>
                            จำนวนสมุนไพร: <?= $herb_count ?> รายการ
                        </div>
                        <div class="text-center">
                            <a href="index.php" class="btn btn-view me-3">
                                <i class="fas fa-eye"></i> ดูฐานข้อมูลสมุนไพร
                            </a>
                            <button type="button" class="btn btn-warning" data-bs-toggle="modal" data-bs-target="#reinstallModal">
                                <i class="fas fa-redo"></i> ติดตั้งใหม่
                            </button>
                        </div>
                    <?php else: ?>
                        <div class="alert alert-warning" role="alert">
                            <i class="fas fa-exclamation-triangle"></i> 
                            <strong>ฐานข้อมูลยังไม่ได้ติดตั้ง</strong><br>
                            กรุณาคลิกปุ่มด้านล่างเพื่อติดตั้งฐานข้อมูล
                        </div>
                        <div class="text-center">
                            <form method="POST">
                                <button type="submit" name="install" class="btn btn-install">
                                    <i class="fas fa-download"></i> ติดตั้งฐานข้อมูล
                                </button>
                            </form>
                        </div>
                    <?php endif; ?>
                </div>
            </div>

            <!-- ผลการติดตั้ง -->
            <?php if ($install_result): ?>
            <div class="status-card card">
                <div class="card-header bg-success text-white">
                    <h5><i class="fas fa-cogs"></i> ผลการติดตั้ง</h5>
                </div>
                <div class="card-body">
                    <div class="row">
                        <div class="col-md-6">
                            <h6>การสร้างตาราง:</h6>
                            <p class="text-success">สำเร็จ: <?= $install_result['create']['success'] ?> คำสั่ง</p>
                            <?php if ($install_result['create']['errors'] > 0): ?>
                            <p class="text-danger">ข้อผิดพลาด: <?= $install_result['create']['errors'] ?> คำสั่ง</p>
                            <?php endif; ?>
                        </div>
                        <div class="col-md-6">
                            <h6>การใส่ข้อมูล:</h6>
                            <p class="text-success">สำเร็จ: <?= $install_result['data']['success'] ?> คำสั่ง</p>
                            <?php if ($install_result['data']['errors'] > 0): ?>
                            <p class="text-danger">ข้อผิดพลาด: <?= $install_result['data']['errors'] ?> คำสั่ง</p>
                            <?php endif; ?>
                        </div>
                    </div>
                    
                    <?php if ($install_result['create']['errors'] > 0 || $install_result['data']['errors'] > 0): ?>
                    <div class="mt-3">
                        <button class="btn btn-outline-danger" type="button" data-bs-toggle="collapse" data-bs-target="#errorDetails">
                            <i class="fas fa-exclamation-circle"></i> ดูรายละเอียดข้อผิดพลาด
                        </button>
                        <div class="collapse mt-3" id="errorDetails">
                            <?php foreach (array_merge($install_result['create']['error_details'], $install_result['data']['error_details']) as $error): ?>
                            <div class="alert alert-danger"><?= htmlspecialchars($error) ?></div>
                            <?php endforeach; ?>
                        </div>
                    </div>
                    <?php endif; ?>
                    
                    <div class="text-center mt-3">
                        <a href="index.php" class="btn btn-view">
                            <i class="fas fa-eye"></i> ดูฐานข้อมูลสมุนไพร
                        </a>
                    </div>
                </div>
            </div>
            <?php endif; ?>

            <!-- ข้อมูลเกี่ยวกับฐานข้อมูล -->
            <div class="status-card card">
                <div class="card-header bg-primary text-white">
                    <h5><i class="fas fa-info"></i> เกี่ยวกับฐานข้อมูล</h5>
                </div>
                <div class="card-body">
                    <h6>โครงสร้างฐานข้อมูลแบบ 5NF (Fifth Normal Form):</h6>
                    <ul>
                        <li><strong>ตารางหลัก:</strong> สมุนไพร, สรรพคุณ, อาการ, วิธีการใช้, ผู้รู้, สถานที่, ฤดูกาล</li>
                        <li><strong>ตารางความสัมพันธ์:</strong> เชื่อมโยงข้อมูลระหว่างตารางต่างๆ</li>
                        <li><strong>ข้อมูลตัวอย่าง:</strong> สมุนไพร 10 ชนิด พร้อมข้อมูลครบถ้วน</li>
                        <li><strong>ฟีเจอร์:</strong> ค้นหา, ดูรายละเอียด, ข้อมูลผู้รู้และสถานที่</li>
                    </ul>
                    
                    <h6 class="mt-3">ไฟล์ที่เกี่ยวข้อง:</h6>
                    <ul>
                        <li><code>create_database.sql</code> - สคริปต์สร้างตาราง</li>
                        <li><code>sample_data.sql</code> - ข้อมูลตัวอย่าง</li>
                        <li><code>index.php</code> - หน้าแสดงผลหลัก</li>
                        <li><code>connect.php</code> - การเชื่อมต่อฐานข้อมูล</li>
                    </ul>
                </div>
            </div>
        </div>
    </div>

    <!-- Modal สำหรับยืนยันการติดตั้งใหม่ -->
    <div class="modal fade" id="reinstallModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title"><i class="fas fa-exclamation-triangle text-warning"></i> ยืนยันการติดตั้งใหม่</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <p>การติดตั้งใหม่จะลบข้อมูลทั้งหมดในฐานข้อมูลปัจจุบัน</p>
                    <p><strong>คุณแน่ใจหรือไม่ที่จะดำเนินการต่อ?</strong></p>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">ยกเลิก</button>
                    <form method="POST" class="d-inline">
                        <button type="submit" name="install" class="btn btn-danger">
                            <i class="fas fa-redo"></i> ติดตั้งใหม่
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<?php
$conn->close();
?>