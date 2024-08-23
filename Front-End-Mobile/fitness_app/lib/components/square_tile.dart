import 'package:flutter/material.dart';

class SquareTile extends StatelessWidget {
  final String imagePath;
  final String title;
  final VoidCallback onTap; // Add onTap callback

  const SquareTile({
    super.key,
    required this.imagePath,
    required this.title,
    required this.onTap, // Initialize onTap
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // Handle tap
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(16),
          color: Colors.grey[200],
        ),
        child: Row(
          children: [
            Flexible(
              flex: 1,
              child: Image.asset(
                imagePath,
                height: 40,
              ),
            ),
            const SizedBox(width: 10), // Reduced spacing
            Flexible(
              flex: 3, // Adjust the flex value as needed
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
