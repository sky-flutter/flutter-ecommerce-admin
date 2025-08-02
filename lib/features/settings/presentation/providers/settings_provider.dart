import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/settings_model.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

final settingsProvider =
    FutureProvider.family<SettingsModel, String>((ref, userId) async {
  final firestore = ref.watch(firestoreServiceProvider);
  final doc = await firestore.getDocument('settings', userId);
  return SettingsModel.fromMap(doc.data() as Map<String, dynamic>);
});
