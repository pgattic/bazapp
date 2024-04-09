import 'package:bazapp/time_functions.dart';
import 'package:flutter/material.dart';

class TextMessage extends StatefulWidget {
  final String text;
  final DateTime timestamp;
  final bool isCurrentUser;
  final bool showDate;
  final ScrollController? scrollController;

  const TextMessage(
      this.text, this.timestamp, this.isCurrentUser, this.showDate,
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

    return GestureDetector(
      onTap: () {
        setState(() {
          isHovering = !isHovering;
        });
        if (widget.scrollController != null) {
          //widget.scrollController!.animateTo(, duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
        }
      },
      child: Column(
        children: [
          if (widget.showDate)
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 20.0, 0.0, 8.0),
              child: Text("${TimeFunctions.getComfyDate(widget.timestamp)} • ${TimeFunctions.getFormattedTime(widget.timestamp)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
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
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Text(
                  widget.text,
                  style: TextStyle(fontSize: 16, color: textColor),
                ),
              ),
            ),
          ),
          if (isHovering)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
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
