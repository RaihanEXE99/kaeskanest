import 'package:Kaeskanest/pages/navbar/property.dart';
import 'package:flutter/material.dart';

Column PropertyCard(BuildContext context, ppt) {
    return Column(
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          clipBehavior: Clip.antiAliasWithSaveLayer,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Column(
                children: [
                  Image.asset(
                    "assets/img/cardimage.jpg",
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 15, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ppt["price_unit"]+" "+ppt["price"].toString()+ ppt['price_type'],
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey[800],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                const Icon(Icons.map_outlined),
                                Text(
                                  ppt['address']['country'],
                                  maxLines: 1,
                                  overflow: TextOverflow.fade,
                                  softWrap: false,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.maps_home_work_sharp),
                            const SizedBox(width: 10,),
                            Expanded(
                              child: Text(
                                ppt['title'],
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.grey[700],
                                  fontWeight:FontWeight.w500
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(height: 10),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined),
                            Expanded(
                              child: Text(
                                "Area: "+ppt['loc'],
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(height: 15),
                        Padding(
                          padding: const EdgeInsets.only(left:2),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.bed_outlined),
                                  Text(
                                    "Beds: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ppt['details']['bed'].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.bathtub_outlined,size: 20),
                                  Text(
                                    "Baths: ",
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  Text(
                                    ppt['details']['bath'].toString(),
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(Icons.square_foot_outlined,),
                                  Text(
                                    "${ppt['details']['size']} "+ppt['details']['size_unit'],
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Add a row with two buttons spaced apart and aligned to the right side of the card
                        Container(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            // Add a text button labeled "SHARE" with transparent foreground color and an accent color for the text
                            ElevatedButton.icon(
                              icon: const Icon(
                                Icons.timelapse,
                                color: Colors.black54,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0.0,
                                shadowColor: Colors.transparent,
                                backgroundColor: Colors.white,
                              ),
                              label: Text(
                                ppt['date'].substring(0, 10),
                                style: const TextStyle(
                                  color: Colors.black54
                                  ),
                              ),
                              onPressed: () {},
                            ),
                            // Add a text button labeled "EXPLORE" with transparent foreground color and an accent color for the text
                            ElevatedButton.icon(
                              icon: const Icon(Icons.more_horiz_rounded),
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primary,
                              ),
                              label: const Text(
                                "Details",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetails(propertyID: ppt["sku"]),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20,)
      ],
    );
  }
