class Dog
    attr_accessor :name, :breed, :id
    
    def initialize(name:, breed:, id: nil)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = %Q(
            CREATE TABLE IF NOT EXISTS dogs(
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            )
        )
        DB[:conn].execute(sql)

    end

    def self.drop_table
        sql = %Q(
            DROP TABLE dogs
        )
        DB[:conn].execute(sql)
    end

    def save
        #when opbjects are initiated, id is set to nil, when they are persisted to database, their id is set to the id 
        # in the database.
        # if Instance or object calling #save has an id(it's in the db), call #update on that instance
        if self.id
            self.update
            
        # else if the Instance does not have an id, then it's not yet in the database, insert it's attribute into the database
        else
            sql = %Q(
            INSERT INTO dogs(name, breed)
            VALUES(?,?)
            )
            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs ")[0][0]
            self #returns new object created
        end
    end

    def self.create(name:, breed:)
        new_dog = Dog.new(name: name, breed: breed)
        new_dog.save
    end

    def self.new_from_db(row)
        self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.all
        sql = %Q(
            SELECT * FROM dogs
        )
        DB[:conn].execute(sql).map do |item|
            self.new_from_db(item)
        end
    end

    def self.find_by_name(name)
        sql = %Q(
            SELECT * FROM dogs WHERE name = ?
        )
        DB[:conn].execute(sql, name).map do |item|
            self.new_from_db(item)
        end.first

    end

    def self.find(id)
        sql = %Q(
            SELECT * FROM dogs WHERE id = ?
        )
        DB[:conn].execute(sql, id).map do |item|
            self.new_from_db(item)
        end.first
    end

    def self.find_or_create_by(name:, breed:)
        sql = %Q(
            SELECT * FROM dogs WHERE name = ? AND breed = ?
        )
        result = DB[:conn].execute(sql, name, breed).first

        if result
            self.new_from_db(result)
        else
            self.create(name: name, breed: breed)
        end
    end

    def update
        sql = %Q(
            UPDATE dogs
            SET name = ?, breed = ? WHERE id = ?
        )
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
end
