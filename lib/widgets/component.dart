import 'package:fdls/constants.dart';
import 'package:fdls/providers/popup.dart';
import 'package:fdls/widgets/input_region.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Component<T> extends StatelessWidget {
  final Color primaryColor;
  final double? width;
  final BorderSide border;
  final Function()? onTap;
  final Widget? popup;
  final Widget child;

  const Component({
    required this.primaryColor,
    this.width,
    this.border = BorderSide.none,
    this.onTap,
    this.popup,
    required this.child,
    super.key,
  });

  Component.asyncValue({
    required AsyncValue<T> value,
    required Widget Function(BuildContext, T) builder,
    required this.primaryColor,
    this.width,
    this.border = BorderSide.none,
    this.onTap,
    this.popup,
    super.key,
  }) : child = Builder(
          builder: (context) => value.when(
            data: (v) => builder(context, v),
            error: (e, st) => ComponentErrorContents(e, st),
            loading: () => Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: width != null ? null : 40,
                child: const Center(child: LinearProgressIndicator()),
              ),
            ),
          ),
        );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InputRegion(
          child: Material(
            color: fdlsBackgroundColor,
            shadowColor: Colors.transparent,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: border,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Theme(
              data: Theme.of(context).copyWith(
                primaryColor: primaryColor,
                colorScheme: Theme.of(context).colorScheme.copyWith(
                      primary: primaryColor,
                    ),
              ),
              child: _Interactivity(
                onTap: onTap,
                popup: popup,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Interactivity extends ConsumerStatefulWidget {
  final Function()? onTap;
  final Widget? popup;
  final Widget child;

  const _Interactivity({
    required this.onTap,
    this.popup,
    required this.child,
  });

  @override
  ConsumerState<_Interactivity> createState() => _InteractivityState();
}

class _InteractivityState extends ConsumerState<_Interactivity> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onHover: widget.popup != null
          ? (enter) {
              if (enter) {
                if (ref.read(popupExpandedProvider)) return;

                ref.read(popupProvider.notifier).state = widget.popup!;

                final box = context.findRenderObject() as RenderBox;
                final rect = box.localToGlobal(Offset.zero) & box.size;

                ref.read(popupAnchorRectProvider.notifier).state = rect;

                ref.read(popupSizeProvider.notifier).state = fdlsPopupSize;

                ref.read(popupThemeProvider.notifier).state = Theme.of(context);
              } else if (!ref.read(popupExpandedProvider)) {
                ref.read(popupProvider.notifier).state = null;
              }
            }
          : null,
      onTap: (widget.onTap == null && widget.popup == null)
          ? null
          : () {
              if (widget.onTap != null) widget.onTap!();
              if (widget.popup == null) return;

              if (ref.read(popupExpandedProvider)) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  ref.read(popupProvider.notifier).state = widget.popup!;

                  final box = context.findRenderObject() as RenderBox;
                  final rect = box.localToGlobal(Offset.zero) & box.size;

                  ref.read(popupAnchorRectProvider.notifier).state = rect;
                  ref.read(popupThemeProvider.notifier).state =
                      Theme.of(context);
                });
              } else {
                ref.read(popupExpandedProvider.notifier).state = true;
              }

              ref.read(popupSizeProvider.notifier).state = fdlsPopupFullSize;
            },
      child: widget.child,
    );
  }
}

class ComponentErrorContents extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;

  const ComponentErrorContents(
    this.error,
    this.stackTrace, {
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    print("$error\n$stackTrace");
    return Tooltip(
      message: error.toString(),
      child: Container(
        color: Colors.red.withOpacity(0.2),
        child: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      ),
    );
  }
}
