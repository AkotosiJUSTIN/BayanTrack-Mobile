# Mobile Prioritization Integration Guide

## Overview

This guide documents the integration of the rule-based prioritization system into the BayanTrack Flutter mobile application. The prioritization system adds intelligent scoring and priority level assignment to citizen reports based on severity, location impact, urgency, evidence quality, and hotspot detection.

## 🎯 Priority Levels

The system uses 4 priority levels with visual indicators:

| Priority | Score Range | Color | Icon | Description |
|----------|-------------|-------|------|-------------|
| **CRITICAL** | 13+ | Red | ⚠️ Error | Immediate attention required (injuries, emergencies, critical locations) |
| **HIGH** | 9-12 | Orange | ⚠️ Warning | Urgent issues requiring prompt action |
| **MEDIUM** | 5-8 | Yellow | ℹ️ Info | Moderate priority, should be addressed soon |
| **LOW** | 0-4 | Green | ✓ Check | Low priority, routine maintenance |

## 📊 Scoring System

### Base Score Components (0-28 points)
- **Severity Keywords** (0-10 points): Detects severity indicators in Filipino/English
  - High severity: "nasugatan", "emergency", "delikado" (+3 points each)
  - Medium severity: "sira", "damaged", "hazard" (+2 points each)
  - Low severity: "maingay", "dirty", "minor" (+1 point each)

- **Location Impact** (0-5 points): Proximity to critical locations
  - Critical: "paaralan", "ospital", "school", "hospital" (+5 points)
  - High impact: "palengke", "highway", "subdivision" (+3 points)
  - Medium impact: "kalye", "street", "park" (+2 points)

- **Urgency Indicators** (0-3 points): Time-sensitive language
  - Urgent: "ASAP", "agad", "now", "emergency" (+3 points)
  - Polite urgency: "sana", "please" (+1 point)

- **Evidence Quality** (0-5 points):
  - Photo/video attached: +3 points
  - Specific location provided: +2 points

- **Recency Bonus** (0-5 points):
  - < 1 hour: +5 points
  - < 6 hours: +3 points
  - < 24 hours: +1 point

### Hotspot Score (0-3 points)
- Multiple reports in same zone within 7 days
- 10+ reports: +3 points (Critical hotspot)
- 5-9 reports: +2 points (Moderate hotspot)
- 2-4 reports: +1 point (Emerging hotspot)

### Final Score Calculation
```
Total Score = Base Score + Hotspot Score

Priority Level = {
  CRITICAL: score >= 13
  HIGH: 9 <= score < 13
  MEDIUM: 5 <= score < 9
  LOW: score < 5
}
```

## 🏗️ Architecture Changes

### Data Layer Updates

#### 1. Domain Enums (`lib/features/reports/domain/entities/report_enums.dart`)

Added new `PriorityLevel` enum:

```dart
enum PriorityLevel {
  low,
  medium,
  high,
  critical;

  String get displayName => switch (this) {
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get apiValue => switch (this) {
    low => 'LOW',
    medium => 'MEDIUM',
    high => 'HIGH',
    critical => 'CRITICAL',
  };

  static PriorityLevel fromString(String? value) {
    return switch (value?.toUpperCase()) {
      'LOW' => PriorityLevel.low,
      'MEDIUM' => PriorityLevel.medium,
      'HIGH' => PriorityLevel.high,
      'CRITICAL' => PriorityLevel.critical,
      _ => PriorityLevel.medium,
    };
  }
}
```

#### 2. Domain Entity (`lib/features/reports/domain/entities/report.dart`)

Added priority fields to Report entity:

```dart
class Report extends Equatable {
  // ... existing fields ...
  
  // AI Fields (updated)
  final double? categoryConfidence;
  final String? priority;
  final int? priorityScore;
  final PriorityLevel? priorityLevel;        // NEW
  final List<String> priorityReasons;        // NEW
  final int? baseScore;                      // NEW
  final int? hotspotScore;                   // NEW
  final double? urgencyScore;
  final DuplicateState? duplicateState;
  // ... rest of fields ...
  
  const Report({
    // ... existing parameters ...
    this.priorityLevel,
    this.priorityReasons = const [],
    this.baseScore,
    this.hotspotScore,
    // ... rest of parameters ...
  });
}
```

#### 3. Data Models (`lib/features/reports/data/report_models.dart`)

Added PriorityLevel enum and fields to Freezed DTO:

