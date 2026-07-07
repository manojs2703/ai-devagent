---
name: sql-scripts
description: Load when creating database migration scripts or other SQL scripts.
---

# Skill: SQL Scripts

## When to Apply This Skill

Load this skill when:
- Creating database migration scripts
- Writing DDL (CREATE TABLE, ALTER TABLE, etc.)
- Writing DML (INSERT, UPDATE, DELETE)
- Creating indexes, constraints, or sequences

---

## Script File Structure

```
database/
├── scripts/
│   ├── schema/
│   │   ├── V1__initial_schema.sql
│   │   ├── V2__add_product_table.sql
│   │   └── V3__add_category_index.sql
│   ├── data/
│   │   ├── R__reference_data.sql     (repeatable migrations)
│   │   └── V1.1__seed_categories.sql
│   └── rollback/
│       ├── V2__rollback.sql
│       └── V3__rollback.sql
└── test/
    └── test_data.sql
```

---

## DDL — CREATE TABLE

```sql
-- ✅ Always include schema prefix, NOT NULL constraints, and constraint names
CREATE TABLE PRODUCT (
    ID               NUMBER(19)     NOT NULL,
    VERSION          NUMBER(19)     DEFAULT 0 NOT NULL,
    NAME             VARCHAR2(100)  NOT NULL,
    SKU              VARCHAR2(20)   NOT NULL,
    DESCRIPTION      VARCHAR2(4000),
    PRICE            NUMBER(12, 2)  NOT NULL,
    ACTIVE           NUMBER(1)      DEFAULT 1 NOT NULL,
    CATEGORY_ID      NUMBER(19)     NOT NULL,
    CREATED_AT       TIMESTAMP      DEFAULT SYSTIMESTAMP NOT NULL,
    CREATED_BY       VARCHAR2(100)  NOT NULL,
    MODIFIED_AT      TIMESTAMP,
    MODIFIED_BY      VARCHAR2(100),
    CONSTRAINT PK_PRODUCT           PRIMARY KEY (ID),
    CONSTRAINT UC_PRODUCT_SKU       UNIQUE (SKU),
    CONSTRAINT FK_PRODUCT_CATEGORY  FOREIGN KEY (CATEGORY_ID)
                                        REFERENCES CATEGORY (ID),
    CONSTRAINT CHK_PRODUCT_PRICE    CHECK (PRICE > 0),
    CONSTRAINT CHK_PRODUCT_ACTIVE   CHECK (ACTIVE IN (0, 1))
);

COMMENT ON TABLE  PRODUCT         IS 'Products available for ordering';
COMMENT ON COLUMN PRODUCT.SKU     IS 'Stock Keeping Unit — unique product code';
COMMENT ON COLUMN PRODUCT.ACTIVE  IS '1 = active, 0 = discontinued';
```

---

## DDL — Sequences (Oracle)

```sql
-- ✅ Always create a sequence for each table primary key
CREATE SEQUENCE SEQ_PRODUCT_ID
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- H2 compatible (for testing)
CREATE SEQUENCE IF NOT EXISTS SEQ_PRODUCT_ID
    START WITH 1
    INCREMENT BY 1;
```

---

## DDL — Indexes

```sql
-- ✅ Index foreign keys (not indexed by default in Oracle)
CREATE INDEX IDX_PRODUCT_CATEGORY_ID ON PRODUCT (CATEGORY_ID);

-- ✅ Composite index for frequent query patterns
CREATE INDEX IDX_PRODUCT_ACTIVE_CATEGORY ON PRODUCT (ACTIVE, CATEGORY_ID);

-- ✅ Unique index (alternative to UNIQUE constraint — allows deferred)
CREATE UNIQUE INDEX UC_PRODUCT_SKU ON PRODUCT (SKU);
```

---

## DDL — ALTER TABLE (Migration)

