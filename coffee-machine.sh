#!/bin/bash

coffee -wcb -j umlaut.js -o javascripts/ \
    coffees/utils.coffee                 \
    coffees/diagrams/elements.coffee     \
    coffees/diagrams/links.coffee        \
    coffees/diagrams/diagram.coffee      \
    coffees/diagrams/commons.coffee      \
    coffees/diagrams/groups.coffee       \
    coffees/diagrams/flowchart.coffee    \
    coffees/diagrams/usecase.coffee      \
    coffees/diagrams/electric.coffee     \
    coffees/diagrams/class.coffee        \
    coffees/ui/*                         \
    coffees/svg.coffee                   \
    coffees/storage/*                    \
    coffees/init.coffee                  \
