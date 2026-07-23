# CLAUDE.md — Nursery Management App

Version: 1.0
Status: Locked

---

## Project Overview

Flutter nursery management platform.

Roles:

- Super Admin
- Owner
- Branch Manager
- Supervisor
- Teacher
- Reception
- Guardian

Backend:

- Firebase Realtime Database
- Firebase Storage
- Firebase Auth
- Firebase FCM

Scale:

- ~33 Models
- ~55 Screens

---

## Stack

- Flutter
- GetX
- Dartz
- Firebase
- Dio
- SharedPreferences
- flutter_localizations

---

# Architecture — STRICT RULES

## The 4-Layer CRUD System

Every model goes through exactly 4 layers.

```text
BaseCrudRepo<T>
        ↓
BaseRepository<T>
        ↓
BaseUseCases<T>
        ↓
BaseService<T>
```

NEVER bypass layers.

---

## Adding New Model

Adding a new model requires ONLY 2 steps.

### Step 1

Register model inside:

```text
lib/binding/init.dart
```

```dart
BaseBinding.bindCrud<XModel>(
  tag: "xItems",
  baseUrl: () => ApiConstants.xItems,
  fromJson: (json) => XModel.fromJson(json),
);
```

### Step 2

Create:

```text
XParentService
```

inside:

```text
lib/presentation/parentControllers/services/
```

DO NOT create:

- Custom Repository
- Custom Data Source
- Custom UseCase

for standard CRUD operations.

---

# Dependency Injection Rules

The project uses:

```text
Binding
+
Get.find()
```

ONLY.

No alternative dependency injection patterns are allowed.

---

## Services Registration

Services MUST be registered inside bindings.

Example:

```dart
Get.lazyPut<XParentService>(
  () => XParentService(),
  fenix: true,
);
```

Global singleton services:

```dart
Get.put(
  SessionService(),
  permanent: true,
);
```

Examples:

```dart
Get.put(
  NotificationStreamService(),
  permanent: true,
);

Get.put(
  StaffWatcherService(),
  permanent: true,
);

Get.put(
  ActiveChildService(),
  permanent: true,
);
```

---

## Controller Registration

Feature controllers MUST be registered in bindings.

```dart
Get.lazyPut<TeacherActivityController>(
  () => TeacherActivityController(),
);
```

```dart
Get.lazyPut<ChildrenController>(
  () => ChildrenController(),
);
```

```dart
Get.lazyPut<AttendanceController>(
  () => AttendanceController(),
);
```

---

## Dependency Injection Standard

```text
Binding
+
Get.find()
```

ONLY.

No Get.put() inside screens.

No initController().

No service creation inside widgets.

No controller creation inside widgets.

## Controller Resolution

Controllers MUST be resolved using:

```dart
controller =
    Get.find<XController>();
```

inside views.

Example:

```dart
late final TeacherActivityController
    controller;

@override
void initState() {
  super.initState();

  controller =
      Get.find<
          TeacherActivityController>();
}
```

---

## Service Resolution

Services MUST be resolved inside:

```dart
onInit()
```

ONLY.

Example:

```dart
late final ChildParentService
    _service;

@override
void onInit() {
  super.onInit();

  _service =
      Get.find<ChildParentService>();
}
```

---

## Allowed

```dart
late final XParentService _service;

@override
void onInit() {
  super.onInit();

  _service =
      Get.find<XParentService>();
}
```

```dart
late final XController controller;

@override
void initState() {
  super.initState();

  controller =
      Get.find<XController>();
}
```

---

## Forbidden

```dart
Get.put(
  XController(),
);
```

```dart
Get.put(
  XController(),
  permanent: false,
);
```

```dart
final controller =
    Get.put(XController());
```

```dart
final service =
    Get.find<XService>();
```

```dart
late final XService service =
    Get.find<XService>();
```

```dart
controller =
    initController(
      () => XController(),
    );
```

---

# Controller Rules

Every screen MUST have exactly one controller.

Controllers contain:

- Business Logic
- Filtering
- Validation
- Role Logic
- Data Loading
- State Management

