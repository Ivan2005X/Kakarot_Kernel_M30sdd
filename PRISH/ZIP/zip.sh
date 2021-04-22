#!/bin/bash
rm -rf *.zip
cd ../..
cd output
rm -rf *.zip
cd ..
cd PRISH/ZIP
zip -r9 Kakarot-Kernel_M30sdd-$(date +"%Y-%m-%d").zip META-INF PRISH
cd ../..
cp -r ./PRISH/ZIP/*.zip ./output/
rm -rf *.zip
