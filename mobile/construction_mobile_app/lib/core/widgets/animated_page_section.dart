import 'package:flutter/material.dart';



/// A fade-up entrance animation wrapper for page sections.

///

/// Wraps [child] in a staggered fade + vertical slide-up animation.

/// Use [delay] to create staggered entrances for multiple sections.

class AnimatedPageSection extends StatefulWidget {

  final Widget child;

  final Duration duration;

  final Duration delay;

  final double slideDistance;



  const AnimatedPageSection({

    super.key,

    required this.child,

    this.duration = const Duration(milliseconds: 480),

    this.delay = Duration.zero,

    this.slideDistance = 24.0,

  });



  @override

  State<AnimatedPageSection> createState() => _AnimatedPageSectionState();

}



class _AnimatedPageSectionState extends State<AnimatedPageSection>

    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  late Animation<double> _fadeIn;

  late Animation<Offset> _slideUp;



  @override

  void initState() {

    super.initState();

    _controller = AnimationController(

      vsync: this,

      duration: widget.duration,

    );



    _fadeIn = CurvedAnimation(

      parent: _controller,

      curve: const Interval(0.0, 0.65, curve: Curves.easeOut),

    );



    _slideUp = Tween<Offset>(

      begin: Offset(0, widget.slideDistance / 100),

      end: Offset.zero,

    ).animate(CurvedAnimation(

      parent: _controller,

      curve: const Interval(0.0, 0.75, curve: Curves.easeOutCubic),

    ));



    Future.delayed(widget.delay, () {

      if (mounted) _controller.forward();

    });

  }



  @override

  void dispose() {

    _controller.dispose();

    super.dispose();

  }



  @override

  Widget build(BuildContext context) {

    return FadeTransition(

      opacity: _fadeIn,

      child: SlideTransition(

        position: _slideUp,

        child: widget.child,

      ),

    );

  }

}



/// Stagger helper: returns a list of AnimatedPageSection wrappers

/// for a list of widgets with evenly spaced delays.

List<Widget> staggerAnimatedSections(

  List<Widget> children, {

  Duration baseDelay = const Duration(milliseconds: 80),

  Duration duration = const Duration(milliseconds: 480),

}) {

  return [

    for (int i = 0; i < children.length; i++)

      AnimatedPageSection(

        delay: baseDelay * i,

        duration: duration,

        child: children[i],

      ),

  ];

}



/// A staggered card entrance animation. Cards fade in and slide up

/// with a slight delay between each.

class CardStagger extends StatelessWidget {

  final List<Widget> children;

  final Duration baseDelay;

  final Duration duration;



  const CardStagger({

    super.key,

    required this.children,

    this.baseDelay = const Duration(milliseconds: 60),

    this.duration = const Duration(milliseconds: 420),

  });



  @override

  Widget build(BuildContext context) {

    return Column(

      crossAxisAlignment: CrossAxisAlignment.stretch,

      children: staggerAnimatedSections(

        children,

        baseDelay: baseDelay,

        duration: duration,

      ),

    );

  }

}

