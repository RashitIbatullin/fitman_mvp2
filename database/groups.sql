-- Удаление старых таблиц, если они существуют, для идемпотентности скрипта
DROP TABLE IF EXISTS 
"group_conditions",
"client_group_members",
"client_groups"
CASCADE;

-- Таблица для хранения групп клиентов
CREATE TABLE client_groups (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    type SMALLINT NOT NULL, -- 0: trainingProgram, 1: subscriptionType, etc.
    is_auto_update BOOLEAN NOT NULL DEFAULT FALSE,
    company_id BIGINT NOT NULL DEFAULT -1, -- Для мультитенантности
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id), -- Кто создал
    updated_by BIGINT REFERENCES users(id), -- Кто последним обновил
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id) -- Кто архивировал
);

COMMENT ON TABLE client_groups IS 'Хранит информацию о группах клиентов (тренировочные, финансовые, демографические и т.д.)';
COMMENT ON COLUMN client_groups.type IS 'Тип группы: 0 - Программа тренировок, 1 - Тип абонемента, 2 - Корпоративная, 3 - Демографическая, 4 - Уровень активности, 5 - Статус оплаты, 6 - Произвольная';

-- Таблица для связи клиентов с группами
CREATE TABLE client_group_members (
    id BIGSERIAL PRIMARY KEY,
    client_group_id BIGINT NOT NULL REFERENCES client_groups(id) ON DELETE CASCADE,
    client_id BIGINT NOT NULL REFERENCES users(id) ON DELETE CASCADE, -- user_id с ролью client
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by BIGINT REFERENCES users(id), -- Кто добавил
    updated_by BIGINT REFERENCES users(id), -- Кто последним обновил
    archived_at TIMESTAMPTZ,
    archived_by BIGINT REFERENCES users(id), -- Кто архивировал
    UNIQUE (client_group_id, client_id)
);

COMMENT ON TABLE client_group_members IS 'Связывает клиентов с группами, в которых они состоят';

-- Таблица для хранения условий автоматических групп
CREATE TABLE group_conditions (
    id BIGSERIAL PRIMARY KEY,
    client_group_id BIGINT NOT NULL REFERENCES client_groups(id) ON DELETE CASCADE,
    field VARCHAR(255) NOT NULL,    -- Поле для условия (например, 'subscription_type', 'last_visit_date')
    operator VARCHAR(50) NOT NULL,  -- Оператор ('equals', 'greater_than', 'less_than', 'contains')
    value TEXT NOT NULL             -- Значение для условия
);

COMMENT ON TABLE group_conditions IS 'Хранит условия для автоматического обновления групп клиентов';

-- Индексы для ускорения запросов
CREATE INDEX idx_client_group_members_client_id ON client_group_members(client_id);
CREATE INDEX idx_group_conditions_client_group_id ON group_conditions(client_group_id);
CREATE INDEX idx_client_groups_company_id ON client_groups(company_id);
CREATE INDEX idx_client_groups_is_auto_update ON client_groups(is_auto_update);
