// ─── Flutter Core ────────────────────────────────────────────────────────────
export 'package:flutter/material.dart';
export 'package:flutter/services.dart';
export 'package:flutter/gestures.dart';
export 'package:flutter_screenutil/flutter_screenutil.dart';

// Main
export 'package:get/get_navigation/src/root/get_material_app.dart';
export 'package:kidtrack/Global/services/notification_service.dart';
export 'package:kidtrack/Global/services/storage_service.dart';

// ─── Dart Core ───────────────────────────────────────────────────────────────
export 'dart:async';
export 'dart:convert';

// ─── GetX ────────────────────────────────────────────────────────────────────
export 'package:get/get.dart';

// ─── Firebase ────────────────────────────────────────────────────────────────
export 'package:firebase_core/firebase_core.dart';
export 'package:firebase_auth/firebase_auth.dart';
export 'package:firebase_storage/firebase_storage.dart';
export 'package:cloud_firestore/cloud_firestore.dart';
export 'package:firebase_messaging/firebase_messaging.dart';

// ─── UI Packages ─────────────────────────────────────────────────────────────
export 'package:google_fonts/google_fonts.dart';
export 'package:lottie/lottie.dart';
export 'package:flutter_svg/svg.dart';
export '../Global/widgets/app_network_image.dart';
export 'package:shimmer/shimmer.dart';
export 'package:flutter_easyloading/flutter_easyloading.dart';

// ─── Utility Packages ────────────────────────────────────────────────────────
export 'package:uuid/uuid.dart';
export 'package:connectivity_plus/connectivity_plus.dart';
export 'package:url_launcher/url_launcher.dart';
export 'package:share_plus/share_plus.dart';

// ─── App Entry & Routing ─────────────────────────────────────────────────────
export 'index_main.dart';
export '../index/index.dart';
export '../routing/routing.dart';
export '../binding/init.dart';
export '../binding/base_binding.dart';

// ─── Constants ───────────────────────────────────────────────────────────────
export '../Global/constants/permission_keys.dart';
export '../Global/constants/permission_labels.dart';
export '../Global/constants/permission_templates.dart';
export '../Global/constants/app_colors.dart';
export '../Global/constants/app_strings.dart';
export '../Global/constants/app_icons.dart';
export '../Global/constants/app_images.dart';
export '../Global/constants/app_animations.dart';
export '../Global/constants/app_gradients.dart';
export '../Global/constants/app_shadows.dart';
export '../Global/constants/hex_color.dart';
export '../Global/constants/status_bar.dart';
export '../Global/constants/device_info.dart';
export '../Global/constants/api_constants.dart';

// ─── Localization ─────────────────────────────────────────────────────────────
export '../Global/Localization/app_language.dart';
export '../Global/Localization/ar.dart';
export '../Global/Localization/en.dart';
export '../Global/Localization/local_storage_language.dart';
export '../Global/Localization/translation.dart';

// ─── Utils ───────────────────────────────────────────────────────────────────
export '../Global/Utils/logger.dart';
export '../Global/Utils/date_utils.dart';
export '../Global/Utils/date_helpers.dart';
export '../Global/Utils/firebase_filter.dart';
export '../Global/Utils/responsive.dart';
export '../Global/Utils/network_image.dart';
export '../Global/Utils/svg_icon.dart';
export '../Global/Utils/make_call.dart';
export '../Global/Utils/parse_map.dart';
export '../Global/Utils/image_picker.dart';
export '../Global/Utils/remote_config_keys.dart';
export '../Global/Utils/firebase_remote_config_service.dart';

// ─── Services ─────────────────────────────────────────────────────────────────
export '../Global/services/update_status.dart';
export '../Global/services/location_service.dart';
export '../Global/services/branch_management_service.dart';
export '../Global/services/session_service.dart';
export '../Global/services/notification_stream_service.dart';
export '../Global/services/access_watcher_service.dart';
export '../Global/services/deep_link_service.dart';
export '../Global/services/access_control_service.dart';
export '../Global/services/setup_local_check.dart';
export '../Global/services/nursery_feedback_gate.dart';
export '../Global/services/kidtrack_feedback_gate.dart';
export '../Global/services/notification_send_service.dart';
export '../Global/services/fcm_token_service.dart';
export '../Global/services/notification_prefs_service.dart';
export '../Global/services/active_child_service.dart';
export '../Global/services/parent_engagement_service.dart';
export '../Global/services/auth_bootstrap_service.dart';

// ─── Validation ───────────────────────────────────────────────────────────────
export '../Global/validation/validators.dart';

// ─── Middleware ───────────────────────────────────────────────────────────────
export '../Global/middleware/route_middleware.dart';

// ─── Widgets ─────────────────────────────────────────────────────────────────
export '../Global/widgets/loader.dart';
export '../Global/widgets/child_avatar.dart';
export '../Global/widgets/withdrawn_children_sheet.dart';
export '../Global/widgets/animated_info.dart';
export '../Global/widgets/animated_success.dart';
export '../Global/widgets/animated_error.dart';
export '../Global/widgets/stagger_item.dart';
export '../Global/widgets/kidtrack_tab_header.dart';
export '../Global/widgets/owner_app_bar.dart';
export '../Global/widgets/parent_sliver_app_bar.dart';
export '../Global/widgets/child_switcher_sheet.dart';
export '../Global/widgets/teacher_classic_app_bar.dart';

// ─── Domain Layer ────────────────────────────────────────────────────────────
export '../Domain/Repositories/base_repository.dart';
export '../Domain/Repositories/authentication_repository.dart';
export '../Domain/Repositories/firebase_repository.dart';
export '../Domain/UseCases/use_case.dart';
export '../Domain/UseCases/base_use_cases.dart';
export '../Domain/UseCases/auth_use_cases.dart';
export '../Domain/UseCases/Firebase_UseCases/firebase_sign_in_use_case.dart';
export '../Domain/UseCases/Firebase_UseCases/firebase_sign_up_use_case.dart';
export '../Domain/UseCases/Firebase_UseCases/firebaseupload_image_usecase.dart';

// ─── Data Layer — Core ───────────────────────────────────────────────────────
export '../Data/core/api_client.dart';
export '../Data/core/api_error_handler.dart';
export '../Data/core/api_error_model.dart';
export '../Data/core/firebase_client.dart';
export '../Data/core/dio_factory.dart';
export '../Data/core/interceptors/auth_interceptor.dart';
export '../Data/core/interceptors/error_interceptor.dart';
export '../Data/core/interceptors/logging_interceptor.dart';
export '../Data/core/interceptors/retry_interceptor.dart';
export '../Data/models/core/api_error_model.dart';

