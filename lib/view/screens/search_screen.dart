import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:geocoding/geocoding.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:login/view/screens/polygone_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {


  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onClear() {
    setState(() {
      _controller.clear();
    });
    _focusNode.unfocus();
  }

  var uuid = Uuid();
  String _seesionToken = '122344';
  List<dynamic> _placesList=[];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _controller.addListener(() {
      onChange();
    });
  }

  void onChange(){
    if(_seesionToken == null){
      setState(() {
        _seesionToken = uuid.v4();
      });
    }
    getSuggestion (_controller.text);
  }

  void getSuggestion(String input)async{
    // Billing Account API
    String kPlaces_API_KEY = "AIzaSyDQ2c_pOSOFYSjxGMwkFvCVWKjYOM9siow";
    String baseURL = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String request = '$baseURL?input=$input&key=$kPlaces_API_KEY&sessiontoken=$_seesionToken';

    var response = await http.get(Uri.parse(request));
    var data = response.body.toString();

    // print("data");
    // print(data);

    if(response.statusCode == 200){
      setState(() {
        _placesList= jsonDecode(response.body.toString())['predictions'];
      });
    }else{
      throw Exception('Failed to load');
    }

}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0),
              child: SizedBox(
                width: 400.0, // Set the width to 400
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  autofocus: true,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 17.0,
                      horizontal: 20.0,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1.0,
                      ), // remove the border
                    ),
                    hintText: 'Search...',
                    prefixIcon: IconButton(
                      icon: Icon(color: Colors.black,Icons.arrow_back),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    suffixIcon: _controller.text.isEmpty ? null : IconButton(
                      icon: Icon(color: Colors.black,Icons.clear),
                      onPressed: _onClear,
                    ),
                  ),
                  onChanged: (value) {
                    if (_seesionToken == null) {
                      setState(() {
                        _seesionToken = uuid.v4();
                      });
                    }
                    getSuggestion(value);
                  },
                ),
              ),
            ),
            if (_placesList.isNotEmpty)
            Expanded(
              child: ListView.builder(
                itemCount: _placesList.length,
                itemBuilder: (context, index) {
                  return SizedBox(
                    // width: 100, // set the width of the SizedBox to match the width of the TextFormField
                    child: ListTile(
                      tileColor: Colors.white, 
                      title: Text(_placesList[index]['description']),
                      onTap: () async{
                        List<Location> locations =
                        await locationFromAddress(_placesList[index]['description']);
                        _controller.text = _placesList[index]['description'];
                        setState(() {
                          _placesList = [];
                        });
                        Navigator.of(context).pop();
                        Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => PolygonScreen(location: locations.first),
    ),
  );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