Controllers MUST NOT contain:

- Widgets
- BuildContext
- Navigation UI
- BottomSheets
- Dialogs
- Flutter UI code

---

## Standard Controller Template

```dart
class XController extends GetxController {

  final items = <XModel>[].obs;

  final filteredItems =
      <XModel>[].obs;

  final isLoading = false.obs;

  final searchQuery = ''.obs;

  late final XParentService
      _service;

  late Worker _searchWorker;

  @override
  void onInit() {
    super.onInit();

    _service =
        Get.find<XParentService>();

    loadData();

    _searchWorker = debounce(
      searchQuery,
      (_) => _filter(),
      time: 300.ms,
    );
  }

  Future<void> loadData() async {
    //
  }

  void _filter() {
    //
  }

  @override
  void onClose() {
    _searchWorker.dispose();

    searchController.dispose();

    super.onClose();
  }
}
```

---

## Reactive State Rules

Use:

```dart
final isLoading = false.obs;
```

```dart
final searchQuery = ''.obs;
```

```dart
final items = <XModel>[].obs;
```

```dart
final selectedItem =
    Rxn<XModel>();
```

---

## Async Operations

Every async operation MUST follow:

```dart
Loader.show();

try {

  await operation();

  Loader.showSuccess(
    'success_key'.tr,
  );

} catch (e) {

  Loader.showError(
    'error_key'.tr,
  );

}
```

---

## Search Pattern

```dart
_searchWorker = debounce(
  searchQuery,
  (_) => _filter(),
  time: 300.ms,
);
```

Always debounce searches.

Never filter directly from UI.

---

# Worker Rules

Always dispose workers.

Example:

```dart
late Worker _worker;

@override
void onInit() {
  super.onInit();

  _worker = debounce(
    query,
    (_) => search(),
    time: 300.ms,
  );
}

@override
void onClose() {
  _worker.dispose();
  super.onClose();
}
```

Never leave workers active.

---

## Role Rules

Role checks belong ONLY inside controllers.

Example:

```dart
bool get isTeacher =>
    session.role ==
    UserRole.teacher;
```

Allowed:

```dart
if (isTeacher) {
  //
}
```

Forbidden inside views:

```dart
if (user.role ==
    UserRole.teacher)
```

# View Rules

Views are responsible ONLY for:

- Layout
- Widget Assembly
- Obx Rendering

Nothing else.

---

## Standard View Template

```dart
class XView extends StatefulWidget {
  const XView({super.key});

  @override
  State<XView> createState() =>
      _XViewState();
}

class _XViewState
    extends State<XView> {

  late final XController
      controller;

  @override
  void initState() {
    super.initState();

    controller =
        Get.find<XController>();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      body: Obx(
        () => ListView(
          children: [
            HeaderSection(
              controller:
                  controller,
            ),

            ContentSection(
              controller:
                  controller,
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## View Restrictions

NO:

```dart
Get.put(...)
```

NO:

```dart
Get.find<Service>()
```

NO:

```dart
FirebaseDatabase.instance
```

NO:

```dart
FirebaseFirestore.instance
```

NO:

```dart
FirebaseStorage.instance
```

NO:

```dart
await service.loadData()
```

NO:

```dart
repository.getData()
```

NO:

```dart
business logic
```

inside views.

---

## Allowed

```dart
Obx(
  () => Widget(),
)
```

```dart
controller.items
```

```dart
controller.isLoading
```

```dart
controller.searchQuery
```

---

## Navigation Rules

Views may trigger:

```dart
Get.to(...)
```

```dart
Get.back()
```

ONLY.

Navigation decisions remain in controller.

---

## View File Limits

```text
view.dart
≤ 150 lines
```

Hard limit.

If exceeded:

```text
Split widgets.
```

---

## One Class Rule

Each file contains:

```text
ONE class
```

ONLY.

Forbidden:

```dart
class A {}

class B {}

