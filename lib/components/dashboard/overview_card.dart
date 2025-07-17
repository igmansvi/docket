import 'package:flutter/material.dart';

class OverviewCard extends StatelessWidget {
  const OverviewCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.blue.withOpacity(0.06), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 180, child: Center(child: _DonutChart())),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _LegendDot(color: Colors.blue, label: 'Pending'),
              _LegendDot(color: Colors.orange, label: 'Approved'),
              _LegendDot(color: Colors.red, label: 'Rejected'),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: 18,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[200]!),
              backgroundColor: Colors.blue[50],
            ),
          ),
          SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(painter: _DonutPainter()),
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18;
    final rect = Offset.zero & size;
    paint.color = Colors.blue;
    canvas.drawArc(rect, -1.57, 2, false, paint);
    paint.color = Colors.orange;
    canvas.drawArc(rect, 0.43, 1, false, paint);
    paint.color = Colors.red;
    canvas.drawArc(rect, 1.43, 0.7, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(color: Colors.blueGrey)),
      ],
    );
  }
}
