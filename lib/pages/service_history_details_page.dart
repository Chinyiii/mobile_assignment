import 'package:flutter/material.dart';
import '../models/service_history_item.dart';

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
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Section
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
                          // Customer Avatar
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              color: const Color(0xFFF2F2F5),
                            ),
                            child: const Icon(Icons.person, size: 28, color: Color(0xFF6B7582)),
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
                    ),

                    // Vehicle Section
                    Padding(
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
                    ),

                    // Job Status Section
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
                            widget.serviceHistoryItem.status,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
                          ),
                          Text(
                            widget.serviceHistoryItem.timeElapsed,
                            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
                          ),
                        ],
                      ),
                    ),

                    // Service Day Section
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(
                        'Service Day',
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
                            _formatServiceDate(widget.serviceHistoryItem.serviceDate),
                            style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
                          ),
                          const SizedBox(width: 16), // Spacer for alignment
                        ],
                      ),
                    ),

                    // Job Description Section
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
                        widget.serviceHistoryItem.jobDescription,
                        style: const TextStyle(fontSize: 16, color: Color(0xFF121417)),
                      ),
                    ),

                    // Requested Services Section
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
                    ...widget.serviceHistoryItem.requestedServices.map(
                      (service) => Padding(
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
                      ),
                    ),

                    // Assigned Parts Section
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
                    ...widget.serviceHistoryItem.assignedParts.map(
                      (part) => Padding(
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
                    ...widget.serviceHistoryItem.remarks.asMap().entries.map(
                      (entry) => Padding(
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

                    // Photos Section
                    if (widget.serviceHistoryItem.photos.isNotEmpty) ...[
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
                      ...widget.serviceHistoryItem.photos.asMap().entries.map(
                        (entry) => Padding(
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
                                      'Photo ${entry.key + 1}',
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