class C {}
```

inside same file.

---

# UI Decomposition — STRICT RULES

## The Golden Rule

```text
view.dart
=
Scaffold
+
assembly of widgets only
```

The view is a composition layer.

The view does NOT contain UI implementation.

The view assembles widgets.

---

## Widget Extraction Rule

If a widget exceeds:

```text
3–5 lines
```

move it into:

```text
widgets/
```

immediately.

---

## File Size Limits

```text
view.dart            ≤ 150 lines
controller.dart      ≤ 400 lines
widget.dart          ≤ 200 lines
sheet.dart           ≤ 250 lines
```

Hard limits.

No exceptions.

---

## Split Rules

If controller exceeds:

```text
400 lines
```

Extract logic into:

```text
services/
helpers/
mixins/
```

---

If view exceeds:

```text
150 lines
```

Extract sections.

---

If widget exceeds:

```text
200 lines
```

Split into smaller widgets.

---

# Naming Rules

## Cards

Repeated items:

```text
{name}_card.dart
```

Examples:

```text
child_card.dart

announcement_card.dart

attendance_card.dart

invoice_card.dart
```

---

## Sections

Page sections:

```text
{name}_section.dart
```

Examples:

```text
posts_section.dart

attendance_section.dart

finance_section.dart
```

---

## Sheets

BottomSheets:

```text
{name}_sheet.dart
```

Examples:

```text
child_sheet.dart

homework_sheet.dart

incident_sheet.dart
```

---

## Bars

Horizontal controls:

```text
{name}_bar.dart
```

Examples:

```text
filter_bar.dart

tabs_bar.dart

child_switcher_bar.dart
```

---

## Headers

```text
{name}_header.dart
```

Examples:

```text
home_header.dart

finance_header.dart

teacher_header.dart
```

---

## Empty States

```text
{name}_empty.dart
```

Examples:

```text
attendance_empty.dart

homework_empty.dart
```

---

## Tiles

```text
{name}_tile.dart
```

Examples:

```text
subject_tile.dart

staff_tile.dart
```

# Screen Structure

Every feature MUST follow:

```text
feature/

├── controller.dart
├── view.dart

└── widgets/
    ├── header.dart
    ├── section.dart
    ├── card.dart
    ├── tile.dart
    └── sheet.dart
```

---

# Real Example

## Guardian Home

```text
guardian/home/

├── controller.dart
├── view.dart

└── widgets/
    ├── home_header.dart
    ├── child_switcher_bar.dart
    ├── announcements_section.dart
    ├── announcement_card.dart
    ├── classroom_posts_section.dart
    └── post_card.dart
```

---

## Teacher Activity

```text
teacher/activity/

├── controller.dart

├── view.dart

└── widgets/

    ├── activity_header.dart

    ├── active_activity_section.dart

    ├── child_card.dart

    ├── group_note_sheet.dart

    ├── homework_sheet.dart

    └── end_activity_sheet.dart
```

---

## Correct View

```dart
body: ListView(
  children: [

    HomeHeader(
      controller: controller,
    ),

    ChildSwitcherBar(
      controller: controller,
    ),

    AnnouncementsSection(
      controller: controller,
    ),

    ClassroomPostsSection(
      controller: controller,
    ),

  ],
)
```

---

# Forbidden Patterns

## Widget Inside View

Never:

```dart
class _AttendanceSection
    extends StatelessWidget {
}
```

inside:

```text
view.dart
```

---

## Large Builders

Never:

```dart
Builder(
  builder: (_) {

    // 50 lines

  },
)
```

---

## Multiple Classes

Never:

```dart
class A {}

class B {}

class C {}
```

inside same file.

---

## Huge Views

Never:

```text
view.dart
300+
lines
```

Split immediately.

---

# Folder Structure

```text
lib/

