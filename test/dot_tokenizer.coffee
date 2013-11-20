module "Dot Tokenizer"

i = tok = null

node = (type, value) ->
    ok tok[i] instanceof type, "Node is #{type.name}"
    equal tok[i++].value, value, "Node contains #{value}"

end = ->
    ok not tok[i]?, "There's no extra elements"

token_test = (title, s, tests) ->
    test("#{title}: \n\n#{s}\n\n", ->
        i = 0
        tok = dot_tokenize s
        tests()
        i = null
        tok = null)

token_test('simple', 'graph {}', ->
    node Keyword, 'graph'
    node Brace, '{'
    node Brace, '}'
    end()
)

token_test("normal", """
    graph graphname {
        a -- b -- c;
        b -- d;
    }""", ->
    node Keyword, 'graph'
    node Id, 'graphname'
    node Brace, '{'
    node Id, 'a'
    node Operator, '--'
    node Id, 'b'
    node Operator, '--'
    node Id, 'c'
    node Delimiter, ';'
    node Id, 'b'
    node Operator, '--'
    node Id, 'd'
    node Delimiter, ';'
    node Brace, '}'
    end()
)

token_test('directed', """
    digraph graphname {
        a -> b -> c;
        b -> d;
    }""", ->
    node Keyword, 'digraph'
    node Id, 'graphname'
    node Brace, '{'
    node Id, 'a'
    node Operator, '->'
    node Id, 'b'
    node Operator, '->'
    node Id, 'c'
    node Delimiter, ';'
    node Id, 'b'
    node Operator, '->'
    node Id, 'd'
    node Delimiter, ';'
    node Brace, '}'
    end()
)

token_test('with quoted strings', """
    digraph \"Graph name\" {
        \"Node with \\\" in it\" -> \"Node with
line break\";
    }""", ->
    node Keyword, 'digraph'
    node Id, 'Graph name'
    node Brace, '{'
    node Id, 'Node with " in it'
    node Operator, '->'
    node Id, 'Node with\nline break'
    node Delimiter, ';'
    node Brace, '}'
    end()
)

token_test('with attributes', """
    graph {
        red -- blue [label=\"lbl\"];
        red -- green [shape=box, \"size\"=1.9 id=ea];
    }""", ->
    node Keyword, 'graph'
    node Brace, '{'
    node Id, 'red'
    node Operator, '--'
    node Id, 'blue'
    node Brace, '['
    node Id, 'label'
    node Assign, '='
    node Id, 'lbl'
    node Brace, ']'
    node Delimiter, ';'
    node Id, 'red'
    node Operator, '--'
    node Id, 'green'
    node Brace, '['
    node Id, 'shape'
    node Assign, '='
    node Id, 'box'
    node Delimiter, ','
    node Id, 'size'
    node Assign, '='
    node Id, 1.9
    node Id, 'id'
    node Assign, '='
    node Id, 'ea'
    node Brace, ']'
    node Delimiter, ';'
)

token_test('test attr_stmt', """
    digraph {
        edge [one = 1.00]
    }""", ->
    node Keyword, 'digraph'
    node Brace, '{'
    node Keyword, 'edge'
    node Brace, '['
    node Id, 'one'
    node Assign, '='
    node Number, 1
    node Brace, ']'
    node Brace, '}'
    end()
)

token_test("with comments", """
    graph graphname {
         // This attribute applies /to the graph itself
         size=\"1,1\"; /* size to 1,1 */
         // The label attribute can be used to change the label of a node
         a [label=\"Foo\"]; // label to Foo
         # Here, the node /shape is changed.
         b [shape=box]; # Shape to box
         /* These edges both
            have different /line
            properties
         */
         a -- b -- c [color=blue];
         b -- d [style=dotted];
     }""", ->
    node Keyword, 'graph'
    node Id, 'graphname'
    node Brace, '{'
    node Id, 'size'
    node Assign, '='
    node Id, '1,1'
    node Delimiter, ';'
    node Id, 'a'
    node Brace, '['
    node Id, 'label'
    node Assign, '='
    node Id, 'Foo'
    node Brace, ']'
    node Delimiter, ';'
    node Id, 'b'
    node Brace, '['
    node Id, 'shape'
    node Assign, '='
    node Id, 'box'
    node Brace, ']'
    node Delimiter, ';'
    node Id, 'a'
    node Operator, '--'
    node Id, 'b'
    node Operator, '--'
    node Id, 'c'
    node Brace, '['
    node Id, 'color'
    node Assign, '='
    node Id, 'blue'
    node Brace, ']'
    node Delimiter, ';'
    node Id, 'b'
    node Operator, '--'
    node Id, 'd'
    node Brace, '['
    node Id, 'style'
    node Assign, '='
    node Id, 'dotted'
    node Brace, ']'
    node Delimiter, ';'
    node Brace, '}'
    end()
)