// ─── Data Layer — Core Models ─────────────────────────────────────────────────
export '../Data/models/core/api_result.dart';
export '../Data/models/core/app_error.dart';
export '../Data/models/core/error_model.dart';
export '../Data/models/core/no_params.dart';
export '../Data/models/core/response_status.dart';
export '../Data/models/core/success_model.dart';
export '../Data/models/core/sign_up_error.dart';
export '../Data/models/user/user_model.dart';
export '../Data/models/user/user_type.dart';
export '../Data/models/shared/generic_list_model.dart';
export '../Data/models/shared/pagination.dart';
export '../Data/models/shared/firebase_auth_model.dart';

// ─── Data Layer — Nursery Models ─────────────────────────────────────────────
export '../Data/models/nursery/nursery_model.dart';
export '../Data/models/application_form/application_form_model.dart';
export '../Data/models/package/package_model.dart';
export '../Data/models/branch/branch_model.dart';
export '../Data/models/branch_target/branch_target_model.dart';
export '../Data/models/shift/shift.dart';
export '../Data/models/staff/staff_template.dart';
export '../Data/models/staff/staff_model.dart';
export '../Data/models/permission_set/permission_set_model.dart';
export '../Data/models/audit_log/audit_log_model.dart';
export '../Data/models/support_ticket/support_ticket_model.dart';
export '../Data/models/contact_info/contact_info_model.dart';
export '../Data/models/about_us/about_us_model.dart';
export '../Data/models/city/city_model.dart';
export '../Data/models/support_request/support_request_model.dart';
export '../Data/models/app_review/app_review_model.dart';
export '../Data/models/nursery_feedback/nursery_feedback_model.dart';
export '../Data/models/kidtrack_feedback/kidtrack_feedback_campaign_model.dart';
export '../Data/models/kidtrack_feedback/kidtrack_feedback_response_model.dart';
export '../Data/models/online_application/online_application_model.dart';
export '../Data/models/classroom/classroom_model.dart';
export '../Data/models/schedule/schedule_model.dart';
export '../Data/models/program/program_model.dart';
export '../Data/models/subject/subject_model.dart';
export '../Data/models/child/child_model.dart';
export '../Data/models/withdrawal/withdrawal_log_model.dart';
export '../Data/models/enrollment/enrollment_model.dart';
export '../Data/models/medical_profile/medical_profile_model.dart';
export '../Data/models/document/document_model.dart';
export '../Data/models/authorized_pickup/authorized_pickup_model.dart';
export '../Data/models/waiting_list/waiting_list_model.dart';
export '../Data/models/parent/parent_model.dart';
export '../Data/models/parent_child/parent_child_model.dart';
export '../Data/models/activation_code/activation_code_model.dart';
export '../Data/models/child_attendance/child_attendance_model.dart';
export '../Data/models/staff_attendance/staff_attendance_model.dart';
export '../Data/models/staff_leave/staff_leave_model.dart';
export '../Data/models/child_leave_request/child_leave_request_model.dart';
export '../Data/models/child_report/child_report_model.dart';
export '../Data/models/assessment/assessment_model.dart';
export '../Data/models/daily_assessment/daily_assessment_model.dart';
export '../Data/models/academic_topic/academic_topic_model.dart';
export '../Data/models/teacher_assignment/teacher_assignment_model.dart';
export '../Data/models/topic_progress/topic_progress_model.dart';
export '../Data/models/incident/incident_model.dart';
export '../Data/models/note/note_model.dart';
export '../Data/models/lesson_plan/lesson_plan_model.dart';
export '../Data/models/homework/homework_model.dart';
export '../Data/models/homework_status/homework_status_model.dart';
export '../Data/models/session/session_model.dart';
export '../Data/models/classroom_post/classroom_post_model.dart';
export '../Data/models/announcement/announcement_model.dart';
export '../Data/models/notification/notification_model.dart';
export '../Data/models/daily_care_log/daily_care_log_model.dart';
export '../Data/models/invoice/invoice_model.dart';
export '../Data/models/payment/payment_model.dart';
export '../Data/models/expense/expense_model.dart';
export '../Data/models/fee_category/fee_category_model.dart';
export '../Data/models/shift/shift_model.dart';
export '../Data/models/financial_transaction/financial_transaction_model.dart';

// ─── Data Layer — Data Sources ───────────────────────────────────────────────
export '../Data/data_source/base_crud_repo.dart';
export '../Data/data_source/firebase_data_source.dart';
export '../Data/data_source/authentication_remote_data_source.dart';

// ─── Data Layer — Impls ───────────────────────────────────────────────────────
export '../Data/data_source_impl/base_crud_repo_impl.dart';
export '../Data/data_source_impl/firebase_data_source_impl.dart';
export '../Data/data_source_impl/authentication_remote_datasource_impl.dart';
export '../Data/repository_impl/base_repository_impl.dart';
export '../Data/repository_impl/firebase_repository_impl.dart';
export '../Data/repository_impl/authentication_repo_impl.dart';

// ─── Presentation — Base ─────────────────────────────────────────────────────
export 'package:kidtrack/presentation/parentControllers/base_service.dart';
export 'package:kidtrack/presentation/parentControllers/parent_authentication_controller.dart';

// ─── Presentation — Services ──────────────────────────────────────────────────
export 'package:kidtrack/presentation/parentControllers/services/firebase_credentials_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/notification_service_parent.dart';

// ─── Screens ─────────────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/onboarding/onboard_view.dart';
export 'package:kidtrack/presentation/screens/onboarding/onboard_controller.dart';
export 'package:kidtrack/presentation/screens/force_update/force_update_view.dart';
export 'package:kidtrack/presentation/screens/auth/activation/view.dart';
export 'package:kidtrack/presentation/screens/auth/activation/landing_view.dart';
export 'package:kidtrack/presentation/screens/auth/activation/controller.dart';
export 'package:kidtrack/presentation/screens/auth/activation/widgets/activation_login_sheet.dart';
export 'package:kidtrack/Global/services/activation_login_service.dart';
export 'package:kidtrack/presentation/screens/auth/renewal/renewal_view.dart';
export 'package:kidtrack/presentation/screens/main/main_page.dart';
export 'package:kidtrack/presentation/screens/main/main_page_controller.dart';
export 'package:kidtrack/presentation/screens/notifications/view.dart';
export 'package:kidtrack/presentation/screens/notifications/controller.dart';
export 'package:kidtrack/presentation/screens/notification_settings/view.dart';
export 'package:kidtrack/presentation/screens/notification_settings/controller.dart';

