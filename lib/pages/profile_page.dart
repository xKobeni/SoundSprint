import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import '../utils/managers/stats_manager.dart';
import '../utils/managers/user_preferences.dart';
import '../utils/managers/settings_provider.dart';
import '../utils/managers/difficulty_progression_manager.dart';
import 'package:flutter/services.dart';
import '../widgets/permission_utils.dart';
import 'package:share_plus/share_plus.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _avatarPath;
  String? _initialAvatarPath;
  String _displayName = '';
  String _initialDisplayName = '';
  final TextEditingController _nameController = TextEditingController();
  bool _loading = true;
  double _ageValue = 18;
  double _initialAgeValue = 18;
  bool _showAgeSlider = false;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onFieldChanged);
    _loadProfile();
    _checkPermissionsOnLoad();
  }

  Future<void> _checkPermissionsOnLoad() async {
    // Check if permissions are available without requesting them
    final hasPermissions = await checkPermissionsAvailable();
    if (!hasPermissions && mounted) {
      // Show a subtle notification that permissions might be needed
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permissions may be needed to update your avatar'),
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.fixed,
        ),
      );
    }
  }

  void _onFieldChanged() {
    final hasChanges =
      _nameController.text.trim() != _initialDisplayName ||
      _ageValue != _initialAgeValue ||
      _avatarPath != _initialAvatarPath;
    if (_hasUnsavedChanges != hasChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  Future<void> _loadProfile() async {
    try {
      final user = await UserPreferences().getUser();
      if (mounted) {
        setState(() {
          _avatarPath = UserPreferences().avatarPath;
          _initialAvatarPath = _avatarPath;
          _displayName = user?.name ?? UserPreferences().displayName;
          _initialDisplayName = _displayName;
          _nameController.text = _displayName;
          _ageValue = (user?.age ?? 18).toDouble();
          _initialAgeValue = _ageValue;
          _loading = false;
          _hasUnsavedChanges = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        _showErrorDialog('Failed to load profile: $e');
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text('You have unsaved changes. Do you want to discard them and leave?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return discard ?? false;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickAvatar() async {
    final granted = await checkAndRequestAvatarPermissions(context);
    if (!granted) return;
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = path.basename(picked.path);
        final savedImage = await File(picked.path).copy('${appDir.path}/$fileName');
        setState(() {
          _avatarPath = savedImage.path;
        });
        _onFieldChanged();
        await UserPreferences().updateAvatarPath(savedImage.path);
      }
    } catch (e) {
      _showErrorDialog('Failed to pick avatar: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Settings', style: TextStyle(color: Color(0xFF7C5CFC), fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFFE9E0FF),
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          toolbarHeight: 60,
          iconTheme: const IconThemeData(color: Color(0xFF7C5CFC)),
          automaticallyImplyLeading: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFE9E0FF), Color(0xFF7C5CFC)],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    children: [
                      // Main Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Level display above avatar
                            FutureBuilder<Map<String, int>>(
                              future: DifficultyProgressionManager.getLevelProgression(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(height: 56); // Space for level and progress bar
                                }
                                final data = snapshot.data!;
                                final level = data['level']!;
                                final xp = data['experience']!;
                                final currentXp = data['currentLevelXp']!;
                                final nextXp = data['nextLevelXp']!;
                                final xpProgress = (xp - currentXp).clamp(0, nextXp - currentXp);
                                final percent = ((xp - currentXp) / (nextXp - currentXp)).clamp(0.0, 1.0);
                                return Column(
                                  children: [
                                    Text(
                                      'Level $level',
                                      style: const TextStyle(
                                        color: Color(0xFF7C5CFC),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value: percent,
                                      minHeight: 8,
                                      backgroundColor: const Color(0xFFE9E0FF),
                                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF7C5CFC)),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${xpProgress} / ${nextXp - currentXp} XP to next level',
                                      style: const TextStyle(
                                        color: Color(0xFF7C5CFC),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(height: 8),
                            // Avatar with edit
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundColor: const Color(0xFFFFB6B6),
                                  backgroundImage: _avatarPath != null ? FileImage(File(_avatarPath!)) : null,
                                  child: _avatarPath == null
                                      ? const Icon(Icons.person, size: 48, color: Colors.white)
                                      : null,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: _pickAvatar,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF7C5CFC),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.white, width: 2),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.add, color: Colors.white, size: 18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Name
                            Text(
                              _displayName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF7C5CFC)),
                            ),
                            const SizedBox(height: 8),
                            // Age label below name
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showAgeSlider = !_showAgeSlider;
                                });
                              },
                              child: _buildAgeCategory(_ageValue),
                            ),
                            if (_showAgeSlider) ...[
                              _buildAgeSlider(),
                              const SizedBox(height: 8),
                            ],
                            const SizedBox(height: 12),
                            // Editable name field
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.person, color: Color(0xFF7C5CFC)),
                                hintText: 'Your name',
                                filled: true,
                                fillColor: const Color(0xFFF5F3FF),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              ),
                              onChanged: (_) => _onFieldChanged(),
                            ),
                            const SizedBox(height: 16),
                            // Save Change Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _hasUnsavedChanges
                                    ? () async {
                                        setState(() {
                                          _displayName = _nameController.text.trim();
                                        });
                                        final user = await UserPreferences().getUser();
                                        if (user != null) {
                                          await UserPreferences().saveUser(
                                            user.copyWith(
                                              name: _displayName,
                                              age: _ageValue.round(),
                                            ),
                                          );
                                        }
                                        setState(() {
                                          _initialDisplayName = _displayName;
                                          _initialAgeValue = _ageValue;
                                          _initialAvatarPath = _avatarPath;
                                          _hasUnsavedChanges = false;
                                        });
                                        FocusScope.of(context).unfocus();
                                      }
                                    : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF7C5CFC),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Save Change', style: TextStyle(fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Share App Button
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              const appLink = 'https://drive.google.com/drive/folders/1_90IGyHbsk_StIHReOoMr6wIahztlBVe';
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Share SoundSprint'),
                                  content: const Text('Invite your friends to try SoundSprint!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Clipboard.setData(const ClipboardData(text: appLink));
                                        Navigator.of(context).pop();
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Link copied to clipboard!')),
                                        );
                                      },
                                      child: const Text('Copy Link'),
                                    ),
                                    ElevatedButton.icon(
                                      onPressed: () {
                                        Share.share(
                                          'Check out SoundSprint! Download it now: $appLink',
                                          subject: 'Try SoundSprint!',
                                        );
                                        Navigator.of(context).pop();
                                      },
                                      icon: const Icon(Icons.share),
                                      label: const Text('Share'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            icon: const Icon(Icons.share, color: Color(0xFF7C5CFC)),
                            label: const Text('Share App', style: TextStyle(color: Color(0xFF7C5CFC), fontWeight: FontWeight.bold)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF7C5CFC)),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Data Management Section
                      _buildDataManagementSection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDataManagementSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.storage, color: Color(0xFF7C5CFC), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Data Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C5CFC),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _clearData,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.delete_forever, color: Colors.red, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Clear All Data',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const Text(
                          'Reset profile, stats, and settings',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, color: Colors.red, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will reset your profile, stats, and settings. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear Data'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      try {
        await StatsManager.resetAllStats();
        await SettingsProvider().clearAllSettings();
        await UserPreferences().clearUserData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('All data cleared successfully')),
          );
          await Future.delayed(const Duration(seconds: 1));
          try {
            await SystemNavigator.pop();
          } catch (e) {
            exit(0);
          }
        }
      } catch (e) {
        _showErrorDialog('Failed to clear data: $e');
      }
    }
  }

  Widget _buildAgeSlider() {
    return Slider(
      value: _ageValue,
      min: 3,
      max: 100,
      divisions: 97,
      label: _ageValue.round().toString(),
      activeColor: const Color(0xFF7C5CFC),
      onChanged: (value) {
        setState(() {
          _ageValue = value;
        });
        _onFieldChanged();
      },
    );
  }

  Widget _buildAgeCategory(double age) {
    final List<Map<String, dynamic>> ageCategories = [
      {'min': 3, 'max': 7, 'label': 'Little Explorer', 'emoji': '🧒', 'color': Colors.blue},
      {'min': 8, 'max': 12, 'label': 'Young Adventurer', 'emoji': '👦', 'color': Colors.green},
      {'min': 13, 'max': 17, 'label': 'Teen Hero', 'emoji': '👨‍🎓', 'color': Colors.orange},
      {'min': 18, 'max': 25, 'label': 'Young Adult', 'emoji': '👨‍💼', 'color': Colors.purple},
      {'min': 26, 'max': 35, 'label': 'Professional', 'emoji': '👨‍💻', 'color': Colors.indigo},
      {'min': 36, 'max': 50, 'label': 'Experienced', 'emoji': '👨‍🏫', 'color': Colors.teal},
      {'min': 51, 'max': 65, 'label': 'Wise One', 'emoji': '👨‍🦳', 'color': Colors.brown},
      {'min': 66, 'max': 100, 'label': 'Legend', 'emoji': '👴', 'color': Colors.grey},
    ];
    final ageInt = age.round();
    final category = ageCategories.firstWhere(
      (cat) => ageInt >= cat['min'] && ageInt <= cat['max'],
      orElse: () => ageCategories[3],
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: (category['color'] as Color).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: category['color'], width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(category['emoji'], style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${category['label']}  |  Age $ageInt',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: category['color'],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
} 