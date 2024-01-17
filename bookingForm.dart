import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:partywitty_guest/Pages/Group_booking/package_about.dart';
import '../../Utils/sharepref.dart';

const List<String> list = <String>[
  'Alcoholic',
  'Non-Alcoholic',
];

class BookingForm extends StatefulWidget {
  const BookingForm({super.key});

  @override
  State<BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends State<BookingForm> {
  late List<String> upcomingDays;
  late List<String> timeSlots;
  String _selectedPackage = 'Choose';
  String _selectedChoice = 'Choose';
  String _selectedCity = 'Choose';
  int selectedCityId = -1; // Default value
  int selectedAreaId = -1; // Default value
  int selectedChoiceId = -1; // Default value
  String _selectedArea = 'Choose';

  final List<String> _package = [
    'Alcoholic',
    'Non-Alcoholic',
  ];

  List<String> _myChoice = [];
  List<String> _myCity = [];
  List<String> _myArea = [];

  List<dynamic> cityDataList = [];
  List<dynamic> areaDataList = [];
  List<dynamic> choiceDataList = [];


  List getVenueData = [];
  List<bool> checkedList = [];

  List packageResponse = [];

  String? dropdownValue;

  bool _value = true;
  bool tap = false;
  bool clickOnEdit = true;
  bool isChecked = false;
  int male = 1;
  int female = 1;
  int kid = 1;

  String? timeSlot;



  List<String> tempVenueList = [];
  List<String> tempDateList = [];
  List<String> tempPartyTimeList = [];

  @override
  void initState() {
    super.initState();
    upcomingDays = getUpcomingDays();
    timeSlots = generateTimeSlots();
    getVenueDataTypes();
    getCityData();
    fetchData2();

  }

  Future<void> fetchData2() async {
    final response = await post(
      Uri.parse("https://partywitty.com/master/APIs/ClubPackage/allPackages"),
    );
    Map data = jsonDecode(response.body);
    // print("data$data");
    if (response.statusCode == 200) {
      //loader.value = false;
      packageResponse = data["data"];
      debugPrint('found packageData:\n${response.body}');
      // final jsonData = json.decode(response.body);
      // final apiResponseObject = PackageModelResponse.fromJson(jsonData);
      setState(() {
        packageResponse = data["data"];
        // packageResponse = apiResponseObject;
        print(packageResponse);
      });
      print(data);
    } else {
      debugPrint('Not found packageData:\n${response.body}');
      throw Exception('Failed to load post');
    }
  }

  Future<void> getVenueDataTypes() async {
    final response = await get(
      Uri.parse("https://partywitty.com/master/APIs/ClubPackage/getVenuType"),
    );
    Map data = jsonDecode(response.body);
    // print("data$data");
    print(response.body);
    if (response.statusCode == 200) {
      print('Data List Found:\n${response.body}');
      getVenueData = data["data"];
      debugPrint('found packageData:\n${response.body}');
      // final jsonData = json.decode(response.body);
      // final apiResponseObject = PackageModelResponse.fromJson(jsonData);
      setState(() {
        getVenueData = data["data"];
        checkedList = List.generate(getVenueData.length, (index) => false);
        print(getVenueData);
      });
    } else {
      debugPrint('Not found packageData:\n${response.body}');
      throw Exception('Failed to load post');
    }
  }

  Future<void> getMyChoiceData() async {
    try {
      final response = await http.post(
        Uri.parse('https://partywitty.com/master/APIs/ClubPackage/getChoice'),
        body: {
          'type': _selectedPackage,
          'user_id': '2',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
           choiceDataList = responseData['data'];

          // Access data from the second index
          if (choiceDataList.length >= 2) {
            final Map<String, dynamic> dataFromSecondIndex = choiceDataList[1];

            // Access individual properties
            final String id = dataFromSecondIndex['id'].toString();
            final String name = dataFromSecondIndex['name'].toString();

            // Use id and name as needed
            print('ID from second index: $id');
            print('Name from second index: $name');

            // Update _locations list
            setState(() {
              _myChoice =
                  choiceDataList.map((item) => item['name'].toString()).toList();
            });
          } else {
            print('Not enough elements in the data array');
          }
        } else {
          print('Data not found');
        }
      } else {
        // Handle other response status codes
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or request-related errors
      print('Error fetching data: $e');
    }
  }

  Future<void> getAreaData(int selectedCityId) async {
    try {
      final response = await http.post(
        Uri.parse('https://partywitty.com/master/APIs/Common/cityWiseArea'),
        body: {
          'city_id': selectedCityId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          areaDataList = responseData['data'];

          if (areaDataList.isNotEmpty) {
            setState(() {
              _myArea =
                  areaDataList.map((item) => item['name'].toString()).toList();
            });
          } else {
            print('No areas found for the selected city');
          }
        } else {
          print('Data not found');
        }
      } else {
        // Handle other response status codes
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or request-related errors
      print('Error fetching data: $e');
    }
  }

  Future<void> getCityData() async {
    try {
      final response = await get(
        Uri.parse('https://partywitty.com/master/APIs/Common/getAvailableCity'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true) {
          cityDataList = responseData['data'];

          if (cityDataList.length >= 2) {
            // Access data from the second index
            final Map<String, dynamic> dataFromSecondIndex = cityDataList[1];

            // Access individual properties
            final String id = dataFromSecondIndex['id'].toString();
            final String name = dataFromSecondIndex['name'].toString();

            // Use id and name as needed
            print('ID from second index: $id');
            print('Name from second index: $name');

            // Update _locations list
            setState(() {
              _myCity =
                  cityDataList.map((item) => item['name'].toString()).toList();
            });
          } else {
            print('Not enough elements in the data array');
          }
        } else {
          print('Data not found');
        }
      } else {
        // Handle other response status codes
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or request-related errors
      print('Error fetching data: $e');
    }
  }

  Future<void> submitData() async {
    try {
      final response = await http.post(
        Uri.parse('https://partywitty.com/master/APIs/ClubPackage/submitEnquiry'),
        body: {
          'user_id': '2',
          'venue_type[]': listToString(tempVenueList),
          'lead_source': 'App Links',
          'city_id': selectedCityId.toString(),
          'area_id': selectedAreaId.toString(),
          'male': male.toString(),
          'female': female.toString(),
          'kids': kid.toString(),
          'party_date': 'listToString(tempDateList)',
          'party_time': 'listToString(tempPartyTimeList)',
          'type': _selectedPackage,
          'my_choice': selectedChoiceId.toString(),
          'whatsapp_msg': true.toString(),
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == true) {
          print('SubmitData\n');
          Get.to(PackAbout);
        } else {
          print('Data not found');
        }
      } else {
        // Handle other response status codes
        print('Failed to fetch data: ${response.statusCode}');
      }
    } catch (e) {
      // Handle network or request-related errors
      print('Error Post data: $e');
    }
  }

  String listToString(List<dynamic> list) {
    return list.map((item) => item.toString()).toList().join(',');
  }


  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF141420),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: InkWell(
        onTap: () {
          setState(() {
            submitData();
          });
        },
        child: Container(
          width: width,
          height: 56,
          decoration: ShapeDecoration(
            color: Color(0xFFFD2F71),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Row(
                children: [
                  Text(
                    'Submit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  RotationTransition(
                      turns: new AlwaysStoppedAnimation(9 / 12),
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white,
                      ))
                ],
              ),
            ],
          ),
        ),
      ),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF141420),
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Party Package',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Color(0xFFEEEEEE),
            fontSize: 18,
            fontFamily: 'Krona One',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Plan Your Party',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  letterSpacing: 2,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Column(
                children: [
                  FittedBox(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 55,
                          height: 55,
                          //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: ShapeDecoration(
                            color: Color(0xFF292438),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assest/planpart1.png',
                              scale: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Container(
                              height: 2, width: 50, color: Color(0xFF1EBE92)),
                        ),
                        Container(
                          width: 55,
                          height: 55,
                          //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: ShapeDecoration(
                            color: Color(0xFF292438),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assest/planpart2.png',
                              scale: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Container(
                              height: 2, width: 50, color: Color(0xFF1EBE92)),
                        ),
                        Container(
                          width: 55,
                          height: 55,
                          //padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: ShapeDecoration(
                            color: Color(0xFF292438),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(90),
                            ),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assest/planpart3.png',
                              scale: 1,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Share your Part\nRequirment',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'MAY THE BEST\nBID WIN!!!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Text(
                          'Book Now and\nPay Later',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Open Sans',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(5.0), // Adjust the value as needed
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Choose your venue type ?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 120,
                            child: getVenueData.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: getVenueData.length,
                                    itemBuilder: (context, index) {
                                      final data = getVenueData[index];
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0,
                                                bottom: 16.0,
                                                right: 16.0),
                                            child: Container(
                                              width: 85,
                                              height: 74,
                                              decoration: BoxDecoration(
                                                color:
                                                tempVenueList
                                          .contains(
                                      data['id'])
                                                        ? Color(0x3FD71362)
                                                        : Colors.transparent,
                                                border: Border.all(
                                                  color: tempVenueList
                                                      .contains(
                                                      data['id'])
                                                      ? Color(
                                                      0xFFFD2F71)
                                                      : Colors.white,
                                                  width: 0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Checkbox(
                                                    checkColor: Colors.white,
                                                    fillColor:
                                                        MaterialStateProperty
                                                            .resolveWith(
                                                                getColor),
                                                    value: checkedList[index],
                                                    onChanged: (bool? value) {

                                                      setState(() {
                                                        checkedList[index] =
                                                        value!;
                                                        if (tempVenueList.contains(
                                                            data['id'])) {
                                                          tempVenueList.remove(
                                                              data['id']);
                                                        } else {
                                                          tempVenueList.add(
                                                              data['id']);
                                                        }
                                                      });
                                                      print('tempVenueList\n');
                                                      print(
                                                          tempVenueList.toString());

                                                    },
                                                  ),
                                                  SizedBox(
                                                    height: 25,
                                                    width: 80,
                                                    child: Text(
                                                      data['name'] ?? "Na",
                                                      textAlign:
                                                          TextAlign.center,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 10,
                                                        fontFamily: 'Poppins',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Date of the Party',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 130,
                            child: packageResponse.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: upcomingDays.length,
                                    itemBuilder: (context, index) {
                                      String day = DateFormat('EEE').format(
                                          DateTime.now()
                                              .add(Duration(days: index)));
                                      String monthDate = DateFormat('MMM d')
                                          .format(DateTime.now()
                                              .add(Duration(days: index)));
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0,
                                                bottom: 16.0,
                                                right: 16.0),
                                            child: Container(
                                              width: 100,
                                              height: 70,
                                              decoration: ShapeDecoration(
                                                color: tempDateList.contains(
                                                        "$day,$monthDate")
                                                    ? const Color(0x3FD71362)
                                                    : Colors
                                                        .transparent, // Background color
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 0.50,
                                                    color: tempDateList.contains(
                                                            "$day,$monthDate")
                                                        ? const Color(
                                                            0xFFFD2F71)
                                                        : Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (tempDateList.contains(
                                                        "$day,$monthDate")) {
                                                      tempDateList.remove(
                                                          "$day,$monthDate");
                                                    } else {
                                                      tempDateList.add(
                                                          "$day,$monthDate");
                                                    }
                                                  });
                                                  print('tempDateList\n');
                                                  print(
                                                      tempDateList.toString());
                                                },
                                                child: Center(
                                                  child: Text(
                                                    "$day\n ${monthDate}",
                                                    maxLines: 2,
                                                    // 'Today',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'Party Time',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              Spacer(),
                            ],
                          ),
                          SizedBox(
                            height: 130,
                            child: packageResponse.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: timeSlots.length,
                                    itemBuilder: (context, index) {
                                      String timeslot = timeSlots[index];
                                      return Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 16.0,
                                                bottom: 16.0,
                                                right: 16.0),
                                            child: Container(
                                              width: 100,
                                              height: 70,
                                              decoration: ShapeDecoration(
                                                color: tempPartyTimeList
                                                        .contains(timeslot)
                                                    ? const Color(0x3FD71362)
                                                    : Colors.transparent,
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 0.50,
                                                    color: tempPartyTimeList
                                                            .contains(timeslot)
                                                        ? const Color(
                                                            0xFFFD2F71)
                                                        : Colors.white,
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                              ),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    if (tempPartyTimeList
                                                        .contains(timeslot)) {
                                                      tempPartyTimeList
                                                          .remove(timeslot);
                                                    } else {
                                                      tempPartyTimeList
                                                          .add(timeslot);
                                                    }
                                                  });
                                                  print('tempPartyTimeList\n');
                                                  print(tempPartyTimeList
                                                      .toString());
                                                },
                                                child: Center(
                                                  child: Text(
                                                    timeslot,
                                                    maxLines: 2,
                                                    // 'Today',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 12,
                                                      fontFamily: 'Poppins',
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  )
                                : CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        height: 0.5,
                        color: Colors.grey[900],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Male',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w400,
                                  height: 0.09,
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Color(0x3FD71362),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 0.50, color: Color(0xFFFD2F71)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // Ensure male is always at least 1
                                          male = male > 1 ? male - 1 : 1;
                                        });
                                      },
                                      child: Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/43/43625.png",
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      male.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 0.10,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // Increment male
                                          male++;
                                        });
                                      },
                                      child: Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/2997/2997933.png",
                                        scale: 9,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Female',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w400,
                                  height: 0.09,
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Color(0x3FD71362),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 0.50, color: Color(0xFFFD2F71)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // Ensure male is always at least 1
                                          female = female > 1 ? female - 1 : 1;
                                        });
                                      },
                                      child: Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/43/43625.png",
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      female.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 0.10,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // Increment male
                                          female++;
                                        });
                                      },
                                      child: Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/2997/2997933.png",
                                        scale: 9,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 14,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Kids @600',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Helvetica',
                                  fontWeight: FontWeight.w400,
                                  height: 0.09,
                                ),
                              ),
                              Container(
                                width: 90,
                                height: 30,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 10),
                                clipBehavior: Clip.antiAlias,
                                decoration: ShapeDecoration(
                                  color: Color(0x3FD71362),
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                        width: 0.50, color: Color(0xFFFD2F71)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // Ensure male is always at least 1
                                          kid = kid > 1 ? kid - 1 : 1;
                                        });
                                      },
                                      child: Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/43/43625.png",
                                        color: Colors.red,
                                      ),
                                    ),
                                    Text(
                                      kid.toString(),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                        height: 0.10,
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() {
                                          // Increment male
                                          kid++;
                                        });
                                      },
                                      child: Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/2997/2997933.png",
                                        scale: 9,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Divider(
                        height: 0.5,
                        color: Colors.grey[900],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Package Type',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromRect(
                                      details.globalPosition & Size(1, 1),
                                      Offset.zero & MediaQuery.of(context).size,
                                    ),
                                    items: _package.map((location) {
                                      return PopupMenuItem<String>(
                                        value: location,
                                        child: Text(location),
                                      );
                                    }).toList(),
                                  ).then((value) {
                                    if (value != null) {
                                      setState(() {
                                        _selectedPackage = value;
                                        getMyChoiceData();
                                      });
                                    }
                                  });
                                },
                                child: Container(
                                  width: 110,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: isChecked == false
                                        ? Colors.transparent
                                        : Color(0x3FD71362), // Background color
                                    border: Border.all(
                                      color: isChecked == false
                                          ? Colors.white
                                          : Colors.red, // Border color
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        3), // Optional: Border radius
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedPackage,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/318/318426.png",
                                        scale: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Choice',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromRect(
                                      details.globalPosition & Size(1, 1),
                                      Offset.zero & MediaQuery.of(context).size,
                                    ),
                                    items: _myChoice.map((location) {
                                      return PopupMenuItem<String>(
                                        value: location,
                                        child: Text(location),
                                      );
                                    }).toList(),
                                  ).then((value) {
                                    if (value != null) {
                                      // Find the index of the selected city
                                      int selectedIndex =
                                      _myChoice.indexOf(value);

                                      // Get the ID corresponding to the selected city
                                      int choiceId = int.parse(
                                          choiceDataList[selectedIndex]['id']
                                              .toString());

                                      setState(() {
                                        _selectedChoice = value;
                                        selectedChoiceId = choiceId;
                                      });
                                      print(selectedChoiceId.toString());
                                    }
                                    // if (value != null) {
                                    //   setState(() {
                                    //     _selectedChoice = value;
                                    //   });
                                    // }
                                  });
                                },
                                child: Container(
                                  width: 110,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: isChecked == false
                                        ? Colors.transparent
                                        : Color(0x3FD71362), // Background color
                                    border: Border.all(
                                      color: isChecked == false
                                          ? Colors.white
                                          : Colors.red, // Border color
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        3), // Optional: Border radius
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: 60,
                                        child: Text(
                                          _selectedChoice,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ),
                                      Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/318/318426.png",
                                        scale: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'City',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromRect(
                                      details.globalPosition & Size(1, 1),
                                      Offset.zero & MediaQuery.of(context).size,
                                    ),
                                    items: _myCity.map((location) {
                                      return PopupMenuItem<String>(
                                        value: location,
                                        child: Text(location),
                                      );
                                    }).toList(),
                                  ).then((value) {
                                    if (value != null) {
                                      // Find the index of the selected city
                                      int selectedIndex =
                                          _myCity.indexOf(value);

                                      // Get the ID corresponding to the selected city
                                      int CityId = int.parse(
                                          cityDataList[selectedIndex]['id']
                                              .toString());

                                      setState(() {
                                        _selectedArea = 'Choose';
                                        _selectedCity = value;
                                        selectedCityId = CityId;
                                        getAreaData(selectedCityId);
                                      });
                                      print(selectedCityId.toString());
                                    }
                                  });
                                },
                                child: Container(
                                  width: 110,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: isChecked == false
                                        ? Colors.transparent
                                        : Color(0x3FD71362), // Background color
                                    border: Border.all(
                                      color: isChecked == false
                                          ? Colors.white
                                          : Colors.red, // Border color
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        3), // Optional: Border radius
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedCity,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/318/318426.png",
                                        scale: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Area',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              GestureDetector(
                                onTapDown: (TapDownDetails details) {
                                  showMenu(
                                    context: context,
                                    position: RelativeRect.fromRect(
                                      details.globalPosition & Size(1, 1),
                                      Offset.zero & MediaQuery.of(context).size,
                                    ),
                                    items: _myArea.map((location) {
                                      return PopupMenuItem<String>(
                                        value: location,
                                        child: Text(location),
                                      );
                                    }).toList(),
                                  ).then((value) {
                                    if (value != null) {
                                      // Find the index of the selected area
                                      int selectedIndex =
                                      _myArea.indexOf(value);

                                      // Get the ID corresponding to the selected city
                                      int AreaId = int.parse(
                                          cityDataList[selectedIndex]['id']
                                              .toString());

                                      setState(() {
                                        _selectedArea = value;
                                        selectedAreaId = AreaId;
                                      });
                                      print(selectedAreaId.toString());
                                    }
                                  });
                                },
                                child: Container(
                                  width: 110,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    color: isChecked == false
                                        ? Colors.transparent
                                        : Color(0x3FD71362), // Background color
                                    border: Border.all(
                                      color: isChecked == false
                                          ? Colors.white
                                          : Colors.red, // Border color
                                      width: 0.5, // Border width
                                    ),
                                    borderRadius: BorderRadius.circular(
                                        3), // Optional: Border radius
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        _selectedArea,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      Image.network(
                                        "https://cdn-icons-png.flaticon.com/128/318/318426.png",
                                        scale: 12,
                                        color: Colors.white,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(5.0), // Adjust the value as needed
                ),
                child: Column(
                  children: [
                    Column(
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                top: 20.0,
                                left: 16.0,
                                right: 16.0,
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    'Term and Conditions',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Spacer(),
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '1.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.normal),
                                      ),
                                      Expanded(
                                        child: Text(
                                          ' The package cannot be combined with any other offers, discounts, packages, and/or combos extended by PartyWitty or any other third party."',
                                          maxLines: 2,
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.normal),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              child: Container(
                width: width,
                height: 150,
                color: Colors.grey[900],
                child: Container(
                  width: 110,
                  height: 35,
                  decoration: BoxDecoration(
                    color: Colors.transparent, // Background color
                    // Optional: Border radius
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SizedBox(
                      width: 500,
                      height: 400,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(5),
                            ), //BoxDecoration

                            /** CheckboxListTile Widget **/
                            child: CheckboxListTile(
                              title: Text(
                                'Allow comunication on whatsapp',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  clickOnEdit == true
                                      ? const Text(
                                          '9876543210',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                        )
                                      : TextField(
                                          decoration: InputDecoration(
                                            labelText: 'Edit Number',
                                            labelStyle: TextStyle(
                                                color: Colors.pink,
                                                fontSize: 12,
                                                fontWeight: FontWeight.normal),
                                            border: OutlineInputBorder(),
                                          ),
                                        ),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Text(
                                    'Edit Number',
                                    style: TextStyle(
                                        color: Colors.pink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                              secondary: Image.asset(
                                'assest/whatsapp2.png',
                                scale: 15,
                              ),
                              autofocus: false,
                              activeColor: Colors.pink,
                              checkColor: Colors.white,
                              selected: _value,
                              value: _value,
                              onChanged: (value) {
                                setState(() {
                                  _value = value!;
                                  clickOnEdit == _value;
                                });
                              },
                            ), //CheckboxListTile
                          ), //Container
                        ), //Padding
                      ), //Center
                    ), //SizedB
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> generateTimeSlots() {
    List<String> timeSlots = [];

    for (int i = 12; i < 24; i++) {
      String formattedHour = i.toString().padLeft(2, '0');
      String timeSlot = '$formattedHour:00 - ${(i + 1) % 24}:00';
      timeSlots.add(timeSlot);
    }

    return timeSlots;
  }

  List<String> getUpcomingDays() {
    List<String> days = [];
    DateTime now = DateTime.now();

    for (int i = 0; i < 7; i++) {
      DateTime nextDay = now.add(Duration(days: i));
      String formattedDay = DateFormat('EEEE, MMM d').format(nextDay);
      days.add(formattedDay);
    }
    return days;
  }

}