// ─── Staff Screens ────────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/staff/list/view.dart';
export 'package:kidtrack/presentation/screens/staff/list/controller.dart';
export 'package:kidtrack/presentation/screens/staff/list/widgets/staff_card.dart';
export 'package:kidtrack/presentation/screens/staff/list/widgets/staff_empty.dart';
export 'package:kidtrack/presentation/screens/staff/list/widgets/staff_form_view.dart';
export 'package:kidtrack/presentation/screens/staff/list/widgets/staff_form_controller.dart';
export 'package:kidtrack/presentation/screens/staff/dashboard/staff_dashboard_controller.dart';
export 'package:kidtrack/presentation/screens/staff/dashboard/staff_dashboard_view.dart';

// ─── Parent Services ──────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/parentControllers/services/staff_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/branch_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/permission_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/nursery_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/package_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/classroom_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/program_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/subject_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/child_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/withdrawal_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/enrollment_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/medical_profile_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/document_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/authorized_pickup_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/waiting_list_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/guardian_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/parent_child_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/activation_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/child_attendance_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/staff_attendance_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/staff_leave_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/child_leave_request_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/child_report_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/assessment_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/incident_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/note_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/lesson_plan_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/classroom_post_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/announcement_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/schedule_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/daily_care_log_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/invoice_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/fee_category_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/shift_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/daily_assessment_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/topic_progress_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/academic_topic_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/financial_transaction_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/payment_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/expense_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/audit_log_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/support_ticket_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/contact_info_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/about_us_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/city_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/support_request_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/app_review_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/nursery_feedback_parent_service.dart';
export 'package:kidtrack/presentation/parentControllers/services/online_application_parent_service.dart';
export '../Global/services/online_application_submit_service.dart';
export '../Global/services/nursery_catalog_service.dart';
export 'package:kidtrack/presentation/screens/staff/permissions/staff_permissions_view.dart';
export 'package:kidtrack/presentation/screens/staff/permissions/staff_permissions_controller.dart';

// ─── Branches Screens ────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/branches/list/controller.dart';
export 'package:kidtrack/presentation/screens/branches/list/view.dart';
export 'package:kidtrack/presentation/screens/branches/list/widgets/branch_card.dart';
export 'package:kidtrack/presentation/screens/branches/list/widgets/branch_empty.dart';
export 'package:kidtrack/presentation/screens/branches/list/widgets/branch_shimmer.dart';
export 'package:kidtrack/presentation/screens/branches/list/widgets/branch_sheet.dart';

// ─── Classrooms Screens ───────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/classrooms/list/controller.dart';
export 'package:kidtrack/presentation/screens/classrooms/list/view.dart';
export 'package:kidtrack/presentation/screens/classrooms/list/widgets/classroom_card.dart';
export 'package:kidtrack/presentation/screens/classrooms/list/widgets/classroom_empty.dart';
export 'package:kidtrack/presentation/screens/classrooms/list/widgets/classroom_shimmer.dart';
export 'package:kidtrack/presentation/screens/classrooms/list/widgets/classroom_sheet.dart';
export 'package:kidtrack/presentation/screens/classrooms/detail/controller.dart';
export 'package:kidtrack/presentation/screens/classrooms/detail/view.dart';

// ─── Children Screens ─────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/list/controller.dart';
export 'package:kidtrack/presentation/screens/children/list/view.dart';
export 'package:kidtrack/presentation/screens/children/list/widgets/child_card.dart';
export 'package:kidtrack/presentation/screens/children/list/widgets/child_empty.dart';
export 'package:kidtrack/presentation/screens/children/list/widgets/child_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/list/widgets/child_search_bar.dart';
export 'package:kidtrack/presentation/screens/children/list/widgets/child_sheet.dart';

// ─── Child Profile Screen ─────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/profile/controller.dart';
export 'package:kidtrack/presentation/screens/children/profile/view.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/profile_section_card.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/basic_info_section.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/parents_section.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/attendance_section.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/profile_filter_bar.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/activities_section.dart';
export 'package:kidtrack/presentation/screens/children/profile/widgets/teacher_notes_section.dart';

// ─── Programs Screens ─────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/programs/list/controller.dart';
export 'package:kidtrack/presentation/screens/programs/list/view.dart';
export 'package:kidtrack/presentation/screens/programs/list/widgets/program_card.dart';
export 'package:kidtrack/presentation/screens/programs/list/widgets/program_empty.dart';
export 'package:kidtrack/presentation/screens/programs/list/widgets/program_shimmer.dart';
export 'package:kidtrack/presentation/screens/programs/list/widgets/program_sheet.dart';

// ─── Subjects Screens ─────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/programs/subjects/controller.dart';
export 'package:kidtrack/presentation/screens/programs/subjects/view.dart';
export 'package:kidtrack/presentation/screens/programs/subjects/widgets/subject_card.dart';
export 'package:kidtrack/presentation/screens/programs/subjects/widgets/subject_empty.dart';
export 'package:kidtrack/presentation/screens/programs/subjects/widgets/subject_shimmer.dart';
export 'package:kidtrack/presentation/screens/programs/subjects/widgets/subject_sheet.dart';
export 'package:kidtrack/presentation/screens/academic/topics/academic_topics_view.dart';
export 'package:kidtrack/presentation/screens/academic/topics/academic_topics_controller.dart';

// ─── Nurseries Screens ────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/nurseries/list/controller.dart';
export 'package:kidtrack/presentation/screens/nurseries/list/view.dart';
export 'package:kidtrack/presentation/screens/nurseries/list/widgets/nursery_card.dart';
export 'package:kidtrack/presentation/screens/nurseries/list/widgets/nursery_empty.dart';
export 'package:kidtrack/presentation/screens/nurseries/list/widgets/nursery_shimmer.dart';
export 'package:kidtrack/presentation/screens/nurseries/list/widgets/nursery_sheet.dart';
export 'package:kidtrack/presentation/screens/nurseries/details/controller.dart';
export 'package:kidtrack/presentation/screens/nurseries/details/view.dart';
export 'package:kidtrack/presentation/screens/nurseries/details/widgets/owner_form_sheet.dart';
export 'package:kidtrack/presentation/screens/nurseries/details/widgets/owner_tile.dart';

