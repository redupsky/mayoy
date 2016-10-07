#!/bin/sh

elm make src/Juxta.elm --output app/juxta.js && node_modules/.bin/electron app/app.js app/
