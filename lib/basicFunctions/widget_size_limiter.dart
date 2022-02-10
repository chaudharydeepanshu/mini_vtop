double widgetSizeProvider({
  required double sizeDecidingVariable,
  required double fixedSize,
}) {
  return sizeDecidingVariable * fixedSize > fixedSize
      ? fixedSize
      : sizeDecidingVariable * fixedSize;
}
