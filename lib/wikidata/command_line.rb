module Wikidata
  require 'thor'
  require 'colorize'
  require 'formatador'

  class CommandLine < Thor

    desc "find ARTICLE_NAME", "find a Wikidata entity by name"
    method_option :resolve_properties, :default => false, type: :boolean, aliases: "-r"
    def find(article_name)
      item =  Wikidata::Item.find_by_title(article_name)
      display_item item
    end

    desc "get ID", "find a Wikidata entity by ID"
    method_option :resolve_properties, :default => false, type: :boolean, aliases: "-r"
    def get(article_id)
      display_item Wikidata::Item.find_by_id(article_id)
    end

    desc "traverse ARTICLE_NAME relation_name", "find all related items until there are no more"
    def traverse(article_name, relation_name)
      item = Wikidata::Item.find_by_title(article_name)
      if item
        puts "#{item.label.green} (#{item.id})"
        while true
          if collection = item.entities_for_property_id(relation_name)
            if item = collection.first
              puts "#{item.label.green} (#{item.id})"
            else
              break
            end
          end
        end
      end
    end

  protected

    def display_item(item)
      if item
        puts "  #{item.label.green}" if item.label
        puts "  #{item.description.cyan}" if item.description
        puts "  Wikidata ID: #{item.id}"
        puts "  Claims: #{item.claims.length}" if item.claims
        if item.claims.length > 0
          if options[:resolve_properties]
            item.resolve_claims!
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
end