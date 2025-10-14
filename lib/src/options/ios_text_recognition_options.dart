/// Options specific to iOS text recognition
class DocumentScanKitTextRecognitionOptionsiOS {
  DocumentScanKitTextRecognitionOptionsiOS({
    this.recognitionLevel = RecognitionLevel.accurate,
    this.usesLanguageCorrection = true,
    this.customWords = const [],
    this.recognitionLanguages = const [],
  });

  /// The recognition level for text recognition. Default is accurate.
  final RecognitionLevel recognitionLevel;

  /// Whether to use language correction during text recognition. Default is true.
  final bool usesLanguageCorrection;

  /// Custom words to be recognized during text recognition.
  final List<String> customWords;

  /// Languages to be used for text recognition.
  final List<String> recognitionLanguages;

  Map<String, dynamic> toJson() => {
        'recognitionLevel': recognitionLevel.index,
        'usesLanguageCorrection': usesLanguageCorrection,
        'customWords': customWords,
        'recognitionLanguages': recognitionLanguages,
      };
}

enum RecognitionLevel {
  /// Accurate recognition level (0)
  accurate,

  /// Fast recognition level (1)
  fast,
}
