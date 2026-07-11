import http.server
import socketserver
import os

PORT = 8000
DUMMY_SWF = "dummy.swf"
DUMMY_PNG = "dummy.png"

class MagicHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # Translate the requested URL path to a local computer path
        local_path = self.translate_path(self.path)
        
        # If the requested file DOES NOT exist on your hard drive...
        if not os.path.exists(local_path):
            
            # 1. Handle missing SWF files
            if self.path.endswith('.swf'):
                print(f"[MAGIC SERVER] Faking missing SWF: {self.path}")
                with open(DUMMY_SWF, 'rb') as f:
                    self.send_response(200)
                    self.send_header("Content-type", "application/x-shockwave-flash")
                    self.end_headers()
                    self.wfile.write(f.read())
                return
                
            # 2. Handle missing PNG files
            elif self.path.endswith('.png'):
                print(f"[MAGIC SERVER] Faking missing PNG: {self.path}")
                with open(DUMMY_PNG, 'rb') as f:
                    self.send_response(200)
                    self.send_header("Content-type", "image/png")
                    self.end_headers()
                    self.wfile.write(f.read())
                return
                
        # Otherwise, serve the real file normally
        super().do_GET()

# Start the server
with socketserver.TCPServer(("", PORT), MagicHandler) as httpd:
    print(f"Magic Server running on port {PORT}...")
    print("Serving 'dummy.swf' and 'dummy.png' for missing assets.")
    httpd.serve_forever()