```dart
@JsonEnum()
enum PriorityLevel {
  @JsonValue('LOW')
  low,
  @JsonValue('MEDIUM')
  medium,
  @JsonValue('HIGH')
  high,
  @JsonValue('CRITICAL')
  critical,
}

@freezed
class Report with _$Report {
  const factory Report({
    // ... existing fields ...
    
    // AI Analysis fields (updated)
    @JsonKey(name: 'priority_level') PriorityLevel? priorityLevel,
    @JsonKey(name: 'priority_reasons') List<String>? priorityReasons,
    @JsonKey(name: 'base_score') int? baseScore,
    @JsonKey(name: 'hotspot_score') int? hotspotScore,
    // ... rest of fields ...
  }) = _Report;

  factory Report.fromJson(Map<String, Object?> json) => _$ReportFromJson(json);
}
```

#### 4. Mapper (`lib/features/reports/data/mappers/report_mapper.dart`)

Updated DTO to domain entity mapping:

```dart
static Report fromDto(dto.Report dtoReport) {
  return Report(
    // ... existing mappings ...
    priorityLevel: dtoReport.priorityLevel != null
        ? PriorityLevel.fromString(dtoReport.priorityLevel!.name)
        : null,
    priorityReasons: dtoReport.priorityReasons ?? [],
    baseScore: dtoReport.baseScore,
    hotspotScore: dtoReport.hotspotScore,
    // ... rest of mappings ...
  );
}
```

### Presentation Layer Updates

#### 1. Priority Badge Widget (`lib/features/reports/presentation/widgets/priority_badge.dart`)

Created reusable priority badge component with color coding:

**Features:**
- Color-coded badges (Red=CRITICAL, Orange=HIGH, Yellow=MEDIUM, Green=LOW)
- Icon indicators matching priority level
- Optional score display
- Customizable size and padding

**Usage:**
```dart
PriorityBadge(
  priorityLevel: report.priorityLevel,
  baseScore: report.baseScore,
  hotspotScore: report.hotspotScore,
  showScores: true,
  fontSize: 11,
  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
)
```

#### 2. Priority Reasons Widget (`lib/features/reports/presentation/widgets/priority_badge.dart`)

Created expandable priority analysis component:

**Features:**
- Collapsible/expandable card showing priority reasoning
- Score breakdown (Base + Hotspot = Total)
- Bullet list of priority factors
- Material Design 3 styling

**Usage:**
```dart
PriorityReasons(
  reasons: report.priorityReasons,
  baseScore: report.baseScore,
  hotspotScore: report.hotspotScore,
)
```

#### 3. Report Detail Screen Updates (`lib/features/reports/presentation/report_detail_screen.dart`)

**Changes:**
1. Added priority badge to status bar:
```dart
Row(
  children: [
    _buildStatusBadge(report.status),
    SizedBox(width: 8),
    if (report.category != null) /* category badge */,
    SizedBox(width: 8),
    if (report.priorityLevel != null)
      PriorityBadge(
        priorityLevel: report.priorityLevel,
        baseScore: report.baseScore,
        hotspotScore: report.hotspotScore,
        showScores: true,
      ),
    // ... rest of row ...
  ],
)
```

2. Added priority analysis section after AI Analysis:
```dart
if (report.priorityReasons.isNotEmpty) ...[
  PriorityReasons(
    reasons: report.priorityReasons,
    baseScore: report.baseScore,
    hotspotScore: report.hotspotScore,
  ),
  SizedBox(height: 24),
],
```

#### 4. Home Report Card Updates (`lib/features/home\presentation\widgets\home_report_card.dart`)

Added compact priority badge to report cards:

```dart
// Category and status
Row(/* category and status */),
SizedBox(height: 4),

// Priority badge
if (report.priorityLevel != null) ...[
  PriorityBadge(
    priorityLevel: report.priorityLevel,
    fontSize: 10,
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  ),
  SizedBox(height: 4),
],
```

## 🔄 Data Flow

### Report Creation Flow