// ─── Packages Screens ─────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/nurseries/packages/controller.dart';
export 'package:kidtrack/presentation/screens/nurseries/packages/view.dart';
export 'package:kidtrack/presentation/screens/nurseries/packages/widgets/package_card.dart';
export 'package:kidtrack/presentation/screens/nurseries/packages/widgets/package_empty.dart';
export 'package:kidtrack/presentation/screens/nurseries/packages/widgets/package_shimmer.dart';
export 'package:kidtrack/presentation/screens/nurseries/packages/widgets/package_sheet.dart';

// ─── Enrollments Screens ──────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/enrollments/controller.dart';
export 'package:kidtrack/presentation/screens/children/enrollments/view.dart';
export 'package:kidtrack/presentation/screens/children/enrollments/widgets/enrollment_card.dart';
export 'package:kidtrack/presentation/screens/children/enrollments/widgets/enrollment_empty.dart';
export 'package:kidtrack/presentation/screens/children/enrollments/widgets/enrollment_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/enrollments/widgets/enrollment_sheet.dart';

// ─── Medical Screens ──────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/medical/controller.dart';
export 'package:kidtrack/presentation/screens/children/medical/view.dart';
export 'package:kidtrack/presentation/screens/children/medical/widgets/medical_card.dart';
export 'package:kidtrack/presentation/screens/children/medical/widgets/medical_empty.dart';
export 'package:kidtrack/presentation/screens/children/medical/widgets/medical_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/medical/widgets/medical_sheet.dart';

// ─── Documents Screens ────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/documents/controller.dart';
export 'package:kidtrack/presentation/screens/children/documents/view.dart';
export 'package:kidtrack/presentation/screens/children/documents/widgets/document_card.dart';
export 'package:kidtrack/presentation/screens/children/documents/widgets/document_empty.dart';
export 'package:kidtrack/presentation/screens/children/documents/widgets/document_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/documents/widgets/document_sheet.dart';

// ─── Authorized Pickup Screens ────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/authorized_pickup/controller.dart';
export 'package:kidtrack/presentation/screens/children/authorized_pickup/view.dart';
export 'package:kidtrack/presentation/screens/children/authorized_pickup/widgets/pickup_card.dart';
export 'package:kidtrack/presentation/screens/children/authorized_pickup/widgets/pickup_empty.dart';
export 'package:kidtrack/presentation/screens/children/authorized_pickup/widgets/pickup_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/authorized_pickup/widgets/pickup_sheet.dart';

// ─── Waiting List Screens ─────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/waiting_list/controller.dart';
export 'package:kidtrack/presentation/screens/children/waiting_list/view.dart';
export 'package:kidtrack/presentation/screens/children/waiting_list/widgets/waiting_card.dart';
export 'package:kidtrack/presentation/screens/children/waiting_list/widgets/waiting_empty.dart';
export 'package:kidtrack/presentation/screens/children/waiting_list/widgets/waiting_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/waiting_list/widgets/waiting_sheet.dart';

// ─── Guardian List Screens ────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/guardian/list/controller.dart';
export 'package:kidtrack/presentation/screens/guardian/list/view.dart';
export 'package:kidtrack/presentation/screens/guardian/list/widgets/guardian_card.dart';
export 'package:kidtrack/presentation/screens/guardian/list/widgets/guardian_empty.dart';
export 'package:kidtrack/presentation/screens/guardian/list/widgets/guardian_shimmer.dart';
export 'package:kidtrack/presentation/screens/guardian/list/widgets/guardian_sheet.dart';
export 'package:kidtrack/presentation/screens/guardian/list/widgets/parent_create_sheet.dart';
export 'package:kidtrack/Global/services/parent_account_service.dart';
export 'package:kidtrack/Global/services/child_withdrawal_service.dart';

// ─── Owner Screens ────────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/owner/dashboard/owner_dashboard_controller.dart';
export 'package:kidtrack/presentation/screens/owner/dashboard/owner_dashboard_view.dart';
export 'package:kidtrack/presentation/screens/owner/tabs/owner_children_tab.dart';
export 'package:kidtrack/presentation/screens/owner/tabs/owner_nursery_tab.dart';
export 'package:kidtrack/presentation/screens/owner/tabs/owner_education_tab.dart';
export 'package:kidtrack/presentation/screens/owner/tabs/owner_account_tab.dart';
export 'package:kidtrack/presentation/screens/owner/executive/owner_executive_dashboard.dart';
export 'package:kidtrack/presentation/screens/owner/executive/owner_executive_controller.dart';
export 'package:kidtrack/presentation/screens/owner/executive/models/owner_scope.dart';
export 'package:kidtrack/presentation/screens/owner/executive/services/owner_scope_service.dart';
export 'package:kidtrack/presentation/screens/owner/executive/owner_finance_tab.dart';
export 'package:kidtrack/presentation/screens/owner/executive/owner_more_tab.dart';
export 'package:kidtrack/presentation/screens/finance/services/finance_analytics_service.dart';
export 'package:kidtrack/presentation/screens/finance/models/finance_summary.dart';
export 'package:kidtrack/presentation/screens/finance/finance_dashboard_controller.dart';
export 'package:kidtrack/presentation/screens/finance/finance_dashboard_body.dart';
export 'package:kidtrack/presentation/screens/finance/widgets/category_filter_bar.dart';
export 'package:kidtrack/presentation/screens/finance/unpaid/unpaid_subscription_controller.dart';
export 'package:kidtrack/presentation/screens/finance/unpaid/unpaid_subscription_card.dart';
export 'package:kidtrack/presentation/screens/manager/tabs/manager_dashboard_tab.dart';
export 'package:kidtrack/presentation/screens/manager/tabs/manager_children_tab.dart';
export 'package:kidtrack/presentation/screens/manager/tabs/manager_staff_tab.dart';
export 'package:kidtrack/presentation/screens/manager/tabs/manager_finance_tab.dart';
export 'package:kidtrack/presentation/screens/manager/tabs/manager_social_tab.dart';
export 'package:kidtrack/presentation/screens/manager/tabs/manager_more_tab.dart';
export 'package:kidtrack/presentation/screens/manager/children/manager_children_controller.dart';
export 'package:kidtrack/presentation/screens/manager/staff/manager_staff_controller.dart';
export 'package:kidtrack/presentation/screens/manager/finance/manager_finance_controller.dart';
export 'package:kidtrack/presentation/screens/manager/more/manager_more_controller.dart';
export 'package:kidtrack/presentation/screens/manager/dashboard/manager_dashboard_controller.dart';
export 'package:kidtrack/presentation/screens/manager/profile/manager_nursery_profile_controller.dart';
export 'package:kidtrack/presentation/screens/manager/profile/manager_nursery_profile_view.dart';
export 'package:kidtrack/presentation/screens/manager/application_file/manager_application_file_controller.dart';
export 'package:kidtrack/presentation/screens/manager/application_file/manager_application_file_view.dart';
export 'package:kidtrack/presentation/screens/manager/teacher_reports/manager_teacher_reports_controller.dart';
export 'package:kidtrack/presentation/screens/manager/teacher_reports/manager_teacher_reports_view.dart';
export 'package:kidtrack/presentation/screens/manager/live_teaching/live_teaching_controller.dart';
export 'package:kidtrack/presentation/screens/manager/live_teaching/live_teaching_card.dart';
export 'package:kidtrack/presentation/screens/manager/live_teaching/detail/teacher_today_controller.dart';
export 'package:kidtrack/presentation/screens/manager/applications/manager_applications_controller.dart';
export 'package:kidtrack/presentation/screens/manager/applications/manager_applications_view.dart';
export 'package:kidtrack/presentation/screens/manager/presence/manager_presence_controller.dart';
export 'package:kidtrack/presentation/screens/manager/presence/manager_presence_view.dart';

