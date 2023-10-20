#!/bin/bash
rm README.adoc
echo -e "==TIL\n:source-highlighter: rouge\n:toc:\nToday in learned.\n\ntoc::[]\n\n" > readme-source.adoc; for i in $(find ./adoc -name  '*.adoc' | grep -v README.adoc | cut -c3-) ; do NAME=${i%%.adoc}  ; echo $NAME ; done |sort| awk '{print "include::"$1".adoc["$i"]\n"}' >> readme-source.adoc
