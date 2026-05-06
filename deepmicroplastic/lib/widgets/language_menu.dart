import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../main.dart';

/// Reusable language menu (PT/EN). Uses the global `localeService` to
/// hot-swap the UI without rebuilding the navigator.
class LanguageMenu extends StatelessWidget {
  const LanguageMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final current = localeService.locale.languageCode;
    return PopupMenuButton<String>(
      icon: const Icon(Icons.language, color: Colors.white70),
      tooltip: l.language,
      color: const Color(0xFF111827),
      onSelected: (code) => localeService.setLocale(Locale(code)),
      itemBuilder: (_) => [
        _item(code: 'en', label: l.languageEnglish, current: current),
        _item(code: 'pt', label: l.languagePortuguese, current: current),
      ],
    );
  }

  PopupMenuItem<String> _item({
    required String code,
    required String label,
    required String current,
  }) {
    final selected = code == current;
    return PopupMenuItem(
      value: code,
      child: Row(children: [
        Icon(
          selected ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: selected ? Colors.cyanAccent : Colors.white38,
        ),
        const SizedBox(width: 10),
        Text(label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white70,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            )),
      ]),
    );
  }
}
