@echo off
set SEVENZIP="C:\Program Files\7-Zip\7z.exe"
set DEST="AvoEvents.zip"
cd resourcepack
%SEVENZIP% a -tzip ..\%DEST% *