import base64, cgi, ftplib, json, mimetypes, os
from urllib.parse import unquote, urlparse
from http.server import BaseHTTPRequestHandler, HTTPServer

FTP_HOST = os.getenv("FTP_HOST", "ftp")
FTP_USER = os.environ["FTP_USER"]
FTP_PASSWORD = os.environ["FTP_PASSWORD"]

class App(BaseHTTPRequestHandler):
    def json(self, status, payload):
        body = json.dumps(payload).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def auth(self):
        value = self.headers.get("Authorization", "")
        if not value.startswith("Basic "): return False
        try:
            user, password = base64.b64decode(value[6:]).decode().split(":", 1)
            return user == FTP_USER and password == FTP_PASSWORD
        except Exception: return False

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/health":
            return self.json(200, {"status": "ok"})
        if path == "/files":
            if not self.auth():
                self.send_response(401); self.send_header("WWW-Authenticate", "Basic realm=upload"); self.end_headers(); return
            try:
                with ftplib.FTP(FTP_HOST, timeout=15) as ftp:
                    ftp.login(FTP_USER, FTP_PASSWORD)
                    files = sorted(os.path.basename(item) for item in ftp.nlst("uploads"))
                return self.json(200, {"files": files})
            except Exception as error:
                print(f"FTP list failed: {error}", flush=True)
                return self.json(404, {"error": "uploads not found"})
        if not path.startswith("/files/"):
            return self.json(404, {"error": "not found"})
        if not self.auth():
            self.send_response(401); self.send_header("WWW-Authenticate", "Basic realm=upload"); self.end_headers(); return
        filename = os.path.basename(unquote(path.removeprefix("/files/")))
        if not filename or filename in (".", ".."):
            return self.json(400, {"error": "invalid filename"})
        try:
            with ftplib.FTP(FTP_HOST, timeout=15) as ftp:
                ftp.login(FTP_USER, FTP_PASSWORD)
                size = ftp.size(f"uploads/{filename}")
                if urlparse(self.path).query == "metadata=1":
                    return self.json(200, {"path": f"/uploads/{filename}", "size": size})
                self.send_response(200)
                self.send_header("Content-Type", mimetypes.guess_type(filename)[0] or "application/octet-stream")
                self.send_header("Content-Length", str(size))
                self.end_headers()
                ftp.retrbinary(f"RETR uploads/{filename}", self.wfile.write)
        except Exception as error:
            print(f"FTP download failed: {error}", flush=True)
            self.json(404, {"error": "file not found"})

    def do_POST(self):
        if self.path != "/upload": return self.json(404, {"error": "not found"})
        if not self.auth():
            self.send_response(401); self.send_header("WWW-Authenticate", "Basic realm=upload"); self.end_headers(); return
        content_type = self.headers.get("Content-Type", "")
        if not content_type.startswith("multipart/form-data"): return self.json(400, {"error": "file is required"})
        form = cgi.FieldStorage(fp=self.rfile, headers=self.headers, environ={"REQUEST_METHOD": "POST", "CONTENT_TYPE": content_type})
        if "file" not in form or not form["file"].filename: return self.json(400, {"error": "file is required"})
        item = form["file"]
        filename = os.path.basename(item.filename)
        if not filename or filename in (".", ".."): return self.json(400, {"error": "invalid filename"})
        try:
            with ftplib.FTP(FTP_HOST, timeout=15) as ftp:
                ftp.login(FTP_USER, FTP_PASSWORD)
                try: ftp.mkd("uploads")
                except ftplib.error_perm: pass
                ftp.storbinary(f"STOR uploads/{filename}", item.file)
        except Exception as error:
            print(f"FTP upload failed: {error}", flush=True)
            return self.json(502, {"error": "FTP upload failed"})
        self.json(201, {"path": f"/uploads/{filename}"})

    def log_message(self, fmt, *args): print(fmt % args, flush=True)

HTTPServer(("0.0.0.0", 8000), App).serve_forever()
