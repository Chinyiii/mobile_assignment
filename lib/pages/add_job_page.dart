import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_details.dart';
import 'job_management_page.dart';

class AddJobPage extends StatefulWidget {
  const AddJobPage({super.key});

  @override
  State<AddJobPage> createState() => _AddJobPageState();
}

class _AddJobPageState extends State<AddJobPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  final _customerNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _vehicleNameController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _jobDescriptionController = TextEditingController();
  final _remarksController = TextEditingController();

  // Selected services and parts
  List<String> selectedServices = [];
  List<String> selectedParts = [];

  // Available services and parts
  final List<String> availableServices = [
    'Oil Change',
    'Brake Repair',
    'Tire Replacement',
    'Engine Diagnostic',
    'Wheel Alignment',
    'Battery Replacement',
    'Air Filter Change',
    'Spark Plug Replacement',
  ];

  final List<String> availableParts = [
    'Engine Oil',
    'Brake Pads',
    'Tires',
    'Battery',
    'Air Filter',
    'Spark Plugs',
    'Brake Fluid',
    'Transmission Fluid',
  ];

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneNumberController.dispose();
    _vehicleNameController.dispose();
    _plateNumberController.dispose();
    _jobDescriptionController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  void _showServicesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Services'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableServices.length,
                  itemBuilder: (context, index) {
                    final service = availableServices[index];
                    return CheckboxListTile(
                      title: Text(service),
                      value: selectedServices.contains(service),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedServices.add(service);
                          } else {
                            selectedServices.remove(service);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                this.setState(() {});
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showPartsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Parts'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableParts.length,
                  itemBuilder: (context, index) {
                    final part = availableParts[index];
                    return CheckboxListTile(
                      title: Text(part),
                      value: selectedParts.contains(part),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            selectedParts.add(part);
                          } else {
                            selectedParts.remove(part);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                this.setState(() {});
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _addJob() {
    if (_formKey.currentState!.validate()) {
      // Create new job details
      final jobDetails = JobDetails(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: _customerNameController.text,
        customerPhone: _phoneNumberController.text,
        vehicle: _vehicleNameController.text,
        jobDescription: _jobDescriptionController.text,
        requestedServices: selectedServices,
        assignedParts: selectedParts,
        remarks: _remarksController.text.isNotEmpty
            ? [_remarksController.text]
            : [],
        status: 'Assigned',
        timeElapsed: '0m',
      );

      // Navigate back to job management page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const JobManagementPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header
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
                          color: const Color(0xFFF0F2F5),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF121417),
                          size: 24,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Add Job',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF121417),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Spacer for centering
                  ],
                ),
              ),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Customer Information Section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121417),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Customer Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0F2F5),
                              ),
                              child: TextFormField(
                                controller: _customerNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter customer name';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter customer name',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF61758A),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0F2F5),
                              ),
                              child: TextFormField(
                                controller: _phoneNumberController,
                                keyboardType: TextInputType.phone,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter phone number';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter phone number',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF61758A),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Vehicle Information Section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Vehicle Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121417),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Vehicle Name',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0F2F5),
                              ),
                              child: TextFormField(
                                controller: _vehicleNameController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter vehicle name';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter vehicle name',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF61758A),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Plate Number',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0F2F5),
                              ),
                              child: TextFormField(
                                controller: _plateNumberController,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter plate number';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter plate number',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF61758A),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Job Details Section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Job Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121417),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Job Description',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0F2F5),
                              ),
                              child: TextFormField(
                                controller: _jobDescriptionController,
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter job description';
                                  }
                                  return null;
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter job description',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF61758A),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Requested Services',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showServicesDialog,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFF0F2F5),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          selectedServices.isEmpty ? 'Select services' : selectedServices.join(', '),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: selectedServices.isEmpty
                                                ? const Color(0xFF61758A)
                                                : const Color(0xFF121417),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xFF61758A),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Assigned Parts',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _showPartsDialog,
                              child: Container(
                                height: 56,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: const Color(0xFFF0F2F5),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16),
                                        child: Text(
                                          selectedParts.isEmpty ? 'Select parts' : selectedParts.join(', '),
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: selectedParts.isEmpty
                                                ? const Color(0xFF61758A)
                                                : const Color(0xFF121417),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.only(right: 16),
                                      child: Icon(
                                        Icons.arrow_drop_down,
                                        color: Color(0xFF61758A),
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Remarks Section
                      const Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Text(
                          'Remarks',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121417),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(bottom: 8),
                              child: Text(
                                'Add Note',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color(0xFFF0F2F5),
                              ),
                              child: TextFormField(
                                controller: _remarksController,
                                maxLines: 2,
                                decoration: const InputDecoration(
                                  hintText: 'Enter additional notes',
                                  hintStyle: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF61758A),
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.all(16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                // TODO: Implement photo functionality
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFFF2F2F5),
                                ),
                                child: const Icon(Icons.photo_camera, color: Color(0xFF121417), size: 24),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Add Photo',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF121417),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Add Job Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _addJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDBE8F2),
                      foregroundColor: const Color(0xFF121417),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Add Job',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}