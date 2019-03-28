#!/bin/bash

PLANETNAME=$1
mv ~/Downloads/horizons_results.txt .
python3 horizonEdit.py
firebase database:set /planets/$PLANETNAME converted.json
mv converted.json $PLANETNAME.json
mv $PLANETNAME.json positions
rm converted.txt
rm horizons_results.txt
