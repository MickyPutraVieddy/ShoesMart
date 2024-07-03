int hexcolour(String color) {
  // menambah prefix
  String newcolor = '0xff' + color;
  // removing sign #
  newcolor = newcolor.replaceAll('#', '');
  // converting it to integer
  int finalcolour = int.parse(newcolor);
  return finalcolour;
}

int background(String color) {
  // menambah prefix
  String newcolor = '0xff' + color;
  // removing sign #
  newcolor = newcolor.replaceAll('#', '');
  // converting it to integer
  int finalcolour = int.parse(newcolor);
  return finalcolour;
}
