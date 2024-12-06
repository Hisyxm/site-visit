import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'location_service.dart';

class SiteVisit extends StatefulWidget {
  @override
  _SiteVisitState createState() => _SiteVisitState();
}

class _SiteVisitState extends State<SiteVisit> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  String? _selectedSiteType;
  TextEditingController _locationController = TextEditingController();
  TextEditingController _addressController = TextEditingController();
  TextEditingController _objectiveController = TextEditingController();
  TextEditingController _remarkController = TextEditingController();
  List<File> _imageFiles = [];

  List<String> _siteTypes = [
    "Scheduled",
    "Impromptu",
    "Recurring",
    "Ad Hoc",
    "Remote",
    "Unannounced",
    "Compliance",
    "Safety",
  ];

  Map<String, String> _siteDescriptions = {
    "Scheduled": "Preplanned visits with a set date and time, allowing for adequate preparation.",
    "Impromptu": "Spontaneous visits that occur without prior planning, often in response to urgent needs.",
    "Recurring": "Regularly scheduled visits at predetermined intervals, such as daily, weekly, or monthly.",
    "Ad Hoc": "Arranged on an as-needed basis, without a fixed schedule.",
    "Remote": "Inspection or assessment conducted without physical presence, using technology like drones or cameras.",
    "Unannounced": "Visits conducted without prior notification, often for surprise inspections.",
    "Compliance": "Visits to ensure adherence to specific rules, regulations, or industry standards.",
    "Safety": "Focused on evaluating and enhancing safety.",
  };

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();
      setState(() {
        _currentPosition = position;
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      setState(() {
        _currentPosition = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _showVisitTypeDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Type",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _siteTypes.map((type) {
                return ListTile(
                  title: Text(
                    type,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    _siteDescriptions[type]!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () {
                    setState(() {
                      _selectedSiteType = type;
                    });
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickImage() async {
    PermissionStatus status = await Permission.camera.request();
    if (status.isGranted) {
      final ImagePicker _picker = ImagePicker();
      final XFile? pickedFile =
      await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _imageFiles.add(File(pickedFile.path));
        });
      } else {
        print("No image selected");
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Camera permission is required to take a photo")),
      );
    }
  }

  void _submitForm() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        );
      },
    );

    await Future.delayed(Duration(seconds: 3));

    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Form submitted successfully",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => SystemNavigator.pop(),
        ),
        title: Text('Site Visit', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.grey,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.home_work, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Visit Type",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showVisitTypeDialog,
              child: Text(
                _selectedSiteType ?? 'Select Visit Type',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.grey.shade300,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),
            _buildField("Location", Icons.place, _locationController),
            SizedBox(height: 10),
            _buildField("Address", Icons.location_city, _addressController),
            SizedBox(height: 10),
            _buildField("Objective", Icons.edit, _objectiveController),
            SizedBox(height: 10),
            _buildField("Remark", Icons.comment, _remarkController),
            SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 2),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    offset: Offset(0, 3),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _currentPosition == null
                    ? Center(child: CircularProgressIndicator())
                    : SizedBox(
                  height: 200,
                  child: GoogleMap(
                    onMapCreated: (controller) =>
                    _mapController = controller,
                    initialCameraPosition: CameraPosition(
                      target: LatLng(_currentPosition!.latitude,
                          _currentPosition!.longitude),
                      zoom: 15,
                    ),
                    markers: {
                      if (_currentPosition != null)
                        Marker(
                          markerId: MarkerId('currentLocation'),
                          position: LatLng(_currentPosition!.latitude,
                              _currentPosition!.longitude),
                          infoWindow:
                          InfoWindow(title: "Current Location"),
                        ),
                    },
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.attach_file, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  "Attachment",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
              ],
            ),
            SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1,
              ),
              itemCount: _imageFiles.length + 1,
              itemBuilder: (context, index) {
                if (index < _imageFiles.length) {
                  return GestureDetector(
                    onTap: () {},
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _imageFiles[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else {
                  return GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.green,
                        size: 40,
                      ),
                    ),
                  );
                }
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitForm,
              child: Text(
                "SUBMIT",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                backgroundColor: Colors.green,
                textStyle: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
      String label, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.green),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.green),
        ),
      ),
    );
  }
}
