# BCR+

This script generates scale-free graphs that resemble dependency graphs extracted from Java source code (aka software-realistic graphs). It implements the BCR+ model, described in [this (unfinished) paper](https://gitorious.org/swasr/ist-paper).

The graphs are directed and clustered, i.e., each vertex is assigned to a cluster, that can be seen as an architectural module. Thus, they can be used as benchmarks for software architecture recovery algorithms.

## Dependencies

You'll need the Ruby programming language (at least v1.8).

## Running

To synthesize a graph, you have to call the `create_bcr+.rb` script passing some parameters:

    Input/output:
        -i, --input=FILE                 File containing the architecture
                                         (required)
        -1, --output=FILE                Output l1 filename (required)
        -2, --output=FILE                Output l2 filename (required)

    Model parameters:
        -n, --nodes=N                    Number of nodes (default: 1000)
            --p1=P                       Probability of adding a vertex with an
                                         outgoing edge (default: 0.41)
            --p2=P                       Probability of adding a vertex with an
                                         ingoing edge (default: 0.10)
        -b, --p3=P                       Probability of adding an edge between
                                         vertices from distinct modules
                                         (default: 0.49)
        -m, --mixing=P                   Mixing parameter.
                                         (default: 0.0539)
            --din=N                      In-degree offset (default: 0.0)
            --dout=N                     Out-degree offset (default: 0.0)
            --profile                    Profile the execution

Sample usage:

    ./create_bcr+.rb -i sample-architecture.pairs 
        -1 sample-l1.pairs \
        -2 sample-modules.pairs \
        -n 300 \
        --p1=0.1 --p2=0.1 --p3=0.8 \
        -m 0.09 \
        --din=3 --dout=3

It takes as input an architecture, i.e., a list of modules and allowed dependencies between modules. For a quick start, you can use the file `sample-architecture.pairs` bundled with this package. It outputs two files that describe the synthesized graph. The first one describes the edges, and the second onde describes the modules.

## Output format

Vertices are represented as sequential integer numbers starting from zero. Directed edges are represented as an ordered pair of integers. Modules are represented as sequential numbers starting from zero (or, in general, any string). Each vertex belong to exactly one module.

The graph is represented as two files: the first representing its edges, and the second representing the mapping between vertices and modules.

In the first file, each edge is represented in one line. Each line contains two numbers separated by a blank space. The first number represents the vertex that is the origin of the edge. The second number represents the vertex that is the destination of the edge. 

In the second file, each line contains two numbers separated by a blank space. The first number is the number of a vertex, and the second number is the number of the module to which the vertex belongs. Example:

FIRST FILE (edges):

    0 1
    1 2
    2 3
    3 4
    0 2
    2 0

SECOND FILE (modules):

    0 0
    1 0
    2 1
    3 1
    4 1

This description represents a graph with 5 vertices (0 up to 4) and 6 edges. It is basically a circular graph with an additional bidirectional edge (0 2 / 2 0). Also, there are two modules, one module with 2 vertices and the other with 3 vertices.

## Input format

The input architecture is described the same way edges are described. Each line of the file represents a pair of modules, so that that first module can depend on the second module.
