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

-- สร้างฐานข้อมูลตระกูลสมุนไพร (Herb Families)

-- ตาราง 1: ข้อมูลตระกูลสมุนไพร (Herb Families)
CREATE TABLE herb_families (
    family_id INT PRIMARY KEY AUTO_INCREMENT,
    family_name VARCHAR(100) NOT NULL UNIQUE,
    family_scientific_name VARCHAR(150) NOT NULL UNIQUE,
    family_description TEXT,
    common_characteristics TEXT,
    medicinal_value TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ตาราง 2: ความสัมพันธ์ระหว่างสมุนไพรกับตระกูล (Herb-Family Relationship)
CREATE TABLE herb_family_relationships (
    herb_id INT,
    family_id INT,
    relationship_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (herb_id, family_id),
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE,
    FOREIGN KEY (family_id) REFERENCES herb_families(family_id) ON DELETE CASCADE
);

-- ตาราง 3: ข้อมูลหลักฐานทางวิทยาศาสตร์ของตระกูลสมุนไพร (Scientific Evidence for Herb Families)
CREATE TABLE family_scientific_evidence (
    evidence_id INT PRIMARY KEY AUTO_INCREMENT,
    family_id INT,
    research_title VARCHAR(255) NOT NULL,
    researchers VARCHAR(255),
    publication_year YEAR,
    journal_name VARCHAR(255),
    research_findings TEXT,
    evidence_strength ENUM('น้อย', 'ปานกลาง', 'มาก', 'มากที่สุด') DEFAULT 'ปานกลาง',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (family_id) REFERENCES herb_families(family_id) ON DELETE CASCADE
);

-- ตาราง 4: ความสัมพันธ์ระหว่างตระกูลสมุนไพรกับสรรพคุณหลัก (Family-Property Relationship)
CREATE TABLE family_properties (
    family_id INT,
    property_id INT,
    is_primary_property BOOLEAN DEFAULT FALSE,
    property_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (family_id, property_id),
    FOREIGN KEY (family_id) REFERENCES herb_families(family_id) ON DELETE CASCADE,
    FOREIGN KEY (property_id) REFERENCES properties(property_id) ON DELETE CASCADE
);

-- ตาราง 5: ข้อมูลการแพร่กระจายทางภูมิศาสตร์ของตระกูลสมุนไพร (Geographical Distribution)
CREATE TABLE family_geographical_distribution (
    distribution_id INT PRIMARY KEY AUTO_INCREMENT,
    family_id INT,
    region_name VARCHAR(100) NOT NULL,
    climate_type ENUM('ร้อนชื้น', 'ร้อนแห้ง', 'อบอุ่น', 'หนาว', 'กึ่งร้อนกึ่งอบอุ่น') NOT NULL,
    altitude_range VARCHAR(100),
    distribution_notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (family_id) REFERENCES herb_families(family_id) ON DELETE CASCADE
);

-- สร้าง Index เพื่อเพิ่มประสิทธิภาพการค้นหา
CREATE INDEX idx_family_name ON herb_families(family_name);
CREATE INDEX idx_family_scientific_name ON herb_families(family_scientific_name);
CREATE INDEX idx_herb_family ON herb_family_relationships(herb_id, family_id);
CREATE INDEX idx_family_evidence ON family_scientific_evidence(family_id);
CREATE INDEX idx_family_property ON family_properties(family_id, property_id);
CREATE INDEX idx_family_distribution ON family_geographical_distribution(family_id, region_name);

-- ข้อมูลตัวอย่างตระกูลสมุนไพรที่พบในประเทศไทย
INSERT INTO herb_families (family_name, family_scientific_name, family_description, common_characteristics, medicinal_value)
VALUES 
    ('วงศ์ขิง', 'Zingiberaceae', 'ตระกูลพืชที่มีเหง้าใต้ดินซึ่งมีกลิ่นหอมเฉพาะตัว พบมากในเอเชียตะวันออกเฉียงใต้', 'มีเหง้าใต้ดิน ใบเรียวยาว ดอกมีสีสันสดใส กลิ่นหอมเฉพาะตัว', 'มีสารต้านอักเสบ แก้ท้องอืด ท้องเฟ้อ ขับลม บำรุงธาตุ'),
    ('วงศ์พริกไทย', 'Piperaceae', 'ตระกูลพืชที่มักเป็นไม้เลื้อยหรือไม้พุ่มขนาดเล็ก มีรสเผ็ดร้อน', 'มีข้อปล้องชัดเจน ใบเดี่ยว ผลเป็นผลกลุ่ม มีรสเผ็ด', 'ช่วยย่อยอาหาร แก้ไอ ขับเสมหะ บำรุงธาตุ ขับลม'),
    ('วงศ์ถั่ว', 'Fabaceae', 'ตระกูลพืชที่ใหญ่ที่สุดในโลก มีทั้งไม้ล้มลุก ไม้พุ่ม และไม้ยืนต้น', 'มีฝักเป็นผล ใบประกอบแบบขนนก มีปมที่รากสำหรับตรึงไนโตรเจน', 'บำรุงเลือด แก้อ่อนเพลีย ช่วยเรื่องระบบทางเดินอาหาร'),
    ('วงศ์กระดังงา', 'Annonaceae', 'ตระกูลไม้ยืนต้นที่มีกลิ่นหอมเฉพาะตัว ผลมักมีรสหวาน', 'เปลือกเหนียว ใบเรียบมัน ดอกมีกลีบหนา ผลเป็นผลรวม', 'แก้ไข้ บำรุงโลหิต ขับลม แก้ท้องอืด ท้องเฟ้อ'),
    ('วงศ์เปล้า', 'Euphorbiaceae', 'ตระกูลพืชที่มีน้ำยางสีขาวคล้ายน้ำนม มีทั้งไม้ล้มลุก ไม้พุ่ม และไม้ยืนต้น', 'มีน้ำยางสีขาว ใบเดี่ยว ผลแห้งแตก 3 พู', 'แก้พิษแมลงสัตว์กัดต่อย รักษาโรคผิวหนัง ระบายท้อง แก้ริดสีดวง'),
    ('วงศ์ชา', 'Theaceae', 'ตระกูลไม้พุ่มหรือไม้ยืนต้นขนาดเล็กถึงกลาง ใบมักมีสารกาเฟอีน', 'ใบเรียบมัน ขอบใบหยัก ดอกสีขาวหรือชมพู', 'ต้านอนุมูลอิสระ กระตุ้นระบบประสาท ลดไขมันในเลือด ช่วยการทำงานของสมอง'),
    ('วงศ์บุก', 'Araceae', 'ตระกูลพืชหัวที่มีลำต้นใต้ดิน ใบขนาดใหญ่', 'มีหัวใต้ดิน ก้านใบยาว ใบรูปหัวใจหรือรูปฉัตร ดอกเป็นแท่ง', 'ระบายท้อง แก้ไอ ขับเสมหะ ลดการอักเสบ'),
    ('วงศ์ไม้กฤษณา', 'Thymelaeaceae', 'ตระกูลไม้ยืนต้นที่มีเนื้อไม้หอม นิยมใช้ทำเครื่องหอม', 'เปลือกเหนียว มียางเหนียว เนื้อไม้มีกลิ่นหอม', 'บำรุงหัวใจ แก้โรคทางเดินหายใจ บำรุงกำลัง แก้นอนไม่หลับ'),
    ('วงศ์มะเขือ', 'Solanaceae', 'ตระกูลพืชที่มีทั้งพืชอาหารและพืชพิษ', 'ดอกรูปดาว 5 แฉก ผลเป็นผลสด มีเมล็ดมาก', 'แก้ปวด ลดการอักเสบ แก้ไข้ บำรุงสายตา'),
    ('วงศ์กล้วย', 'Musaceae', 'ตระกูลพืชล้มลุกขนาดใหญ่ ลำต้นเทียมเกิดจากกาบใบซ้อนกัน', 'ลำต้นเทียม ใบขนาดใหญ่ ผลเป็นหวี', 'บำรุงกำลัง แก้ท้องเสีย รักษาแผลในกระเพาะอาหาร บำรุงสมอง');

-- คำสั่ง SQL สำหรับเพิ่ม/อัพเดต Foreign Key (FK) ระหว่างตาราง

-- 1. เพิ่มคอลัมน์ family_id ในตาราง herbs เพื่อเชื่อมโยงกับตระกูลสมุนไพรหลัก
ALTER TABLE herbs 
ADD COLUMN primary_family_id INT,
ADD CONSTRAINT fk_herb_primary_family 
FOREIGN KEY (primary_family_id) REFERENCES herb_families(family_id) 
ON DELETE SET NULL;

-- 2. เพิ่มคอลัมน์ expert_healer_id ในตาราง herbs เพื่อระบุผู้รู้ที่เชี่ยวชาญสมุนไพรชนิดนี้มากที่สุด
ALTER TABLE herbs
ADD COLUMN expert_healer_id INT,
ADD CONSTRAINT fk_herb_expert_healer
FOREIGN KEY (expert_healer_id) REFERENCES healers(healer_id)
ON DELETE SET NULL;

-- 3. เพิ่มคอลัมน์ primary_location_id ในตาราง herbs เพื่อระบุแหล่งที่พบมากที่สุด
ALTER TABLE herbs
ADD COLUMN primary_location_id INT,
ADD CONSTRAINT fk_herb_primary_location
FOREIGN KEY (primary_location_id) REFERENCES locations(location_id)
ON DELETE SET NULL;

-- 4. เพิ่มคอลัมน์ recommended_method_id ในตาราง herb_symptoms เพื่อระบุวิธีใช้ที่แนะนำสำหรับอาการนั้น
ALTER TABLE herb_symptoms
ADD COLUMN recommended_method_id INT,
ADD CONSTRAINT fk_herb_symptom_recommended_method
FOREIGN KEY (recommended_method_id) REFERENCES usage_methods(method_id)
ON DELETE SET NULL;

-- 5. เพิ่มคอลัมน์ discovered_by_healer_id ในตาราง properties เพื่อระบุผู้รู้ที่ค้นพบสรรพคุณนี้
ALTER TABLE properties
ADD COLUMN discovered_by_healer_id INT,
ADD CONSTRAINT fk_property_discovered_by
FOREIGN KEY (discovered_by_healer_id) REFERENCES healers(healer_id)
ON DELETE SET NULL;

-- 6. เพิ่มคอลัมน์ best_season_id ในตาราง herb_locations เพื่อระบุฤดูกาลที่ดีที่สุดสำหรับการเก็บสมุนไพรจากสถานที่นั้น
ALTER TABLE herb_locations
ADD COLUMN best_season_id INT,
ADD CONSTRAINT fk_herb_location_best_season
FOREIGN KEY (best_season_id) REFERENCES seasons(season_id)
ON DELETE SET NULL;

-- 7. เพิ่มคอลัมน์ recommended_for_family_id ในตาราง properties เพื่อระบุตระกูลสมุนไพรที่มักมีสรรพคุณนี้
ALTER TABLE properties
ADD COLUMN recommended_for_family_id INT,
ADD CONSTRAINT fk_property_recommended_family
FOREIGN KEY (recommended_for_family_id) REFERENCES herb_families(family_id)
ON DELETE SET NULL;

-- 8. เพิ่มคอลัมน์ parent_symptom_id ในตาราง symptoms เพื่อสร้างความสัมพันธ์แบบลำดับชั้นของอาการ
ALTER TABLE symptoms
ADD COLUMN parent_symptom_id INT,
ADD CONSTRAINT fk_symptom_parent
FOREIGN KEY (parent_symptom_id) REFERENCES symptoms(symptom_id)
ON DELETE SET NULL;

-- 9. เพิ่มคอลัมน์ primary_herb_id ในตาราง symptoms เพื่อระบุสมุนไพรที่ใช้รักษาอาการนี้ได้ดีที่สุด
ALTER TABLE symptoms
ADD COLUMN primary_herb_id INT,
ADD CONSTRAINT fk_symptom_primary_herb
FOREIGN KEY (primary_herb_id) REFERENCES herbs(herb_id)
ON DELETE SET NULL;

-- 10. เพิ่มคอลัมน์ related_location_id ในตาราง healers เพื่อระบุสถานที่ที่หมอพื้นบ้านอาศัยหรือเก็บสมุนไพร
ALTER TABLE healers
ADD COLUMN related_location_id INT,
ADD CONSTRAINT fk_healer_location
FOREIGN KEY (related_location_id) REFERENCES locations(location_id)
ON DELETE SET NULL;

-- 11. เพิ่มคอลัมน์ substitute_herb_id ในตาราง herbs เพื่อระบุสมุนไพรที่สามารถใช้ทดแทนกันได้
ALTER TABLE herbs
ADD COLUMN substitute_herb_id INT,
ADD CONSTRAINT fk_herb_substitute
FOREIGN KEY (substitute_herb_id) REFERENCES herbs(herb_id)
ON DELETE SET NULL;

-- 12. เพิ่มความสัมพันธ์ระหว่างวิธีการใช้กับตระกูลสมุนไพร
CREATE TABLE family_usage_methods (
    family_id INT,
    method_id INT,
    is_preferred BOOLEAN DEFAULT FALSE,
    usage_notes TEXT,
    PRIMARY KEY (family_id, method_id),
    FOREIGN KEY (family_id) REFERENCES herb_families(family_id) ON DELETE CASCADE,
    FOREIGN KEY (method_id) REFERENCES usage_methods(method_id) ON DELETE CASCADE
);

-- 13. เพิ่มคอลัมน์ researched_by_healer_id ในตาราง family_scientific_evidence
ALTER TABLE family_scientific_evidence
ADD COLUMN researched_by_healer_id INT,
ADD CONSTRAINT fk_family_evidence_healer
FOREIGN KEY (researched_by_healer_id) REFERENCES healers(healer_id)
ON DELETE SET NULL;

-- 14. เพิ่มคอลัมน์ specific_location_id ในตาราง family_geographical_distribution
ALTER TABLE family_geographical_distribution
ADD COLUMN specific_location_id INT,
ADD CONSTRAINT fk_family_distribution_location
FOREIGN KEY (specific_location_id) REFERENCES locations(location_id)
ON DELETE SET NULL;

-- 15. เพิ่มความสัมพันธ์ระหว่างฤดูกาลกับพื้นที่ (เพื่อระบุว่าแต่ละพื้นที่มีลักษณะเฉพาะในแต่ละฤดูกาลอย่างไร)
CREATE TABLE location_seasons (
    location_id INT,
    season_id INT,
    climate_characteristics TEXT,
    herb_availability ENUM('น้อย', 'ปานกลาง', 'มาก', 'มากที่สุด') DEFAULT 'ปานกลาง',
    notes TEXT,
    PRIMARY KEY (location_id, season_id),
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE,
    FOREIGN KEY (season_id) REFERENCES seasons(season_id) ON DELETE CASCADE
);

-- 16. เพิ่มคอลัมน์ parent_property_id ในตาราง properties เพื่อสร้างความสัมพันธ์แบบลำดับชั้นของสรรพคุณ
ALTER TABLE properties
ADD COLUMN parent_property_id INT,
ADD CONSTRAINT fk_property_parent
FOREIGN KEY (parent_property_id) REFERENCES properties(property_id)
ON DELETE SET NULL;

-- 17. สร้างตารางสำหรับเก็บข้อมูลการรวมสมุนไพรหลายชนิดเข้าด้วยกัน (ตำรับยา)
CREATE TABLE herb_formulas (
    formula_id INT PRIMARY KEY AUTO_INCREMENT,
    formula_name VARCHAR(150) NOT NULL UNIQUE,
    description TEXT,
    preparation_method TEXT,
    dosage VARCHAR(100),
    created_by_healer_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by_healer_id) REFERENCES healers(healer_id) ON DELETE SET NULL
);

