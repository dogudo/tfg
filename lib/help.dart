import 'package:flutter/material.dart';

// stores ExpansionPanel state information
class Item {
  Item({
    required this.expandedValue,
    required this.headerValue,
    this.isExpanded = false,
  });

  String expandedValue;
  String headerValue;
  bool isExpanded;
}

class HelpScreen extends StatefulWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final List<Item> _data = [
    Item(
      headerValue: 'How can I scan an ingredients list?',
      expandedValue:
          'To scan an ingredients list, simply press the scan button and point the camera at the list, wait for the focus to adjust and press the shutter button.',
    ),
    Item(
      headerValue: 'Why are the ingredients not being recognized?',
      expandedValue:
          'To ensure an accurate scanning, check that the lighting is adecuate and use the flash option if needed. Also, please note that the scanner will offer better results with plain surfaces and may not work on rugged or curved text.',
    ),
    Item(
      headerValue: 'Can I blindly trust the scanner results?',
      expandedValue:
          'No, while the scanner does its best to ensure accurate results, it may not be able to read or detect all of the allergens in the ingredients list. Please always double-check the packaging yourself.',
    )
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Help'),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: _buildPanel(),
        ),
      ),
    );
  }

  Widget _buildPanel() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(
                item.headerValue,
                style: Theme.of(context).textTheme.headline6,
              ),
            );
          },
          body: ListTile(
            title: Text(item.expandedValue),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
