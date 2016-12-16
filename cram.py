#!/usr/bin/python

# Simulate a CRAM-MD5 identification

import hmac, hashlib, sys
def cram_md5_response(username, password, base64challenge):
    return (username + ' ' +
            hmac.new(password,
                     base64challenge.decode('base64'),
                     hashlib.md5).hexdigest()).encode('base64')


print "Username: %s" % sys.argv[1]
print cram_md5_response(sys.argv[1], sys.argv[2], sys.argv[3])
