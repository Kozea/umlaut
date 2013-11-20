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
        a -- b -- c;
        b -- d;
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 3
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'a'
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'b'
    ok g.statements[0].nodes[2] instanceof Node
    eq g.statements[0].nodes[2].id, 'c'
    ok g.statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].id, 'b'
    ok g.statements[1].nodes[1] instanceof Node
    eq g.statements[1].nodes[1].id, 'd'
)

lex_test('simple node directed', """
    digraph graphname {
        a -> b -> c
        b -> d
    }""", ->
    eq g.statements.length, 2
    ok g.statements[0] instanceof Edge
    eq g.statements[0].nodes.length, 3
    ok g.statements[0].nodes[0] instanceof Node
    eq g.statements[0].nodes[0].id, 'a'
    ok g.statements[0].nodes[1] instanceof Node
    eq g.statements[0].nodes[1].id, 'b'
    ok g.statements[0].nodes[2] instanceof Node
    eq g.statements[0].nodes[2].id, 'c'
    eq g.statements[0].attributes.length, 0
    ok g.statements[1].nodes[0] instanceof Node
    eq g.statements[1].nodes[0].id, 'b'
    ok g.statements[1].nodes[1] instanceof Node
    eq g.statements[1].nodes[1].id, 'd'
    eq g.statements[1].attributes.length, 0
)

lex_test('with attributes', """
    graph {
        red -- blue [label=\"lbl\"];
        red [shape=box, \"size\"=.9 id=ea];
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
        { c -> d o } -> { e -> a }
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
