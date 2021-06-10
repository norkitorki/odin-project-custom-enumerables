# Enumerable expanded with custom methods
module Enumerable
  def my_each(&block)
    return to_enum unless block_given?

    iterate(&block)

    self
  end

  def my_each_with_index
    return to_enum unless block_given?

    i = -1
    iterate { |el| yield(el, i += 1) }

    self
  end

  def my_select
    return to_enum unless block_given?

    output = []
    iterate { |el| output << el if yield(el) }

    output
  end

  def my_all?(*args)
    custom_argument_error(args, 1)

    if args.empty?
      iterate { |el| return false unless block_given? ? yield(el) : el }
    else
      warn 'warning: given block not used' if block_given? && length.positive?
      iterate { |el| return false unless args.first === el }
    end

    true
  end

  def my_any?(*args)
    custom_argument_error(args, 1)

    if args.empty?
      iterate { |el| return true if block_given? ? yield(el) : el }
    else
      warn 'warning: given block not used' if block_given? && length.positive?
      iterate { |el| return true if args.first === el }
    end

    false
  end

  def my_none?(*args)
    custom_argument_error(args, 1)

    if args.empty?
      iterate { |el| return false if block_given? ? yield(el) : el }
    else
      warn 'warning: given block not used' if block_given? && length.positive?
      iterate { |el| return false if args.first === el }
    end

    true
  end

  def my_count(*args)
    custom_argument_error(args, 1)

    count = 0
    if args.empty?
      iterate { |el| count += 1 if block_given? ? yield(el) : el }
    else
      warn 'warning: given block not used' if block_given?
      iterate { |el| count += 1 if el.eql?(args.first) }
    end

    count
  end

  def my_map(proc = nil)
    return to_enum unless proc.is_a?(Proc) || block_given?

    output = []
    iterate { |el| proc ? output << proc.call(el) : output << yield(el) }

    output
  end

  def my_inject(*args)
    custom_argument_error(args, 2)

    memo   = args.first
    method = args.last
    if block_given? && args.length <= 1
      iterate { |el| memo = memo ? yield(memo, el) : el }
    else
      raise LocalJumpError, 'no block given' if args.empty?

      iterate { |el| memo = memo.is_a?(Symbol) ? el : memo.send(method, el) }
    end

    memo
  end

  private

  def iterate
    entries.length.times { |i| yield(entries[i]) }
  end

  def custom_argument_error(arguments, max_length)
    if arguments.length > max_length
      raise ArgumentError, 'wrong number of arguments ' \
        "(given #{arguments.length}, expected 0..#{max_length})"
    end
  end
end
