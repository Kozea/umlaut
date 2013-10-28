from http.server import HTTPServer, SimpleHTTPRequestHandler
from socketserver import ThreadingMixIn
from multiprocessing import Process
from subprocess import call


class ThreadedHTTPServer(ThreadingMixIn, HTTPServer):
    """Handle requests in a separate thread."""


class Compass(Process):
    daemon = True

    def run(self):
        call(['compass', 'watch'])


class CoffeeScript(Process):
    daemon = True

    def run(self):
        call(['./coffee-machine.sh'], shell=True)


print('Lauching compass')
Compass().start()
print('Lauching compass')
CoffeeScript().start()

print('Lauching http server')
server = ThreadedHTTPServer(('localhost', 1212), SimpleHTTPRequestHandler)
server.serve_forever()
