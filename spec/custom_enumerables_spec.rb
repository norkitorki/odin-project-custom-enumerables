require_relative '../lib/custom_enumerables'

describe Enumerable do
  # the private iterate method is called in every method tested below
  context 'iterate' do
    it 'should yield each element to a block' do
      expect { |x| ['a', 'b', 'c'].send(:iterate, &x) }.
        to yield_successive_args('a', 'b', 'c')
    end
  end

  context 'my_each' do
    it 'should return an Enumerator if no block is given' do
      expect((0..10).my_each).to be_a(Enumerator)
    end

    it 'should work with a block' do
      expect { [ "a", "b", "c" ].my_each { |x| print x, ' -- ' } }.to output(
        'a -- b -- c -- '
      ).to_stdout

      string = ''
      ('a'..'z').each { |letter| string << letter }

      another_string = ''
      ('a'..'z').my_each { |letter| another_string << letter }

      expect(string).to eq(another_string)
    end

    it 'should work with multiple block variables' do
      expect { {a: 1, b: 2}.my_each { |k, v| puts "#{k} : #{v}" } }.to output(
        "a : 1\nb : 2\n"
      ).to_stdout
    end

    it 'should return the object' do
      expect(('a'..'z').my_each {}).to eq(('a'..'z').each {})
    end
  end

  context 'my_each_with_index' do
    it 'should return an Enumerator if no block is given' do
      expect({}.my_each_with_index).to be_a(Enumerator)
    end

    it 'should work with a block' do
      hash = Hash.new
      %w(cat dog wombat).each_with_index { |item, index| hash[item] = index }

      other_hash = Hash.new
      %w(cat dog wombat).my_each_with_index do |item, index|
        other_hash[item] = index
      end

      expect(hash).to eq(other_hash)
    end

    it 'should return the object' do
      expect(('a'..'z').my_each_with_index {}).to eq(
        ('a'..'z').each_with_index {}
      )
    end
  end

  context 'my_select' do
    it 'should return an Enumerator if no argument nor block is given' do
      expect([].my_select).to be_a(Enumerator)
    end

    it 'should work with a block' do
      expect((1..10).my_select(&:odd?)).to eq((1..10).select(&:odd?))
      expect([120, 20, 5, 31, 10023].my_select { |num| num < 40 }).to eq(
        [120, 20, 5, 31, 10023].select { |num| num < 40 }
      )
    end

    it 'should return an empty array' do
      expect([10, 'str', {}].my_select {}).to eq([10, 'str', {}].select {})
    end
  end

  context 'my_all?' do
    it 'should raise an error when more than one argument is passed' do
      expect { (0..10).my_all?(10, 10) }.to raise_error(ArgumentError)
    end

    it 'should work without passing an argument' do
      expect(['a', 'b', 100].my_all?).to eq(['a', 'b', 100].all?)
      expect(['a', 'b', 100, nil].my_all?).to eq(['a', 'b', 100, nil].all?)
    end

    it 'should work when called with an argument' do
      expect((0..10).my_all?(Numeric)).to eq((0..10).all?(Numeric))
      expect(%w[horse horse horse].my_all?('horse')).to eq(
        %w[horse horse horse].all?('horse')
      )
    end

    it 'should work with a block' do
      expect(%w[ant bear cat].my_all? { |word| word.length >= 3 }).to eq(
        %w[ant bear cat].all? { |word| word.length >= 3 }
      )
      expect(%w[ant bear cat].my_all? { |word| word.length >= 4 }).to eq(
        %w[ant bear cat].all? { |word| word.length >= 4 }
      )
    end

    it 'should return true when called on an empty collection' do
      expect([].my_all?).to eq([].all?)
      expect({}.my_all?).to eq({}.all?)
    end

    it 'should display a warning when the block is unused' do
      expect { [10].my_all?(10) {} }.to output(
        "warning: given block not used\n"
      ).to_stderr
    end
  end

  context 'my_any?' do
    it 'should raise an error when more than one argument is passed' do
      expect { (0..10).my_any?(10, 10) }.to raise_error(ArgumentError)
    end

    it 'should work without passing an argument' do
      expect([nil, true, 99].my_any?).to eq([nil, true, 99].any?)
      expect([nil, false, nil].my_any?).to eq([nil, false, nil].any?)
    end

    it 'should work when called with an argument' do
      expect((0..10).my_any?(Numeric)).to eq((0..10).any?(Numeric))
      expect(%w[dog horse goat].my_any?('horse')).to eq(
        %w[dog horse goat].any?('horse')
      )
    end

    it 'should work with a block' do
      expect(%w[ant bear cat].my_any? { |word| word.length >= 3 }).to eq(
        %w[ant bear cat].any? { |word| word.length >= 3 }
      )
      expect(%w[ant bear cat].my_any? { |word| word.length >= 5 }).to eq(
        %w[ant bear cat].any? { |word| word.length >= 5 }
      )
    end

    it 'should return false when called on an empty collection' do
      expect([].my_any?).to eq([].any?)
      expect({}.my_any?).to eq({}.any?)
    end

    it 'should display a warning when the block is unused' do
      expect { [5].my_any?(10) {} }.to output(
        "warning: given block not used\n"
      ).to_stderr
    end
  end

  context 'my_none?' do
    it 'should raise an error when more than one argument is passed' do
      expect { (0..10).my_none?(10, 10) }.to raise_error(ArgumentError)
    end

    it 'should work without passing an argument' do
      expect([nil, true, 99].my_none?).to eq([nil, 20, false].none?)
      expect([nil, false, nil].my_none?).to eq([nil, false, nil].none?)
    end

    it 'should work when called with an argument' do
      expect((0..10).my_none?(Numeric)).to eq((0..10).none?(Numeric))
      expect(%w[dog horse goat].my_none?('horse')).to eq(
        %w[dog horse goat].none?('horse')
      )
    end

    it 'should work with a block' do
      expect(%w{ant bear cat}.my_none? { |word| word.length == 5 }).to eq(
        %w{ant bear cat}.none? { |word| word.length == 5 }
      )
      expect(%w{ant bear cat}.my_none? { |word| word.length >= 4 }).to eq(
        %w{ant bear cat}.none? { |word| word.length >= 4 }
      )
    end

    it 'should return true when called on an empty collection' do
      expect([].my_none?).to eq([].none?)
      expect({}.my_none?).to eq({}.none?)
    end

    it 'should display a warning when the block is unused' do
      expect { [5].my_none?(10) {} }.to output(
        "warning: given block not used\n"
      ).to_stderr
    end
  end

  context 'my_count' do
    it 'should raise an error when more than one argument is passed' do
      expect { (0..10).my_count(10, 10) }.to raise_error(ArgumentError)
    end

    it 'should work without passing an argument' do
      expect((0..10).my_count).to eq((0..10).count)
      expect(%w[apple orange tomato].my_count).to eq(
        %w[apple orange tomato].count
      )
    end

    it 'should work when called with an argument' do
      expect([20, 42, 20, 100].my_count(20)).to eq([20, 42, 20, 100].count(20))
      expect(%w[apple orange apple].my_count('apple')).to eq(
        %w[apple orange apple].count('apple')
      )
    end

    it 'should work with a block' do
      expect((0..10).my_count(&:even?)).to eq((0..10).count(&:even?))
      expect([20, 42, 15, 10].my_count { |num| num >= 20}).to eq(
        [20, 42, 15, 10].count { |num| num >= 20}
      )
    end

    it 'should display a warning when the block is unused' do
      expect { [].my_count(4) {} }.to output(
        "warning: given block not used\n"
      ).to_stderr
    end
  end

  context 'my_map' do
    it 'should return an Enumerator if no block nor proc is given' do
      expect((0..10).my_map).to be_a(Enumerator)
    end

    it 'should work with a block' do
      expect((1..4).my_map { |i| i * i }).to eq((1..4).map { |i| i * i })
      expect({a: 1, b: 2}.my_map { |k, v| [k.next, v * 2] }).to eq(
        {a: 1, b: 2}.map { |k, v| [k.next, v * 2] }
      )
    end

    it 'should use a proc when passed as an argument' do
      prc = proc { |num| num > 4 ? num : 0 }
      expect((0..10).my_map(prc)).to eq([0, 0, 0, 0, 0, 5, 6, 7, 8, 9, 10])
    end
  end

  context 'my_inject' do
    it 'should raise an error when more than two arguments are passed' do
      expect { (0..10).my_inject(10, 10, 20) }.to raise_error(ArgumentError)
    end

    it 'should raise an error when no argument nor block is given' do
      expect { (0..10).my_inject }.to raise_error(LocalJumpError)
    end

    it 'should work when called with a method' do
      expect((0..10).my_inject(:+)).to eq((0..10).inject(:+))
      expect([2, 4, 5].my_inject(:*)).to eq([2, 4, 5].inject(:*))
    end

    it 'should work when called with two both an initial memo and a method' do
      expect((1..10).my_inject(1, :*)).to eq((1..10).inject(1, :*))
      expect((20..40).my_inject(20, :+)).to eq((20..40).inject(20, :+))
    end

    it 'should work with a block' do
      expect([1024, 32, 2324].my_inject { |sum, num| sum + num }).to eq(
        [1024, 32, 2324].inject { |sum, num| sum + num }
      )
      expect(
        %w{ cat sheep bear }.my_inject do |memo, word|
          memo.length > word.length ? memo : word
        end
      ).to eq(
        %w{ cat sheep bear }.inject do |memo, word|
          memo.length > word.length ? memo : word
        end
      )
    end
  end

end