├── Data/
│
│   ├── core/
│   ├── data_source/
│   ├── data_source_impl/
│   ├── models/
│   └── repository_impl/
│
├── Domain/
│
│   ├── Repositories/
│   └── UseCases/
│
├── Global/
│
│   ├── Localization/
│   ├── Utils/
│   ├── constants/
│   ├── middleware/
│   ├── services/
│   ├── validation/
│   └── widgets/
│
├── binding/
│
│   ├── base_binding.dart
│   └── init.dart
│
├── index/
│
│   └── index_main.dart
│
├── presentation/
│
│   ├── design_systems/
│
│   ├── parentControllers/
│   │
│   └── services/
│
│   ├── screens/
│
│   ├── auth/
│   ├── branches/
│   ├── classrooms/
│   ├── children/
│   ├── programs/
│   ├── attendance/
│   ├── timeline/
│   ├── announcements/
│   ├── notifications/
│   ├── requests/
│   ├── dashboard/
│   ├── settings/
│
│   ├── guardian/
│   ├── teacher/
│   ├── reception/
│   ├── supervisor/
│
│   └── super_admin/
│
├── routing/
│
│   └── routing.dart
│
└── main.dart
```

---

# Architecture Summary

```text
View
↓
Controller
↓
ParentService
↓
BaseService
↓
UseCase
↓
Repository
↓
DataSource
↓
Firebase
```

No shortcuts allowed.

---

# Firebase Rules

Controllers NEVER access Firebase directly.

Forbidden:

```dart
FirebaseDatabase.instance
```

```dart
FirebaseFirestore.instance
```

```dart
FirebaseStorage.instance
```

Views NEVER access Firebase.

All Firebase access must go through:

```text
ParentService
↓
BaseService
↓
UseCase
↓
Repository
↓
DataSource
↓
Firebase
```

ONLY.

# Design System — ALWAYS USE

The design system is mandatory.

If a design system component exists:

```text
USE IT
```

Do not create raw Flutter alternatives.

---

# Colors

Always use:

```dart
AppColors.primary

AppColors.textDefault

AppColors.errorForeground
```

Additional colors should be added to:

```text
AppColors
```

Never hardcode colors.

Forbidden:

```dart
Color(0xFF2196F3)
```

```dart
Colors.blue
```

```dart
Colors.green
```

```dart
Colors.red
```

---

# Typography

Always use:

```dart
context.typography
```

Never use:

```dart
TextStyle(
  fontSize: ...
)
```

directly.

---

## Typography Reference

| Style | Usage |
|--------|--------|
| xsRegular | Caption |
| xsMedium | Small Labels |
| xsBold | Large Numbers |
| smRegular | Body Text |
| smMedium | Secondary Text |
| smSemiBold | Titles |
| displaySmBold | Highlighted Text |
| mdRegular | Main Content |
| mdMedium | Form Labels |
| mdBold | Section Headers |
| lgBold | Dialog Titles |
| xlBold | Screen Titles |
| xxlBold | KPI Numbers |

---

## Correct Examples

```dart
AppText(
  'key'.tr,
  style:
      context.typography.smRegular,
)
```

```dart
Text(
  'key'.tr,
  style:
      context.typography.smSemiBold,
)
```

```dart
AppText(
  'key'.tr,
  style:
      context.typography.mdBold,
)
```

---

## Forbidden Examples

```dart
Text(
  'Hello',
  style: TextStyle(
    fontSize: 14,
  ),
)
```

```dart
Text(
  'Hello',
  style: TextStyle(
    fontWeight:
        FontWeight.w700,
  ),
)
```

```dart
TextStyle(
  fontSize: 18,
  fontWeight: FontWeight.bold,
)
```

---

# copyWith Rules

Allowed:

```dart
context.typography.smSemiBold
    .copyWith(
  color: AppColors.primary,
)
```

```dart
context.typography.smRegular
    .copyWith(
  decoration:
      TextDecoration.lineThrough,
)
```

Allowed modifications:

- color
- decoration

ONLY.

---

Forbidden:

```dart
context.typography.smRegular
    .copyWith(
  fontSize: 18,
)
```

```dart
context.typography.smRegular
    .copyWith(
  fontWeight:
      FontWeight.w700,
)
```

Choose a proper typography style instead.

---

# Core Widgets

Always prefer:

```dart
AppText()
```

```dart
AppTextField()
```

```dart
PrimaryTextButton()
```

```dart
SecondaryTextButton()
```

```dart
OutlineTextButton()
```

```dart
HomeAppBar()
```

```dart
CachedNetworkImage()
```

```dart
Shimmer.fromColors()
```

---

# Utility Components

Always use:

```dart
Loader.show()
```

before async operations.

---

Success:

```dart
Loader.showSuccess(
  'success_key'.tr,
)
```

---

Error:

```dart
Loader.showError(
  'error_key'.tr,
)
```

---

Validation:

```dart
Validators.notEmpty()
```

```dart
Validators.combine([
  ...
])
```

---

Images:

```dart
PickedImage()
```

---

# Async Pattern

Every async operation:

```dart
Loader.show();

