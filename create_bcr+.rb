#!/usr/bin/env ruby

if __FILE__ == $0

  require 'choice'
  require 'gxl'
  #require 'graph'
  require 'random_graphs'

  Choice.options do
    header ''
    header 'Input/output:'

    option :input, :required => true do
      short '-i'
      long '--input=FILE'
      desc 'File containing the architecture'
      desc '(required)'
    end
    
    option :output_l1, :required => true do
      short '-1'
      long '--output=FILE'
      desc 'Output l1 filename (required)'
    end
    
    option :output_l2, :required => true do
      short '-2'
      long '--output=FILE'
      desc 'Output l2 filename (required)'
    end

    separator ''
    separator 'Model parameters:'

    option :nodes do
      short '-n'
      long '--nodes=N'
      cast Integer
      default 1000
      desc 'Number of nodes (default: 1000)'
    end

    option :alpha do
      long '--p1=P'
      cast Float
      default 0.41
      desc 'Probability of adding a vertex with an'
      desc 'outgoing edge (default: 0.41)'
    end
    
    option :gamma do
      long '--p2=P'
      cast Float
      default 0.10
      desc 'Probability of adding a vertex with an'
      desc 'ingoing edge (default: 0.10)'
    end

    option :beta do
      short '-b'
      long '--p3=P'
      cast Float
      default 0.49
      desc 'Probability of adding an edge between'
      desc 'vertices from distinct modules'
      desc '(default: 0.49)'
    end

    option :mixing do
      short '-m'
      long '--mixing=P'
      cast Float
      default 0.0539
      desc 'Mixing parameter.'
      desc '(default: 0.0539)'
    end

    option :din do
      long '--din=N'
      cast Float
      default 0.0
      desc 'In-degree offset (default: 0.0)'
    end

    option :dout do
      long '--dout=N'
      cast Float
      default 0.0
      desc 'Out-degree offset (default: 0.0)'
    end

    option :profile do
      long '--profile'
      desc 'Profile the execution'
    end

    separator ''
  end

  c = Choice.choices

  arch = nil
  begin
    arch_pairs = read_pairs(c.input)
    arch = Network.new
    arch.add_edges(arch_pairs)
  rescue Errno::ENOENT => e
    puts "File not found: #{c.input}"
    exit 1
  end

  if c.profile
    require 'ruby-prof'
    RubyProf.start
  end

  g = souza2009_game(
     c.nodes, 
     arch,
     c.alpha,
     c.beta,
     c.gamma,
     c.din,
     c.dout,
     c.mixing)

  if c.profile
    result = RubyProf.stop
    printer = RubyProf::FlatPrinter.new(result)
    printer.print(STDOUT, 0)
  end

  pairs = g.edges.map { |e| [e.from.eid, e.to.eid] }
  modules = g.nodes.map { |n| [n.eid, n.cluster.eid] }
  puts_pairs(pairs, c.output_l1)
  puts_pairs(modules, c.output_l2) 
end
