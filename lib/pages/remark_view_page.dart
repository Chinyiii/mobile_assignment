import 'package:flutter/material.dart';
import '../models/remark.dart';

class RemarkViewPage extends StatelessWidget {
  final Remark remark;

  const RemarkViewPage({super.key, required this.remark});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ✅ Same header style
            _RemarkViewHeader(onBack: () => Navigator.pop(context)),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _RemarkTextSection(remark: remark),
                    _RemarkImagesSection(remark: remark),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemarkViewHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _RemarkViewHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: const Color(0xFFF2F2F5),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF121417),
                size: 24,
              ),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                'View Remark',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121417),
                ),
              ),
            ),
          ),
          const SizedBox(width: 48), // Spacer for centering
        ],
      ),
    );
  }
}

class _RemarkTextSection extends StatelessWidget {
  final Remark remark;

  const _RemarkTextSection({required this.remark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Description',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            remark.text.trim().isNotEmpty ? remark.text : 'No description provided.',
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
        ),
      ],
    );
  }
}

class _RemarkImagesSection extends StatelessWidget {
  final Remark remark;

  const _RemarkImagesSection({required this.remark});

  @override
  Widget build(BuildContext context) {
    if (remark.imageUrls.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Photos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: remark.imageUrls.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final url = remark.imageUrls[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 24),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
