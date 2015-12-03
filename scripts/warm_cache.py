#!/usr/bin/python

import argparse
import multiprocessing
import urllib2


class bcolors:
    INFO = '\033[95m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    UNDERLINE = '\033[4m'


def colorize(text, color):
    return color + text + bcolors.ENDC


# Class for making requests against the server
class Requester(multiprocessing.Process):
    def __init__(self, host, symbol):
        multiprocessing.Process.__init__(self)
        self.host = host
        self.symbol = symbol

    def run(self):
        target = self.host + "/sentiment?symbol={0}".format(self.symbol)
        if not target.startswith("http://"):
            target = "http://{0}".format(target)

        print "Requesting: {0}".format(target)
        try:
            urllib2.urlopen(target)
            print colorize("       Got: {0}".format(target), bcolors.INFO)
        except:
            print colorize("    FAILED: {0}".format(target), bcolors.FAIL)


# Tickers to test with
default_symbols = ['AAPL', 'GOOGL', 'FB', 'TSLA']

# Parse arguments
parser = argparse.ArgumentParser(description="Warm up the cache")
parser.add_argument('hostname', help="the hostname of the server")
parser.add_argument('-s',
                    '--symbols',
                    nargs='+',
                    help='Symbols to lookup (default = {0})'
                    .format(' '.join(default_symbols)),
                    default=default_symbols)
args = parser.parse_args()

# Build list of requests to make
requests = []
for symbol in args.symbols:
    requests.append(Requester(args.hostname, symbol))

# Make requests in parallel
for request in requests:
    request.start()
