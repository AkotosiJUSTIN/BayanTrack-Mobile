# Mobile AI Integration Guide

## New Report Flow (Automatic AI Classification)

```
Mobile App:
1. Photos Screen → Select images
2. Location Screen → Set location (GPS/manual)
3. Details Screen → Enter title, description (NO category)
4. Review Screen → Consent & Submit
                ↓
            createReport() API (no category field)
                ↓
Backend:
1. Receive report → AI classifies description
2. Save to MongoDB with AI category + confidence
3. Save hash to Blockchain (immutable record)
4. Return report with assigned category
```

## Changes Needed

### Mobile App: REMOVE Category Selection

**What to change:**

1. Remove category dropdown from Details Screen
2. Remove category field from CreateReportRequest
3. Backend assigns category automatically

---

## Implementation

### 1. Update Mobile Models

```dart
// In lib/features/reports/data/reports_repository.dart

/// Classify report text using AI
Future<CategoryPrediction> classifyReport(String description) async {
  final response = await _dio.post(
    '/api/reports/classify',  // New endpoint
    data: {'description': description},
  );
  return CategoryPrediction.fromJson(response.data);
}
```

#### 2. Add Model for AI Response

```dart
// In lib/features/reports/data/report_models.dart

@freezed
class CategoryPrediction with _$CategoryPrediction {
  const factory CategoryPrediction({
    required String category,
    required double confidence,
    Map<String, double>? allScores,
  }) = _CategoryPrediction;

  factory CategoryPrediction.fromJson(Map<String, dynamic> json) =>
      _$CategoryPredictionFromJson(json);
}
```

#### 3. Update Controller

```dart
// In new_report_controller.dart

class NewReportState {
  // Add these fields
  final CategoryPrediction? aiSuggestion;
  final bool isAnalyzing;
  final bool userOverrodeAI;  // Track if user changed AI suggestion
}

// Add methods
void setAISuggestion(CategoryPrediction? prediction) {
  state = state.copyWith(aiSuggestion: prediction);
}

void setAnalyzing(bool value) {
  state = state.copyWith(isAnalyzing: value);
}

void acceptAISuggestion() {
  if (state.aiSuggestion != null) {
    setCategory(ReportCategory.fromString(state.aiSuggestion!.category));
    state = state.copyWith(userOverrodeAI: false);
  }
}

// Modify setCategory to track manual changes
void setCategory(ReportCategory? category) {
  final isOverride = state.aiSuggestion != null && 
                     category?.value != state.aiSuggestion?.category;
  state = state.copyWith(
    category: category,
    userOverrodeAI: isOverride,
  );
}
```

#### 4. Update Details Screen UI

```dart
// In new_report_details_screen.dart

// Add after description field
if (state.description.length > 20)
  Padding(
    padding: const EdgeInsets.only(top: 8),
    child: OutlinedButton.icon(
      icon: state.isAnalyzing
          ? SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(Icons.auto_awesome),
      label: Text('Analyze with AI'),
      onPressed: state.isAnalyzing ? null : () async {
        controller.setAnalyzing(true);
        try {
          final repo = ref.read(reportsRepositoryProvider);
          final prediction = await repo.classifyReport(state.description);
          controller.setAISuggestion(prediction);
          
          // Show suggestion dialog
          _showAISuggestionDialog(prediction);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('AI analysis failed: $e')),
          );
        } finally {
          controller.setAnalyzing(false);
        }
      },
    ),
  ),

// Show AI suggestion if available
if (state.aiSuggestion != null) ...[
  const SizedBox(height: 8),
  Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(Icons.lightbulb_outline, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Suggestion:',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                ReportCategory.fromString(state.aiSuggestion!.category).displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(state.aiSuggestion!.confidence * 100).toStringAsFixed(0)}% confidence',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
        if (!state.userOverrodeAI)
          TextButton(
            onPressed: controller.acceptAISuggestion,
            child: Text('Accept'),
          ),
      ],
    ),
  ),
],
```

#### 5. Show Suggestion Dialog

