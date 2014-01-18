module Wikidata
  require 'thor'
  require 'colorize'
  require 'formatador'

  class CommandLine < Thor

    desc "find article_name", "fetch headlines from a sources"
    method_option :resolve_properties, :default => false, type: :boolean, aliases: "-r"
    def find(article_name)
      item = Wikidata::Item.find_by_title(article_name)
      if item
        puts "  #{item.label.green}" if item.label
        puts "  #{item.description.cyan}" if item.description
        puts "  #{item.claims.length} claim(s)" if item.claims

        if options[:resolve_properties]
          table_data = item.resolved_properties.map do |property, datavalue|
            {property: property.label, property_id: property.id, value: datavalue}
          end
        else
          table_data = item.simple_properties.map do |k, v|
            {property_id: k, value: v}
          end
        end

        Formatador.display_table(table_data)

      end
    end

  end
end