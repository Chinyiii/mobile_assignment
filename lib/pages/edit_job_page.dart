import 'package:flutter/material.dart';
import '../models/job.dart';
import '../models/job_details.dart';
import 'job_details_page.dart';

class EditJobPage extends StatefulWidget {
  final JobDetails jobDetails;

  const EditJobPage({super.key, required this.jobDetails});

  @override
  State<EditJobPage> createState() => _EditJobPageState();
}

class _EditJobPageState extends State<EditJobPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for form fields
  late final TextEditingController _customerNameController;
  late final TextEditingController _phoneNumberController;
  late final TextEditingController _vehicleNameController;
  late final TextEditingController _plateNumberController;
  late final TextEditingController _jobDescriptionController;
  late final TextEditingController _remarksController;

  // Selected services and parts
  late List<String> selectedServices;
  late List<String> selectedParts;

  // Available services and parts
  final List<String> availableServices = [
    'Oil Change',
    'Brake Repair',
    'Tire Replacement',
    'Engine Diagnostic',
    'Engine Repair',
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
    'Ignition Coils',
    'Brake Fluid',
    'Transmission Fluid',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize controllers with existing data
    _customerNameController = TextEditingController(
      text: widget.jobDetails.customerName,
    );
    _phoneNumberController = TextEditingController(
      text: widget.jobDetails.customerPhone,
    );
    _vehicleNameController = TextEditingController(
      text: widget.jobDetails.vehicle,
    );
    _plateNumberController = TextEditingController(
      text: 'PHP 1234',
    ); // Default plate number
    _jobDescriptionController = TextEditingController(
      text: widget.jobDetails.jobDescription,
    );
    _remarksController = TextEditingController(
      text: widget.jobDetails.remarks.isNotEmpty
          ? widget.jobDetails.remarks.first
          : '',
    );

    // Initialize selected items with existing data
    selectedServices = List.from(widget.jobDetails.requestedServices);
    selectedParts = List.from(widget.jobDetails.assignedParts);
  }

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

  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // Update job details
      final updatedJobDetails = JobDetails(
        id: widget.jobDetails.id,
        customerName: _customerNameController.text,
        customerPhone: _phoneNumberController.text,
        vehicle: _vehicleNameController.text,
        jobDescription: _jobDescriptionController.text,
        requestedServices: selectedServices,
        assignedParts: selectedParts,
        remarks: _remarksController.text.isNotEmpty
            ? [_remarksController.text]
            : [],
        status: widget.jobDetails.status,
        timeElapsed: widget.jobDetails.timeElapsed,
      );

      // Navigate back to job details page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => JobDetailsPage(jobDetails: updatedJobDetails),
        ),
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
              _buildHeader(),

              // Form Content
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Customer Information Section
                      _buildSectionTitle('Customer Information'),
                      _buildTextField(
                        controller: _customerNameController,
                        label: 'Customer Name',
                        hint: 'Enter customer name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter customer name';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _phoneNumberController,
                        label: 'Phone Number',
                        hint: 'Enter phone number',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter phone number';
                          }
                          return null;
                        },
                      ),

                      // Vehicle Information Section
                      _buildSectionTitle('Vehicle Information'),
                      _buildTextField(
                        controller: _vehicleNameController,
                        label: 'Vehicle Name',
                        hint: 'Enter vehicle name',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter vehicle name';
                          }
                          return null;
                        },
                      ),
                      _buildTextField(
                        controller: _plateNumberController,
                        label: 'Plate Number',
                        hint: 'Enter plate number',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter plate number';
                          }
                          return null;
                        },
                      ),

                      // Job Details Section
                      _buildSectionTitle('Job Details'),
                      _buildTextField(
                        controller: _jobDescriptionController,
                        label: 'Job Description',
                        hint: 'Enter job description',
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter job description';
                          }
                          return null;
                        },
                      ),
                      _buildDropdownField(
                        label: 'Requested Services',
                        hint: 'Select services',
                        selectedItems: selectedServices,
                        onTap: _showServicesDialog,
                      ),
                      // Show selected services
                      ...selectedServices.map(
                        (service) => _buildSelectedItem(service),
                      ),
                      _buildDropdownField(
                        label: 'Assigned Parts',
                        hint: 'Select parts',
                        selectedItems: selectedParts,
                        onTap: _showPartsDialog,
                      ),
                      // Show selected parts
                      ...selectedParts.map((part) => _buildSelectedItem(part)),

                      // Remarks Section
                      _buildSectionTitle('Remarks'),
                      _buildTextField(
                        controller: _remarksController,
                        label: 'Add Note',
                        hint: 'Enter additional notes',
                        maxLines: 2,
                      ),
                      // Show existing remarks
                      ...widget.jobDetails.remarks.map(
                        (remark) => _buildRemarkItem(remark),
                      ),
                      _buildActionButton(
                        icon: Icons.photo_camera,
                        label: 'Add Photo',
                        onTap: () {
                          // TODO: Implement photo functionality
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Save Changes Button
              _buildSaveChangesButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
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
              'Edit Job',
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
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF121417),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
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
              controller: controller,
              keyboardType: keyboardType,
              maxLines: maxLines,
              validator: validator,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF61758A),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> selectedItems,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF121417),
              ),
            ),
          ),
          GestureDetector(
            onTap: onTap,
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
                        selectedItems.isEmpty ? hint : selectedItems.join(', '),
                        style: TextStyle(
                          fontSize: 16,
                          color: selectedItems.isEmpty
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
    );
  }

  Widget _buildSelectedItem(String item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(Icons.check, color: Color(0xFF121417), size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            item,
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkItem(String remark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(Icons.note, color: Color(0xFF121417), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Note 1',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121417),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  remark,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF6B7582),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFF2F2F5),
              ),
              child: Icon(icon, color: const Color(0xFF121417), size: 24),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF121417),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveChangesButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _saveChanges,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFDBE8F2),
            foregroundColor: const Color(0xFF121417),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Save Changes',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