```dart
void _showAISuggestionDialog(CategoryPrediction prediction) {
  final suggestedCategory = ReportCategory.fromString(prediction.category);
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.auto_awesome, color: AppColors.primary),
          const SizedBox(width: 8),
          Text('AI Analysis Complete'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Based on your description, this appears to be:'),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  suggestedCategory.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: prediction.confidence,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(prediction.confidence * 100).toStringAsFixed(1)}% confident',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Ignore'),
        ),
        FilledButton(
          onPressed: () {
            controller.acceptAISuggestion();
            Navigator.pop(context);
          },
          child: Text('Accept'),
        ),
      ],
    ),
  );
}
```

---

### Option 2: Auto-Classify on Submit (Silent)

**When:** In review screen, classify before sending to backend

**Pros:** 
- No extra UI
- Backend gets category immediately

**Cons:**
- User never sees the AI working
- No way to correct if AI is wrong

**Implementation:**

```dart
// In new_report_review_screen.dart, modify _submitReport()

Future<void> _submitReport() async {
  setState(() {
    _isSubmitting = true;
    _statusMessage = 'Analyzing report...';
  });

  try {
    final reportsRepo = ref.read(reportsRepositoryProvider);
    
    // Classify if category not set
    var request = state.toCreateRequest();
    if (request.category == null && state.description.isNotEmpty) {
      final prediction = await reportsRepo.classifyReport(state.description);
      request = request.copyWith(
        category: prediction.category,
        // Add AI metadata
        categoryConfidence: prediction.confidence,
      );
    }

    setState(() => _statusMessage = 'Creating report...');
    final createdReport = await reportsRepo.createReport(request);
    
    // ... rest of submission
  } catch (e) {
    // ... error handling
  }
}
```

---

## Backend Endpoint Needed

```python
# In backend/reports/services.py

import sys
import os

# Initialize AI classifier (do once at startup)
AI_PATH = os.path.join(os.path.dirname(__file__), '../../citizen-report-ai')
sys.path.insert(0, AI_PATH)

from inference.enhanced_classifier import EnhancedClassifier
from inference.predict import ReportClassifier
from inference.prediction_logger import PredictionLogger

# Global instances
_enhanced_classifier = None
_base_classifier = None
_prediction_logger = None

def get_ai_classifier():
    global _enhanced_classifier, _base_classifier, _prediction_logger
    if _enhanced_classifier is None:
        _enhanced_classifier = EnhancedClassifier()
        model_path = os.path.join(AI_PATH, 'models/distilbert')
        _base_classifier = ReportClassifier(model_path)
        _prediction_logger = PredictionLogger()
    return _enhanced_classifier, _base_classifier, _prediction_logger


def classify_report_description(description: str) -> dict:
    """
    Classify report using AI model.
    
    Returns:
        {
            'category': str,
            'confidence': float,
            'all_scores': dict
        }
    """
    if not description or len(description) < 20:
        return {
            'category': None,
            'confidence': 0.0,
            'error': 'Description too short'
        }
    
    try:
        enhanced, base, logger = get_ai_classifier()
        
        # Get category with post-processing rules
        category = enhanced.predict(description)
        
        # Get confidence and all scores
        result = base.predict(description)
        
        return {
            'category': category,
            'confidence': result['confidence'],
            'all_scores': result.get('all_scores', {})
        }
    except Exception as e:
        logger.error(f'AI classification failed: {e}')
        return {
            'category': None,
            'confidence': 0.0,
            'error': str(e)
        }
```

### 2. Update Report Creation View

```python
# In backend/reports/views.py

from .services import classify_report_description
from inference.prediction_logger import PredictionLogger

logger = PredictionLogger()

class ReportCreateView(APIView):
    @jwt_required
    def post(self, request):
        # Get report data
        description = request.data.get('description', '')
        title = request.data.get('title')
        
        # AI Classification (automatic)
        ai_result = classify_report_description(description)
        
        if ai_result.get('error'):
            return Response({
                'error': 'Could not classify report',
                'details': ai_result['error']
            }, status=400)
        
        # Create report with AI-assigned category
        report = Report.create(
            user_id=request.user.id,
            title=title,
            description=description,
            category=ai_result['category'],  # AI-assigned
            ai_confidence=ai_result['confidence'],
            ai_all_scores=ai_result.get('all_scores'),
            status='submitted',
            # ... other fields from request
        )
        
        # Log prediction for retraining
        logger.log_prediction(
            report_id=str(report._id),
            text=description,
            predicted_category=ai_result['category'],
            confidence=ai_result['confidence']
        )
        
        # Save to blockchain (optional)
        try:
            from backend.blockchain.service import BlockchainService
            blockchain = BlockchainService()
            content_hash = blockchain.hash_report(report)
            tx_hash = blockchain.submit_to_blockchain(
                str(report._id),
                content_hash
            )
            report.blockchain_tx = tx_hash
            report.save()
        except Exception as e:
            logger.warning(f'Blockchain save failed: {e}')
            # Don't fail the request if blockchain fails
        
        return Response({
            'report': ReportSerializer(report).data,
            'ai_classification': {
                'category': ai_result['category'],
                'confidence': f"{ai_result['confidence']:.2%}"
            },
            'message': 'Report created successfully'
        }, status=201)
```

