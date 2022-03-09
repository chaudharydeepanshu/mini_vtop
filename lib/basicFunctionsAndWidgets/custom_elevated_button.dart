import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:mini_vtop/basicFunctionsAndWidgets/widget_size_limiter.dart';

class CustomElevatedButton extends StatefulWidget {
  const CustomElevatedButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    this.size,
    required this.borderRadius,
    required this.padding,
  }) : super(key: key);

  final void Function()? onPressed;
  final Widget child;
  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final Size? size;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  State<CustomElevatedButton> createState() => _CustomElevatedButtonState();
}

class _CustomElevatedButtonState extends State<CustomElevatedButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: widgetSizeProvider(
      //     fixedSize: widget.size.width + 50,
      //     sizeDecidingVariable: widget.screenBasedPixelWidth),
      height: widget.size != null
          ? widgetSizeProvider(
              fixedSize: (widget.size?.height)!,
              sizeDecidingVariable: widget.screenBasedPixelWidth)
          : null,
      child: ElevatedButton(
        style: ButtonStyle(
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          minimumSize: MaterialStateProperty.all<Size?>(
            widget.size != null
                ? Size(
                    widgetSizeProvider(
                        fixedSize: (widget.size?.height)!,
                        sizeDecidingVariable: widget.screenBasedPixelWidth),
                    widgetSizeProvider(
                        fixedSize: (widget.size?.height)!,
                        sizeDecidingVariable: widget.screenBasedPixelHeight),
                  )
                : Size.fromHeight(
                    widgetSizeProvider(
                        fixedSize: 56,
                        sizeDecidingVariable: widget.screenBasedPixelHeight),
                  ),
          ),
          // backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
          padding: MaterialStateProperty.all(EdgeInsets.symmetric(
            vertical: widgetSizeProvider(
                fixedSize: widget.padding.vertical,
                sizeDecidingVariable: widget.screenBasedPixelWidth),
            horizontal: widgetSizeProvider(
                fixedSize: widget.padding.horizontal,
                sizeDecidingVariable: widget.screenBasedPixelWidth),
          )),
          textStyle: MaterialStateProperty.all(
            getDynamicTextStyle(
                textStyle: Theme.of(context).textTheme.button,
                sizeDecidingVariable: widget.screenBasedPixelWidth),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(widget.borderRadius
                  // widgetSizeProvider(
                  //     fixedSize: 20,
                  //     sizeDecidingVariable: widget.screenBasedPixelWidth),
                  ),
            ),
          ),
        ),
        onPressed: widget.onPressed,
        child: widget.child,
      ),
    );
  }
}

class CustomTextButton extends StatefulWidget {
  const CustomTextButton({
    Key? key,
    required this.onPressed,
    required this.child,
    required this.screenBasedPixelWidth,
    required this.screenBasedPixelHeight,
    required this.size,
    required this.borderRadius,
    required this.padding,
  }) : super(key: key);

  final void Function()? onPressed;
  final Widget child;
  final double screenBasedPixelWidth;
  final double screenBasedPixelHeight;
  final Size size;
  final double borderRadius;
  final EdgeInsets padding;

  @override
  State<CustomTextButton> createState() => _CustomTextButtonState();
}

class _CustomTextButtonState extends State<CustomTextButton> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      // width: widgetSizeProvider(
      //     fixedSize: widget.size.width + 50,
      //     sizeDecidingVariable: widget.screenBasedPixelWidth),
      height: widgetSizeProvider(
          fixedSize: widget.size.height,
          sizeDecidingVariable: widget.screenBasedPixelWidth),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: TextButton(
          style: ButtonStyle(
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            minimumSize: MaterialStateProperty.all<Size?>(
              Size(
                widgetSizeProvider(
                    fixedSize: widget.size.width,
                    sizeDecidingVariable: widget.screenBasedPixelWidth),
                widgetSizeProvider(
                    fixedSize: widget.size.height,
                    sizeDecidingVariable: widget.screenBasedPixelHeight),
              ),
            ),
            // backgroundColor: MaterialStateProperty.all(const Color(0xff04294f)),
            padding: MaterialStateProperty.all(EdgeInsets.symmetric(
              vertical: widgetSizeProvider(
                  fixedSize: widget.padding.vertical,
                  sizeDecidingVariable: widget.screenBasedPixelWidth),
              horizontal: widgetSizeProvider(
                  fixedSize: widget.padding.horizontal,
                  sizeDecidingVariable: widget.screenBasedPixelWidth),
            )),
            textStyle: MaterialStateProperty.all(
              getDynamicTextStyle(
                  textStyle: Theme.of(context).textTheme.button,
                  sizeDecidingVariable: widget.screenBasedPixelWidth),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.borderRadius
                    // widgetSizeProvider(
                    //     fixedSize: 20,
                    //     sizeDecidingVariable: widget.screenBasedPixelWidth),
                    ),
              ),
            ),
          ),
          onPressed: widget.onPressed,
          child: widget.child,
        ),
      ),
    );
  }
}
