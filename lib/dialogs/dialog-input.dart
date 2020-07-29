import 'package:flutter/material.dart';
import 'package:masked_text/masked_text.dart';

Future<String> asyncInputDialog(
    {BuildContext context,
    String inputText,
    String title,
    String doneText,
    String placeholder,
    TextInputType keyboardType,
    bool cantCancel: false,
    bool phoneNumberMask: false}) async {
  TextEditingController _controller = new TextEditingController();
  _controller.text = inputText;

  return showDialog<String>(
    barrierDismissible: !cantCancel,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Row(
          children: <Widget>[
            Expanded(
                child: phoneNumberMask
                    ? MaskedTextField(
                        maskedTextFieldController: _controller,
                        mask: '+27 xx xxx xxxx',
                        maxLength: 15,
                        keyboardType: TextInputType.phone,
                        inputDecoration: InputDecoration(
                            labelText: 'Phone Number', hintText: '+27'),
                      )
                    : TextFormField(
                        maxLines: null,
                        keyboardType: keyboardType,
                        controller: _controller,
                        autofocus: true,
                        decoration: InputDecoration(hintText: placeholder)))
          ],
        ),
        actions: <Widget>[
          !cantCancel
              ? FlatButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white54),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              : null,
          FlatButton(
            child: Text((doneText != null) ? doneText : 'Done'),
            onPressed: () {
              Navigator.of(context).pop(_controller.text);
            },
          ),
        ],
      );
    },
  );
}
