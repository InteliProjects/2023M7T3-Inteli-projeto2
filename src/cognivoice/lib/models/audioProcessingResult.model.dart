class AudioContent {
  final String text;
  final String audio;

  AudioContent({
    required this.text,
    required this.audio,
  });

  factory AudioContent.fromJson(Map<String, dynamic> json) {
    return AudioContent(
      text: json['text'] ?? '',
      audio: json['audio'] ?? '',
    );
  }
}

class AudioProcessingResult {
  final AudioContent question;
  final AudioContent answer;
  final int statusCode;

  AudioProcessingResult({
    required this.question,
    required this.answer,
    required this.statusCode,
  });

  factory AudioProcessingResult.fromJson(Map<String, dynamic> json) {
    return AudioProcessingResult(
      question: AudioContent.fromJson(json['question'] ?? {}),
      answer: AudioContent.fromJson(json['answer'] ?? {}),
      statusCode: json['statusCode'] ?? -1,
    );
  }
}
