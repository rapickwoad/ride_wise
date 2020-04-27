import 'package:flutter/material.dart';

class Tclock {
  const Tclock({this.name});
  final String name;
}

typedef void InspectChangedCallback(Tclock tclock, bool Checked);

class InspectionListItem extends StatelessWidget {
  InspectionListItem({this.tclock, this.Checked, this.onInspectChanged})
      : super(key: ObjectKey(tclock));

  final Tclock tclock;
  final bool Checked;
  final InspectChangedCallback onInspectChanged;

  Color _getColor(BuildContext context) {

    return Checked ? Colors.black : Theme.of(context).primaryColor;

  }

  TextStyle _getTextStyle(BuildContext context) {
    if (!Checked) return null;

    return TextStyle(
      color: Colors.black,
      decoration: TextDecoration.lineThrough,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        onInspectChanged(tclock, Checked);
      },
      leading: CircleAvatar(
        backgroundColor: _getColor(context),
        child: Text(tclock.name[0]),
      ),
      title: Text(tclock.name, style: _getTextStyle(context)),
    );
  }
}

class InspectionList extends StatefulWidget {
  InspectionList({Key key, this.tclocks}) : super(key: key);

  final List<Tclock> tclocks;

  @override
  _InspectionListState createState() => _InspectionListState();
}

class _InspectionListState extends State<InspectionList> {
  Set<Tclock> _Inspected = Set<Tclock>();

  void _handleInspectChanged(Tclock tclock, bool Checked) {
    setState(() {
      if (!Checked)
        _Inspected.add(tclock);
      else
        _Inspected.remove(tclock);
    });
  }

  @override

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('TCLOCK'),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        children: widget.tclocks.map((Tclock tclock) {
          return InspectionListItem(
            tclock: tclock,
            Checked: _Inspected.contains(tclock),
            onInspectChanged: _handleInspectChanged,
          );
        }).toList(),
      ),
    );
  }
}

class TclockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
    child: InspectionList(
      tclocks: <Tclock>[
        Tclock(name: 'Tires'),
        Tclock(name: 'Controls'),
        Tclock(name: 'Lights'),
        Tclock(name: 'Oils'),
        Tclock(name: 'Chains & Chasis'),
        Tclock(name: 'Kickstand'),
      ],
    ),
    );
  }
}