#!/usr/bin/python

import argparse
import os
from subprocess import call
import re
import urllib2

conf = {
        'xml': 'https://raw.githubusercontent.com/scalableinternetservices/ABCs/testing/load_tests/critical.xml',
        'log_dir': '~/.tsung/log',
        'home': os.path.expanduser('~'),
        }

servers = {
        'm3med': '',
        }


class bcolors:
    INFO = '\033[95m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    UNDERLINE = '\033[4m'


def colorize(text, color):
    return color + text + bcolors.ENDC


# Download the XML for testing
def get_xml(url):
    response = urllib2.urlopen(url)
    return response.read()


# Make XML testing file
def make_xml(filename, host, template):
    contents = get_xml(template).replace('CHANGEME', host)
    fobj = open(filename, 'w')
    fobj.write(contents)
    fobj.close()

# Parse arguments
parser = argparse.ArgumentParser(description="Run many Tsung tests")
parser.add_argument('ready', help="Did you change the servers dictionary as required to point to your servers?  And make sure the key value is the instance type!  It must also be a valid Unix filename.")
parser.add_argument('-x',
                    '--xmltemplate',
                    help="Use this to set the XML template to use for testing. Default value is {}".format(conf['xml']),
                    default=conf['xml'])
args = parser.parse_args()


# Make the temp dir to work in
tmp_dir = 'perf_tmp'
os.mkdir(tmp_dir)

# Run each test on each instance in order
for instance, host in servers.iteritems():
    print "Generating files for {}".format(instance)
    filename = os.path.join(tmp_dir, "test_{}.xml".format(instance))
    make_xml(filename, host, args.xmltemplate)

    print colorize("Running Tsung for {}".format(instance), bcolors.INFO)
    # Run Tsung
    call(['tsung', '-f', filename, 'start'])

    print "Analyzing the data for {}".format(instance)
    # Find the result directory
    result_dir = [f for f in os.listdir(os.path.expanduser(conf['log_dir'])) if re.match(r'[0-9]+.*', f)][0]
    result_dir = os.path.join(os.path.expanduser(conf['log_dir']), result_dir)

    # Analyze the generated test data
    call("cd {} && tsung_stats.pl".format(result_dir))

    # Package up the generated test data
    tar = os.path.join(conf['home'], "{}.tar.gz".format(instance))
    call("tar -vczf {} {}".format(tar, result_dir))

    # Rename the generated test data directory
    new_dir = os.path.join(os.path.dirname(result_dir), instance)
    call("mv {} {}".format(result_dir, new_dir))

    print colorize("Created {}. Be sure to copy it to your computer to save it!".format(tar))
