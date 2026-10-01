# Mobile priority integration

Updated October 1, 2026. Mobile consumes Backend priority levels and does not
calculate priority from report text.

## Contract

| Level | API label | Display |
| --- | --- | --- |
| 1 | `very_low` | Very low |
| 2 | `low` | Low |
| 3 | `medium` | Medium |
| 4 | `high` | High |
| 5 | `critical` | Critical |

Report fields use integer `priority_rank`, `suggested_priority_rank`, and
`queue_priority_rank`, together with their corresponding level names.
`staff_priority_level` records the staff decision. `priority_factors` contains
qualitative evidence, and `priority_review_reasons` explains review flags.
There are no point scores, weighted components, or base/hotspot additions.
A queue rank of zero means unassigned; it is not a predicted priority level.

The Backend converts old stored scores to levels before returning reports.
Missing optional metadata remains safe for parsing. Unknown response fields
are ignored. Mobile does not reconstruct legacy score calculations.

## Display

`Report.displayPriorityLevel` uses:

```dart
queuePriorityLevel ?? suggestedPriorityLevel ?? priorityLevel
```

Report lists and details use the same effective level. `PriorityBadge` can
show an integer rank out of five when `showRank` is enabled. A missing level
hides the badge. `PriorityReasons` displays reasons without numerical
component breakdowns.

Staff and emergency queue decisions remain Backend policy. Category and
department probabilities retain their separate confidence displays.

## Data path

```text
FastAPI /analyze -> Django priority policy and storage
                -> Report API -> DTO -> ReportMapper -> domain Report
                -> PriorityBadge
```

The DTO and domain model retain qualitative `priorityFactors` for consistent
report metadata. They do not treat these factors as verified neural
attributions or calculate a new priority from them.

Restart the AI and Backend services and rebuild clients together for the
updated contract. See the Backend priority guide at
`ai-triage/prioritization/README.md` for migration and training details.

## Verify

Run from the Mobile repository root:

```powershell
flutter test test/features/reports/priority_level_contract_test.dart `
  test/features/reports/reports_repository_test.dart `
  test/features/reports/reports_repository_impl_test.dart `
  test/features/reports/report_detail_screen_test.dart
```

The new contract checks cover all five levels, qualitative factors, removal
of score fields from serialization, and badge display as `4 / 5`.
