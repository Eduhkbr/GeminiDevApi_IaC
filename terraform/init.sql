-- Script SQL para tabela de usuários
CREATE TABLE IF NOT EXISTS users (
    id BIGSERIAL PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(50) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Script SQL para tabela de cache de geração (já existente, mas para referência)
CREATE TABLE IF NOT EXISTS generation_cache (
    id BIGSERIAL PRIMARY KEY,
    hash VARCHAR(128) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    source_code TEXT NOT NULL,
    result TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);
