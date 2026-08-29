# Mobile priority integration

Last updated: August 24, 2026

The Mobile application consumes priority values calculated and persisted by
the Backend. It does not score report text, apply keyword points, detect
hotspots, or reconstruct the priority rubric.

## Priority contract

The current system uses five levels.

| Score | API value | Display label |
| --- | --- | --- |
| 0-20 | `VERY_LOW` | Very low |
| 21-40 | `LOW` | Low |
| 41-60 | `MEDIUM` | Medium |
| 61-80 | `HIGH` | High |
| 81-100 | `CRITICAL` | Critical |

The main report fields are:

| Field | Mobile use |
| --- | --- |
| `suggested_priority_score` | AI model score from `0` to `100`. |
| `suggested_priority_level` | Level derived from the AI score. |
| `queue_priority_score` | Backend operational queue score. |
| `queue_priority_level` | Backend operational queue level. |
| `staff_priority_level` | Explicit staff-selected level, when present. |
| `priority_components` | Deterministic rubric factors for compatibility. |
| `priority_review_reasons` | Policy reasons attached to the suggestion. |

Legacy fields such as `priority_level`, `priority_score`, `base_score`, and
`hotspot_score` remain optional compatibility inputs. New Mobile behavior does
not calculate from those legacy values.

## Display precedence

`Report.displayPriorityLevel` selects the first available value in this order:

```dart
queuePriorityLevel ?? suggestedPriorityLevel ?? priorityLevel
```

This keeps Mobile aligned with the Backend queue while still displaying older
reports that only contain a suggested or legacy level.

Report lists sort by `queuePriorityLevel` where queue ordering is required.
The detail screen and report cards use `displayPriorityLevel` for the badge.

## Data path

```text
POST /api/reports/
        |
        v
Django calls FastAPI /analyze
        |
        v
Django applies priority policy and stores the report
        |
        v
GET /api/reports/ or GET /api/reports/{id}/
        |
        v
Report DTO -> mapper -> domain Report -> PriorityBadge
```

Relevant files:

- `lib/features/reports/data/report_models.dart`
- `lib/features/reports/data/mappers/report_mapper.dart`
- `lib/features/reports/domain/entities/report.dart`
- `lib/features/reports/domain/entities/report_enums.dart`
- `lib/features/reports/presentation/widgets/priority_badge.dart`
- `lib/features/reports/presentation/report_detail_screen.dart`
- `lib/features/home/presentation/widgets/home_report_card.dart`

## Priority explanation metadata

The Backend also returns `priority_components`, which contains:

```text
hazard_severity
human_impact
infrastructure_damage
service_disruption
immediacy
component_total
safety_floor
rubric_total
```

These values come from a deterministic `severity_rubric_v2` calculation. They
are not individual outputs or attributions from the neural priority model.
The full factor explanation currently appears in the Web staff report detail
view. Mobile retains the map so future citizen-facing presentation can use the
same Backend data without adding a second scoring implementation.

See the shared
[AI suggestion and explanation contract](../docs/ai-explanations.md) for the
formula and distinction between AI suggestions and operational values.

## Compatibility behavior

- Missing optional AI fields do not block report parsing.
- Unknown response fields remain safe for older Mobile builds.
- A missing priority level hides the badge instead of inventing a default.
- Mobile does not derive a level from `priority_components`.
- Mobile does not use department suggestions as an assignment.

## Verification

Run from `BayanTrack-Mobile`:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Manual checks:

1. Open reports containing each of the five priority levels.
2. Confirm the list and detail badge match `queue_priority_level` when present.
3. Confirm a report with only `suggested_priority_level` still displays.
4. Confirm an older report with only `priority_level` still displays.
5. Confirm a report without priority metadata opens without an error.
