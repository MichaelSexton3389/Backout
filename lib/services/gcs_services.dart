import 'dart:io';
import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/storage/v1.dart' as gcs;
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class GCSService {
  static const String bucketName = 'backout-message-files';

  // Authenticate using service account credentials
  static Future<AuthClient> getAuthClient() async {
    try {
      // Load service account credentials from assets
      final jsonString =
          await rootBundle.loadString('assets/service-account.json');
      final credentials =
          ServiceAccountCredentials.fromJson(jsonDecode(jsonString));

      return await clientViaServiceAccount(
          credentials, [gcs.StorageApi.devstorageFullControlScope]);
    } catch (e) {
      print("Error loading credentials: $e");
      rethrow;
    }
  }

  // Upload image to Google Cloud Storage
  static Future<String?> uploadImageToGCS(File imageFile) async {
    try {
      final authClient = await getAuthClient();
      final storageApi = gcs.StorageApi(authClient);

      String fileName = "images/${DateTime.now().millisecondsSinceEpoch}.jpg";
      final media = gcs.Media(imageFile.openRead(), imageFile.lengthSync());

      final object = gcs.Object()..name = fileName;

      await storageApi.objects.insert(object, bucketName, uploadMedia: media);

      // Return public URL of the uploaded image
      final imageUrl = "https://storage.googleapis.com/$bucketName/$fileName";

      return imageUrl;
    } catch (e, stackTrace) {
      print("Error uploading image to GCS: $e");
      print("Stack trace: $stackTrace");
      return null;
    }
  }
}
