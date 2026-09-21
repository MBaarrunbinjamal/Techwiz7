

import 'dart:io';
import 'package:firebase_database/firebase_database.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class FirebaseSupabaseService {
  final DatabaseReference _db = FirebaseDatabase.instance.ref();
  final SupabaseClient _supabase = Supabase.instance.client;

  // ---------------- FILE UPLOAD (Supabase Storage) ----------------

  /// Uploads [file] to Supabase Storage bucket [bucketName].
  /// Returns the public URL.
  Future<String> uploadFile({
    required File file,
    required String bucketName,
    String? fileName,
  }) async {
    try {
      final name = fileName ?? const Uuid().v4();
      final ext = _getExtension(file.path);
      final path = '$name$ext';

      await _supabase.storage.from(bucketName).upload(
        path,
        file,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      return _supabase.storage.from(bucketName).getPublicUrl(path);
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }

  String _getExtension(String path) {
    final dot = path.lastIndexOf('.');
    return dot == -1 ? '' : path.substring(dot);
  }

  /// Uploads [file] to Supabase, merges the resulting link into [data]
  /// under [linkKey], then creates a new record in [tableName].
  /// Returns the new Firebase key.
  Future<String> uploadFileAndSave({
    required File file,
    required String bucketName,
    required String tableName,
    required Map<String, dynamic> data,
    String linkKey = 'fileUrl',
  }) async {
    final url = await uploadFile(file: file, bucketName: bucketName);
    final payload = {...data, linkKey: url};
    return create(tableName: tableName, data: payload);
  }

  // ---------------- CREATE ----------------

  /// Creates a new record under [tableName]. Returns the generated key.
  Future<String> create({
    required String tableName,
    required Map<String, dynamic> data,
  }) async {
    try {
      final newRef = _db.child(tableName).push();
      await newRef.set(data);
      return newRef.key!;
    } catch (e) {
      throw Exception('Create failed: $e');
    }
  }

  // ---------------- READ ----------------

  /// Table name only -> all records. Table name + id -> single record.
  Future<dynamic> read({
    required String tableName,
    String? id,
  }) async {
    try {
      final ref =
      id == null ? _db.child(tableName) : _db.child(tableName).child(id);
      final snapshot = await ref.get();
      if (!snapshot.exists) return null;
      return snapshot.value;
    } catch (e) {
      throw Exception('Read failed: $e');
    }
  }

  // ---------------- UPDATE ----------------

  /// Updates the record [id] under [tableName] with [data].
  Future<void> update({
    required String tableName,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _db.child(tableName).child(id).update(data);
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  // ---------------- DELETE ----------------

  /// Deletes a single record by [id] under [tableName].
  Future<void> deleteById({
    required String tableName,
    required String id,
  }) async {
    try {
      await _db.child(tableName).child(id).remove();
    } catch (e) {
      throw Exception('Delete by id failed: $e');
    }
  }

  /// Deletes ALL records under [tableName].
  Future<void> deleteAll({
    required String tableName,
  }) async {
    try {
      await _db.child(tableName).remove();
    } catch (e) {
      throw Exception('Delete all failed: $e');
    }
  }
}
