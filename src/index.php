<?php
require_once 'connect.php';
//
// ฟังก์ชันสำหรับดึงข้อมูลสมุนไพรทั้งหมด
function getAllHerbs($conn) {
    $sql = "SELECT h.*, GROUP_CONCAT(DISTINCT p.property_name SEPARATOR ', ') as properties,
                   GROUP_CONCAT(DISTINCT s.symptom_name SEPARATOR ', ') as symptoms
            FROM herbs h
            LEFT JOIN herb_properties hp ON h.herb_id = hp.herb_id
            LEFT JOIN properties p ON hp.property_id = p.property_id
            LEFT JOIN herb_symptoms hs ON h.herb_id = hs.herb_id
            LEFT JOIN symptoms s ON hs.symptom_id = s.symptom_id
            GROUP BY h.herb_id
            ORDER BY h.herb_name";
    
    $result = $conn->query($sql);
    return $result->fetch_all(MYSQLI_ASSOC);
}

// ฟังก์ชันค้นหาสมุนไพร
function searchHerbs($conn, $search_term) {
    $search_term = "%" . $search_term . "%";
    $sql = "SELECT DISTINCT h.*, GROUP_CONCAT(DISTINCT p.property_name SEPARATOR ', ') as properties,
                   GROUP_CONCAT(DISTINCT s.symptom_name SEPARATOR ', ') as symptoms
            FROM herbs h
            LEFT JOIN herb_properties hp ON h.herb_id = hp.herb_id
            LEFT JOIN properties p ON hp.property_id = p.property_id
            LEFT JOIN herb_symptoms hs ON h.herb_id = hs.herb_id
            LEFT JOIN symptoms s ON hs.symptom_id = s.symptom_id
            WHERE h.herb_name LIKE ? OR h.scientific_name LIKE ? OR h.description LIKE ?
               OR p.property_name LIKE ? OR s.symptom_name LIKE ?
            GROUP BY h.herb_id
            ORDER BY h.herb_name";
    
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("sssss", $search_term, $search_term, $search_term, $search_term, $search_term);
    $stmt->execute();
    $result = $stmt->get_result();
    return $result->fetch_all(MYSQLI_ASSOC);
}

// ฟังก์ชันดึงรายละเอียดสมุนไพร
function getHerbDetails($conn, $herb_id) {
    // ข้อมูลพื้นฐานของสมุนไพร
    $sql = "SELECT * FROM herbs WHERE herb_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $herb_id);
    $stmt->execute();
    $herb = $stmt->get_result()->fetch_assoc();
    
    if (!$herb) return null;
    
    // สรรพคุณ
    $sql = "SELECT p.property_name, p.property_description, hp.effectiveness_level, hp.notes
            FROM herb_properties hp
            JOIN properties p ON hp.property_id = p.property_id
            WHERE hp.herb_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $herb_id);
    $stmt->execute();
    $herb['properties'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // อาการที่รักษาได้
    $sql = "SELECT s.symptom_name, s.symptom_description, hs.effectiveness_level, hs.dosage, hs.precautions
            FROM herb_symptoms hs
            JOIN symptoms s ON hs.symptom_id = s.symptom_id
            WHERE hs.herb_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $herb_id);
    $stmt->execute();
    $herb['symptoms'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // วิธีการใช้
    $sql = "SELECT m.method_name, m.method_description, hum.dosage, hum.frequency, hum.duration
            FROM herb_usage_methods hum
            JOIN usage_methods m ON hum.method_id = m.method_id
            WHERE hum.herb_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $herb_id);
    $stmt->execute();
    $herb['usage_methods'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // สถานที่พบ
    $sql = "SELECT l.location_name, l.location_type, hl.abundance, hl.harvest_notes
            FROM herb_locations hl
            JOIN locations l ON hl.location_id = l.location_id
            WHERE hl.herb_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $herb_id);
    $stmt->execute();
    $herb['locations'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    // ผู้รู้
    $sql = "SELECT h.healer_name, h.phone, h.specialization, hhk.knowledge_level, hhk.special_techniques
            FROM healer_herb_knowledge hhk
            JOIN healers h ON hhk.healer_id = h.healer_id
            WHERE hhk.herb_id = ?";
    $stmt = $conn->prepare($sql);
    $stmt->bind_param("i", $herb_id);
    $stmt->execute();
    $herb['healers'] = $stmt->get_result()->fetch_all(MYSQLI_ASSOC);
    
    return $herb;
}

