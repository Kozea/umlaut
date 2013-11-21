# This file is part of umlaut

# Copyright (C) 2013 Kozea - Mounier Florian <paradoxxx.zero->gmail.com>

# umlaut is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or any later version.

# umlaut is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.


module "Dot Lexer"

eq = equal
g = null

lex_test = (title, s, tests) ->
    test("#{title} \n\n#{s}\n\n", ->
        g = dot_lex dot_tokenize(s)
        tests()
        g = null)

lex_test("graph normal", 'graph {}', ->
    eq g.type, 'normal'
    eq g.id, null
    eq g.strict, false
    deepEqual g.statements, []
)

lex_test("graph directed", 'digraph {}', ->
    eq g.type, 'directed'
    eq g.id, null
    eq g.strict, false
    deepEqual g.statements, []
)

lex_test("graph strict", 'strict graph {}', ->
    eq g.type, 'normal'
    eq g.id, null
    eq g.strict, true
    deepEqual g.statements, []
)

lex_test("graph with id", 'graph "My Graph" {}', ->
    eq g.type, 'normal'
    eq g.id, "My Graph"
    eq g.strict, false
    deepEqual g.statements, []
)

lex_test("simple nodes", """
    graph graphname {
        a -- b -- c:h;
        b:e -- d;
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 3
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'a'
    eq g.statements[0].nodes[0].port, null
    eq g.statements[0].nodes[0].compass_pt, null
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'b'
    eq g.statements[0].nodes[1].port, null
    eq g.statements[0].nodes[1].compass_pt, null
    ok g.statements[0].nodes[2] instanceof Node
    eq g.statements[0].nodes[2].id, 'c'
    eq g.statements[0].nodes[2].port, 'h'
    eq g.statements[0].nodes[2].compass_pt, null
    ok g.statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].id, 'b'
    eq g.statements[1].nodes[0].port, null
    eq g.statements[1].nodes[0].compass_pt, 'e'
    ok g.statements[1].nodes[1] instanceof Node
    eq g.statements[1].nodes[1].id, 'd'
    eq g.statements[1].nodes[1].port, null
    eq g.statements[1].nodes[1].compass_pt, null
)

lex_test('simple node directed', """
    digraph graphname {
        a -> b -> c
        b -> d:id:nw
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 3
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'a'
    eq g.statements[0].nodes[0].port, null
    eq g.statements[0].nodes[0].compass_pt, null
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'b'
    eq g.statements[0].nodes[1].port, null
    eq g.statements[0].nodes[1].compass_pt, null
    ok g.statements[0].nodes[2] instanceof Node
    eq g.statements[0].nodes[2].id, 'c'
    eq g.statements[0].nodes[2].id, 'c'
    eq g.statements[0].nodes[2].port, null
    eq g.statements[0].nodes[2].compass_pt, null
    eq g.statements[0].attributes.length, 0
    ok g.statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].id, 'b'
    eq g.statements[1].nodes[0].port, null
    eq g.statements[1].nodes[0].compass_pt, null
    ok g.statements[1].nodes[1] instanceof Node
    eq g.statements[1].nodes[1].id, 'd'
    eq g.statements[1].nodes[1].port, 'id'
    eq g.statements[1].nodes[1].compass_pt, 'nw'
    eq g.statements[1].attributes.length, 0
)

lex_test('with attributes', """
    graph {
        red -- blue [label=\"lbl\"];
        red [shape=box, \"size\"=.9 id=ea]
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 2
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'red'
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'blue'

    eq g.statements[0].attributes.length, 1
    eq g.statements[0].attributes[0].left, 'label'
    eq g.statements[0].attributes[0].right, 'lbl'

    ok g.statements[1] instanceof Edge
    eq g.statements[1].nodes.length, 1
    ok g.statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].id, 'red'

    eq g.statements[1].attributes.length, 3
    eq g.statements[1].attributes[0].left, 'shape'
    eq g.statements[1].attributes[0].right, 'box'
    eq g.statements[1].attributes[1].left, 'size'
    eq g.statements[1].attributes[1].right, .9
    eq g.statements[1].attributes[2].left, 'id'
    eq g.statements[1].attributes[2].right, 'ea'
)

lex_test('test attr_stmt', """
    digraph {
        edge [one = 1.00]
    }""", ->
    eq g.statements.length, 1
    ok g.statements[0] instanceof Attributes
    eq g.statements[0].type, 'edge'
    eq g.statements[0].attributes.length, 1
    eq g.statements[0].attributes[0].left, 'one'
    eq g.statements[0].attributes[0].right, 1
)

lex_test('basic subgraph', """
    digraph {
        a -> b;
        { c; b -> c }
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 2
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'a'
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'b'
    eq g.statements[0].attributes.length, 0

    ok g.statements[1] instanceof Edge
    eq g.statements[1].nodes.length, 1
    ok g.statements[1].nodes[0] instanceof SubGraph
    eq g.statements[1].nodes[0].statements.length, 2
    ok g.statements[1].nodes[0].statements[0] instanceof Edge
    eq g.statements[1].nodes[0].statements[0].nodes.length, 1
    ok g.statements[1].nodes[0].statements[0].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].statements[0].nodes[0].id, 'c'
    ok g.statements[1].nodes[0].statements[1] instanceof Edge
    eq g.statements[1].nodes[0].statements[1].nodes.length, 2
    ok g.statements[1].nodes[0].statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].statements[1].nodes[0].id, 'b'
    ok g.statements[1].nodes[0].statements[1].nodes[1] instanceof Node
    eq g.statements[1].nodes[0].statements[1].nodes[1].id, 'c'
)

lex_test('linked subgraph', """
    digraph {
        a -> b;
        { c -> d o } -> subgraph { e -> a }
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 2
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'a'
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'b'
    eq g.statements[0].attributes.length, 0

    ok g.statements[1] instanceof Edge
    eq g.statements[1].nodes.length, 2
    ok g.statements[1].nodes[0] instanceof SubGraph
    eq g.statements[1].nodes[0].statements.length, 2
    ok g.statements[1].nodes[0].statements[0] instanceof Edge
    eq g.statements[1].nodes[0].statements[0].nodes.length, 2
    ok g.statements[1].nodes[0].statements[0].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].statements[0].nodes[0].id, 'c'
    ok g.statements[1].nodes[0].statements[0].nodes[1] instanceof Node
    eq g.statements[1].nodes[0].statements[0].nodes[1].id, 'd'
    ok g.statements[1].nodes[0].statements[1] instanceof Edge
    eq g.statements[1].nodes[0].statements[1].nodes.length, 1
    ok g.statements[1].nodes[0].statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].statements[1].nodes[0].id, 'o'

    ok g.statements[1].nodes[1] instanceof SubGraph
    eq g.statements[1].nodes[1].statements.length, 1
    ok g.statements[1].nodes[1].statements[0] instanceof Edge
    eq g.statements[1].nodes[1].statements[0].nodes.length, 2
    ok g.statements[1].nodes[1].statements[0].nodes[0] instanceof Node
    eq g.statements[1].nodes[1].statements[0].nodes[0].id, 'e'
    ok g.statements[1].nodes[1].statements[0].nodes[1] instanceof Node
    eq g.statements[1].nodes[1].statements[0].nodes[1].id, 'a'
)
