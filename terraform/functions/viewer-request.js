function handler(event) {
  var request = event.request;
  var uri = request.uri;

  if (uri.endsWith('/')) {
    // /admin/ -> /admin/index.html
    request.uri += 'index.html';
  } else if (!uri.includes('.')) {
    // SPA route ที่ไม่มีนามสกุลไฟล์ -> /index.html
    request.uri = '/index.html';
  }

  return request;
}
