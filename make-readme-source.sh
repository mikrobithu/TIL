#!/bin/bash
rm README.adoc
echo -e "\n\n= TIL\n:source-highlighter: rouge\n:toc:\n:idprefix: id_\n:idseparator: -\n:toc-level: 5\n:toc-title: Today in learned.\n:sectnumlevels: 5\n:sectnums: |,all|\n\n" > readme-source.adoc; for i in $(find ./adoc -name  '*.adoc' | grep -v README.adoc | cut -c3-) ; do NAME=${i%%.adoc}  ; echo $NAME ; done |sort| awk '{print "include::"$1".adoc["$i"]\n"}' >> readme-source.adoc
