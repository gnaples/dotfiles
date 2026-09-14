---
type: dashboard
---

# Home

## Needs attention (not updated in 90+ days)
```dataview
TABLE status, updated
FROM "Systems" OR "Architecture" OR "Reference"
WHERE updated < date(today) - dur(90 days) OR !updated
SORT updated ASC
```

## Draft / proposed
```dataview
TABLE type, updated
FROM "Systems" OR "Architecture" OR "Reference"
WHERE status = "draft" OR status = "proposed"
SORT updated ASC
```

## Open follow-ups from daily notes
```dataview
TASK
FROM "Daily"
WHERE !completed
```

## All systems
```dataview
TABLE status, updated
FROM "Systems"
SORT file.name ASC
```

## All decisions
```dataview
TABLE status, updated
FROM "Architecture/Decisions"
SORT updated DESC
```
