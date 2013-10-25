#!/bin/bash

coffee -wc -j umlaut.js -o javascripts/ \
    coffees/diagrams/*                  \
    coffees/svg.coffee                  \
    coffees/ui/*                        \
    coffees/storage/*                   \
