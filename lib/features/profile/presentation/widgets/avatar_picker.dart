import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../providers/profile_provider.dart';

class AvatarPicker extends ConsumerStatefulWidget {
  final String? currentAvatarUrl;
  final String userId;
  final double size;

  const AvatarPicker({
    Key? key,
    this.currentAvatarUrl,
    required this.userId,
    this.size = 100,
  }) : super(key: key);

  @override
  ConsumerState<AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends ConsumerState<AvatarPicker> {
  File? _selectedImage;
  bool _isUploading = false;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
      
      await _uploadImage(pickedImage);
    }
  }

  Future<void> _uploadImage(XFile image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      final bytes = await image.readAsBytes();
      final fileName = image.name;
      
      final params = (
        userId: widget.userId,
        fileBytes: bytes,
        fileName: fileName,
      );
      
      await ref.read(uploadAvatarProvider(params).future);
      
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile picture updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading image: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
          _selectedImage = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickImage,
          child: CircleAvatar(
            radius: widget.size / 2,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            backgroundImage: _getAvatarImage(),
            child: _isUploading
                ? const CircularProgressIndicator()
                : (widget.currentAvatarUrl == null && _selectedImage == null)
                    ? Icon(
                        Icons.person,
                        size: widget.size * 0.6,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
          ),
        ),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.camera_alt,
            size: widget.size * 0.2,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  ImageProvider? _getAvatarImage() {
    if (_selectedImage != null) {
      return FileImage(_selectedImage!);
    } else if (widget.currentAvatarUrl != null) {
      return NetworkImage(widget.currentAvatarUrl!);
    }
    return null;
  }
}
