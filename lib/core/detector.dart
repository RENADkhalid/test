export 'detector_interface.dart' show SignDetector;

// Use an alias for the conditional import so the factory name exists.
// On web => imports detector_web.dart; on IO platforms => detector_io.dart.
import 'detector_web.dart'
    if (dart.library.io) 'detector_io.dart' as impl;

import 'detector_interface.dart';

// Public factory for the rest of your app.
SignDetector createSignDetector() => impl.createDetectorImpl();
