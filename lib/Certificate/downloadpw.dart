import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

class PdfViewerScreen extends StatefulWidget {
  final File? file; // Update to allow null values
  final String? fileURL; // Update to allow null values

  PdfViewerScreen({this.file, this.fileURL});

  @override
  _PdfViewerScreenState createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  Future<void> _downloadPDF() async {
    try {
      String? downloadUrl;
      if (widget.file != null) {
        downloadUrl = widget.file!.path;
      } else if (widget.fileURL != null) {
        downloadUrl = widget.fileURL!;
      }
      if (downloadUrl != null) {
        print('Downloading PDF from: $downloadUrl');
        File pdfFile = File(downloadUrl);
        if (!pdfFile.existsSync()) {
          throw Exception('File does not exist at path: $downloadUrl');
        }
        Directory appDocumentsDirectory =
            await getApplicationDocumentsDirectory();
        String destinationPath = '${appDocumentsDirectory.path}/file.pdf';
        await pdfFile.copy(destinationPath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF downloaded successfully. ${pdfFile.path}'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        throw Exception('File or URL not provided.');
      }
    } catch (e, stackTrace) {
      print('Error downloading PDF: $e');
      print(stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to download PDF: $e'),
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
        filePath: widget.file?.path ?? '',
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
