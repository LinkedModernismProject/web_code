from __future__ import print_function
from __future__ import unicode_literals


from argparse import ArgumentParser
import os
import os.path
import shutil
import platform
from io import StringIO
import subprocess
import sys
import tarfile
import xml.etree.ElementTree as ET

import wget

import server
from lib.util import get_static_resource_path



launch_parser = ArgumentParser()
server.populate_parser(launch_parser)
args = launch_parser.parse_args(['TopicExplorerFolder.ini'])
#print (args)
#raise Exception("")
server.main(args)

