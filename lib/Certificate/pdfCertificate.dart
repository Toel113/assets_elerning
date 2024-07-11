import 'dart:io';
import 'package:assets_elerning/Certificate/saveandopenpdf.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CertificatePdfApi {
  static Future<File> generateCertificatePdf(
      String userName, String courseName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Container(
          padding: pw.EdgeInsets.all(30),
          decoration: pw.BoxDecoration(
            border: pw.Border.all(
              color: PdfColors.black,
              width: 3,
            ),
          ),
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            children: [
              pw.Text(
                'Certificate of Completion',
                style: pw.TextStyle(
                  fontSize: 30,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'This is to certify that',
                style: pw.TextStyle(fontSize: 24),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                userName,
                style: pw.TextStyle(
                  fontSize: 36,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                'has successfully completed the course:',
                style: pw.TextStyle(fontSize: 24),
              ),
              pw.SizedBox(height: 10),
              pw.Text(
                courseName,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontStyle: pw.FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return SaveAndOpenDocument.savePDF(name: "Certificate.pdf", pdf: pdf);
  }
}
