import 'package:flutter/material.dart';
import '../models/job_details.dart';

class ServiceHistoryDetailsPage extends StatefulWidget {
  final ServiceHistoryItem serviceHistoryItem;

  const ServiceHistoryDetailsPage({
    super.key,
    required this.serviceHistoryItem,
  });

  @override
  State<ServiceHistoryDetailsPage> createState() =>
      _ServiceHistoryDetailsPageState();
}

class _ServiceHistoryDetailsPageState extends State<ServiceHistoryDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Section
                    _buildSectionTitle('Customer'),
                    _buildCustomerCard(),

                    // Vehicle Section
                    _buildVehicleCard(),

                    // Job Status Section
                    _buildSectionTitle('Job Status'),
                    _buildJobStatusCard(),

                    // Service Day Section
                    _buildSectionTitle('Service Day'),
                    _buildServiceDayCard(),

                    // Job Description Section
                    _buildSectionTitle('Job Description'),
                    _buildJobDescription(),

                    // Requested Services Section
                    _buildSectionTitle('Requested Services'),
                    ...widget.serviceHistoryItem.requestedServices.map(
                      (service) => _buildServiceCard(service),
                    ),

                    // Assigned Parts Section
                    _buildSectionTitle('Assigned Parts'),
                    ...widget.serviceHistoryItem.assignedParts.map(
                      (part) => _buildPartCard(part),
                    ),

                    // Remarks Section
                    _buildSectionTitle('Remarks'),
                    ...widget.serviceHistoryItem.remarks.asMap().entries.map(
                      (entry) => _buildRemarkCard(entry.key + 1, entry.value),
                    ),

                    // Photos Section
                    if (widget.serviceHistoryItem.photos.isNotEmpty) ...[
                      _buildSectionTitle('Photos'),
                      ...widget.serviceHistoryItem.photos.asMap().entries.map(
                        (entry) => _buildPhotoCard(entry.key + 1, entry.value),
                      ),
                    ],

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
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
              'Service Details',
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
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF121417),
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Customer Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: const Color(0xFFF2F2F5),
            ),
            child: widget.serviceHistoryItem.customerImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      widget.serviceHistoryItem.customerImage!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(Icons.person, size: 28, color: Color(0xFF6B7582)),
          ),

          const SizedBox(width: 16),

          // Customer Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.serviceHistoryItem.customerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121417),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.serviceHistoryItem.customerPhone,
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

  Widget _buildVehicleCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Vehicle Icon
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

          // Vehicle Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vehicle',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121417),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.serviceHistoryItem.vehicle,
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

  Widget _buildJobStatusCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.serviceHistoryItem.status,
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
          Text(
            widget.serviceHistoryItem.timeElapsed,
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDayCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _formatServiceDate(widget.serviceHistoryItem.serviceDate),
            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
          ),
          const SizedBox(width: 16), // Spacer for alignment
        ],
      ),
    );
  }

  Widget _buildJobDescription() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Text(
        widget.serviceHistoryItem.jobDescription,
        style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
      ),
    );
  }

  Widget _buildServiceCard(String service) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Service Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(Icons.build, color: Color(0xFF121417), size: 20),
          ),

          const SizedBox(width: 16),

          // Service Name
          Expanded(
            child: Text(
              service,
              style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartCard(String part) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          // Part Icon
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

          // Part Name
          Expanded(
            child: Text(
              part,
              style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarkCard(int index, String remark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Remark Icon
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

          // Remark Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Note $index',
                  style: const TextStyle(
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

  Widget _buildPhotoCard(int index, String photoDescription) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Photo Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFFF2F2F5),
            ),
            child: const Icon(Icons.photo, color: Color(0xFF121417), size: 24),
          ),

          const SizedBox(width: 16),

          // Photo Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo $index',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF121417),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  photoDescription,
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

  String _formatServiceDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class ServiceHistoryItem {
  final String id;
  final String plateNumber;
  final String customerName;
  final String customerPhone;
  final String? customerImage;
  final String vehicle;
  final DateTime serviceDate;
  final String serviceType;
  final String status;
  final String timeElapsed;
  final String jobDescription;
  final List<String> requestedServices;
  final List<String> assignedParts;
  final List<String> remarks;
  final List<String> photos;

  ServiceHistoryItem({
    required this.id,
    required this.plateNumber,
    required this.customerName,
    required this.customerPhone,
    this.customerImage,
    required this.vehicle,
    required this.serviceDate,
    required this.serviceType,
    required this.status,
    required this.timeElapsed,
    required this.jobDescription,
    required this.requestedServices,
    required this.assignedParts,
    required this.remarks,
    required this.photos,
  });
}
