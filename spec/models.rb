ActiveRecord::Base.establish_connection(
  adapter: "sqlite3",
  database: File.join(File.dirname(__FILE__), "test.db")
)

class CreateSchema < ActiveRecord::Migration[5.2]
  def up
    create_table :users, force: true do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :username
      t.boolean :admin, default: false
    end

    create_table :posts, force: true do |t|
      t.string :title
      t.integer :author_id
    end

    create_table :business, force: true do |t|
      t.string :name
      t.integer :owner_id
    end
  end
end

CreateSchema.suppress_messages { CreateSchema.migrate(:up) }

class User < ActiveRecord::Base
  has_many :posts, foreign_key: "author_id"

  validates :first_name, :last_name, :email, presence: true
end

class Post < ActiveRecord::Base
  belongs_to :author, class_name: "User"

  validates :title, presence: true
end

class Business < ActiveRecord::Base
  belongs_to :owner, class_name: "User"

  validates :name, :owner_id, presence: true
end
