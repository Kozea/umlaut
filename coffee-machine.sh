#!/bin/bash

coffee -wcb -j umlaut.js -o javascripts/ \
    coffees/utils.coffee                 \
    coffees/diagrams/*                   \
    coffees/ui/*                         \
    coffees/svg.coffee                   \
    coffees/storage/*                    \
