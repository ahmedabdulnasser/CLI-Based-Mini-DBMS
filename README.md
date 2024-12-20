# Mini CLI-based DBMS Shell Script System

## Description
A Bash-based database management system that provides SQL-like operations through shell scripts.
## Features
- **Database Creation and Management**: Create and manage databases with ease.
- **Table Operations**:
  - Create, list, and drop tables.
- **Data Manipulation**:
  - `INSERT`: Add new records with value validation.
  - `SELECT`: Query data with column filtering and conditions.
  - `UPDATE`: Modify existing records with `WHERE` clause.
  - `DELETE`: Remove records based on conditions.
- **SQL Query Support**:
  - Custom SQL parser and executor.
  - Support for basic SQL operations.
  - Data type validation.
- **Metadata Management**:
  - Column definitions.
  - Primary key constraints.
  - Data type constraints.
  - Unique constraints.
  - Not null constraints.

## Supported SQL Operations
```sql
-- Create table with constraints
CREATE TABLE tablename (col1 type1, col2 type2);

-- Insert data
INSERT INTO table (col1, col2) VALUES (val1, val2);

-- Select data
SELECT * FROM table;
SELECT col1, col2 FROM table WHERE col = value;

-- Update records
UPDATE table SET col = value WHERE condition;

-- Delete records
DELETE FROM table WHERE condition;

## Data Types

- **varchar**: String values.
- **numeric**: Numbers (0-9).
- **date**: Date in the format YYYY-MM-DD.

## Storage

- **Tables**: Stored as CSV files in the working directory.
- **Metadata**: Stored in `.csvmeta` files for each table, containing:
  - Column definitions.
  - Constraints (primary key, unique, not null).
  - Data types.

## Requirements

- **Environment**: Linux/Unix.
- **Shell**: Bash (version 4+).
- **Core Utilities**:
  - `awk`
  - `sed`
  - `cut`
  - `grep`
- **Permissions**: Read/Write permissions in the working directory.

