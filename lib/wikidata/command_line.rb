module Wikidata
  require "thor"
  require "colorize"
  require "terminal-table"

  class CommandLine < Thor
    desc "find ARTICLE_NAME", "find a Wikidata entity by name"
    method_option :fast, default: false, type: :boolean, aliases: "-f"
    method_option :verbose, default: false, type: :boolean, aliases: "-v"
    method_option :show_types, default: false, type: :boolean, aliases: "-t"
    def find(article_name)
      apply_options!
      display_item Wikidata::Item.find_by_title(article_name)
    end

    desc "get ID", "find a Wikidata entity by ID"
    method_option :fast, default: false, type: :boolean, aliases: "-f"
    method_option :verbose, default: false, type: :boolean, aliases: "-v"
    method_option :show_types, default: false, type: :boolean, aliases: "-t"
    def get(article_id)
      apply_options!
      display_item Wikidata::Item.find_by_id(article_id)
    end

    desc "traverse ARTICLE_NAME relation_name", "find all related items until there are no more"
    method_option :verbose, default: false, type: :boolean, aliases: "-v"
    def traverse(article_name, relation_name)
      apply_options!
      item = Wikidata::Item.find_by_title(article_name)
      if item
        puts "#{item.label.green} (#{item.id})"
        loop do
          if (collection = item.entities_for_property_id(relation_name))
            if (item = collection.first)
              puts "#{item.label.green} (#{item.id})"
            else
              break
            end
          end
        end
      end
    end

    protected

    def apply_options!
      Wikidata.verbose = options[:verbose]
    end

    def display_item(item)
      if item
        puts item.label.green.to_s if item.label
        puts item.description.cyan.to_s if item.description
        puts "Wikidata ID: #{item.id}"
        puts "Claims: #{item.claims.length}" if item.claims
        if item.claims.length > 0
          print "Loading claims...\r".yellow
          if !options[:fast]
            headings = ["ID", "Property Label", "Value"]
            headings << "Type" if options[:show_types]
            item.resolve_claims!
            table_data = item.claims.map do |claim|
              should_resolve_value = claim.mainsnak.value.class != Wikidata::DataValues::CommonsMedia
              h = {
                id: claim.mainsnak.property_id,
                label: claim.mainsnak.property.label,
                value: should_resolve_value ? claim.mainsnak.value.resolved : claim.mainsnak.value
              }
              h[:type] = claim.mainsnak.property.datatype if options[:show_types]
              h
            end
          else
            headings = ["Property ID", "Value"]
            table_data = item.claims.map do |claim|
              {id: claim.mainsnak.property_id, value: claim.mainsnak.value}
            end
          end
          # Slightly nicer output
          pids = table_data.map { |d| d[:id] }.uniq
          nice_data = pids.map do |pid|
            all_values = table_data.select { |d| d[:id] == pid }
            all_values.first.merge({value: all_values.map { |d| d[:value] }.join("\n")})
          end
          table = Terminal::Table.new(
            headings: headings,
            rows: nice_data.map { |r| r.values }
            # Broken until https://github.com/visionmedia/terminal-table/pull/30
            # style: {width: 80},
          )
          puts table
        end
      end
    end
  end
end
