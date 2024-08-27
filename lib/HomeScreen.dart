import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';


class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  Position? _currentPosition;
  bool _locationEnabled = false;
  String? locationadress;

  @override
  void initState() {
    super.initState();
    _showLocationDialog();
  }

  void _showLocationDialog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Permission'),
            content: const Text('Allow location access to enhance your experience.'),
            actions: <Widget>[
              Column(
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      getpostion();
                      Navigator.of(context).pop();
                    },
                    child: const Text("Allow"),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text("Deny"),
                  ),
                ],
              ),
            ],
          );
        },
      );
    });
  }

  Future<void> getpostion() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
    
      return;
    }

    // Check for permission status
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try requesting permissions again
      
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
     
      return;
    }

    // When permissions are granted, fetch the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _locationEnabled=true;
      _currentPosition = position;
    });
    getAddress(_currentPosition);

  }
Future<void> getAddress(Position? currentPosition) async {
  if (currentPosition == null) {
    setState(() {
      locationadress = "Unable to fetch location.";
    });
    return;
  }

  try {
    // Use List<Placemark> instead of dynamic List
    List<Placemark> placemarks = await placemarkFromCoordinates(
      currentPosition.latitude,
      currentPosition.longitude,
    );

    // Ensure the placemarks list is not null and has elements
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      setState(() {
        locationadress =
            "${place.street ?? 'No street'}, ${place.locality ?? 'No locality'}, ${place.postalCode ?? 'No postal code'}, ${place.country ?? 'No country'}";
      });
    } else {
      setState(() {
        locationadress = "No address available for the location.";
      });
    }
  } catch (e) {
    print("Error fetching address: $e");
    setState(() {
      locationadress = "Unable to fetch address.";
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("User Location"),
        centerTitle: true,
      ),
      body: Center(
        child: _locationEnabled
            ? _currentPosition != null
                ? Column(
                  children: [
                    Text(
                        "Latitude: ${_currentPosition!.latitude}, Longitude: ${_currentPosition!.longitude}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(  locationadress ?? "Loading address...")
                  ],
                )
                
                : const CircularProgressIndicator() // Display a loading indicator while fetching the location
            : const Text("Location access denied or services are disabled"),
      ),
    );
  }
}
