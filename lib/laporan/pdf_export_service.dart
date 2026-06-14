import 'dart:io';

import 'package:cashier/manage/formater.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  /// Generates and saves a professional sales report PDF.
  ///
  /// [filteredTrx] — list of transaction wrappers (same structure used in the
  /// CSV export: each element is `{'id': ..., 'data': {...}}`).
  ///
  /// [periodeLabel] — human-readable period label, e.g. "Hari Ini", "Bulan Ini".
  ///
  /// Returns the saved [File] on success, or `null` on failure.
  static Future<File?> generateReport({
    required List filteredTrx,
    required String periodeLabel,
  }) async {
    // ── 1. Compute data (same logic as CSV export) ──────────────────────
    int totalRevenue = 0;
    int totalCost = 0;
    int totalProductsSold = 0;
    final Map<String, Map<String, dynamic>> stats = {};

    // Collect detail rows (per-item per-transaction)
    final List<Map<String, dynamic>> detailRows = [];

    for (var wrap in filteredTrx) {
      var trx = wrap['data'] as Map<String, dynamic>;
      totalRevenue += _asInt(trx['bayar']);

      DateTime? tglDate;
      try {
        tglDate = trx['tgl']?.toDate();
      } catch (_) {}

      var items = trx['data'] as List<dynamic>? ?? [];
      for (var it in items) {
        if (it is! Map) continue;
        String idb = (it['idb'] ?? it['id'] ?? it['kode'] ?? '').toString();
        int qty = _asInt(it['jumlahbeli']);
        int harga = _asInt(it['harga']);
        int revenue =
            it['totharga'] == null ? harga * qty : _asInt(it['totharga']);
        int modalVal = _asInt(it['modal']);
        int cost = modalVal * qty;
        totalCost += cost;
        totalProductsSold += qty;

        // Detail row
        detailRows.add({
          'tanggal': tglDate,
          'nama': it['nama'] ?? '-',
          'jumlah': qty,
          'harga': harga,
          'total': revenue,
        });

        // Stats aggregation
        if (!stats.containsKey(idb)) {
          stats[idb] = {
            'name': it['nama'] ?? '',
            'qty': qty,
            'revenue': revenue,
            'cost': cost,
          };
        } else {
          stats[idb]!['qty'] = _asInt(stats[idb]!['qty']) + qty;
          stats[idb]!['revenue'] = _asInt(stats[idb]!['revenue']) + revenue;
          stats[idb]!['cost'] = _asInt(stats[idb]!['cost']) + cost;
        }
      }
    }

    final int totalProfit = totalRevenue - totalCost;

    // Sort detail rows by date descending
    detailRows.sort((a, b) {
      final da = a['tanggal'] as DateTime?;
      final db = b['tanggal'] as DateTime?;
      if (da == null && db == null) return 0;
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });

    // Sort product stats by qty descending
    var sortedStats = stats.entries.toList()
      ..sort(
          (a, b) => _asInt(b.value['qty']).compareTo(_asInt(a.value['qty'])));

    // ── 2. Build PDF ────────────────────────────────────────────────────
    final pdf = pw.Document();

    // Try to load custom font from assets, fall back to Helvetica
    pw.Font? customFont;
    pw.Font? customFontBold;
    try {
      final fontData = await rootBundle.load('assets/m.ttf');
      customFont = pw.Font.ttf(fontData);
      customFontBold = customFont; // Use the same font for bold
    } catch (_) {
      // Fall back to default fonts
    }

    final baseStyle = customFont != null
        ? pw.TextStyle(font: customFont, fontSize: 9)
        : const pw.TextStyle(fontSize: 9);
    final boldStyle = customFontBold != null
        ? pw.TextStyle(font: customFontBold, fontSize: 9, fontWeight: pw.FontWeight.bold)
        : pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold);

    final now = DateTime.now();
    final tanggalCetak =
        DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(now);

    // Color palette matching the app
    const navyColor = PdfColor.fromInt(0xFF1A237E);
    const tealColor = PdfColor.fromInt(0xFF00BFA5);
    const lightBg = PdfColor.fromInt(0xFFF5F7FA);

    // ── Helper widgets ──────────────────────────────────────────────────

    pw.Widget sectionTitle(String title) {
      return pw.Container(
        margin: const pw.EdgeInsets.only(bottom: 8, top: 16),
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: const pw.BoxDecoration(
          color: navyColor,
          borderRadius: pw.BorderRadius.all(pw.Radius.circular(4)),
        ),
        child: pw.Text(
          title,
          style: pw.TextStyle(
            font: customFontBold ?? customFont,
            fontSize: 11,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.white,
          ),
        ),
      );
    }

    pw.Widget summaryRow(String label, String value,
        {bool highlight = false}) {
      return pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: pw.BoxDecoration(
          color: highlight ? const PdfColor.fromInt(0xFFE8F5E9) : null,
          border: pw.Border(
            bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
          ),
        ),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label, style: baseStyle),
            pw.Text(value, style: boldStyle),
          ],
        ),
      );
    }

    // ── Build multi-page PDF ────────────────────────────────────────────
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) {
          if (context.pageNumber > 1) {
            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'LAPORAN PENJUALAN — KasirKilat',
                    style: pw.TextStyle(
                      font: customFontBold ?? customFont,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    'Halaman ${context.pageNumber}',
                    style: pw.TextStyle(
                      font: customFont,
                      fontSize: 8,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            );
          }
          return pw.SizedBox.shrink();
        },
        footer: (context) {
          return pw.Container(
            margin: const pw.EdgeInsets.only(top: 10),
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 0.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Dicetak pada $tanggalCetak',
                  style: pw.TextStyle(
                    font: customFont,
                    fontSize: 7,
                    color: PdfColors.grey500,
                  ),
                ),
                pw.Text(
                  'Halaman ${context.pageNumber} dari ${context.pagesCount}',
                  style: pw.TextStyle(
                    font: customFont,
                    fontSize: 7,
                    color: PdfColors.grey500,
                  ),
                ),
              ],
            ),
          );
        },
        build: (context) {
          final widgets = <pw.Widget>[];

          // ─── HEADER ─────────────────────────────────────────────────
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                color: navyColor,
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'LAPORAN PENJUALAN',
                    style: pw.TextStyle(
                      font: customFontBold ?? customFont,
                      fontSize: 20,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'KasirKilat',
                    style: pw.TextStyle(
                      font: customFont,
                      fontSize: 13,
                      color: tealColor,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Divider(color: PdfColors.white, thickness: 0.5),
                  pw.SizedBox(height: 8),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Periode Laporan',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 8,
                              color: PdfColors.grey300,
                            ),
                          ),
                          pw.Text(
                            periodeLabel,
                            style: pw.TextStyle(
                              font: customFontBold ?? customFont,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.end,
                        children: [
                          pw.Text(
                            'Tanggal Cetak',
                            style: pw.TextStyle(
                              font: customFont,
                              fontSize: 8,
                              color: PdfColors.grey300,
                            ),
                          ),
                          pw.Text(
                            tanggalCetak,
                            style: pw.TextStyle(
                              font: customFontBold ?? customFont,
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );

          // ─── RINGKASAN LAPORAN ──────────────────────────────────────
          widgets.add(sectionTitle('RINGKASAN LAPORAN'));
          widgets.add(
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                children: [
                  summaryRow(
                      'Total Transaksi', '${filteredTrx.length} transaksi'),
                  summaryRow(
                      'Total Produk Terjual', '$totalProductsSold produk'),
                  summaryRow(
                      'Total Penjualan', uang.format(totalRevenue),
                      highlight: true),
                  if (totalCost > 0)
                    summaryRow('Total Modal', uang.format(totalCost)),
                  if (totalCost > 0)
                    summaryRow(
                      'Total Keuntungan',
                      uang.format(totalProfit),
                      highlight: true,
                    ),
                ],
              ),
            ),
          );

          // ─── TABEL DETAIL PENJUALAN ─────────────────────────────────
          widgets.add(sectionTitle('DETAIL PENJUALAN'));

          if (detailRows.isEmpty) {
            widgets.add(
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                child: pw.Text(
                  'Tidak ada data transaksi pada periode ini.',
                  style: pw.TextStyle(
                    font: customFont,
                    fontSize: 10,
                    color: PdfColors.grey600,
                    fontStyle: pw.FontStyle.italic,
                  ),
                ),
              ),
            );
          } else {
            widgets.add(
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                    color: PdfColors.grey400, width: 0.5),
                headerDecoration:
                    const pw.BoxDecoration(color: navyColor),
                headerStyle: pw.TextStyle(
                  font: customFontBold ?? customFont,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerAlignment: pw.Alignment.center,
                cellStyle: pw.TextStyle(font: customFont, fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(30), // No
                  1: const pw.FixedColumnWidth(80), // Tanggal
                  2: const pw.FlexColumnWidth(3), // Nama Produk
                  3: const pw.FixedColumnWidth(45), // Jumlah
                  4: const pw.FixedColumnWidth(75), // Harga
                  5: const pw.FixedColumnWidth(80), // Total
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.centerRight,
                  5: pw.Alignment.centerRight,
                },
                headers: ['No', 'Tanggal', 'Nama Produk', 'Jml', 'Harga', 'Total'],
                data: List.generate(detailRows.length, (i) {
                  final row = detailRows[i];
                  final tgl = row['tanggal'] as DateTime?;
                  final tglStr = tgl != null
                      ? DateFormat('dd/MM/yy HH:mm', 'id_ID').format(tgl)
                      : '-';
                  return [
                    '${i + 1}',
                    tglStr,
                    row['nama'].toString(),
                    '${row['jumlah']}',
                    _formatRupiah(row['harga'] as int),
                    _formatRupiah(row['total'] as int),
                  ];
                }),
              ),
            );

            // Total row below the table
            widgets.add(
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  border: pw.Border.all(color: PdfColors.grey400, width: 0.5),
                  borderRadius: const pw.BorderRadius.only(
                    bottomLeft: pw.Radius.circular(4),
                    bottomRight: pw.Radius.circular(4),
                  ),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'TOTAL PENJUALAN:  ',
                      style: pw.TextStyle(
                        font: customFontBold ?? customFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      uang.format(totalRevenue),
                      style: pw.TextStyle(
                        font: customFontBold ?? customFont,
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: tealColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // ─── REKAP PRODUK TERJUAL ───────────────────────────────────
          if (sortedStats.isNotEmpty) {
            widgets.add(sectionTitle('REKAP PRODUK TERJUAL'));
            widgets.add(
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                    color: PdfColors.grey400, width: 0.5),
                headerDecoration:
                    const pw.BoxDecoration(color: tealColor),
                headerStyle: pw.TextStyle(
                  font: customFontBold ?? customFont,
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerAlignment: pw.Alignment.center,
                cellStyle: pw.TextStyle(font: customFont, fontSize: 8),
                cellAlignment: pw.Alignment.centerLeft,
                columnWidths: {
                  0: const pw.FixedColumnWidth(30), // No
                  1: const pw.FlexColumnWidth(4), // Nama Produk
                  2: const pw.FixedColumnWidth(65), // Jumlah Terjual
                  3: const pw.FixedColumnWidth(90), // Total Penjualan
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                },
                headers: [
                  'No',
                  'Nama Produk',
                  'Jumlah Terjual',
                  'Total Penjualan',
                ],
                data: List.generate(sortedStats.length, (i) {
                  final entry = sortedStats[i];
                  return [
                    '${i + 1}',
                    entry.value['name'].toString(),
                    '${_asInt(entry.value['qty'])}',
                    _formatRupiah(_asInt(entry.value['revenue'])),
                  ];
                }),
              ),
            );
          }

          // ─── KESIMPULAN ─────────────────────────────────────────────
          widgets.add(sectionTitle('KESIMPULAN'));
          widgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: pw.BorderRadius.circular(4),
                border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              ),
              child: pw.Text(
                'Pada periode "$periodeLabel", KasirKilat mencatat total penjualan '
                'sebesar ${uang.format(totalRevenue)} dari ${filteredTrx.length} '
                'transaksi dengan total $totalProductsSold produk terjual.'
                '${totalCost > 0 ? ' Total modal yang dikeluarkan sebesar ${uang.format(totalCost)} '
                    'dengan keuntungan bersih sebesar ${uang.format(totalProfit)}.' : ''}'
                ' Laporan ini dicetak secara otomatis oleh aplikasi KasirKilat '
                'pada $tanggalCetak.',
                style: pw.TextStyle(
                  font: customFont,
                  fontSize: 9,
                  lineSpacing: 4,
                ),
                textAlign: pw.TextAlign.justify,
              ),
            ),
          );

          // Spacing at the end
          widgets.add(pw.SizedBox(height: 20));

          return widgets;
        },
      ),
    );

    // ── 3. Save the PDF file ────────────────────────────────────────────
    final bytes = await pdf.save();

    String path = '.';
    if (Platform.isAndroid) {
      path = '/storage/emulated/0/Download';
      if (!await Directory(path).exists()) {
        final dir = await getExternalStorageDirectory();
        path = dir?.path ?? '.';
      }
    } else {
      try {
        final dir = await getDownloadsDirectory();
        path = dir?.path ?? '';
      } catch (_) {}
      if (path.isEmpty) {
        final dir = await getApplicationDocumentsDirectory();
        path = dir.path;
      }
    }
    final fileName =
        'laporan_penjualan_${DateFormat('yyyyMMdd_HHmmss').format(now)}.pdf';
    final file = File('$path/$fileName');
    await file.writeAsBytes(bytes);

    return file;
  }

  /// Opens the system share / print dialog for the generated PDF.
  static Future<void> sharePdf(File file) async {
    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
  }

  static int _asInt(dynamic value) {
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _formatRupiah(int value) {
    return uang.format(value);
  }
}
