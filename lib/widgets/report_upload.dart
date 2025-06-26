import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportUpload extends StatelessWidget {
  final String title;
  final List<File> files;
  final List<String> urls;
  final VoidCallback onUploadTap;
  final VoidCallback onCameraTap;

  const ReportUpload({
    Key? key,
    required this.title,
    required this.files,
    required this.urls,
    required this.onUploadTap,
    required this.onCameraTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: onUploadTap,
                  icon: const Icon(Icons.upload_file),
                ),
                IconButton(
                  onPressed: onCameraTap,
                  icon: const Icon(Icons.camera_alt),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: files.isNotEmpty
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: files.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: title == 'History Docs'
                        ? const Icon(Icons.insert_drive_file, size: 50)
                        : Image.file(
                            files[i],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                )
              : Center(
                  child: Text(
                    'No files uploaded',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ),
        ),
        const SizedBox(height: 8),
        ...urls.map(
          (url) => InkWell(
            onTap: () => _openUrl(url),
            child: Text(
              url,
              style: const TextStyle(
                decoration: TextDecoration.underline,
                color: Colors.blue,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    }
  }
}
