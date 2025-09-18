import 'package:flutter/material.dart';
import 'package:mobile_assignment/models/job_details.dart';
import 'package:mobile_assignment/models/service_history_item.dart';
import 'package:mobile_assignment/pages/service_history_details_page.dart';
import 'package:mobile_assignment/services/supabase_service.dart';
import '../widgets/service_task_widget.dart';
import 'package:mobile_assignment/models/service_task.dart';

class JobDetailsPage extends StatefulWidget {
  final JobDetails jobDetails;

  const JobDetailsPage({super.key, required this.jobDetails});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  late JobDetails _jobDetails;
  late Future<List<ServiceHistoryItem>> _serviceHistoryFuture;

  @override
  void initState() {
    super.initState();
    _jobDetails = widget.jobDetails;
    _serviceHistoryFuture =
        SupabaseService().getServiceHistory(_jobDetails.plateNumber);
  }

  void _showChangeStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        Widget buildStatusRadioListTile(String status) {
          return RadioListTile<String>(
            title: Text(status),
            value: status,
            groupValue: _jobDetails.status,
            onChanged: (String? value) {
              if (value != null) {
                _updateStatus(value);
              }
              Navigator.of(context).pop();
            },
          );
        }

        return AlertDialog(
          title: const Text('Change Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildStatusRadioListTile('Assigned'),
              buildStatusRadioListTile('In Progress'),
              buildStatusRadioListTile('On Hold'),
              buildStatusRadioListTile('Completed'),
              buildStatusRadioListTile('Cancelled'),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateStatus(String newStatus) async {
    try {
      await SupabaseService().updateJobStatus(_jobDetails.id, newStatus);
      setState(() {
        _jobDetails = JobDetails(
          id: _jobDetails.id,
          customerName: _jobDetails.customerName,
          customerPhone: _jobDetails.customerPhone,
          vehicle: _jobDetails.vehicle,
          plateNumber: _jobDetails.plateNumber,
          jobDescription: _jobDetails.jobDescription,
          requestedServices: _jobDetails.requestedServices,
          assignedParts: _jobDetails.assignedParts,
          remarks: _jobDetails.remarks,
          status: newStatus,
          timeElapsed: _jobDetails.timeElapsed,
          createdAt: _jobDetails.createdAt,
        );
      });
    } catch (e) {
      // Handle error
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '$difference days ago';
    } else if (difference < 30) {
      final weeks = (difference / 7).floor();
      return '$weeks weeks ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildJobDetailsHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCustomerSection(),
                    _buildVehicleSection(),
                    _buildJobStatusSection(),
                    _buildJobDescriptionSection(),
                    _buildRequestedServicesSection(),
                    _buildAssignedPartsSection(),
                    _buildRemarksSection(),
                    _buildVehicleServiceHistorySection(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailsHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context, true),
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
                'Job Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF121417),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Customer',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  color: const Color(0xFFF2F2F5),
                ),
                child: const Icon(
                  Icons.person,
                  size: 28,
                  color: Color(0xFF6B7582),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _jobDetails.customerName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF121417),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _jobDetails.customerPhone,
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
        ),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(
              Icons.directions_car,
              color: Color(0xFF121417),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _jobDetails.plateNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121417),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _jobDetails.vehicle,
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

  Widget _buildJobStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Job Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _jobDetails.status,
                style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
              ),
              Text(
                _jobDetails.timeElapsed,
                style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Job Description',
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
            _jobDetails.jobDescription,
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
        ),
      ],
    );
  }

  Widget _buildRequestedServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Requested Services',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        ..._jobDetails.requestedServices.map(
              (service) => ServiceTaskWidget(task: service),
        ),
      ],
    );
  }

  Widget _buildAssignedPartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Assigned Parts',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        ..._jobDetails.assignedParts.map(
          (part) => Padding(
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
                  child: const Icon(
                    Icons.settings,
                    color: Color(0xFF121417),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    part,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF121417),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRemarksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ..._jobDetails.remarks.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: const Color(0xFFF2F2F5),
                  ),
                  child: const Icon(
                    Icons.note,
                    color: Color(0xFF121417),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Note ${entry.key + 1}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF121417),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
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
          ),
        ),
      ],
    );
  }

  Widget _buildVehicleServiceHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            'Vehicle Service History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF121417),
            ),
          ),
        ),
        FutureBuilder<List<ServiceHistoryItem>>(
          future: _serviceHistoryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading service history'));
            }
            final serviceHistory = snapshot.data;
            if (serviceHistory == null || serviceHistory.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  'No service history for this vehicle.',
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7582)),
                ),
              );
            }
            return Column(
              children: serviceHistory.map((item) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ServiceHistoryDetailsPage(serviceHistoryItem: item),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: const Color(0xFFF2F2F5),
                          ),
                          child: const Icon(
                            Icons.build,
                            color: Color(0xFF121417),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.serviceType,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF121417),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDate(item.serviceDate),
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
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showChangeStatusDialog,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFDEE8F2),
                ),
                child: const Center(
                  child: Text(
                    'Change Status',
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
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFFF2F2F5),
              ),
              child: const Center(
                child: Text(
                  'Add Remarks',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF121417),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
