import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_assignment/services/supabase_service.dart';
import '../models/remark.dart';

class RemarkFormPage extends StatefulWidget {
  final int jobId;
  final int userId;
  final Remark? remark;

  const RemarkFormPage({
    super.key,
    required this.jobId,
    required this.userId,
    this.remark,
  });

  @override
  State<RemarkFormPage> createState() => _RemarkFormPageState();
}

class _RemarkFormPageState extends State<RemarkFormPage> {
  final TextEditingController _descriptionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  final List<String> _existingImages = [];
  final List<String> _deletedImages = []; // keep track of removed images
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.remark != null) {
      _descriptionController.text = widget.remark!.text;
      _existingImages.addAll(widget.remark!.imageUrls);
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((xfile) => File(xfile.path)));
      });
    }
  }

  Future<void> _takePhoto() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _saveRemark() async {
    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please add a description")));
      return;
    }

    setState(() => _isSaving = true);

    try {
      if (widget.remark == null) {
        // ADD new remark
        final newRemark = await SupabaseService().addRemarkWithPhotos(
          jobId: widget.jobId,
          userId: widget.userId,
          description: _descriptionController.text.trim(),
          imageFiles: _selectedImages,
        );
        Navigator.pop(context, newRemark);
      } else {
        // EDIT existing remark

        //Delete removed images from storage and DB
        for (final url in _deletedImages) {
          await SupabaseService().deleteRemarkPhoto(widget.remark!.id, url);
          _existingImages.remove(url);
        }
        _deletedImages.clear();

        //Upload new images and get their public URLs
        final List<String> newUploadedUrls = [];
        for (final file in _selectedImages) {
          final publicUrl = await SupabaseService().uploadRemarkImage(
            widget.remark!.id,
            file,
          );
          newUploadedUrls.add(publicUrl);
        }
        _selectedImages.clear(); // clear selected files after upload

        //Combine existing images + newly uploaded URLs
        final allImages = [..._existingImages, ...newUploadedUrls];

        //Update remark text only (images already inserted)
        await SupabaseService().updateRemark(
          remarkId: widget.remark!.id,
          newText: _descriptionController.text.trim(),
        );

        //Return updated remark
        final updatedRemark = Remark(
          id: widget.remark!.id,
          text: _descriptionController.text.trim(),
          imageUrls: allImages,
        );

        Navigator.pop(context, updatedRemark);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error saving remark: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _RemarkFormHeader(
              title: widget.remark == null ? "Add Remark" : "Edit Remark",
              onBack: () => Navigator.pop(context),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121417),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F2F5),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          hintText: "Enter description...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Photos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF121417),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount:
                          _existingImages.length + _selectedImages.length + 2,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemBuilder: (context, index) {
                        if (index < _existingImages.length) {
                          final url = _existingImages[index];
                          return _ImageTile.network(
                            url: url,
                            onRemove: () {
                              setState(() {
                                _deletedImages.add(
                                  _existingImages[index],
                                ); // mark for deletion
                                _existingImages.removeAt(
                                  index,
                                ); // remove from local preview
                              });
                            },
                          );
                        } else if (index <
                            _existingImages.length + _selectedImages.length) {
                          final fileIndex = index - _existingImages.length;
                          final file = _selectedImages[fileIndex];
                          return _ImageTile.file(
                            file: file,
                            onRemove: () => setState(
                              () => _selectedImages.removeAt(fileIndex),
                            ),
                          );
                        } else if (index ==
                            _existingImages.length + _selectedImages.length) {
                          return _AddTile(
                            icon: Icons.add_photo_alternate,
                            label: 'Gallery',
                            onTap: _pickImages,
                          );
                        } else {
                          return _AddTile(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            onTap: _takePhoto,
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveRemark,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: const Color(0xFFDEE8F2),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          widget.remark == null
                              ? "Save Remark"
                              : "Update Remark",
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RemarkFormHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _RemarkFormHeader({required this.title, required this.onBack});

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
                color: const Color(0xFFF0F2F5),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Color(0xFF121417),
                size: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF121417),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final String? url;
  final File? file;
  final VoidCallback onRemove;

  const _ImageTile.network({required this.url, required this.onRemove})
    : file = null;

  const _ImageTile.file({required this.file, required this.onRemove})
    : url = null;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          Positioned.fill(
            child: url != null
                ? Image.network(url!, fit: BoxFit.cover)
                : Image.file(file!, fit: BoxFit.cover),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black54,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AddTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: const Color(0xFF61758A)),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Color(0xFF61758A))),
          ],
        ),
      ),
    );
  }
}
