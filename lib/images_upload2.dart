import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';


class Album {
  String  Msg;
  String  img_url;
  String  Status;

  Album(this.Msg, this.img_url, this.Status);
}

class Image_Upload2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Image Picker Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //final ImagePicker _imagePicker = ImagePickerChannel();

  File _imageFile;
  var _futureAlbumlist=List<Album>();
  var Isloading=false;

  Future<void> captureImage(ImageSource imageSource) async {
    try {
      final imageFile = await ImagePicker.pickImage(source: imageSource);
      setState(() {
        _imageFile = imageFile;
      });
    } catch (e) {
      print(e);
    }
  }


/*
  Future _getuser(String file) async {
    var date = await http.post("http://clevbraintechnologies.com/Game/Webserices/public/api/img?img_url="+file);

    var jsonDate = json.encode(date.body);

    print(jsonDate);

*/
/*    for (var i in jsonDate) {
      Album model = new Album(i["Msg"], i["img_url"],i['Status']
      );
      setState(() {
        _futureAlbumlist.add(model);
      });
    }
    print(_futureAlbumlist.length);*//*

  }
*/


  UploadImage() async {
    setState(() {
      Isloading=true;
    });
    var weblink="http://clevbraintechnologies.com/Game/Webserices/public/api/img";
    FormData formData=FormData.fromMap({});

    formData.files.add(MapEntry(
      "img_url",
      await MultipartFile.fromFile(_imageFile.path,filename: "Image.jpeg"),
    ));
    print(formData.files);

    Dio dio = new Dio();

    var resp = await dio.post(weblink, data: formData);
    print(weblink);
    print(jsonEncode(resp.data));

    var Data = jsonDecode(jsonEncode(resp.data))["Data"];
    var msg = Data["Msg"];
    var status = Data["Status"].toString();
    if(status=="200"){
      setState(() {
        Isloading=false;
      });
    }
    print(status);
    print(msg);
  }


  Widget _buildImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile);
    } else {
      return Text('Take an image to start', style: TextStyle(fontSize: 18.0));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(child: Stack(
            children: <Widget>[
              Center(
                  child: _buildImage()
              ),
              Isloading?
              Center(
                  child: SizedBox(
                    height: 80,
                    width: 80,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                    ),
                  )
              ):Container()
            ],
          )),
          _buildButtons(),
          Container(
            height: 80,
            width: double.maxFinite,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                RaisedButton(
                  color: Colors.green,
                  onPressed: (){
                    if (_imageFile != null){
                      UploadImage();
                    }
                  },
                  child: Text(
                    "Upload image",
                    style: TextStyle(
                        color: Colors.white
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    return ConstrainedBox(
        constraints: BoxConstraints.expand(height: 50.0),
        child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              _buildActionButton(
                key: Key('retake'),
                text: 'Photos',
                onPressed: () => captureImage(ImageSource.gallery),
              ),
              _buildActionButton(
                key: Key('upload'),
                text: 'Camera',
                onPressed: () => captureImage(ImageSource.camera),
              ),
            ]));
  }

  Widget _buildActionButton({Key key, String text, Function onPressed}) {
    return Expanded(
      child: FlatButton(
          key: key,
          child: Text(text, style: TextStyle(fontSize: 20.0)),
          shape: RoundedRectangleBorder(),
          color: Colors.blueAccent,
          textColor: Colors.white,
          onPressed: onPressed),
    );
  }
}