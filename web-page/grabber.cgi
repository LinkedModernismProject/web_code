#!/usr/bin/python
import requests
import cgitb
import cgi
import sys
cgitb.enable()
form = cgi.FieldStorage()
#r = requests.get("http://linkedmods.uvic.ca:8890/grabber.cgi")
#print r
print "hello"
print form
f = open('dataFile.txt', 'a')
fwrite('Testing')
f.write(form)
f.close()

###import cgi
###form = cgi.FieldStorage()
###print form

###
###
###class MyPage:
###    def POST(self):
###    	print 'in the POST'
###    	f.write('in the POST')
###        data = web.input()
###        eval(data.code)
###
###print 'in here'
###f.write 'in hera'
###f.close()

#form = web.input()
#print form


#from socket import *
#import json
#s = socket()
#s.bind(('', 80)) # <-- Since the GET request will be sent to port 80 most likely
#s.listen(4)
#ns, na = s.accept()
#print 'in here!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'
#
#while 1:
#    try:
#        data = ns.recv(8192) # <-- Get the browser data
#        print data
#    except:
#        ns.close()
#        s.close()
#        break
#
#    ## ---------- NOTE ------------ ##
#    ## "data" by default contains a bunch of HTTP headers
#    ## You need to get rid of those and parse the HTML data,
#    ## the best way is to either just "print data" and see
#    ## what it contains, or just try to find a HTTP parser lib (server side)    
#
#    data = json.loads(data)
#    print data