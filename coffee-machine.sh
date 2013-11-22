#!/bin/bash

coffee -wcb -j umlaut.js -o javascripts/ \
    coffees/utils.coffee                 \
    coffees/diagrams/base.coffee         \
    coffees/svg/linking.coffee           \
    coffees/diagrams/elements.coffee     \
    coffees/diagrams/links.coffee        \
    coffees/diagrams/diagram.coffee      \
    coffees/diagrams/commons.coffee      \
    coffees/diagrams/groups.coffee       \
    coffees/diagrams/dot.coffee          \
    coffees/diagrams/flowchart.coffee    \
    coffees/diagrams/usecase.coffee      \
    coffees/diagrams/electric.coffee     \
    coffees/diagrams/class.coffee        \
    coffees/ui/*.coffee                  \
    coffees/svg/behavior.coffee          \
    coffees/svg/drawing.coffee           \
    coffees/svg.coffee                   \
    coffees/storage/*.coffee             \
    coffees/lang/*.coffee                \
    coffees/init.coffee                  \
