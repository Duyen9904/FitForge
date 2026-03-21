# Onboarding API Contract — Frontend Reference

> **Base URL**: `/api/v1/onboarding`
> **Auth**: All endpoints require `Bearer` token in `Authorization` header.

---

## Endpoints Overview

| Method | Path | Description |
|--------|------|-------------|
| `GET` | `/flow` | Get all steps + user progress |
| `POST` | `/steps/{stepId}/submit` | Submit response for a step |
| `POST` | `/steps/{stepId}/skip` | Skip an optional step |
| `POST` | `/complete` | Mark onboarding as done |
| `GET` | `/status` | Check if onboarding is complete |

---

## Submit Step — `POST /steps/{stepId}/submit`

**Request body** (for all step types):

```json
{
  "responseData": "<JSON string>"
}
```

> ⚠️ `responseData` is a **JSON-encoded string**, not a nested object.

---

## Required `responseData` Format Per Step Type

The backend uses the step's `stepType` (returned in `GET /flow`) to decide how to parse `responseData`.  
**The keys below are the EXACT keys the backend checks. Using different keys will silently fail — the data won't be saved.**

---

### 1. `GENDER`

Sets `user.gender` column.

```json
// Option A (preferred — matches SINGLE_CHOICE input type)
{ "selected": "MALE" }

// Option B
{ "gender": "FEMALE" }
```

| Key | Type | Values |
|-----|------|--------|
| `selected` **or** `gender` | `string` | `"MALE"`, `"FEMALE"` |

> ❌ **Will NOT work**: `{"selectedOption": "MALE"}`, `{"value": "MALE"}`

---

### 2. `AGE`

Sets `user.date_of_birth` (calculated as today minus age in years).

```json
// Option A (preferred)
{ "value": 25 }

// Option B
{ "age": 25 }
```

| Key | Type |
|-----|------|
| `value` **or** `age` | `integer` |

---

### 3. `WEIGHT`

Sets `user.current_weight_kg`.

```json
// Option A (preferred)
{ "value": 70.5 }

// Option B
{ "weight": 70.5 }
```

| Key | Type | Unit |
|-----|------|------|
| `value` **or** `weight` | `number` | kg |

> ⚠️ This does **NOT** set `target_weight_kg`. For target weight, use `BODY_METRICS`.

---

### 4. `HEIGHT`

Sets `user.height_cm`.

```json
// Option A (preferred)
{ "value": 175 }

// Option B
{ "height": 175 }
```

| Key | Type | Unit |
|-----|------|------|
| `value` **or** `height` | `number` | cm |

---

### 5. `BODY_METRICS`

Sets `user.current_weight_kg`, `user.height_cm`, and `user.target_weight_kg` in one step.

```json
{
  "weight": 70.5,
  "height": 175,
  "targetWeight": 68
}
```

| Key | Type | Unit | Required |
|-----|------|------|----------|
| `weight` | `number` | kg | optional |
| `height` | `number` | cm | optional |
| `targetWeight` | `number` | kg | optional |

> ⚠️ `targetWeight` is **ONLY parsed in the `BODY_METRICS` step type**. If your onboarding has separate `WEIGHT`/`HEIGHT` steps instead of a combined `BODY_METRICS` step, `targetWeight` will have **no place to be saved** unless you add it to `BODY_METRICS` or the `WEIGHT` step.

---

### 6. `FITNESS_LEVEL`

Sets `user.fitness_level` column.

```json
// Option A (preferred — matches SINGLE_CHOICE input type)
{ "selected": "BEGINNER" }

// Option B
{ "fitnessLevel": "INTERMEDIATE" }
```

| Key | Type | Values |
|-----|------|--------|
| `selected` **or** `fitnessLevel` | `string` | `"BEGINNER"`, `"INTERMEDIATE"`, `"ADVANCED"` |

> ❌ **Will NOT work**: `{"selectedOption": "BEGINNER"}`, `{"value": "BEGINNER"}`

---

### 7. `FITNESS_GOAL`

Sets `user.primary_goal_id` FK. Uses `optionId` to look up the linked `Goal` entity.

```json
// Option A — direct optionId (preferred, simplest)
{ "optionId": 3 }

// Option B — selected with optionId
{ "selected": [{ "optionId": 3 }] }

// Option C — selected as numeric array
{ "selected": [3] }

// Option D — selected as single number
{ "selected": 3 }
```

| Key | Type | Description |
|-----|------|-------------|
| `optionId` | `long` | The `optionId` from the onboarding option (returned in `GET /flow`) |

> ⚠️ The `optionId` must reference an `onboarding_option` that has a linked `goal_id` in the database. If `goal_id` is `NULL` on that option, `primary_goal` will NOT be set.

> ❌ **Will NOT work**: `{"selectedOptions": ["BUILD_MUSCLE"]}`, `{"goalName": "Build Muscle"}`.  
> The string-based fallback exists but requires `goalId` or exact `goalName` match — using `optionId` is strongly recommended.

---

### 8. `PERSONAL_INFO`

Sets `user.date_of_birth` and `user.gender` in one step.

```json
{
  "dateOfBirth": "1998-05-15",
  "gender": "MALE"
}
```

| Key | Type | Format |
|-----|------|--------|
| `dateOfBirth` | `string` | ISO date `YYYY-MM-DD` |
| `gender` | `string` | `"MALE"`, `"FEMALE"` |

---

### 9. `EQUIPMENT` / `SCHEDULE` / `HEALTH_LIMITATIONS` / `NOTIFICATIONS`

These are **stored in `user_onboarding_progress.response_data`** but are **NOT applied to the `user` table**. They may be used for preferences or recommendations later. Format is flexible.

---

## Common Mistakes Checklist

| ❌ Wrong | ✅ Correct | Affected Step |
|----------|-----------|---------------|
| `"selectedOption"` | `"selected"` | FITNESS_LEVEL, GENDER |
| `"selectedOptions"` | `"selected"` or `"optionId"` | FITNESS_GOAL |
| Sending goal **name** string | Sending `optionId` (number) | FITNESS_GOAL |
| Sending `targetWeight` in `WEIGHT` step | Send in `BODY_METRICS` step | WEIGHT vs BODY_METRICS |
| `responseData` as JSON object | `responseData` as **JSON string** | All steps |

---

## Full Example — Submit Fitness Level

```bash
POST /api/v1/onboarding/steps/5/submit
Authorization: Bearer <token>
Content-Type: application/json

{
  "responseData": "{\"selected\": \"BEGINNER\"}"
}
```

**Response** (`200 OK`):
```json
{
  "status": "success",
  "data": {
    "stepId": 5,
    "stepKey": "fitness_level",
    "inputType": "SINGLE_CHOICE",
    "status": "COMPLETED",
    "responseData": "{\"selected\": \"BEGINNER\"}",
    "completedAt": "2026-03-17T16:40:00",
    "nextStepId": 6,
    "onboardingComplete": false
  }
}
```

---

## Debugging

If data is not being saved to the `user` table after submit:

1. Check server logs for: `Applying onboarding response for user X, stepType: Y, responseData: Z`
2. Verify the `stepType` in the `onboarding_step` DB table matches the expected enum value
3. Verify `responseData` uses the **exact keys** listed above
4. For `FITNESS_GOAL`: verify the `onboarding_option` row has a non-null `goal_id`