### 3. Allow Officials to Correct AI Category

```python
# In backend/reports/views.py

class ReportUpdateCategoryView(APIView):
    @jwt_required
    @role_required(['official', 'admin'])
    def patch(self, request, report_id):
        report = Report.get(report_id)
        
        new_category = request.data['category']
        correction_notes = request.data.get('notes', '')
        
        # Update report
        old_category = report.category
        report.category = new_category
        report.manual_category_override = True
        report.save()
        
        # Log correction for AI improvement
        logger.update_correction(
            report_id=report_id,
            manual_category=new_category,
            notes=f"Changed from {old_category}. {correction_notes}"
        )
        
        return Response({'success': True})
```

---

## Updated Flow Diagram

```
┌──────────────────────────────────────────────────────────────┐
│                        MOBILE APP                            │
│                                                              │
│  User creates report:                                        │
│  - Photos                                                    │
│  - Location                                                  │
│  - Title + Description (NO category selection)              │
│  - Submit                                                    │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    DJANGO BACKEND                            │
│                                                              │
│  POST /api/reports/                                          │
│  ├─ 1. Receive report data                                  │
│  ├─ 2. AI classifies description                            │
│  │     → category + confidence                              │
│  ├─ 3. Save to MongoDB                                      │
│  │     - Report with AI category                            │
│  │     - Confidence score                                   │
│  ├─ 4. Log prediction (for retraining)                      │
│  └─ 5. Save hash to Blockchain (optional)                   │
│                                                              │
│  Response: Report with assigned category                     │
└──────────────────────────────────────────────────────────────┘
```

---

## Benefits of Backend-Only Classification

✅ **Simple UX** - Users don't need to understand categories  
✅ **Consistent** - All reports use same AI  
✅ **Fast** - No extra API calls from mobile  
✅ **Accurate** - Enhanced classifier with post-processing  
✅ **Trackable** - Log all predictions for improvement  
✅ **Correctable** - Officials can override if AI is wrong  

---

## Testing Checklist

- [ ] Reports created without category field
- [ ] Backend assigns category automatically
- [ ] Category visible in report details
- [ ] Confidence score saved to DB
- [ ] Low confidence reports flagged for review
- [ ] Officials can correct miscategorized reports
- [ ] Corrections logged for retraining
- [ ] Blockchain hash saved (if enabled)

---

## Mobile UI (Simplified - No Category)

```
┌─────────────────────────────────────┐
│ New Report                     [X] │
├─────────────────────────────────────┤
│                                     │
│ Title (Optional)                    │
│ ┌─────────────────────────────────┐ │
│ │ Lubak sa kalsada                │ │
│ └─────────────────────────────────┘ │
│                                     │
│ Description *                       │
│ ┌─────────────────────────────────┐ │
│ │ May malaking butas sa tapat ng  │ │
│ │ bahay namin. Delikado na kasi   │ │
│ │ malalim at madilim pag gabi     │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ℹ️ AI will categorize your report   │
│    automatically                    │
│                                     │
│              [Continue →]           │
└─────────────────────────────────────┘
```

After submission:
```
┌─────────────────────────────────────┐
│ ✅ Report Submitted                 │
├─────────────────────────────────────┤
│                                     │
│ Your report has been categorized as:│
│                                     │
│ 🚗 Road & Traffic Issues            │
│                                     │
│ Report ID: #12345                   │
│ Status: Under Review                │
│                                     │
│         [View My Reports]           │
└─────────────────────────────────────┘
```