-- 18. สร้างตารางความสัมพันธ์ระหว่างตำรับยากับสมุนไพรที่ใช้
CREATE TABLE formula_herbs (
    formula_id INT,
    herb_id INT,
    quantity VARCHAR(50) NOT NULL,
    herb_role ENUM('หลัก', 'รอง', 'ปรุงแต่ง', 'แก้พิษ') DEFAULT 'รอง',
    notes TEXT,
    PRIMARY KEY (formula_id, herb_id),
    FOREIGN KEY (formula_id) REFERENCES herb_formulas(formula_id) ON DELETE CASCADE,
    FOREIGN KEY (herb_id) REFERENCES herbs(herb_id) ON DELETE CASCADE
);

-- 19. สร้างตารางความสัมพันธ์ระหว่างตำรับยากับอาการที่รักษา
CREATE TABLE formula_symptoms (
    formula_id INT,
    symptom_id INT,
    effectiveness_level ENUM('น้อย', 'ปานกลาง', 'มาก', 'มากที่สุด') DEFAULT 'ปานกลาง',
    usage_instructions TEXT,
    contraindications TEXT,
    PRIMARY KEY (formula_id, symptom_id),
    FOREIGN KEY (formula_id) REFERENCES herb_formulas(formula_id) ON DELETE CASCADE,
    FOREIGN KEY (symptom_id) REFERENCES symptoms(symptom_id) ON DELETE CASCADE
);

-- 20. เพิ่ม Index เพื่อเพิ่มประสิทธิภาพการค้นหาในฟิลด์ใหม่
CREATE INDEX idx_herb_primary_family ON herbs(primary_family_id);
CREATE INDEX idx_herb_expert_healer ON herbs(expert_healer_id);
CREATE INDEX idx_herb_primary_location ON herbs(primary_location_id);
CREATE INDEX idx_herb_substitute ON herbs(substitute_herb_id);
CREATE INDEX idx_symptom_parent ON symptoms(parent_symptom_id);
CREATE INDEX idx_symptom_primary_herb ON symptoms(primary_herb_id);
CREATE INDEX idx_property_parent ON properties(parent_property_id);
CREATE INDEX idx_healer_location ON healers(related_location_id);
CREATE INDEX idx_herb_symptoms_method ON herb_symptoms(recommended_method_id);
CREATE INDEX idx_formula_created_by ON herb_formulas(created_by_healer_id);
