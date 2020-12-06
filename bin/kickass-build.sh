#!/usr/bin/env bash

/usr/local/opt/openjdk/bin/java -jar vendor/KickAssembler/KickAss.jar -vicesymbols -debugdump -o $1 $2 -asminfo allPredefined