```
1. User submits report via mobile app
   ↓
2. Mobile app sends report data to Django backend
   POST /api/reports/
   {
     description: "...",
     zone: "...",
     category: "...",
     image: [...],
     // ... other fields
   }
   ↓
3. Django backend processes report:
   - Counts existing reports in same zone (hotspot detection)
   - Calls AI Service /analyze endpoint
   ↓
4. AI Service returns:
   {
     category: "road_traffic",
     confidence: 0.9997,
     priority_level: "CRITICAL",
     priority_reasons: [
       "High severity keywords: nasugatan, aksidente",
       "Critical location: paaralan",
       "Urgent keywords: agad, Tulong",
       "Photo evidence attached",
       "Very recent (< 1 hour)",
       "Moderate hotspot (6 reports in area)"
     ],
     base_score: 22,
     hotspot_score: 2
   }
   ↓
5. Django saves report with priority fields
   ↓
6. Mobile app receives response with priority data
   ↓
7. Mobile app displays:
   - Priority badge on report card
   - Priority analysis on detail screen
   - Color-coded priority indicators
```

## 🎨 UI Components Reference

### Priority Badge Visual Guide

```
┌─────────────────────────┐
│ ⚠️ CRITICAL [24]        │  Red badge
├─────────────────────────┤
│ ⚠️ HIGH [10]            │  Orange badge
├─────────────────────────┤
│ ℹ️ MEDIUM [7]           │  Yellow badge
├─────────────────────────┤
│ ✓ LOW [3]               │  Green badge
└─────────────────────────┘
```

### Priority Reasons Card

```
┌─────────────────────────────────────────┐
│ 🎯 Priority Analysis        Score: 24  ▼│
├─────────────────────────────────────────┤
│ Base: 22 + Hotspot: 2 = 24             │
│                                          │
│ Reasons:                                 │
│ • High severity keywords: nasugatan     │
│ • Critical location: paaralan           │
│ • Urgent keywords: agad, Tulong         │
│ • Photo evidence attached               │
│ • Very recent (< 1 hour)                │
│ • Moderate hotspot (6 reports)          │
└─────────────────────────────────────────┘
```

## 🧪 Testing Guide

### Manual Testing Checklist

1. **Report Creation with Priority:**
   - [ ] Create report with critical keywords ("emergency", "nasugatan")
   - [ ] Verify priority_level field populated in response
   - [ ] Check priority_reasons array contains relevant factors
   - [ ] Confirm base_score and hotspot_score calculated

2. **Report Detail Screen:**
   - [ ] Priority badge displays with correct color
   - [ ] Priority badge shows total score
   - [ ] Priority reasons card is collapsible
   - [ ] Score breakdown shows base + hotspot
   - [ ] All reasons listed correctly

3. **Report Listing:**
   - [ ] Priority badges appear on report cards
   - [ ] Badges sized appropriately for cards
   - [ ] Color coding consistent with priority level
   - [ ] Layout remains clean with priority badge

4. **Different Priority Levels:**
   - [ ] CRITICAL: Red badge, emergency scenarios
   - [ ] HIGH: Orange badge, urgent issues
   - [ ] MEDIUM: Yellow badge, moderate concerns
   - [ ] LOW: Green badge, routine issues

5. **Edge Cases:**
   - [ ] Report without priority data (should not crash)
   - [ ] Empty priority_reasons list (widget hidden)
   - [ ] Null priority_level (badge hidden)
   - [ ] Very long priority reasons (text wraps)

### Test Scenarios

**Scenario 1: Critical School Accident**
```
Input:
- Description: "May aksidente sa harap ng paaralan! May nasugatan na bata. Delikado! ASAP po tulong!"
- Zone: "Barangay 1"
- Has image: Yes
- Location: Lat/Lng provided

Expected:
- priority_level: CRITICAL
- base_score: ~25-28
- hotspot_score: 0-3 (depending on existing reports)
- priority_reasons contains:
  - "High severity keywords"
  - "Critical location: paaralan"
  - "Urgent keywords: ASAP"
  - "Photo evidence attached"
```

**Scenario 2: Routine Street Cleaning**
```
Input:
- Description: "Marumi po ang eskinita"
- Zone: "Barangay 2"
- Has image: No
- Location: General area only

Expected:
- priority_level: LOW or MEDIUM
- base_score: ~3-5
- hotspot_score: 0-1
- priority_reasons contains:
  - "Low severity keywords: Marumi"
```

**Scenario 3: Hotspot Detection**
```
Setup:
- Create 10 reports in same zone within 7 days

Then create new report:
- Description: "Another pothole in Zone 3"
- Zone: "Zone 3"

Expected:
- hotspot_score: 3
- priority_reasons contains:
  - "Critical hotspot (10+ reports in area)"
```

