import http.server
import socketserver
import os


class Handler(http.server.SimpleHTTPRequestHandler):

    def do_GET(self):
        # Construct a server response.

        message = str(os.environ)

        self.send_response(200)
        self.send_header('Content-Type',
                         'text/plain; charset=utf-8')
        self.end_headers()
        self.wfile.write(message.encode('utf-8'))


print('Server listening on port 8000...')
httpd = socketserver.TCPServer(('', 8000), Handler)
httpd.serve_forever()