// ─── Receptionist Check-In Screen ────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/receptionist/checkin/receptionist_checkin_controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/checkin/receptionist_checkin_view.dart';

// ─── Child Attendance Screens ─────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/attendance/controller.dart';
export 'package:kidtrack/presentation/screens/children/attendance/view.dart';
export 'package:kidtrack/presentation/screens/children/attendance/widgets/attendance_child_card.dart';
export 'package:kidtrack/presentation/screens/children/attendance/widgets/attendance_child_empty.dart';
export 'package:kidtrack/presentation/screens/children/attendance/widgets/attendance_child_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/attendance/widgets/attendance_child_filter_bar.dart';
export 'package:kidtrack/presentation/screens/children/attendance/widgets/attendance_child_sheet.dart';

// ─── Daily Care Screens ───────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/daily_care/controller.dart';
export 'package:kidtrack/presentation/screens/children/daily_care/view.dart';
export 'package:kidtrack/presentation/screens/children/daily_care/widgets/daily_care_card.dart';
export 'package:kidtrack/presentation/screens/children/daily_care/widgets/daily_care_empty.dart';
export 'package:kidtrack/presentation/screens/children/daily_care/widgets/daily_care_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/daily_care/widgets/daily_care_sheet.dart';

// ─── Child Leave Request Screens ──────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/children/leave_requests/controller.dart';
export 'package:kidtrack/presentation/screens/children/leave_requests/view.dart';
export 'package:kidtrack/presentation/screens/children/leave_requests/widgets/child_leave_card.dart';
export 'package:kidtrack/presentation/screens/children/leave_requests/widgets/child_leave_empty.dart';
export 'package:kidtrack/presentation/screens/children/leave_requests/widgets/child_leave_shimmer.dart';
export 'package:kidtrack/presentation/screens/children/leave_requests/widgets/child_leave_filter_bar.dart';
export 'package:kidtrack/presentation/screens/children/leave_requests/widgets/child_leave_sheet.dart';

// ─── Invoice Screens ──────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/finance/invoices/controller.dart';
export 'package:kidtrack/presentation/screens/finance/invoices/view.dart';
export 'package:kidtrack/presentation/screens/finance/invoices/widgets/invoice_card.dart';
export 'package:kidtrack/presentation/screens/finance/invoices/widgets/invoice_empty.dart';
export 'package:kidtrack/presentation/screens/finance/invoices/widgets/invoice_shimmer.dart';
export 'package:kidtrack/presentation/screens/finance/invoices/widgets/invoice_filter_bar.dart';
export 'package:kidtrack/presentation/screens/finance/invoices/widgets/invoice_sheet.dart';

// ─── Overdue / Obligations Screen ─────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/finance/overdue/overdue_models.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/controller.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/view.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_dashboard.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_date_bar.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_hero_card.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_filter_bar.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_category_bar.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_card.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_empty.dart';
export 'package:kidtrack/presentation/screens/finance/overdue/widgets/overdue_create_view.dart';

// ─── Payment Screens ──────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/finance/payments/controller.dart';
export 'package:kidtrack/presentation/screens/finance/payments/view.dart';
export 'package:kidtrack/presentation/screens/finance/payments/widgets/payment_card.dart';
export 'package:kidtrack/presentation/screens/finance/payments/widgets/payment_empty.dart';
export 'package:kidtrack/presentation/screens/finance/payments/widgets/payment_shimmer.dart';
export 'package:kidtrack/presentation/screens/finance/payments/widgets/payment_sheet.dart';

// ─── Payment Categories ────────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/payment_category/payment_category_model.dart';
export 'package:kidtrack/presentation/screens/finance/categories/payment_categories_controller.dart';
export 'package:kidtrack/presentation/screens/finance/categories/payment_categories_view.dart';
export 'package:kidtrack/presentation/screens/finance/categories/widgets/category_sheet.dart';
export 'package:kidtrack/presentation/screens/settings/shifts/shifts_controller.dart';
export 'package:kidtrack/presentation/screens/settings/shifts/shifts_view.dart';
export 'package:kidtrack/presentation/screens/settings/shifts/widgets/shift_card.dart';
export 'package:kidtrack/presentation/screens/settings/shifts/widgets/shift_sheet.dart';
export 'package:kidtrack/presentation/screens/parent/reports/reports_hub_view.dart';
export 'package:kidtrack/presentation/screens/parent/reports/attendance/weekly_attendance_controller.dart';
export 'package:kidtrack/presentation/screens/parent/reports/attendance/weekly_attendance_view.dart';
export 'package:kidtrack/presentation/screens/parent/reports/evaluation/weekly_evaluation_controller.dart';
export 'package:kidtrack/presentation/screens/parent/reports/evaluation/weekly_evaluation_view.dart';
export 'package:kidtrack/presentation/screens/parent/reports/learning/weekly_learning_controller.dart';
export 'package:kidtrack/presentation/screens/parent/reports/learning/weekly_learning_view.dart';
export 'package:kidtrack/presentation/screens/parent/reports/financial/financial_report_controller.dart';
export 'package:kidtrack/presentation/screens/parent/reports/financial/financial_report_view.dart';
export 'package:kidtrack/presentation/screens/parent/reports/monthly/monthly_report_controller.dart';
export 'package:kidtrack/presentation/screens/parent/reports/monthly/monthly_report_view.dart';
export 'package:kidtrack/Global/services/finance_service.dart';
export 'package:kidtrack/Global/services/monthly_invoice_service.dart';

