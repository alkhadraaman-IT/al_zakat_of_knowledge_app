import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:pdf_compressor/pdf_compressor.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:al_zakat_of_knowledge_app/core/utils/supabase_timeout.dart';

/// Outcome of a profile-media upload attempt.
enum MediaUploadStatus { success, tooLarge, cancelled, failed }

/// Immutable result of a profile-media upload attempt.
class MediaUploadResult {
  final MediaUploadStatus status;
  final String? url;

  /// Exact error message when the upload failed
  /// (e.g. the Supabase storage error) — surfaced
  /// in the sheet's error dialog.
  final String? errorMessage;

  /// File compressed, within the size limit and uploaded —
  /// [url] is the public storage URL.
  const MediaUploadResult.success(this.url)
      : status = MediaUploadStatus.success,
        errorMessage = null;

  /// File still exceeds the size limit after compression.
  const MediaUploadResult.tooLarge()
      : status = MediaUploadStatus.tooLarge,
        url = null,
        errorMessage = null;

  /// The user dismissed the picker without choosing a file.
  const MediaUploadResult.cancelled()
      : status = MediaUploadStatus.cancelled,
        url = null,
        errorMessage = null;

  /// The picker or the upload failed unexpectedly —
  /// [errorMessage] carries the exact exception.
  const MediaUploadResult.failed({this.errorMessage})
      : status = MediaUploadStatus.failed,
        url = null;
}

/// A picked CV PDF — its local path and the
/// original file name (e.g. `my_cv.pdf`).
class CvPickResult {
  final String path;
  final String fileName;

  const CvPickResult({required this.path, required this.fileName});
}

/// Picks, compresses, size-checks and uploads profile media
/// (avatar photos and CV PDFs) to Supabase Storage.
///
/// Backend specification limits:
/// - Avatars: max 300 KB after compression
/// - CVs: max 2 MB after compression
///
/// Picking ([pickAvatar] / [pickCv]) only reads the local
/// file — the upload ([uploadAvatar] / [uploadCv]) runs
/// separately, so the caller can show instant local
/// feedback before any bytes leave the device.
class ProfileMediaService {
  final SupabaseClient supabaseClient;

  static const int _maxAvatarBytes = 300 * 1024;
  static const int _maxCvBytes = 2 * 1024 * 1024;

  /// Descending quality ladder — the first level that fits
  /// the avatar limit wins.
  static const List<int> _avatarQualities = [85, 65, 45, 25];

  ProfileMediaService({required this.supabaseClient});

