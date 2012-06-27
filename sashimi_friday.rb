module SashimiFriday
  def all?(&block)
    each do |*item|
      return false unless pick(item, &block)
    end
    return true
  end

  def any?(&block)
    each do |*item|
      return true if pick(item, &block)
    end
    return false
  end

  def none?(&block)
    each do |*item|
      return false if pick(item, &block)
    end
    return true
  end

  def one?(&block)
    result = nil
    each do |*item|
      if pick(item, &block)
        case result
        when nil
          result = true
        when true
          return false
        end
      end
    end
    return false unless result
    return result
  end

  def chunk
  end

  def collect(&block)
    return enum_for(__method__) unless block
    results = []
    each do |*item|
      results << pick(item, &block)
    end
    return results
  end

  alias map collect

  def collect_concat
  end

  def count(*args, &block)
    found = 0
    case args.size
    when 0
      if block_given?
        each do |item|
          found += 1 if block.call(item)
        end
      else
        each do |item|
          found += 1
        end
      end
    when 1
      arg = args.first
      each do |item|
        found += 1 if item == arg
      end
    else
      raise ArgumentError
    end
    return found
  end

  def cycle(*args, &block)
    return enum_for(__method__, *args) unless block
    raise ArgumentError if args.size > 1
    n = args.first
    unless n.nil?
      begin
        n = Integer(n)
        return if n <= 0
      rescue
        raise TypeError
      end
    end
    ary = []
    each do |*item|
      item = pick(item)
      ary << item
      block.call(item)
    end
    return if ary.empty?
    (1...(n || Float::INFINITY)).each do
      ary.each do |item|
        block.call(item)
      end
    end
    return nil
  end

  def drop(n)
    results = []
    begin
      n = Integer(n)
    rescue
      raise TypeError
    end
    raise ArgumentError if n < 0
    each do |*item|
      next if (n = n.pred) >= 0
      results << pick(item)
    end
    return results
  end

  def take(n)
    results = []
    begin
      n = Integer(n)
    rescue
      raise TypeError
    end
    raise ArgumentError if n < 0
    return results if n.zero?
    each do |*item|
      item = pick(item)
      results << item
      break if (n = n.pred) <= 0
    end
    return results
  end

  def drop_while
  end

  def each_cons
  end

  def each_entry(*args, &block)
    return enum_for(__method__, *args) unless block
    each(*args) do |*item|
      item = pick(item)
      block.call(item)
    end
    return self
  end

  def each_slice
  end

  def each_with_index(*args, &block)
    return enum_for(__method__, *args) unless block
    index = -1
    each(*args) do |*item|
      item = pick(item)
      block.call(item, index = index.next)
    end
    return self
  end

  def each_with_object
  end

  def entries
  end

  def find(ifnone = nil, &block)
    return enum_for(__method__, ifnone) unless block
    each do |*item|
      item = pick(item)
      return item if block.call(item)
    end
    ifnone.call if ifnone
  end

  alias detect find

  def find_all(&block)
    return enum_for(__method__) unless block
    results = []
    each do |*item|
      item = pick(item)
      results << item if block.call(item)
    end
    return results
  end

  alias select find_all

  def find_index
  end

  def first(*n)
    if(n.empty?)
      index = 1
    else
      begin
        index = Integer(n.first)
      rescue
        raise TypeError
      end
      return [] if index.zero?
      raise ArgumentError if index < 0
    end

    result = []
    begin
      each do |*item|
        result << pick(item) 
        break if (index -= 1).zero?
      end
    rescue
      return []
    end
    
    return nil if result.empty? && n.empty?
    return result.first if result.size == 1 && n.empty?
    return result
  end

  def flat_map
  end

  def grep(pattern)
    result = []
    each do |item|
      if pattern === item
        result << (block_given? ? yield(item) : item)
      end
    end
    return result
  end

  def group_by
  end

  def include?(args, &block)
    each() do |*item| 
      return true if pick(item) == args
    end 
    return false
  end

  def inject
  end

  def lazy
  end

  def max
    _max = nil
    init = false
    each do |*item|
      item = item.first if item.length == 1
      unless init
        _max = item
        init = true
        next
      end

      cmp = if block_given?
              yield(item, _max)
            else
              item <=> _max
            end
      raise ArgumentError unless cmp
      _max = item if cmp > 0
    end
    _max
  end

  def max_by
  end

  def member?
  end

  def min
  end

  def min_by
  end

  def minmax
  end

  def minmax_by
  end

  def partition
  end

  def reduce
  end

  def reject
  end

  def reverse_each(*args, &block)
    return enum_for(__method__, *args) unless block
    to_a.reverse.each() do |item| 
      block.call(item) 
    end 
  end

  def slice_before
  end

  def sort
  end

  def sort_by
  end

  def take_while(*args, &block)
    return enum_for(__method__, *args) unless block
    results = []
    each() do |item| 
        break unless(block.call(*item)) 
        results << item 
    end 
    return results 
  end

  def to_a(*args)
    #下記だとテストは徹がreverse_eachの最後のテストでおかしくなる 
    #  each(*args){|*item|}
    #  pick　超便利だった
    results = []
    each(*args) do |*item| 
        results << pick(item)
    end 
    results 
  end

  def zip(*args)
  end

  private

  def pick(item, &block)
    if block
      block.call(*item)
    else
      item.size == 1 ? item.first : item
    end
  end
end
