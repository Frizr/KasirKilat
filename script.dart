import 'dart:io';

void main() {
  File file = File('lib/laporan/laporan.dart');
  String content = file.readAsStringSync();

  // 1. Remove call to _buildBarChart
  content = content.replaceAll(
    '                // Bar Chart\n                _buildBarChart(val),\n                const SizedBox(height: 20),\n\n                // Pembukuan Kasir',
    '                // Pembukuan Kasir'
  );

  // 2. Remove _buildBarChart and _formatShort methods
  content = content.replaceAll(RegExp(r'  Widget _buildBarChart[\s\S]*?  String _formatShort[\s\S]*?  }\n'), '');

  // 3. Update grouped type and loop inside _buildPembukuan
  content = content.replaceAll(
    'Map<String, List<Map<String, dynamic>>> grouped = {};',
    'Map<String, List<dynamic>> grouped = {};'
  );
  content = content.replaceAll(
    'grouped[dateKey]!.add(trx);',
    'grouped[dateKey]!.add(wrap);'
  );

  // 4. Update the inner loop calculating total
  content = content.replaceAll(
    'for (var trx in dayTrx) {\n              dayTotal += (trx[\'bayar\'] as num).toInt();\n            }',
    'for (var wrap in dayTrx) {\n              var trx = wrap[\'data\'] as Map<String, dynamic>;\n              dayTotal += (trx[\'bayar\'] as num).toInt();\n            }'
  );

  // 5. Add GestureDetector
  content = content.replaceAll(
    '            return Container(\n              margin: const EdgeInsets.only(bottom: 8),\n              padding: const EdgeInsets.all(12),\n              decoration: BoxDecoration(\n                color: isToday',
    '            return GestureDetector(\n              onTap: () {\n                _showDailyTransactions(context, date, dayTrx);\n              },\n              child: Container(\n                margin: const EdgeInsets.only(bottom: 8),\n                padding: const EdgeInsets.all(12),\n                decoration: BoxDecoration(\n                  color: isToday'
  );
  
  // Update closing tags for the container
  content = content.replaceAll(
    '                    ),\n                  ),\n                ],\n              ),\n            );\n          }),',
    '                    ),\n                  ),\n                ],\n              ),\n            ));\n          }),'
  );

  // 6. Add _showDailyTransactions
  String showDailyCode = '''
  void _showDailyTransactions(BuildContext context, DateTime date, List<dynamic> dayTrx) {
    String dateStr = DateFormat('dd MMMM yyyy', 'id_ID').format(date);
    Get.bottomSheet(
      Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Transaksi \$dateStr',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: dayTrx.length,
                itemBuilder: (context, index) {
                  var wrap = dayTrx[index];
                  var trx = wrap['data'] as Map<String, dynamic>;
                  var bayar = (trx['bayar'] as num?)?.toInt() ?? 0;
                  var id = wrap['id'] ?? 'Unknown';
                  var tglDate = trx['tgl']?.toDate();
                  String timeStr = tglDate != null ? DateFormat('HH:mm').format(tglDate) : '';
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.bgLight,
                      child: Icon(Icons.receipt, color: AppColors.navy),
                    ),
                    title: Text(
                      'Transaksi \$id',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    subtitle: Text(timeStr, style: const TextStyle(fontSize: 11)),
                    trailing: Text(
                      uang.format(bayar),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      ignoreSafeArea: false,
    );
  }

  Widget _buildTopProducts(
''';
  content = content.replaceAll(
    '  Widget _buildTopProducts(',
    showDailyCode
  );

  file.writeAsStringSync(content);
}
