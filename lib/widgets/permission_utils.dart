import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

/// Checks and requests camera and storage/photos permissions.
/// Returns true if all permissions are granted, false otherwise.
Future<bool> checkAndRequestAvatarPermissions(BuildContext context) async {
  // Check current permission status
  final cameraStatus = await Permission.camera.status;
  final photosStatus = await Permission.photos.status;
  final storageStatus = await Permission.storage.status;

  // Check if permissions were previously granted but are now denied (app reset scenario)
  final wasCameraGranted = await Permission.camera.isGranted;
  final wasPhotosGranted = await Permission.photos.isGranted;
  final wasStorageGranted = await Permission.storage.isGranted;

  bool allGranted = cameraStatus.isGranted && (photosStatus.isGranted || storageStatus.isGranted);
  
  if (!allGranted) {
    // Request permissions
    final results = await Future.wait([
      Permission.camera.request(),
      Permission.photos.request(),
      Permission.storage.request(),
    ]);
    allGranted = results[0].isGranted && (results[1].isGranted || results[2].isGranted);
  }

  if (!allGranted && context.mounted) {
    // Determine if this is an app reset scenario
    final isAppReset = (wasCameraGranted || wasPhotosGranted || wasStorageGranted) && 
                      !cameraStatus.isGranted && !photosStatus.isGranted && !storageStatus.isGranted;
    
    String message = 'Camera and storage permissions are needed to update your avatar.';
    if (isAppReset) {
      message = 'Permissions were reset. Camera and storage permissions are needed to update your avatar.';
    }
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isAppReset ? 'Permissions Reset' : 'Permission Required'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.of(context).pop();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }
  return allGranted;
}

/// Check if permissions are available without requesting them
Future<bool> checkPermissionsAvailable() async {
  final cameraStatus = await Permission.camera.status;
  final photosStatus = await Permission.photos.status;
  final storageStatus = await Permission.storage.status;
  
  return cameraStatus.isGranted && (photosStatus.isGranted || storageStatus.isGranted);
} 