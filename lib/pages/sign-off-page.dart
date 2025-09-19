import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../services/supabase_service.dart';

class DigitalSignOffPage extends StatefulWidget {
  final int jobId;

  const DigitalSignOffPage({super.key, required this.jobId});

  @override
  State<DigitalSignOffPage> createState() => _DigitalSignOffPageState();
}

class _DigitalSignOffPageState extends State<DigitalSignOffPage> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSaving = false;
  final SupabaseService _supabaseService = SupabaseService();

  Future<void> _saveSignature() async {
    if (_controller.isNotEmpty) {
      setState(() => _isSaving = true); // show loading state

      try {
        final signatureBytes = await _controller.toPngBytes();

        if (signatureBytes != null) {
          print('Starting signature upload...');

          // Step 1: Save the signature (upload + database update)
          await _supabaseService.saveJobSignOff(widget.jobId, signatureBytes);
          print('Signature saved to database');

          // Step 2: Verify the signature was saved by fetching fresh job details
          print('Verifying signature was saved...');
          bool signatureSaved = false;
          int attempts = 0;

          while (!signatureSaved && attempts < 5) {
            attempts++;
            print('Verification attempt $attempts...');

            await Future.delayed(Duration(seconds: attempts)); // Progressive delay

            try {
              final freshJobDetails = await _supabaseService.getSingleJobDetails(widget.jobId);
              if (freshJobDetails.signatureUrl != null && freshJobDetails.signatureUrl!.isNotEmpty) {
                print('Signature verified! URL: ${freshJobDetails.signatureUrl}');
                signatureSaved = true;
              } else {
                print('Signature not yet available, retrying...');
              }
            } catch (e) {
              print('Error verifying signature: $e');
            }
          }

          if (mounted) {
            if (signatureSaved) {
              // Step 3: Only navigate back if signature is confirmed saved
              print('Navigation back to previous page...');
              Navigator.pop(context, true); // return success
            } else {
              // If verification failed, show error but don't navigate
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Signature saved but couldn't verify. Please check manually."),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Failed to generate signature image")),
            );
          }
        }
      } catch (e) {
        print('Error saving signature: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to save signature: $e")),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isSaving = false); // reset state
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a signature first")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Custom Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
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
                        'Customer Sign-Off',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF121417),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Signature Area
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFF2F2F5), width: 2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Signature(
                    controller: _controller,
                    backgroundColor: Colors.white
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _controller.clear(),
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFF2F2F5),
                        ),
                        child: const Center(
                          child: Text(
                            'Clear',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF121417),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _isSaving ? null : _saveSignature,
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: _isSaving
                              ? const Color(0xFFF2F2F5)
                              : const Color(0xFFDEE8F2),
                        ),
                        child: Center(
                          child: _isSaving
                              ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF121417)
                            ),
                          )
                              : const Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF121417),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}