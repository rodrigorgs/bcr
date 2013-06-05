#!/usr/bin/env ruby

#require 'graph'
require 'network'

# choose one index, with probability proportional to its weight
def choose_random_acc(acc_weights, labels=(0..acc_weights.size-1).to_a)
  return nil if acc_weights.nil? || acc_weights.empty?

  n = rand * acc_weights[-1]
  # XXX optimize using binary search
  acc_weights.each_with_index { |x, i| return labels[i] if x > n }
  return labels[acc_weights.size - 1]
end

# XXX optimize (maybe avoid using this function)
def choose_random(weights, labels=(0..weights.size-1).to_a)
  return nil if weights.nil? || weights.empty?

  sum = 0
  acc_weights = weights.map { |x| sum += x; sum } #+ [sum + 1]

  return choose_random_acc(acc_weights, labels)
end

def souza2009_game(size_limit, arch, alpha, beta, gamma, 
    delta_in, delta_out, prob_out)
  g = Network.new

  next_eid = 0
  arch.each_vertex do |module_|
    v = g.node!(next_eid, module_.eid)
    g.edge!(v, v)
    next_eid += 1
  end

  sum = 0  
  event_prob_acc = [alpha, beta, gamma].map { |x| sum += x; sum }
  while g.size < size_limit
    event = choose_random_acc(event_prob_acc, [:alpha, :beta, :gamma])

    case event
    when :alpha
      w = choose_random(g.nodes.map{ |x| x.in_degree + delta_in }, g.nodes)
      v = g.node!(next_eid, w.cluster)
      g.edge!(v, w)
    when :beta
      if rand < prob_out # external edge
        clusters_with_neighbors = arch.nodes.select { |n| !n.neighbors.empty? }
        clusters_with_neighbors.map! { |n| g.cluster?(n.eid) }
        nodes = clusters_with_neighbors.inject([]) { |union, c| union + c.nodes.to_a }
        v = choose_random(nodes.map{ |x| x.out_degree + delta_out}, nodes)
        adjacent_clusters = arch.node?(v.cluster.eid).out_nodes.map { |m| g.cluster?(m.eid) }.select { |c| c != v.cluster }
        candidates = g.nodes.select { |x| adjacent_clusters.include? x.cluster }
        unless candidates.empty?
          w = choose_random(candidates.map{ |x| x.in_degree + delta_in }, candidates)
          g.edge!(v, w)
        end
      else # internal edge
        v = choose_random(g.nodes.map { |x| x.out_degree + delta_out }, g.nodes)
        nodes = v.cluster.nodes.to_a - [v]

        unless nodes.empty?
          w = choose_random(nodes.map { |x| x.in_degree + delta_in }, nodes)
          g.edge!(v, w)
        end
      end
    when :gamma
      v = choose_random(g.nodes.map{ |x| x.out_degree + delta_out }, g.nodes)
      w = g.node!(next_eid, v.cluster)
      g.edge!(v, w)
    end
    next_eid += 1 if (event == :alpha || event == :gamma)
  end

  return g
end
