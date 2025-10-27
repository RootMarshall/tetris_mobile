import 'package:flutter/material.dart';
import '../constants.dart';

class CountdownOverlay extends StatefulWidget {
  final VoidCallback onComplete;

  const CountdownOverlay({
    Key? key,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<CountdownOverlay> createState() => _CountdownOverlayState();
}

class _CountdownOverlayState extends State<CountdownOverlay>
    with SingleTickerProviderStateMixin {
  int countdown = 3;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _startCountdown();
  }

  void _startCountdown() {
    _animationController.forward(from: 0);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (countdown > 1) {
          setState(() {
            countdown--;
          });
          _startCountdown();
        } else {
          // Show "GO!" for a moment then complete
          setState(() {
            countdown = 0;
          });
          _animationController.forward(from: 0);
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              widget.onComplete();
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: 1.0 - (_animationController.value * 0.3),
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: boardColor.withOpacity(0.9),
                    border: Border.all(
                      color: countdown > 0 ? Colors.cyan.shade400 : Colors.green.shade400,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (countdown > 0 ? Colors.cyan : Colors.green).withOpacity(0.5),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Text(
                    countdown > 0 ? countdown.toString() : 'GO!',
                    style: TextStyle(
                      color: countdown > 0 ? Colors.cyan.shade300 : Colors.green.shade300,
                      fontSize: countdown > 0 ? 120 : 80,
                      fontWeight: FontWeight.bold,
                      letterSpacing: countdown > 0 ? 0 : 8,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

