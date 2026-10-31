-- Automatically initialize multiple databases on first container startup
SELECT 'CREATE DATABASE db_kss'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'db_kss')\gexec

SELECT 'CREATE DATABASE db_iqrolife'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'db_iqrolife')\gexec

SELECT 'CREATE DATABASE db_notification'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'db_notification')\gexec
