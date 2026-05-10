import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sliding_up_panel/sliding_up_panel_widget.dart';
import 'package:flutter_zoom_drawer/config.dart';
import 'package:flutter_zoom_drawer/flutter_zoom_drawer.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:inatel_app_challenge/models/request.dart';
import 'package:inatel_app_challenge/widgets/map_controls.dart';
import 'package:sizer/sizer.dart';
import '../core/core.dart';
import '../helpers/dblogics.dart';
import 'package:inatel_app_challenge/utils/reusable_functions.dart';
import '../models/plan.dart';
import 'package:provider/provider.dart';
import '../providers/permission_provider.dart';

class HomeInstaller extends StatefulWidget {
  const HomeInstaller({Key? key}) : super(key: key);

  @override
  State<HomeInstaller> createState() => _HomeInstallerState();
}

class _HomeInstallerState extends State<HomeInstaller> {
  late GoogleMapController mapController;
  late String _mapStyle;
  late Position position;
  final DataRepository repository = DataRepository();
  final SlidingUpPanelController _panelController = SlidingUpPanelController();
  List<RequestInstaller> request = [];
  late String username;
  bool onRequest = false;
  late RequestInstaller selected;
  late Set<Marker> markers = {};
  final ZoomDrawerController _drawerController = ZoomDrawerController();

  // List of coordinates to join
  List<LatLng> polylineCoordinates = [];

  // Map storing polylines created by connecting two points
  Map<PolylineId, Polyline> polylines = {};

  // Create the polylines for showing the route between two places
  _createPolylines(
    double startLatitude,
    double startLongitude,
    double destinationLatitude,
    double destinationLongitude,
  ) async {
    polylines = {};
    polylineCoordinates = [];

    const googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');
    if (googleMapsApiKey.isNotEmpty) {
      polylineCoordinates = await _fetchRoutePolyline(
        googleMapsApiKey,
        LatLng(startLatitude, startLongitude),
        LatLng(destinationLatitude, destinationLongitude),
      );
    }

    if (polylineCoordinates.isEmpty) {
      polylineCoordinates.addAll([
        LatLng(startLatitude, startLongitude),
        LatLng(destinationLatitude, destinationLongitude),
      ]);
    }

    // Defining an ID
    PolylineId id = const PolylineId('poly');

    // Initializing Polyline
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.redAccent,
      points: polylineCoordinates,
      width: 3,
    );

    // Adding the polyline to the map
    polylines[id] = polyline;

    setState(() {});

