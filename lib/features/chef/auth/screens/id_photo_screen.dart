import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/state/providers/auth_provider.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';

class IdPhotoScreen extends StatefulWidget {
  final String? profileId;
  const IdPhotoScreen({super.key, this.profileId});

  @override
  State<IdPhotoScreen> createState() => _IdPhotoScreenState();
}

class _IdPhotoScreenState extends State<IdPhotoScreen> {
  String? _frontFileName;
  String? _backFileName;
  XFile? _frontFile;
  XFile? _backFile;
  bool _isUploading = false;
  String? _resolvedProfileId;

  @override
  void initState() {
    super.initState();
    _resolveProfileId();
  }

  Future<void> _resolveProfileId() async {
    if (widget.profileId != null) {
      _resolvedProfileId = widget.profileId;
      return;
    }
    var pid = authState.profileId;
    if (pid == null) {
      final userId = authState.userId;
      if (userId != null) {
        try {
          final userData = await SavoraApi.getUserById(userId);
          final user = userData['data'] as Map<String, dynamic>?;
          pid = user?['profile'] as String?;
          if (pid != null && pid.isNotEmpty) {
            final profile = await SavoraApi.getChiefProfile(pid);
            final profileObj = profile['profile'] as Map<String, dynamic>?;
            if (profileObj != null) {
              authState.setProfileData(profileObj);
              authState.setProfileId(pid);
            }
          }
        } catch (_) {}
      }
    }
    if (mounted) setState(() => _resolvedProfileId = pid);
  }

  Future<void> _pickImage(bool isFront) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          if (isFront) {
            _frontFile = image;
            _frontFileName = image.name;
          } else {
            _backFile = image;
            _backFileName = image.name;
          }
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${isFront ? "Front" : "Back"} ID selected: ${image.name}'),
              backgroundColor: kVfGreen,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open gallery: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (_frontFile == null || _backFile == null || _resolvedProfileId == null) return;
    setState(() => _isUploading = true);

    try {
      final frontBytes = await _frontFile!.readAsBytes();
      final backBytes = await _backFile!.readAsBytes();

      final frontRes = await SavoraApi.uploadFrontIdImage(frontBytes, _frontFileName ?? 'front_id.jpg');
      final frontUrl = frontRes['data']?['URL'] as String?;
      if (frontUrl == null) throw Exception('Front image upload failed');

      final backRes = await SavoraApi.uploadBackIdImage(backBytes, _backFileName ?? 'back_id.jpg');
      final backUrl = backRes['data']?['URL'] as String?;
      if (backUrl == null) throw Exception('Back image upload failed');

      await SavoraApi.assignNationalIdUrls(
        profileId: _resolvedProfileId!,
        frontImageURL: frontUrl,
        backImageURL: backUrl,
      );

      await SavoraApi.verifyStep(
        profileId: _resolvedProfileId!,
        step: 'National_ID_Status',
        status: 'verified',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('National ID submitted successfully'), backgroundColor: kVfGreen),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString().replaceFirst("Exception: ", "")}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kVfBackground,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _buildTopNavBar(context),
                    const SizedBox(height: 24),
                    _buildMainContent(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNavBar(BuildContext context) {
    return Container(
      height: 64,
      decoration: BoxDecoration(
        color: kVfWhite,
        border: Border(bottom: BorderSide(color: kVfBorder.withValues(alpha: 0.6))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.arrow_back, color: kVfDarkText),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Text(
            'Identity Verification',
            style: TextStyle(fontFamily: 'DM Sans', fontSize: 24, fontWeight: FontWeight.w600, color: kVfDarkText),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'National ID Card Photo',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 32, fontWeight: FontWeight.w700, color: kVfDarkText, height: 1.25),
        ),
        const SizedBox(height: 4),
        Text(
          'Please upload clear photos of both the front and back of your national identity card.',
          style: TextStyle(fontFamily: 'DM Sans', fontSize: 16, fontWeight: FontWeight.w400, color: kVfMutedText, height: 1.5),
        ),
        const SizedBox(height: 24),
        _buildUploadCard(
          title: 'Front of ID Card',
          isSelected: _frontFile != null,
          fileName: _frontFileName,
          onTap: () => _pickImage(true),
        ),
        const SizedBox(height: 16),
        _buildUploadCard(
          title: 'Back of ID Card',
          isSelected: _backFile != null,
          fileName: _backFileName,
          onTap: () => _pickImage(false),
        ),
        const SizedBox(height: 32),
        _buildSubmitButton(context),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isSelected,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? kVfGreen.withValues(alpha: 0.5) : kVfBorder, width: 2),
        color: isSelected ? kVfGreen.withValues(alpha: 0.02) : kVfBorder.withOpacity(0.1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
            child: Column(
              children: [
                Container(
                  width: 56, height: 56,
                  decoration: BoxDecoration(
                    color: kVfWhite,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: kVfDarkText.withValues(alpha: 0.05), blurRadius: 8, spreadRadius: 2)],
                  ),
                  child: Icon(
                    isSelected ? Icons.check_circle_outline : Icons.add_a_photo_outlined,
                    color: isSelected ? kVfGreen : kVfAccent,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isSelected ? fileName ?? '' : 'Tap to upload $title',
                  style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.bold, color: isSelected ? kVfGreen : kVfDarkText),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  isSelected ? 'Ready to upload' : 'Ensure all details on the card are clearly readable',
                  style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w400, color: kVfMutedText),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isEnabled = _frontFile != null && _backFile != null && _resolvedProfileId != null && !_isUploading;

    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: isEnabled ? kVfAccent : Colors.grey.shade300,
        boxShadow: isEnabled ? [BoxShadow(color: kVfAccent.withOpacity(0.2), blurRadius: 8, spreadRadius: 2)] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? _submit : null,
          borderRadius: BorderRadius.circular(8),
          child: Center(
            child: _isUploading
                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C1810)))
                : Text(
                    'Submit ID Card',
                    style: TextStyle(fontFamily: 'DM Sans', fontSize: 14, fontWeight: FontWeight.w600, color: isEnabled ? Colors.white : Colors.grey.shade600),
                  ),
          ),
        ),
      ),
    );
  }
}