```sql
-- ✅ Add a column with a default (Oracle: must add then set NOT NULL separately)
ALTER TABLE PRODUCT ADD WEIGHT_KG NUMBER(8, 3);

-- Update existing rows before making NOT NULL
UPDATE PRODUCT SET WEIGHT_KG = 0 WHERE WEIGHT_KG IS NULL;

ALTER TABLE PRODUCT MODIFY WEIGHT_KG NOT NULL;

-- ✅ Add a foreign key constraint
ALTER TABLE PRODUCT
    ADD CONSTRAINT FK_PRODUCT_SUPPLIER
    FOREIGN KEY (SUPPLIER_ID) REFERENCES SUPPLIER (ID);
```

---

## DML — INSERT (Reference / Seed Data)

```sql
-- ✅ Use explicit column list — never rely on column order
INSERT INTO CATEGORY (ID, VERSION, CODE, NAME, ACTIVE)
VALUES (SEQ_CATEGORY_ID.NEXTVAL, 0, 'ELEC', 'Electronics', 1);

COMMIT;
```

---

## DML — UPDATE (Migration)

```sql
-- ✅ Always use WHERE clause — never mass-update without filter
UPDATE PRODUCT
SET    ACTIVE = 0,
       MODIFIED_AT = SYSTIMESTAMP
WHERE  PRICE < 0;

COMMIT;
```

---

## DML — DELETE (Migration)

```sql
-- ✅ Always use WHERE clause
DELETE FROM ORDER_LINE
WHERE  ORDER_ID IN (
    SELECT ID FROM ORDER_HEADER WHERE STATUS = 'CANCELLED' AND CREATED_AT < DATE '2020-01-01'
);

COMMIT;
```

---

## H2 Compatibility (for Tests)

```sql
-- H2 uses different syntax for some Oracle features
-- Oracle:                              H2 equivalent:
-- NUMBER(19)                     →    BIGINT
-- NUMBER(12,2)                   →    DECIMAL(12,2)
-- VARCHAR2(100)                  →    VARCHAR(100)
-- SYSTIMESTAMP                   →    CURRENT_TIMESTAMP
-- SEQ.NEXTVAL                    →    NEXT VALUE FOR SEQ
-- NVL(x, y)                      →    COALESCE(x, y)
```

---

## Script Best Practices

| Rule | Example |
|------|---------|
| Name constraints explicitly | `CONSTRAINT PK_PRODUCT PRIMARY KEY (ID)` |
| Always COMMIT DML | `COMMIT;` at end of DML scripts |
| Comment tables and key columns | `COMMENT ON TABLE PRODUCT IS '...'` |
| Separate DDL and DML | Different script files |
| Make scripts idempotent where possible | `CREATE TABLE IF NOT EXISTS` (H2/PG) |
| Include rollback script | `V3__rollback.sql` that reverses `V3__...sql` |
| Avoid `SELECT *` | Always list columns explicitly |

---

## Naming Conventions

| Object | Pattern | Example |
|--------|---------|---------|
| Table | UPPER_SNAKE_CASE | `ORDER_LINE`, `PRODUCT` |
| Column | UPPER_SNAKE_CASE | `ORDER_DATE`, `UNIT_PRICE` |
| Primary Key constraint | `PK_{TABLE}` | `PK_PRODUCT` |
| Unique constraint | `UC_{TABLE}_{COLUMN}` | `UC_PRODUCT_SKU` |
| Foreign Key constraint | `FK_{TABLE}_{REF_TABLE}` | `FK_ORDER_LINE_PRODUCT` |
| Check constraint | `CHK_{TABLE}_{COLUMN}` | `CHK_PRODUCT_PRICE` |
| Index | `IDX_{TABLE}_{COLUMN(S)}` | `IDX_PRODUCT_CATEGORY_ID` |
| Sequence | `SEQ_{TABLE}_ID` | `SEQ_PRODUCT_ID` |
| Migration file | `V{n}__{description}.sql` | `V12__add_weight_column.sql` |

