module Kaminari
  module PageExtensions
    def calculate_offset(num)
      num =  default_per_page * ([num.to_i, 1].max - 1)
      goto_page = Kaminari.config.out_of_range

      return 0 if goto_page == :first && out_of_range?(num)
      return count - default_per_page if goto_page == :last && out_of_range?(num)
      num
    end

    def out_of_range?(num)
      num + 1 > count
    end
  end
end
