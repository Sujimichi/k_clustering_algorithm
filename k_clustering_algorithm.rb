#A algorithm for clustering k's :¬)

#Arbitarily assign points to groups
#calculate the mean pos of each group
#check each point and move to group with closest mean pos
#return to step 2 untill no more changes occur.
#

class Point
	attr_accessor :grp_id
	attr_reader :values

	def initialize values, meta_inf = nil
		@values = values
		@meta_inf = meta_inf if meta_inf
	end

	def get_closest groups
		min = groups.first
		groups.each do |group|
			ed_1 = eulidean_dist self.values, min.mean
			ed_2 = eulidean_dist self.values, group.mean
			min = group if ed_2 < ed_1
		end
		min
	end

	def eulidean_dist a, b
		d=0
		self.dimentions.times do |i|
			d += ( (a[i] - b[i]) * (a[i] - b[i]) )
		end
		Math.sqrt(d)
	end

	def dimentions
		@values.size
	end

end

class Group
	attr_accessor :grp_points

	def initialize
		@grp_points = []
	end

	def add_point point
		point.grp_id = self.object_id
		@grp_points << point
	end

	def rem_point point
		@grp_points.delete point
	end

	def mean
		#return mean pos of group
		dim_vals = []
		c = 0
		@grp_points.each do |point|
			point.values.size.times do |i|
				dim_vals[i] ||= 0.00
				dim_vals[i] += point.values[i]
			end
			c+=1
		end
		dim_vals.map{|v| v.to_f/c}
	end

	def size
		@grp_points.size
	end

end

class KCluster
	attr_accessor :groups
	def initialize grp_count = 2
		@points = []
		@torrerance = 0
		@g_count = grp_count 
		@groups = []
		@g_count.times { @groups << Group.new }
		@d = nil
	end

	def add_point point
		@d ||= point.dimentions
		raise "dimentional imcompatability" unless @d == point.dimentions
		@points << point
	end

	def rand_assign
		@points.each do |point|
			r = (rand * (@groups.size-1)).round
			@groups[r].add_point point
		end
	end

	def cluster
		moves = process_points
		puts "Pass 1: #{moves} points moved"
		i = 1
		while moves > @torrerance do 
			moves = process_points
			puts "Pass #{i+=1}: #{moves} points moved"
		end
	end

	def process_points
		moves = 0
		@points.each do |point|
			closest_group = point.get_closest @groups
			a = @groups.select{|grp| grp if grp.object_id == point.grp_id}
			raise "Point was in two groups atst" if a.size > 1
			current_group = a.first
			unless current_group == closest_group
				current_group.rem_point(point)
				closest_group.add_point point
				moves += 1
			end
		end
		moves
	end

	def g_inspect
		@groups.each do |g| 
			puts "group"
			g.grp_points.each {|p| puts "vals: #{p.values.inspect}" }
			puts "mean: #{g.mean.inspect}"
		end
	end

	def demo
		grp_1 =[]
		grp_2 =[]
		8.times do 
			grp_1 << Point.new([(rand*10).round, (rand * 10).round ])
			grp_2 << Point.new([(rand*10).round + 5, (rand * 10).round + 5 ])
		end
		all = [grp_1, grp_2].flatten.sort_by { rand }
		all.each do |point|
			add_point point
		end
		rand_assign
		g_inspect
		cluster
		g_inspect
	end
end

#k = KCluster.new
#k.demo

Shoes.app :resizable => false do
  background gradient(rgb(10, 10, 40), rgb(0, 0, 0))

  title "K-means Cluster", :stroke => white

  stack do
    begin

      k = KCluster.new(2)
    #  (width/2).times do 
    #    k.add_point Point.new([rand, rand, rand])
    #  end

		grp_1 =[]
		grp_2 =[]
		offset = 0.2
		100.times do 
			grp_1 << Point.new( [rand, rand , rand] )
			grp_2 << Point.new( [rand + offset, rand + offset, rand + offset ] )
		end
		all = [grp_1, grp_2].flatten.sort_by { rand }
		all.each do |point|
			k.add_point point
		end

      k.rand_assign
      k.cluster

      k.groups.each do |group|
        nostroke
        fill rgb(rand, rand, rand)

        group.grp_points.each do |point|
          x, y, z = *point.values
          x = x * width
          y = y * height
          z = z * 20
          oval(x, y, z, z)
        end
      end

    rescue Object
      title "Error!", :stroke => red
      para [$!.inspect, $!.message, $!.backtrace.join("\n\t")].flatten.join("\n"), :stroke => white
    end
  end
end
