import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nosh/config/globalScaffold.dart';
import 'package:nosh/helpers/errorMessageSnackBar.dart';
import 'package:nosh/models/ShoppingItem.dart';
import 'package:nosh/models/StoredItem.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:nosh/helpers/sourceAndImageFetcherDialog.dart';
import 'dart:io';

class InputModal extends StatefulWidget {
  final vm;
  final String modalName;
  final recievedItem;
  final imageUri;
  InputModal(this.modalName, this.vm, this.recievedItem, {this.imageUri = ''});

  @override
  _InputModalState createState() => _InputModalState(modalName);
}

class _InputModalState extends State<InputModal> {
  final String modalName;

  _InputModalState(this.modalName);

  final _formKey = GlobalKey<FormState>();

  final int animationSpeed = 200;
  bool willHaveExpiry = false;
  bool willHaveQuantity = false;
  var item;
  var submit;
  String modalTitle = '';
  String initialQuantityText = '';
  String initialNameText = '';
  DateTime initialDate = DateTime.now();
  String configuration;
  String imageUri = '';
  String buttonText = '';

  DatePickerController _calenderController = DatePickerController();

  @override
  void initState() {
    super.initState();
    imageUri = widget.imageUri;
    setModalState();
    WidgetsBinding.instance.addPostFrameCallback((_) => navToDate());
  }

  navToDate() {
    if (configuration != 'STOCK_CONFIG') return;
    _calenderController.animateToDate(
        initialDate.difference(DateTime.now()).inDays == 0
            ? initialDate.add(Duration(days: -1))
            : initialDate,
        curve: Curves.easeOut);
  }

  setModalState() {
    if (modalName == 'ADD_TO_STOCKED') {
      modalTitle = "Add to inventory";
      configuration = 'STOCK_CONFIG';
      item = Item();
      if (widget.recievedItem != null)
        initialNameText = widget.recievedItem.name;
    }

    if (modalName == 'SHOP_LIST') {
      modalTitle = "Add to shopping list";
      item = ShoppingItem();
      configuration = 'SHOP_CONFIG';
    }

    if (modalName == 'UPDATE_SHOP') {
      buttonText = "Update item";
      modalTitle = "Update Item";
      configuration = "SHOP_CONFIG";
      item = ShoppingItem();
      initialNameText = widget.recievedItem.name ?? '';
      initialQuantityText = widget.recievedItem.quantity ?? '';
      if (widget.recievedItem.quantity != null) willHaveQuantity = true;
    }

    if (modalName == 'UPDATE_STOCKED') {
      buttonText = "Update item";
      modalTitle = "Update Item";
      configuration = "STOCK_CONFIG";
      item = Item();
      initialNameText = widget.recievedItem.name ?? '';
      initialQuantityText = widget.recievedItem.quantity ?? '';
      if (widget.recievedItem.quantity != '') willHaveQuantity = true;
      if (widget.recievedItem.expiry != null) {
        willHaveExpiry = true;
        initialDate = widget.recievedItem.expiry;
      }
      if (widget.recievedItem.imageUri != '')
        imageUri = widget.recievedItem.imageUri ?? '';
    }
    if (modalName == 'MOVE_TO_STOCKED') {
      modalTitle = "Add to inventory";
      configuration = 'STOCK_CONFIG';
      item = Item();
      item.expiry = initialDate;
      if (widget.recievedItem != null && widget.recievedItem.quantity != '')
        willHaveQuantity = true;
      initialNameText = widget.recievedItem.name ?? '';
      initialQuantityText = widget.recievedItem.quantity ?? '';
    }
  }

