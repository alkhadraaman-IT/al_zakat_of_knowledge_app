import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_compressor/pdf_compressor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Outcome of a profile-media upload attempt.
enum MediaUploadStatus { success, tooLarge, cancelled, failed }

/// Immutable result of a profile-media upload attempt.
class MediaUploadResult {
  final MediaUploadStatus status;
  final String? url;

  /// File compressed, within the size limit and uploaded —
  /// [url] is the public storage URL.
  const MediaUploadResult.success(this.url)
      : status = MediaUploadStatus.success;

  /// File still exceeds the size limit after compression.
  const MediaUploadResult.tooLarge()
      : status = MediaUploadStatus.tooLarge,
        url = null;

  /// The user dismissed the picker without choosing a file.
  const MediaUploadResult.cancelled()
      : status = MediaUploadStatus.cancelled,
        url = null;

  /// The picker or the upload failed unexpectedly.
  const MediaUploadResult.failed()
      : status = MediaUploadStatus.failed,
        url = null;
}

/// Picks, compresses, size-checks and uploads profile media
/// (avatar photos and CV PDFs) to Supabase Storage.
///
/// Backend specification limits:
/// - Avatars: max 300 KB after compression
/// - CVs: max 2 MB after compression
class ProfileMediaService {
  final SupabaseClient supabaseClient;

  static const int _maxAvatarBytes = 300 * 1024;
  static const int _maxCvBytes = 2 * 1024 * 1024;

  /// Descending quality ladder — the first level that fits
  /// the avatar limit wins.
  static const List<int> _avatarQualities = [85, 65, 45, 25];

  ProfileMediaService({required this.supabaseClient});

  /// Picks an avatar photo from the gallery, compresses it
  /// down to the 300 KB limit, uploads it to the `avatars`
  /// bucket and returns its public URL.
  Future<MediaUploadResult> pickAndUploadAvatar() async {
    print('<<<<<<<<<<<[pickAndUploadAvatar]>>>>>>>>>>>>>');
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    if (picked == null) {
      return const MediaUploadResult.cancelled();
    }
    try {
      final bytes = await _compressAvatar(File(picked.path));
      if (bytes == null) {
        return const MediaUploadResult.tooLarge();
      }
      final path = 'avatars/${_uniqueName('jpg')}';
      await supabaseClient.storage.from('avatars').uploadBinary(path, bytes);
      final url = supabaseClient.storage.from('avatars').getPublicUrl(path);
      return MediaUploadResult.success(url);
    } catch (e) {
      return const MediaUploadResult.failed();
    }
  }

  /// Picks a CV PDF, compresses it down to the 2 MB limit,
  /// uploads it to the `cvs` bucket and returns its public URL.
  Future<MediaUploadResult> pickAndUploadCv() async {
    print('<<<<<<<<<<<[pickAndUploadCv]>>>>>>>>>>>>>');
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    final inputPath = picked?.path;
    if (inputPath == null) {
      return const MediaUploadResult.cancelled();
    }
    try {
      final compressed = await _compressCv(inputPath);
      if (compressed == null) {
        return const MediaUploadResult.tooLarge();
      }
      final path = 'cvs/${_uniqueName('pdf')}';
      await supabaseClient.storage.from('cvs').upload(path, compressed);
      final url = supabaseClient.storage.from('cvs').getPublicUrl(path);
      return MediaUploadResult.success(url);
    } catch (e) {
      return const MediaUploadResult.failed();
    }
  }

  /// Compresses the avatar, stepping down through the
  /// quality ladder until the result fits the 300 KB
  /// limit. Returns `null` when even the lowest
  /// quality level still exceeds the limit.
  Future<Uint8List?> _compressAvatar(File image) async {
    print('<<<<<<<<<<<[_compressAvatar]>>>>>>>>>>>>>');
    for (final quality in _avatarQualities) {
      final compressed = await FlutterImageCompress.compressWithFile(
        image.path,
        minWidth: 512,
        minHeight: 512,
        quality: quality,
        format: CompressFormat.jpeg,
      );
      if (compressed != null && compressed.lengthInBytes <= _maxAvatarBytes) {
        return compressed;
      }
    }
    return null;
  }

  /// Compresses the CV PDF into the temporary directory.
  /// Returns the compressed file, or `null` when the
  /// result still exceeds the 2 MB limit.
  Future<File?> _compressCv(String inputPath) async {
    print('<<<<<<<<<<<[_compressCv]>>>>>>>>>>>>>');
    final dir = await getTemporaryDirectory();
    final output = File('${dir.path}/${_uniqueName('pdf')}');
    if (await output.exists()) {
      await output.delete();
    }
    await PdfCompressor.compressPdfFile(
      inputPath,
      output.path,
      CompressQuality.LOW,
    );
    if (output.lengthSync() <= _maxCvBytes) {
      return output;
    }
    // Still too large — the original only qualifies if it
    // was within the limit to begin with.
    final original = File(inputPath);
    if (original.lengthSync() <= _maxCvBytes) {
      return original;
    }
    return null;
  }

  /// Unique storage object name — timestamp based to
  /// avoid collisions between uploads.
  String _uniqueName(String extension) {
    print('<<<<<<<<<<<[_uniqueName]>>>>>>>>>>>>>');
    return '${DateTime.now().microsecondsSinceEpoch}.$extension';
  }
}
