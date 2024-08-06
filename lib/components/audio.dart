import 'package:fdls/constants.dart';
import 'package:fdls/src/rust/api/pipewire.dart';
import 'package:fdls/widgets/component.dart';
import 'package:fdls/widgets/component_hover_popup.dart';
import 'package:fdls/widgets/two_row.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:freezed_annotation/freezed_annotation.dart';

part 'audio.g.dart';
// part 'audio.freezed.dart';

@riverpod
Stream<List<void>> audioStream(AudioStreamRef ref) async* {}

class AudioComponent extends ConsumerWidget {
  const AudioComponent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audios = ref.watch(audioStreamProvider);

    return Component(
      primaryColor: Colors.green,
      width: fdlsSmallComponentWidth,
      popup: const _Popup(),
      child: GestureDetector(
        onHorizontalDragUpdate: (details) {},
        child: TwoRow(
          top: const Text("..."),
          icon: const Icon(Icons.volume_up),
          bottom: LinearProgressIndicator(
            value: 0.5,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

class _Popup extends ConsumerWidget {
  const _Popup();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    pipewireSendMsg(msg: PipeWireMsg.print);
    final objects = pipewireGetGlobals();
    return ComponentHoverPopup(
      icon: Icons.volume_up,
      title: "Audio",
      body: ListView.builder(
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(
              objects[index]
                      .props
                      .entries
                      .where((e) => e.key.endsWith("name"))
                      .firstOrNull
                      ?.value ??
                  "???",
            ),
            subtitle: Text(objects[index].kind.toString()),
          );
        },
      ),
    );
  }
}
