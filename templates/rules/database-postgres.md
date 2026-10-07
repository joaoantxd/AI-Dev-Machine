---
name: database-postgres
description: PostgreSQL and Supabase schema design, RLS security policies, and query performance.
trigger: model_decision
---

# PostgreSQL & Supabase Database Rules

## 1. Schema & Migrations Discipline
- All database schema changes must be written as reversible, version-controlled SQL migrations.
- Avoid modifying existing applied migrations; create new forward migrations.
- Always include explicit `NOT NULL`, foreign key constraints, and default values.

## 2. Row Level Security (RLS) & Authorization
- Every table holding tenant or user data must have RLS enabled (`ALTER TABLE ... ENABLE ROW LEVEL SECURITY;`).
- Write explicit policies for `SELECT`, `INSERT`, `UPDATE`, and `DELETE`.
- Test RLS policies with both authenticated and anonymous roles.

## 3. Query Performance & Indexing
- Index all foreign key columns and frequently filtered columns.
- Use composite indexes where queries filter on multiple columns.
- Validate slow queries with `EXPLAIN ANALYZE` before deploying to production.
