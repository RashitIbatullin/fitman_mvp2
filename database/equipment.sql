-- ============================================
-- Файл создания таблиц оборудования и бронирования
-- для системы "Фитнес-менеджер" (FitMan)
-- ============================================

-- Удаляем в обратном порядке (сначала дочерние таблицы, затем родительские)
DROP TABLE IF EXISTS equipment_bookings CASCADE;
DROP TABLE IF EXISTS equipment_items CASCADE;
DROP TABLE IF EXISTS equipment_types CASCADE;

-- Отключаем проверку внешних ключей для удобства
SET session_replication_role = 'replica';

-- Таблица типов оборудования (для связи с упражнениями)
CREATE TABLE equipment_types (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  
  -- Классификация
  category SMALLINT NOT NULL,      -- EquipmentCategory enum (0:cardio, 1:strength, 2:freeWeights, 3:functional, 4:accessories, 5:measurement, 6:other)
  sub_type SMALLINT,               -- EquipmentSubType enum
  
  -- Характеристики
  weight_range VARCHAR(50),
  dimensions VARCHAR(100),
  power_requirements VARCHAR(100),
  is_mobile BOOLEAN DEFAULT true,
  
  -- Медиа
  photo_url TEXT,
  manual_url TEXT,
  
  -- Статус
  is_active BOOLEAN DEFAULT true,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  note VARCHAR(100)
);

-- Экземпляры оборудования
CREATE TABLE equipment_items (
  id BIGSERIAL PRIMARY KEY,
  
  -- Тип оборудования
  type_id BIGINT NOT NULL REFERENCES equipment_types(id),
  
  -- Идентификация
  inventory_number VARCHAR(50) NOT NULL UNIQUE,
  serial_number VARCHAR(100),
  model VARCHAR(100),
  manufacturer VARCHAR(255),
  
  -- Локация
  room_id BIGINT REFERENCES rooms(id), -- This will reference rooms.id, which means rooms.sql must be run before this.
  placement_note TEXT,
  
  -- Состояние
  status SMALLINT DEFAULT 0,  -- EquipmentStatus enum (0:available, 1:inUse, 2:reserved, 3:maintenance, 4:outOfOrder, 5:storage)
  condition_rating INT CHECK (condition_rating >= 1 AND condition_rating <= 5),
  condition_notes TEXT,
  
  -- Обслуживание
  last_maintenance_date DATE,
  next_maintenance_date DATE,
  maintenance_notes TEXT,
  
  -- Учёт
  purchase_date DATE,
  purchase_price DECIMAL(10,2),
  supplier VARCHAR(255),
  warranty_months INT,
  
  -- Использование
  usage_hours INT DEFAULT 0,
  last_used_date DATE,
  
  -- Фотографии
  photo_urls JSONB,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  archived_reason TEXT,
  note VARCHAR(100)
);

-- Бронирование оборудования
CREATE TABLE equipment_bookings (
  id BIGSERIAL PRIMARY KEY,
  
  -- Что бронируем
  equipment_item_id BIGINT NOT NULL REFERENCES equipment_items(id),
  
  -- Кто бронирует
  booked_by BIGINT NOT NULL REFERENCES users(id),
  
  -- Время
  start_time TIMESTAMPTZ NOT NULL,
  end_time TIMESTAMPTZ NOT NULL,
  
  -- Контекст
  lesson_id BIGINT,  -- Ссылка будет добавлена позже
  training_group_id BIGINT,  -- Ссылка будет добавлена позже
  purpose VARCHAR(255) NOT NULL,
  
  -- Статус
  status SMALLINT DEFAULT 0,  -- BookingStatus enum
  
  -- Дополнительно
  notes TEXT,
  
  -- Системные поля
  company_id BIGINT DEFAULT -1,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  created_by BIGINT REFERENCES users(id),
  updated_by BIGINT REFERENCES users(id),
  archived_at TIMESTAMPTZ,
  archived_by BIGINT REFERENCES users(id),
  
  -- Ограничения
  CONSTRAINT valid_booking_time CHECK (end_time > start_time)
);

-- Индексы для equipment_types
CREATE INDEX idx_equipment_types_category ON equipment_types(category) WHERE is_active = true;
CREATE INDEX idx_equipment_types_active ON equipment_types(company_id) WHERE archived_at IS NULL;

-- Индексы для equipment_items
CREATE INDEX idx_equipment_items_type ON equipment_items(type_id);
CREATE INDEX idx_equipment_items_room ON equipment_items(room_id) WHERE room_id IS NOT NULL;
CREATE INDEX idx_equipment_items_status ON equipment_items(status) WHERE status = 0;
CREATE INDEX idx_equipment_items_inventory ON equipment_items(inventory_number);
CREATE INDEX idx_equipment_items_active ON equipment_items(company_id) WHERE archived_at IS NULL;

-- Индексы для equipment_bookings
CREATE INDEX idx_equipment_bookings_item ON equipment_bookings(equipment_item_id);
CREATE INDEX idx_equipment_bookings_user ON equipment_bookings(booked_by);
CREATE INDEX idx_equipment_bookings_time ON equipment_bookings(equipment_item_id, start_time, end_time) WHERE status IN (0, 1);
CREATE INDEX idx_equipment_bookings_active ON equipment_bookings(company_id) WHERE archived_at IS NULL;
CREATE INDEX idx_equipment_bookings_time_status ON equipment_bookings(equipment_item_id, start_time, end_time, status);

-- Включаем проверку внешних ключей
SET session_replication_role = 'origin';

