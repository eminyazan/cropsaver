import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cool_alert/cool_alert.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:get/route_manager.dart';
import 'package:get/get_utils/get_utils.dart';

import '../common/loading_screen.dart';
import '../bases/crop_base.dart';
import '../bases/farmer_base.dart';
import '../common/custom_button.dart';
import '../common/screen_sizes.dart';
import '../db/database_base.dart';
import '../error_manager/errors.dart';

class ChooseCrops extends StatefulWidget {
  final String lanCode;
  final Farmer farmer;

  const ChooseCrops({Key key, @required this.farmer, @required this.lanCode}) : super(key: key);
  @override
  _ChooseCropsState createState() => _ChooseCropsState();
}

class _ChooseCropsState extends State<ChooseCrops> {
  Database _database=Database();


  List<Crop> _allCrops = [];

  var load = tr("load_more");
  var save = tr("save");
  var back = tr("back");
  var critic = tr("critical_heat");
  var choose = tr("choose_crops");

  @override
  void initState() {
    super.initState();
    _getCropList();
  }
  void _getCropList() async {
    _allCrops = await _database.getCropList();
    if (_allCrops.isNotEmpty) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return _allCrops.isNotEmpty?Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(choose),
        backgroundColor: Colors.lightGreenAccent.shade700,
      ),
      body:  Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: _allCrops.length,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                ),
                itemBuilder: (BuildContext ctx, int index) {
                  return GestureDetector(
                    onTap: () {
                      return showDialog(
                        context: context,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: pageHeight*0.3,
                              width: pageWidth*0.9,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: NetworkImage(_allCrops[index].url),
                                    fit: BoxFit.fill,
                                  )
                              ),
                            ),
                            AlertDialog(
                              title: widget.lanCode == "tr"
                                  ? Text(_allCrops[index].tr)
                                  : Text(_allCrops[index].name.capitalize),
                              content: Text(
                                critic + _allCrops[index].minHeat.toString()+" °C",
                              ),
                              actions: [
                                FlatButton(
                                  onPressed: () {
                                    Get.back();
                                    print("BACK PRESSED");
                                  },
                                  child: Text(back),
                                ),
                                FlatButton(
                                  onPressed: () {
                                    print("ADD PRESSED");
                                    Get.back();
                                    _addCropToMyCrops(widget.farmer.uid,_allCrops[index]);
                                  },
                                  child: Text(save),
                                ),

                              ],
                            ),
                          ],
                        ),);
                    },
                    child: Card(
                      elevation: 10,
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceAround,
                        children: [
                          widget.lanCode == "tr"
                              ? Text(
                            _allCrops[index].tr,
                            style: TextStyle(fontSize: 15),
                          )
                              : Text(_allCrops[index].name.capitalize),
                          Container(
                            height: pageHeight * 0.1,
                            width: pageWidth * 0.2,
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image:
                                NetworkImage(_allCrops[index].url),
                                fit: BoxFit.fill,
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _allCrops.last.id!=74?CustomButton(
              buttonIcon: Icon(
                Icons.more_outlined,
                color: Colors.white,
              ),
              buttonText: load,
              buttonColor: Colors.lightGreenAccent.shade700,
              onPressed: () => _loadMoreCrop(_allCrops.last.id),
            ):SizedBox(),
          ],
        ),
      ),
    ):LoadingScreen();

  }
  void _addCropToMyCrops(String uid,Crop crop) async{
    try{
      bool isAdded=await _database.addToMyCrops(uid,crop);
      if(isAdded){
        var title=tr("successful");
        var message=tr("crop_added");
        Get.snackbar(title, message);
      }else{
        var message=tr("limited_crop");
        Get.snackbar("", message);
      }
    }on FirebaseException catch(e){
      CoolAlert.show(
          context: context,
          type: CoolAlertType.error,
          title: ErrorManager.show(e.code));
    }
  }

  _loadMoreCrop(int lastId) async {
    List<Crop> _moreCrops = await _database.loadMoreCrop(lastId);
    _allCrops.addAll(_moreCrops);
    setState(() {});
  }
}
