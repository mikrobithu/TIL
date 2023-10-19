#!/bin/bash
echo -e "\n= TIL\n:source-highlighter: rouge\n\nToday in learned.\n\n:toc:\n" > readme-source.adoc; for i in $(find . -name  '*.adoc' | grep -v README.adoc | cut -c3-) ; do NAME=${i%%.adoc}  ; echo $NAME ; done |sort| awk '{print "include::"$1".adoc["$i"]\n"}' >> readme-source.adoc
