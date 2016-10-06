#!/bin/sh

elm make src/Juxta.elm --output juxta.js && node_modules/.bin/electron index.js ./
