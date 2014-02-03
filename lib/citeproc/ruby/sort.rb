module CiteProc
  module Ruby

    module SortItems

      def sort!(items, keys)
        return itmes unless !keys.nil? && !keys.empty?

        # TODO refactor
        if items.is_a?(CitationData)
          items.sort! do |a, b|
            compare_items_by_keys(a.data, b.data, keys)
          end
        else
          items.sort! do |a, b|
            compare_items_by_keys(a, b, keys)
          end
        end
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_keys(a, b, keys)
        result = 0

        keys.each do |key|
          result = compare_items_by_key(a, b, key)
          return result unless result.zero?
        end

        result
      end

      # @returns [-1, 0, 1, nil]
      def compare_items_by_key(a, b, key)
        if key.macro?
          result = renderer.render_sort(a, b, key.macro, key).reduce(&:<=>)

        else
          va, vb = a.data[key.variable], b.data[key.variable]

          # Return early if one side is nil. In this
          # case ascending/descending is irrelevant!
          return  1 if va.nil? || va.empty?
          return -1 if vb.nil? || va.empty?

          result = case CiteProc::Variable.types[key.variable]
            when :names
              node = CSL::Style::Name.new(key.name_options)
              node.all_names_as_sort_order!

              renderer.render_sort(va, vb, node, key).reduce(&:<=>)

            when :date
              va <=> vb
            when :number
              va <=> vb
            else
              va <=> vb
            end
        end

        result = -result unless key.ascending?
        result
      end

    end

  end
end
