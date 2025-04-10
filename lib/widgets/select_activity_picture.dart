

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SelectActivityPicture extends StatefulWidget {
  final Function(String) onImageSelected;

  const SelectActivityPicture({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  State<SelectActivityPicture> createState() => _SelectActivityPictureState();
}

class _SelectActivityPictureState extends State<SelectActivityPicture> {
  List<dynamic> photos = [];
  String? selectedUrl;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    final String response = await rootBundle.loadString('assets/pexels.json');
    final data = await json.decode(response);

    List<dynamic> allPhotos = [];

    data.forEach((category, value) {
      final photos = value['pexels']['photos'] as List<dynamic>?;
      if (photos != null) {
        allPhotos.addAll(photos);
      }
    });

    setState(() {
      this.photos = allPhotos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.9),
      body: Column(
        children: [
          const SizedBox(height: 20),
          const Text(
            'Select an Image',
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              itemCount: photos.length,
              itemBuilder: (context, index) {
                final url = photos[index]['src']['medium'];
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedUrl = url;
                    });
                  },
                  child: Stack(
                    children: [
                      Image.network(url, fit: BoxFit.cover),
                      if (selectedUrl == url)
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                        )
                    ],
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            onPressed: () {
              if (selectedUrl != null) {
                widget.onImageSelected(selectedUrl!);
                Navigator.pop(context);
              }
            },
            child: const Text('Done'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}