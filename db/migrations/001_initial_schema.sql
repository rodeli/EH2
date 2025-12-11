-- Migration: 001_initial_schema
-- Description: Create initial core schema for users, clients, leads, and expedientes
-- Created: 2025-12-11

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id TEXT PRIMARY KEY,
    email TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('admin', 'staff', 'viewer')),
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);

-- Clients table
CREATE TABLE IF NOT EXISTS clients (
    id TEXT PRIMARY KEY,
    user_id TEXT,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_clients_email ON clients(email);
CREATE INDEX IF NOT EXISTS idx_clients_user_id ON clients(user_id);

-- Leads table
CREATE TABLE IF NOT EXISTS leads (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    property_location TEXT NOT NULL,
    property_type TEXT NOT NULL CHECK(property_type IN ('casa', 'departamento', 'terreno', 'comercial')),
    urgency TEXT CHECK(urgency IN ('alta', 'media', 'baja')),
    status TEXT NOT NULL DEFAULT 'nuevo' CHECK(status IN ('nuevo', 'contactado', 'convertido', 'perdido')),
    notes TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_leads_email ON leads(email);
CREATE INDEX IF NOT EXISTS idx_leads_status ON leads(status);
CREATE INDEX IF NOT EXISTS idx_leads_created_at ON leads(created_at);

-- Expedientes table
CREATE TABLE IF NOT EXISTS expedientes (
    id TEXT PRIMARY KEY,
    client_id TEXT NOT NULL,
    lead_id TEXT,
    property_location TEXT NOT NULL,
    type TEXT NOT NULL CHECK(type IN ('compraventa', 'donacion', 'sucesion', 'otro')),
    status TEXT NOT NULL DEFAULT 'inicial' CHECK(status IN ('inicial', 'documentacion', 'revision', 'firma', 'cerrado', 'cancelado')),
    metadata TEXT,
    created_at INTEGER NOT NULL,
    updated_at INTEGER NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_expedientes_client_id ON expedientes(client_id);
CREATE INDEX IF NOT EXISTS idx_expedientes_status ON expedientes(status);
CREATE INDEX IF NOT EXISTS idx_expedientes_created_at ON expedientes(created_at);

