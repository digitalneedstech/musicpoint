import 'package:cached_network_image/cached_network_image.dart';

class CustomImageProvider {
  static CachedNetworkImageProvider cachedImage(String imageUrl) {
    return CachedNetworkImageProvider(imageUrl);
  }
}