  Widget buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        modalTitle,
        style: TextStyle(color: Colors.grey[700]),
      ),
    );
  }

  Widget buildInputForm() {
    return Builder(
      builder: (context) => Form(
        key: _formKey,
        child: Wrap(
          children: <Widget>[
            configuration == 'STOCK_CONFIG' ? buildImagePicker() : SizedBox(),
            TextFormField(
              initialValue: initialNameText,
              validator: (value) {
                if (value.isEmpty) return 'please enter a product name';
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: 'Product name',
              ),
              onSaved: (val) => setState(() => item.name = val),
            ),
            enterQuantity(),
            configuration == "STOCK_CONFIG" ? enterDate() : Container()
          ],
        ),
      ),
    );
  }

  Widget buildImagePicker() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child:
            Stack(alignment: AlignmentDirectional.bottomEnd, children: <Widget>[
          CircleAvatar(
              backgroundColor: Colors.grey[100],
              radius: 50,
              backgroundImage: selectImageType(imageUri),
              child: imageUri == ''
                  ? Icon(Icons.fastfood, size: 30, color: Colors.grey[800])
                  : null),
          GestureDetector(
            child: CircleAvatar(
                backgroundColor: Color(0xff5c39f8),
                radius: 18,
                child: Icon(
                  Icons.camera_alt,
                  size: 17,
                  color: Colors.white,
                )),
            onTap: () async {
              File imageFile = await alertForSourceAndGetImage(context);

              if (imageFile != null) setState(() => imageUri = imageFile.path);
            },
          ),
        ]),
      ),
    );
  }

  selectImageType(String link) {
    if (link.startsWith('https'))
      return NetworkImage(link);
    else if (link == '')
      return null;
    else
      return FileImage(File(link));
  }

  Widget enterQuantity() {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("Enter Quantity?"),
            Checkbox(
              activeColor: Color(0xff5c39f8),
              value: willHaveQuantity,
              onChanged: (value) {
                FocusScope.of(context).unfocus();
                setState(() => willHaveQuantity = value);
              },
            ),
          ],
        ),
        AnimatedCrossFade(
          crossFadeState: willHaveQuantity
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: Duration(milliseconds: animationSpeed),
          firstChild: TextFormField(
              initialValue: initialQuantityText,
              decoration: InputDecoration(
                  border: InputBorder.none, labelText: 'Quantity'),
              onSaved: (val) => setState(() => item.quantity = val)),
          secondChild: Container(),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget enterDate() {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text("Enter an expiry?"),
            Checkbox(
              activeColor: Color(0xff5c39f8),
              value: willHaveExpiry,
              onChanged: (value) {
                FocusScope.of(context).unfocus();
                setState(() => willHaveExpiry = value);
              },
            ),
          ],
        ),
        AnimatedCrossFade(
          crossFadeState: willHaveExpiry
              ? CrossFadeState.showFirst
              : CrossFadeState.showSecond,
          duration: Duration(milliseconds: animationSpeed),
          firstChild: Container(
            width: MediaQuery.of(context).size.width,
            height: 135,
            padding: EdgeInsets.symmetric(vertical: 20),
            child: SizedOverflowBox(
              alignment: Alignment.centerLeft,
              child: DatePicker(
                DateTime.now(),
                initialSelectedDate: initialDate,
                controller: _calenderController,
                daysCount: 100,
                selectionColor: Theme.of(context).primaryColor,
                selectedTextColor: Colors.white,
                onDateChange: (date) {
                  if (willHaveExpiry) initialDate = date;
                },
              ),
              size: Size(100, 80),
            ),
          ),
          secondChild: Container(),
        ),
        SizedBox(height: 10)
      ],
    );
  }

  Widget buildSubmit() {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: RaisedButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        color: Theme.of(context).primaryColor,
        onPressed: () async {
          final form = _formKey.currentState;
          if (form.validate()) {
            form.save();
            if (configuration == 'STOCK_CONFIG') {
              if (willHaveExpiry == true)
                print("will expire laaaaaaaaaaaaaaaaaaaaa");
              if (modalName == 'ADD_TO_STOCKED' ||
                  modalName == 'MOVE_TO_STOCKED') {
                widget.vm
                    .onAddItem(item.name, item.quantity, item.expiry, imageUri);
                baseScaffold.currentState.showSnackBar(
                    showError('Item successfully added to stock'));
              }
              if (modalName == 'MOVE_TO_STOCKED') {
                widget.vm.onRemoveShopItem(widget.recievedItem);
              }
              if (modalName == 'UPDATE_STOCKED') {
                if (!willHaveQuantity) setState(() => item.quantity = '');
                widget.vm.onUpdateItem(item.copyWith(
                    id: widget.recievedItem.id, imageUri: imageUri));
                baseScaffold.currentState
                    .showSnackBar(showError('Item successfully updated'));
              }
            }

            if (configuration == 'SHOP_CONFIG') {
              if (modalName == 'SHOP_LIST') {
                widget.vm.onAddShopItem(item.name, item.quantity);
                baseScaffold.currentState
                    .showSnackBar(showError('Item added to shopping list'));
              }
              if (modalName == 'UPDATE_SHOP') {
                widget.vm.onUpdateShoppingItem(
                    item.copyWith(id: widget.recievedItem.id));
                baseScaffold.currentState
                    .showSnackBar(showError('Item successfully updated'));
              }
            }
            Navigator.pop(context);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
          child: Row(
            children: <Widget>[
              Text(buttonText == '' ? '+' : '',
                  style:
                      TextStyle(fontWeight: FontWeight.normal, fontSize: 18)),
              Text(buttonText == '' ? "  Add item" : "Update item")
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: (_) {
        FocusScope.of(context).unfocus();
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        contentPadding: EdgeInsets.all(28),
        title: buildTitle(),
        content:
            Scrollbar(child: SingleChildScrollView(child: buildInputForm())),
        actions: <Widget>[buildSubmit()],
      ),
    );
  }
}