try {

  await operation();

  Loader.showSuccess(
    'success_key'.tr,
  );

} catch (e) {

  Loader.showError(
    'error_key'.tr,
  );

}
```

No silent operations.

---

# Performance Rules

- Use const constructors whenever possible
- Avoid rebuilding large Obx trees
- Prefer small reactive widgets
- Cache expensive calculations
- Use ListView.builder for large lists
- Use Rxn<T> instead of nullable observables when applicable
- Extract expensive widgets
- Keep Obx scope as small as possible

---

## Reactive Performance

Preferred:

```dart
Obx(
  () => Text(
    controller.name.value,
  ),
)
```

Avoid:

```dart
Obx(
  () => Scaffold(
    body: EntireHugeScreen(),
  ),
)
```

Keep reactive rebuilds localized.


# Localization

ZERO hardcoded text.

Everything goes through:

```text
ar.dart
en.dart
```

---

## Translation Usage

Correct:

```dart
'child_add'.tr
```

```dart
'attendance_checkin'.tr
```

```dart
'teacher_activity_start'.tr
```

---

Forbidden:

```dart
Text(
  'إضافة طفل',
)
```

```dart
Text(
  'Add Child',
)
```

```dart
AppText(
  'Start Activity',
)
```

---

# Translation Naming Convention

Pattern:

```text
feature_action
```

Examples:

```text
child_add_success

attendance_checkin_title

teacher_activity_start

guardian_home_title

invoice_paid_success

classroom_add_success

notification_send_success
```

---

# Localization Rules

Every user-facing string MUST use:

```dart
'key'.tr
```

No exceptions.

---

Allowed:

```dart
AppText(
  'save'.tr,
)
```

```dart
AppText(
  'cancel'.tr,
)
```

---

Forbidden:

```dart
AppText(
  'Save',
)
```

```dart
AppText(
  'حفظ',
)
```

---

# Localization Workflow — App-Wide AR / EN Pass

We are localizing the ENTIRE app into Arabic + English.

Much of the UI is already built with hardcoded text.

The task is to sweep the app widget by widget and localize each one.

---

## The Per-Widget Process

For EACH widget, do EXACTLY these steps — nothing more:

### Step 1 — Extract & Add Keys

Find every hardcoded user-facing string in the widget.

Replace it with:

```dart
'key'.tr
```

Add the key to BOTH:

```text
ar.dart
en.dart
```

- Arabic value in `ar.dart`
- English value in `en.dart`

Key naming follows:

```text
feature_action
```

(see Translation Naming Convention)

---

### Step 2 — Fix UI

After swapping strings, fix any UI that breaks:

- Overflow
- Truncation
- Wrapping
- Spacing / padding
- Widths that no longer fit the new text

Text length differs between Arabic and English — the layout MUST hold for both.

---

### Step 3 — Check RTL Alignment

Verify the widget is correct in RTL (Arabic):

- Alignment (start / end, not hardcoded left / right)
- Row / padding / margin direction
- Icons that must mirror
- `EdgeInsetsDirectional` instead of `EdgeInsets` where side-specific
- `Alignment` / `TextAlign` respect directionality
- No hardcoded `left` / `right` that breaks in RTL

---

## Scope Limit

Per widget, ONLY:

```text
1. Add keys (ar + en)
2. Fix UI
3. Check RTL alignment
```

Do NOT:

- Refactor architecture
- Restructure widgets
- Change logic
- Rename files
- Add features
- Touch anything unrelated to localization

Keep each pass minimal and focused on localization only.

---

## Rules Recap

- Every user-facing string → `'key'.tr`
- Key added to BOTH `ar.dart` and `en.dart` in the same pass
- Never leave a key in only one file
- Never invent a value in only one language
- UI must not overflow or break in either language
- Widget must be correct in RTL

---

# Roles & Access

Role checks belong ONLY in controllers.

Never inside views.

Never inside widgets.

---

## Role Scope

| Role | Scope |
|--------|--------|
| Super Admin | Entire platform |
| Owner | All branches |
| Branch Manager | Assigned branches |
| Supervisor | Assigned branch |
| Teacher | Assigned classrooms |
| Reception | Registration & Documents |
| Guardian | Own children only |

---

## Correct

```dart
bool get isTeacher =>
    currentUser.role ==
    UserRole.teacher;