-- 5.6. Заполняем типы оборудования
INSERT INTO equipment_types (name, description, category, sub_type, weight_range, dimensions, is_mobile, photo_url, note) VALUES
('Беговая дорожка', 'Кардио тренажер для бега и ходьбы', 0, 0, NULL, '180x80x140 см', false, '/equipment/treadmill.jpg', 'Электрическая, с наклоном'),
('Эллиптический тренажер', 'Кардио тренажер для низкоударной тренировки', 0, 1, NULL, '160x70x170 см', true, '/equipment/elliptical.jpg', 'Орбитрек'),
('Велотренажер', 'Кардио тренажер для тренировки ног', 0, 2, NULL, '120x60x140 см', true, '/equipment/bike.jpg', 'С вертикальной посадкой'),
('Гантели', 'Свободные веса для силовых упражнений', 2, 0, '1-30 кг', NULL, true, '/equipment/dumbbells.jpg', 'Резиновое покрытие'),
('Штанга', 'Свободный вес для базовых упражнений', 2, 1, '20 кг (гриф)', '220 см', false, '/equipment/barbell.jpg', 'Олимпийский гриф'),
('Скамья для жима', 'Силовой тренажер для жима лежа', 1, 0, NULL, '120x30x45 см', true, '/equipment/bench.jpg', 'Регулируемый наклон'),
('Тренажер для жима ногами', 'Силовой тренажер для ног', 1, 1, NULL, '200x120x150 см', false, '/equipment/leg_press.jpg', 'Под углом 45°'),
('Фитбол', 'Мяч для функциональных упражнений', 3, 0, NULL, 'Диаметр 65 см', true, '/equipment/fitball.jpg', 'Антиразрывный'),
('Коврик для йоги', 'Аксессуар для растяжки и йоги', 4, 0, NULL, '180x60x0.5 см', true, '/equipment/yoga_mat.jpg', 'ПВХ, 5 мм'),
('Весы напольные', 'Измерительное оборудование', 5, 0, NULL, '30x30x3 см', true, '/equipment/scales.jpg', 'Электронные, до 200 кг');

-- 5.17. Заполняем экземпляры оборудования
INSERT INTO equipment_items (type_id, inventory_number, serial_number, model, manufacturer, room_id, placement_note, status, condition_rating, purchase_date, purchase_price, note) VALUES
(1, 'ТРЕД-001', 'SN123456', 'T8.5', 'Matrix', 2, 'У окна, левая сторона', 0, 5, '2023-01-15', 250000.00, 'Основная беговая дорожка'),
(1, 'ТРЕД-002', 'SN123457', 'T8.5', 'Matrix', 2, 'У окна, правая сторона', 0, 5, '2023-01-15', 250000.00, 'Запасная беговая дорожка'),
(2, 'ЭЛЛ-001', 'SN123458', 'E7Xi', 'Matrix', 2, 'Центр зала', 0, 4, '2023-02-20', 180000.00, 'Эллиптический тренажер'),
(3, 'ВЕЛ-001', 'SN123459', 'R7xe', 'Matrix', 2, 'У стены', 0, 5, '2023-02-20', 150000.00, 'Велотренажер вертикальный'),
(4, 'ГАН-001', NULL, 'Резиновые', 'Kettler', 3, 'Стеллаж №1', 0, 4, '2022-11-10', 5000.00, 'Гантели 5 кг, пара'),
(4, 'ГАН-002', NULL, 'Резиновые', 'Kettler', 3, 'Стеллаж №1', 0, 4, '2022-11-10', 7000.00, 'Гантели 10 кг, пара'),
(5, 'ШТАН-001', 'SN123460', 'Олимпийская', 'Rogue', 3, 'Стойка для штанги', 0, 5, '2023-03-05', 30000.00, 'Олимпийский гриф 20 кг'),
(6, 'СКАМ-001', 'SN123461', 'Adjustable', 'Body Solid', 3, 'Возле зеркала', 0, 4, '2022-12-15', 45000.00, 'Скамья регулируемая'),
(7, 'НОГИ-001', 'SN123462', 'Leg Press', 'Hammer Strength', 3, 'Угол зала', 0, 5, '2023-01-10', 320000.00, 'Тренажер для жима ногами'),
(8, 'ФИТ-001', NULL, 'Anti-Burst', 'Ledraplastik', 4, 'Корзина с мячами', 0, 5, '2023-04-01', 3000.00, 'Фитбол 65 см'),
(9, 'КОВ-001', NULL, 'Professional', 'Manduka', 4, 'Стеллаж для ковриков', 0, 5, '2023-04-01', 2500.00, 'Коврик для йоги 5мм'),
(10, 'ВЕС-001', 'SN123463', 'BF-350', 'Beurer', 5, 'У входа', 0, 5, '2023-05-10', 8000.00, 'Электронные весы');

-- 5.19. Создаем несколько бронирований оборудования (пример)
INSERT INTO equipment_bookings (equipment_item_id, booked_by, start_time, end_time, purpose, notes) VALUES
(1, 1, '2024-01-15 10:00:00+03', '2024-01-15 11:00:00+03', 'Индивидуальная тренировка', 'Клиент: Иванов И.И.'),
(2, 1, '2024-01-15 11:00:00+03', '2024-01-15 12:00:00+03', 'Групповое занятие', 'Группа "Кардио для начинающих"'),
(5, 2, '2024-01-15 14:00:00+03', '2024-01-15 15:00:00+03', 'Силовая тренировка', 'Клиент: Петров П.П.'),
(8, 2, '2024-01-15 16:00:00+03', '2024-01-15 17:00:00+03', 'Тренировка грудных', 'Собственный вес + гантели');

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Создание таблиц оборудования и бронирования завершено!';
    RAISE NOTICE 'Создано таблиц: 3';
    RAISE NOTICE 'Создано индексов: 10';
    RAISE NOTICE 'Загружено начальных данных: 26 записей';
    RAISE NOTICE '============================================';
END $$;
