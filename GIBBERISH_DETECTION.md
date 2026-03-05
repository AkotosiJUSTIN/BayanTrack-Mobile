# Gibberish Detection in Mobile Report Submission

## Overview
The BayanTrack mobile app now includes automatic gibberish and nonsense text detection for report submissions. This feature prevents users from submitting low-quality or invalid reports before they reach the backend.

## Implementation

### Location
- **Validator**: `lib/core/utils/validators.dart` - `Validators.reportText()`
- **Usage**: `lib/features/reports/presentation/new_report/new_report_details_screen.dart`
- **Tests**: `test/core/utils/validators_test.dart`

### Detection Criteria

The gibberish detector checks for the following patterns:

1. **Minimum Length**: Requires at least 10 characters for meaningful descriptions
2. **Placeholder Text**: Rejects common placeholders like "n/a", "tbd", "test", "none", "todo"
3. **Character Repetition**: Detects excessive repetition like "aaaaaaa" or "hahahaha"
4. **Keyboard Mashing**: Identifies patterns like "qwertyuiop", "asdfghjkl", "123456"
5. **Excessive Consonants/Vowels**: Flags unusual sequences (6+ consonants, 5+ vowels)
6. **Word Structure**: Ensures text has reasonable word patterns
7. **Special Characters**: Prevents excessive use of non-alphabetic characters

### User Experience

When users attempt to submit gibberish text, they see helpful error messages:
- "Please provide a more detailed description (at least 10 characters)"
- "Please provide a meaningful description of the issue instead of 'n/a'" (for placeholder text)
- "Please enter a meaningful description without excessive repetition"
- "Please enter a valid description (keyboard mashing detected)"
- "Please enter a coherent description"
- "Please provide a meaningful description with proper words"

### Validation Scope

The gibberish detection is applied to:
- **Report Description** (required field): Full validation
- **Report Title** (optional field): Only validated if text is provided

### Language Support

The validator supports both English and Filipino text, ensuring natural language patterns are accepted while filtering out nonsense.

### Examples

**Accepted**:
- "There is a broken streetlight on Main Street that needs repair"
- "May nakaharang na basura sa daanan, kailangan po ng linis"
- "Report #123: Broken streetlight at 10:30 PM on Baker St."

**Rn/a" (placeholder text)
- "test" (placeholder text)
- "tbd" (placeholder text)
- "ejected**:
- "qwertyuiop asdfghjkl" (keyboard mashing)
- "aaaaaaaaaa" (excessive repetition)
- "short" (too short)
- "!@#$%^&*()!@#$%^&*()" (excessive special characters)

## Testing

Run the validator tests:
```bash
cd BayanTrack-Mobile
flutt2 test cases should pass, covering:
- Valid descriptions
- Empty/short descriptions
- Placeholder text (n/a, test, tbd, etc.)
All 11 test cases should pass, covering:
- Valid descriptions
- Empty/short descriptions
- Character repetition
- Keyboard mashing
- Consonant/vowel patterns
- Word structure
- Special characters
- Optional field behavior
- Edge cases
- Filipino language support

## Technical Details

The validator uses multiple heuristics:
- Regular expressions for pattern matching
- Statistical analysis of character types
- Word structure validation
- Language-agnostic checks

The validation runs in real-time as users type (with debouncing) and again on form submission, providing immediate feedback without blocking the UI.
