-- สร้างฐานข้อมูลสมุนไพรในตำบลบ้านดู่ที่เป็น 5NF (Fifth Normal Form)

-- ตาราง 1: ข้อมูลสมุนไพร (Herbs)
CREATE TABLE herbs (
    herb_id INT PRIMARY KEY AUTO_INCREMENT,
    herb_name VARCHAR(100) NOT NULL UNIQUE,
    scientific_name VARCHAR(150),
    herb_type ENUM('ใบ', 'ราก', 'เปลือก', 'ดอก', 'ผล', 'เมล็ด', 'ทั้งต้น') NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 2: ข้อมูลสรรพคุณ (Properties)
CREATE TABLE properties (
    property_id INT PRIMARY KEY AUTO_INCREMENT,
    property_name VARCHAR(100) NOT NULL UNIQUE,
    property_description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 3: ข้อมูลโรค/อาการ (Symptoms)
CREATE TABLE symptoms (
    symptom_id INT PRIMARY KEY AUTO_INCREMENT,
    symptom_name VARCHAR(100) NOT NULL UNIQUE,
    symptom_description TEXT,
    severity_level ENUM('เบา', 'ปานกลาง', 'รุนแรง'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 4: ข้อมูลวิธีการใช้ (Usage Methods)
CREATE TABLE usage_methods (
    method_id INT PRIMARY KEY AUTO_INCREMENT,
    method_name VARCHAR(100) NOT NULL UNIQUE,
    method_description TEXT,
    preparation_time INT, -- เวลาในการเตรียม (นาที)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 5: ข้อมูลผู้รู้/หมอพื้นบ้าน (Local Healers)
CREATE TABLE healers (
    healer_id INT PRIMARY KEY AUTO_INCREMENT,
    healer_name VARCHAR(100) NOT NULL,
    age INT,
    experience_years INT,
    phone VARCHAR(20),
    address TEXT,
    specialization TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 6: ข้อมูลสถานที่เก็บ/ปลูก (Locations)
CREATE TABLE locations (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(100) NOT NULL,
    location_type ENUM('ป่า', 'สวน', 'บ้าน', 'ไร่', 'นา', 'ริมน้ำ', 'ภูเขา') NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    accessibility ENUM('ง่าย', 'ปานกลาง', 'ยาก'),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 7: ข้อมูลฤดูกาล (Seasons)
CREATE TABLE seasons (
    season_id INT PRIMARY KEY AUTO_INCREMENT,
    season_name ENUM('ฤดูฝน', 'ฤดูหนาว', 'ฤดูร้อน') NOT NULL UNIQUE,
    start_month INT NOT NULL,
    end_month INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตารางความสัมพันธ์ 1: สมุนไพร-สรรพคุณ (Herb-Property Relationship)
CREATE TABLE herb_properties (
    herb_id INT,
    property_id INT,
    effectiveness_level ENUM('น้อย', 'ปานกลาง', 'มาก', 'มากที่สุด') DEFAULT 'ปานกลาง',
    notes TEXT,
    PRIMARY KEY (herb_id, property_id),
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE
);

-- ตารางความสัมพันธ์ 2: สมุนไพร-อาการ (Herb-Symptom Relationship)
CREATE TABLE herb_symptoms (
    herb_id INT,
    symptom_id INT,
    effectiveness_level ENUM('น้อย', 'ปานกลาง', 'มาก', 'มากที่สุด') DEFAULT 'ปานกลาง',
    dosage VARCHAR(100),
    precautions TEXT,
    PRIMARY KEY (herb_id, symptom_id),
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE,
    FOREIGN KEY (symptom_id) REFERENCES symptoms(symptom_id) ON DELETE CASCADE
);

-- ตารางความสัมพันธ์ 3: สมุนไพร-วิธีการใช้ (Herb-Usage Method Relationship)
CREATE TABLE herb_usage_methods (
    herb_id INT,
    method_id INT,
    dosage VARCHAR(100),
    frequency VARCHAR(50),
    duration VARCHAR(50),
    PRIMARY KEY (herb_id, method_id),
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE,
    FOREIGN KEY (method_id) REFERENCES usage_methods(method_id) ON DELETE CASCADE
);

-- ตารางความสัมพันธ์ 4: สมุนไพร-สถานที่ (Herb-Location Relationship)
CREATE TABLE herb_locations (
    herb_id INT,
    location_id INT,
    abundance ENUM('น้อย', 'ปานกลาง', 'มาก', 'มากมาย') DEFAULT 'ปานกลาง',
    harvest_notes TEXT,
    PRIMARY KEY (herb_id, location_id),
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

-- ตารางความสัมพันธ์ 5: สมุนไพร-ฤดูกาล (Herb-Season Relationship)
CREATE TABLE herb_seasons (
    herb_id INT,
    season_id INT,
    harvest_quality ENUM('ดีมาก', 'ดี', 'ปานกลาง', 'พอใช้') DEFAULT 'ดี',
    notes TEXT,
    PRIMARY KEY (herb_id, season_id),
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE,
    FOREIGN KEY (season_id) REFERENCES seasons(season_id) ON DELETE CASCADE
);

-- ตารางความสัมพันธ์ 6: ผู้รู้-สมุนไพร (Healer-Herb Knowledge)
CREATE TABLE healer_herb_knowledge (
    healer_id INT,
    herb_id INT,
    knowledge_level ENUM('เบื้องต้น', 'ปานกลาง', 'ดี', 'เชี่ยวชาญ') DEFAULT 'ปานกลาง',
    years_of_use INT,
    special_techniques TEXT,
    PRIMARY KEY (healer_id, herb_id),
    FOREIGN KEY (healer_id) REFERENCES healers(healer_id) ON DELETE CASCADE,
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE
);

-- ตารางความสัมพันธ์ 7: สรรพคุณ-อาการ-วิธีการใช้ (Property-Symptom-Method Relationship)
-- ตารางนี้แสดงความสัมพันธ์ 3 ทาง ซึ่งเป็นลักษณะของ 5NF
CREATE TABLE property_symptom_methods (
    property_id INT,
    symptom_id INT,
    method_id INT,
    effectiveness_rating DECIMAL(3,2) CHECK (effectiveness_rating >= 0 AND effectiveness_rating <= 10),
    research_notes TEXT,
    PRIMARY KEY (property_id, symptom_id, method_id),
    FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE,
    FOREIGN KEY (symptom_id) REFERENCES symptoms(symptom_id) ON DELETE CASCADE,
    FOREIGN KEY (method_id) REFERENCES usage_methods(method_id) ON DELETE CASCADE
);

-- สร้าง Index เพื่อเพิ่มประสิทธิภาพการค้นหา
CREATE INDEX idx_herb_name ON herbs(herb_name);
CREATE INDEX idx_scientific_name ON herbs(scientific_name);
CREATE INDEX idx_property_name ON properties(property_name);
CREATE INDEX idx_symptom_name ON symptoms(symptom_name);
CREATE INDEX idx_healer_name ON healers(healer_name);
CREATE INDEX idx_location_type ON locations(location_type);
CREATE INDEX idx_effectiveness ON herb_properties(effectiveness_level);
CREATE INDEX idx_abundance ON herb_locations(abundance);