// ─── Nursery Contact Numbers (parent WhatsApp) ──────────────────────────────────
export 'package:kidtrack/Data/models/nursery_contact/nursery_contact_model.dart';
export 'package:kidtrack/presentation/parentControllers/services/nursery_contact_parent_service.dart';
export 'package:kidtrack/presentation/screens/owner/contacts/nursery_contacts_controller.dart';
export 'package:kidtrack/presentation/screens/owner/contacts/nursery_contacts_view.dart';
export 'package:kidtrack/presentation/screens/owner/contacts/widgets/nursery_contact_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/nursery_feedback/nursery_feedback_list_controller.dart';
export 'package:kidtrack/presentation/screens/shared/nursery_feedback/nursery_feedback_list_view.dart';
export 'package:kidtrack/presentation/screens/shared/nursery_whatsapp_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/activation_message.dart';
export 'package:kidtrack/presentation/screens/shared/activation_qr.dart';
export 'package:kidtrack/presentation/screens/shared/activation_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/activation_pdf.dart';

// ─── Parent Invoices ───────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/parent/invoices/parent_invoices_controller.dart';
export 'package:kidtrack/presentation/screens/parent/invoices/parent_invoices_view.dart';

// ─── Super Admin Screens ──────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/super_admin/dashboard/controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/dashboard/view.dart';
export 'package:kidtrack/presentation/screens/super_admin/dashboard/widgets/sa_header.dart';
export 'package:kidtrack/presentation/screens/super_admin/dashboard/widgets/sa_action_card.dart';
export 'package:kidtrack/presentation/screens/super_admin/dashboard/widgets/sa_actions_section.dart';

// ─── Audit Log Screens ────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/super_admin/audit_log/controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/audit_log/view.dart';
export 'package:kidtrack/presentation/screens/super_admin/audit_log/widgets/audit_card.dart';
export 'package:kidtrack/presentation/screens/super_admin/audit_log/widgets/audit_empty.dart';
export 'package:kidtrack/presentation/screens/super_admin/audit_log/widgets/audit_shimmer.dart';
export 'package:kidtrack/presentation/screens/super_admin/audit_log/widgets/audit_filter_bar.dart';

// ─── Support Ticket Screens ───────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/view.dart';
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/widgets/ticket_card.dart';
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/widgets/ticket_empty.dart';
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/widgets/ticket_shimmer.dart';
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/widgets/ticket_filter_bar.dart';
export 'package:kidtrack/presentation/screens/super_admin/support_tickets/widgets/support_ticket_sheet.dart';

// ─── Platform Subscription Billing ────────────────────────────────────────────
export 'package:kidtrack/Data/models/platform_bill/platform_bill_model.dart';
export 'package:kidtrack/Global/services/platform_billing_service.dart';
export '../Global/services/kidtrack_campaign_service.dart';
export '../Global/services/kidtrack_feedback_service.dart';
export 'package:kidtrack/presentation/screens/billing/my_subscription_controller.dart';
export 'package:kidtrack/presentation/screens/billing/my_subscription_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/billing/sa_billing_controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/billing/sa_billing_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/billing/sa_billing_detail_controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/billing/sa_billing_detail_view.dart';

// ─── Nursery Widgets ──────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/nurseries/list/widgets/nursery_owner_section.dart';

// ─── Design System ───────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/design_systems/widgets/date_picker/date_picker_widget.dart';

// ─── Parent Screens ───────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/parent/dashboard/controller.dart';
export 'package:kidtrack/presentation/screens/parent/dashboard/view.dart';
export 'package:kidtrack/presentation/screens/parent/dashboard/widgets/payment_reminder_section.dart';
export 'package:kidtrack/presentation/screens/parent/today_schedule/view.dart';
export 'package:kidtrack/presentation/screens/parent/posts/controller.dart';
export 'package:kidtrack/presentation/screens/parent/posts/view.dart';
export 'package:kidtrack/presentation/screens/parent/pickup_history/controller.dart';
export 'package:kidtrack/presentation/screens/parent/pickup_history/view.dart';
export 'package:kidtrack/presentation/screens/parent/education/controller.dart';
export 'package:kidtrack/presentation/screens/parent/education/view.dart';
export 'package:kidtrack/presentation/screens/parent/education/homework_all_view.dart';
export 'package:kidtrack/presentation/screens/parent/education/subjects_all_view.dart';
export 'package:kidtrack/presentation/screens/parent/link_book/link_book_controller.dart';
export 'package:kidtrack/presentation/screens/parent/link_book/link_book_view.dart';
export 'package:kidtrack/presentation/screens/parent/link_book/link_book_day_view.dart';
export 'package:kidtrack/presentation/screens/parent/link_book/subject_history_view.dart';
export 'package:kidtrack/presentation/screens/parent/medical/controller.dart';
export 'package:kidtrack/presentation/screens/parent/medical/view.dart';
export 'package:kidtrack/presentation/screens/parent/courses/controller.dart';
export 'package:kidtrack/presentation/screens/parent/courses/view.dart';
export 'package:kidtrack/Data/models/nursery_course/nursery_course_model.dart';
export 'package:kidtrack/presentation/screens/parent/account/controller.dart';
export 'package:kidtrack/presentation/screens/parent/account/view.dart';
export 'package:kidtrack/presentation/screens/parent/notifications/notification_prefs_controller.dart';
export 'package:kidtrack/presentation/screens/parent/notifications/notification_prefs_sheet.dart';
export 'package:kidtrack/presentation/screens/parent/home_location/controller.dart';
export 'package:kidtrack/presentation/screens/parent/home_location/view.dart';
export 'package:kidtrack/presentation/screens/owner/bus_assignment/controller.dart';
export 'package:kidtrack/presentation/screens/owner/bus_assignment/view.dart';
export 'package:kidtrack/presentation/screens/parent/class_photos/view.dart';

