import 'dart:io';

void main() {
  File file = File('lib/laporan/laporan.dart');
  String content = file.readAsStringSync();

  // 1. Fix the loop: for (var trx in dayTrx) -> for (var wrap in dayTrx)
  content = content.replaceAllMapped(
      RegExp(r'for\s*\(\s*var\s+trx\s+in\s+dayTrx\s*\)\s*\{\s*dayTotal\s*\+=\s*\(trx\[\x27bayar\x27\]\s*as\s*num\)\.toInt\(\);\s*\}'),
      (m) => '''for (var wrap in dayTrx) {
              var trx = wrap['data'] as Map<String, dynamic>;
              dayTotal += (trx['bayar'] as num).toInt();
            }'''
  );

  // 2. Wrap Container in GestureDetector
  content = content.replaceAllMapped(
      RegExp(r'return\s+Container\(\s*margin:\s*const\s*EdgeInsets\.only\(bottom:\s*8\),\s*padding:\s*const\s*EdgeInsets\.all\(12\),\s*decoration:\s*BoxDecoration\(\s*color:\s*isToday'),
      (m) => '''return GestureDetector(
              onTap: () {
                _showDailyTransactions(context, date, dayTrx);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isToday'''
  );

  // 3. Fix the closing tag of the GestureDetector
  content = content.replaceAllMapped(
      RegExp(r'\),\s*\],\s*\),\s*\);\s*\}\);'),
      (m) => '),\n                ],\n              ),\n            ));\n          }),'
  );

  file.writeAsStringSync(content);
}
