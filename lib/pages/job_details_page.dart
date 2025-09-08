import 'package:flutter/material.dart';
import '../models/job_details.dart';
import 'edit_job_page.dart';

class JobDetailsPage extends StatefulWidget {
  final JobDetails jobDetails;

  const JobDetailsPage({super.key, required this.jobDetails});

  @override
  State<JobDetailsPage> createState() => _JobDetailsPageState();
}

class _JobDetailsPageState extends State<JobDetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header (inlined)
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
                        'Job Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF121417),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditJobPage(jobDetails: widget.jobDetails),
                        ),
                      );
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        color: const Color(0xFFF0F2F5),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF121417),
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Customer Section (inlined)
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                            child: widget.jobDetails.customerImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(28),
                                    child: Image.asset(
                                      widget.jobDetails.customerImage!,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : const Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Color(0xFF6B7582),
                                  ),
                          ),
                          const SizedBox(width: 16),
                          // Customer Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.jobDetails.customerName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF121417),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.jobDetails.customerPhone,
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

                    // Vehicle Section (inlined)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
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
                                  widget.jobDetails.vehicle,
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
                            widget.jobDetails.status,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF121417),
                            ),
                          ),
                          Text(
                            widget.jobDetails.timeElapsed,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF121417),
                            ),
                          ),
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
                        widget.jobDetails.jobDescription,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF121417),
                        ),
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
                    ...widget.jobDetails.requestedServices.map(
                      (service) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
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
                              child: const Icon(
                                Icons.build,
                                color: Color(0xFF121417),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Service Name
                            Expanded(
                              child: Text(
                                service,
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
                    ...widget.jobDetails.assignedParts.map(
                      (part) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
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
                    ...widget.jobDetails.remarks.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
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
                              child: const Icon(
                                Icons.note,
                                color: Color(0xFF121417),
                                size: 24,
                              ),
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

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Action Buttons
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Change Status Button
                  Expanded(
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
                  const SizedBox(width: 12),
                  // Add Remarks Button
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
            ),
          ],
        ),
      ),
    );
  }
}
