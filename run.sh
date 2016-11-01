#!/bin/sh

elm make src/Mayoy.elm --output app/mayoy.js && node_modules/.bin/electron app/app.js app/
