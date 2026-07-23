// Shared string constants for the Assessment Engine (Template → Run →
// ChildAssessment → Attempt → ItemResult).
//
// The codebase models enums as plain string constants (see child_state_template
// `kStateKindStatus`), so we follow the same convention here — the stored JSON
// stays human-readable and forward-compatible.

// ─── AssessmentRun.status ─────────────────────────────────────────────────────
// The run (the scheduled instance of a template on a branch/classroom) has a
// deliberately SIMPLE lifecycle. Progress (e.g. "28/32 graded") is computed at
// runtime from the child rows, NOT stored here.
const String kRunStatusDraft = 'draft'; // manager still preparing
const String kRunStatusActive = 'active'; // published → teachers can grade
const String kRunStatusCompleted = 'completed'; // all children done/archived

const List<String> kRunStatuses = [
  kRunStatusDraft,
  kRunStatusActive,
  kRunStatusCompleted,
];

// ─── ChildAssessment.status ───────────────────────────────────────────────────
// This is where the REAL workflow lives (per child, independent of the class).
// A child is published on its own — the parent sees it the moment it reaches
// `published`, regardless of the rest of the classroom.
const String kChildStatusInProgress = 'in_progress'; // teacher grading
const String kChildStatusTeacherCompleted = 'teacher_completed'; // awaiting review
const String kChildStatusReviewed = 'reviewed'; // manager reviewed, pre-publish
const String kChildStatusPublished = 'published'; // visible to parent
const String kChildStatusLocked = 'locked'; // frozen; edits need unlock/attempt

const List<String> kChildStatuses = [
  kChildStatusInProgress,
  kChildStatusTeacherCompleted,
  kChildStatusReviewed,
  kChildStatusPublished,
  kChildStatusLocked,
];

// ─── AssessmentAttempt.kind ───────────────────────────────────────────────────
// A retake is a NEW attempt (a normal flow, no audit). A correction is an
// UNLOCK + edit of an existing attempt (the audited exception) — it does not
// create a new attempt, so it has no kind here.
const String kAttemptKindOfficial = 'official'; // the first / primary attempt
const String kAttemptKindPractice = 'practice'; // a non-counting retry
const String kAttemptKindRetake = 'retake'; // a scheduled re-assessment

const List<String> kAttemptKinds = [
  kAttemptKindOfficial,
  kAttemptKindPractice,
  kAttemptKindRetake,
];

// ─── AssessmentScale.kind ─────────────────────────────────────────────────────
// One scale per Assessment (not per item) — a locked product decision so the
// teacher UI stays uniform. `rating` = discrete levels (Excellent…Weak,
// Pass/Fail); `numeric` = a 0..max slider (e.g. 0-10). Both normalise every
// result to a 0-1 `fraction` so totals reconcile across scale types.
const String kScaleKindRating = 'rating';
const String kScaleKindNumeric = 'numeric';
