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
        puts "  Wikidata ID: #{item.id}"
        puts "  Claims: #{item.claims.length}" if item.claims

        if options[:resolve_properties]
          table_data = item.claims.map do |claim|
            { :id => claim.mainsnak.property_id,
              'Property Label' => claim.mainsnak.property.label,
              value: claim.mainsnak.value.resolved}
          end
        else
          table_data = item.claims.map do |claim|
            {:property_id => claim.mainsnak.property_id, value: claim.mainsnak.value}
          end
        end

        Formatador.display_table(table_data)

      end
    end

  end
end