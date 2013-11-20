module "Dot Lexer"

g = null

lex_test = (title, s, tests) ->
    test("#{title} \n\n#{s}\n\n", ->
        g = dot_lex dot_tokenize(s)
        tests()
        g = null)

lex_test("graph normal", 'graph {}', ->
    equal g.type, 'normal'
    equal g.id, null
    equal g.strict, false
    deepEqual g.statements, []
)

lex_test("graph directed", 'digraph {}', ->
    equal g.type, 'directed'
    equal g.id, null
    equal g.strict, false
    deepEqual g.statements, []
)

lex_test("graph strict", 'strict graph {}', ->
    equal g.type, 'normal'
    equal g.id, null
    equal g.strict, true
    deepEqual g.statements, []
)

lex_test("graph with id", 'graph "My Graph" {}', ->
    equal g.type, 'normal'
    equal g.id, "My Graph"
    equal g.strict, false
    deepEqual g.statements, []
)

lex_test("simple nodes", """
    graph graphname {
        a -- b -- c;
        b -- d;
    }""", ->
    equal g.statements.length, 2
    ok g.statements[0] instanceof Edge
    equal g.statements[0].nodes.length, 3
    ok g.statements[0].nodes[0] instanceof Node
    equal g.statements[0].nodes[0].id, 'a'
    ok g.statements[0].nodes[1] instanceof Node
    equal g.statements[0].nodes[1].id, 'b'
    ok g.statements[0].nodes[2] instanceof Node
    equal g.statements[0].nodes[2].id, 'c'
    ok g.statements[1].nodes[0] instanceof Node
    equal g.statements[1].nodes[0].id, 'b'
    ok g.statements[1].nodes[1] instanceof Node
    equal g.statements[1].nodes[1].id, 'd'
)

lex_test('simple node directed', """
    digraph graphname {
        a -> b -> c
        b -> d
    }""", ->
    equal g.statements.length, 2
    ok g.statements[0] instanceof Edge
    equal g.statements[0].nodes.length, 3
    ok g.statements[0].nodes[0] instanceof Node
    equal g.statements[0].nodes[0].id, 'a'
    ok g.statements[0].nodes[1] instanceof Node
    equal g.statements[0].nodes[1].id, 'b'
    ok g.statements[0].nodes[2] instanceof Node
    equal g.statements[0].nodes[2].id, 'c'
    equal g.statements[0].attributes.length, 0
    ok g.statements[1].nodes[0] instanceof Node
    equal g.statements[1].nodes[0].id, 'b'
    ok g.statements[1].nodes[1] instanceof Node
    equal g.statements[1].nodes[1].id, 'd'
    equal g.statements[1].attributes.length, 0
)

lex_test('with attributes', """
    graph {
        red -- blue [label=\"lbl\"];
        red [shape=box, \"size\"=.9 id=ea];
    }""", ->
    equal g.statements.length, 2
    ok g.statements[0] instanceof Edge
    equal g.statements[0].nodes.length, 2
    ok g.statements[0].nodes[0] instanceof Node
    equal g.statements[0].nodes[0].id, 'red'
    ok g.statements[0].nodes[1] instanceof Node
    equal g.statements[0].nodes[1].id, 'blue'

    equal g.statements[0].attributes.length, 1
    equal g.statements[0].attributes[0].left, 'label'
    equal g.statements[0].attributes[0].right, 'lbl'

    ok g.statements[1] instanceof Edge
    equal g.statements[1].nodes.length, 1
    ok g.statements[1].nodes[0] instanceof Node
    equal g.statements[1].nodes[0].id, 'red'

    equal g.statements[1].attributes.length, 3
    equal g.statements[1].attributes[0].left, 'shape'
    equal g.statements[1].attributes[0].right, 'box'
    equal g.statements[1].attributes[1].left, 'size'
    equal g.statements[1].attributes[1].right, .9
    equal g.statements[1].attributes[2].left, 'id'
    equal g.statements[1].attributes[2].right, 'ea'
)
