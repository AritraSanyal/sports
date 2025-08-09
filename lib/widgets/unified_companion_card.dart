import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_app/screen/chat_screen.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../model/unified_model.dart';
import '../providers/user_provider.dart';
import '../widgets/circular_avatar.dart';

class UnifiedCompanionCard extends StatefulWidget {
  final UnifiedCompanionModel companion;
  final VoidCallback? onDeleted;

  const UnifiedCompanionCard({
    super.key,
    required this.companion,
    this.onDeleted,
  });

  @override
  State<UnifiedCompanionCard> createState() => _UnifiedCompanionCardState();
}

class _UnifiedCompanionCardState extends State<UnifiedCompanionCard> {
  bool _isExpanded = false;
  bool _isLoading = false;
  String? _creatorName;
  String? _creatorImage;
  bool _hasJoined = false;
  bool _hasRequested = false;

  @override
  void initState() {
    super.initState();
    _fetchCreatorInfo();
    _checkMembershipStatus();
  }

  Future<void> _fetchCreatorInfo() async {
    try {
      final url = Uri.parse(
        'https://sportsapp1-31d70-default-rtdb.firebaseio.com/users/${widget.companion.createdBy}.json',
      );
      final response = await http.get(url);

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        setState(() {
          _creatorName = data['name'] ?? 'Unknown';
          _creatorImage = data['imageUrl'];
        });
      }
    } catch (e) {
      print('Error fetching creator info: $e');
    }
  }

  Future<void> _checkMembershipStatus() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      final groupUrl = Uri.parse(
        'https://sportsapp1-31d70-default-rtdb.firebaseio.com/${widget.companion.groupsPath}/${widget.companion.id}.json',
      );
      final response = await http.get(groupUrl);

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        final members = List<String>.from(data['members'] ?? []);
        final requests = data['requests'] as Map<String, dynamic>? ?? {};

        setState(() {
          _hasJoined = members.contains(user.id);
          _hasRequested = requests.containsKey(user.id);
        });
      }
    } catch (e) {
      print('Error checking membership: $e');
    }
  }

  Future<void> _joinGroup() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      final groupUrl = Uri.parse(
        'https://sportsapp1-31d70-default-rtdb.firebaseio.com/${widget.companion.groupsPath}/${widget.companion.id}.json',
      );
      final response = await http.get(groupUrl);

      if (response.statusCode == 200 && response.body != 'null') {
        final data = json.decode(response.body);
        final requests = data['requests'] as Map<String, dynamic>? ?? {};

        requests[user.id] = {
          'userId': user.id,
          'name': user.name,
          'timestamp': DateTime.now().toIso8601String(),
        };

        final updateResponse = await http.patch(
          groupUrl,
          body: json.encode({'requests': requests}),
        );

        if (updateResponse.statusCode == 200) {
          setState(() => _hasRequested = true);
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Join request sent!')));
        }
      }
    } catch (e) {
      print('Error joining group: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteRequirement() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    if (user == null || user.id != widget.companion.createdBy) return;

    setState(() => _isLoading = true);

    try {
      // Delete requirement
      final reqUrl = Uri.parse(
        'https://sportsapp1-31d70-default-rtdb.firebaseio.com/${widget.companion.databasePath}/${widget.companion.id}.json',
      );
      await http.delete(reqUrl);

      // Delete group
      final groupUrl = Uri.parse(
        'https://sportsapp1-31d70-default-rtdb.firebaseio.com/${widget.companion.groupsPath}/${widget.companion.id}.json',
      );
      await http.delete(groupUrl);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Requirement deleted successfully')),
      );

      if (widget.onDeleted != null) {
        widget.onDeleted!();
      }
    } catch (e) {
      print('Error deleting requirement: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatRemainingTime() {
    final now = DateTime.now();
    final endTime = DateTime.parse(widget.companion.endTime2);
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return 'Expired';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      if (days == 1) {
        return '1 day ${hours}h left';
      } else {
        return '$days days ${hours}h left';
      }
    } else if (hours > 0) {
      if (minutes > 0) {
        return '${hours}h ${minutes}m left';
      } else {
        return '${hours}h left';
      }
    } else if (minutes > 0) {
      return '${minutes}m left';
    } else {
      return 'Less than 1m left';
    }
  }

  String _formatTimeRange() {
    try {
      final startTime = widget.companion.startTime.trim();
      final endTime = widget.companion.endTime.trim();

      return '${_formatSingleTime(startTime)} - ${_formatSingleTime(endTime)}';
    } catch (e) {
      return '${widget.companion.startTime} - ${widget.companion.endTime}';
    }
  }

  String _formatSingleTime(String time) {
    try {
      // Remove any extra whitespace
      time = time.trim();

      // If already in HH:MM format, ensure proper formatting
      if (time.contains(':')) {
        final parts = time.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          int minute = int.parse(parts[1]);

          // Convert to 12-hour format with AM/PM
          String period = hour >= 12 ? 'PM' : 'AM';
          if (hour == 0) {
            hour = 12;
          } else if (hour > 12) {
            hour -= 12;
          }

          return '${hour.toString()}:${minute.toString().padLeft(2, '0')} $period';
        }
      }

      // If it's just a number (like "14" for 2 PM)
      if (RegExp(r'^\d+$').hasMatch(time)) {
        int hour = int.parse(time);
        String period = hour >= 12 ? 'PM' : 'AM';
        if (hour == 0) {
          hour = 12;
        } else if (hour > 12) {
          hour -= 12;
        }
        return '${hour.toString()}:00 $period';
      }

      // If it already contains AM/PM, just format it nicely
      if (time.toUpperCase().contains('AM') ||
          time.toUpperCase().contains('PM')) {
        // Clean up existing AM/PM format
        String cleanTime = time.replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
        return cleanTime;
      }

      // Return as is if we can't parse it
      return time;
    } catch (e) {
      return time;
    }
  }

  String _formatDate() {
    try {
      final dateStr = widget.companion.date;

      // Handle different date formats
      if (dateStr.contains('-')) {
        // Try YYYY-MM-DD format
        try {
          final date = DateTime.parse(dateStr);
          final months = [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ];
          return '${date.day} ${months[date.month - 1]} ${date.year}';
        } catch (e) {
          // If parsing fails, try DD-MM-YYYY format
          final parts = dateStr.split('-');
          if (parts.length == 3) {
            try {
              final day = int.parse(parts[0]);
              final month = int.parse(parts[1]);
              final year = int.parse(parts[2]);
              final months = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ];
              return '$day ${months[month - 1]} $year';
            } catch (e) {
              return dateStr;
            }
          }
        }
      } else if (dateStr.contains('/')) {
        // Handle DD/MM/YYYY or MM/DD/YYYY format
        final parts = dateStr.split('/');
        if (parts.length == 3) {
          try {
            final day = int.parse(parts[0]);
            final month = int.parse(parts[1]);
            final year = int.parse(parts[2]);
            final months = [
              'Jan',
              'Feb',
              'Mar',
              'Apr',
              'May',
              'Jun',
              'Jul',
              'Aug',
              'Sep',
              'Oct',
              'Nov',
              'Dec',
            ];
            return '$day ${months[month - 1]} $year';
          } catch (e) {
            return dateStr;
          }
        }
      }

      return dateStr;
    } catch (e) {
      return widget.companion.date;
    }
  }

  Color _getRemainingTimeColor() {
    final now = DateTime.now();
    final endTime = DateTime.parse(widget.companion.endTime2);
    final difference = endTime.difference(now);

    if (difference.isNegative) {
      return Colors.red;
    } else if (difference.inHours < 2) {
      return Colors.orange;
    } else if (difference.inHours < 24) {
      return Colors.amber;
    } else {
      return widget.companion.typeColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    final isCreator = user?.id == widget.companion.createdBy;
    final remainingTime = _formatRemainingTime();
    final timeColor = _getRemainingTimeColor();

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: widget.companion.typeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundColor: widget.companion.typeColor.withOpacity(0.2),
                child: Icon(
                  widget.companion.typeIcon,
                  color: widget.companion.typeColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                widget.companion.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on, widget.companion.location),
            _buildInfoRow(Icons.calendar_today, _formatDate()),
            const SizedBox(height: 12),
            Row(
              children: [
                CircularAvatar(
                  imageUrl: _creatorImage,
                  userId: widget.companion.createdBy,
                  radius: 12,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _creatorName ?? 'Loading...',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: timeColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: timeColor.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    remainingTime == 'Expired' ? Icons.timer_off : Icons.timer,
                    size: 14,
                    color: timeColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    remainingTime,
                    style: TextStyle(
                      fontSize: 12,
                      color: timeColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 24),
              _buildDetailRow(
                Icons.description,
                'Description',
                widget.companion.description,
              ),
              _buildDetailRow(Icons.person, 'Gender', widget.companion.gender),
              _buildDetailRow(
                Icons.cake,
                'Age Limit',
                widget.companion.ageLimit,
              ),
              _buildDetailRow(
                Icons.payment,
                'Type',
                widget.companion.paymentType,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (isCreator)
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _deleteRequirement,
                      icon: const Icon(Icons.delete),
                      label: const Text('Delete'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed:
                          (_isLoading || _hasJoined || _hasRequested)
                              ? null
                              : _joinGroup,
                      icon: Icon(
                        _hasRequested
                            ? Icons.hourglass_empty
                            : _hasJoined
                            ? Icons.check
                            : Icons.group_add,
                      ),
                      label: Text(
                        _hasRequested
                            ? 'Requested'
                            : _hasJoined
                            ? 'Joined'
                            : 'Join Group',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        disabledBackgroundColor: widget.companion.typeColor
                            .withOpacity(0.3),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (context) => ChatScreen(
                                groupId: widget.companion.groupId,
                                groupName: widget.companion.name,
                              ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Chat'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => setState(() => _isExpanded = !_isExpanded),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isExpanded ? 'Show Less' : 'Show More',
                      style: const TextStyle(color: AppTheme.primaryColor),
                    ),
                    Icon(
                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
