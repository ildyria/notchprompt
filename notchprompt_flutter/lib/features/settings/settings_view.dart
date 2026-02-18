import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/extensions.dart';
import '../../core/platform.dart';
import '../overlay/overlay_window.dart';
import '../prompter/prompter_provider.dart';
import '../prompter/prompter_state.dart';
import '../script/script_editor_view.dart';
import 'settings_provider.dart';

/// Settings window — script editor + all configurable options.
class SettingsView extends ConsumerWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final transport = ref.watch(prompterProvider);
    final prompter = ref.read(prompterProvider.notifier);

    final readDuration =
        estimateReadSeconds(settings.script, settings.speedPointsPerSecond);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notchprompt'),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: prompter.toggleRunning,
            icon: Icon(
              transport.transportState.isRunning
                  ? Icons.pause_rounded
                  : Icons.play_arrow_rounded,
            ),
            label: Text(
              transport.transportState.isRunning ? 'Pause' : 'Start',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Script editor ──────────────────────────────────────────────
            const SectionHeader('Script'),
            const SizedBox(height: 8),
            ScriptEditorView(
              initialText: settings.script,
              onChanged: notifier.updateScript,
            ),
            const SizedBox(height: 4),
            Text(
              'Estimated read time: ${formatDuration(readDuration)}',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white54),
            ),
            const SizedBox(height: 24),

            // ── Speed ──────────────────────────────────────────────────────
            const SectionHeader('Speed'),
            const SizedBox(height: 8),
            _SpeedRow(
              value: settings.speedPointsPerSecond,
              onChanged: notifier.updateSpeed,
              onPreset: notifier.applySpeedPreset,
            ),
            const SizedBox(height: 24),

            // ── Display ────────────────────────────────────────────────────
            const SectionHeader('Display'),
            const SizedBox(height: 8),
            _LabeledSlider(
              label: 'Font size',
              value: settings.fontSize,
              min: kMinFontSize,
              max: kMaxFontSize,
              divisions: (kMaxFontSize - kMinFontSize).toInt(),
              format: (v) => '${v.toStringAsFixed(0)} pt',
              onChanged: notifier.updateFontSize,
            ),
            _LabeledSlider(
              label: 'Overlay width',
              value: settings.overlayWidth,
              min: kMinOverlayWidth,
              max: kMaxOverlayWidth,
              divisions: ((kMaxOverlayWidth - kMinOverlayWidth) / 10).toInt(),
              format: (v) => '${v.toStringAsFixed(0)} px',
              onChanged: notifier.updateOverlayWidth,
            ),
            _LabeledSlider(
              label: 'Overlay height',
              value: settings.overlayHeight,
              min: kMinOverlayHeight,
              max: kMaxOverlayHeight,
              divisions: ((kMaxOverlayHeight - kMinOverlayHeight) / 5).toInt(),
              format: (v) => '${v.toStringAsFixed(0)} px',
              onChanged: notifier.updateOverlayHeight,
            ),
            const SizedBox(height: 24),

            // ── Countdown ──────────────────────────────────────────────────
            const SectionHeader('Countdown'),
            const SizedBox(height: 8),
            _LabeledSlider(
              label: 'Duration',
              value: settings.countdownSeconds.toDouble(),
              min: kMinCountdownSeconds.toDouble(),
              max: kMaxCountdownSeconds.toDouble(),
              divisions: kMaxCountdownSeconds - kMinCountdownSeconds,
              format: (v) =>
                  v == 0 ? 'Off' : '${v.toStringAsFixed(0)} s',
              onChanged: (v) => notifier.updateCountdownSeconds(v.round()),
            ),
            const SizedBox(height: 24),

            // ── Privacy mode (macOS only) ──────────────────────────────────
            if (supportsPrivacyMode) ...[
              const SectionHeader('Privacy'),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('Privacy mode'),
                subtitle: const Text(
                  'Hides the overlay from screen capture and recordings.',
                ),
                value: settings.privacyModeEnabled,
                onChanged: (_) => notifier.togglePrivacyMode(),
                contentPadding: EdgeInsets.zero,
              ),
              const SizedBox(height: 24),
            ],

            // ── Launch overlay ─────────────────────────────────────────────
            const SectionHeader('Overlay'),
            const SizedBox(height: 8),
            _LaunchOverlayButton(),
            const SizedBox(height: 24),

            // ── Transport shortcuts ────────────────────────────────────────
            const SectionHeader('Quick Actions'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: prompter.resetScroll,
                  icon: const Icon(Icons.restart_alt_rounded, size: 16),
                  label: const Text('Reset scroll'),
                ),
                OutlinedButton.icon(
                  onPressed: prompter.jumpBack,
                  icon: const Icon(Icons.replay_5_rounded, size: 16),
                  label: const Text('Jump back 5 s'),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Section header ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white38,
            letterSpacing: 1.2,
            fontSize: 11,
          ),
    );
  }
}