```

```dart
bool get isSupervisor =>
    currentUser.role ==
    UserRole.supervisor;
```

```dart
if (isTeacher) {
  //
}
```

---

## Forbidden

```dart
if (
  currentUser.role ==
  UserRole.teacher
) {
}
```

inside views.

---

```dart
if (
  currentUser.role ==
  UserRole.supervisor
) {
}
```

inside widgets.

---

# ParentService Pattern

ParentService is the ONLY layer allowed to resolve BaseService directly.

This is an approved exception.

---

## Standard ParentService

```dart
class XParentService {

  final BaseService<XModel>
      _service =
      Get.find<
          BaseService<XModel>
      >(
        tag: 'xItems',
      );

  Future<void> addX({
    required XModel item,
    required Function(
      ResponseStatus,
    ) callBack,
  }) async {

    await _service.addData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> updateX({
    required XModel item,
    required Function(
      ResponseStatus,
    ) callBack,
  }) async {

    await _service.updateData(
      item: item,
      toJson: (m) => m.toJson(),
      id: item.key ?? '',
      voidCallBack: callBack,
    );
  }

  Future<void> deleteX({
    required String id,
    required Function(
      ResponseStatus,
    ) callBack,
  }) async {

    await _service.deleteData(
      id: id,
      voidCallBack: callBack,
    );
  }

  Future<void> getAll({
    required Function(
      List<XModel?>,
    ) callBack,
  }) async {

    await _service.getData(
      data: {},
      voidCallBack: callBack,
    );
  }
}
```

---

## ParentService Rules

Allowed:

```dart
final BaseService<XModel>
    _service =
    Get.find<
        BaseService<XModel>
    >(
      tag: 'xItems',
    );
```

ONLY inside ParentService.

---

Forbidden everywhere else:

```dart
final service =
    Get.find<Service>();
```

```dart
late final service =
    Get.find<Service>();
```

outside ParentService or Controller.onInit().

---

## ParentService Responsibilities

ParentService may:

- Call BaseService
- Transform data
- Aggregate multiple models
- Execute business workflows
- Handle Firebase transaction orchestration

ParentService MUST NOT:

- Contain UI code
- Use Widgets
- Use BuildContext
- Use Obx
- Use Get.put()
# CRUD Screen Checklist

Before finishing ANY CRUD screen:

---

## Binding

- [ ] bindCrud added
- [ ] ParentService created
- [ ] ParentService registered
- [ ] Controller registered
- [ ] Controller loaded using Get.find()

---

## Controller

- [ ] Uses Get.find() in onInit()
- [ ] No field initializer DI
- [ ] Controller < 400 lines
- [ ] No BuildContext
- [ ] No Flutter widgets
- [ ] Search uses debounce
- [ ] Workers disposed

---

## View

- [ ] View < 150 lines
- [ ] No Get.put()
- [ ] No Get.find<Service>()
- [ ] No business logic
- [ ] No Firebase calls
- [ ] No repository calls

---

## Widgets

- [ ] One widget per file
- [ ] Widget < 200 lines
- [ ] Repeated item = card
- [ ] Page section = section
- [ ] Empty state = empty
- [ ] Header = header
- [ ] List tile = tile

---

## Forms

- [ ] Form = sheet
- [ ] BottomSheet < 250 lines

---

## Localization

- [ ] Every string uses .tr
- [ ] No hardcoded text

---

## Design System

- [ ] Uses AppColors
- [ ] Uses Typography
- [ ] Uses Design System widgets

---

## Async

- [ ] Loader.show()
- [ ] Loader.showSuccess()
- [ ] Loader.showError()

---

## Lifecycle

- [ ] Dispose TextEditingControllers
- [ ] Dispose AnimationControllers
- [ ] Dispose FocusNodes
- [ ] Dispose Workers
- [ ] Cancel StreamSubscriptions
- [ ] Dispose Streams

---

# DO / DON'T

| DO | DON'T |
|------|------|
| Get.find() inside onInit() | Get.find() in field initializer |
| Get.lazyPut(..., fenix:true) | Register dependency twice |
| Get.find<XController>() | Get.put(XController()) |
| Obx(() => ...) | setState() for business state |
| One class per file | Multiple classes per file |
| One widget per file | Nested widget classes |
| .tr for strings | Hardcoded strings |
| Loader.show() before async | Silent async operations |
| AppColors | Raw colors |
| Typography | TextStyle(fontSize: ...) |
| Design System widgets | Raw alternatives |
| Binding-based DI | Service creation in widgets |
| ParentService → BaseService | Firebase access from View |
| Worker.dispose() | Active workers after close |

---

# Absolute Rules

These rules are non-negotiable.

---

## NEVER

```dart
Get.put(
  XController(),
);
```

inside screens.

---

```dart
Get.put(
  XController(),
  permanent: false,
);
```

---

```dart
final controller =
    Get.put(
      XController(),
    );
```

---

```dart
controller =
    initController(
      () => XController(),
    );
```

---

```dart
final service =
    Get.find<Service>();
```

outside Controller.onInit().

---

```dart
late final service =
    Get.find<Service>();
```

as a field initializer.

---

NEVER use `setState()` for business state management.

Use:

- Rx
- Rxn
- Obx
- GetX reactive state management

instead.

Example:

```dart
final isLoading = false.obs;

Obx(
  () => LoaderWidget(
    isLoading: isLoading.value,
  ),
);
```

Flutter-specific UI state such as:

- AnimationController
- TabController
- PageController
- FocusNode

may use normal Flutter lifecycle patterns when appropriate.

---

## ALWAYS

```dart
late final XService
    _service;

@override
void onInit() {
  super.onInit();

  _service =
      Get.find<XService>();
}
```

---

```dart
late final XController
    controller;

@override
void initState() {
  super.initState();

  controller =
      Get.find<XController>();
}
```

---

```dart
Get.lazyPut<
    XController>(
  () => XController(),
);
```

inside bindings.

---

```dart
Get.lazyPut<
    XParentService>(
  () => XParentService(),
  fenix: true,
);
```

inside bindings.

---

```dart
late Worker _worker;

@override
void onInit() {
  super.onInit();

  _worker = debounce(
    searchQuery,
    (_) => _filter(),
    time: 300.ms,
  );
}

@override
void onClose() {
  _worker.dispose();
  super.onClose();
}
```

for any Worker usage.

---

# Project Standards

```text
Binding
↓
Get.find()
↓
Controller
↓
ParentService
↓
BaseService
↓
UseCase
↓
Repository
↓
DataSource
↓
Firebase
```

ONLY.

No shortcuts.

No exceptions.

Except the approved ParentService BaseService resolution rule.

---

# Final Notes

This document is the official architecture guide for the project.

Rules in this document override personal coding preferences.

When in doubt:

```text
Follow CLAUDE.md
```

Do not invent new architecture patterns.

Do not introduce alternative dependency injection systems.

Do not bypass ParentService.

Do not access Firebase directly from Views or Controllers.

Keep the codebase consistent.

Version: 1.0
Status: Locked