// จัดการการค้นหา
$search_term = isset($_GET['search']) ? trim($_GET['search']) : '';
$herb_id = isset($_GET['herb_id']) ? (int)$_GET['herb_id'] : 0;

if ($herb_id > 0) {
    $herb_detail = getHerbDetails($conn, $herb_id);
} else {
    $herbs = $search_term ? searchHerbs($conn, $search_term) : getAllHerbs($conn);
}
?>

<!DOCTYPE html>
<html lang="th">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ฐานข้อมูลสมุนไพรตำบลบ้านดู่</title>
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
        }
        .header {
            background: linear-gradient(45deg, #2E8B57, #228B22);
            color: white;
            padding: 30px;
            border-radius: 15px;
            text-align: center;
            margin-bottom: 30px;
        }
        .herb-card {
            border: none;
            border-radius: 15px;
            box-shadow: 0 8px 25px rgba(0,0,0,0.1);
            transition: transform 0.3s ease, box-shadow 0.3s ease;
            margin-bottom: 20px;
            overflow: hidden;
        }
        .herb-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 15px 35px rgba(0,0,0,0.15);
        }
        .herb-card-header {
            background: linear-gradient(45deg, #4CAF50, #45a049);
            color: white;
            padding: 20px;
            border-bottom: none;
        }
        .search-box {
            background: white;
            border-radius: 50px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.1);
            border: none;
            padding: 15px 25px;
        }
        .btn-search {
            background: linear-gradient(45deg, #FF6B6B, #FF8E53);
            border: none;
            border-radius: 50px;
            padding: 12px 30px;
            color: white;
            font-weight: bold;
        }
        .btn-detail {
            background: linear-gradient(45deg, #4ECDC4, #44A08D);
            border: none;
            border-radius: 25px;
            color: white;
            padding: 8px 20px;
        }
        .badge-custom {
            background: linear-gradient(45deg, #667eea, #764ba2);
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.8em;
            margin: 2px;
        }
        .detail-section {
            background: #f8f9fa;
            border-radius: 10px;
            padding: 20px;
            margin-bottom: 20px;
        }
        .section-title {
            color: #2E8B57;
            border-bottom: 2px solid #2E8B57;
            padding-bottom: 10px;
            margin-bottom: 15px;
        }
    </style>
</head>
<body>
    <div class="container-fluid">
        <div class="main-container">
            <div class="header">
                <h1><i class="fas fa-leaf"></i> ฐานข้อมูลสมุนไพรตำบลบ้านดู่</h1>
                <p class="mb-0">ภูมิปัญญาท้องถิ่นเพื่อสุขภาพที่ยั่งยืน</p>
            </div>

            <?php if ($herb_id > 0 && $herb_detail): ?>
                <!-- แสดงรายละเอียดสมุนไพร -->
                <div class="mb-3">
                    <a href="index.php" class="btn btn-secondary">
                        <i class="fas fa-arrow-left"></i> กลับหน้าหลัก
                    </a>
                </div>
                
                <div class="row">
                    <div class="col-12">
                        <div class="herb-card">
                            <div class="herb-card-header">
                                <h2><i class="fas fa-seedling"></i> <?= htmlspecialchars($herb_detail['herb_name']) ?></h2>
                                <p class="mb-0"><em><?= htmlspecialchars($herb_detail['scientific_name']) ?></em></p>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-6">
                                        <p><strong>ประเภท:</strong> <span class="badge badge-custom"><?= htmlspecialchars($herb_detail['herb_type']) ?></span></p>
                                        <p><strong>คำอธิบาย:</strong> <?= htmlspecialchars($herb_detail['description']) ?></p>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- สรรพคุณ -->
                <?php if (!empty($herb_detail['properties'])): ?>
                <div class="detail-section">
                    <h3 class="section-title"><i class="fas fa-star"></i> สรรพคุณ</h3>
                    <div class="row">
                        <?php foreach ($herb_detail['properties'] as $property): ?>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title text-success"><?= htmlspecialchars($property['property_name']) ?></h5>
                                    <p class="card-text"><?= htmlspecialchars($property['property_description']) ?></p>
                                    <span class="badge bg-info">ประสิทธิภาพ: <?= htmlspecialchars($property['effectiveness_level']) ?></span>
                                    <?php if ($property['notes']): ?>
                                    <p class="mt-2 text-muted"><small><?= htmlspecialchars($property['notes']) ?></small></p>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

                <!-- อาการที่รักษาได้ -->
                <?php if (!empty($herb_detail['symptoms'])): ?>
                <div class="detail-section">
                    <h3 class="section-title"><i class="fas fa-heartbeat"></i> อาการที่รักษาได้</h3>
                    <div class="row">
                        <?php foreach ($herb_detail['symptoms'] as $symptom): ?>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title text-danger"><?= htmlspecialchars($symptom['symptom_name']) ?></h5>
                                    <p class="card-text"><?= htmlspecialchars($symptom['symptom_description']) ?></p>
                                    <p><strong>ขนาดการใช้:</strong> <?= htmlspecialchars($symptom['dosage']) ?></p>
                                    <span class="badge bg-warning">ประสิทธิภาพ: <?= htmlspecialchars($symptom['effectiveness_level']) ?></span>
                                    <?php if ($symptom['precautions']): ?>
                                    <div class="alert alert-warning mt-2" role="alert">
                                        <small><strong>ข้อควรระวัง:</strong> <?= htmlspecialchars($symptom['precautions']) ?></small>
                                    </div>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

                <!-- วิธีการใช้ -->
                <?php if (!empty($herb_detail['usage_methods'])): ?>
                <div class="detail-section">
                    <h3 class="section-title"><i class="fas fa-prescription-bottle"></i> วิธีการใช้</h3>
                    <div class="row">
                        <?php foreach ($herb_detail['usage_methods'] as $method): ?>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title text-primary"><?= htmlspecialchars($method['method_name']) ?></h5>
                                    <p class="card-text"><?= htmlspecialchars($method['method_description']) ?></p>
                                    <ul class="list-unstyled">
                                        <li><strong>ขนาด:</strong> <?= htmlspecialchars($method['dosage']) ?></li>
                                        <li><strong>ความถี่:</strong> <?= htmlspecialchars($method['frequency']) ?></li>
                                        <li><strong>ระยะเวลา:</strong> <?= htmlspecialchars($method['duration']) ?></li>
                                    </ul>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

                <!-- สถานที่พบ -->
                <?php if (!empty($herb_detail['locations'])): ?>
                <div class="detail-section">
                    <h3 class="section-title"><i class="fas fa-map-marker-alt"></i> สถานที่พบ</h3>
                    <div class="row">
                        <?php foreach ($herb_detail['locations'] as $location): ?>
                        <div class="col-md-4 mb-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title text-info"><?= htmlspecialchars($location['location_name']) ?></h5>
                                    <p><span class="badge bg-secondary"><?= htmlspecialchars($location['location_type']) ?></span></p>
                                    <p><strong>ความอุดมสมบูรณ์:</strong> <span class="badge bg-success"><?= htmlspecialchars($location['abundance']) ?></span></p>
                                    <?php if ($location['harvest_notes']): ?>
                                    <p class="text-muted"><small><?= htmlspecialchars($location['harvest_notes']) ?></small></p>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

                <!-- ผู้รู้ -->
                <?php if (!empty($herb_detail['healers'])): ?>
                <div class="detail-section">
                    <h3 class="section-title"><i class="fas fa-user-md"></i> ผู้รู้/หมอพื้นบ้าน</h3>
                    <div class="row">
                        <?php foreach ($herb_detail['healers'] as $healer): ?>
                        <div class="col-md-6 mb-3">
                            <div class="card h-100">
                                <div class="card-body">
                                    <h5 class="card-title text-success"><?= htmlspecialchars($healer['healer_name']) ?></h5>
                                    <p><strong>โทรศัพท์:</strong> <?= htmlspecialchars($healer['phone']) ?></p>
                                    <p><strong>ความเชี่ยวชาญ:</strong> <?= htmlspecialchars($healer['specialization']) ?></p>
                                    <p><strong>ระดับความรู้:</strong> <span class="badge bg-primary"><?= htmlspecialchars($healer['knowledge_level']) ?></span></p>
                                    <?php if ($healer['special_techniques']): ?>
                                    <p class="text-muted"><small><strong>เทคนิคพิเศษ:</strong> <?= htmlspecialchars($healer['special_techniques']) ?></small></p>
                                    <?php endif; ?>
                                </div>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

            <?php else: ?>
                <!-- หน้าหลัก - แสดงรายการสมุนไพร -->
                <div class="row mb-4">
                    <div class="col-12">
                        <form method="GET" class="d-flex gap-3">
                            <input type="text" name="search" class="form-control search-box" 
                                   placeholder="ค้นหาสมุนไพร อาการ หรือสรรพคุณ..." 
                                   value="<?= htmlspecialchars($search_term) ?>">
                            <button type="submit" class="btn btn-search">
                                <i class="fas fa-search"></i> ค้นหา
                            </button>
                            <?php if ($search_term): ?>
                            <a href="index.php" class="btn btn-outline-secondary">
                                <i class="fas fa-times"></i> ล้าง
                            </a>
                            <?php endif; ?>
                        </form>
                    </div>
                </div>

                <?php if ($search_term): ?>
                <div class="alert alert-info">
                    <i class="fas fa-info-circle"></i> ผลการค้นหา "<?= htmlspecialchars($search_term) ?>" พบ <?= count($herbs) ?> รายการ
                </div>
                <?php endif; ?>

                <div class="row">
                    <?php foreach ($herbs as $herb): ?>
                    <div class="col-lg-6 col-xl-4">
                        <div class="herb-card">
                            <div class="herb-card-header">
                                <h5 class="mb-1"><?= htmlspecialchars($herb['herb_name']) ?></h5>
                                <small><em><?= htmlspecialchars($herb['scientific_name']) ?></em></small>
                            </div>
                            <div class="card-body">
                                <p class="card-text"><?= htmlspecialchars(substr($herb['description'], 0, 100)) ?>...</p>
                                
                                <div class="mb-2">
                                    <span class="badge badge-custom"><?= htmlspecialchars($herb['herb_type']) ?></span>
                                </div>
                                
                                <?php if ($herb['properties']): ?>
                                <div class="mb-2">
                                    <small class="text-muted"><strong>สรรพคุณ:</strong></small><br>
                                    <?php 
                                    $properties = explode(', ', $herb['properties']);
                                    foreach (array_slice($properties, 0, 3) as $prop): 
                                    ?>
                                    <span class="badge bg-success"><?= htmlspecialchars($prop) ?></span>
                                    <?php endforeach; ?>
                                    <?php if (count($properties) > 3): ?>
                                    <span class="badge bg-secondary">+<?= count($properties) - 3 ?> อื่นๆ</span>
                                    <?php endif; ?>
                                </div>
                                <?php endif; ?>
                                
                                <?php if ($herb['symptoms']): ?>
                                <div class="mb-3">
                                    <small class="text-muted"><strong>รักษาอาการ:</strong></small><br>
                                    <?php 
                                    $symptoms = explode(', ', $herb['symptoms']);
                                    foreach (array_slice($symptoms, 0, 2) as $symptom): 
                                    ?>
                                    <span class="badge bg-warning text-dark"><?= htmlspecialchars($symptom) ?></span>
                                    <?php endforeach; ?>
                                    <?php if (count($symptoms) > 2): ?>
                                    <span class="badge bg-secondary">+<?= count($symptoms) - 2 ?> อื่นๆ</span>
                                    <?php endif; ?>
                                </div>
                                <?php endif; ?>
                                
                                <a href="?herb_id=<?= $herb['herb_id'] ?>" class="btn btn-detail">
                                    <i class="fas fa-eye"></i> ดูรายละเอียด
                                </a>
                            </div>
                        </div>
                    </div>
                    <?php endforeach; ?>
                </div>

                <?php if (empty($herbs)): ?>
                <div class="text-center py-5">
                    <i class="fas fa-search fa-3x text-muted mb-3"></i>
                    <h4 class="text-muted">ไม่พบข้อมูลสมุนไพร</h4>
                    <p class="text-muted">ลองค้นหาด้วยคำอื่น หรือ <a href="index.php">ดูทั้งหมด</a></p>
                </div>
                <?php endif; ?>
            <?php endif; ?>

            <footer class="text-center mt-5 pt-4 border-top">
                <p class="text-muted">
                    <i class="fas fa-leaf text-success"></i> 
                    ฐานข้อมูลสมุนไพรตำบลบ้านดู่ - ภูมิปัญญาท้องถิ่นเพื่อสุขภาพที่ยั่งยืน
                </p>
                <small class="text-muted">ข้อมูลนี้เป็นภูมิปัญญาท้องถิ่น ควรปรึกษาแพทย์ก่อนใช้รักษา</small>
            </footer>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<?php
$conn->close();
?>