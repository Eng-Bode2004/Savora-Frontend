import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:savora_app/features/chef/auth/screens/verification_theme.dart';

class HealthCertificateScreen extends StatefulWidget {
  const HealthCertificateScreen({super.key});

  @override
  State<HealthCertificateScreen> createState() =>
      _HealthCertificateScreenState();
}

class _HealthCertificateScreenState extends State<HealthCertificateScreen> {
  bool _fileSelected = false;
  String? _fileName;

  Future<void> _browseFiles() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _fileSelected = true;
          _fileName = image.name;
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

  void _upload() {
    if (!_fileSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a certificate file first.')),
      );
      return;
    }
    Navigator.of(context).pop(true);
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
        onPressed: _upload,
        style: ElevatedButton.styleFrom(
          backgroundColor: kVfAccent,
          foregroundColor: const Color(0xFF2C1810),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
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