// ─── Nursery Discovery (pre-login) ──────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/discovery/list/controller.dart';
export 'package:kidtrack/presentation/screens/discovery/list/view.dart';
export 'package:kidtrack/presentation/screens/discovery/profile/controller.dart';
export 'package:kidtrack/presentation/screens/discovery/profile/view.dart';
export 'package:kidtrack/presentation/screens/discovery/apply/online_application_controller.dart';
export 'package:kidtrack/presentation/screens/discovery/apply/online_application_view.dart';
export 'package:kidtrack/presentation/screens/discovery/apply/apply_success_view.dart';

// ─── Platform Content (Settings, Contact, About, Support) ───────────────────────
export 'package:kidtrack/presentation/screens/settings/app_settings_view.dart';
export 'package:kidtrack/presentation/screens/settings/contact_us/contact_us_controller.dart';
export 'package:kidtrack/presentation/screens/settings/contact_us/contact_us_view.dart';
export 'package:kidtrack/presentation/screens/settings/about_us/about_us_controller.dart';
export 'package:kidtrack/presentation/screens/settings/about_us/about_us_view.dart';
export 'package:kidtrack/presentation/screens/settings/support/support_request_controller.dart';
export 'package:kidtrack/presentation/screens/settings/support/support_request_view.dart';
export 'package:kidtrack/presentation/screens/settings/join_us/join_us_controller.dart';
export 'package:kidtrack/presentation/screens/settings/join_us/join_us_view.dart';
export 'package:kidtrack/presentation/screens/settings/app_review/app_review_controller.dart';
export 'package:kidtrack/presentation/screens/settings/app_review/app_review_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/cities/cities_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/feedback_campaigns/kidtrack_campaigns_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/feedback_responses/kidtrack_feedback_responses_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/platform_content_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/contact_info_form_controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/contact_info_form_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/about_us_form_controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/about_us_form_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/support_requests_controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/support_requests_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/widgets/support_request_reply_sheet.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/app_reviews_controller.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/app_reviews_view.dart';
export 'package:kidtrack/presentation/screens/super_admin/platform_content/widgets/app_review_reply_sheet.dart';

// ─── Shared Screens ───────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/shared/edit_profile_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/child_details_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/language_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/contact_sheet.dart';
export 'package:kidtrack/presentation/screens/shared/logout_helper.dart';
export 'package:kidtrack/presentation/screens/shared/role_switch_helper.dart';

// ─── Parent Requests History ──────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/parent/requests_history/controller.dart';
export 'package:kidtrack/presentation/screens/parent/requests_history/view.dart';
export 'package:kidtrack/presentation/screens/parent/requests_history/widgets/parent_leave_card.dart';
export 'package:kidtrack/presentation/screens/parent/requests_history/widgets/parent_leave_empty.dart';
export 'package:kidtrack/presentation/screens/parent/requests_history/widgets/parent_leave_shimmer.dart';

// ─── Staff Account Screens ────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/staff/account/controller.dart';
export 'package:kidtrack/presentation/screens/staff/account/view.dart';

// ─── Setup Screens ────────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/setup/owner/controller.dart';
export 'package:kidtrack/presentation/screens/setup/owner/view.dart';
export 'package:kidtrack/presentation/screens/setup/manager/controller.dart';
export 'package:kidtrack/presentation/screens/setup/manager/view.dart';
export 'package:kidtrack/presentation/screens/setup/checklist/controller.dart';
export 'package:kidtrack/presentation/screens/setup/checklist/view.dart';

// ─── Receptionist Screens ─────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/pickup_request/pickup_request_model.dart';
export 'package:kidtrack/presentation/parentControllers/services/pickup_request_parent_service.dart';
export 'package:kidtrack/presentation/screens/receptionist/dashboard/controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/dashboard/view.dart';
export 'package:kidtrack/presentation/screens/receptionist/absent/absent_today_controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/absent/widgets/absent_today_section.dart';
export 'package:kidtrack/presentation/screens/receptionist/absent/widgets/absent_child_tile.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_dashboard_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_children_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/children/add_child/add_child_view.dart';
export 'package:kidtrack/presentation/screens/receptionist/children/parent_account/parent_account_view.dart';
export 'package:kidtrack/presentation/screens/receptionist/children/bulk_invitations/bulk_invitations_view.dart';
export 'package:kidtrack/presentation/screens/receptionist/children/bulk_invitations/bulk_invitations_controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_parents_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_classes_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_operations_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_account_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/tabs/receptionist_finance_tab.dart';
export 'package:kidtrack/presentation/screens/receptionist/pickup_requests/controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/pickup_requests/view.dart';
export 'package:kidtrack/presentation/screens/receptionist/pickup_verification/controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/pickup_verification/view.dart';

// ─── Chaperone Screens ────────────────────────────────────────────────────────
export 'package:kidtrack/presentation/screens/chaperone/home/controller.dart';
export 'package:kidtrack/presentation/screens/chaperone/home/view.dart';
export 'package:kidtrack/presentation/screens/chaperone/history/controller.dart';
export 'package:kidtrack/presentation/screens/chaperone/history/view.dart';

// ─── Bus Tracking ─────────────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/bus_tracking/bus_tracking_model.dart';
export 'package:kidtrack/Global/services/bus_tracking_service.dart';

