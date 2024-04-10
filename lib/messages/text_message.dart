import 'package:bazapp/time_functions.dart';
import 'package:flutter/material.dart';

class TextMessage extends StatefulWidget {
  final String text;
  final DateTime timestamp;
  final bool isCurrentUser;
  final GapType gapType;
  final ScrollController? scrollController;

  const TextMessage(
      this.text, this.timestamp, this.isCurrentUser, this.gapType,
      {super.key, this.scrollController});

  @override
  State<TextMessage> createState() => _TextMessageState();
}

class _TextMessageState extends State<TextMessage> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    final [bubbleColor, textColor] = widget.isCurrentUser
        ? [
            Colors.blue,
            Colors.white,
          ]
        : [
            const Color(0xFFDDDDDD),
            Colors.black,
          ];
    final padding = widget.isCurrentUser
        ? const EdgeInsets.fromLTRB(72.0, 1.0, 8.0, 1.0)
        : const EdgeInsets.fromLTRB(8.0, 1.0, 72.0, 1.0);

    final gap = widget.gapType.toGap(widget.timestamp);

    return GestureDetector(
      onTap: () {
        setState(() {
          isHovering = !isHovering;
        });
      },
      child: Column(
        children: [
          gap,
          Align(
            alignment: widget.isCurrentUser
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Padding(
              padding: padding,
              child: Container(
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  widget.text,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
          ),
          if (isHovering)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Align(
                alignment: widget.isCurrentUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                child: Text(TimeFunctions.getFormattedTime(widget.timestamp), style: const TextStyle(fontSize: 12)),
              ),
            )
        ],
      ),
    );
  }
}

enum GapType {
  showDate,
  showTime,
  showSmallGap,
  showNoGap;

  Widget toGap(DateTime timestamp) {
    switch (this) {
      case GapType.showDate:
        return Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 8.0),
          child: Text("${TimeFunctions.getComfyDate(timestamp)} • ${TimeFunctions.getFormattedTime(timestamp)}",
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        );
      case GapType.showTime:
        return Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 4.0),
          child: Text(TimeFunctions.getFormattedTime(timestamp), style: const TextStyle(fontSize: 12)),
        );
      case GapType.showSmallGap:
        return const SizedBox(
          height: 8.0,
        );
      case GapType.showNoGap:
        return const SizedBox.shrink();
    }
  }

  static GapType getGapType(DateTime currentMessageTimestamp, DateTime previousMessageTimestamp) {
    if (currentMessageTimestamp.day != previousMessageTimestamp.day) {
      return GapType.showDate;
    }
    if (currentMessageTimestamp.difference(previousMessageTimestamp).inHours >= 1) {
      return GapType.showTime;
    }
    if (currentMessageTimestamp.difference(previousMessageTimestamp).inMinutes >= 1) {
      return GapType.showSmallGap;
    }
    return GapType.showNoGap;
  }
}
