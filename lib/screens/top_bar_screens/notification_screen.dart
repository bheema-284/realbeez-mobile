import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beez/utils/app_colors.dart';

void main() {
  runApp(MaterialApp(
    home: NotificationsScreen(),
    debugShowCheckedModeBanner: false,
  ));
}

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool showUnread = false;
  bool _hasUnreadNotifications = true;

  List<Map<String, dynamic>> notifications = [
    {
      'name': 'Charvi',
      'message':
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris.',
      'time': '10:30 pm',
      'date': 'Today',
      'avatar': 'assets/images/submit.png',
      'unread': true,
      'id': '1',
      'type': 'message',
    },
    {
      'name': 'Yami',
      'message':
          'Your order #12345 has been shipped successfully. You can track your order using the tracking number: TRK789456123.',
      'time': '08:30 pm',
      'date': 'Today',
      'avatar': 'assets/images/submit.png',
      'unread': false,
      'id': '2',
      'type': 'order',
    },
    {
      'name': 'John',
      'message':
          'There is a new update available for the app. Update now to get the latest features and security improvements.',
      'time': '03:30 pm',
      'date': 'Today',
      'avatar': 'assets/images/wishlist.png',
      'unread': false,
      'id': '3',
      'type': 'system',
    },
    {
      'name': 'Ravi',
      'message':
          'Your payment of \$45.99 has been processed successfully. Thank you for your purchase!',
      'time': '08:30 pm',
      'date': 'Yesterday',
      'avatar': 'assets/images/wishlist.png',
      'unread': false,
      'id': '4',
      'type': 'payment',
    },
    {
      'name': 'Kishore',
      'message':
          'Your account security settings have been updated. If this was not you, please contact support immediately.',
      'time': '03:30 pm',
      'date': 'Yesterday',
      'avatar': 'assets/images/submit.png',
      'unread': true,
      'id': '5',
      'type': 'security',
    },
    {
      'name': 'Yamini',
      'message':
          'New products from your favorite brands are now available. Check them out before they sell out!',
      'time': '03:30 pm',
      'date': '2 days ago',
      'avatar': 'assets/images/wishlist.png',
      'unread': false,
      'id': '6',
      'type': 'promotion',
    },
  ];

  // Mark a notification as read
  void _markAsRead(String notificationId) {
    setState(() {
      final index = notifications.indexWhere((n) => n['id'] == notificationId);
      if (index != -1) {
        notifications[index]['unread'] = false;
      }
      _updateUnreadStatus();
    });
  }

  // Mark all notifications as read
  void _markAllAsRead() {
    setState(() {
      for (var notification in notifications) {
        notification['unread'] = false;
      }
      _updateUnreadStatus();
    });
  }

  // Delete a notification
  void _deleteNotification(String notificationId) {
    setState(() {
      notifications.removeWhere((n) => n['id'] == notificationId);
      _updateUnreadStatus();
    });
  }

  // Update the unread status flag
  void _updateUnreadStatus() {
    _hasUnreadNotifications = notifications.any((n) => n['unread'] == true);
  }

  // Navigate to notification detail
  void _openNotificationDetail(Map<String, dynamic> notification) {
    if (notification['unread'] == true) {
      _markAsRead(notification['id']);
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NotificationDetailScreen(
          notification: notification,
          onDelete: () {
            _deleteNotification(notification['id']);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  // Show options dialog for a notification
  void _showNotificationOptions(BuildContext context, String notificationId, bool isUnread) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isUnread)
                ListTile(
                  leading: const Icon(Icons.mark_email_read, color: Colors.blue),
                  title: Text('Mark as read', style: GoogleFonts.poppins()),
                  onTap: () {
                    Navigator.pop(context);
                    _markAsRead(notificationId);
                  },
                ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: Text('Delete', style: GoogleFonts.poppins()),
                onTap: () {
                  Navigator.pop(context);
                  _deleteNotification(notificationId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cancel, color: Colors.grey),
                title: Text('Cancel', style: GoogleFonts.poppins()),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _updateUnreadStatus();
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFFEFF1FA);
    const Color greyText = Color(0xFF707070);
    const Color lightGreyText = Color(0xFFB0B0B0);

    final filtered = showUnread
        ? notifications.where((n) => n['unread'] == true).toList()
        : notifications;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          if (_hasUnreadNotifications && !showUnread)
            IconButton(
              icon: const Icon(Icons.mark_email_read, color: Colors.black54),
              onPressed: _markAllAsRead,
              tooltip: 'Mark all as read',
            ),
        ],
      ),
      body: Theme(
        data: Theme.of(context).copyWith(
          scrollbarTheme: ScrollbarThemeData(
            thumbColor: MaterialStateProperty.all(AppColors.beeYellow),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // "All" tab
                  GestureDetector(
                    onTap: () => setState(() => showUnread = false),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                      decoration: BoxDecoration(
                        color: !showUnread ? AppColors.beeYellow : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: !showUnread
                              ? Colors.transparent
                              : Colors.grey.shade400,
                        ),
                      ),
                      child: Text(
                        'All',
                        style: GoogleFonts.poppins(
                          color: !showUnread ? Colors.black : Colors.black54,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // "Unread" tab with badge
                  GestureDetector(
                    onTap: () => setState(() => showUnread = true),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: showUnread ? AppColors.beeYellow : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: showUnread
                                  ? Colors.transparent
                                  : Colors.grey.shade400,
                            ),
                          ),
                          child: Text(
                            'Unread',
                            style: GoogleFonts.poppins(
                              color: showUnread ? Colors.black : Colors.black54,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (_hasUnreadNotifications)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            // Empty State or List
            if (filtered.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        showUnread ? Icons.notifications_off : Icons.notifications_none,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        showUnread ? 'No unread notifications' : 'No notifications',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade600,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        showUnread 
                            ? 'You\'re all caught up!'
                            : 'Notifications will appear here',
                        style: GoogleFonts.poppins(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Expanded(
                child: Scrollbar(
                  thumbVisibility: true,
                  thickness: 4,
                  radius: const Radius.circular(4),
                  interactive: true,
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      final bool unread = item['unread'] ?? false;

                      return GestureDetector(
                        onTap: () => _openNotificationDetail(item),
                        onLongPress: () {
                          _showNotificationOptions(context, item['id'], unread);
                        },
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              // Main Card
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: unread
                                      ? Border.all(color: AppColors.beeYellow, width: 2)
                                      : null,
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 3,
                                      offset: Offset(0, 1),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 13),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    // Avatar
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundImage: AssetImage(item['avatar']),
                                      backgroundColor: Colors.grey.shade200,
                                    ),
                                    const SizedBox(width: 12),
                                    // Text column
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Name + Time
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                item['name'],
                                                style: GoogleFonts.poppins(
                                                  color: Colors.black,
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                item['time'],
                                                style: GoogleFonts.poppins(
                                                  color: lightGreyText,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 6),
                                          // Message
                                          Text(
                                            item['message'],
                                            style: GoogleFonts.poppins(
                                              color: greyText,
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Options button
                                    GestureDetector(
                                      onTap: () {
                                        _showNotificationOptions(context, item['id'], unread);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: unread
                                              ? AppColors.beeYellow
                                              : Colors.grey.shade300,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: const Icon(
                                          Icons.more_horiz,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.chevron_right,
                                      color: AppColors.beeYellow,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                              // Unread indicator
                              if (unread)
                                Positioned(
                                  top: -4,
                                  right: -4,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: AppColors.beeYellow,
                                      borderRadius: BorderRadius.circular(6),
                                      border:
                                          Border.all(color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble,
                                      color: Colors.white,
                                      size: 10,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Notification Detail Screen
class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;
  final VoidCallback onDelete;

  const NotificationDetailScreen({
    super.key,
    required this.notification,
    required this.onDelete,
  });

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'payment':
        return Icons.payment;
      case 'security':
        return Icons.security;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.settings;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'payment':
        return Colors.green;
      case 'security':
        return Colors.orange;
      case 'promotion':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      default:
        return AppColors.beeYellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF1FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.black54),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Delete Notification', style: GoogleFonts.poppins()),
                  content: Text('Are you sure you want to delete this notification?', 
                      style: GoogleFonts.poppins()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Cancel', style: GoogleFonts.poppins()),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        onDelete();
                      },
                      child: Text('Delete', 
                          style: GoogleFonts.poppins(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Icon and Title
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: _getNotificationColor(notification['type']).withOpacity(0.1),
                    child: Icon(
                      _getNotificationIcon(notification['type']),
                      color: _getNotificationColor(notification['type']),
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notification['name'],
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${notification['date']} • ${notification['time']}',
                    style: GoogleFonts.poppins(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Message Content
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Message',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    notification['message'],
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Action Buttons
            if (notification['type'] == 'order')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Track order action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.beeYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Track Order',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            if (notification['type'] == 'promotion')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Shop now action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.beeYellow,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Shop Now',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}