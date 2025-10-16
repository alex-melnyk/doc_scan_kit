/// ScannerModeAndroid is an enum that represents the scanner mode on Android.
enum ScannerModeAndroid {
  /// Basic editing capabilities (crop, rotate, reorder pages, etc…).
  base,

  /// Adds image filters (grayscale, auto image enhancement, etc…)
  /// to the [base] mode.
  filter,

  /// Adds ML-enabled image cleaning capabilities (erase stains, fingers, etc…)
  /// to the [filter] mode. This mode will also allow future major features
  /// to be automatically added along with Google Play services updates,
  /// while the other two modes will maintain their current feature sets
  /// and only receive minor refinements.
  full;
}
