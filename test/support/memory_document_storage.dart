/// A [DocumentStorage] that keeps its document in memory, so a test can start
/// the app, "restart" it with the same storage and see what was remembered.
library;

import 'package:qaddy/core/services/document_storage.dart';

/// Remembers the last document written.
class MemoryDocumentStorage implements DocumentStorage {
  MemoryDocumentStorage([this.document]);

  /// The stored document.
  String? document;

  @override
  String? read() => document;

  @override
  Future<void> write(String document) async => this.document = document;
}
