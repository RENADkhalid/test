class BBox {
  final double l; // left (x)
  final double t; // top (y)
  final double w; // width
  final double h; // height;

  const BBox({required this.l, required this.t, required this.w, required this.h});
}

class Detection {
  final String label; // class name
  final double score; // confidence 0..1
  final BBox bbox;

  const Detection({required this.label, required this.score, required this.bbox});
}
