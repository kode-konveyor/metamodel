#!/usr/bin/python3
import re
import sys

def main():
   for l in sys.stdin.readlines():
     ll=l[:-1]
     show(ll)

def show(ll):
     print ('mv "{0}" "{1}"'.format(convert(ll),ll))

def convert(ll):
    return re.sub(
        r'(.*/[^_]*)_',
        '\\1 ',
        ll)

#a = "/(build)/modelparts/metamodel/design_base/2. Design metamodel base/00. Design Relations/fcf8ccf8-a98d-456f-8479-0cd2bb491b1e_contributes to_uses"
#show(a)
main()
