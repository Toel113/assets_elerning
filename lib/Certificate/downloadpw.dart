import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final File file;

  PdfViewerScreen({required this.file});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Future<void> _downloadPDF() async {
    try {
      Directory? downloadsDir = await getExternalStorageDirectory();
      String downloadsPath = downloadsDir!.path;
      File downloadFile =
          File('$downloadsPath/${widget.file.path.split('/').last}');
      await downloadFile.writeAsBytes(await widget.file.readAsBytes());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('PDF Downloaded successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: _downloadPDF,
          ),
        ],
      ),
      body: PDFView(
        filePath: widget.file.path,
        enableSwipe: true,
        swipeHorizontal: false,
        autoSpacing: false,
        pageSnap: true,
        onError: (error) {
          print(error.toString());
        },
      ),
    );
  }
}
