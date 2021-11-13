import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pda_scan/pda_scan.dart';

//body: Container(
//child: SearchEdit(
//controller: TextEditingController(),
//scanCallback: ([value,error]){
//Logger.l
// og('扫描返回的内容$value');
//},
//),
//),
class SearchEdit extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final isSupportScan;
  final ValueChanged<String> onChanged;
  final VoidCallback onComplete;
  final TextAlign textAlign;
  final Color backgroundColor;
  final TextStyle textStyle;
  final TextStyle hintStyle;
  final EdgeInsets contentPadding;
  final EdgeInsets margin;
  final double height;
  final void Function([String, Object]) scanCallback; //满足直接扫描完后直接可以拿到值

  final bool enable; //不可编辑的同时，也无法响应点击事件
  final String contentText;

  final bool showIcon; // 是否显示前面的Icon
  final FocusNode focusNode;
  final showKeyBoard;

  SearchEdit({
    Key key,
    this.controller,
    this.hintText = '请扫描相应的内容',
    this.onChanged,
    this.onComplete,
    this.textAlign = TextAlign.left,
    this.isSupportScan = true,
    this.backgroundColor = Colors.white,
    this.textStyle = const TextStyle(fontSize: 14.0, color: Colors.blueAccent),
    this.hintStyle = const TextStyle(fontSize: 14.0, color: Colors.blueAccent),
    this.contentPadding,
    this.margin,
    this.height,
    this.enable = true, //
    this.scanCallback,
    this.contentText,
    this.showIcon = true,
    this.focusNode,
    this.showKeyBoard = true,
  }) : super(key: key);

  TextEditingController _setController(
      TextEditingController _controller, String contentText) {
    if (contentText != null) {
      _controller.value = _controller.value.copyWith(
        text: contentText,
        selection: TextSelection(
            baseOffset: contentText.length, extentOffset: contentText.length),
        composing: TextRange.empty,
      );
      return _controller;
    } else {
      return controller;
    }
  }

  @override
  _SearchEditState createState() =>
      _SearchEditState(_setController(controller, contentText));
}

class _SearchEditState extends State<SearchEdit> {
  FocusNode focusNode = new FocusNode();
  TextEditingController controller;
  PdaScan _pdaScan;

  _SearchEditState(this.controller);

  @override
  void initState() {
    super.initState();

    if (mounted) {
      focusNode?.addListener(() {
        if (focusNode.hasFocus) {
          // KeyBoardUtil.show();
        } else {}
      });
      if (widget.isSupportScan) {
        initScan();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 40,
      margin: widget.margin ?? EdgeInsets.fromLTRB(16, 6, 6, 16),
      decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(4.0),
          color: widget.backgroundColor),
      child: TextField(
        focusNode: focusNode,
        enabled: widget.enable,
        textAlign: widget.textAlign,
        style: widget.textStyle,
        controller: controller,
        onChanged: widget.onChanged,
        onEditingComplete: () {
          if (widget.scanCallback != null) {
            widget.scanCallback(controller.text);
          }
          widget.onComplete();
        },
        decoration: InputDecoration(
          prefixIcon: widget.showIcon
              ? IconButton(
                  icon: Icon(Icons.search, color: Color(0xffc6c6c6)),
                  onPressed: () async {
                    if (widget.isSupportScan == false) {
                      return;
                    }
                    String content = await _pdaScan.scanResult;
                    setState(() {
                      if (widget.scanCallback != null) {
                        widget.scanCallback(content);
                      }
                      if (content != null && content.toString().length > 0) {
                        controller.text = content;
                        controller.selection = TextSelection.fromPosition(
                            TextPosition(
                                affinity: TextAffinity.downstream,
                                offset: content.toString()?.length));
                      }
                    });
                  },
                )
              : null,
          hintText: widget.hintText,
          fillColor: widget.backgroundColor,
          hintStyle: widget.hintStyle,
          contentPadding:
              widget.contentPadding ?? EdgeInsets.only(top: 8, bottom: 8),
          border: OutlineInputBorder(
            borderSide: BorderSide.none,
          ),
          filled: true,
        ),
        autofocus: false,
      ),
    );
  }

  initScan() async {
    if (_pdaScan == null) {
      _pdaScan = PdaScan();
      _pdaScan.onScanResult.listen(_onEvent, onError: _onError);
    }
  }

  void _onEvent(Object event) {
    setState(() {
      if (event != null && event.toString().length > 0) {
        // if (mounted) FocusScope.of(context).requestFocus(focusNode);
        controller.text = event.toString();
        controller.selection = TextSelection.fromPosition(TextPosition(
            affinity: TextAffinity.downstream,
            offset: event.toString()?.length));
        if (widget.scanCallback != null) widget.scanCallback(event.toString());
      }
    });
  }

  void _onError(Object error) {
    if (widget.scanCallback != null) widget.scanCallback(null, error);
  }
}
