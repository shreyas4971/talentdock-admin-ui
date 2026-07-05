import 'package:flutter/material.dart';

class TalentDataTable<T> extends StatelessWidget {
  final List<T> items;
  final List<String> columns;
  final Widget Function(T item, String column) cellBuilder;
  final VoidCallback? onSort;
  final VoidCallback? onPageNext;
  final VoidCallback? onPagePrevious;

  const TalentDataTable({
    super.key,
    required this.items,
    required this.columns,
    required this.cellBuilder,
    this.onSort,
    this.onPageNext,
    this.onPagePrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: columns.map((col) => DataColumn(
                label: Text(col, style: const TextStyle(fontWeight: FontWeight.bold)),
                onSort: onSort != null ? (i, b) => onSort!() : null,
              )).toList(),
              rows: items.map((item) => DataRow(
                cells: columns.map((col) => DataCell(cellBuilder(item, col))).toList(),
              )).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPagePrevious),
                IconButton(icon: const Icon(Icons.chevron_right), onPressed: onPageNext),
              ],
            ),
          )
        ],
      ),
    );
  }
}
