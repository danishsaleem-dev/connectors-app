/// Matches the server's mobile upload route exactly: "photo" (images only,
/// 10MB — profile pictures) or "document" (PDF/DOC/DOCX/image, 20MB —
/// consultant experience/education attachments, enquiry form attachments).
enum UploadPurpose {
  photo,
  document;

  /// What actually goes in the multipart `purpose` field — a dedicated
  /// getter (not the built-in `.name`, which can't be overridden on an
  /// enum) so a future rename of these values can't silently change the
  /// wire value without a compile error reminding you to update this too.
  String get wireValue => switch (this) {
    UploadPurpose.photo => 'photo',
    UploadPurpose.document => 'document',
  };
}

/// What a successful upload hands back — see ApiClient.uploadFile's doc
/// comment for which of these two actually gets saved anywhere.
class UploadResult {
  final String path;
  final String? url;

  const UploadResult({required this.path, required this.url});
}