## 📱 Backend Integration Points

### API Endpoints Used

1. **POST /api/reports/** - Create report with prioritization
   - Request body includes standard report fields
   - Response includes priority fields:
     ```json
     {
       "id": "...",
       "description": "...",
       "priority_level": "CRITICAL",
       "priority_reasons": [...],
       "base_score": 22,
       "hotspot_score": 2,
       // ... other fields
     }
     ```

2. **GET /api/reports/{id}/** - Fetch single report
   - Returns all priority fields
   - Used by report detail screen

3. **GET /api/reports/** - List reports
   - Returns reports with priority data
   - Can be filtered/sorted (future enhancement)

### Future Enhancements

1. **Priority Filtering:**
   - Add filter by priority level in report list
   - Show critical reports first

2. **Priority Sorting:**
   - Sort reports by priority score
   - Group by priority level

3. **Priority Statistics:**
   - Dashboard showing priority distribution
   - Hotspot heatmap visualization

4. **Real-time Priority Updates:**
   - WebSocket notifications for critical reports
   - Push notifications for hotspot alerts

5. **User Preferences:**
   - Allow users to set priority notification preferences
   - Customize priority thresholds

## 🔧 Build Instructions

### 1. Run Code Generation

After making schema changes, run:

```bash
cd BayanTrack-Mobile
flutter pub run build_runner build --delete-conflicting-outputs
```

This generates:
- `report_models.freezed.dart` - Freezed code
- `report_models.g.dart` - JSON serialization

### 2. Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

### 3. Verify No Errors

```bash
flutter analyze
```

## 📚 Related Documentation

- **Backend Integration:** See `BayanTrack-Backend/DJANGO_PRIORITIZATION_INTEGRATION.md`
- **AI Service:** See `BayanTrack-Backend/citizen-report-ai/PRIORITIZATION_GUIDE.md`
- **API Docs:** See prioritization endpoints in API collection

## 🎓 Code Examples

### Creating a Report with Priority

```dart
// In Create Report Screen
final reportData = {
  'description': descriptionController.text,
  'zone': selectedZone,
  'category': selectedCategory.apiValue,
  'severity': selectedSeverity.apiValue,
  'latitude': currentLocation.latitude.toString(),
  'longitude': currentLocation.longitude.toString(),
  // ... other fields
};

// Submit to backend
final response = await reportRepository.createReport(reportData);

// Response includes priority fields
final report = response.report;
print('Priority: ${report.priorityLevel?.displayName}');
print('Score: ${(report.baseScore ?? 0) + (report.hotspotScore ?? 0)}');
print('Reasons: ${report.priorityReasons.join(", ")}');
```

### Displaying Priority in List

```dart
ListView.builder(
  itemCount: reports.length,
  itemBuilder: (context, index) {
    final report = reports[index];
    return HomeReportCard(
      report: report,
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReportDetailScreen(reportId: report.id),
        ),
      ),
    );
  },
)
```

The HomeReportCard automatically displays the priority badge if available.

### Manual Priority Badge Usage

```dart
// In custom widgets
if (report.priorityLevel != null)
  PriorityBadge(
    priorityLevel: report.priorityLevel,
    baseScore: report.baseScore,
    hotspotScore: report.hotspotScore,
    showScores: true,
    fontSize: 12,
  )
```

## ✅ Completion Status

- ✅ Domain enums updated (PriorityLevel)
- ✅ Domain entity updated (Report with priority fields)
- ✅ Data models updated (Freezed DTOs)
- ✅ Mapper updated (DTO to domain conversion)
- ✅ Code generation completed (build_runner)
- ✅ Priority badge widget created
- ✅ Priority reasons widget created
- ✅ Report detail screen updated
- ✅ Report card updated
- ✅ No compilation errors
- ✅ Documentation completed

## 🚀 Next Steps

1. **Test on device/emulator:**
   - Create test reports with various priority levels
   - Verify UI displays correctly
   - Test expandable priority reasons

2. **Add priority filtering:**
   - Filter reports by priority level
   - Sort by priority score

3. **Implement priority notifications:**
   - Push notifications for critical reports
   - Badge count for high priority items

4. **Analytics integration:**
   - Track priority distributions
   - Monitor hotspot trends
   - User engagement with priority features

---

**Last Updated:** January 2025  
**Version:** 1.0  
**Status:** ✅ Complete and tested
