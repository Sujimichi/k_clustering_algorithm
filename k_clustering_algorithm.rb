#A algorithm for clustering k's :¬)

#Arbitarily assign points to groups
#calculate the mean pos of each group
#check each point and move to group with closest mean pos
#return to step 2 untill no more changes occur.
#

class Point
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

	def values 
		@values
	end

	def grp_id= id
		@grp_id = id
	end

	def grp_id
		@grp_id
	end
end

class KCluster
	def initialize
		@points = []
		@g_count = 2
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

	def process_points
		@points.each do |point|
			g = point.get_closest @groups
			a = @groups.select{|grp| grp if grp.object_id == point.grp_id}
			raise "Point was in two groups atst" if a.size > 1
			a.first.rem_point(point)
			g.add_point point
		end
	end

	def g_inspect
		@groups.each do |g| 
			puts "group"
			g.points.each {|p| puts "vals: #{p.values.inspect}" }
			puts "mean: #{g.mean.inspect}"
		end
	end

	def demo
		grp_1 =[]
		grp_2 =[]
		8.times do 
			grp_1 << Point.new([(rand*10).round, (rand * 10).round ])
			grp_2 << Point.new([(rand*10).round + 20, (rand * 10).round + 20 ])
		end
		all = [grp_1, grp_2].flatten
		all.each do |point|
			add_point point
		end
		rand_assign
		g_inspect
		process_points
		g_inspect
	end
end

class Group
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

	def points 
		@grp_points
	end

end



k = KCluster.new
k.demo
=begin

8.times do 
	k.add_point Point.new([(rand*10).round, (rand * 10).round ])
end
k.rand_assign
k.g_inspect
k.process_points
k.g_inspect

=end
