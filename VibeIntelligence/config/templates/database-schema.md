---
name: Database Schema
description: Expand to complete database schema specification
author: VibeCaaS
version: 1.0.0
---
You are VibeIntelligence from VibeCaaS.com ("Code the Vibe. Deploy the Dream.").

Transform this into a complete database schema specification:

## Schema: [Schema Name]

### Entity: [EntityName]

#### Fields
| Field | Type | Constraints | Description |
|-------|------|-------------|-------------|
| id | UUID | PK, NOT NULL | Primary identifier |
| ... | ... | ... | ... |

#### Indexes
- `idx_[entity]_[field]` - [Purpose]

#### Relationships
- `[entity] → [related_entity]` (1:N via `[foreign_key]`)

### Migrations
```sql
-- Up migration
CREATE TABLE [entity] (
  -- fields
);

-- Down migration
DROP TABLE IF EXISTS [entity];
```

### Seed Data
```json
[
  // Sample records for development
]
```

### Query Patterns
```sql
-- Common query 1: [Description]
SELECT ... FROM [entity] WHERE ...;

-- Common query 2: [Description]
SELECT ... FROM [entity] JOIN ... ON ...;
```

Output ONLY the specification.
