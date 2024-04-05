
import 'package:bazapp/event/event.dart';
import 'package:bazapp/firebase/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EventSubscriptionDialog extends StatefulWidget {
  final CustomEvent event;
  final String? viewerId;

  const EventSubscriptionDialog(this.event, {Key? key, this.viewerId}) : super(key: key);

  @override
  State<EventSubscriptionDialog> createState() => _EventSubscriptionDialogState();
}

class _EventSubscriptionDialogState extends State<EventSubscriptionDialog> {
  bool? subscribed;
  int? subscriptions;

  @override
  void initState() {
    super.initState();
    _getSubStatus();
    _getSubCount();

    // Listen for changes in AuthProvider
    Provider.of<BZAuthProvider>(context, listen: false)
        .addListener(_onAuthProviderChange);
  }

  void _onAuthProviderChange() {
    _getSubStatus();
    _getSubCount();
  }

  void _getSubStatus() async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      bool? result = await authProvider.getEventSubscriptionStatus(widget.viewerId!, widget.event.id!);
      setState(() {
        subscribed = result;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  void _getSubCount() async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      int? result = await authProvider.getEventSubscriptionCount(widget.event.id!);
      setState(() {
        subscriptions = result;
      });
    } catch (e) {
      print('Error fetching events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (widget.viewerId != null && widget.viewerId != widget.event.userId) Row(
          children:
          [
            if (subscribed == null) const Text("Loading..."),
            if (subscribed == true) FilledButton(
              onPressed: () => {_unsubscribeFromEvent(context)},
              child: const Text("Unsubscribe"), 
            ),
            if (subscribed == false) ElevatedButton(
              onPressed: () => {_subscribeToEvent(context)},
              child: const Text("Subscribe"),
            ),
            SizedBox(width: 8),
          ]
        ),
        Row(
          children: [
            Icon(Icons.person),
            Text(subscriptions == null? "Loading...": subscriptions.toString()),
          ],
        ),
      ],
    );
  }

  _subscribeToEvent(BuildContext context) async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      await authProvider.subscribeToEvent(widget.viewerId!, widget.event.id!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }

  _unsubscribeFromEvent(BuildContext context) async {
    try {
      final authProvider = Provider.of<BZAuthProvider>(context, listen: false);
      await authProvider.unsubscribeFromEvent(widget.viewerId!, widget.event.id!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: $e'),
      ));
    }
  }
}
