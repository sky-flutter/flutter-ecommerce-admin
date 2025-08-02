import 'package:flutter/material.dart';

class CustomDataTable extends StatelessWidget {
  final List<DataColumn> columns;
  final List<DataRow> rows;
  final void Function(DataRow)? onRowTap;
  const CustomDataTable(
      {super.key, required this.columns, required this.rows, this.onRowTap});

  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: columns,
      rows: rows,
    );
  }
}
