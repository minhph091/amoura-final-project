import 'package:flutter/material.dart';

class ProfileGallery extends StatelessWidget {
  const ProfileGallery({super.key});
  @override
  Widget build(BuildContext context) {
    // Display user's photo gallery using images from model/provider
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 0, // Replace with length of photo list
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          // final photo = photos[index];
          return ClipRRect(
            borderRadius: BorderRadius.circular(12),
            // child: Image.network(photo.url, width: 90, height: 120, fit: BoxFit.cover)
            child: Container(width: 90, height: 120, color: Colors.grey[200]),
          );
        },
      ),
    );
  }
}