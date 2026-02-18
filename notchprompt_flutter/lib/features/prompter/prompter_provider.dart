import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notchprompt/features/prompter/prompter_notifier.dart';
import 'package:notchprompt/features/prompter/prompter_state.dart';

/// The single source of truth for teleprompter transport state.
final prompterProvider =
    StateNotifierProvider<PrompterNotifier, PrompterState>((ref) {
  return PrompterNotifier(ref);
});
