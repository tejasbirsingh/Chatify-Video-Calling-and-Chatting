import 'package:flutter/material.dart';

class TextAreaWidget extends StatelessWidget {
  final String text;
  final VoidCallback onClickedCopy;

  const TextAreaWidget({
    @required this.text,
    @required this.onClickedCopy,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).splashColor,
                ),
                gradient: LinearGradient(colors: [
                  Theme.of(context).backgroundColor,
                  Theme.of(context).scaffoldBackgroundColor
                ]),
              ),
              padding: EdgeInsets.all(8),
              alignment: Alignment.center,
              child: SelectableText(
                text.isEmpty ? 'Scan an Image to get text' : text,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText1,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.copy, color: Colors.green),
            color: Colors.grey[200],
            onPressed: onClickedCopy,
          ),
        ],
      );
}
