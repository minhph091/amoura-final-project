import 'package:flutter/material.dart';
import '../../setup/theme/setup_profile_theme.dart';

Future<void> showProfileActionMenu(BuildContext context, dynamic profile) async {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Container(
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.report, color: Colors.red),
              title: Text('Report User'),
              onTap: () {
                Navigator.pop(ctx);
                _showReportDialog(context, profile);
              },
            ),
            ListTile(
              leading: Icon(Icons.block, color: Colors.orange),
              title: Text('Block User'),
              onTap: () {
                Navigator.pop(ctx);
                _showBlockDialog(context, profile);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );
}

Future<void> _showReportDialog(BuildContext context, dynamic profile) async {
  // These reasons would come from backend in production
  final reasons = [
    "Fake profile/Impersonation",
    "Inappropriate photos",
    "Harassment/Bullying",
    "Spam/Scam",
    "Underage user",
    "Other"
  ];

  String? selectedReason;

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.report_problem, color: ProfileTheme.darkPink),
            const SizedBox(width: 8),
            Text('Report User', style: TextStyle(color: ProfileTheme.darkPurple)),
          ],
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Why are you reporting this user?',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        children: reasons.map((reason) {
                          return RadioListTile<String>(
                            contentPadding: EdgeInsets.symmetric(horizontal: 0),
                            title: Text(reason),
                            value: reason,
                            groupValue: selectedReason,
                            activeColor: ProfileTheme.darkPink,
                            onChanged: (value) {
                              setState(() {
                                selectedReason = value;
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: ProfileTheme.darkPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Submit Report'),
            onPressed: selectedReason == null ? null : () {
              // This would send the report to backend
              Navigator.of(context).pop();

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Report submitted successfully'),
                    backgroundColor: Colors.green,
                  )
              );
            },
          ),
        ],
      );
    },
  );
}

Future<void> _showBlockDialog(BuildContext context, dynamic profile) async {
  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.block, color: Colors.red),
            const SizedBox(width: 8),
            Text('Block User'),
          ],
        ),
        content: Text(
          'Are you sure you want to block this user? You will no longer see their profile or receive messages from them.',
          style: TextStyle(fontSize: 15),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('Block User'),
            onPressed: () {
              // This would send the block request to backend
              Navigator.of(context).pop();

              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('User blocked successfully'),
                    backgroundColor: Colors.green,
                  )
              );
            },
          ),
        ],
      );
    },
  );
}