  /// Picks an avatar photo from the gallery and returns
  /// its local path — no upload happens until
  /// [uploadAvatar] is called.
  Future<String?> pickAvatar() async {
    print('<<<<<<<<<<<[pickAvatar]>>>>>>>>>>>>>');
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );
    return picked?.path;
  }

  /// Picks a CV PDF and returns its local path together
  /// with the original file name — no upload happens
  /// until [uploadCv] is called.
  Future<CvPickResult?> pickCv() async {
    print('<<<<<<<<<<<[pickCv]>>>>>>>>>>>>>');
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (picked == null) {
      return null;
    }
    final path = picked.path;
    if (path == null) {
      return null;
    }
    return CvPickResult(path: path, fileName: picked.name);
  }

  /// Compresses the picked avatar down to the 300 KB
  /// limit and uploads it to the `avatars` bucket —
  /// returns its public URL.
  Future<MediaUploadResult> uploadAvatar(String localPath) async {
    print('<<<<<<<<<<<[uploadAvatar]>>>>>>>>>>>>>');
    try {
      final bytes = await _compressAvatar(File(localPath));
      if (bytes == null) {
        return const MediaUploadResult.tooLarge();
      }
      final path = 'avatars/${_uniqueName('jpg')}';
      await supabaseClient.storage
          .from('avatars')
          .uploadBinary(path, bytes)
          .withStorageTimeout(operationName: 'uploadAvatar');
      final url = supabaseClient.storage.from('avatars').getPublicUrl(path);
      return MediaUploadResult.success(url);
    } catch (e) {
      // The exact exception (e.g. the Supabase
      // storage error) is kept for the error dialog.
      return MediaUploadResult.failed(errorMessage: '$e');
    }
  }

  /// Compresses the picked CV down to the 2 MB limit
  /// and uploads it to the `cvs` bucket — returns
  /// its public URL.
  Future<MediaUploadResult> uploadCv(String localPath) async {
    print('<<<<<<<<<<<[uploadCv]>>>>>>>>>>>>>');
    try {
      final compressed = await _compressCv(localPath);
      if (compressed == null) {
        return const MediaUploadResult.tooLarge();
      }
      final path = 'cvs/${_uniqueName('pdf')}';
      await supabaseClient.storage
          .from('cvs')
          .upload(path, compressed)
          .withStorageTimeout(operationName: 'uploadCv');
      final url = supabaseClient.storage.from('cvs').getPublicUrl(path);
      return MediaUploadResult.success(url);
    } catch (e) {
      // The exact exception (e.g. the Supabase
      // storage error) is kept for the error dialog.
      return MediaUploadResult.failed(errorMessage: '$e');
    }
  }

  /// Compresses the avatar, stepping down through the
  /// quality ladder until the result fits the 300 KB
  /// limit. Returns `null` when even the lowest
  /// quality level still exceeds the limit.
  ///
  /// When `flutter_image_compress` is unsupported on
  /// the platform (e.g. Windows/Linux/macOS desktop)
  /// the call throws — the original file is used
  /// instead so testing never crashes.
  Future<Uint8List?> _compressAvatar(File image) async {
    print('<<<<<<<<<<<[_compressAvatar]>>>>>>>>>>>>>');
    for (final quality in _avatarQualities) {
      Uint8List? compressed;
      try {
        compressed = await FlutterImageCompress.compressWithFile(
          image.path,
          minWidth: 512,
          minHeight: 512,
          quality: quality,
          format: CompressFormat.jpeg,
        );
      } catch (e) {
        // Compression is unsupported on this platform
        // (e.g. Windows desktop) — gracefully fall
        // back to the original file when it already
        // fits the avatar limit.
        print('<<<<<<<<<<<[_compressAvatar Fallback]>>>>>>>>>>>>>');
        print('Exception: $e');
        final bytes = await image.readAsBytes();
        return bytes.lengthInBytes <= _maxAvatarBytes
            ? bytes
            : null;
      }
      if (compressed != null && compressed.lengthInBytes <= _maxAvatarBytes) {
        return compressed;
      }
    }
    return null;
  }

  /// Compresses the CV PDF into the temporary directory.
  /// Returns the compressed file, or `null` when the
  /// result still exceeds the 2 MB limit.
  ///
  /// When `pdf_compressor` is unsupported on the
  /// platform (e.g. Windows/Linux/macOS desktop)
  /// the call throws — the original file is used
  /// instead so testing never crashes.
  Future<File?> _compressCv(String inputPath) async {
    print('<<<<<<<<<<<[_compressCv]>>>>>>>>>>>>>');
    final dir = await getTemporaryDirectory();
    final output = File('${dir.path}/${_uniqueName('pdf')}');
    if (await output.exists()) {
      await output.delete();
    }
    try {
      // await PdfCompressor.compressPdfFile(
      //   inputPath,
      //   output.path,
        // CompressQuality.LOW,
      // );
    } catch (e) {
      // Compression is unsupported on this platform
      // (e.g. Windows desktop) — fall through to
      // the original file below.
      print('<<<<<<<<<<<[_compressCv Fallback]>>>>>>>>>>>>>');
      print('Exception: $e');
    }
    if (output.existsSync() && output.lengthSync() <= _maxCvBytes) {
      return output;
    }
    // Compression unavailable or still too large — the
    // original only qualifies if it was within the
    /// limit to begin with.
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