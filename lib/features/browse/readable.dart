String readableText(String html) {
  var text = html.replaceAll(
    RegExp(r'<script\b[^>]*>[\s\S]*?</script>', caseSensitive: false),
    ' ',
  );
  text = text.replaceAll(
    RegExp(r'<style\b[^>]*>[\s\S]*?</style>', caseSensitive: false),
    ' ',
  );
  text = text.replaceAll(RegExp(r'<[^>]+>'), ' ');
  text = text
      .replaceAll('&nbsp;', ' ')
      .replaceAll('&', '&')
      .replaceAll('<', '<')
      .replaceAll('>', '>')
      .replaceAll('"', '"');
  return text.replaceAll(RegExp(r'\s+'), ' ').trim();
}