// ─── Teacher UI ───────────────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/classroom_activity/classroom_activity_model.dart';
export 'package:kidtrack/Global/services/teacher_activity_service.dart';
export 'package:kidtrack/Global/services/teacher_academic_service.dart';
export 'package:kidtrack/presentation/screens/teacher/home/teacher_home_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/home/teacher_home_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/activity/teacher_activity_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/activity/teacher_activity_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/students/teacher_students_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/students/teacher_students_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/onboarding/teacher_onboarding_view.dart';
export 'package:kidtrack/presentation/screens/teacher/onboarding/teacher_onboarding_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/lessons/teacher_lessons_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/lessons/teacher_lessons_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/assessment/teacher_assessment_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/assessment/teacher_assessment_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/classes/teacher_classes_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/classes/teacher_classes_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/link_book/teacher_link_book_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/link_book/link_book_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/link_book/widgets/lb_filter_bar.dart';
export 'package:kidtrack/presentation/screens/teacher/link_book/widgets/lb_classroom_report.dart';
export 'package:kidtrack/presentation/screens/teacher/link_book/widgets/lb_child_summary.dart';
export 'package:kidtrack/presentation/screens/teacher/link_book/widgets/lb_activity_detail_view.dart';
export 'package:kidtrack/presentation/screens/teacher/reports/teacher_reports_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/reports/activity_report_view.dart';
export 'package:kidtrack/presentation/screens/teacher/reports/widgets/report_activity_card.dart';
export 'package:kidtrack/presentation/screens/teacher/homework/homework_tab_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/homework/teacher_homework_tab.dart';
export 'package:kidtrack/presentation/screens/teacher/homework/widgets/hw_report_card.dart';
export 'package:kidtrack/presentation/screens/teacher/homework/widgets/hw_detail_view.dart';

// ─── Feed ─────────────────────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/feed/nursery_post_model.dart';
export 'package:kidtrack/Global/services/feed_service.dart';
export 'package:kidtrack/presentation/screens/feed/feed_controller.dart';
export 'package:kidtrack/presentation/screens/feed/feed_view.dart';
export 'package:kidtrack/presentation/screens/feed/widgets/post_card.dart';
export 'package:kidtrack/presentation/screens/feed/widgets/create_post_sheet.dart';

// ─── Chat (manager ↔ parent, per child) ───────────────────────────────────────
export 'package:kidtrack/Data/models/chat/chat_message_model.dart';
export 'package:kidtrack/Data/models/chat/chat_conversation_model.dart';
export 'package:kidtrack/Global/services/chat_service.dart';
export 'package:kidtrack/presentation/screens/chat/chat_list_controller.dart';
export 'package:kidtrack/presentation/screens/chat/chat_list_view.dart';
export 'package:kidtrack/presentation/screens/chat/chat_thread_controller.dart';
export 'package:kidtrack/presentation/screens/chat/chat_thread_view.dart';
export 'package:kidtrack/presentation/screens/chat/parent_chat_launcher.dart';
export 'package:kidtrack/presentation/screens/chat/staff_chat_launcher.dart';
export 'package:kidtrack/presentation/screens/chat/widgets/chat_unread_badge.dart';

// ─── Events ───────────────────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/nursery_event/nursery_event_model.dart';
export 'package:kidtrack/Data/models/event_attendance/event_attendance_model.dart';
export 'package:kidtrack/Global/services/event_service.dart';
export 'package:kidtrack/presentation/screens/receptionist/events/events_controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/events/events_view.dart';
export 'package:kidtrack/Data/models/holiday/holiday_model.dart';
export 'package:kidtrack/Global/services/holiday_service.dart';
export 'package:kidtrack/presentation/screens/holidays/holidays_controller.dart';
export 'package:kidtrack/presentation/screens/holidays/holidays_view.dart';
export 'package:kidtrack/presentation/screens/receptionist/collections/collections_controller.dart';
export 'package:kidtrack/presentation/screens/receptionist/collections/late_payers_view.dart';
export 'package:kidtrack/presentation/screens/receptionist/collections/reception_payment_sheet.dart';
export 'package:kidtrack/presentation/screens/parent/events/parent_events_controller.dart';
export 'package:kidtrack/presentation/screens/parent/events/parent_events_view.dart';

// ─── Courses ──────────────────────────────────────────────────────────────────
export 'package:kidtrack/Global/services/course_service.dart';
export 'package:kidtrack/presentation/screens/courses/owner/owner_courses_tab.dart';
export 'package:kidtrack/presentation/screens/courses/owner/owner_courses_controller.dart';
export 'package:kidtrack/presentation/screens/courses/owner/course_lessons_view.dart';
export 'package:kidtrack/presentation/screens/courses/owner/course_lessons_controller.dart';
export 'package:kidtrack/presentation/screens/courses/parent/lesson_viewer_view.dart';
export 'package:kidtrack/presentation/screens/receptionist/courses/receptionist_courses_tab.dart';

// ── Evaluation Reasons ────────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/evaluation_reason/evaluation_reason_model.dart';
export 'package:kidtrack/Global/services/evaluation_reasons_service.dart';
export 'package:kidtrack/presentation/screens/teacher/activity_reasons/evaluation_reasons_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/activity_reasons/evaluation_reasons_view.dart';

// ── Child State Templates ─────────────────────────────────────────────────────
export 'package:kidtrack/Data/models/child_state_template/child_state_option.dart';
export 'package:kidtrack/Data/models/child_state_template/child_state_template_model.dart';
export 'package:kidtrack/Global/services/child_state_service.dart';
export 'package:kidtrack/Global/widgets/child_state_dropdown.dart';
export 'package:kidtrack/Global/widgets/child_state_picker_sheet.dart';
export 'package:kidtrack/Global/widgets/child_state_icons.dart';
export 'package:kidtrack/presentation/parentControllers/services/child_state_template_parent_service.dart';
export 'package:kidtrack/presentation/screens/owner/child_states/child_states_controller.dart';
export 'package:kidtrack/presentation/screens/owner/child_states/child_states_view.dart';
export 'package:kidtrack/presentation/screens/owner/child_states/widgets/state_card.dart';
export 'package:kidtrack/presentation/screens/owner/child_states/widgets/state_sheet.dart';
export 'package:kidtrack/presentation/screens/owner/child_states/widgets/state_classification_editor.dart';
export 'package:kidtrack/presentation/screens/owner/child_states/widgets/state_option_editor_card.dart';
export 'package:kidtrack/presentation/screens/teacher/home/classroom_states_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/teacher_weekly_schedule_controller.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/teacher_weekly_schedule_view.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/widgets/schedule_slot_card.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/widgets/schedule_entry_sheet.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/widgets/schedule_empty_section.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/widgets/schedule_no_classrooms_section.dart';
export 'package:kidtrack/presentation/screens/teacher/schedule/widgets/schedule_filter_bar.dart';
export 'package:kidtrack/presentation/screens/teacher/home/widgets/weekly_schedule_widget.dart';
export 'package:kidtrack/presentation/screens/teacher/home/widgets/quick_tasks_card.dart';
