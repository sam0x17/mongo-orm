module Mongo::ORM::Collection
  macro included
    macro inherited
      PRIMARY = {name: _id, type: BSON::ObjectId}
    end
  end

  @@adapter = Mongo::ORM::Adapter.new
  def self.adapter
    @@adapter
  end

  def self.db
    @@adapter.database
  end

  # specify the collection name to use otherwise it will use the model's name
  macro collection_name(name)
    {% SETTINGS[:collection_name] = name.id %}
  end

  macro __process_collection
    {% name_space = @type.name.gsub(/::/, "_").downcase.id %}
    {% collection_name = SETTINGS[:collection_name] || name_space + "s" %}
    {% primary_name = PRIMARY[:name] %}
    {% primary_type = PRIMARY[:type] %}

    # Collection Name
    @@collection_name = "{{collection_name}}"
    @@primary_name = "{{primary_name}}"

    # make accessible to outside classes
    def self.collection_name
      @@collection_name
    end
    def self.primary_name
      @@primary_name
    end
    def self.collection
      Mongo::ORM::Collection.db[@@collection_name]
    end

    def self.adapter
      Mongo::ORM::Collection.adapter
    end

    def self.db
      Mongo::ORM::Collection.db
    end

    def id
      _id
    end

    def id=(value : BSON::ObjectId | String)
      if value.is_a?(String)
        _id = BSON::ObjectId.from_string(value)
      else
        _id = value
      end
    end

    # Create the primary key
    property {{primary_name}} : Union({{primary_type.id}} | Nil)
  end
end