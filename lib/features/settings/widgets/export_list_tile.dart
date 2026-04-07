import 'package:flutter/material.dart';
import 'package:poketra_vy/features/settings/widgets/export_data_dialog.dart';

class ExportListTile extends StatelessWidget {
  const ExportListTile({super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.file_download_outlined,
        color: Theme.of(context).primaryColor,
      ),
      title: Text(
        'Export Data',
        style: TextStyle(
          color: Theme.of(context).primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: const Text(
        'Download your data in Excel or JSON format',
        style: TextStyle(color: Colors.black54, fontSize: 13),
      ),
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const ExportDataDialog(),
        );
      },
    );
  }
}
