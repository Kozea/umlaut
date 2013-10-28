#!/bin/bash

coffee -wcb -j umlaut.js -o javascripts/ \
    coffees/utils.coffee                 \
    coffees/diagrams/elements.coffee     \
    coffees/diagrams/links.coffee        \
    coffees/diagrams/diagram.coffee      \
    coffees/diagrams/flowchart.coffee    \
    coffees/diagrams/usecase.coffee      \
    coffees/ui/*                         \
    coffees/svg.coffee                   \
    coffees/storage/*                    \
    coffees/init.coffee                  \
