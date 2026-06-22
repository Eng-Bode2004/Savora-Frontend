import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savora_app/core/network/savora_api.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';

class HealthCertificateScreen extends StatefulWidget {
  final String profileId;
  const HealthCertificateScreen({super.key, required this.profileId});

  @override
  State<HealthCertificateScreen> createState() =>
      _HealthCertificateScreenState();
}

class _HealthCertificateScreenState extends State<HealthCertificateScreen> {
  bool _fileSelected = false;
  String? _fileName;
  XFile? _pickedFile;
  bool _uploading = false;

  Future<void> _browseFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _fileSelected = true;
          _fileName = image.name;
          _pickedFile = image;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Certificate selected: ${image.name}'),
              backgroundColor: kVfGreen,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Picker error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open gallery: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _upload() async {
    if (!_fileSelected || _pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a certificate file first.')),
      );
      return;
    }
    setState(() => _uploading = true);
    try {
      final bytes = await _pickedFile!.readAsBytes();
      final uploadRes = await SavoraApi.uploadHealthCertificateImage(bytes, _fileName ?? 'certificate.jpg');
      final imageUrl = uploadRes['data']?['URL'] as String?;
      if (imageUrl == null) throw Exception('No URL returned from upload');

      await SavoraApi.assignHealthCertificateUrl(
        profileId: widget.profileId,
        certificateUrl: imageUrl,
      );

      await SavoraApi.verifyStep(
        profileId: widget.profileId,
        step: 'Health_Certificate_Status',
        status: 'verified',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Health certificate uploaded successfully'),
            backgroundColor: kVfGreen,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      debugPrint("Upload error: $e");
      if (mounted) {
        setState(() => _uploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $e'),
            backgroundColor: Colors.red,
          ),
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
            _buildTopBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  const SizedBox(height: 8),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                  const SizedBox(height: 24),
                  _buildUploadZone(),
                  const SizedBox(height: 24),
                  _buildUploadButton(),
                  const SizedBox(height: 12),
                  _buildSupportLink(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kVfWhite,
        border: Border(
          bottom: BorderSide(color: kVfBorder.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            color: kVfDarkText,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 4),
          Text(
            'Health Certificate',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: kVfDarkText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload Health Certificate',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: kVfDarkText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Please upload your valid food handler or hygiene certification.',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: kVfMutedText,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kVfAccent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kVfAccent.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: kVfAccent.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.info_outline, color: kVfAccent, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why is this required?',
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: kVfDarkText,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "To maintain Savora's high standards and ensure safety, we verify that all partner chefs hold current health and safety credentials.",
                  style: TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: kVfMutedText,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadZone() {
    return GestureDetector(
      onTap: _browseFiles,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
        decoration: BoxDecoration(
          color: kVfWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _fileSelected ? kVfGreen : kVfBorder,
            width: _fileSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _fileSelected
                  ? Icons.check_circle_outline_rounded
                  : Icons.cloud_upload_outlined,
              color: _fileSelected ? kVfGreen : kVfAccent,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              _fileSelected
                  ? (_fileName ?? 'Certificate selected')
                  : 'Tap to upload certificate',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: kVfDarkText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Supports PDF, JPG, or PNG (Max 5MB)',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: kVfMutedText,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: kVfAccent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Browse Files',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: kVfAccent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _uploading ? null : _upload,
        style: ElevatedButton.styleFrom(
          backgroundColor: kVfAccent,
          foregroundColor: const Color(0xFF2C1810),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _uploading
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF2C1810)),
              )
            : Text(
                'Upload Certificate',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }

  Widget _buildSupportLink() {
    return Center(
      child: GestureDetector(
        onTap: () {},
        child: Text(
          'Need help? Contact Support',
          style: TextStyle(
            fontFamily: 'DM Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: kVfAccent,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
