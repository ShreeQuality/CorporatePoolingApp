import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  bool _aadhaarUploaded = false;
  bool _dlUploaded = false;
  bool _photoUploaded = false;

  void _uploadDocument(String docType) {
    setState(() {
      if (docType == 'aadhaar') _aadhaarUploaded = true;
      if (docType == 'driving_licence') _dlUploaded = true;
      if (docType == 'photo') _photoUploaded = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$docType document selected & submitted for admin review.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Identity & Driver Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Document Upload Queue 📄',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              'Public users require Aadhaar verification. Drivers require Driving Licence approval.',
              style: TextStyle(color: AppTheme.textMuted),
            ),
            const SizedBox(height: 24),
            _buildDocCard(
              title: 'Aadhaar Card (Front/Back)',
              description: 'Identity proof for all public riders & drivers',
              isDone: _aadhaarUploaded,
              onTap: () => _uploadDocument('aadhaar'),
            ),
            const SizedBox(height: 16),
            _buildDocCard(
              title: 'Driving Licence',
              description: 'Required if offering rides as a driver',
              isDone: _dlUploaded,
              onTap: () => _uploadDocument('driving_licence'),
            ),
            const SizedBox(height: 16),
            _buildDocCard(
              title: 'Profile Photo',
              description: 'Clear face photo for passenger safety',
              isDone: _photoUploaded,
              onTap: () => _uploadDocument('photo'),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Complete Verification Setup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocCard({
    required String title,
    required String description,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDone ? AppTheme.accentGreen : Colors.transparent),
      ),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle : Icons.upload_file,
            color: isDone ? AppTheme.accentGreen : AppTheme.accentSaffron,
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white)),
                const SizedBox(height: 4),
                Text(description, style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDone ? Colors.grey : AppTheme.accentGreen,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            onPressed: onTap,
            child: Text(isDone ? 'Uploaded' : 'Upload'),
          ),
        ],
      ),
    );
  }
}
