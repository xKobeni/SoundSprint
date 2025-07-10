import 'package:flutter/material.dart';
import '../utils/managers/audio_manager.dart';
import '../utils/managers/accessibility_manager.dart';

class SoundPreviewWidget extends StatefulWidget {
  final String fileName;
  final String type; // 'sound' or 'music'
  final int? clipStart;
  final int? clipEnd;
  final String label;

  const SoundPreviewWidget({
    Key? key,
    required this.fileName,
    required this.type,
    this.clipStart,
    this.clipEnd,
    required this.label,
  }) : super(key: key);

  @override
  State<SoundPreviewWidget> createState() => _SoundPreviewWidgetState();
}

class _SoundPreviewWidgetState extends State<SoundPreviewWidget>
    with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 0.5;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _playPreview() async {
    if (_isPlaying) return;

    setState(() {
      _isPlaying = true;
    });

    // Trigger haptic feedback
    await AccessibilityManager().triggerHapticFeedback(HapticFeedbackType.selection);

    // Start animation
    _animationController.forward();

    try {
      final success = await AudioManager().playAudio(
        fileName: widget.fileName,
        type: widget.type,
        clipStart: widget.clipStart,
        clipEnd: widget.clipEnd,
        category: null, // No category info in this widget
      );

      if (success) {
        // Wait for audio to finish or show playing state
        await Future.delayed(Duration(seconds: widget.clipEnd != null && widget.clipStart != null 
            ? widget.clipEnd! - widget.clipStart! 
            : 3));
      }
    } catch (e) {
      debugPrint('Error playing preview: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isPlaying = false;
        });
        _animationController.reverse();
      }
    }
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
    AudioManager().setVolume(_isMuted ? 0.0 : _volume);
  }

  void _onVolumeChanged(double value) {
    setState(() {
      _volume = value;
    });
    AudioManager().setVolume(_isMuted ? 0.0 : _volume);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with label and play button
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Audio visual indicator
                AccessibilityManager().getAudioVisualIndicator(
                  isPlaying: _isPlaying,
                  isMuted: _isMuted,
                  volume: _volume,
                  size: 20,
                ),
                const SizedBox(width: 8),
                // Play button
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: IconButton(
                    onPressed: _isPlaying ? null : _playPreview,
                    icon: Icon(
                      _isPlaying ? Icons.stop : Icons.play_arrow,
                      color: _isPlaying ? Colors.grey : Colors.blue,
                    ),
                    tooltip: _isPlaying ? 'Playing...' : 'Play preview',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Volume controls
            Row(
              children: [
                IconButton(
                  onPressed: _toggleMute,
                  icon: Icon(
                    _isMuted ? Icons.volume_off : Icons.volume_up,
                    color: _isMuted ? Colors.red : Colors.grey,
                  ),
                  tooltip: _isMuted ? 'Unmute' : 'Mute',
                ),
                Expanded(
                  child: Slider(
                    value: _volume,
                    onChanged: _onVolumeChanged,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(_volume * 100).round()}%',
                  ),
                ),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${(_volume * 100).round()}%',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // Audio info
            if (widget.clipStart != null && widget.clipEnd != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Clip: ${widget.clipStart}s - ${widget.clipEnd}s',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SoundPreviewList extends StatelessWidget {
  final List<Map<String, dynamic>> previewItems;

  const SoundPreviewList({
    Key? key,
    required this.previewItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: previewItems.length,
      itemBuilder: (context, index) {
        final item = previewItems[index];
        return SoundPreviewWidget(
          fileName: item['fileName'],
          type: item['type'],
          clipStart: item['clipStart'],
          clipEnd: item['clipEnd'],
          label: item['label'],
        );
      },
    );
  }
} 