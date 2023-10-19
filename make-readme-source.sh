#!/bin/bash
echo -e ":source-highlighter: rouge\n:toc:\n\n\nToday in learned.\n\n" > readme-source.adoc; for i in $(find . -name  '*.adoc' | grep -v README.adoc | cut -c3-) ; do NAME=${i%%.adoc}  ; echo $NAME ; done |sort| awk '{print "include::"$1".adoc["$i"]\n"}' >> readme-source.adoc