    zoomPolyline(polylineCoordinates);
  }

  Future<List<LatLng>> _fetchRoutePolyline(
    String apiKey,
    LatLng origin,
    LatLng destination,
  ) async {
    final uri = Uri.https(
      'maps.googleapis.com',
      '/maps/api/directions/json',
      {
        'origin': '${origin.latitude},${origin.longitude}',
        'destination': '${destination.latitude},${destination.longitude}',
        'mode': 'driving',
        'key': apiKey,
      },
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        debugPrint('Directions API HTTP ${response.statusCode}');
        return [];
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final status = body['status'] as String?;
      if (status != 'OK') {
        debugPrint(
          'Directions API status: $status - ${body['error_message'] ?? 'No route returned'}',
        );
        return [];
      }

      final routes = body['routes'] as List<dynamic>;
      if (routes.isEmpty) return [];

      final overviewPolyline =
          routes.first['overview_polyline'] as Map<String, dynamic>?;
      final encodedPolyline = overviewPolyline?['points'] as String?;
      if (encodedPolyline == null || encodedPolyline.isEmpty) return [];

      return _decodePolyline(encodedPolyline);
    } catch (error) {
      debugPrint('Directions API error: $error');
      return [];
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    final points = <LatLng>[];
    var index = 0;
    var latitude = 0;
    var longitude = 0;

    while (index < encoded.length) {
      var shift = 0;
      var result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      latitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1f) << shift;
        shift += 5;
      } while (byte >= 0x20);

      longitude += (result & 1) != 0 ? ~(result >> 1) : result >> 1;

      points.add(LatLng(latitude / 1E5, longitude / 1E5));
    }

    return points;
  }

  void zoomPolyline(List<LatLng> coords) {
    LatLng coord = coords.elementAt(coords.length ~/ 2);
    mapController.animateCamera(
        CameraUpdate.newCameraPosition(CameraPosition(target: coord, zoom: 9)));
  }

  Future<void> _onMapCreated(
    GoogleMapController controller,
    LatLng currentLocation,
  ) async {
    mapController = controller;
    mapController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(target: currentLocation, zoom: 15),
    ));
    setState(() {
      markers
        ..clear()
        ..add(Marker(
          markerId: const MarkerId("installer-location"),
          position: currentLocation,
          icon: BitmapDescriptor.defaultMarker,
        ));
    });
  }

  @override
  initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      rootBundle.loadString('assets/style/mapStyle.json').then((string) {
        _mapStyle = string;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xFF0D1724),
        body: ZoomDrawer(
          controller: _drawerController,
          openCurve: Curves.fastOutSlowIn,
          style: DrawerStyle.defaultStyle,
          showShadow: false,
          slideWidth: 65.0.w,
          angle: 0.0,
          mainScreenTapClose: true,
          disableDragGesture: true,
          mainScreen: ChangeNotifierProvider<LocationProvider>(
            create: (_) => LocationProvider(),
            builder: (context, snapshot) {
              final locationProvider = Provider.of<LocationProvider>(context);
              if (locationProvider.status == LocationProviderStatus.Initial) {
                locationProvider.getLocation();
              }
              if (locationProvider.status == LocationProviderStatus.Error) {
                return Center(
                  child: Text(
                    "An Error Occurs",
                    style: infoColPanel,
                  ),
                );
              } else if (locationProvider.status ==
                      LocationProviderStatus.Loading ||
                  locationProvider.status == LocationProviderStatus.Initial) {
                return SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      Text(
                        "Get Location",
                        style: infoColPanel,
                      ),
                    ],
                  ),
                );
              } else {
                position = locationProvider.userLocation;
                final currentLocation = LatLng(
                  position.latitude,
                  position.longitude,
                );

                return Stack(
                  children: [
                    GoogleMap(
                      onMapCreated: (controller) => _onMapCreated(
                        controller,
                        currentLocation,
                      ),
                      myLocationEnabled: true,
                      markers: markers,
                      polylines: Set<Polyline>.of(polylines.values),
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      style: _mapStyle,
                      initialCameraPosition: CameraPosition(
                        target: currentLocation,
                        zoom: 15.0,
                      ),
                    ),

                    // Menu Button
                    Positioned(
                      top: 5.0.h,
                      left: 5.0.w,
                      child: MapFloatingButton(
                        width: 12.0.w,
                        height: 6.0.h,
                        icon: Icons.menu,
                        onPressed: () => _drawerController.open!(),
                      ),
                    ),

                    Positioned(
                        top: request.isNotEmpty ? 20.0.h : 50.0.h,
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SlidingUpPanelWidget(
                          panelController: _panelController,
                          controlHeight: 30.0.h,
                          anchor: 1,
                          child: Container(
                            padding: EdgeInsets.only(left: 7.0.w, top: 5.0.h),
                            decoration: const BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                )),
                            child: Column(
                              children: [
                                StreamBuilder<List<RequestInstaller>>(
                                    stream: repository.getStream(),
                                    builder: (context, snapshot) {
                                      request = (snapshot.data ?? [])
                                          .where(
                                              (item) => item.installerId == 37)
                                          .toList();
                                      return request.isNotEmpty
                                          ? FutureBuilder<List<Plan>>(
                                              future: Future.wait(
                                                request.map(
                                                  (item) => fetchPlansId(
                                                      item.planId.toString()),
                                                ),
                                              ),
                                              builder: (context, planSnapshot) {
                                                final plans =
                                                    planSnapshot.data ?? [];

                                                return ListView.separated(
                                                    itemCount: request.length,
                                                    shrinkWrap: true,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return Row(
                                                        children: [
                                                          SizedBox(
                                                            width: 20.0.w,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: Text(
                                                                "\$ ${calculatePrice(currentLocation, LatLng(request[index].lat, request[index].lng), "2.5")}",
                                                                style: priceBig,
                                                              ),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 40.0.w,
                                                            child: FittedBox(
                                                              fit: BoxFit
                                                                  .scaleDown,
                                                              child: RichText(
                                                                  textAlign:
                                                                      TextAlign
                                                                          .start,
                                                                  text: TextSpan(
                                                                      text:
                                                                          "Nome do Usuario \n",
                                                                      style:
                                                                          infoColPanel,
                                                                      children: [
                                                                        TextSpan(
                                                                            text: plans.length > index
                                                                                ? "${plans[index].isp} |  ${plans[index].data_capacity} GB"
                                                                                : "Loading...",
                                                                            style:
                                                                                dataExpPanel)
                                                                      ])),
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            width: 4.0.w,
                                                          ),
                                                          Expanded(
                                                            child: Row(
                                                              children: [
                                                                IconButton(
                                                                    onPressed:
                                                                        () => {
                                                                              setState(() {
                                                                                _createPolylines(currentLocation.latitude, currentLocation.longitude, request[index].lat, request[index].lng);
                                                                                onRequest = true;
                                                                                selected = request[index];
                                                                                markers.add(Marker(markerId: const MarkerId("Destination"), position: LatLng(request[index].lat, request[index].lng), icon: BitmapDescriptor.defaultMarker));
                                                                              }),
                                                                              _panelController.hide()
                                                                            },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .check,
                                                                      color: Colors
                                                                          .teal,
                                                                      size:
                                                                          7.0.w,
                                                                    )),
                                                                IconButton(
                                                                    onPressed:
                                                                        () => {
                                                                              setState(() {
                                                                                repository.deleteRequest(request[index]);
                                                                              })
                                                                            },
                                                                    icon: Icon(
                                                                      Icons
                                                                          .close,
                                                                      color: Colors
                                                                          .red,
                                                                      size:
                                                                          7.0.w,
                                                                    )),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    },
                                                    separatorBuilder:
                                                        (context, int) {
                                                      return Divider(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.3),
                                                      );
                                                    });
                                              },
                                            )
                                          : Center(
                                              child: Text("Without Requests",
                                                  style: infoColPanel),
                                            );
                                    })
                              ],
                            ),
                          ),
                        )),

                    Visibility(
                      visible: onRequest,
                      child: Positioned(
                        bottom: 2.0.h,
                        left: 5.0.w,
                        right: 5.0.w,
                        child: MapPrimaryButton(
                            label: "Done",
                            icon: Icons.check,
                            height: 5.0.h,
                            textStyle: buttonBlack,
                            onPressed: () {
                              _panelController.collapse();
                              setState(() {
                                polylines = {};
                                onRequest = false;
                                repository.deleteRequest(selected);
                                markers.remove(markers.elementAt(1));
                                CameraUpdate.newCameraPosition(CameraPosition(
                                    target: currentLocation, zoom: 15));
                              });
                            }),
                      ),
                    )
                  ],
                );
              }
            },
          ),
          menuScreen: Padding(
            padding: EdgeInsets.only(left: 2.0.w, top: 12.0.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: const Alignment(-0.9, 0),
                  child: Container(
                    width: 25.0.w,
                    height: 25.0.w,
                    decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.5),
                        shape: BoxShape.circle),
                  ),
                ),
                SizedBox(
                  height: 2.0.h,
                ),
                Align(
                  alignment: const Alignment(-0.8, 0),
                  child: Text(
                    "Nome Installer",
                    style: infoColPanel,
                  ),
                ),
                SizedBox(
                  height: 5.0.h,
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.house_alt_fill,
                      ),
                      SizedBox(
                        width: 5.0.w,
                      ),
                      const Text(
                        "Home",
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.money_dollar,
                      ),
                      SizedBox(
                        width: 5.0.w,
                      ),
                      const Text(
                        "Balance",
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.calendar,
                      ),
                      SizedBox(
                        width: 5.0.w,
                      ),
                      const Text(
                        "History",
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.profile_circled,
                      ),
                      SizedBox(
                        width: 5.0.w,
                      ),
                      const Text(
                        "Profile",
                      )
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  child: Row(
                    children: [
                      const Icon(
                        CupertinoIcons.question,
                      ),
                      SizedBox(
                        width: 5.0.w,
                      ),
                      const Text(
                        "Help",
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                      alignment: const Alignment(-0.9, 0),
                      child: TextButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                            ),
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white),
                            padding: EdgeInsets.symmetric(horizontal: 5.0.w)),
                        child: const Text(
                          "Log Out",
                        ),
                      )),
                ),
              ],
            ),
          ),
        ));
  }
}
