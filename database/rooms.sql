-- ============================================
-- Файл создания таблиц помещений и зданий
-- для системы "Фитнес-менеджер" (FitMan)
-- ============================================

-- Удаляем в обратном порядке (сначала дочерние таблицы, затем родительские)
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS buildings CASCADE;

-- Отключаем проверку внешних ключей для удобства
SET session_replication_role = 'replica';

-- Здания
CREATE TABLE buildings (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  address TEXT,
  
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

-- Помещения (залы)
CREATE TABLE rooms (
  id BIGSERIAL PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  room_number VARCHAR(50), -- New field for room/cabinet number
  type SMALLINT NOT NULL,  -- RoomType enum (0:groupHall, 1:cardioZone, 2:strengthZone, 3:mixedZone, 4:studio, 5:boxingRing, 6:pool, 7:lockerRoom, 8:reception, 9:office, 10:other)
  
  -- Локация
  floor INT,
  building_id BIGINT REFERENCES buildings(id),
  
  -- Характеристики
  max_capacity INT NOT NULL DEFAULT 30,
  area DECIMAL(5,2),
  
  -- Расписание доступности
  open_time TIME,
  close_time TIME,
  working_days JSONB,  -- Массив дней недели [1,2,3,4,5,6,7]
  
  -- Статус
  is_active BOOLEAN DEFAULT true,
  deactivate_reason TEXT,
  deactivate_at TIMESTAMPTZ,
  deactivate_by BIGINT REFERENCES users(id),
  
  -- Файлы
  photo_urls JSONB,
  floor_plan_url TEXT,
  
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

-- Индексы для rooms
CREATE INDEX idx_rooms_type ON rooms(type) WHERE is_active = true;
CREATE INDEX idx_rooms_building ON rooms(building_id) WHERE building_id IS NOT NULL;
CREATE INDEX idx_rooms_active ON rooms(company_id) WHERE archived_at IS NULL AND is_active = true;

-- Индексы для buildings
CREATE INDEX idx_buildings_name ON buildings(name);
CREATE INDEX idx_buildings_active ON buildings(company_id) WHERE archived_at IS NULL;

-- Включаем проверку внешних ключей
SET session_replication_role = 'origin';

-- 5.15. Заполняем Здания
INSERT INTO buildings (name, address, note) VALUES
('Основной корпус', 'г. Москва, ул. Центральная, 1', 'Главное здание фитнес-центра'),
('Водный комплекс', 'г. Москва, ул. Центральная, 2', 'Здание с бассейном и спа');

-- 5.16. Заполняем помещения (залы)
INSERT INTO rooms (name, description, type, floor, building_id, max_capacity, area, open_time, close_time, working_days, note) VALUES
('Зал групповых занятий', 'Основной зал для групповых тренировок, йоги, аэробики', 0, '1', 1, 25, 120.0, '08:00', '22:00', '[1,2,3,4,5,6]', 'Основной зал, паркетное покрытие'),
('Кардио-зона', 'Зона с кардио оборудованием', 1, '1', 1, 15, 80.0, '06:00', '23:00', '[1,2,3,4,5,6,7]', '24/7 для членов клуба'),
('Силовая зона', 'Зона со свободными весами и силовыми тренажерами', 2, '1', 1, 20, 100.0, '06:00', '23:00', '[1,2,3,4,5,6,7]', 'Олимпийские платформы'),
('Йога-студия', 'Зал для йоги и пилатеса', 4, '2', 1, 12, 60.0, '07:00', '21:00', '[1,2,3,4,5,6]', 'Бамбуковое покрытие, оборудование для йоги'),
('Боксерский зал', 'Зал для единоборств и функционального тренинга', 5, '2', 1, 10, 70.0, '09:00', '20:00', '[1,2,3,4,5]', 'Боксерские груши, татами'),
('Бассейн', 'Плавание', 6, '1', 2, 30, 250.0, '07:00', '22:00', '[1,2,3,4,5,6,7]', '25-метровый бассейн, 4 дорожки'),
('Сауна', 'Зона отдыха с сауной', 7, '1', 2, 8, 20.0, '10:00', '21:00', '[1,2,3,4,5,6,7]', 'Финская сауна'),
('Сауна 2', 'Дополнительная зона отдыха с сауной', 7, '1', 2, 8, 20.0, '10:00', '21:00', '[1,2,3,4,5,6,7]', 'Вторая финская сауна');

DO $$
BEGIN
    RAISE NOTICE '============================================';
    RAISE NOTICE 'Создание таблиц помещений и зданий завершено!';
    RAISE NOTICE 'Создано таблиц: 2';
    RAISE NOTICE 'Создано индексов: 5';
    RAISE NOTICE 'Загружено начальных данных: 10 записей';
    RAISE NOTICE '============================================';
END $$;
