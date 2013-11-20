module "dot tokenization"

i = 0
tok = null

node = (type, value) ->
    ok tok[i] instanceof type
    equal tok[i++].value, value

end = ->
    ok not tok[i]?

test("simple tokenization", ->
    i = 0
    tok = dot_tokenize 'graph {}'
    node Keyword, 'graph'
    node Brace, '{'
    node Brace, '}'
    end()
)

test("tokenization normal", ->
    i = 0
    tok = dot_tokenize(
        """graph graphname {
            a -- b -- c;
            b -- d;
         }""")
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

test("tokenization directed", ->
    i = 0
    tok = dot_tokenize(
        """digraph graphname {
            a -> b -> c;
            b -> d;
         }""")
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

test("tokenization with quoted strings", ->
    i = 0
    tok = dot_tokenize(
        """digraph \"Graph name\" {
            \"Node with \\\" in it\" -> \"Node with
line break\";
         }""")
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


test("tokenization with attributes", ->
    i = 0
    tok = dot_tokenize(
        """graph ethane {
             C_0 -- H_0 [type=s];
             C_0 -- H_1 [type=s];
             C_0 -- H_2 [type=s];
             C_0 -- C_1 [type=s];
             C_1 -- H_3 [type=s];
             C_1 -- H_4 [type=s];
             C_1 -- H_5 [type=s];
         }""")
    node Keyword, 'graph'
    node Id, 'ethane'
    node Brace, '{'
    node Id, 'C_0'
    node Operator, '--'
    node Id, 'H_0'
    node Brace, '['
    node Id, 'type'
    node Assign, '='
    node Id, 's'
    node Brace, ']'
    node Delimiter, ';'
    node Id, 'C_0'
    node Operator, '--'
    node Id, 'H_1'
    node Brace, '['
    node Id, 'type'
    node Assign, '='
    node Id, 's'
    node Brace, ']'
    node Delimiter, ';'
)

test("tokenization with comments", ->
    i = 0
    tok = dot_tokenize(
        """graph graphname {
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
         }""")
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