// ─── Labeled slider ───────────────────────────────────────────────────────────

class _LabeledSlider extends StatelessWidget {
  const _LabeledSlider({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.format,
    required this.onChanged,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final String Function(double) format;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 120,
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 64,
          child: Text(
            format(value),
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.white70),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ─── Speed row with presets ───────────────────────────────────────────────────

class _SpeedRow extends StatelessWidget {
  const _SpeedRow({
    required this.value,
    required this.onChanged,
    required this.onPreset,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final ValueChanged<double> onPreset;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 120,
              child: Text(
                'Speed',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Slider(
                value: value.clamp(kMinSpeed, kMaxSpeed),
                min: kMinSpeed,
                max: kMaxSpeed,
                divisions:
                    ((kMaxSpeed - kMinSpeed) / kSpeedStep).round(),
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 64,
              child: Text(
                '${value.toStringAsFixed(0)} px/s',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.white70),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 120),
            _PresetButton(
              label: 'Slow',
              preset: kSpeedPresetSlow,
              current: value,
              onTap: onPreset,
            ),
            const SizedBox(width: 8),
            _PresetButton(
              label: 'Normal',
              preset: kSpeedPresetNormal,
              current: value,
              onTap: onPreset,
            ),
            const SizedBox(width: 8),
            _PresetButton(
              label: 'Fast',
              preset: kSpeedPresetFast,
              current: value,
              onTap: onPreset,
            ),
          ],
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  const _PresetButton({
    required this.label,
    required this.preset,
    required this.current,
    required this.onTap,
  });

  final String label;
  final double preset;
  final double current;
  final ValueChanged<double> onTap;

  @override
  Widget build(BuildContext context) {
    final active = (current - preset).abs() < 0.5;
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 32),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        backgroundColor:
            active ? Colors.white24 : Colors.white10,
      ),
      onPressed: () => onTap(preset),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }
}

// ─── Launch overlay button ────────────────────────────────────────────────────

class _LaunchOverlayButton extends ConsumerWidget {
  // ignore: prefer_const_constructors_in_immutables — used as a leaf with state
  _LaunchOverlayButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOverlayVisible = ref.watch(
      overlayWindowProvider.select((s) => s.isVisible),
    );

    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: isOverlayVisible ? Colors.white24 : Colors.deepPurple,
        minimumSize: const Size(160, 40),
      ),
      onPressed: isOverlayVisible
          ? () => ref.read(overlayWindowProvider.notifier).hide()
          : () => ref.read(overlayWindowProvider.notifier).show(),
      icon: Icon(
        isOverlayVisible
            ? Icons.close_fullscreen_rounded
            : Icons.open_in_full_rounded,
        size: 16,
      ),
      label: Text(isOverlayVisible ? 'Hide Overlay' : 'Launch Overlay'),
    );
  }
}

// ─── Transport state extension ────────────────────────────────────────────────

extension _TransportStateX on TransportState {
  bool get isRunning => this == TransportState.running;
}
