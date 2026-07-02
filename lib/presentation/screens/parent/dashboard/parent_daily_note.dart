class ParentDailyNote {
  final String text;
  final String severity; // positive | needs_followup | important | info

  const ParentDailyNote({required this.text, required this.severity});
}
